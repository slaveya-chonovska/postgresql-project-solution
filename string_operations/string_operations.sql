-- 1. Output the names of all members, formatted as 'Surname, Firstname'
select CONCAT(surname,', ', firstname)
from cd.members;

-- 2. Find all facilities whose name begins with 'Tennis'
select *
from cd.facilities
where name like 'Tennis%';

-- 3. Perform a case-insensitive search to find all facilities whose name begins with 'Tennis'
select *
from cd.facilities
where name ilike 'tennis%';

-- 4. Find telephone numbers with parentheses
select memid, telephone
from cd.members
where telephone ~ '[()]'
order by memid;

-- 5. Pad zip codes with leading zeroes
select lpad(zipcode::varchar(5), 5, '0') as zip
from cd.members
order by zip;

-- 6. Count the number of members whose surname starts with each letter of the alphabet
select substr(surname, 1, 1) as letter, count(1)
from cd.members
group by substr(surname, 1, 1)
order by substr(surname, 1, 1);

-- 7. Clean up telephone numbers
SELECT memid, regexp_replace(telephone, '[^0-9]', '', 'g') as telephone
FROM cd.members;