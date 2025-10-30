from pyspark.sql import SparkSession
from pyspark.sql.functions import broadcast
from utils import read_csv, write_bucketed

def load_processing(spark: SparkSession):
    base_path = "./03-spark-fundamentals/data/"

    maps = read_csv(spark, base_path + "maps.csv")
    match_details = read_csv(spark, base_path + "match_details.csv")
    matches = read_csv(spark, base_path + "matches.csv")
    medals_matches_players = read_csv(spark, base_path + "medals_matches_players.csv")
    medals = read_csv(spark, base_path + "medals.csv")

    write_bucketed(match_details, "md_bucketed", 16, "match_id")
    write_bucketed(matches, "m_bucketed", 16, "match_id")
    write_bucketed(medals_matches_players, "mmp_bucketed", 16, "match_id")

    md_b = spark.table("md_bucketed")
    m_b = spark.table("m_bucketed")
    mmp_b = spark.table("mmp_bucketed")

    # mmp_b = mmp_b.withColumnRenamed("player_gamertag", "mmp_player_gamertag")
    maps = maps.withColumnRenamed("name", "map_name").withColumnRenamed("description", "map_description")
    medals = medals.withColumnRenamed("name", "medal_name").withColumnRenamed("description", "medal_description")

    joined_df = (
        md_b.join(m_b, on="match_id")
        .join(mmp_b, ["match_id", "player_gamertag"], "left")
        .join(broadcast(maps), on="mapid", how="left")
        .join(broadcast(medals), on="medal_id", how="left")
    )

    return joined_df