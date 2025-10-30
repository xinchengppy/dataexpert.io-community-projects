from pyspark.sql import DataFrame, SparkSession

def read_csv(spark: SparkSession, path: str):
    """Read CSV file into Spark DataFrame"""
    return spark.read.csv(path, header=True, inferSchema=True)

def write_bucketed(df: DataFrame, table_name: str, buckets: int, bucket_col: str):
    """Write DataFrame as Spark bucketed table"""
    (
        df.write
        .mode("overwrite")
        .bucketBy(buckets, bucket_col)
        .sortBy(bucket_col)
        .saveAsTable(table_name)
    )