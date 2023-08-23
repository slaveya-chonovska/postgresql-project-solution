-- 1. Produce a timestamp for 1 a.m. on the 31st of August 2012
SELECT date '2012-08-31' + interval '1 hour';

-- 2. Find the result of subtracting the timestamp '2012-07-30 01:00:00' FROM the timestamp '2012-08-31 01:00:00'
SELECT timestamp '2012-08-31 01:00' - timestamp '2012-07-30 01:00';

-- 3. Generate a list of all the dates in October 2012
SELECT generate_series(timestamp '2012-10-01', timestamp '2012-10-31', '1 day'::interval) as ts;

-- 4. Get the day of the month FROM a timestamp 2012-08-31
SELECT extract(day FROM timestamp '2012-08-31') as date_part;

-- 5. Work out the number of seconds between timestamps
SELECT round(extract(epoch FROM (timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00')));

-- 6. Work out the number of days in each month of 2012
WITH all_months as (SELECT generate_series(timestamp '2012-01-01', timestamp '2012-12-31',
										   '1 day'::interval) as ts)
																		
SELECT extract(month FROM ts) as month, concat(count(1), ' days') as lenght
FROM all_months
GROUP BY extract(month FROM ts)
ORDER BY month;

-- 7. Work out the number of days remaining in the month FROM a timestamp
SELECT (date_trunc('month', '2012-02-11 01:00:00'::date) + interval '1 month')
		- '2012-02-11 01:00:00'::date;

-- 8. Return a list of the start and end time of the last 10 bookings
SELECT starttime, (starttime + (interval '30 minutes')*slots) as endtime
FROM cd.bookings
ORDER BY endtime desc, starttime desc
limit 10;

-- 9. Return a count of bookings for each month
SELECT date_trunc('month', starttime) as month, count(*)
FROM cd.bookings
GROUP BY date_trunc('month', starttime)
ORDER BY month;

-- 10. Work out the utilisation percentage for each facility by month
WITH date_table as (SELECT name, date_trunc('month', starttime) as month, sum(slots/2.0) as slots
				   FROM cd.facilities as f
					JOIN cd.bookings as b on b.facid = f.facid
					GROUP BY name, date_trunc('month', starttime)
					ORDER BY name, month)

SELECT name, month,
round(100 * slots / 
(12.5 * extract(day FROM ((month + interval '1 month') - month))::numeric),1)
FROM date_table;