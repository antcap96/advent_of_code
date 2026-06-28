import tempfile
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.config("spark.sql.shuffle.partitions", 1).getOrCreate()
assert isinstance(spark, SparkSession)

paper = (
    spark.read.text("../inputs/2025/day4.txt", wholetext=True)
    .select(F.posexplode(F.split(F.col("value"), "\n")).alias("y", "row"))
    .select(F.posexplode(F.split("row", "")).alias("x", "cell"), F.col("y"))
    .filter(F.col("cell") == "@")
)


def neighboors(df: DataFrame) -> DataFrame:
    left = df
    right = (
        df.withColumnRenamed("x", "x2")
        .withColumnRenamed("y", "y2")
        .withColumn("x", F.explode(F.sequence(F.col("x2") - 1, F.col("x2") + 1)))
        .withColumn("y", F.explode(F.sequence(F.col("y2") - 1, F.col("y2") + 1)))
    )

    return left.join(right, on=["x", "y"], how="inner").groupBy("x", "y").count()


df = neighboors(paper).filter(F.col("count") <= 4)

part1 = df.count()
print(f"Part 1: {part1}")


def step(df: DataFrame) -> DataFrame:
    return neighboors(df).filter(F.col("count") > 4).drop("count")


with tempfile.TemporaryDirectory() as d:
    spark.sparkContext.setCheckpointDir(d)

    df = paper.coalesce(1)
    initial_count = df.count()

    prev_count = initial_count
    count = initial_count - 1

    while count < prev_count:
        print(f"count: {count} from {prev_count}")
        prev_count = count
        df = step(df)
        df = df.persist().checkpoint(eager=True)
        count = df.count()

    part2 = initial_count - count
    print(f"Part 2: {part2}")
