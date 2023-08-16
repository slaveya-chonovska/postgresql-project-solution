-- 1. Produce a list of the start times for bookings by members named 'David Farrell'
select starttime
from cd.bookings as b
join cd.members as m on m.memid = b.memid
where firstname = 'David' and surname = 'Farrell';

-- 2. Produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'
select starttime as start, name
from cd.bookings as b
join cd.facilities as f on f.facid = b.facid
where starttime::date = date '2012-09-21' and name like 'Tennis Court%'
order by starttime;

-- 3. Output a list of all members who have recommended another member, no duplicates and ordered by (surname, firstname)
select distinct m2.firstname, m2.surname from 
cd.members as m1
join cd.members as m2 on m1.recommendedby = m2.memid
where m1.recommendedby is not null
order by m2.surname, m2.firstname;

-- 4. Output a list of all members, including the individual who recommended them (if any) and ordered by (surname, firstname)
select m1.firstname as memfname, m1.surname as memsname,
m2.firstname as recfname, m2.surname as recsname
from cd.members as m1
left join cd.members as m2 on m1.recommendedby = m2.memid
order by m1.surname, m1.firstname;

-- 5. Produce a list of all members who have used a tennis court. Include the name of the court, 
-- and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name followed by the facility name.
select DISTINCT CONCAT(firstname,' ',surname) as member, f.name as facility
from cd.members as m
join cd.bookings as b on b.memid = m.memid
join cd.facilities as f on f.facid = b.facid
where f.name like 'Tennis Court%'
order by member, facility;

-- 6. Produce a list of bookings on the day of 2012-09-14 which cost the member/guest) more than $30? The total cost is calculated as slots * cost. The output is:
-- the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.
select CONCAT(firstname,' ',surname) as member, f.name as facility, 
(slots * (case when m.memid <> 0 then membercost
     		when m.memid = 0 then guestcost end)) as cost
from cd.members as m
join cd.bookings as b on b.memid = m.memid
join cd.facilities as f on f.facid = b.facid
where b.starttime::date = date '2012-09-14' AND (slots * (case when m.memid <> 0 then membercost
     														when m.memid = 0 then guestcost end)) > 30
order by cost desc;

-- 7. Output a list of all members, including the individual who recommended them (if any), without using any joins.
-- Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
with rec_users as (select memid as rec_id, CONCAT(firstname,' ',surname) as recommender
					from cd.members
					where memid IN (select recommendedby from cd.members))

select * from (select DISTINCT CONCAT(firstname,' ',surname) as member, recommender
			  from cd.members, rec_users
			  where recommendedby = rec_id
			  union all
			  select DISTINCT CONCAT(firstname,' ',surname) as member, null as recommender
			  from cd.members
			  where recommendedby is null) as t
order by member;
-- After looking at the solution:
select DISTINCT CONCAT(m1.firstname,' ',m1.surname) as member, 
(select CONCAT(m2.firstname,' ',m2.surname) as recommender
 from cd.members as m2
 where m1.recommendedby = m2.memid)
from cd.members AS m1	  
order by member;

-- 8. Rewrite exercise 6 with a subquary
select member, facility, cost 
from (select CONCAT(firstname,' ',surname) as member, starttime, f.name as facility, 
    (slots * (case when m.memid <> 0 then membercost
                when m.memid = 0 then guestcost end)) as cost
    from cd.members as m
    join cd.bookings as b on b.memid = m.memid
    join cd.facilities as f on f.facid = b.facid) as t
where t.starttime::date = date '2012-09-14' AND cost > 30
order by cost desc;


