-- 1. Retrieve everything from a table
select * from cd.facilities;

-- 2. Retrieve specific columns from a table
select name, membercost from cd.facilities;

-- 3. Produce a list of facilities that charge a fee to members
select * 
from cd.facilities
where membercost > 0;

-- 4. Produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost
select facid, name, membercost, monthlymaintenance  
from cd.facilities
where membercost > 0 AND membercost < monthlymaintenance/50;

-- 5. Produce a list of all facilities with the word 'Tennis' in their name
select * 
from cd.facilities
where name like '%Tennis%';

-- 6. Retrieve the details of facilities with ID 1 and 5, without using the OR operator
select * 
from cd.facilities
where facid in (1, 5);

-- 7. Produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on 
-- if their monthly maintenance cost is more than $100
select name,
case when monthlymaintenance > 100 then 'expensive'
	 when monthlymaintenance < 100 then 'cheap'
end as cost
from cd.facilities;

-- 8. Produce a list of members who joined after the start of September 2012
select memid, surname, firstname, joindate 
from cd.members
where joindate >= TO_DATE('20120901', 'YYYYMMDD');

-- 9. Produce an ordered list of the first 10 surnames in the members table
select DISTINCT surname
from cd.members
order by surname
limit 10;

-- 10. combined list of all surnames and all facility names
select surname
from cd.members
UNION ALL 
select name
from cd.facilities;

-- 11. Get the signup date of the last member (latest join date)
select max(joindate) as latest
from cd.members

-- 12. Get the first and last name of the last member(s) who signed up
select firstname, surname, joindate
from cd.members
where joindate = (select max(joindate) as latest
					from cd.members);

