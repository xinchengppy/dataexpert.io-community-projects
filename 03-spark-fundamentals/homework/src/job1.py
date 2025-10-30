from pyspark.sql import SparkSession, DataFrame

query = """
WITH did_change AS (
	SELECT 
		actorid,
		actor,
		current_year,
		quality_class,
		is_active,
		LAG(quality_class, 1) OVER
			(PARTITION BY actorid ORDER BY current_year) <> quality_class
			 OR LAG(quality_class, 1) OVER
               (PARTITION BY actorid ORDER BY current_year) IS NULL
               AS did_quality_change,
	   	LAG(is_active, 1) OVER
		   	(PARTITION BY actorid ORDER BY current_year) <> is_active
			 OR LAG(is_active, 1) OVER
               (PARTITION BY actorid ORDER BY current_year) IS NULL
               AS did_active_change
   FROM actors
),
	change_identified AS (
	SELECT
		actorid,
		actor,
		current_year,
		quality_class,
		is_active,
		SUM(CASE WHEN did_quality_change OR did_active_change THEN 1 ELSE 0 END) OVER
			(PARTITION BY actorid ORDER BY current_year) 
		AS change_identifier
	FROM did_change
),
	aggregated AS (
	SELECT
		actorid,
		actor,
		change_identifier,
		quality_class,
		is_active,
		MIN(current_year) AS start_year,
		MAX(current_year) AS end_year,
		(SELECT MAX(current_year) FROM actors) AS current_year
	FROM change_identified
	GROUP BY 1, 2, 3, 4, 5
)
    SELECT
        actorid,
        actor,
        quality_class,
        start_year,
        end_year,
        is_active,
        current_year
    FROM aggregated;
"""

def do_actor_cumulative_transformation(spark: SparkSession, dataframe: DataFrame):
    """Perform cumulative transformation on actors data."""
    dataframe.createOrReplaceTempView("actors")
    return spark.sql(query)

def main():
    spark = SparkSession.builder.master("local").appName("Actor_Cumulative").getOrCreate()
    output_df = do_actor_cumulative_transformation(spark, spark.table("actors"))
    output_df.write.mode("overwrite").insertInto("actors_cumulative")
