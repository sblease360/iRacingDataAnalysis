USE [master]
GO
/****** Object:  Database [iRacingData]    Script Date: 11/04/2023 15:37:56 ******/
CREATE DATABASE [iRacingData]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'iRacingData', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\iRacingData.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'iRacingData_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\iRacingData_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [iRacingData] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [iRacingData].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [iRacingData] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [iRacingData] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [iRacingData] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [iRacingData] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [iRacingData] SET ARITHABORT OFF 
GO
ALTER DATABASE [iRacingData] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [iRacingData] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [iRacingData] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [iRacingData] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [iRacingData] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [iRacingData] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [iRacingData] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [iRacingData] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [iRacingData] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [iRacingData] SET  DISABLE_BROKER 
GO
ALTER DATABASE [iRacingData] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [iRacingData] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [iRacingData] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [iRacingData] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [iRacingData] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [iRacingData] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [iRacingData] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [iRacingData] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [iRacingData] SET  MULTI_USER 
GO
ALTER DATABASE [iRacingData] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [iRacingData] SET DB_CHAINING OFF 
GO
ALTER DATABASE [iRacingData] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [iRacingData] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [iRacingData] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [iRacingData] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [iRacingData] SET QUERY_STORE = OFF
GO
USE [iRacingData]
GO
/****** Object:  Table [dbo].[CarClasses]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarClasses](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CarID] [int] NOT NULL,
	[ClassID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_CarClassID] UNIQUE NONCLUSTERED 
(
	[CarID] ASC,
	[ClassID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cars]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cars](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Classes]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Classes](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Drivers]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Drivers](
	[ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Club] [varchar](100) NULL,
	[Notes] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventEntries]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventEntries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventID] [int] NOT NULL,
	[iRacingID] [int] NOT NULL,
	[CarID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[IsTeam] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_iRacingIDEventID] UNIQUE NONCLUSTERED 
(
	[EventID] ASC,
	[iRacingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventEntryDrivers]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventEntryDrivers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventEntryID] [int] NOT NULL,
	[DriverID] [int] NOT NULL,
	[OldiRating] [int] NULL,
	[NewiRating] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Events]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Events](
	[ID] [int] NOT NULL,
	[Description] [nvarchar](100) NULL,
	[EventDate] [date] NULL,
	[Hosted] [bit] NULL,
	[Official] [bit] NULL,
	[EventStartTime] [time](7) NULL,
	[InSimDate] [date] NULL,
	[InSimStartTime] [time](7) NULL,
	[LayoutID] [int] NOT NULL,
	[Temp] [float] NULL,
	[Humidity] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IncidentTypes]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LapEvents]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LapEvents](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypeID] [int] NOT NULL,
	[LapID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LapEventTypes]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LapEventTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_Name] UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Laps]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Laps](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[EventEntryID] [int] NOT NULL,
	[EventEntryDriverID] [int] NOT NULL,
	[LapTime] [decimal](15, 6) NOT NULL,
	[LapInSession] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_EventDriverLapInSession] UNIQUE NONCLUSTERED 
(
	[EventID] ASC,
	[EventEntryDriverID] ASC,
	[LapInSession] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Layouts]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Layouts](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Length] [decimal](10, 2) NOT NULL,
	[Corners] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_Location] UNIQUE NONCLUSTERED 
(
	[ID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sessions]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sessions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EventID] [int] NOT NULL,
	[SessionTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_EventIDSessionTypeID] UNIQUE NONCLUSTERED 
(
	[EventID] ASC,
	[SessionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SessionTypes]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SessionTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarClasses]  WITH CHECK ADD FOREIGN KEY([CarID])
REFERENCES [dbo].[Cars] ([ID])
GO
ALTER TABLE [dbo].[CarClasses]  WITH CHECK ADD FOREIGN KEY([ClassID])
REFERENCES [dbo].[Classes] ([ID])
GO
ALTER TABLE [dbo].[EventEntries]  WITH CHECK ADD FOREIGN KEY([CarID])
REFERENCES [dbo].[Cars] ([ID])
GO
ALTER TABLE [dbo].[EventEntries]  WITH CHECK ADD FOREIGN KEY([EventID])
REFERENCES [dbo].[Events] ([ID])
GO
ALTER TABLE [dbo].[EventEntryDrivers]  WITH CHECK ADD FOREIGN KEY([DriverID])
REFERENCES [dbo].[Drivers] ([ID])
GO
ALTER TABLE [dbo].[EventEntryDrivers]  WITH CHECK ADD FOREIGN KEY([EventEntryID])
REFERENCES [dbo].[EventEntries] ([ID])
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD FOREIGN KEY([LayoutID])
REFERENCES [dbo].[Layouts] ([ID])
GO
ALTER TABLE [dbo].[LapEvents]  WITH CHECK ADD FOREIGN KEY([LapID])
REFERENCES [dbo].[Laps] ([ID])
GO
ALTER TABLE [dbo].[LapEvents]  WITH CHECK ADD FOREIGN KEY([TypeID])
REFERENCES [dbo].[LapEventTypes] ([ID])
GO
ALTER TABLE [dbo].[Laps]  WITH CHECK ADD FOREIGN KEY([EventID])
REFERENCES [dbo].[Events] ([ID])
GO
ALTER TABLE [dbo].[Laps]  WITH CHECK ADD FOREIGN KEY([SessionID])
REFERENCES [dbo].[Sessions] ([ID])
GO
ALTER TABLE [dbo].[Laps]  WITH CHECK ADD FOREIGN KEY([EventEntryID])
REFERENCES [dbo].[EventEntries] ([ID])
GO
ALTER TABLE [dbo].[Laps]  WITH CHECK ADD FOREIGN KEY([EventEntryDriverID])
REFERENCES [dbo].[EventEntryDrivers] ([ID])
GO
ALTER TABLE [dbo].[Layouts]  WITH CHECK ADD FOREIGN KEY([LocationID])
REFERENCES [dbo].[Locations] ([ID])
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD FOREIGN KEY([EventID])
REFERENCES [dbo].[Events] ([ID])
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD FOREIGN KEY([SessionTypeID])
REFERENCES [dbo].[SessionTypes] ([ID])
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateCarsAndClasses]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateCarsAndClasses]
    @iRacingID INT,
    @CarName VARCHAR(50),
    @ClassID INT,
    @ClassName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the class already exists
    IF NOT EXISTS (SELECT ID FROM dbo.Classes WHERE ID = @ClassID)
    BEGIN
        -- Class does not exist, create it
        INSERT INTO dbo.Classes (ID, Name)
        VALUES (@ClassID, @ClassName)
    END

    -- Check if the car already exists
    IF NOT EXISTS (SELECT CAR.ID FROM dbo.Cars CAR WHERE CAR.ID = @iRacingID)
    BEGIN
        -- Car does not exist, create it
        INSERT INTO dbo.Cars (ID, Name)
        VALUES (@iRacingID, @CarName)
    END

	-- Check if CarClasses record already exists
	IF NOT EXISTS (SELECT * FROM dbo.CarClasses WHERE CarID = @iRacingID AND ClassID = @ClassID)
	BEGIN
		INSERT INTO dbo.CarClasses (CarID, ClassID)
		VALUES (@iRacingID, @ClassID)
	END
END

GO
/****** Object:  StoredProcedure [dbo].[sp_CreateDriver]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateDriver]
    @ID INT,
    @Name VARCHAR(100),
    @Club VARCHAR(100),
    @Notes VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM dbo.Drivers WHERE ID = @ID)
    BEGIN
        RAISERROR('Driver with ID %d already exists.', 0, 1, @ID);
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Drivers (ID, Name, Club, Notes)
        VALUES (@ID, @Name, @Club, @Notes);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateEvent]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateEvent]
(
    @EventID INT,
	@Description varchar(50),
    @EventDate DATE,
    @Hosted BIT,
	@Official BIT,
	@EventStartTime TIME,
	@InSimDate DATE,
	@InSimStartTime TIME,
	@LocationID INT,
	@LayoutID INT,
	@Temp FLOAT,
	@Humidity FLOAT
)
AS
BEGIN
    SET NOCOUNT ON;
	
	-- Check if event ID already exists
    IF EXISTS(SELECT * FROM Events WHERE ID = @EventID)
    BEGIN
        RAISERROR('Event already exists.', 1, 1);
        RETURN;
    END

	IF @LocationID IS NULL
    BEGIN
        RAISERROR('LocationID cannot be null', 16, 1);
        RETURN;
    END

	IF @LayoutID IS NULL
    BEGIN
        RAISERROR('Layout ID Cannot be null', 16, 1);
        RETURN;
    END

	IF NOT EXISTS (SELECT TOP 1 * FROM Locations INNER JOIN Layouts ON Locations.ID = Layouts.locationID WHERE Locations.ID = @LocationID AND Layouts.ID = @LayoutID)
	BEGIN
	    RAISERROR('Locations or Layout IDs are not valid', 16, 1);
        RETURN;
	END
   
    -- Insert layout
    INSERT INTO Events (ID, Description, EventDate, Hosted, Official, EventStartTime, InSimDate, InSimStartTime, LayoutID, Temp, Humidity)
    VALUES (@EventID, @Description, @EventDate, @Hosted, @Official, @EventStartTime, @InSimDate, @InSimStartTime, @LayoutID, @Temp, @Humidity);
    
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateEventEntriesAndEntryDrivers]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateEventEntriesAndEntryDrivers]
    @EventID INT,
	@iRacingID INT,
    @CarID INT,
    @Name NVARCHAR(50),
    @IsTeam BIT,
    @DriverID INT,
    @OldiRating DECIMAL(10,2),
    @NewiRating DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EventEntryID INT;
    
    -- See if entry already exists, and if not create it
	IF EXISTS (SELECT * FROM EventEntries WHERE EventID = @EventID AND iRacingID = @iRacingID)
	BEGIN
		SET @EventEntryID = (SELECT ID FROM EventEntries WHERE EventID = @EventID AND iRacingID = @iRacingID)
	END
	ELSE
	BEGIN
		INSERT INTO EventEntries (EventID, iRacingID, CarID, Name, IsTeam)
		VALUES (@EventID, @iRacingID, @CarID, @Name, @IsTeam);
    
		-- Get the EntryID of the newly inserted row
		SET @EventEntryID = SCOPE_IDENTITY();
    END
	
    -- Insert into the EntryDriver table
	IF NOT EXISTS (SELECT * FROM EventEntryDrivers WHERE EventEntryID = @EventEntryID AND DriverID = @DriverID)
	BEGIN
		INSERT INTO EventEntryDrivers (EventEntryID, DriverID, OldiRating, NewiRating)
		VALUES (@EventEntryID, @DriverID, @OldiRating, @NewiRating);
	END
    
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateLocationAndLayout]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateLocationAndLayout]
(
    @LocationName varchar(50),
    @LayoutName varchar(50),
    @LayoutLength float,
    @LayoutCorners int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @LocationName IS NULL OR @LocationName = ''
    BEGIN
        RAISERROR('LocationName cannot be empty or null.', 16, 1);
        RETURN;
    END
    
    IF @LayoutName IS NULL OR @LayoutName = ''
    BEGIN
        RAISERROR('LayoutName cannot be empty or null.', 16, 1);
        RETURN;
    END
    
    IF @LayoutLength IS NULL
    BEGIN
        RAISERROR('LayoutLength cannot be null.', 16, 1);
        RETURN;
    END
    
    IF @LayoutCorners IS NULL
    BEGIN
        RAISERROR('LayoutCorners cannot be null.', 16, 1);
        RETURN;
    END
       
	DECLARE @LocationID int;
		-- Check if location already exists
    IF EXISTS(SELECT * FROM dbo.Locations WHERE Name = @LocationName)
    BEGIN
        RAISERROR('Location name already exists.', 0, 1);
		SET @LocationID = (SELECT TOP 1 ID FROM dbo.Locations WHERE Name = @LocationName)
    END
	ELSE
	BEGIN
	    -- Insert location
		INSERT INTO dbo.Locations (Name) VALUES (@LocationName);
		SET @LocationID = SCOPE_IDENTITY();
	END
       
    -- Check if layout already exists at existing location
	IF EXISTS(SELECT * FROM dbo.Layouts WHERE LocationID = @LocationID AND Name = @LayoutName)
	BEGIN
		RAISERROR('Layout name already exists.', 0, 1);
		RETURN;
	END
	ELSE
	BEGIN    
		INSERT INTO dbo.Layouts (Name, Length, Corners, LocationID) 
		VALUES (@LayoutName, @LayoutLength, @LayoutCorners, @LocationID);
	END   
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateSessionAndSessionType]    Script Date: 11/04/2023 15:37:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateSessionAndSessionType]
    @EventID INT,
    @SessionTypeName VARCHAR(50)
AS
BEGIN
    -- Check if SessionType already exists
    IF NOT EXISTS (SELECT * FROM SessionTypes WHERE Name = @SessionTypeName)
    BEGIN
        -- Insert new SessionType
        INSERT INTO SessionTypes (Name) VALUES (@SessionTypeName)
    END

    DECLARE @SessionTypeID INT

    -- Get SessionTypeID of the SessionType
    SELECT @SessionTypeID = ID FROM SessionTypes WHERE Name = @SessionTypeName

    -- Insert new Session
	IF NOT EXISTS (SELECT * FROM Sessions S WHERE S.EventID = @EventID AND S.SessionTypeID = @SessionTypeID)
	BEGIN
		INSERT INTO Sessions (EventID, SessionTypeID) VALUES (@EventID, @SessionTypeID)
	END
END
GO
USE [master]
GO
ALTER DATABASE [iRacingData] SET  READ_WRITE 
GO
