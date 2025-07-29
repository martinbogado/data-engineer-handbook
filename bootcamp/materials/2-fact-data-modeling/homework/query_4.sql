WITH users_devices AS (
    SELECT * FROM user_devices_cumulated
    WHERE date = DATE('2023-01-31')
),
    series AS (
        SELECT *
        FROM generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') as series_date
    ),
    place_holder_ints AS (
        SELECT
            CASE WHEN
                device_activity_datelist @> ARRAY[DATE(series_date)]
            THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)
                -- Converts all of those dates into integer values that are all powers of 2
                ELSE 0
                    END as datelist_int,
            *
        FROM users_devices CROSS JOIN series
    )

SELECT
    user_id,
    browser_type,
    CAST(CAST(SUM(datelist_int) AS BIGINT) AS BIT(32)) AS datelist_int

FROM place_holder_ints
GROUP BY user_id, browser_type;