-- 1. Add into the facilities table: 
-- facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800
INSERT INTO cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);

-- 2. Insert the following multiple entries in one command:
-- facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800
-- facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80
INSERT INTO cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800),
	   (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);

-- 3. Insert the same 'Spa' entry but this time automatically +1 from the previous facid
INSERT INTO cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES ((select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800);

-- 4. Update initial outlay to 10000 for the second tennis court entry
UPDATE cd.facilities
SET initialoutlay = 10000 WHERE name = 'Tennis Court 2';

-- 5. Update the costs to be 6 for members, and 30 for guests for all the tenis courts
UPDATE cd.facilities
SET membercost = 6, guestcost = 30 WHERE name like 'Tennis Court%';

-- 6. Alter the price of the second tennis court so that it costs 10% more than the first one
UPDATE cd.facilities
SET membercost = (select membercost::decimal + (membercost*0.1) from cd.facilities where name = 'Tennis Court 1'),
	guestcost = (select guestcost::decimal + (guestcost*0.1) from cd.facilities where name = 'Tennis Court 1')
WHERE name = 'Tennis Court 2';

-- 7. Delete all records from the table bookings
DELETE FROM cd.bookings;

-- 8. Delete member with id 37
DELETE FROM cd.members WHERE memid = 37;

-- 9. Delete all members who have never made a booking
DELETE FROM cd.members 
WHERE memid not in (SELECT memid FROM cd.bookings);
