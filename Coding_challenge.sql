--creating the database
create database Crime_management
use Crime_management

--creating the tables
CREATE TABLE Crime (
 CrimeID INT PRIMARY KEY,
 IncidentType VARCHAR(255),
 IncidentDate DATE,
 Location VARCHAR(255),
 Description TEXT,
 Status VARCHAR(20)
);

CREATE TABLE Victim (
 VictimID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 ContactInfo VARCHAR(255),
 Injuries VARCHAR(255),
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE Suspect (
 SuspectID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 Description TEXT,
 CriminalHistory TEXT,
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);


-- Insert sample data
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
 (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
 (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under
Investigation'),
 (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

--inserted one tuple
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
 (4, 'Robbery', '2024-04-15', '123 Cityville', 'Armed robbery at a grocery store', 'Open')


INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries)
VALUES
 (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
 (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
 (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');

--adding the DateOfBirth attribute in Victim table
alter table Victim
add DateOfBirth DATE

--inserting the DateOfBirth values
update Victim
set DateOfBirth = '1990-01-07'
where VictimID=1

update Victim
set DateOfBirth = '1991-01-07'
where VictimID=2

update Victim
set DateOfBirth = '1993-01-07'
where VictimID=3

-- Inserting sample data
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory)
VALUES
 (1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
 (2, 2, 'Unknown', 'Investigation ongoing', NULL),
 (3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');

--adding the DateOfBirth attribute in the Suspect table
alter table Suspect
add DateOfBirth DATE

--inserting the DateOfBirth values
update Suspect
set DateOfBirth = '1989-01-07'
where SuspectID=1

update Suspect
set DateOfBirth = '1991-02-07'
where SuspectID=2

update Suspect
set DateOfBirth = '1992-03-07'
where SuspectID=3


                                      --Questions--

-- 1. Select all open incidents.
select * from Crime where Status='Open'

--2. Find the total number of incidents.
select count(distinct CrimeID) as [total number of incidents] from Crime

--3. List all unique incident types.
select distinct IncidentType from Crime

--4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.
select * from Crime where IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';


--5. List persons involved in incidents in descending order of age.
select VictimId,name, DATEDIFF(year,DateofBirth,GETDATE()) as age from Victim
union all
select SuspectId,name, DATEDIFF(year,DateofBirth,GETDATE()) as age from Suspect
order by age desc

--age of only victims in descending order
select VictimId,name, DATEDIFF(year,DateofBirth,GETDATE()) as age from Victim order by age desc

--6. Find the average age of persons involved in incidents.

-- AVG age of both suspects and victims
select avg (age) as [Average age]
from (select DATEDIFF(year,DateofBirth,GETDATE()) as age
from Victim  
union
select DATEDIFF(year,DateofBirth,GETDATE()) as age
from Suspect  ) as subquerry

--of only victims
select avg (age) as [Average age]
from (select DATEDIFF(year,DateofBirth,GETDATE()) as age
from Victim) as subquerry


--7. List incident types and their counts, only for open cases.
select IncidentType, count(*) as [count]
from Crime where Status='open'
group by IncidentType


--8. Find persons with names containing 'Doe'.
select name from Victim where name like '%Doe%'
union
select name from Suspect where name like '%Doe%'


--9. Retrieve the names of persons involved in open cases and closed cases.
select name as [Name] from Victim where CrimeID IN (select CrimeID from Crime where Status = 'Open')
UNION
select name [Name] from Victim where CrimeID IN (select CrimeID from Crime where Status = 'Closed')
UNION
select name as [Name] from Suspect where CrimeID IN (select CrimeID from Crime where Status = 'Open')
UNION
select name [Name] from Suspect where CrimeID IN (select CrimeID from Crime where Status = 'Closed')

--10. List incident types where there are persons aged 30 or 35 involved.
select IncidentType
from Crime
where CrimeID in (
select CrimeID from Victim where DATEDIFF(year, DateOfBirth,GETDATE()) in (30,35)
union select CrimeID from Suspect where DATEDIFF(year, DateOfBirth,GETDATE()) in (30,35) )


--11. Find persons involved in incidents of the same type as 'Robbery'.
select name as [Name]
from Victim
where CrimeID in (select CrimeID from crime where IncidentType='Robbery')
union
select name as [Name]
from Suspect
where CrimeID in (select CrimeID from crime where IncidentType='Robbery')

--12. List incident types with more than one open case.
select IncidentType
from Crime 
where Status='open'
group by IncidentType
having count(*)>1


--13. List all incidents with suspects whose names also appear as victims in other incidents.
select c.CrimeID, c.IncidentType, c.IncidentDate, c.Location, c.Description, c.Status
from Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
where s.Name IN (
    select Name
    from Victim
)


--14. Retrieve all incidents along with victim and suspect details.
select c.*, v.Name AS VictimName, v.ContactInfo, v.Injuries, s.Name AS SuspectName, s.Description AS SuspectDescription, s.CriminalHistory 
from Crime c left join Victim v on c.CrimeID=v.CrimeID
left join Suspect s on c.CrimeID=s.CrimeID

--15. Find incidents where the suspect is older than any victim.
select c.IncidentType
from Crime c left join Victim v on c.CrimeID=v.CrimeID
left join Suspect s on c.CrimeID=s.CrimeID
where (DATEDIFF(year,s.DateOfBirth,v.DateOfBirth)>0)


--16. Find suspects involved in multiple incidents:
select name
from Suspect
group by name
having COUNT(distinct CrimeID) > 1

--17. List incidents with no suspects involved.
select * 
from Crime 
where CrimeID not in (select distinct CrimeID from Suspect)

--18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type
--'Robbery'.
select CrimeID
from Crime
group by CrimeID
having 
    COUNT(CASE when IncidentType = 'Homicide' THEN 1 END) >= 1 -- This condition counts the number of occurrences where the IncidentType is 'Homicide' within each group
    AND COUNT(CASE when IncidentType = 'Robbery' THEN 1 END) = (COUNT(*) - 1) --This condition counts the number of occurrences where the IncidentType is 'Robbery' within each group (CrimeID). The expression (COUNT(*) - 1) calculates the total count of incidents in each group minus 1. 


--19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or
--'No Suspect' if there are none.
select c.* , s.Name AS SuspectName, s.Description AS SuspectDescription, s.CriminalHistory 
from Crime c left join Suspect s
on c.CrimeID=s.CrimeID

--20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'
select name
from suspect 
where CrimeID in (select CrimeID from crime where IncidentType in ('Robbery', 'Assault'))