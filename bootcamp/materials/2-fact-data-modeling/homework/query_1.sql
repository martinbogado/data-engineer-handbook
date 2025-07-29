SELECT
    game_id, team_id, player_id, COUNT(1)
FROM game_details
GROUP BY 1, 2, 3
HAVING COUNT(1) > 1;

WITH deduped AS (
    SELECT
        *,
        row_number() over (PARTITION BY game_id, team_id, player_id) AS row_num
    FROM game_details
)
SELECT * FROM deduped
WHERE row_num = 1;