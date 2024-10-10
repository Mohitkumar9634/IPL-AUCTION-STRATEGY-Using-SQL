select player, total_runs, balls_faced, round(cast(strike_rate as numeric),3)
as rounded_strike_rate
from (
select batsman as player,
sum(batsman_runs) as total_runs,
count(ball) as balls_faced,
(cast(sum(batsman_runs) as float) / count(ball))*100 as strike_rate
from Deliveries
where extras_type != 'wides'
group by batsman
) as player_stats
where balls_faced >= 500
order by strike_rate desc
limit 10;


with PlayerStats as (
select batsman as player,
sum(batsman_runs) as total_runs,
count(distinct id) as total_matches,
count(is_wicket) filter (where is_wicket = 1) as times_dismissed
from Deliveries
group BY batsman
having count(distinct id) > 28
and count(is_wicket) filter (where is_wicket = 1) > 0
)
select player, total_runs, total_matches, times_dismissed,
round(cast(cast(total_runs as float) / times_dismissed as numeric),2)
as average
from PlayerStats
order by average desc
limit 10;



select player,total_runs, boundary_runs,ROUND(cast(boundary_percentage as NUMERIC), 2) as rouned_boundary_percentage
from (
select batsman as player,
sum(batsman_runs) as total_runs,
count(distinct id) as total_matches,
sum(case when batsman_runs = 4 or batsman_runs = 6 then
batsman_runs else 0 end) as boundary_runs,
cast(sum(case when batsman_runs = 4 or batsman_runs = 6 then batsman_runs else 0 end) as float) / nullif(sum(batsman_runs),0)*100 as boundary_percentage
from Deliveries
group by batsman
having count(distinct id)>28
) as player_stats
where boundary_percentage>0
order by boundary_percentage desc limit 10;



select * from matches
select batsman,cast(boundary_percentage as decimal(3,1)),DENSE_RANK() OVER (ORDER BY boundary_percentage DESC) from( select*, (cast(boundary_runs as float)/total_runs*100) as boundary_percentage
from (SELECT batsman,total_runs,SUM(batsman_runs) AS boundary_runs,
COUNT(batsman_runs) AS boundaries_total,count(distinct extract(year from date)) as played_years
from (SELECT a.batsman,a.batsman_runs,SUM(a.batsman_runs) OVER (PARTITION BY a.batsman) as total_runs,
b.date FROM Deliveries as a full join Matches as b
on a.id=b.id) as c WHERE batsman_runs=4 or batsman_runs=6 group by total_runs, batsman order by boundaries_total DESC
) as d where played_years>2 order by boundary_percentage desc) as e limit 10;


select player, total_runs, balls_faced, round(cast(strike_rate as numeric),3) as rounded_strike_rate,
dense_rank() over (order by strike_rate desc) as players_rank 
from (
select batsman as player,
sum(batsman_runs) as total_runs,
count(ball) as balls_faced,
(cast(sum(batsman_runs) as float) / count(ball))*100 as strike_rate
from Deliveries
where extras_type != 'wides'
group by batsman
) as player_stats
where balls_faced >= 500
order by strike_rate desc
limit 10;


select player, total_runs, total_matches,player_average,played_years,dismissed_no, DENSE_RANK() OVER (ORDER BY player_average DESC) 
from (
select batsman as player,
sum(batsman_runs) as total_runs,
count(distinct id) as total_matches
FROM ( SELECT *,cast(AVG(batsman_runs/dismissed_no) as decimal(3,1))AS player_average
FROM(select batsman,sum(batsman_runs) as total_runs,
sum(is_wicket) as dismissed_no,count(distinct extract(year from date)) as played_years
from (SELECT a.batsman, a.batsman_runs, a.is_wicket, b.date
FROM Deliveries as a full join matches as b
on a.id=b.id) AS c GROUP BY player
) as d group by player,total_runs, dismissed_no,
played_years having dismissed_no>=1 and played_years>2 ORDER BY player_average DESC LIMIT 10;

﻿

SELECT batsman as player,player_average,total_runs,dismissed_no, DENSE_RANK() OVER (ORDER BY player_average DESC)
FROM ( SELECT *,cast(AVG(total_runs/dismissed_no) as decimal(3,1))AS player_average
FROM(select batsman,sum(batsman_runs) as total_runs,
sum(is_wicket) as dismissed_no,count(distinct extract(year from date)) as played_years
from (SELECT a.batsman, a.batsman_runs, a.is_wicket, b.date
FROM Deliveries as a full join matches as b
on a.id=b.id) AS c GROUP BY batsman
) as d group by batsman,total_runs, dismissed_no,
played_years having dismissed_no>=1 and played_years>2 ORDER BY player_average DESC) as e LIMIT 10;



SELECT
    player,
    total_runs,
    boundary_runs,
    ROUND(CAST(boundary_percentage AS NUMERIC), 2) AS rounded_boundary_percentage
FROM (
    SELECT
        batsman AS player,
        SUM(batsman_runs) AS total_runs,
        COUNT(DISTINCT id) AS total_matches,
        SUM(CASE WHEN batsman_runs = 4 OR batsman_runs = 6 THEN batsman_runs ELSE 0 END) AS boundary_runs,
        CAST(SUM(CASE WHEN batsman_runs = 4 OR batsman_runs = 6 THEN batsman_runs ELSE 0 END) AS FLOAT) / NULLIF(SUM(batsman_runs),0) * 100 AS boundary_percentage
    FROM
        Deliveries
    GROUP BY
        batsman
    HAVING
        COUNT(DISTINCT id) > 28
) AS player_stats
WHERE
    boundary_percentage>0
ORDER BY
    boundary_percentage DESC
LIMIT 10;

select player, total_runs, balls_faced, round(cast(strike_rate as numeric),3) as rounded_strike_rate from (select batsman as player,sum(batsman_runs) as total_runs,count(ball) as balls_faced,(cast(sum(batsman_runs) as float) / count(ball))*100 as strike_rate from Deliveries where extras_type != 'wides'group by batsman) as player_stats where balls_faced >= 500 order by strike_rate desc limit 10;

﻿

select bowler,
sum(total_runs) AS total_runs_conceded,
sum(case when extras_type != 'wides' and extras_type != 'noballs' then 1 else 0 end) as balls_bowled,
round(cast(cast(sum(total_runs) as float) / (sum(case when extras_type != 'wides' and extras_type != 'noballs' then 1 else 0 end)/6) as numeric),3) as economy from Deliveries
group by bowler
having sum(case when extras_type != 'wides' and extras_type != 'noballs' then 1 else 0 end) >= 500
order by economy asc
limit 10;

﻿

with BowlerStats as (
select bowler,
sum(case when is_wicket = 1 then 1 else 0 end) as wickets,
sum(case when extras_type != 'wides' and extras_type != 'noballs' then ball else 0
end) AS valid_balls
from Deliveries
group by bowler
having sum(case when extras_type != 'wides' and extras_type != 'noballs' then ball else 0 end) >= 500
)
select bowler,
valid_balls,
wickets,
round(cast((cast(valid_balls as float) / wickets) as numeric),3) as strike_rate
from BowlerStats
where wickets > 0
order by strike_rate asc
LIMIT 10;

with BowlerStats as (select bowler,sum(case when is_wicket = 1 then 1 else 0 end) as wickets,sum(case when extras_type != 'wides' and extras_type != 'noballs' then ball else 0 end) AS valid_balls from Deliveries group by bowler having sum(case when extras_type != 'wides' and extras_type != 'noballs' then ball else 0 end) >= 500)select bowler,valid_balls,wickets,round(cast((cast(valid_balls as float) / wickets) as numeric),3) as strike_rate from BowlerStats where wickets > 0 order by strike_rate asc limit 10;

﻿

SELECT batsman AS All_rounders,
round((SUM (batsman_runs)*1.0/ COUNT (ball)*100), 2) AS bats_strike_rate, bowl_strike_rate
FROM deliveries AS d
INNER JOIN
(SELECT bowler, COUNT (bowler) AS balls,
SUM (is_wicket) AS total_wicket,
round(((COUNT (bowler)*1.0/ SUM (is_wicket))), 2) AS bowl_strike_rate
FROM deliveries
GROUP BY bowler
HAVING COUNT (bowler)>300
ORDER BY bowl_strike_rate ASC) AS b
ON d.batsman = b.bowler
WHERE NOT extras_type= 'wides'
GROUP BY batsman, bowl_strike_rate
HAVING COUNT (ball)>=500
ORDER BY bats_strike_rate DESC, bowl_strike_rate DESC
LIMIT 10;


select batsman as All_rounders,round((sum (batsman_runs)*1.0/ count (ball)*100), 2) as bats_strike_rate, bowl_strike_rate from deliveries as d inner join(select bowler, count (bowler) as balls,sum (is_wicket) as total_wicket,round(((count (bowler)*1.0/ sum (is_wicket))), 2) as bowl_strike_rate from deliveries group by bowler having count (bowler)>300 order by bowl_strike_rate asc) as b on d.batsman = b.bowler where not extras_type = 'wides' group by batsman, bowl_strike_rate having count (ball)>=500 order by bats_strike_rate desc, bowl_strike_rate desc limit 10;


create table bats_sr as ( select batsman,cast(player_total_runs as decimal)/balls_faced *100 as batting_sr from SELECT batsman,sum (batsman_runs) AS player_total_runs,
count(ball) AS balls_faced FROM ipl_player_data WHERE NOT extras_type ='wides'
GROUP BY batsman having count(ball)>500) as a )
create table bowl_sr as (select bowler,cast(total_balls as decimal)/wicket_taken as bowling_sr from(
select bowler,total_balls,sum(is_wicket) as wicket_taken from (
select bowler,is_wicket,count(ball) over (partition by bowler) as total_balls from ipl_player_data ) as a where is_wicket>0 and total_balls>300
group by bowler,total_balls) as a )
select a.batsman as allrounder,cast(a.batting_sr as decimal(4,1)),cast(b.bowling_sr as decimal(3,1))
from bats_sr as a inner join bowl_sr as b on a.batsman-b.bowler where batting_sr>150 and bowling_sr<21


select count(distinct city) as city_count
from matches;


﻿

create table deliveries_v02 as select *,
case
when total_runs >= 4 then 'boundary'
when total_runs = 0 then 'dot'
else 'other'
end as ball_result
from Deliveries;

select * from deliveries_v02

﻿

select ball_result, count(*) as total_count
from deliveries_v02
where ball_result in ('boundary', 'dot') group by ball_result;


﻿

select
batting_team,
count(*) as total_boundaries
from
deliveries_v02
where
ball_result = 'boundary'
group by
batting_team
order by
total_boundaries desc;


﻿

select
bowling_team,
count(*) as total_dot_balls
from
deliveries_v02
where
ball_result = 'dot'
group by
bowling_team
order by
total_dot_balls desc;

﻿

select
dismissal_kind,
count(*) as total_dismissals
from
deliveries_v02
where
dismissal_kind <> 'NA'
group by
dismissal_kind;

﻿

select
bowler,
sum(extra_runs) as total_extra_runs
from
deliveries
group by
bowler
order by
total_extra_runs desc
limit 5;

﻿

create table deliveries_v03 as
select
dv2.*,
m.venue,
m.date as match_date
from
deliveries_v02 dv2
join 
matches m on
dv2.id = m.id;

select * from deliveries_v03


﻿

select
venue,
sum(total_runs) as total_runs_scored
from
deliveries_v03
group by
venue
order by
total_runs_scored desc;

select * from matches
select * from deliveries


select
extract(year from match_date) as year,
sum(total_runs) as total_runs_scored
from
deliveries_v03
where
venue = 'Eden Gardens'
group by
year
order by
total_runs_scored desc;