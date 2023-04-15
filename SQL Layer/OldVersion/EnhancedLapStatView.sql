--CREATE VIEW vw_EnhancedLapData AS
SELECT
	LA.ID
	, LA.EventID
	, SE.ID SessionID
	, SE.SessionTypeID
	, EED.DriverID AS DriverID
	, EE.CarID
	, CC.ClassID
	, CASE WHEN EE.IsTeam = 1 THEN EE.Name ELSE NULL END AS TeamName
	, CASE WHEN EE.IsTeam = 1 THEN EE.iRacingID ELSE NULL END AS TeamID
	, LA.LapInSession
	, LA.LapTime
	, LA.TimeInSession
	, L2.PositionInClass AS PositionOnLap
	, CASE WHEN L3.BestLap IS NOT NULL AND LA.LapTime > 1 THEN (100 * LA.Laptime / L3.BestLap) - 100 ELSE NULL END AS PercentageGapToBestLap
	, La.TimeInSession - L3.LeaderTime AS GapToClassLeader
	, L3.BestLap
	, D.Name
	, SUM(CASE WHEN LET.Name = 'pitted' THEN 1 ELSE 0 END) AS Pitted
	, SUM(CASE WHEN LET.Name = 'invalid' THEN 1 ELSE 0 END) AS Invalid
	, SUM(CASE WHEN LET.Name = 'car reset' THEN 1 ELSE 0 END) AS Reset
	, SUM(CASE WHEN LET.Name = 'discontinuity' THEN 1 ELSE 0 END) AS Discontinuity
	, SUM(CASE WHEN LET.Name = 'off track' THEN 1 ELSE 0 END) AS OffTrack
	, SUM(CASE WHEN LET.Name = 'black flag' THEN 1 ELSE 0 END) AS BlackFlag
	, SUM(CASE WHEN LET.Name = 'lost control' THEN 1 ELSE 0 END) AS LostControl
	, SUM(CASE WHEN LET.Name = 'car contact' THEN 1 ELSE 0 END) AS CarContact
	, SUM(CASE WHEN LET.Name = 'contact' THEN 1 ELSE 0 END) AS Contact
FROM Laps LA
	INNER JOIN Sessions SE
		ON LA.SessionID = SE.ID
		AND LA.EventID = SE.EventID
	INNER JOIN EventEntryDrivers EED 
		ON LA.EventEntryID = EED.EventEntryID  SELECT * FROM EventEntryDrivers
	INNER JOIN EventEntries EE
		ON EED.EventEntryID = EE.ID
		AND EE.EventID = La.EventID
	INNER JOIN CarClasses CC
		ON EE.CarID = CC.CarID
	LEFT OUTER JOIN (
			SELECT 
				RANK() OVER (PARTITION BY Laps.EventID, Laps.SessionID, Laps.LapInSession, CC.ClassID ORDER BY Laps.TimeInSession) AS PositionInClass
				, EED.DriverID
				, Laps.EventID
				, Laps.SessionID
				, Laps.LapInSession
				, CC.ClassID
			FROM Laps 
			INNER JOIN EventEntryDrivers EED 
				ON Laps.EventEntryID = EED.EventEntryID
			INNER JOIN EventEntries EE
				ON EED.EventEntryID = EE.ID
			INNER JOIN CarClasses CC
				ON EE.CarID = CC.CarID			
			WHERE Laps.LapTime > 1
	) L2 ON L2.EventID = LA.EventID AND L2.SessionID = LA.SessionID AND L2.LapInSession = LA.LapInSession AND L2.DriverID = EED.DriverID
	LEFT OUTER JOIN (
			SELECT 
				MIN(Laps.LapTime) BestLap
				, MIN(Laps.TimeInSession) LeaderTime
				, Laps.EventID
				, Laps.SessionID
				, Laps.LapInSession
				, CC.ClassID
			FROM Laps 
			INNER JOIN EventEntryDrivers EED 
				ON Laps.EventEntryID = EED.EventEntryID
			INNER JOIN EventEntries EE
				ON EED.EventEntryID = EE.ID
			INNER JOIN CarClasses CC
				ON EE.CarID = CC.CarID
			WHERE LapTime > 1
			GROUP BY Laps.EventID, Laps.SessionID, Laps.LapInSession, CC.ClassID
		) L3 ON L3.EventID = LA.EventID AND L3.SessionID = LA.SessionID AND L3.LapInSession = LA.LapInSession
	LEFT OUTER JOIN LapEvents LE
		ON LE.LapID = LA.ID
	LEFT OUTER JOIN LapEventTypes LET
		ON LE.TypeID = LET.ID
	INNER JOIN Drivers D
		ON EED.DriverID = D.ID
	WHERE LA.EventID = 60776975 AND LA.SessionID = 5
	GROUP BY 
	LA.ID
	, LA.EventID
	, SE.ID 
	, SE.SessionTypeID
	, EED.DriverID
	, EE.CarID
	, CC.ClassID
	, CASE WHEN EE.IsTeam = 1 THEN EE.Name ELSE NULL END
	, CASE WHEN EE.IsTeam = 1 THEN EE.iRacingID ELSE NULL END
	, LA.LapInSession
	, LA.LapTime
	, LA.TimeInSession
	, L2.PositionInClass
	, CASE WHEN L3.BestLap IS NOT NULL AND LA.LapTime > 1 THEN (100 * LA.Laptime / L3.BestLap) - 100 ELSE NULL END
	, La.TimeInSession - L3.LeaderTime
	, L3.BestLap
	, D.Name
ORDER BY La.ID

