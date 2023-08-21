-- 1. Produce a timestamp for 1 a.m. on the 31st of August 2012
SELECT date '2012-08-31' + interval '1 hour';

-- 2. Find the result of subtracting the timestamp '2012-07-30 01:00:00' from the timestamp '2012-08-31 01:00:00'
SELECT timestamp '2012-08-31 01:00' - timestamp '2012-07-30 01:00';

-- 3. Generate a list of all the dates in October 2012
SELECT generate_series(timestamp '2012-10-01', timestamp '2012-10-31', '1 day'::interval) as ts;

-- 4. Get the day of the month from a timestamp 2012-08-31
SELECT extract(day from timestamp '2012-08-31') as date_part;

-- 5. Work out the number of seconds between timestamps
SELECT round(extract(epoch from (timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00')));

-- 6. Work out the number of days in each month of 2012
with all_months as (select generate_series(timestamp '2012-01-01', timestamp '2012-12-31',
										   '1 day'::interval) as ts)
																		
select extract(month from ts) as month, concat(count(1), ' days') as lenght
from all_months
group by extract(month from ts)
order by month;

-- 7. Work out the number of days remaining in the month from a timestamp
select (date_trunc('month', '2012-02-11 01:00:00'::date) + interval '1 month')
		- '2012-02-11 01:00:00'::date;

-- 8. Return a list of the start and end time of the last 10 bookings
select starttime, (starttime + (interval '30 minutes')*slots) as endtime
from cd.bookings
order by endtime desc, starttime desc
limit 10;

-- 9. Return a count of bookings for each month
select date_trunc('month', starttime) as month, count(*)
from cd.bookings
group by date_trunc('month', starttime)
order by month;

-- 10. Work out the utilisation percentage for each facility by month
with date_table as (select name, date_trunc('month', starttime) as month, sum(slots/2.0) as slots
				   from cd.facilities as f
					join cd.bookings as b on b.facid = f.facid
					group by name, date_trunc('month', starttime)
					order by name, month)

select name, month,
round(100 * slots / 
(12.5 * extract(day from ((month + interval '1 month') - month))::numeric),1)
from date_table;