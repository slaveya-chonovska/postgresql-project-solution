-- 1. Output the names of all members, formatted as 'Surname, Firstname'
SELECT CONCAT(surname,', ', firstname)
FROM cd.members;

-- 2. Find all facilities whose name begins with 'Tennis'
SELECT *
FROM cd.facilities
WHERE name like 'Tennis%';

-- 3. Perform a case-insensitive search to find all facilities whose name begins with 'Tennis'
SELECT *
FROM cd.facilities
WHERE name ilike 'tennis%';

-- 4. Find telephone numbers with parentheses
SELECT memid, telephone
FROM cd.members
WHERE telephone ~ '[()]'
ORDER BY memid;

-- 5. Pad zip codes with leading zeroes
SELECT lpad(zipcode::varchar(5), 5, '0') as zip
FROM cd.members
ORDER BY zip;

-- 6. Count the number of members whose surname starts with each letter of the alphabet
SELECT substr(surname, 1, 1) as letter, count(1)
FROM cd.members
GROUP BY substr(surname, 1, 1)
ORDER BY substr(surname, 1, 1);

-- 7. Clean up telephone numbers
SELECT memid, regexp_replace(telephone, '[^0-9]', '', 'g') as telephone
FROM cd.members;