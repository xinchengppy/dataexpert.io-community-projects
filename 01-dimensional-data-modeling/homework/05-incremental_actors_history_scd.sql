CREATE TYPE scd_type AS (
		quality_class quality_class,
		start_year INTEGER,
		end_year INTEGER,
        is_active boolean
		);



WITH params AS (
  SELECT 2001::int AS prev_year, 2002::int AS this_year
),
    last_year_scd AS (
        SELECT * FROM actors_history_scd
        WHERE current_year = (SELECT prev_year FROM params)
        AND end_year = (SELECT prev_year FROM params)
),
    historical_scd AS (
    SELECT
        actorid,
        actor,
        quality_class,
        start_year,
        end_year,
        is_active
    FROM actors_history_scd
    WHERE current_year = (SELECT prev_year FROM params)
    AND end_year < (SELECT prev_year FROM params)
),
	this_year AS (
	SELECT *
    FROM actors
    WHERE current_year = (SELECT this_year FROM params)
),
	unchanged_records AS (
	SELECT
        t.actorid,
        t.actor,
        t.quality_class,
        l.start_year,
        t.current_year as end_year,
        t.is_active
    FROM this_year t
    JOIN last_year_scd l USING (actorid)
    WHERE l.quality_class = t.quality_class
      AND l.is_active = t.is_active
),
	changed_records AS (
    SELECT 
        t.actorid,
        t.actor,
        UNNEST(ARRAY[
            ROW(
                l.quality_class,
                l.start_year,
                (SELECT prev_year FROM params),
                l.is_active
            )::scd_type,
            ROW(
                t.quality_class,
                t.current_year,
                t.current_year,
                t.is_active
            )::scd_type        
        ]) as records
    FROM this_year t
    JOIN last_year_scd l USING(actorid)
    WHERE (t.quality_class <> l.quality_class OR t.is_active <> l.is_active)
),
	unnested_changed_records AS (
        SELECT 
            actorid,
            actor,
            (records::scd_type).quality_class,
            (records::scd_type).start_year,
            (records::scd_type).end_year,
            (records::scd_type).is_active
        FROM changed_records
), 
    new_records AS (
        SELECT 
            t.actorid,
            t.actor,
            t.quality_class,
            t.current_year as start_year,
            t.current_year as end_year,
            t.is_active
        FROM this_year t
        LEFT JOIN last_year_scd l
        ON t.actorid = l.actorid
        WHERE l.actorid IS NULL
)

INSERT INTO actors_history_scd
SELECT *, (SELECT this_year FROM params) AS current_year
FROM (
    SELECT * FROM historical_scd
    UNION ALL
    SELECT * FROM unchanged_records
    UNION ALL
    SELECT * FROM unnested_changed_records
    UNION ALL
    SELECT * FROM new_records
) a;