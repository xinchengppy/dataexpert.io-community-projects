--Q1:  What is the average number of web events of a session from a user on Tech Creator?
SELECT 
    ip, 
    ROUND(AVG(num_events), 2) AS avg_num_events
FROM processed_events_sessionized
WHERE host LIKE '%.techcreator.io'
GROUP BY ip
ORDER BY avg_num_events DESC;

-- Sample Output:
--       ip        | avg_num_events 
-- -----------------+----------------
--  172.220.104.13  |           9.00
--  135.129.124.213 |           1.00
--  43.173.179.220  |           1.00
--  43.173.180.180  |           1.00
--  43.173.181.202  |           1.00
--  66.249.70.67    |           1.00


-- Q2.: Compare results between different hosts (zachwilson.techcreator.io, zachwilson.tech, lulu.techcreator.io)
SELECT 
    host,
    COUNT(*) AS total_sessions,
    ROUND(AVG(num_events), 2) AS avg_num_events
FROM processed_events_sessionized
WHERE host IN (
    'zachwilson.techcreator.io',
    'zachwilson.tech',
    'lulu.techcreator.io'
)
GROUP BY host;

-- Sample Output:
--  host | total_sessions | avg_num_events 
-- ------+----------------+----------------

