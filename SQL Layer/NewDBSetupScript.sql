--Drop tables

DROP TABLE IF EXISTS LapEvents;
DROP TABLE IF EXISTS Laps;
DROP TABLE IF EXISTS DriverSessionEntries;
DROP TABLE IF EXISTS SessionEntries;
DROP TABLE IF EXISTS Sessions;
DROP TABLE IF EXISTS Drivers;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Cars;
DROP TABLE IF EXISTS Classes;
DROP TABLE IF EXISTS Layouts;
DROP TABLE IF EXISTS Locations;

--Create tables
CREATE TABLE Locations (
  LocationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  LocationName VARCHAR(100),
  CONSTRAINT UC_LocationName UNIQUE(LocationName)
);

CREATE TABLE Layouts (
  LayoutID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  LocationID INT NOT NULL,
  LayoutName VARCHAR(100),
  TrackLength DECIMAL(5,2),
  Corners INT,
  FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
  CONSTRAINT UC_LayoutNameLocationID UNIQUE(LocationID, LayoutName)
);

CREATE TABLE Events (
  EventID INT NOT NULL PRIMARY KEY,
  Description VARCHAR(100),
  Date DATE,
  Hosted BIT,
  Official BIT,
  StartTime TIME,
  InSimDate DATE,
  InSimTime TIME,
  LayoutID INT NOT NULL,
  Temp DECIMAL(5,2),
  Humidity DECIMAL(5,2),
  SeasonName VARCHAR(100),
  LeagueSeasonName VARCHAR(100),
  Year INT,
  Quarter INT,
  SoF INT,
  FOREIGN KEY (LayoutID) REFERENCES Layouts(LayoutID)
);

CREATE TABLE Classes (
  ClassID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  ClassiRacingID INT NOT NULL,
  ClassName VARCHAR(100),
  CONSTRAINT UC_ClassiRacingID UNIQUE(ClassiRacingID)
);

CREATE TABLE Cars (
  CarID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  CariRacingID INT,
  ClassID INT NOT NULL,
  CarName VARCHAR(100),
  FOREIGN KEY (ClassID) REFERENCES Classes(ClassID),
  CONSTRAINT UC_CarIDClassID UNIQUE(CariRacingID, ClassID)
);

CREATE TABLE Sessions (
  SessionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  SessioniRacingID INT NOT NULL,
  EventID INT NOT NULL,
  SessionType VARCHAR(100),
  SessionName VARCHAR(100),
  SimStartTime DATETIME,
  FOREIGN KEY (EventID) REFERENCES Events(EventID),
  CONSTRAINT UC_iRacingIDEventID UNIQUE(EventID, SessioniRacingID)
);


CREATE TABLE SessionEntries (
  SessionEntryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  SessionID INT NOT NULL,
  SessionEntryiRacingID INT,
  EntryName VARCHAR(100),
  IsTeam BIT,
  CarID INT NOT NULL,
  FinishPos INT NOT NULL,
  FinishPosInClass INT NOT NULL,
  StartingPos INT NOT NULL,
  StartingPosInClass INT NOT NULL, 
  ReasonOut VARCHAR(50),
  Interval FLOAT NOT NULL,
  ClassInterval FLOAT NOT NULL,
  ChampPoints INT NOT NULL,
  FOREIGN KEY (SessionID) REFERENCES Sessions(SessionID),
  FOREIGN KEY (CarID) REFERENCES Cars(CarID),
  CONSTRAINT UC_SessionIDiRacingID UNIQUE(SessionID, SessionEntryiRacingID)
);


CREATE TABLE Drivers (
  DriverID INT NOT NULL PRIMARY KEY,
  DriverName VARCHAR(100),
  DriverClub VARCHAR(100),
  DriverNotes VARCHAR(255)
);

CREATE TABLE DriverSessionEntries (
  DriverEntryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  SessionEntryID INT NOT NULL,
  DriverID INT NOT NULL,
  PreviRating INT NOT NULL,
  NewiRating INT NOT NULL,
  IncidentCount INT,
  FOREIGN KEY (SessionEntryID) REFERENCES SessionEntries(SessionEntryID),
  FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID),
  CONSTRAINT UC_DriverIDSessionEntryIDSessionID UNIQUE(SessionEntryID, DriverID)
);

CREATE TABLE Laps (
  LapID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  DriverEntryID INT NOT NULL,
  LapTime FLOAT NOT NULL,
  LapStartTime FLOAT NOT NULL,
  LapInSession INT NOT NULL,
  FOREIGN KEY (DriverEntryID) REFERENCES DriverSessionEntries(DriverEntryID),
  CONSTRAINT UC_LapInSessionDriverEntryID UNIQUE(DriverEntryID, LapInSession)
);

CREATE TABLE LapEvents (
  LapEventID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  LapID INT NOT NULL,
  LapEventType VARCHAR(50),
  FOREIGN KEY (LapID) REFERENCES Laps(LapID),
  CONSTRAINT UC_LapEventTypeLapID UNIQUE(LapID, LapEventType)
);

--Location and Layout Population
DROP PROCEDURE IF EXISTS sp_CreateLocationAndLayout 
GO

CREATE PROCEDURE sp_CreateLocationAndLayout
    @LocationName NVARCHAR(100),
    @LayoutName NVARCHAR(100),
	@TrackLength DECIMAL(5,2),
	@Corners INT
AS
	--Check if LocationName already exists, if not create it, we capture the LocationID in either case.
	DECLARE @LocationID INT
	IF EXISTS (SELECT * FROM Locations WHERE LocationName = @LocationName)
	BEGIN
		SELECT @LocationID = LocationID FROM Locations WHERE LocationName = @LocationName
	END
	ELSE 
	BEGIN
		INSERT INTO Locations(LocationName)
		Values (@LocationName)
		SET @LocationID = SCOPE_IDENTITY()
	END

	--Check if Layout details already exist, enter them if not
	IF NOT EXISTS (SELECT * FROM Layouts WHERE LocationID = @LocationID AND LayoutName = @LayoutName)
	BEGIN
		INSERT INTO Layouts(LocationID, LayoutName, TrackLength, Corners)
		VALUES (@LocationID, @LayoutName, @TrackLength, @Corners)
	END	
GO

--Creation of driver details
DROP PROCEDURE IF EXISTS sp_CreateDriver
GO

CREATE PROCEDURE sp_CreateDriver
	@DriverID INT,
	@DriverName NVARCHAR(100),
	@DriverClub NVARCHAR(100),
	@DriverNotes NVARCHAR(255)
AS
	IF NOT EXISTS (SELECT * FROM Drivers WHERE DriverID = @DriverID)
	BEGIN
		INSERT INTO Drivers (DriverID, DriverName, DriverClub, DriverNotes)
		VALUES (@DriverID, @DriverName, @DriverClub,@DriverNotes)
	END
GO

--Creation of cars and classes
DROP PROCEDURE IF EXISTS sp_CreateCarsAndClasses
GO

CREATE PROCEDURE sp_CreateCarsAndClasses
	@CariRacingID INT,
	@CarName NVARCHAR(100),
	@ClassiRacingID INT,
	@ClassName NVARCHAR(100)
AS
	
	--Does the class exist, if not get the ID, either way store the ClassID
	DECLARE @ClassID INT
	IF NOT EXISTS (SELECT * FROM Classes WHERE ClassiRacingID = @ClassiRacingID)
	BEGIN
		INSERT INTO Classes (ClassiRacingID, ClassName)
		VALUES (@ClassiRacingID, @ClassName)
		SET @ClassID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT @ClassID = ClassID FROM Classes WHERE ClassiRacingID = @ClassiRacingID
	END

	--Insert the car details if they don't already exist
	IF NOT EXISTS (SELECT * FROM Cars WHERE ClassID = @ClassID AND CariRacingID = @CariRacingID)
	BEGIN
		INSERT INTO Cars (CariRacingID, ClassID, CarName)
		VALUES (@CariRacingID, @ClassID, @CarName)
	END
GO

--Creation of event
DROP PROCEDURE IF EXISTS sp_CreateEvent
GO

CREATE PROCEDURE sp_CreateEvent
	@EventID INT,
	@Description NVARCHAR(100),
	@EventDate DATE,
	@Hosted BIT,
	@Official BIT,
	@EventStartTime TIME,
	@InSimDate DATE,
	@InSimStartTime TIME,
	@LocationName NVARCHAR(100),
	@LayoutName NVARCHAR(100),
	@Temp DECIMAL (5,2),
	@Humidity DECIMAL (5,2),
	@SeasonName NVARCHAR(100),
	@LeagueSeasonName NVARCHAR(100),
	@Year INT,
	@Quarter INT,
	@SoF INT
AS
	DECLARE @LocationID INT
	IF NOT EXISTS (SELECT * FROM Locations WHERE LocationName = @LocationName)
	BEGIN
		RAISERROR('Error: Location not in DB, Event cannot be created', 16, 1);
        RETURN;
	END
	ELSE
	BEGIN
		SELECT @LocationID = LocationID FROM Locations WHERE LocationName = @LocationName
	END

	--Get LocationID ID Exists, raise error if it doesnt
	DECLARE @LayoutID INT
	IF NOT EXISTS (SELECT * FROM Layouts WHERE LocationID = @LocationID AND LayoutName = @LayoutName)
	BEGIN
		RAISERROR('Error: Location/Layout details not found in DB, Event cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	BEGIN
		SELECT @LayoutID = LayoutID FROM Layouts WHERE LocationID = @LocationID AND LayoutName = @LayoutName
	END
	   
	--Check if event ID already exists, if so nothing is required. 
	IF EXISTS (SELECT * FROM Events WHERE EventID = @EventID)
	BEGIN
		RAISERROR('Notice: EventID already exists, aborting event creation', 1, 1);
        RETURN;
	END

	INSERT INTO Events (EventID, Description, Date, Hosted, Official, StartTime, InSimDate, InSimTime, LayoutID, Temp, Humidity, SeasonName, LeagueSeasonName, Year, Quarter, SoF)
	VALUES (@EventID, @Description, @EventDate, @Hosted, @Official, @EventStartTime, @InSimDate, @InSimStartTime, @LayoutID, @Temp, @Humidity, @SeasonName, @LeagueSeasonName, @Year, @Quarter, @Sof)
GO

DROP PROCEDURE IF EXISTS sp_CreateSession
GO

CREATE PROCEDURE sp_CreateSession
	@EventID INT,
	@SessioniRacingID INT,
	@SessionType NVARCHAR(100),
	@SessionName NVARCHAR(100),
	@SimStartTime TIME
AS
	--Check that Event has already been created
	IF NOT EXISTS (SELECT * FROM Events WHERE EventID = @EventID)
	BEGIN
		RAISERROR('Error: Event details not found in DB, Session cannot be created', 16, 1);
        RETURN;
	END

	--Check if this session already exists - if so nothing is required
	IF EXISTS (SELECT * FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID)
	BEGIN
		RAISERROR('Notice: Session already exists, aborting session creation', 1, 1);
        RETURN;
	END

	INSERT INTO Sessions (EventID, SessioniRacingID, SessionType, SessionName, SimStartTime)
	VALUES (@EventID, @SessioniRacingID, @SessionType, @SessionName, @SimStartTime)


GO

DROP PROCEDURE IF EXISTS sp_CreateSessionEntry
GO 

CREATE PROCEDURE sp_CreateSessionEntry
	@EventID INT,
	@SessioniRacingID INT,
	@SessionEntryiRacingID INT,
	@CariRacingID INT,
	@CarClassiRacingID INT,
	@IsTeam BIT,
	@EntryName NVARCHAR(100),
	@FinishPos INT,
	@FinishPosInClass INT,
	@StartingPos INT,
	@StartingPosInClass INT,
	@ReasonOut VARCHAR(100),
	@Interval FLOAT,
	@ClassInterval FLOAT,
	@ChampPoints INT
AS
	--Check Event Exists
	IF NOT EXISTS (SELECT * FROM Events WHERE EventID = @EventID)
	BEGIN
		RAISERROR('Error: Event details not found in DB, Entry cannot be created', 16, 1);
        RETURN;
	END

	--Check Session exists and record the ID
	DECLARE @SessionID INT
	IF NOT EXISTS (SELECT * FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID)
	BEGIN 
		RAISERROR('Error: Session details not found in DB, Entry cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	BEGIN
		SELECT @SessionID = SessionID FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID
	END


	--Check car class exists and record the ID
	DECLARE @CarClassID INT
	IF NOT EXISTS (SELECT * FROM Classes WHERE ClassiRacingID = @CarClassiRacingID)
		BEGIN
		RAISERROR('Error: Car class details not found in DB, Entry cannot be created', 16, 1);
        RETURN;
	END
	ELSE
	BEGIN
		SELECT @CarClassID = ClassID FROM Classes WHERE ClassiRacingID = @CarClassiRacingID
	END

	--Check Car exists and record the ID
	DECLARE @CarID INT
	IF NOT EXISTS (SELECT * FROM Cars WHERE CariRacingID = @CariRacingID AND ClassID = @CarClassID)
	BEGIN
		RAISERROR('Error: Car details not found in DB, Entry cannot be created', 16, 1);
        RETURN;
	END
	ELSE
	BEGIN
		SELECT @CarID = CarID FROM Cars WHERE CariRacingID = @CariRacingID AND ClassID = @CarClassID
	END

	--Check EventEntry doesn't already exist
	IF EXISTS (SELECT * FROM SessionEntries WHERE SessionID = @SessionID AND SessionEntryiRacingID = @SessionEntryiRacingID)
	BEGIN
		RAISERROR('Notice: Session event entry already exists, aborting event entry creation', 1, 1);
        RETURN;
	END

	INSERT INTO SessionEntries (SessionID, EntryName, IsTeam, SessionEntryiRacingID, CarID, FinishPos, FinishPosInClass, StartingPos, StartingPosInClass, ReasonOut, Interval, ClassInterval, ChampPoints)
	VALUES (@SessionID, @EntryName, @IsTeam, @SessionEntryiRacingID, @CarID, @FinishPos, @FinishPosInClass, @StartingPos, @StartingPosInClass, @ReasonOut, @Interval, @ClassInterval, @ChampPoints)
GO


DROP PROCEDURE IF EXISTS sp_CreateDriverEntry
GO

CREATE PROCEDURE sp_CreateDriverEntry
	@EventID INT,
	@SessionEntryiRacingID INT,
	@SessioniRacingID INT,
	@DriverID INT,
	@PreviRating INT,
	@NewiRating INT,
	@IncidentCount INT
AS
	--Get SessionID
	DECLARE @SessionID INT
	IF NOT EXISTS (SELECT * FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID)
	BEGIN
		RAISERROR('Error: Session not found in DB, DriverEntry cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	BEGIN
		SELECT @SessionID = SessionID FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID
	END

	--Check and retrieve SessionEntryID
	DECLARE @SessionEntryID INT
	IF NOT EXISTS (SELECT * FROM SessionEntries WHERE SessionID = @SessionID AND SessionEntryiRacingID = @SessionEntryiRacingID)
	BEGIN
		RAISERROR('Error: Session Entry not found in DB, DriverEntry cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	BEGIN
		SELECT @SessionEntryID = SessionEntryID FROM SessionEntries WHERE SessionID = @SessionID AND SessionEntryiRacingID = @SessionEntryiRacingID
	END

	--Check DriverID exists
	IF NOT EXISTS (SELECT * FROM Drivers WHERE DriverID = @DriverID)
	BEGIN
		RAISERROR('Error: Driver details not found in DB, DriverEntry cannot be created', 16, 1);
        RETURN;
	END

	--Check DriverEntry does not already exist
	IF NOT EXISTS (SELECT * FROM DriverSessionEntries WHERE SessionEntryID = @SessionEntryID AND SessionEntryID = @SessionEntryID AND DriverID = @DriverID)
	BEGIN
		INSERT INTO DriverSessionEntries (SessionEntryID, DriverID, PreviRating, NewiRating, IncidentCount)
		VALUES (@SessionEntryID, @DriverID, @PreviRating, @NewiRating, @IncidentCount)
	END
GO

DROP PROCEDURE IF EXISTS sp_CreateLapData
GO

CREATE PROCEDURE sp_CreateLapData
	@EventID INT,
	@SessionEntryiRacingID INT,
	@SessioniRacingID INT,
	@DriverID INT,
	@LapTime FLOAT,
	@LapStartTime FLOAT,
	@LapInSession INT, 
	@LapEventType NVARCHAR(50)
AS

	--Get SessionID
	DECLARE @SessionID INT
	IF NOT EXISTS (SELECT * FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID)
	BEGIN
		RAISERROR('Error: Session not found in DB, DriverEntry cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	BEGIN
		SELECT @SessionID = SessionID FROM Sessions WHERE EventID = @EventID AND SessioniRacingID = @SessioniRacingID
	END

	--Check and retrieve SessionEntryID
	DECLARE @SessionEntryID INT
	IF NOT EXISTS (SELECT * FROM SessionEntries WHERE SessionID = @SessionID AND SessionEntryiRacingID = @SessionEntryiRacingID)
	BEGIN
		RAISERROR('Error: Event Entry not found in DB, Lap cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	BEGIN
		SELECT @SessionEntryID = SessionEntryID FROM SessionEntries WHERE SessionID = @SessionID AND SessionEntryiRacingID = @SessionEntryiRacingID
	END

	--Check DriverID exists
	IF NOT EXISTS (SELECT * FROM Drivers WHERE DriverID = @DriverID)
	BEGIN
		RAISERROR('Error: Driver details not found in DB, Lap cannot be created', 16, 1);
        RETURN;
	END

	--Check and retrieve DriverEntry
	DECLARE @DriverEntryID INT
	IF NOT EXISTS (SELECT * FROM DriverSessionEntries WHERE SessionEntryID = @SessionEntryID AND SessionEntryID = @SessionEntryID AND DriverID = @DriverID)
	BEGIN
		RAISERROR('Error: Driver Entry not found in DB, Lap cannot be created', 16, 1);
        RETURN;
	END
	ELSE 
	SELECT @DriverEntryID = DriverEntryID FROM DriverSessionEntries WHERE SessionEntryID = @SessionEntryID AND SessionEntryID = @SessionEntryID AND DriverID = @DriverID

	--Insert lap data if not already present
	DECLARE @LapID INT
	IF NOT EXISTS (SELECT * FROM Laps WHERE LapInSession = @LapInSession AND DriverEntryID = @DriverEntryID)
	BEGIN
		INSERT INTO Laps(DriverEntryID, LapTime, LapStartTime, LapInSession)
		VALUES (@DriverEntryID, @LapTime, @LapStartTime, @LapInSession)
		SET @LapID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT @LapID = LapID FROM Laps WHERE LapInSession = @LapInSession AND DriverEntryID = @DriverEntryID
	END

	--Insert LapEvent data if not already present
	IF NOT EXISTS (SELECT * FROM LapEvents WHERE LapID = @LapID AND LapEventType = @LapEventType) AND @LapEventType IS NOT NULL AND @LapEventType <> ''
	BEGIN
		INSERT INTO LapEvents (LapID, LapEventType)
		VALUES (@LapID, @LapEventType)
	END

GO

DROP VIEW IF EXISTS vw_EnhancedLapData
GO

CREATE VIEW vw_EnhancedLapData AS

SELECT 
	LA.*
	, ELD.PositionInClass
	, ELD.BestLapOnLap
	, ELD.LeaderLapStartTime
	, CASE WHEN ELD.BestLapOnLap IS NOT NULL AND LA.LapTime > 1 THEN (100 * LA.Laptime / ELD.BestLapOnLap) - 100 ELSE NULL END AS PercentageGapToBestLap
	, LA.LapStartTime - ELD.LeaderLapStartTime AS GapToClassLeader
	, CASE WHEN LA.LapTime < (1.07 * ELD.DriverBestLap) THEN 1 ELSE 0 END AS Within107
FROM (
			SELECT 
				LapID
				, DriverEntryID
				, LapTime
				, LapStartTime
				, LapInSession
				, CASE WHEN ([black flag] + [car contact] + [car reset] + [contact] + [discontinuity] + [invalid] + [lost control] + [off track] + [tow]) = 0 THEN 1 ELSE 0 END AS CleanLap
				, [black flag] AS BlackFlag 
				, [car contact] AS CarContact 
				, [car reset] AS CarReset
				, [contact] AS Contact
				, [discontinuity] AS Discontinuity
				, [invalid] AS Invalid
				, [lost control] AS LostControl
				, [off track] As OffTrack
				, [pitted] AS Pitted
				, [tow] AS Tow
				,	STUFF(CASE WHEN [black flag] = 1 THEN ', Black Flag' ELSE '' END
					+ CASE WHEN [car contact] = 1 THEN ', CarContact' ELSE '' END
					+ CASE WHEN [car reset] = 1 THEN ', Car Reset' ELSE '' END
					+ CASE WHEN [discontinuity] = 1 THEN ', Discontinuity' ELSE '' END
					+ CASE WHEN [contact] = 1 THEN ', Contact' ELSE '' END
					+ CASE WHEN [invalid] = 1 THEN ', Invalid' ELSE '' END
					+ CASE WHEN [lost control] = 1 THEN ', Lost Control' ELSE '' END
					+ CASE WHEN [off track] = 1 THEN ', Off Track' ELSE '' END
					+ CASE WHEN [pitted] = 1 THEN ', In Pits' ELSE '' END, 1, 2, '') AS EventCategory
			FROM 
			(
			  SELECT l.LapID, l.DriverentryID, l.LapTime, l.LapStartTime, l.LapInSession, le.LapEventType
			  FROM Laps l 
			  LEFT OUTER JOIN LapEvents le ON l.LapID = le.LapID
			) AS LapEventData
			PIVOT
			(
			  COUNT(LapEventType)
			  FOR LapEventType IN ([black flag], [car contact], [car reset], [contact], [discontinuity], [invalid], [lost control], [off track], [pitted], [tow])
			) AS PivotTable
		) LA
	INNER JOIN DriverSessionEntries DE
		ON LA.DriverEntryID = DE.DriverEntryID
	LEFT OUTER JOIN (
			SELECT 
				LA.LapID
				, RANK() OVER (PARTITION BY SE.EventID, SE.SessionID, LA.LapInSession, CL.ClassID ORDER BY LA.LapStartTime) AS PositionInClass
				, BL.BestLapOnLap
				, BL.DriverBestLap
				, MIN(La.LapStartTime) OVER (PARTITION BY SE.EventID, SE.SessionID, LA.LapInSession, CL.ClassID ORDER BY LA.LapStartTime) AS LeaderLapStartTime
			FROM Laps LA
				INNER JOIN DriverSessionEntries DE
					ON LA.DriverEntryID = DE.DriverEntryID
				INNER JOIN SessionEntries EE
					ON DE.SessionEntryID = EE.SessionEntryID
				INNER JOIN Cars CA
					ON EE.CarID = CA.CarID
				INNER JOIN Classes CL
					ON CA.ClassID = CL.ClassID
				INNER JOIN Sessions SE
					ON EE.SessionID = SE.SessionID
				LEFT OUTER JOIN (
					SELECT LA.LapID
					, MIN(La.LapTime) OVER (PARTITION BY SE.EventID, SE.SessionID, LA.LapInSession, CL.ClassID ORDER BY LA.LapStartTime) AS BestLapOnLap
					, MIN(La.LapTime) OVER (PARTITION BY LA.DriverEntryID ORDER BY LA.LapStartTime) AS DriverBestLap
					FROM Laps LA
					INNER JOIN DriverSessionEntries DE
						ON LA.DriverEntryID = DE.DriverEntryID
					INNER JOIN SessionEntries EE
						ON DE.SessionEntryID = EE.SessionEntryID
					INNER JOIN Cars CA
						ON EE.CarID = CA.CarID
					INNER JOIN Classes CL
						ON CA.ClassID = CL.ClassID
					INNER JOIN Sessions SE
						ON EE.SessionID = SE.SessionID
					WHERE LA.LapTime > 1
				) BL ON LA.LapID = BL.LapID
	) ELD ON LA.LapID = ELD.LapID
GO	

DROP VIEW IF EXISTS vw_PitTimeLoss
GO 

CREATE VIEW vw_PitTimeLoss
AS 
WITH Pivoted
AS
(SELECT 
		LapID
		, SessionEntryID
		, LapTime
		, LapInSession
		, CASE WHEN ([black flag] + [car contact] + [car reset] + [contact] + [discontinuity] + [invalid] + [lost control] + [off track] + [tow]) = 0  AND LapInSession >= 1 THEN 1 ELSE 0 END AS ValidLapForAverages
		, PivotTable.pitted AS Pitted	
	FROM 
	(
		SELECT l.LapID, DSE.SessionEntryID, l.LapTime, l.LapStartTime, l.LapInSession, le.LapEventType
		FROM Laps l 
		INNER JOIN DriverSessionEntries DSE ON L.DriverEntryID = DSE.DriverEntryID
		LEFT OUTER JOIN LapEvents le ON l.LapID = le.LapID
	) AS LapEventData
	PIVOT
	(
		COUNT(LapEventType)
		FOR LapEventType IN ([black flag], [car contact], [car reset], [contact], [discontinuity], [invalid], [lost control], [off track], [pitted], [tow])
	) AS PivotTable
), 
Averages
AS 
(
	SELECT 
		Pivoted.SessionEntryID
		, AVG(Pivoted.LapTime) AS MeanCleanLapTime
		, MIN(Pivoted.LapTime) AS BestLap
		, AVG(Pivoted.LapTime) - MIN(Pivoted.LapTime) AS Gap
	FROM Pivoted 
	LEFT OUTER JOIN (SELECT Pivoted.SessionEntryID, MIN(Pivoted.LapTime) AS BestLap FROM Pivoted WHERE Pivoted.ValidLapForAverages = 1 GROUP BY Pivoted.SessionEntryID) P2 on Pivoted.SessionEntryID = P2.SessionEntryID -- This is to exclude any unrepresentative laps, such as those behind a safety car, used in the WHERE clause immediated below
	WHERE ValidLapForAverages = 1 AND Pivoted.LapTime < 1.07 * P2.BestLap
	GROUP BY Pivoted.SessionEntryID
),
Rankings AS (
SELECT 
	L.*
	, DSE.SessionEntryID
	, CASE WHEN Le.LapEventType IS NOT NULL AND LapTime > 0 THEN L.LapTime - A.MeanCleanLapTime END AS LapTimeLoss
	, DENSE_RANK() OVER (PARTITION BY DSE.SessionEntryID ORDER BY LapInSession) AS LapRanking--Ranking by lap
	, DENSE_RANK() OVER (PARTITION BY DSE.SessionEntryID, CASE WHEN Le.LapEventType IS NOT NULL AND LapTime > 0 THEN 1 ELSE 0 END ORDER BY LapInSession) AS GroupRanking--Ranking by lap separately for pit and not pit laps
FROM Laps L
INNER JOIN DriverSessionEntries DSE 
	ON L.DriverEntryID = DSE.DriverEntryID
INNER JOIN Averages A
	ON DSE.SessionEntryID = A.SessionEntryID
LEFT OUTER JOIN LapEvents LE
	ON L.LapID = LE.LapID
	AND LE.LapEventType = 'pitted'
), 
Islands AS (
SELECT * 
	, LapRanking - GroupRanking AS IslandID
FROM 
Rankings
WHERE LapTimeLoss IS NOT NULL
), 
IslandRanks AS (
	SELECT * 
	, DENSE_RANK() OVER (PARTITION BY SessionEntryID ORDER BY IslandID) AS PitInstanceInSession
	FROM Islands
)

SELECT 
	L.*
	, I.SessionEntryID
	, I.LapTimeLoss
	, I.PitInstanceInSession
FROM Laps L
INNER JOIN IslandRanks I
	ON I.LapID = L.LapID
GO

DROP VIEW IF EXISTS vw_EnhancedEventDetails
GO 

CREATE VIEW vw_EnhancedEventDetails
AS

SELECT 
	EV.SeasonName + ' - ' +
	EV.Description + ' - ' +
	LO.LocationName + ' - ' +
	CASE WHEN LA.LayoutName <> 'N/A' THEN LA.LayoutName + ' - ' ELSE '' END +
	FORMAT(EV.Date, 'dd MMMM yyyy') + ' - ' + 
	CAST(EV.EventID	 AS NVARCHAR)
	 AS EventFilterValue
	, EV.EventID
	, EV.Description
	, EV.Date
	, EV.Hosted
	, EV.Official
	, EV.StartTime
	, EV.InSimDate
	, EV.InSimTime
	, EV.LayoutID
	, EV.Temp
	, EV.Humidity
	, EV.SeasonName
	, EV.Year
	, EV.Quarter
	, EV.SoF
	, EV.LeagueSeasonName
FROM Events EV
	INNER JOIN Layouts LA
		ON EV.LayoutID = La.LayoutID
	INNER JOIN Locations LO 
		ON LO.LocationID = LA.LocationID
GO


DROP VIEW IF EXISTS vw_EnhancedSessionDetails --Old name of this view
DROP VIEW IF EXISTS vw_EventSessionClassFilterDetails
GO 

CREATE VIEW vw_EventSessionClassFilterDetails
AS

SELECT DISTINCT
	EV.EventID
	, EV.Description
	, EV.Date
	, EV.Hosted
	, EV.Official
	, EV.StartTime
	, EV.InSimDate
	, EV.InSimTime
	, EV.LayoutID
	, EV.Temp
	, EV.Humidity
	, EV.SeasonName
	, EV.Year
	, EV.Quarter
	, EV.SoF
	, S.SessionID
	, S.SessioniRacingID
	, S.SessionType
	, S.SessionName
	, CC.ClassID
	, CC.ClassName
	, EV.SeasonName + ' - ' +
		EV.Description + ' - ' +
		LO.LocationName + ' - ' +
		CASE WHEN LA.LayoutName <> 'N/A' THEN LA.LayoutName + ' - ' ELSE '' END +
		FORMAT(EV.Date, 'dd MMMM yyyy') + ' - ' + 
		CAST(EV.EventID	 AS NVARCHAR)
		 AS EventFilterValue
	, EV.SeasonName + ' - ' +
		EV.Description + ' - ' +
		LO.LocationName + ' - ' +
		CASE WHEN LA.LayoutName <> 'N/A' THEN LA.LayoutName + ' - ' ELSE '' END +
		S.SessionName + ' - ' + 
		FORMAT(EV.Date, 'dd MMMM yyyy') + ' - ' + 
		CAST(EV.EventID	 AS NVARCHAR)
		 AS SessionFilterValue
	, EV.SeasonName + ' - ' +
		EV.Description + ' - ' +
		LO.LocationName + ' - ' +
		CASE WHEN LA.LayoutName <> 'N/A' THEN LA.LayoutName + ' - ' ELSE '' END +
		S.SessionName + ' - ' + 
		CC.ClassName + ' - ' + 
		FORMAT(EV.Date, 'dd MMMM yyyy') + ' - ' + 
		CAST(EV.EventID	 AS NVARCHAR)
		 AS SessionClassFilterValue
	, EV.LeagueSeasonName
FROM Events EV
	INNER JOIN Layouts LA
		ON EV.LayoutID = La.LayoutID
	INNER JOIN Locations LO 
		ON LO.LocationID = LA.LocationID
	INNER JOIN Sessions S
		ON S.EventID = EV.EventID
	INNER JOIN SessionEntries SE
		ON S.SessionID = SE.SessionID
	INNER JOIN Cars C ON
		SE.CarID = C.CarID
	INNER JOIN Classes CC ON
		C.ClassID = CC.ClassID
GO


DROP VIEW IF EXISTS vw_EnhancedSessionEntryDetails
GO 

CREATE VIEW vw_EnhancedSessionEntryDetails
AS

SELECT 
	SE.SessionEntryID
	, SE.SessionID
	, SE.SessionEntryiRacingID
	, SE.EntryName
	, SE.IsTeam
	, SE.CarID
	, SE.FinishPosInClass
	, RANK() OVER (PARTITION BY SE.SessionID, C.ClassID ORDER BY L1.LapStartTime) AS StartPositionInClass
	, C.ClassID
	, DSE.IncidentCount AS EntryIncidents	
	, CASE 
		WHEN SE.ClassInterval > 0 THEN CAST(SE.ClassInterval AS NVARCHAR)
		ELSE CAST(MAX(L2.LapsCompleted) OVER (PARTITION BY SE.SessionID, C.ClassID) - L2.LapsCompleted AS NVARCHAR) + ' Laps'
	END AS GapToLeader
	, L2.LapsCompleted
	, L2.FinalLapFinishTime --DO NOT USE, if a slowdown is taken on the final lap this is incorrect
	, SE.FinishPos AS OverallFinishPos
	, SE.StartingPos AS OverallStartPos
	, SE.StartingPosInClass AS StartPos
	, SE.ReasonOut
	, SE.ChampPoints
FROM SessionEntries SE
	INNER JOIN DriverSessionEntries DSE ON
		SE.SessionEntryID = DSE.SessionEntryID
	INNER JOIN Cars C
		ON SE.CarID = C.CarID
	INNER JOIN Laps L1 ON
		L1.DriverEntryID = DSE.DriverEntryID
		AND L1.LapInSession = 0
	INNER JOIN 
		(SELECT 
			DSE.SessionEntryID
			, MAX(L.LapInSession) AS LapsCompleted 
			, MAX(L.LapStartTime + L.LapTime) AS FinalLapFinishTime --Left in for Tableau Public compatability, but should not be used
		FROM Laps L
			INNER JOIN DriverSessionEntries DSE ON L.DriverEntryID = DSE.DriverEntryID
		GROUP BY DSE.SessionEntryID) L2 ON
			L2.SessionEntryID = SE.SessionEntryID
GO

			
			