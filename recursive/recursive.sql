-- 1. Find the upward recommendation chain for member ID 27. ORDER BY descending member id
WITH RECURSIVE rec_chain(follower, recommender, firstname, surname) as (
  SELECT m1.memid as follower, m2.memid as recommender, m2.firstname, m2.surname
  FROM cd.members as m1
  JOIN cd.members as m2 on m1.recommendedby = m2.memid
  WHERE m1.memid = 27
  UNION ALL
  SELECT m1.memid as follower, m2.memid as recommender, m2.firstname, m2.surname
  FROM cd.members as m1
  JOIN cd.members as m2 on m1.recommendedby = m2.memid
  JOIN rec_chain on rec_chain.recommender = m1.memid
  )
  
SELECT recommender, firstname, surname
FROM rec_chain
ORDER BY recommender desc;

-- 2. Find the downward recommendation chain for member ID 1. Return member ID and name, and ORDER BY ascending member id
WITH RECURSIVE down_rec_chain(memid) as(
  	SELECT memid FROM cd.members WHERE recommendedby = 1
  	UNION ALL
  	SELECT m1.memid 
  	FROM cd.members as m1
  	JOIN down_rec_chain on down_rec_chain.memid = m1.recommendedby
  )
SELECT rec.memid, firstname, surname 
FROM down_rec_chain as rec
JOIN cd.members as m1 on m1.memid = rec.memid
ORDER BY rec.memid;

-- 3. Produce a CTE that can return the upward recommendation chain for any member. Get the chains for members 12 and 22.
-- Results table should have member and recommender, ordered by member ascending, recommender descending
WITH RECURSIVE rec_chain(memid, recommender) as (
  SELECT memid, recommendedby
  FROM cd.members
  UNION ALL
  SELECT rec_chain.memid, m1.recommendedby as recommender
  FROM cd.members as m1
  JOIN rec_chain on rec_chain.recommender = m1.memid
  )
  
SELECT rec_chain.memid as member, recommender, firstname, surname
FROM rec_chain
JOIN cd.members as m1 on m1.memid = rec_chain.recommender
WHERE rec_chain.memid = 12 or rec_chain.memid = 22
ORDER BY member, recommender desc;
  