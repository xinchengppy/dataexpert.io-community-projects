-- Query 6: What is the most games a team has won in a 90 game stretch?
-- What is the most games a team has won in a 90 game stretch?
WITH team_games AS (
      SELECT team_id, game_id, game_date_est, MAX(team_won) AS team_won
      FROM staging_table
      GROUP BY team_id, game_id, game_date_est
    ),
    rw AS (
      SELECT
        team_id,
        game_date_est,
        game_id,
        SUM(team_won) OVER (
          PARTITION BY team_id
          ORDER BY game_date_est, game_id
          ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS wins_in_90
      FROM team_games
    )
    SELECT team_id, MAX(wins_in_90) AS max_wins_in_90
    FROM rw
    GROUP BY team_id
    ORDER BY max_wins_in_90 DESC;

-- Query 7: How many games in a row did LeBron James score over 10 points a game?
-- What is the most games a team has won in a 90 game stretch?
WITH lebron AS (
    SELECT
        game_date_est,
        game_id,
		pts,
        CASE WHEN pts > 10 THEN 1 ELSE 0 END AS scored_over_10
    FROM staging_table
    WHERE player_name = 'LeBron James'
),
	marked AS (
	    SELECT 
			*,
		   CASE
			   WHEN scored_over_10 = 1
					AND LAG(scored_over_10) OVER (ORDER BY game_date_est, game_id) = 0 THEN 1
			   WHEN scored_over_10 = 1
					AND LAG(scored_over_10) OVER (ORDER BY game_date_est, game_id) IS NULL THEN 1
			   ELSE 0
		   END AS streak_start
	    FROM lebron
),
	grouped AS (
	    SELECT *,
	           SUM(streak_start) OVER (ORDER BY game_date_est, game_id) AS streak_group
	    FROM marked
	)
SELECT MAX(streak_length) AS longest_streak
FROM (
    SELECT streak_group, COUNT(*) AS streak_length
    FROM grouped
    WHERE scored_over_10 = 1
    GROUP BY streak_group
) s;
