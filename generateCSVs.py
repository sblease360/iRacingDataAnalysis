import pyodbc
import csv

CONN_STR = (
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    r'SERVER=(local)\SQLEXPRESS;'
    r'DATABASE=iRacingData;'
    r'Trusted_Connection=yes;'
)
CNXN = pyodbc.connect(CONN_STR)
CURSOR = CNXN.cursor()

CURSOR.execute("SELECT * FROM vw_EnhancedEventDetails")
results = CURSOR.fetchall()

filename = "data/eventDetails.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM vw_EnhancedLapData")
results = CURSOR.fetchall()

filename = "data/lapDetails.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM vw_EnhancedSessionEntryDetails")
results = CURSOR.fetchall()

filename = "data/sessionEntryDetails.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM vw_EventSessionClassFilterDetails")
results = CURSOR.fetchall()

filename = "data/eventSessionClassFilterDetails.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM vw_PitTimeLoss")
results = CURSOR.fetchall()

filename = "data/pitTimeLoss.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM DriverSessionEntries")
results = CURSOR.fetchall()

filename = "data/DriverEntryDetails.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM Drivers")
results = CURSOR.fetchall()

filename = "data/Drivers.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM Cars")
results = CURSOR.fetchall()

filename = "data/Cars.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.execute("SELECT * FROM Classes")
results = CURSOR.fetchall()

filename = "data/Classes.csv"

with open(filename, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow([i[0] for i in CURSOR.description])
    csvwriter.writerows(results)

CURSOR.close()
CNXN.close()