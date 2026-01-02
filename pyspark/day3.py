from pyspark.sql import functions as F
from pyspark.sql import SparkSession
from pyspark.sql import Column

spark: SparkSession
spark = SparkSession.builder.getOrCreate()

range_split = F.split(F.col("ranges"), "-")


def max_of_slice(n: int, i: int) -> Column:
    if i == 1:
        return F.array_max(F.slice("idx", 1, F.size("idx") - n + 1))

    prev_idx = -F.col(f"max_{n}_{i - 1}").getField("idx")
    return F.array_max(
        F.slice(
            "idx",
            prev_idx + 1,
            F.size("idx") - prev_idx - n + i,
        )
    )


def combine(n: int) -> Column:
    cols = [F.col(f"max_{n}_{i}").getField("value") for i in range(1, n + 1)]
    return F.concat(*cols).cast("bigint")


df = (
    spark.read.text("../inputs/2025/day3.txt", wholetext=True)
    .select(F.explode(F.split(F.col("value"), "\n")).alias("ratings"))
    .filter(F.col("ratings") != "")
    .withColumn("digits", F.split(F.col("ratings"), ""))
    .withColumn(
        "idx",
        F.zip_with(
            "digits",
            F.sequence(-F.lit(1), -F.size("digits"), step=F.lit(-1)),
            lambda value, idx: F.struct(value.alias("value"), idx.alias("idx")),
        ),
    )
)

for i in range(1, 3):
    df = df.withColumn(f"max_2_{i}", max_of_slice(2, i))

for i in range(1, 13):
    df = df.withColumn(f"max_12_{i}", max_of_slice(12, i))

df.show()

part1 = df.agg(F.sum(combine(2))).first()
assert part1 is not None
part1 = part1[0]
print(f"Part 1: {part1}")

part2 = df.agg(F.sum(combine(12))).first()
assert part2 is not None
part2 = part2[0]
print(f"Part 2: {part2}")
