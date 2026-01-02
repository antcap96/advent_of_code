import functools
from pyspark.sql import functions as F
from pyspark.sql import SparkSession
from pyspark.sql import Column

spark: SparkSession
spark = SparkSession.builder.getOrCreate()

range_split = F.split(F.col("ranges"), "-")

df = (
    spark.read.text("../inputs/2025/day2.txt", wholetext=True)
    .select(F.explode(F.split(F.col("value"), ",")).alias("ranges"))
    .filter(F.col("ranges") != "")
    .select(
        F.explode(
            F.sequence(
                F.get(range_split, 0).cast("bigint"),
                F.get(range_split, 1).cast("bigint"),
            )
        )
    )
)

df.show()


def is_repeated(n: int) -> Column:
    return (
        (F.length("col") % n == 0)
        & (F.length("col") > n)
        & functools.reduce(
            lambda a, b: a & b,
            [
                F.col("col").substr(F.lit(1), F.length("col") / n)
                == F.col("col").substr(F.length("col") / n * i + 1, F.length("col") / n)
                for i in range(1, n)
            ],
        )
    )


part1 = df.filter(is_repeated(2)).select(F.sum("col")).first()
assert part1 is not None
part1 = part1[0]
print(f"Part 1: {part1}")

# Bigint can hold up to 19 digits
part2 = (
    df.filter(
        functools.reduce(lambda a, b: a | b, [is_repeated(n) for n in range(2, 10)])
    )
    .select(F.sum("col"))
    .first()
)
assert part2 is not None
part2 = part2[0]
print(f"Part 2: {part2}")
