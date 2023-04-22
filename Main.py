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
    r'DRIVER={ODBC Driver 17 for SQL Server};'
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
    print (f"Querying API: {url} \nwith parameters: {params}")

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
    data = runQuery(IR_SESSION_URL, True, session_params)
    return json.loads(data)

def getDriverSessionList(sessionData):
    """Takes in session data and returns list of DriverID~SimSessionID~SessionName~TeamID"""    
    driverSessions = [] 
    for i in session_data["session_results"]:
        for j in i["results"]:
            if 'team_id' in j:
                for k in j['driver_results']:
                    driverSessions.append(f"{k['cust_id']}~{i['simsession_number']}~{i['simsession_name']}~{j['team_id']}")
            else:    
                driverSessions.append(f"{j['cust_id']}~{i['simsession_number']}~{i['simsession_name']}~0")
    return driverSessions

def getLapData(session_id, driver_id, simsession_no, team_id):
    """Gets the lap data for a specific driver in a specific session"""
    params = {
        "subsession_id": session_id,
        "simsession_number": simsession_no,
        "cust_id": driver_id,
    }
    if (team_id != 0):
        params['team_id'] = team_id
    chunk_raw = runQuery(IR_LAPS_URL, True, params)
    chunk_data = json.loads(chunk_raw)

    try: 
        data_raw = ''
        if chunk_data['chunk_info'] == None:
            #No lap data available for this sub-session
            return []
        for i in chunk_data['chunk_info']['chunk_file_names']:
            data_raw = data_raw + runQuery(f"{chunk_data['chunk_info']['base_download_url']}{i}")
        return json.loads(data_raw)
    except KeyError as e:
        print (f"Error getting lap data: {e}")
        exit()
    except TypeError as e:
        print (f"Error getting lap data: {e}")
        exit()

def sendTrackDetailsToDB(location, layout, layout_length, corners_per_lap):
    """Send the details of the track to the DB for storing, de-duplication is handled at the DB"""
    CURSOR.execute(f"""
                    EXEC sp_CreateLocationAndLayout 
                    @LocationName = '{session_data['track']['track_name']}', 
                    @LayoutName = '{session_data['track']['config_name']}', 
                    @TrackLength = 0, 
                    @Corners = {session_data['corners_per_lap']}
                """)
    CURSOR.commit()
    print ("Track Details sent to DB")

def sendEventDetailsToDB(track_name, config_name, subsession_id, 
                        session_name, start_datetime_str, hosted, 
                        official, sim_start_utc, utc_offset, temp, humidity, season_name, year, quarter, sof):
    sim_start = parser.parse(sim_start_utc) + datetime.timedelta(0,60 * utc_offset)

    if quarter is None:
        quarter = "Null"
    if sof is None:
        sof = "Null"

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
                    @LocationName = '{track_name}',
                    @LayoutName = '{config_name}',
                    @Temp = {temp},
                    @Humidity = {humidity},
                    @SeasonName = '{season_name}',
                    @Year = {year},
                    @Quarter = {quarter},
                    @SoF = {sof}
                """)
    CURSOR.commit()
    print ("Event details sent to DB")
  
def processSessionLevelData(session_data):
    sendTrackDetailsToDB(session_data['track']['track_name'], 
                            session_data['track']['config_name'],
                            0,
                            session_data['corners_per_lap']
                        )
    if 'session_name' in session_data:
        session_name = session_data['session_name']
    else:
        session_name = session_data['season_name']

    if session_data['season_name'] == "Hosted iRacing":
        year = datetime.datetime.now().year
        quarter = None
        sof = None
    else:
        year = session_data['season_year']
        quarter = session_data['season_quarter']
        sof = session_data['event_strength_of_field']

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
                            session_data['weather']['rel_humidity'],
                            session_data['season_name'],
                            year,
                            quarter,
                            sof
                        )
class Driver:
    def __init__(self, driverID, driverName, driverClub, oldiRating, newiRating):
        self.driverID = driverID
        self.driverName = driverName
        self.driverClub = driverClub
        self.previRating = oldiRating
        self.newiRating = newiRating

class Car:
    def __init__(self, carID, carName, classID, className):
        self.carID = carID
        self.carName = carName
        self.classID = classID
        self.className = className

class Entry:
    def __init__(self, eventID, sessionID, iRacingID, carID, carClassID, entryName, isTeam, drivers, incidents, finishPos):
        self.eventID = eventID
        self.sessionID = sessionID
        self.iRacingID = iRacingID
        self.carID = carID
        self.carClassID = carClassID
        self.entryName = entryName
        self.isTeam = isTeam
        self.drivers = drivers
        self.incidents = incidents
        self.finishPos = finishPos + 1

class Session:
    def __init__(self, eventID, simsession_no, session_name, session_type):
        self.eventID = eventID
        self.simsession_no = simsession_no
        self.session_type = session_type
        self.session_name = session_name

def processSessionDriverLevelData(session_data):
    """
        Create python objects containing all required data to add to DB
        Additional API queries are required for lap level changes.
        
    """
    drivers = [] # list of Drivers
    cars = [] #list of Cars
    eventEntries = [] #list of Entry 
    sessions = [] #list of Session

    eventID = session_data['subsession_id']


    for i in session_data['session_results']:
        session = Session(eventID, i['simsession_number'],i['simsession_name'], i['simsession_type_name'])
        for j in i['results']:
            car = Car(j['car_id'], j['car_name'], j['car_class_id'], j['car_class_name'])
            entry = Entry(eventID, i['simsession_number'],0, j['car_id'], j['car_class_id'], j['display_name'], False, [], j['incidents'], j['finish_position_in_class'])
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

        if not session in sessions:
            sessions.append(session)

    addDriverDetailsToDB(drivers)
    addCarDetailsToDB(cars)
    addSessionDetailsToDB(sessions)
    addEntryDetailsToDB(eventEntries)
    

def addSessionDetailsToDB(sessions):
    for i in sessions:

        CURSOR.execute (f"""
                    EXEC sp_CreateSession
                    @EventID = {i.eventID}, 
                    @SessioniRacingID = {i.simsession_no},
                    @SessionType = '{i.session_type}',
                    @SessionName = '{i.session_name}',
                    @SimStartTime = ''
                """)
    print ("Adding session details to DB")
    CURSOR.commit()

def addEntryDetailsToDB(entries):
    for i in entries:
        for j in i.drivers:

            CURSOR.execute (f"""
                        EXEC sp_CreateSessionEntry
                        @EventID = {i.eventID}, 
                        @SessioniRacingID = {i.sessionID},
                        @SessionEntryiRacingID = {i.iRacingID}, 
                        @CariRacingID = {i.carID}, 
                        @CarClassiRacingID = {i.carClassID},
                        @isTeam = {i.isTeam},
                        @EntryName = '{i.entryName.replace("'"," ")}',
                        @FinishPosInClass = {i.finishPos}
                    """)
            CURSOR.commit()
            CURSOR.execute(f"""
                        EXEC sp_CreateDriverEntry
                        @EventID = {i.eventID}, 
                        @SessionEntryiRacingID = {i.iRacingID}, 
                        @SessioniRacingID = {i.sessionID},
                        @DriverID = {j.driverID},
                        @PreviRating = {j.previRating},
                        @NewiRating = {j.newiRating},
                        @IncidentCount = {i.incidents}
                    """)
    print ("Adding Entry details to DB")
    CURSOR.commit()

def addCarDetailsToDB(cars):
    for i in cars:
        CURSOR.execute (f"""
                    EXEC sp_CreateCarsAndClasses
                    @CariRacingID = {i.carID}, 
                    @CarName = '{i.carName}', 
                    @ClassiRacingID = '{i.classID}', 
                    @ClassName = '{i.className}'
                """)
    print ("Adding driver details to DB")
    CURSOR.commit()
    

def addDriverDetailsToDB(drivers):
    for i in drivers:
        CURSOR.execute (f"""
                    EXEC sp_CreateDriver
                    @DriverID = {i.driverID}, 
                    @DriverName = '{i.driverName.replace("'"," ")}', 
                    @DriverClub = '{i.driverClub}', 
                    @DriverNotes = ''
                """)
    print ("Adding driver details to DB")
    CURSOR.commit()

class Stint:
    def __init__(self, driverID, entryiRacingID, eventID, iRacingSessionID, sessionName, laps):
        self.driverID = driverID
        self.entryiRacingID = entryiRacingID
        self.eventID = eventID
        self.iRacingSessionID = iRacingSessionID
        self.sessionName = sessionName
        self.laps = laps

class Lap:
    def __init__(self, lap_time, lap_in_session, lap_start_time, lap_events):
        self.lap_time = lap_time
        self.lap_in_session = lap_in_session
        self.lap_start_time = lap_start_time
        self.lap_events = lap_events


def processLapLevelData(session_data):
    driver_session_list = getDriverSessionList(session_data)
    lap_data = []
    stint_data = []
    for i in driver_session_list:
        laps = getLapData(session_data['subsession_id'], i.split("~")[0], i.split("~")[1], i.split('~')[3])
        for j in laps:
            lap = Lap(j['lap_time']/10000, j['lap_number'], j['session_time']/10000, [])
            for k in j['lap_events']:
                lap.lap_events.append(k)
            if lap not in lap_data:
                lap_data.append(lap)
        stint = Stint(i.split("~")[0], i.split("~")[3], session_data['subsession_id'],i.split("~")[1],i.split("~")[2],lap_data)
        if not stint in stint_data:
            stint_data.append(stint)
            lap_data = []
            del stint              

    addLapDetailsToDB(stint_data)

def addLapDetailsToDB(stint_data):
    count = 0
    for i in stint_data:
        if i.entryiRacingID == "0":
            i.entryiRacingID = i.driverID
        for j in i.laps:
            count += 1
            if len(j.lap_events) > 0:
                for k in j.lap_events:
                    CURSOR.execute (f"""
                                EXEC sp_CreateLapData
                                @EventID = {i.eventID}, 
                                @SessionEntryiRacingID = '{i.entryiRacingID}', 
                                @SessioniRacingID = {i.iRacingSessionID},
                                @DriverID = '{i.driverID}', 
                                @LapTime = '{j.lap_time}', 
                                @LapInSession = '{j.lap_in_session}', 
                                @LapStartTime = '{j.lap_start_time}', 
                                @LapEventType = '{k}'
                            """)
            else:
                CURSOR.execute (f"""
                            EXEC sp_CreateLapData
                            @EventID = {i.eventID}, 
                            @SessionEntryiRacingID = '{i.entryiRacingID}', 
                            @SessioniRacingID = {i.iRacingSessionID},
                            @DriverID = '{i.driverID}', 
                            @LapTime = '{j.lap_time}', 
                            @LapInSession = '{j.lap_in_session}', 
                            @LapStartTime = '{j.lap_start_time}', 
                            @LapEventType = ''
                    """)
    print ("Adding Laps details to DB")
    CURSOR.commit()

if __name__ == "__main__":
    session_id = input("Please enter comma separated list of session ids: ")
    for i in session_id.split(","):
        session_data = getSessionData(i.strip())
        
        processSessionLevelData(session_data)
        processSessionDriverLevelData(session_data)
        processLapLevelData(session_data)

    #TODO: 
    # Confirm that heat racing is handled correctly and that separate sessions are being created
    # Sort out stints and confirm all laps are being stored
    # Determine if LapInStint is going to be viable, and write logic for it if so        

    print ("Script completed")
    #print (json.dumps(session_data)) 


    #driver_session_list = getDriverSessionList(session_data)  
    # Get individual lap data for each driver and session
    #     j = i.split("~")
    #     print(getLapData(session_id, j[0], j[1]))
        

    exit()