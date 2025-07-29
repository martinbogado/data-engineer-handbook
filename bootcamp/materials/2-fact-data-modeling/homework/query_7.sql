CREATE TABLE host_activity_reduced (
    host TEXT,
    month_start DATE,
    hit_array INTEGER[],
    unique_visitors INTEGER[],
    PRIMARY KEY (host, month_start)
);