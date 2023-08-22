-- 1. Find the upward recommendation chain for member ID 27. Order by descending member id
WITH RECURSIVE rec_chain(follower, recommender, firstname, surname) as (
  select m1.memid as follower, m2.memid as recommender, m2.firstname, m2.surname
  from cd.members as m1
  join cd.members as m2 on m1.recommendedby = m2.memid
  where m1.memid = 27
  UNION ALL
  select m1.memid as follower, m2.memid as recommender, m2.firstname, m2.surname
  from cd.members as m1
  join cd.members as m2 on m1.recommendedby = m2.memid
  join rec_chain on rec_chain.recommender = m1.memid
  )
  
select recommender, firstname, surname
from rec_chain
order by recommender desc;

-- 2. Find the downward recommendation chain for member ID 1. Return member ID and name, and order by ascending member id
WITH RECURSIVE down_rec_chain(memid) as(
  	select memid from cd.members where recommendedby = 1
  	UNION ALL
  	select m1.memid 
  	from cd.members as m1
  	join down_rec_chain on down_rec_chain.memid = m1.recommendedby
  )
select rec.memid, firstname, surname 
from down_rec_chain as rec
join cd.members as m1 on m1.memid = rec.memid
order by rec.memid;

-- 3. Produce a CTE that can return the upward recommendation chain for any member. Get the chains for members 12 and 22.
-- Results table should have member and recommender, ordered by member ascending, recommender descending
WITH RECURSIVE rec_chain(memid, recommender) as (
  select memid, recommendedby
  from cd.members
  UNION ALL
  select rec_chain.memid, m1.recommendedby as recommender
  from cd.members as m1
  join rec_chain on rec_chain.recommender = m1.memid
  )
  
select rec_chain.memid as member, recommender, firstname, surname
from rec_chain
join cd.members as m1 on m1.memid = rec_chain.recommender
where rec_chain.memid = 12 or rec_chain.memid = 22
order by member, recommender desc;
  