// Statuses with counts of incidents
MATCH (status:Status)--(incident:Incident) RETURN status.code, status.description, count(incident) ORDER BY status.code


// Top crimes per area by incident counts
MATCH (area:Area)<-[:happened_in]-(incident:Incident)-[:reported_crime]->(crime:Crime)
WITH area, crime, count(incident) AS count
 ORDER BY count DESC
WITH area, collect(crime) AS crimes
 UNWIND crimes[0..5] AS crime
RETURN area.name, crime.description
 ORDER BY area.name


// Crimes per area by incident counts
MATCH (area:Area)<-[:happened_in]-(incident:Incident)-[:reported_crime]->(crime:Crime)
RETURN area.name, crime.description, count(incident)
 ORDER BY area.name, count(incident) DESC



// Data around incidents at 9300 S HOOVER ST
MATCH (i:Incident {address: '9300 S HOOVER ST'})--(n)
WHERE n:Address OR n:Status OR n:Area OR n:Crime
RETURN *
