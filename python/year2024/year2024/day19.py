from dataclasses import dataclass
from functools import cache

from year2024.utils.aoc import Solution


@dataclass
class Data:
    patterns: tuple[str, ...]
    designs: list[str]


def parse_patterns(string: str) -> tuple[str, ...]:
    return tuple(string.split(", "))


def parse_designs(string: str) -> list[str]:
    return string.splitlines()


def parse_input(string: str) -> Data:
    patterns_str, designs_str = string.strip().split("\n\n")

    return Data(
        parse_patterns(patterns_str),
        parse_designs(designs_str),
    )


@cache
def count_possibilities(design: str, patterns: tuple[str, ...]) -> int:
    if len(design) == 0:
        return 1

    count = 0
    for pattern in patterns:
        if design.startswith(pattern):
            count += count_possibilities(design.removeprefix(pattern), patterns)

    return count


def calculate_answer1(data: Data) -> str:
    count = 0
    for design in data.designs:
        if count_possibilities(design, data.patterns) > 0:
            count += 1
    return str(count)


def calculate_answer2(data: Data) -> str:
    count = 0
    for design in data.designs:
        count += count_possibilities(design, data.patterns)
    return str(count)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=19)
