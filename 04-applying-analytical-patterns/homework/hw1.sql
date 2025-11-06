-- Query 1: state change tracking for players
SELECT
    player_name,
    current_season,
    is_active,
    CASE
        WHEN prev_is_active IS NULL AND is_active THEN 'New'
        WHEN prev_is_active AND NOT is_active THEN 'Retired'
        WHEN prev_is_active AND is_active THEN 'Continued Playing'
        WHEN NOT prev_is_active AND is_active THEN 'Returned from Retirement'
        WHEN (NOT prev_is_active AND NOT is_active) OR (prev_is_active IS NULL AND NOT is_active) THEN 'Stayed Retired'
        ELSE 'Unknown'
    END AS season_active_state
FROM (
    SELECT
        player_name,
        current_season,
        is_active,
        LAG(is_active) OVER (PARTITION BY player_name ORDER BY current_season) AS prev_is_active
    FROM players
) sub;