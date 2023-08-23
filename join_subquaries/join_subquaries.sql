-- 1. Produce a list of the start times for bookings by members named 'David Farrell'
SELECT starttime
FROM cd.bookings as b
JOIN cd.members as m on m.memid = b.memid
WHERE firstname = 'David' and surname = 'Farrell';

-- 2. Produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'
SELECT starttime as start, name
FROM cd.bookings as b
JOIN cd.facilities as f on f.facid = b.facid
WHERE starttime::date = date '2012-09-21' and name like 'Tennis Court%'
ORDER BY starttime;

-- 3. Output a list of all members who have recommended another member, no duplicates and ordered by (surname, firstname)
SELECT distinct m2.firstname, m2.surname FROM 
cd.members as m1
JOIN cd.members as m2 on m1.recommendedby = m2.memid
WHERE m1.recommendedby is not null
ORDER BY m2.surname, m2.firstname;

-- 4. Output a list of all members, including the individual who recommended them (if any) and ordered by (surname, firstname)
SELECT m1.firstname as memfname, m1.surname as memsname,
m2.firstname as recfname, m2.surname as recsname
FROM cd.members as m1
left JOIN cd.members as m2 on m1.recommendedby = m2.memid
ORDER BY m1.surname, m1.firstname;

-- 5. Produce a list of all members who have used a tennis court. Include the name of the court, 
-- and the name of the member formatted as a single column. Ensure no duplicate data, and ORDER BY the member name followed by the facility name.
SELECT DISTINCT CONCAT(firstname,' ',surname) as member, f.name as facility
FROM cd.members as m
JOIN cd.bookings as b on b.memid = m.memid
JOIN cd.facilities as f on f.facid = b.facid
WHERE f.name like 'Tennis Court%'
ORDER BY member, facility;

-- 6. Produce a list of bookings on the day of 2012-09-14 which cost the member/guest) more than $30? The total cost is calculated as slots * cost. The output is:
-- the name of the facility, the name of the member formatted as a single column, and the cost. ORDER BY descending cost, and do not use any subqueries.
SELECT CONCAT(firstname,' ',surname) as member, f.name as facility, 
(slots * (CASE when m.memid <> 0 then membercost
     		when m.memid = 0 then guestcost end)) as cost
FROM cd.members as m
JOIN cd.bookings as b on b.memid = m.memid
JOIN cd.facilities as f on f.facid = b.facid
WHERE b.starttime::date = date '2012-09-14' AND (slots * (CASE when m.memid <> 0 then membercost
     														when m.memid = 0 then guestcost end)) > 30
ORDER BY cost desc;

-- 7. Output a list of all members, including the individual who recommended them (if any), WITHout using any JOINs.
-- Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
WITH rec_users as (SELECT memid as rec_id, CONCAT(firstname,' ',surname) as recommender
					FROM cd.members
					WHERE memid IN (SELECT recommendedby FROM cd.members))

SELECT * FROM (SELECT DISTINCT CONCAT(firstname,' ',surname) as member, recommender
			  FROM cd.members, rec_users
			  WHERE recommendedby = rec_id
			  union all
			  SELECT DISTINCT CONCAT(firstname,' ',surname) as member, null as recommender
			  FROM cd.members
			  WHERE recommendedby is null) as t
ORDER BY member;
-- After looking at the solution:
SELECT DISTINCT CONCAT(m1.firstname,' ',m1.surname) as member, 
(SELECT CONCAT(m2.firstname,' ',m2.surname) as recommender
 FROM cd.members as m2
 WHERE m1.recommendedby = m2.memid)
FROM cd.members AS m1	  
ORDER BY member;

-- 8. Rewrite exercise 6 with a subquary
SELECT member, facility, cost 
FROM (SELECT CONCAT(firstname,' ',surname) as member, starttime, f.name as facility, 
    (slots * (CASE when m.memid <> 0 then membercost
                when m.memid = 0 then guestcost end)) as cost
    FROM cd.members as m
    JOIN cd.bookings as b on b.memid = m.memid
    JOIN cd.facilities as f on f.facid = b.facid) as t
WHERE t.starttime::date = date '2012-09-14' AND cost > 30
ORDER BY cost desc;


