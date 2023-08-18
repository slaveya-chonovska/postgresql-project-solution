-- 1. Count the number of facilities
select count(1) from cd.facilities;

-- 2. Count the number of facilities with guest cost more than 10
select count(1)
from cd.facilities
where guestcost > 10;

-- 3. Count the number of recommendations each member makes.
select recommendedby, count(memid)
from cd.members
where recommendedby is not null
group by recommendedby
order by recommendedby;

-- 4. List the total slots booked per facility
select facid, sum(slots)
from cd.bookings
group by facid
order by facid;

-- 5. List the total slots booked per facility in a September 2012
select facid, sum(slots) as total_slots
from cd.bookings
where starttime::date BETWEEN date '2012-09-01' AND date '2012-09-30'
group by facid
order by total_slots;

-- 6. List the total slots booked per facility per month for the year 2012
select facid, EXTRACT(month from starttime) as month, sum(slots)
from cd.bookings
where EXTRACT(year from starttime) = 2012
group by facid, EXTRACT(month from starttime)
order by facid, EXTRACT(month from starttime);

-- 7. Find the count of members who have made at least one booking
select count(distinct memid)
from cd.bookings;

-- 8. List facilities with more than 1000 slots booked
select facid, sum(slots) as total_slots
from cd.bookings
group by facid
having sum(slots) > 1000
order by facid;

-- 9. Find the total revenue of each facility
select name, sum(slots * (case when memid = 0 then guestcost
					  		when memid <> 0 then membercost end)) as revenue
from cd.facilities as f
join cd.bookings as b on b.facid = f.facid
group by name
order by revenue;

-- 10. Find facilities with a total revenue less than 1000
select name, sum(slots * (case when memid = 0 then guestcost
					  		when memid <> 0 then membercost end)) as revenue
from cd.facilities as f
join cd.bookings as b on b.facid = f.facid
group by name
having sum(slots * (case when memid = 0 then guestcost
					  		when memid <> 0 then membercost end)) < 1000
order by revenue;

-- 11. Output the facility id that has the highest number of slots booked
with all_slots as (select facid, sum(slots) as total_slots
				  from cd.bookings
				  group by facid)
select facid, total_slots
from all_slots
where total_slots = (select max(total_slots) from all_slots);

-- 12. List the total slots booked per facility per month in 2012, also display the total for the year
-- for each facility and the overall total slots
with by_month as (select facid, EXTRACT(month from starttime) as month, sum(slots) as slots
				  from cd.bookings
				  where EXTRACT(year from starttime) = 2012
				  group by facid, EXTRACT(month from starttime)
				  order by facid, EXTRACT(month from starttime)),
	total_slots_by_id as (select facid, null::int as month ,sum(slots) as slots
						  from by_month
						  group by facid),
	total_slots as (select null::int as facid, null::int as month , sum(slots) as slots
				    from by_month),
	union_slots as (select * from by_month
				    union all
				    select * from total_slots_by_id
				    union all
				   	select * from total_slots)
	
select *
from union_slots
order by facid, slots;

-- A solution with ROLLUP, as suggested by the solution
select facid,  EXTRACT(month from starttime) as month, sum(slots) as total_slots
from cd.bookings
where EXTRACT(year from starttime) = 2012
group by ROLLUP(facid, EXTRACT(month from starttime))
order by facid, total_slots;

-- 13. List the total hours booked per named facility, each slots is half an hour
select distinct b.facid, name, round(sum(slots)/2::decimal, 2) as total_slots
from cd.bookings as b
join cd.facilities as f on f.facid = b.facid
group by b.facid, name
order by b.facid;

-- 14. List each member's first booking after September 1st 2012
select surname, firstname, memid, starttime
from (select surname, firstname, m.memid, starttime,
	row_number() over(partition by m.memid order by m.memid) as rn
	from cd.members as m
	join cd.bookings as b on b.memid = m.memid
	where starttime >= '2012-09-01') as t
where rn = 1;

-- 15. Produce a list of member names, with each row containing the total member count, order by join date
select count(memid) over() as count, firstname, surname
from cd.members
order by joindate;

-- 16. Produce a numbered list of members
select row_number() over (), firstname, surname
from cd.members
order by joindate;

-- 17. Output the facility id that has the highest number of slots booked, again
select facid, total_slots
from (select facid, sum(slots) as total_slots,
	  dense_rank() over(order by sum(slots) desc) as rnk
	  from cd.bookings
	  group by facid) as t
where rnk = 1;

-- 18. Rank members by (rounded by ten) hours used, order by rank, surname, and first name
select firstname, surname, round(sum(slots)/2::decimal, -1) as hours,
rank() over(order by round(sum(slots)/2::decimal, -1) desc) as rnk
from cd.members as m
join cd.bookings as b on b.memid = m.memid
group by firstname, surname
order by rnk, surname, firstname;

-- 19. Find the top three revenue generating facilities
with pref_cost as (select name, slots * ((case when memid = 0 then guestcost
					  					when memid <> 0 then membercost end)) as cost
				   from cd.facilities as f
				   join cd.bookings as b on b.facid = f.facid)

select * from (select name, rank() over (order by sum(cost) desc) as rnk
			  from pref_cost
			  group by name) as t
where rnk <= 3
order by rnk, name;

-- 20. Classify facilities by equally sized groups of high, average, and low based on their revenue.
-- Order by classification and facility name

with pref_cost as (select name, slots * ((case when memid = 0 then guestcost
					  					when memid <> 0 then membercost end)) as cost
				   from cd.facilities as f
				   join cd.bookings as b on b.facid = f.facid),
	facilities_buckets as (select name, ntile(3) over(order by sum(cost) desc) as buckets
						  from pref_cost
						  group by name)
select name,
case when buckets = 1 then 'high'
     when buckets = 2 then 'average'
	 when buckets = 3 then 'low'
end as revenue
from facilities_buckets
order by buckets, name;

-- 21. Calculate the payback time for each facility
with pref_cost as (select name, initialoutlay, monthlymaintenance, slots * 
										((case when memid = 0 then guestcost
					  					when memid <> 0 then membercost end)) as cost
				   from cd.facilities as f
				   join cd.bookings as b on b.facid = f.facid)

select name, initialoutlay / (sum(cost)/3 - monthlymaintenance)::decimal as months
from pref_cost
group by name, initialoutlay, monthlymaintenance
order by name;

-- 22. Calculate a rolling average of total revenue

with date_range AS (SELECT generate_series('2012-07-10', '2012-08-31','1 day'::interval)::date as date),
  
 	all_revenue as (select date, sum(slots * (case when memid <> 0 then membercost
					   	when memid = 0 then guestcost end)) as revenue
					from date_range as d
					left join (cd.bookings as b join cd.facilities as f on f.facid = b.facid) 
					on starttime::date = d.date
					group by d.date)
select * from (select date, 
			  avg(revenue) over(order by date rows 14 preceding) as revenue
			  from all_revenue) as avg_rev_table
where date >= '2012-08-01';
