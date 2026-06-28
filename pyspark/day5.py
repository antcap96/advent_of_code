from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql import Window

spark = SparkSession.builder.config("spark.sql.shuffle.partitions", 1).getOrCreate()
assert isinstance(spark, SparkSession)

chunks = spark.read.text("../inputs/2025/day5.txt", wholetext=True).select(
    F.posexplode(F.split(F.col("value"), "\n\n")).alias("idx", "data")
)

ranges = (
    chunks.filter(F.col("idx") == 0)
    .select(F.explode(F.split("data", "\n")).alias("ranges"))
    .select(
        F.split_part("ranges", F.lit("-"), F.lit(1)).alias("low"),
        F.split_part("ranges", F.lit("-"), F.lit(2)).alias("high"),
    )
    .select(
        F.col("low").cast("bigint").alias("low"),
        F.col("high").cast("bigint").alias("high"),
    )
)

ids = (
    chunks.filter(F.col("idx") == 1)
    .select(F.explode(F.split("data", "\n")).alias("id"))
    .select(F.col("id").cast("bigint").alias("id"))
)


ranges.show()
ids.show()

part1 = ids.join(
    ranges, on=ids["id"].between(ranges["low"], ranges["high"]), how="left_semi"
).count()
print(f"Part 1: {part1}")

w = Window().partitionBy(F.lit(1)).orderBy("low", "high")

part2 = (
    ranges.withColumn("overlap", F.lag("high").over(w) >= F.col("low"))
    .withColumn(
        "group", F.sum(F.when(F.col("overlap"), F.lit(0)).otherwise(F.lit(1))).over(w)
    )
    .groupBy("group")
    .agg(F.min("low").alias("low"), F.max("high").alias("high"))
    .withColumn("count", F.col("high") - F.col("low") + 1)
    .agg(F.sum("count"))
    .first()
)
assert part2 is not None
part2 = part2[0]
print(f"Part 2: {part2}")
