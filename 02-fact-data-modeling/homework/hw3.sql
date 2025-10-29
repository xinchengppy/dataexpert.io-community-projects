-- Create temporary table to hold deduplicated device records
CREATE TEMP TABLE device_deduped AS
SELECT
    CAST(device_id AS TEXT) AS device_id,
    browser_type,
    browser_version_major,
    browser_version_minor,
    browser_version_patch,
    device_type,
    device_version_major,
    device_version_minor,
    device_version_patch,
    os_type,
    os_version_major,
    os_version_minor,
    os_version_patch
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
             PARTITION BY device_id, browser_type, device_type, os_type
             ORDER BY device_id, browser_type, device_type, os_type
           ) AS row_num
    FROM devices
) d
WHERE row_num = 1;


DO $$
DECLARE loop_date DATE := DATE '2023-01-01';
BEGIN
    WHILE loop_date <= DATE '2023-01-31' LOOP
        INSERT INTO user_devices_cumulated
        WITH yesterday AS (
                SELECT * FROM user_devices_cumulated
                WHERE date = loop_date - INTERVAL '1 DAY'
        ),
            today AS (
                SELECT 
                    CAST(e.user_id AS TEXT) AS user_id,
                    dd.browser_type,
                    DATE(CAST(event_time AS TIMESTAMP)) AS device_activity_date
                FROM events e JOIN device_deduped dd
                ON CAST(e.device_id as TEXT) = dd.device_id
                WHERE DATE(CAST(event_time AS TIMESTAMP)) = loop_date
                AND e.user_id IS NOT NULL
                GROUP BY e.user_id, dd.browser_type, DATE(CAST(event_time AS TIMESTAMP))
        )
        SELECT
            COALESCE(t.user_id, y.user_id) AS user_id,
            COALESCE(t.browser_type, y.browser_type) AS browser_type,
            CASE
                WHEN y.device_activity_datelist IS NULL THEN ARRAY[t.device_activity_date]
                WHEN t.device_activity_date IS NULL THEN y.device_activity_datelist
                ELSE ARRAY[t.device_activity_date] || y.device_activity_datelist
            END AS device_activity_datelist,
            COALESCE(t.device_activity_date, (y.date + INTERVAL '1 DAY')::date) AS date
        FROM today t 
        FULL OUTER JOIN yesterday y
        ON CAST(t.user_id AS TEXT) = y.user_id 
        AND t.browser_type = y.browser_type
        ON CONFLICT (user_id, browser_type, date) DO NOTHING;
        loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END $$;
