import datetime
import time
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path


def print_time(prefix: str, start_time: float) -> None:
    duration_in_ms = (
        datetime.timedelta(seconds=time.perf_counter() - start_time)
    ).microseconds // 1000
    print(f"{prefix} {duration_in_ms}ms")


@dataclass
class Solution[T]:
    parse_input: Callable[[str], T]
    calculate_answer1: Callable[[T], int]
    calculate_answer2: Callable[[T], int]
    day: int

    def solve(self, path: str | Path | None, timed: bool = False):
        start_time = time.perf_counter()
        if path is None:
            path = (
                Path(__file__).resolve().parents[4]
                / f"inputs/year2024/day{self.day}/input.txt"
            )
        with open(path) as f:
            string = f.read()

        data = self.parse_input(string)

        if timed:
            print_time("Parsing imput:", start_time)
            start_time = time.perf_counter()

        answer1 = self.calculate_answer1(data)
        print(f"{answer1 = }")

        if timed:
            print_time("Calculating answer 1:", start_time)
            start_time = time.perf_counter()

        answer2 = self.calculate_answer2(data)
        print(f"{answer2 = }")

        if timed:
            print_time("Calculating answer 2:", start_time)
