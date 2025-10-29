CREATE TABLE user_device_datelist_int (
    user_id TEXT,
    browser_type TEXT,
	datelist_int BIT(32),
	date DATE,
	PRIMARY KEY (user_id, browser_type, date)
);


WITH starter AS (
    SELECT udc.device_activity_datelist @> ARRAY [DATE(d.valid_date)]  AS is_active,
           EXTRACT(
               DAY FROM DATE('2023-01-31') - d.valid_date) AS days_since,
           udc.user_id,
		   udc.browser_type
    FROM user_devices_cumulated udc
    CROSS JOIN
		(SELECT generate_series('2022-12-31', '2023-01-31', INTERVAL '1 day') AS valid_date) as d
),
     bits AS (
         SELECT user_id,
				browser_type,
                SUM(CASE
                        WHEN is_active THEN POW(2, 32 - days_since)
                        ELSE 0 END)::bigint::bit(32) AS datelist_int,
                DATE('2023-01-31') as date
         FROM starter
         GROUP BY user_id, browser_type
     )
INSERT INTO user_device_datelist_int
SELECT * FROM bits;