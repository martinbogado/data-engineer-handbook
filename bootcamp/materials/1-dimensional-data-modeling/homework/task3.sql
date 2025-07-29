CREATE TABLE actors_history_scd (
    actor_name TEXT,
    actorid TEXT,
    quality_class quality_class,
    is_active BOOLEAN,
    start_date INTEGER,
    end_date INTEGER,
    year INTEGER,
    PRIMARY KEY (actorid, start_date)
);
