CREATE OR REPLACE TABLE staging_table AS
WITH deduped AS (
	SELECT
		g.game_date_est,
		g.season,
		g.home_team_id,
		g.visitor_team_id, 
		g.home_team_wins,
		gd.game_id,
		gd.player_id,
		gd.player_name,
		gd.team_id,
		gd.fgm,
		gd.fg3m,
		gd.ftm,
		ROW_NUMBER() 
			OVER(PARTITION BY gd.game_id, gd.team_id, gd.player_id 
					ORDER BY g.game_date_est) AS row_num
	    FROM game_details gd 
		JOIN games g USING (game_id)
)
SELECT
	game_date_est,
	season,
	game_id,
	team_id,
	player_id,
	player_name,
	(2 * (COALESCE(fgm, 0) - COALESCE(fg3m, 0)) + 3 * COALESCE(fg3m, 0) + COALESCE(ftm, 0)) AS pts,
	CASE
		WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
		WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1
		ELSE 0
	END AS team_won
FROM deduped
WHERE row_num = 1;

-- Query 2: uses GROUPING SETS to do efficient aggregations of game_details data
SELECT
	CASE 
		WHEN GROUPING(player_id) = 0 AND GROUPING(team_id) = 0 THEN 'Player-Team'
		WHEN GROUPING(player_id) = 0 AND GROUPING(season) = 0 THEN 'Player-Season'
		WHEN GROUPING(team_id) = 0 AND GROUPING(player_id) = 1 THEN 'Team'
  	END AS grouping_level,
	player_id,
	player_name,
	team_id,
	season,
	SUM(pts) AS total_pts,
	COUNT(DISTINCT CASE WHEN team_won = 1 THEN game_id END) AS total_win_counts
FROM staging_table
GROUP BY GROUPING SETS(
	(player_id, player_name, team_id),
	(player_id, player_name, season),
    (team_id)
)
ORDER BY grouping_level, total_pts DESC, total_win_counts DESC;

-- Query 3:
-- who scored the most points playing for one team?
WITH player_team_totals AS (
	SELECT
		player_id,
		player_name,
		team_id,
		SUM(pts) AS total_pts,
		RANK() OVER (ORDER BY SUM(pts) DESC) AS rnk
	FROM staging_table
	WHERE pts IS NOT NULL
	GROUP BY player_id, player_name, team_id
)
SELECT player_id, player_name, team_id, total_pts
FROM player_team_totals
WHERE rnk = 1;

-- Query 4:
-- who scored the most points in one season?
WITH season_totals AS (
	SELECT
		player_id,
		player_name,
		season,
		SUM(pts) AS total_pts,
		RANK() OVER (ORDER BY SUM(pts) DESC) AS rnk
	FROM staging_table
	WHERE pts IS NOT NULL
	GROUP BY player_id, player_name, season
)
SELECT player_id, player_name, season, total_pts
FROM season_totals
WHERE rnk = 1;

-- Query 5:
-- which team has won the most games?
WITH team_totals AS (
    SELECT
        team_id,
        COUNT(DISTINCT CASE WHEN team_won = 1 THEN game_id END) AS total_win_counts,
        RANK() OVER (ORDER BY COUNT(DISTINCT CASE WHEN team_won = 1 THEN game_id END) DESC) AS rnk
    FROM staging_table
    GROUP BY team_id
)
SELECT team_id, total_win_counts
FROM team_totals
WHERE rnk = 1;