from pathlib import Path
from typing import Callable
from year2024.day1 import main as main1
from year2024.day2 import main as main2
import typer

solutions: dict[int, Callable[[Path | None], None]] = {
    1: main1,
    2: main2,
}


def main(day: int, input_path: Path | None = None):
    solution = solutions[day]
    solution(input_path)


if __name__ == "__main__":
    typer.run(main)
