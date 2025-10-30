from pyspark.sql import SparkSession
from load_processing import load_processing
from queries import *
import os
import builtins

def compare_file_size(paths: list):
    """Compare local Parquet folder sizes"""
    for path in paths:
        total_size = 0
        if os.path.exists(path):
            for file in os.listdir(path):
                total_size += os.path.getsize(os.path.join(path, file))
            print(f"{path}: {builtins.round(total_size / 1024 / 1024, 2)} MB")
        else:
            print(f"Path not found: {path}")

def main():
    # Initialize Spark
    spark = (
        SparkSession.builder
        .appName("LocalSparkHomework")
        .master("local[*]")
        .config("spark.sql.autoBroadcastJoinThreshold", "-1")
        .getOrCreate()
    )

    print("\nLoading and joining data...")
    joined_df = load_processing(spark)

    print("\nRunning analytical queries...")
    q1 = player_avg_kills(joined_df)
    q2 = playlist_counts(joined_df)
    q3 = map_counts(joined_df)
    q4 = map_killingspree_medals_counts(joined_df)

    q1.show(10)
    q2.show(1)
    q3.show(1)
    q4.show(1)

    print("\n Writing partitioned versions for compression analysis...")
    base_out = "./out_partitioned"
    os.makedirs(base_out, exist_ok=True)

    # Version A: baseline (no partition)
    (
        q3.write
        .mode("overwrite")
        .format("parquet")
        .save(f"{base_out}/q3_no_partition")
    )

    # Version B: partitioned by playlist_id (from q2)
    (
        q2.repartition("playlist_id")
        .sortWithinPartitions("playlist_id")
        .write
        .mode("overwrite")
        .format("parquet")
        .partitionBy("playlist_id")
        .save(f"{base_out}/q2_partition_playlist")
    )

    # Version C: partitioned by mapid (from q3)
    (
        q3.repartition("mapid")
        .sortWithinPartitions("mapid", "map_name")
        .write
        .mode("overwrite")
        .format("parquet")
        .partitionBy("mapid")
        .save(f"{base_out}/q3_partition_mapid")
    )

    # Version D: partitioned by both mapid + map_name
    (
        q3.repartition("mapid", "map_name")
        .sortWithinPartitions("mapid", "map_name")
        .write
        .mode("overwrite")
        .format("parquet")
        .partitionBy("mapid", "map_name")
        .save(f"{base_out}/q3_partition_mapid_name")
    )

    print("\nComparing partitioned file sizes:")
    compare_file_size([
        f"{base_out}/q3_no_partition",
        f"{base_out}/q2_partition_playlist",
        f"{base_out}/q3_partition_mapid",
        f"{base_out}/q3_partition_mapid_name",
    ])
    
    print("\nSpark job complete.")
    spark.stop()

if __name__ == "__main__":
    main()