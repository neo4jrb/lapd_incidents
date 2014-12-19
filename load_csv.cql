CREATE CONSTRAINT ON (n:Area) ASSERT n.number IS UNIQUE;
CREATE CONSTRAINT ON (n:Crime) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :Status(code);
CREATE CONSTRAINT ON (n:Incident) ASSERT n.dr_no IS UNIQUE;
CREATE INDEX ON :Incident(location);
CREATE INDEX ON :Incident(address);
CREATE CONSTRAINT ON (n:Address) ASSERT n.text IS UNIQUE;

CREATE CONSTRAINT ON (n:Date)  ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:Month) ASSERT n.text IS UNIQUE;

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///Users/brian/github/neo4jrb/lapd_incidents/db/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv" AS line
MERGE (area:Area {name: line.`AREA NAME`, number: line.`AREA`});

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///Users/brian/github/neo4jrb/lapd_incidents/db/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv" AS line
MERGE (crime:Crime {description: line.`Crm Cd Desc`, code: line.`Crm Cd`});

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///Users/brian/github/neo4jrb/lapd_incidents/db/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv" AS line
MERGE (status:Status {code: line.Status, description: coalesce(line.`Status Desc`, '')});


USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///Users/brian/github/neo4jrb/lapd_incidents/db/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv" AS line
CREATE (incident:Incident
  {
    dr_no: toInt(line.`DR NO`),
    location: line.LOCATION,
    date_reported: line.`Date Rptd`,
    latitute: split(split(line.`Location 1`, ',')[0], '(')[1],
    longitude: split(split(line.`Location 1`, ',')[1], ')')[0],
    address: line.RD,
    time: line.`TIME OCC`,
    date: line.`DATE OCC`
  });


USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///Users/brian/github/neo4jrb/lapd_incidents/db/LAPD_Crime_and_Collision_Raw_Data_-_2014.csv" AS line
MATCH (area:Area {number: line.`AREA`})
MATCH (crime:Crime {code: line.`Crm Cd`})
MATCH (status:Status {code: line.Status})
MATCH (incident:Incident {dr_no: toInt(line.`DR NO`)})
MERGE (area)<-[:happened_in]-incident
MERGE incident-[:reported_crime]->(crime)
MERGE incident-[:has_status]->status;

MATCH (incident:Incident) WHERE incident.address =~ '[0-9]+ .*'
MERGE (address:Address {text: UPPER(incident.address)})
CREATE incident-[:has_address]->address;

MATCH (incident:Incident)
WITH incident, toInt(split(incident.date, '/')[0]) AS month_number
WITH incident, month_number, [null, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][month_number] AS month_text
MERGE (date:Date {text: incident.date})
MERGE (month:Month {number: month_number, text: month_text})
MERGE date-[:in_month]->month
CREATE incident-[:happened_on_date]->date;
