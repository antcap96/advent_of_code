from dataclasses import dataclass
from pathlib import Path
from typing import Callable


@dataclass
class Solution[T]:
    parse_input: Callable[[str], T]
    calculate_answer1: Callable[[T], int]
    calculate_answer2: Callable[[T], int]
    day: int

    def solve(self, path: str | Path | None):
        if path is None:
            path = (
                Path(__file__).resolve().parents[4]
                / f"inputs/year2024/day{self.day}/input.txt"
            )
        with open(path) as f:
            string = f.read()

        data = self.parse_input(string)

        answer1 = self.calculate_answer1(data)
        print(f"{answer1 = }")

        answer2 = self.calculate_answer2(data)
        print(f"{answer2 = }")
