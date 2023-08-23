-- 1. Count the number of facilities
SELECT count(1) FROM cd.facilities;

-- 2. Count the number of facilities with guest cost more than 10
SELECT count(1)
FROM cd.facilities
WHERE guestcost > 10;

-- 3. Count the number of recommendations each member makes.
SELECT recommendedby, count(memid)
FROM cd.members
WHERE recommendedby is not null
GROUP BY recommendedby
ORDER BY recommendedby;

-- 4. List the total slots booked per facility
SELECT facid, sum(slots)
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

-- 5. List the total slots booked per facility in a September 2012
SELECT facid, sum(slots) as total_slots
FROM cd.bookings
WHERE starttime::date BETWEEN date '2012-09-01' AND date '2012-09-30'
GROUP BY facid
ORDER BY total_slots;

-- 6. List the total slots booked per facility per month for the year 2012
SELECT facid, EXTRACT(month FROM starttime) as month, sum(slots)
FROM cd.bookings
WHERE EXTRACT(year FROM starttime) = 2012
GROUP BY facid, EXTRACT(month FROM starttime)
ORDER BY facid, EXTRACT(month FROM starttime);

-- 7. Find the count of members who have made at least one booking
SELECT count(distinct memid)
FROM cd.bookings;

-- 8. List facilities with more than 1000 slots booked
SELECT facid, sum(slots) as total_slots
FROM cd.bookings
GROUP BY facid
HAVING sum(slots) > 1000
ORDER BY facid;

-- 9. Find the total revenue of each facility
SELECT name, sum(slots * (CASE when memid = 0 then guestcost
					  		when memid <> 0 then membercost end)) as revenue
FROM cd.facilities as f
JOIN cd.bookings as b on b.facid = f.facid
GROUP BY name
ORDER BY revenue;

-- 10. Find facilities with a total revenue less than 1000
SELECT name, sum(slots * (CASE when memid = 0 then guestcost
					  		when memid <> 0 then membercost end)) as revenue
FROM cd.facilities as f
JOIN cd.bookings as b on b.facid = f.facid
GROUP BY name
HAVING sum(slots * (CASE when memid = 0 then guestcost
					  		when memid <> 0 then membercost end)) < 1000
ORDER BY revenue;

-- 11. Output the facility id that has the highest number of slots booked
WITH all_slots as (SELECT facid, sum(slots) as total_slots
				  FROM cd.bookings
				  GROUP BY facid)
SELECT facid, total_slots
FROM all_slots
WHERE total_slots = (SELECT max(total_slots) FROM all_slots);

-- 12. List the total slots booked per facility per month in 2012, also display the total for the year
-- for each facility and the overall total slots
WITH by_month as (SELECT facid, EXTRACT(month FROM starttime) as month, sum(slots) as slots
				  FROM cd.bookings
				  WHERE EXTRACT(year FROM starttime) = 2012
				  GROUP BY facid, EXTRACT(month FROM starttime)
				  ORDER BY facid, EXTRACT(month FROM starttime)),
	total_slots_by_id as (SELECT facid, null::int as month ,sum(slots) as slots
						  FROM by_month
						  GROUP BY facid),
	total_slots as (SELECT null::int as facid, null::int as month , sum(slots) as slots
				    FROM by_month),
	union_slots as (SELECT * FROM by_month
				    union all
				    SELECT * FROM total_slots_by_id
				    union all
				   	SELECT * FROM total_slots)
	
SELECT *
FROM union_slots
ORDER BY facid, slots;

-- A solution with ROLLUP, as suggested by the solution
SELECT facid,  EXTRACT(month FROM starttime) as month, sum(slots) as total_slots
FROM cd.bookings
WHERE EXTRACT(year FROM starttime) = 2012
GROUP BY ROLLUP(facid, EXTRACT(month FROM starttime))
ORDER BY facid, total_slots;

-- 13. List the total hours booked per named facility, each slots is half an hour
SELECT distinct b.facid, name, round(sum(slots)/2::decimal, 2) as total_slots
FROM cd.bookings as b
JOIN cd.facilities as f on f.facid = b.facid
GROUP BY b.facid, name
ORDER BY b.facid;

-- 14. List each member's first booking after September 1st 2012
SELECT surname, firstname, memid, starttime
FROM (SELECT surname, firstname, m.memid, starttime,
	row_number() over(partition by m.memid ORDER BY m.memid) as rn
	FROM cd.members as m
	JOIN cd.bookings as b on b.memid = m.memid
	WHERE starttime >= '2012-09-01') as t
WHERE rn = 1;

-- 15. Produce a list of member names, with each row containing the total member count, ORDER BY JOIN date
SELECT count(memid) over() as count, firstname, surname
FROM cd.members
ORDER BY JOINdate;

-- 16. Produce a numbered list of members
SELECT row_number() over (), firstname, surname
FROM cd.members
ORDER BY JOINdate;

-- 17. Output the facility id that has the highest number of slots booked, again
SELECT facid, total_slots
FROM (SELECT facid, sum(slots) as total_slots,
	  dense_rank() over(ORDER BY sum(slots) desc) as rnk
	  FROM cd.bookings
	  GROUP BY facid) as t
WHERE rnk = 1;

-- 18. Rank members by (rounded by ten) hours used, ORDER BY rank, surname, and first name
SELECT firstname, surname, round(sum(slots)/2::decimal, -1) as hours,
rank() over(ORDER BY round(sum(slots)/2::decimal, -1) desc) as rnk
FROM cd.members as m
JOIN cd.bookings as b on b.memid = m.memid
GROUP BY firstname, surname
ORDER BY rnk, surname, firstname;

-- 19. Find the top three revenue generating facilities
WITH pref_cost as (SELECT name, slots * ((CASE when memid = 0 then guestcost
					  					when memid <> 0 then membercost end)) as cost
				   FROM cd.facilities as f
				   JOIN cd.bookings as b on b.facid = f.facid)

SELECT * FROM (SELECT name, rank() over (ORDER BY sum(cost) desc) as rnk
			  FROM pref_cost
			  GROUP BY name) as t
WHERE rnk <= 3
ORDER BY rnk, name;

-- 20. Classify facilities by equally sized groups of high, average, and low based on their revenue.
-- ORDER BY classification and facility name

WITH pref_cost as (SELECT name, slots * ((CASE when memid = 0 then guestcost
					  					when memid <> 0 then membercost end)) as cost
				   FROM cd.facilities as f
				   JOIN cd.bookings as b on b.facid = f.facid),
	facilities_buckets as (SELECT name, ntile(3) over(ORDER BY sum(cost) desc) as buckets
						  FROM pref_cost
						  GROUP BY name)
SELECT name,
CASE when buckets = 1 then 'high'
     when buckets = 2 then 'average'
	 when buckets = 3 then 'low'
end as revenue
FROM facilities_buckets
ORDER BY buckets, name;

-- 21. Calculate the payback time for each facility
WITH pref_cost as (SELECT name, initialoutlay, monthlymaintenance, slots * 
										((CASE when memid = 0 then guestcost
					  					when memid <> 0 then membercost end)) as cost
				   FROM cd.facilities as f
				   JOIN cd.bookings as b on b.facid = f.facid)

SELECT name, initialoutlay / (sum(cost)/3 - monthlymaintenance)::decimal as months
FROM pref_cost
GROUP BY name, initialoutlay, monthlymaintenance
ORDER BY name;

-- 22. Calculate a rolling average of total revenue

WITH date_range AS (SELECT generate_series('2012-07-10', '2012-08-31','1 day'::interval)::date as date),
  
 	all_revenue as (SELECT date, sum(slots * (CASE when memid <> 0 then membercost
					   	when memid = 0 then guestcost end)) as revenue
					FROM date_range as d
					left JOIN (cd.bookings as b JOIN cd.facilities as f on f.facid = b.facid) 
					on starttime::date = d.date
					GROUP BY d.date)
SELECT * FROM (SELECT date, 
			  avg(revenue) over(ORDER BY date rows 14 preceding) as revenue
			  FROM all_revenue) as avg_rev_table
WHERE date >= '2012-08-01';
