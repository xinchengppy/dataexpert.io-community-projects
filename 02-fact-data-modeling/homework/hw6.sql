DO $$
DECLARE loop_date DATE := DATE '2023-01-01';
BEGIN
    WHILE loop_date <= DATE '2023-01-31' LOOP
        INSERT INTO hosts_cumulated
        WITH yesterday AS (
            SELECT * 
            FROM hosts_cumulated
            WHERE date = loop_date - INTERVAL '1 day'
        ),
        today AS (
            SELECT 
                CAST(host AS TEXT) AS host,
                DATE(CAST(event_time AS TIMESTAMP)) AS host_activity_date
            FROM events
            WHERE DATE(CAST(event_time AS TIMESTAMP)) = loop_date AND host IS NOT NULL
            GROUP BY CAST(host AS TEXT), DATE(CAST(event_time AS TIMESTAMP))
        )
        SELECT
            COALESCE(t.host, y.host) AS host,
            CASE
                WHEN y.host_activity_datelist IS NULL THEN ARRAY[t.host_activity_date]
                WHEN t.host_activity_date IS NULL THEN y.host_activity_datelist
                ELSE ARRAY[t.host_activity_date] || y.host_activity_datelist
            END AS host_activity_datelist,
            COALESCE(t.host_activity_date, (y.date + INTERVAL '1 DAY')::date) AS date
        FROM today t
        FULL OUTER JOIN yesterday y
        ON t.host = y.host
        ON CONFLICT (host, date) DO NOTHING;
        
        -- increment date for next loop
        loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END $$;