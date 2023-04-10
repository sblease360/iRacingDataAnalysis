import json
import requests
import pickle
import pyodbc
import datetime
from dateutil import parser

COOKIE_FILE = "irCookieJar.json"
CRED_FILE = "credentials.json"
IR_SESSION_URL = "https://members-ng.iracing.com/data/results/get?"
IR_LAPS_URL = "https://members-ng.iracing.com/data/results/lap_data?"

CONN_STR = (
    r'DRIVER={SQL Server};'
    r'SERVER=(local)\SQLEXPRESS;'
    r'DATABASE=iRacingData;'
    r'Trusted_Connection=yes;'
)
CNXN = pyodbc.connect(CONN_STR)
CURSOR = CNXN.cursor()

def getCredentials():
    """Get credentials stored in local JSON file, returns dictionary containing email and password"""
    try:
        file = open(CRED_FILE, "r")
        text = file.read()
        file.close()
        return json.loads(text)
        
    except FileExistsError:
        print (f"Credentials file not found, please created {CRED_FILE} and try again")
        exit()

def getCookie():
    """Returns the contents of the local cookie file"""
    try:
        file = open(COOKIE_FILE, "rb")
        text = file.read()
        file.close()
        return pickle.loads(text)
    except FileExistsError:
        authenticate(getCredentials())
        getCookie()

def storeCookie(contents):
    """Stores a cookie file locally for use as required"""
    file = open(COOKIE_FILE, "wb")    
    file.write(contents)
    file.close
    print("Cookie File Updated")

def authenticate(credentials):
    """Authenticates with iRacing"""
    r = requests.post("https://members-ng.iracing.com/auth", data=credentials)
    if r.status_code == 200 and not json.loads(r.text)["authcode"] == 0:
        print ("Authenticated with iRacing")
        storeCookie(pickle.dumps(r.cookies))

def runQuery(url, includeCookie = False, params={}):
    """
    Runs a query to a specified URL, if cookie is needed this is included
    If the result contains a link attribute, this method returns the data found at this link
    Otherwise returns text value of initial query
    """
    if includeCookie:
        cookie = getCookie()
        r = requests.get(f"{url}", cookies=cookie, params=params)
    else: 
        r = requests.get(f"{url}", params=params)  

    # If this returns an unauthorised error then re-auth and try again
    i = json.loads(r.text)
    if 'error' in i and i['error'] == 'Unauthorized':
        authenticate(getCredentials())
        r2 = runQuery(url, includeCookie, params)
        return r2

    #if this returns just a link, get the actual data from the link
    if 'link' in i:
        r2 = runQuery(i['link'], includeCookie, params)
        return r2

    return r.text

def getSessionData(sessionID):
    """Returns a dictionary of the session details if data is successfully located"""
    session_params = {
        "subsession_id": sessionID
    }
    print (session_params)
    data = runQuery(IR_SESSION_URL, True, session_params)
    return json.loads(data)

def getDriverSessionList(sessionData):
    """Takes in session data and returns list of DriverID~SimSessionID"""    
    driverSessions = [] 
    for i in session_data["session_results"]:
        for j in i["results"]:
            driverSessions.append(f"{j['cust_id']}~{i['simsession_number']}")
    return driverSessions

def getLapData(session_id, driver_id, simsession_no):
    """Gets the lap data for a specific driver in a specific session"""
    params = {
        "subsession_id": session_id,
        "simsession_number": simsession_no,
        "cust_id": driver_id,
    }
    chunk_raw = runQuery(IR_LAPS_URL, True, params)
    chunk_data = json.loads(chunk_raw)

    try: 
        data_raw = ''
        for i in chunk_data['chunk_info']['chunk_file_names']:
            data_raw = data_raw + runQuery(f"{chunk_data['chunk_info']['base_download_url']}{i}")
        return json.loads(data_raw)
    except KeyError as e:
        print (f"Error getting lap data: {e}")
        exit()

def sendTrackDetailsToDB(location, layout, layout_length, corners_per_lap):
    """Send the details of the track to the DB for storing, de-duplication is handled at the DB"""
    CURSOR.execute(f"""
                    EXEC sp_CreateLocationAndLayout 
                    @LocationName = '{session_data['track']['track_name']}', 
                    @LayoutName = '{session_data['track']['config_name']}', 
                    @LayoutLength = 0, 
                    @LayoutCorners = {session_data['corners_per_lap']}
                """)
    CURSOR.commit()
    print ("Track Details sent to DB")

def sendEventDetailsToDB(track_name, config_name, subsession_id, 
                        session_name, start_datetime_str, hosted, 
                        official, sim_start_utc, utc_offset, temp, humidity):
    CURSOR.execute(f"SELECT TOP 1 ID FROM Locations WHERE Name = '{track_name}'") 
    LocationID = CURSOR.fetchval()

    CURSOR.execute(f"""
                    SELECT TOP 1 lay.ID FROM Locations loc 
                    INNER JOIN Layouts lay ON loc.ID = lay.LocationID 
                    WHERE Loc.Name = '{track_name}' 
                    AND lay.Name = '{config_name}'
                    """) 
    LayoutID = CURSOR.fetchval()

    sim_start = parser.parse(sim_start_utc) + datetime.timedelta(0,60 * utc_offset)

    CURSOR.execute (f"""
                    EXEC sp_CreateEvent 
                    @EventID = {subsession_id}, 
                    @Description = '{session_name}', 
                    @EventDate = '{parser.parse(start_datetime_str).date()}', 
                    @Hosted = {hosted}, 
                    @Official = {official}, 
                    @EventStartTime = '{parser.parse(start_datetime_str).time()}', 
                    @InSimDate = '{sim_start.date()}', 
                    @InSimStartTime = '{sim_start.time()}', 
                    @LocationID = {LocationID}, 
                    @LayoutID = {LayoutID}, 
                    @Temp = {temp},
                    @Humidity = {humidity}
                """)
    CURSOR.commit()
    print ("Event details sent to DB")
  
def sendSessionLevelDataToDB(session_data):
    sendTrackDetailsToDB(session_data['track']['track_name'], 
                            session_data['track']['config_name'],
                            0,
                            session_data['corners_per_lap']
                        )
    if 'session_name' in session_data:
        session_name = session_data['session_name']
    else:
        session_name = session_data['season_name']

    sendEventDetailsToDB(session_data['track']['track_name'],
                            session_data['track']['config_name'],
                            session_data['subsession_id'],
                            session_name,
                            session_data['start_time'],
                            session_data['season_name'] == "Hosted iRacing", # TODO: Find a way to determine hosted vs others
                            session_data['official_session'],
                            session_data['weather']['simulated_start_utc_time'],
                            session_data['weather']['simulated_start_utc_offset'],
                            session_data['weather']['temp_value'],
                            session_data['weather']['rel_humidity']
                        )
class Driver:
    def __init__(self, d_id, d_name, d_club, oldiRating, newiRating):
        self.d_id = d_id
        self.d_name = d_name
        self.d_club = d_club
        self.d_oldiRating = oldiRating
        self.d_newiRating = newiRating

class Car:
    def __init__(self, carID, carName, classID, className):
        self.carID = carID
        self.carName = carName
        self.classID = classID
        self.className = className

class Entry:
    def __init__(self, eventID, iRacingID, carID, entryName, isTeam, drivers):
        self.eventID = eventID
        self.iRacingID = iRacingID
        self.carID = carID
        self.entryName = entryName
        self.isTeam = isTeam
        self.drivers = drivers

def processSessionDriverLevelData(session_data):
    """
        Create python objects containing all required data to add to DB
        Additional API queries are required for lap level changes.
        
    """
    drivers = [] # list of Drivers
    cars = [] #list of Cars
    eventEntries = [] #list of Entry 


    for i in session_data['session_results']:
        for j in i['results']:
            car = Car(j['car_id'], j['car_name'], j['car_class_id'], j['car_class_name'])
            entry = Entry(session_data['subsession_id'], 0, j['car_id'], j['display_name'], False, [])
            if 'team_id' in j:
                # Team entry specific settings
                entry.isTeam = True
                entry.iRacingID = j['team_id']
                for k in j['driver_results']:
                    driver = Driver(k['cust_id'], k['display_name'], k['club_name'], k['oldi_rating'], k['newi_rating'])
                    entry.drivers.append(driver)
                    if not driver in drivers:
                        drivers.append(driver)
            else:
                # Single driver setup
                entry.isTeam = False
                entry.iRacingID = j['cust_id']                
                driver = Driver(j['cust_id'], j['display_name'], j['club_name'], j['oldi_rating'], j['newi_rating'])
                entry.drivers.append(driver)            
                if not driver in drivers:
                    drivers.append(driver)

            if not car in cars:
                cars.append(car)

            if not entry in eventEntries:
                eventEntries.append(entry)

    addDriverDetailsToDB(drivers)
    addCarDetailsToDB(cars)
    addEntryDetailsToDB(eventEntries)

def addEntryDetailsToDB(entries):
    for i in entries:
        for j in i.drivers:
            CURSOR.execute (f"""
                        EXEC sp_CreateEventEntriesAndEntryDrivers
                        @EventID = '{i.eventID}', 
                        @iRacingID = '{i.iRacingID}', 
                        @CarID = '{i.carID}', 
                        @Name = '{i.entryName.replace("'"," ")}',
                        @isTeam = '{i.isTeam}',
                        @DriverID = '{j.d_id}',
                        @OldiRating = '{j.d_oldiRating}',
                        @NewiRating = '{j.d_newiRating}'""")
    print ("Adding Entry details to DB")
    CURSOR.commit()

def addCarDetailsToDB(cars):
    for i in cars:
        CURSOR.execute (f"""
                    EXEC sp_CreateCarsAndClasses
                    @iRacingID = {i.carID}, 
                    @CarName = '{i.carName}', 
                    @ClassID = '{i.classID}', 
                    @ClassName = '{i.className}'
                """)
    print ("Adding driver details to DB")
    CURSOR.commit()
    

def addDriverDetailsToDB(drivers):
    for i in drivers:
        CURSOR.execute (f"""
                    EXEC sp_CreateDriver
                    @ID = {i.d_id}, 
                    @Name = '{i.d_name.replace("'"," ")}', 
                    @Club = '{i.d_club}', 
                    @Notes = ''
                """)
    print ("Adding driver details to DB")
    CURSOR.commit()

if __name__ == "__main__":
    session_id = input("Please enter comma separated list of session ids: ")
    for i in session_id.split(","):
        print (i.strip())
        session_data = getSessionData(i.strip())
        
        sendSessionLevelDataToDB(session_data)

        processSessionDriverLevelData(session_data)

    print ("Script completed")
    #print (json.dumps(session_data)) 


    #driver_session_list = getDriverSessionList(session_data)  
    # Get individual lap data for each driver and session
    #     j = i.split("~")
    #     print(getLapData(session_id, j[0], j[1]))
        

    exit()