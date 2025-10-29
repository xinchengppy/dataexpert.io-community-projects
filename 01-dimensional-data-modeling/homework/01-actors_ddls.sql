CREATE TYPE film_review AS (
						year INTEGER,
						film TEXT,
						votes INTEGER,
						rating REAL,
						filmid TEXT
						);

CREATE TYPE quality_class AS
	ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE IF NOT EXISTS actors (
	actorid TEXT NOT NULL,
	actor TEXT NOT NULL,
	films film_review[],
	quality_class quality_class NOT NULL,
	is_active BOOLEAN NOT NULL,
	current_year INTEGER NOT NULL,
	PRIMARY KEY (actorid, current_year)
);