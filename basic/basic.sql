-- 1. Retrieve everything FROM a table
SELECT * FROM cd.facilities;

-- 2. Retrieve specific columns FROM a table
SELECT name, membercost FROM cd.facilities;

-- 3. Produce a list of facilities that charge a fee to members
SELECT * 
FROM cd.facilities
WHERE membercost > 0;

-- 4. Produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost
SELECT facid, name, membercost, monthlymaintenance  
FROM cd.facilities
WHERE membercost > 0 AND membercost < monthlymaintenance/50;

-- 5. Produce a list of all facilities with the word 'Tennis' in their name
SELECT * 
FROM cd.facilities
WHERE name like '%Tennis%';

-- 6. Retrieve the details of facilities with ID 1 and 5, without using the OR operator
SELECT * 
FROM cd.facilities
WHERE facid in (1, 5);

-- 7. Produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on 
-- if their monthly maintenance cost is more than $100
SELECT name,
CASE when monthlymaintenance > 100 then 'expensive'
	 when monthlymaintenance < 100 then 'cheap'
end as cost
FROM cd.facilities;

-- 8. Produce a list of members who JOINed after the start of September 2012
SELECT memid, surname, firstname, JOINdate 
FROM cd.members
WHERE JOINdate >= TO_DATE('20120901', 'YYYYMMDD');

-- 9. Produce an ordered list of the first 10 surnames in the members table
SELECT DISTINCT surname
FROM cd.members
ORDER BY surname
limit 10;

-- 10. combined list of all surnames and all facility names
SELECT surname
FROM cd.members
UNION ALL 
SELECT name
FROM cd.facilities;

-- 11. Get the signup date of the last member (latest JOIN date)
SELECT max(JOINdate) as latest
FROM cd.members

-- 12. Get the first and last name of the last member(s) who signed up
SELECT firstname, surname, JOINdate
FROM cd.members
WHERE JOINdate = (SELECT max(JOINdate) as latest
					FROM cd.members);

