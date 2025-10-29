CREATE TABLE host_activity_reduced (
	month DATE,
	host TEXT,
	hit_array BIGINT[] NOT NULL DEFAULT '{}',
	unique_visitors_array BIGINT[] NOT NULL DEFAULT '{}',
	PRIMARY KEY (month, host)
);