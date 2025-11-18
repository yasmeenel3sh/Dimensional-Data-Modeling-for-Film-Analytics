-- select * from player_seasons where player_name='A.C. Green' limit 10 ;
-- CREATE TYPE film AS (
-- film TEXT,
-- votes INTEGER,
-- rating REAL,
-- filmid TEXT
-- );

-- CREATE TYPE quality_class AS
--      ENUM ('bad', 'average', 'good', 'star');



-- CREATE TABLE actors(
-- actor TEXT,
-- actorid TEXT,
-- films film[],
-- quality_class quality_class,
-- is_active BOOLEAN,
-- year INTEGER,
-- primary key (actorid,year)
-- );


-- with today as (
-- select actor,
-- 	   actorid,
-- 	   MIN(year) as current_year,
-- 	   array_agg(ROW(film, votes, rating, filmid)::film) AS films_this_year,
--        avg(rating) as avg_rating     
	  
-- 	from actor_films
-- 	where year=1971
-- 	 group by actor, actorid
-- ), yesterday as (
--   select * from actors
--   where year=1970
-- )
-- Insert into actors
-- select 
-- coalesce (l.actor,t.actor) as actor,
--        coalesce (l.actorid,t.actorid) as actorid,
-- 	   coalesce (l.films,
-- 	   Array[]::film[]) || coalesce(t.films_this_year, ARRAY[]::film[]) AS films,
-- 	   case when t.current_year is not null 
-- 	   then (case 
-- 	    when t.avg_rating > 8 then 'star'
-- 	    when t.avg_rating > 7 and t.avg_rating <= 8 then 'good' 
-- 	    when t.avg_rating > 6 and t.avg_rating <= 7 then 'average'
-- 		else 'bad'
-- 		end)::quality_class
-- 		ELSE l.quality_class
-- 		end as quality_class,
-- 		t.current_year is not null as is_active,
-- 		1971 as year
-- from 
-- today t full outer join yesterday l
-- on t.actorid=l.actorid;



-- select * from player_seasons where player_name='A.C. Green' limit 10 ;
CREATE TYPE film AS (
film TEXT,
votes INTEGER,
rating REAL,
filmid TEXT
);

CREATE TYPE quality_class AS
     ENUM ('bad', 'average', 'good', 'star');



CREATE TABLE actors(
actor TEXT,
actorid TEXT,
films film[],
quality_class quality_class,
is_active BOOLEAN,
year INTEGER,
primary key (actorid, year)
);


with today as (
select actor,
	   actorid,
	   MIN(year) as current_year,
	   array_agg(DISTINCT ROW(film, votes, rating, filmid)::film) AS films_this_year,
       avg(rating) as avg_rating     
	  
	from actor_films
	where year=1980
	 group by actor, actorid
), yesterday as (
  select * from actors
  where year=1979
)
-- ON CONFLICT (actorid, year) DO UPDATE
Insert into actors
select 
coalesce (l.actor,t.actor) as actor,
       coalesce (l.actorid,t.actorid) as actorid,
	   coalesce (l.films,
	   Array[]::film[]) || coalesce(t.films_this_year, ARRAY[]::film[]) AS films,
	   case when t.current_year is not null 
	   then (case 
	    when t.avg_rating is null then l.quality_class
	    when t.avg_rating >= 8 then 'star'
	    when t.avg_rating >= 7 and t.avg_rating <= 8 then 'good' 
	    when t.avg_rating >= 6 and t.avg_rating <= 7 then 'average'
		else 'bad'
		end)::quality_class
		ELSE l.quality_class
		end as quality_class,
		t.current_year is not null as is_active,
		1980 as year
from 
today t full outer join yesterday l
on t.actorid=l.actorid
ON CONFLICT (actorid, year) DO UPDATE
SET films = EXCLUDED.films,
    quality_class = EXCLUDED.quality_class,
    is_active = EXCLUDED.is_active;

-- select * from actors;

-- drop table actors_history_scd;
create table actors_history_scd(
actorid text,
actor Text,
quality_class quality_class,
is_active boolean,
start_date integer,
end_date integer,
current_year integer,
primary key (actorid,start_date)
);



Insert into actors_history_scd
with previous as(
select actorid,
actor,
quality_class,
is_active,
year,
lag(quality_class) over(partition by actorid order by year) as previous_quality_class,
lag(is_active) over(partition by actorid order by year) as previous_is_active
from actors
where year<=1979
), indicators as (
select *,
case when previous_is_active <> is_active or previous_quality_class <> quality_class then 1
else 0
end as change
from previous
), streak as (
select *,
sum(change) over( partition by actorid order by year) as streak_identifier
from indicators
) select
 actorid, 
 actor,  
 quality_class,
 is_active,
 min(year) as start_date,
 max(year) as end_date,

 -- streak_identifier,
 1979 as current_year
 from streak
 group by actorid,actor,quality_class,is_active,streak_identifier
 order by actorid, streak_identifier;
 
select * from actors_history_scd limit 20;
create type actor_scd_type as (
quality_class quality_class,
is_active boolean,
start_date integer,
end_date integer
);


-- Incremental query for actors_history_scd
Insert into actors_history_scd
with last_year_scd as(
select * from actors_history_scd
where current_year = 1979
and end_date=1979
), historical_scd as(
select actorid,
actor,
quality_class,
is_active,
start_date,
end_date
from actors_history_scd
where current_year=1979
and end_date < 1979
)
, this_year_data as(
select * from actors
where year = 1980
)
, unchanged_records as (
select t.actorid,
t.actor,
t.quality_class,
t.is_active,
l.start_date,
t.year as end_date
from this_year_data t
join last_year_scd l
on t.actorid = l.actorid
where t.year = 1980 
and t.quality_class= l.quality_class
and t.is_active=l.is_active
)
, changed_records as(
-- I need to create 2 recrods
select 
t.actorid,
t.actor,
unnest(Array[
Row(l.quality_class,
    l.is_active,
	l.start_date,
	l.end_date)::actor_scd_type,
Row(
t.quality_class,
t.is_active,
t.year, 
t.year
)::actor_scd_type]) as records

from this_year_data t
join last_year_scd l
on t.actorid = l.actorid
where t.year=1980
and (t.quality_class<> l.quality_class
or t.is_active<>l.is_active)
), flat_changed_records as(
select actorid,
actor,
(records::actor_scd_type).quality_class,
(records::actor_scd_type).is_active,
(records::actor_scd_type).start_date,
(records::actor_scd_type).end_date
from changed_records),
new_data as(
select t.actorid,
t.actor,
t.quality_class,
t.is_active,
t.year as start_date,
t.year as end_date
from this_year_data t
left join last_year_scd l
on t.actorid = l.actorid 
where l.actorid is null
), dropped_records AS (
    SELECT
        l.actorid,
        l.actor,
        l.quality_class,
        FALSE AS is_active,
        l.start_date,
        1980 AS end_date
    FROM last_year_scd l
    LEFT JOIN this_year_data t
        ON l.actorid = t.actorid
    WHERE t.actorid IS NULL
)

select *, 1980 as current_year from(
select * from historical_scd 
union all
select * from unchanged_records
union all
select * from flat_changed_records
union all
select * from new_data
UNION ALL
SELECT * FROM dropped_records


) updated
order by actorid,start_date;


-- select * from actors limit 10;
-- select * from players_scd limit(25);
