from pyspark.sql import DataFrame
from pyspark.sql.functions import *


def player_avg_kills(joined_df: DataFrame) -> DataFrame:
    """
    Compute average kills per match per player
    """
    return (
        joined_df.groupBy("match_id", "player_gamertag")
        .agg(max("player_total_kills").alias("kills_in_match"))
        .groupBy("player_gamertag")
        .agg(avg("kills_in_match").alias("avg_kills_per_match"))
        .orderBy(desc("avg_kills_per_match"))
    )


def playlist_counts(joined_df: DataFrame) -> DataFrame:
    """
    Compute number of matches per playlist
    """
    return (
        joined_df.groupBy("playlist_id")
        .agg(count_distinct("match_id").alias("num_matches"))
        .orderBy(desc("num_matches"))
    )


def map_counts(joined_df: DataFrame) -> DataFrame:
    """
    Compute number of matches per map
    """
    return (
        joined_df.groupBy("mapid", "map_name")
        .agg(count_distinct("match_id").alias("num_matches"))
        .orderBy(desc("num_matches"))
    )


def map_killingspree_medals_counts(joined_df: DataFrame) -> DataFrame:
    """
    Compute the number of killing spree medals per map
    """
    return (
        joined_df.filter(col("medal_name") == "Killing Spree")
        .groupBy("mapid", "map_name")
        .agg(count("medal_name").alias("num_killing_spree_medals"))
        .orderBy(desc("num_killing_spree_medals"))
    )

