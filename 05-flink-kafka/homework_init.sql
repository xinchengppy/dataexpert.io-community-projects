CREATE TABLE IF NOT EXISTS processed_events_sessionized (
	session_start TIMESTAMP(3),
    session_end TIMESTAMP(3),
    ip VARCHAR,
    host VARCHAR,
    num_events BIGINT
    );