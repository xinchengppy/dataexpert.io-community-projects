CREATE TABLE user_devices_cumulated (
	user_id TEXT NOT NULL,
	browser_type TEXT NOT NULL,
	device_activity_datelist DATE[] NOT NULL DEFAULT '{}',
	date DATE NOT NULL,
	PRIMARY KEY (user_id, browser_type, date)
);