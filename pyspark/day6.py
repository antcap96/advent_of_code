from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql import Window

spark = SparkSession.builder.config("spark.sql.shuffle.partitions", 1).getOrCreate()
assert isinstance(spark, SparkSession)

chunks = (
    spark.read.text("../inputs/2025/day6.txt", wholetext=True)
    .select(F.posexplode(F.split("value", "\n")).alias("i", "col"))
    .filter(F.length("col") > 0)
)

w = Window().orderBy("i")

max_i = chunks.agg(F.max("i")).scalar()

ops = chunks.filter(F.col("i") == max_i)
nums = chunks.filter(F.col("i") < max_i)

indicies = (
    ops.select("col", F.split("col", r"[\+\*]").alias("spaces"))
    .select("col", F.posexplode("spaces").alias("i", "s"))
    .withColumn("size", F.length("s"))
    .withColumn("cum_size", F.sum("size").over(w))
    .withColumn("start", F.col("cum_size") + F.col("i") + 1)
    .withColumn("op", F.substr("col", "start", F.lit(1)))
    .select(
        "op",
        "start",
        (
            F.lead("start").over(w)
            - F.col("start")
            - F.when(F.lead("start", 2).over(w).isNotNull(), 1).otherwise(0)
        ).alias("len"),
    )
    .filter(F.col("len").isNotNull())
)


data = (
    indicies.join(nums, how="cross")
    .withColumn("num", F.substr("col", "start", "len"))
    .drop("col")
)

part1 = (
    data.groupBy("start", "op")
    .agg(
        F.when(F.col("op") == "+", F.sum("num"))
        .otherwise(F.product("num"))
        .cast("bigint")
        .alias("x")
    )
    .agg(F.sum("x"))
    .first()
)
assert part1 is not None
part1 = part1[0]
print(f"Part 1: {part1}")

w2 = (
    Window()
    .partitionBy("start", "op", "j")
    .orderBy("i")
    .rangeBetween(Window.unboundedPreceding, Window.unboundedFollowing)
)

data2 = (
    data.select("*", F.posexplode(F.split("num", "")).alias("j", "d"))
    .withColumn("num2", F.concat_ws("", F.collect_list("d").over(w2)))
    .drop_duplicates(["start", "op", "j"])
)


part2 = (
    data2.groupBy("start", "op")
    .agg(
        F.when(F.col("op") == "+", F.sum("num2"))
        .otherwise(F.product("num2"))
        .cast("bigint")
        .alias("x")
    )
    .agg(F.sum("x"))
    .first()
)
assert part2 is not None
part2 = part2[0]
print(f"Part 2: {part2}")
