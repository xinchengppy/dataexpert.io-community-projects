CREATE TABLE hosts_cumulated (
	host TEXT NOT NULL,
	host_activity_datelist DATE[] NOT NULL DEFAULT '{}',
	date DATE NOT NULL,
	PRIMARY KEY(host, date)
);