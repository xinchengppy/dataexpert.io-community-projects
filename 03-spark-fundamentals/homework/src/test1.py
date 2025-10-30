from chispa.dataframe_comparer import *
from ..jobs.job1 import do_actor_cumulative_transformation
from collections import namedtuple


ActorYear = namedtuple("ActorYear", "actorid actor current_year quality_class is_active")
ActorHistoryScd = namedtuple(
    "ActorHistoryScd",
    "actorid actor quality_class start_year end_year is_active current_year",
)


def test_scd_generation(spark):
    source_data = [
        ActorYear(1, "actor A", 2013, "good", True),
        ActorYear(1, "actor A", 2014, "good", True),
        ActorYear(1, "actor A", 2015, "star", True),
        ActorYear(2, "actor B", 2013, "bad", False),
        ActorYear(2, "actor B", 2014, "average", True),
        ActorYear(2, "actor B", 2015, "average", True),
    ]
    source_df = spark.createDataFrame(source_data)

    source_df.createOrReplaceTempView("actors")
    actual_df = do_actor_cumulative_transformation(spark, source_df)

    expected_data = [
        ActorHistoryScd(1, "actor A", "good", 2013, 2014, True, 2015),
        ActorHistoryScd(1, "actor A", "star", 2015, 2015, True, 2015),
        ActorHistoryScd(2, "actor B", "bad", 2013, 2013, False, 2015),
        ActorHistoryScd(2, "actor B", "average", 2014, 2015, True, 2015),
    ]
    expected_df = spark.createDataFrame(expected_data).select(
    "actorid", "actor", "quality_class", "start_year", "end_year", "is_active", "current_year"
)
    assert_df_equality(actual_df, expected_df, ignore_nullable=True)