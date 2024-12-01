from pathlib import Path
from year2024.day1 import main as main1
import typer

solutions = {
    1: main1,
}


def main(day: int, input_path: Path | None = None):
    solution = solutions[day]
    solution(input_path)


if __name__ == "__main__":
    typer.run(main)
