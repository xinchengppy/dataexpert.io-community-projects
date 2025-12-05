# Homework Run Instructions

This guide provides step-by-step instructions to run the Apache Flink homework, which sessionizes web events by IP address and host using a 5-minute gap.

## Environment Variables

Create or update `flink-env.env` with the following variables:

```bash
KAFKA_WEB_TRAFFIC_SECRET="<your-confluent-secret>"
KAFKA_WEB_TRAFFIC_KEY="<your-confluent-key>"
IP_CODING_KEY="<your-ip2location-key>"
KAFKA_GROUP=web-events
KAFKA_TOPIC=raw_events_kafka
KAFKA_URL=pkc-rgm37.us-west-2.aws.confluent.cloud:9092

FLINK_VERSION=1.16.0
PYTHON_VERSION=3.7.9

POSTGRES_URL=jdbc:postgresql://host.docker.internal:5432/postgres
JDBC_BASE_URL=jdbc:postgresql://host.docker.internal:5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
```

**Note:** Do not share or commit this file as it contains sensitive credentials.

## Steps

1. **Start the services:**
   ```bash
   make up
   ```
   Wait until the Flink UI is available at http://localhost:8081.


2. **Create table in postgres**
    run `homework_init.sql` in pgadmin or other sql IDE.

3. **Run the homework job:**
   ```bash
   make homework_job
   ```
   This runs `homework_job.py`, which reads from the Kafka topic specified by `KAFKA_TOPIC` ('raw_events_kafka'), applies session windows (5-minute gap), and writes sessionized data to `processed_events_sessionized` in PostgreSQL.

4. **Verify the results:**
   Connect to PostgreSQL (assuming it's running on localhost:5432 as per the env vars):
   ```bash
   psql -h localhost -U postgres -d postgres
   ```
   Then run:
   ```sql
   SELECT * FROM processed_events_sessionized LIMIT 10;
   ```

5. **Answer the homework questions:**
   - What is the average number of web events per session from a user on Tech Creator?
   - Compare results between different hosts (zachwilson.techcreator.io, zachwilson.tech, lulu.techcreator.io)

   Example queries:
   ```sql
   -- Average events per session
   SELECT 
    ip, 
    ROUND(AVG(num_events), 2) AS avg_num_events
    FROM processed_events_sessionized
    WHERE host LIKE '%.techcreator.io'
    GROUP BY ip, host
    ORDER BY avg_num_events DESC;
    

   -- Compare by host
   SELECT 
    host,
    COUNT(*) AS total_sessions,
    ROUND(AVG(num_events), 2) AS avg_num_events
    FROM processed_events_sessionized
    WHERE host IN (
        'zachwilson.techcreator.io',
        'zachwilson.tech',
        'lulu.techcreator.io'
    )
    GROUP BY host;
   ```

6. **Clean up:**
   ```bash
   make down
   ```

## Troubleshooting

- If jobs fail, check Flink UI logs or run without `-d` for error output.
- Ensure Kafka topics exist in Confluent Cloud.
- For topic creation issues, check ACLs or enable auto-creation.