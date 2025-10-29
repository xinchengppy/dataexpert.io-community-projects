DO $$
DECLARE loop_date DATE := DATE '2023-01-01';
BEGIN
    WHILE loop_date <= DATE '2023-01-31' LOOP
		INSERT INTO host_activity_reduced
		WITH yesterday AS (
		    SELECT *
		    FROM host_activity_reduced
		    WHERE month = DATE_TRUNC('month', loop_date)
		),
	     today AS (
	         SELECT	
			 	host,
	            DATE(CAST(event_time AS TIMESTAMP)) AS date,
	            COUNT(*) AS num_hits,
				COUNT(DISTINCT user_id) AS num_distinct_users
	         FROM events
	         WHERE DATE(CAST(event_time AS TIMESTAMP)) = loop_date
	         AND user_id IS NOT NULL
	         GROUP BY host, DATE(CAST(event_time AS TIMESTAMP))	
		)
		SELECT
			COALESCE(y.month, DATE_TRUNC('month', t.date)) AS month,
			COALESCE(y.host, t.host) AS host,
			CASE 
				WHEN y.hit_array IS NOT NULL THEN 
				y.hit_array || ARRAY[COALESCE(t.num_hits, 0)] 
				WHEN y.hit_array IS NULL THEN
				ARRAY_FILL(0, ARRAY[COALESCE (t.date - DATE(DATE_TRUNC('month', t.date)), 0)]) 
					|| ARRAY[COALESCE(t.num_hits, 0)]
			END AS hit_array,
			CASE 
				WHEN y.unique_visitors_array IS NOT NULL THEN 
				y.unique_visitors_array || ARRAY[COALESCE(t.num_distinct_users, 0)] 
				WHEN y.unique_visitors_array IS NULL THEN
				ARRAY_FILL(0, ARRAY[COALESCE (t.date - DATE(DATE_TRUNC('month', t.date)), 0)]) 
					|| ARRAY[COALESCE(t.num_distinct_users, 0)]
			END AS unique_visitors_array
		FROM today t
		FULL OUTER JOIN yesterday y
		ON t.host = y.host
		ON CONFLICT (month, host)
        DO UPDATE SET
            hit_array = EXCLUDED.hit_array,
            unique_visitors_array = EXCLUDED.unique_visitors_array;
		loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END $$;
