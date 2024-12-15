from pathlib import Path
from typing import Any

import typer

from year2024.day1 import solution as solution1
from year2024.day2 import solution as solution2
from year2024.day3 import solution as solution3
from year2024.day4 import solution as solution4
from year2024.day5 import solution as solution5
from year2024.day6 import solution as solution6
from year2024.day7 import solution as solution7
from year2024.day8 import solution as solution8
from year2024.day9 import solution as solution9
from year2024.day10 import solution as solution10
from year2024.day11 import solution as solution11
from year2024.day12 import solution as solution12
from year2024.day13 import solution as solution13
from year2024.day14 import solution as solution14
from year2024.day15 import solution as solution15
from year2024.utils.aoc import Solution

solutions: dict[int, Solution[Any]] = {
    1: solution1,
    2: solution2,
    3: solution3,
    4: solution4,
    5: solution5,
    6: solution6,
    7: solution7,
    8: solution8,
    9: solution9,
    10: solution10,
    11: solution11,
    12: solution12,
    13: solution13,
    14: solution14,
    15: solution15,
}


def main(day: int, input_path: Path | None = None, timed: bool = False):
    solution = solutions[day]
    solution.solve(input_path, timed)


if __name__ == "__main__":
    typer.run(main)
