WITH last_year AS (
	SELECT * FROM actors
	WHERE current_year = 2001
), this_year AS (
	SELECT 
		actorid,
		actor,
		ARRAY_AGG(
			ROW(year, film, votes, rating, filmid)::film_review
			ORDER BY year, filmid
		) AS films,
		AVG(rating) AS rating,
		year
	FROM actor_films
	WHERE year = 2002
	GROUP BY actorid, actor, year
)

INSERT INTO actors
SELECT
	COALESCE(ly.actorid, ty.actorid) AS actorid,
	COALESCE(ty.actor, ly.actor) AS actor,
	COALESCE(ly.films, ARRAY[]::film_review[]) ||
		COALESCE(ty.films, ARRAY[]::film_review[])
	AS films,
	CASE 
        WHEN ty.year IS NOT NULL THEN
            CASE
                WHEN ty.rating IS NULL THEN COALESCE(ly.quality_class, 'bad') 
                WHEN ty.rating > 8 THEN 'star'
                WHEN ty.rating > 7 AND ty.rating <= 8 THEN 'good'
                WHEN ty.rating > 6 AND ty.rating <= 7 THEN 'average'
                ELSE 'bad'
            END::quality_class
        ELSE
            ly.quality_class
    END AS quality_class,
	ty.year IS NOT NULL AS is_active,
	COALESCE(ly.current_year + 1, ty.year) as current_year
FROM last_year ly
FULL OUTER JOIN this_year ty ON ly.actorid = ty.actorid;