DROP VIEW IF EXISTS vw_EnhancedLapData
GO

CREATE VIEW vw_EnhancedLapData AS

SELECT 
	SE.EventID
	, SE.SessionID
	, DE.DriverID
	, CA.CarID
	, CA.ClassID
	, LA.*
	, ELD.PositionInClass
	, ELD.BestLapOnLap
	, ELD.LeaderLapStartTime
	, CASE WHEN ELD.BestLapOnLap IS NOT NULL AND LA.LapTime > 1 THEN (100 * LA.Laptime / ELD.BestLapOnLap) - 100 ELSE NULL END AS PercentageGapToBestLap
	, LA.LapStartTime - ELD.LeaderLapStartTime AS GapToClassLeader
FROM (
			SELECT 
				LapID
				, DriverEntryID
				, LapTime
				, LapStartTime
				, LapInSession
				, CASE WHEN ([black flag] + [car contact] + [car reset] + [contact] + [discontinuity] + [invalid] + [lost control] + [off track] + [pitted] + [tow]) = 0 THEN 1 ELSE 0 END AS CleanLap
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
	LEFT OUTER JOIN (
			SELECT 
				LA.LapID
				, RANK() OVER (PARTITION BY EE.EventID, SE.SessionID, LA.LapInSession, CL.ClassID ORDER BY LA.LapStartTime) AS PositionInClass
				, MIN(LA.LapTime) OVER (PARTITION BY EE.EventID, SE.SessionID, LA.LapInSession, CL.ClassID ORDER BY LA.LapStartTime) AS BestLapOnLap
				, MIN(La.LapStartTime) OVER (PARTITION BY EE.EventID, SE.SessionID, LA.LapInSession, CL.ClassID ORDER BY LA.LapStartTime) AS LeaderLapStartTime
			FROM Laps LA
				INNER JOIN DriverEntries DE
					ON LA.DriverEntryID = DE.DriverEntryID
				INNER JOIN EventEntries EE
					ON DE.EventEntryID = EE.EntryID
				INNER JOIN Cars CA
					ON EE.CarID = CA.CarID
				INNER JOIN Classes CL
					ON CA.ClassID = CL.ClassID
				INNER JOIN Sessions SE
					ON DE.SessionID = SE.SessionID
	) ELD ON LA.LapID = ELD.LapID
	INNER JOIN DriverEntries DE
		ON LA.DriverEntryID = DE.DriverEntryID
	INNER JOIN EventEntries EE
		ON DE.EventEntryID = EE.EntryID
	INNER JOIN Cars CA
		ON EE.CarID = CA.CarID
	INNER JOIN Sessions SE 
		ON DE.SessionID = SE.SessionID
	
