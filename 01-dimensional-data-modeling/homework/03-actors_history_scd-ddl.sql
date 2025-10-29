CREATE TABLE actors_history_scd (    
    actorid text NOT NULL,
	actor text NOT NULL,
    quality_class quality_class NOT NULL,
    start_year integer NOT NULL,
    end_year integer,
    is_active boolean NOT NULL,
    current_year integer,
    PRIMARY KEY (actorid,start_year, current_year)
);