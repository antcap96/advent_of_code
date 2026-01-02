from pyspark.sql import functions as F, Window
from pyspark.sql import SparkSession

spark: SparkSession
spark = SparkSession.builder.getOrCreate()

df = (
    spark.read.text("../inputs/2025/day1.txt", wholetext=True)
    .select(F.posexplode(F.split(F.col("value"), "\n")))
    .filter(F.col("col") != "")
)

# Extract number from instruction by ignoring first character
num = F.col("col").substr(F.lit(2), F.length("col") - 1).cast("int")

rotation_index = F.floor(F.col("sum") / 100)
rotations = F.abs(rotation_index - F.lag(rotation_index, 1, 0).over(Window.orderBy("pos")))

df = (
    df.withColumn(
        "delta",
        F.when(F.col("col").startswith("L"), -num).otherwise(num),
    )
    .withColumn(
        "sum",
        F.sum("delta").over(
            Window.orderBy("pos").rowsBetween(Window.unboundedPreceding, 0)
        )
        + 50,
    )
    .withColumn("at", F.col("sum") % 100)
    .withColumn(
        "rotations",
        rotations
        + F.when((F.col("at") == 0) & (F.col("delta") < 0), F.lit(1))
        .when(
            (F.lag("at", 1, 50).over(Window.orderBy("pos")) == 0)
            & (F.col("delta") < 0),
            F.lit(-1),
        )
        .otherwise(F.lit(0)),
    )
)

df.show()

part1 = df.filter(F.col("at") == 0).count()
print(f"Part 1: {part1}")

part2 = df.select(F.sum("rotations")).first()
assert part2 is not None
part2 = part2[0]
print(f"Part 2: {part2}")
