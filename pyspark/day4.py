import tempfile
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql import functions as F
import time
import gc

spark: SparkSession
spark = SparkSession.builder.config("spark.sql.shuffle.partitions", 8).getOrCreate()


paper = (
    spark.read.text("../inputs/2025/day4.txt", wholetext=True)
    .select(F.posexplode(F.split(F.col("value"), "\n")).alias("y", "row"))
    .select(F.posexplode(F.split("row", "")).alias("x", "cell"), F.col("y"))
    .filter(F.col("cell") == "@")
)

df = (
    paper.alias("left")
    .join(
        paper.alias("right"),
        on=[
            F.col("left.x").between(F.col("right.x") - 1, F.col("right.x") + 1),
            F.col("left.y").between(F.col("right.y") - 1, F.col("right.y") + 1),
        ],
        how="inner",
    )
    .groupBy("left.x", "left.y")
    .count()
    .filter(F.col("count") <= 4)
)

df.show()

part1 = df.count()
print(f"Part 1: {part1}")


def step(df: DataFrame) -> DataFrame:
    return (
        df.alias("left")
        .join(
            df.alias("right"),
            on=[
                F.col("left.x").between(F.col("right.x") - 1, F.col("right.x") + 1),
                F.col("left.y").between(F.col("right.y") - 1, F.col("right.y") + 1),
            ],
            how="inner",
        )
        .groupBy("left.x", "left.y")
        .count()
        .filter(F.col("count") > 4)
        .drop("count")
    )

with tempfile.TemporaryDirectory() as d:
    spark.sparkContext.setCheckpointDir(d)

    df = paper
    initial_count = df.count()

    prev_count = initial_count
    count = initial_count - 1
    
    start = time.perf_counter()
    while count < prev_count:
        dur = time.perf_counter() - start
        print(f"count: {count} from {prev_count} in {dur}")
        start = time.perf_counter()
        prev_count = count
        old_df = df
        df = step(df)
        # df.explain()
        df = df.checkpoint()
        print(f"{df.rdd.getNumPartitions()}")
        count = df.count()
        old_df.unpersist(blocking=True)
        gc.collect()

    part2 = initial_count - count
    print(f"Part 2: {part2}")
