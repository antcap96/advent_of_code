from pathlib import Path
from typing import Callable
from year2024.day1 import main as main1
from year2024.day2 import main as main2
from year2024.day3 import main as main3
from year2024.day4 import main as main4
from year2024.day5 import main as main5
from year2024.day6 import main as main6
from year2024.day7 import main as main7
from year2024.day8 import main as main8
import typer

solutions: dict[int, Callable[[Path | None], None]] = {
    1: main1,
    2: main2,
    3: main3,
    4: main4,
    5: main5,
    6: main6,
    7: main7,
    8: main8,
}


def main(day: int, input_path: Path | None = None):
    solution = solutions[day]
    solution(input_path)


if __name__ == "__main__":
    typer.run(main)
