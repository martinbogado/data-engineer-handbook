INSERT INTO actors
WITH yesterday AS (
    SELECT * FROM actors
    WHERE year = 2020
),
    today AS (
        SELECT
            actor AS actor_name,
            actorid,
            ARRAY_AGG(
              ROW(film, votes, rating, filmid)::films
            ) AS films,
            ROUND(AVG(rating)::numeric, 2) AS avg_rating,
            MAX(year) as year
          FROM actor_films
          WHERE year = 2021
          GROUP BY actor, actorid
    )

SELECT
    COALESCE(t.actor_name, y.actor_name) AS actor_name,
    COALESCE(t.actorid, y.actorid) AS actorid,

    CASE
        WHEN y.films IS NULL THEN t.films
        ELSE y.films || t.films
    END AS films,

    CASE
        WHEN t.avg_rating > 8 THEN 'star'
        WHEN t.avg_rating > 7 AND t.avg_rating <= 8 THEN 'good'
        WHEN t.avg_rating > 6 AND t.avg_rating <= 7 THEN 'average'
        ELSE 'bad'
    END::quality_class AS quality_class,

    CASE
        WHEN t.actorid IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active,

    COALESCE(t.year, y.year + 1) AS year

FROM today t FULL OUTER JOIN yesterday y
ON t.actorid = y.actorid;