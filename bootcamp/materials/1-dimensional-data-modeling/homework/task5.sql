CREATE TYPE scd_type_actors AS (
    quality_class quality_class,
    is_active BOOLEAN,
    start_date INTEGER,
    end_date INTEGER
                               );

WITH last_year_scd_actors AS (
    SELECT *
    FROM actors_history_scd
    WHERE year = 2021
    AND end_date = 2021
),
    historical_scd AS (
        SELECT actor_name, actorid, quality_class, is_active, start_date, end_date
        FROM actors_history_scd
        WHERE year = 2021
        AND end_date < 2021
    ),
    this_year_data AS (
        SELECT * FROM actors
                 WHERE year = 2022
    ),
    unchanged_records AS (
        SELECT
            ts.actor_name,
            ts.actorid,
            ts.quality_class,
            ts.is_active,
            ls.start_date,
            ts.year AS end_date
        FROM this_year_data ts
        JOIN last_year_scd_actors ls ON ls.actorid = ts.actorid
        WHERE ts.quality_class = ls.quality_class
        AND ts.is_active = ls.is_active
    ),
    changed_records AS (
        SELECT
            ts.actor_name,
            ts.actorid,
            UNNEST(ARRAY[
                ROW(
                    ls.quality_class,
                    ls.is_active,
                    ls.start_date,
                    ls.end_date
                    )::scd_type_actors,
                ROW(
                    ts.quality_class,
                    ts.is_active,
                    ts.year,
                    ts.year
                    )::scd_type_actors
                ]) AS records
        FROM this_year_data ts
        LEFT JOIN last_year_scd_actors ls ON ls.actorid = ts.actorid
        WHERE ts.quality_class <> ls.quality_class
        OR ts.is_active <> ls.is_active
    ),
    unnested_changed_records AS (
        SELECT
            actor_name,
            actorid,
            (records::scd_type_actors).quality_class,
            (records::scd_type_actors).is_active,
            (records::scd_type_actors).start_date,
            (records::scd_type_actors).end_date
        FROM changed_records
    ),
    new_records AS (
        SELECT
            ts.actor_name,
            ts.actorid,
            ts.quality_class,
            ts.is_active,
            ts.year AS start_date,
            ts.year AS end_date
        FROM this_year_data ts
        LEFT JOIN last_year_scd_actors ls ON ts.actorid = ls.actorid
        WHERE ls.actorid IS NULL
    )

SELECT * FROM historical_scd

UNION ALL

SELECT * FROM unchanged_records

UNION ALL

SELECT * FROM unnested_changed_records

UNION ALL

SELECT * FROM new_records;