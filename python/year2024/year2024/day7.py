from dataclasses import dataclass
from pathlib import Path
from typing import Callable
import operator
from tqdm import tqdm


@dataclass
class Equation:
    total: int
    numbers: list[int]


def parse_line(string: str) -> Equation:
    total_str, numbers_str = string.split(": ")
    numbers = [int(x) for x in numbers_str.split(" ")]

    return Equation(int(total_str), numbers)


def parse_input(string: str) -> list[Equation]:
    lines = string.strip().splitlines()
    return [parse_line(line) for line in lines]


def is_possible(
    total: int,
    current: int,
    numbers: list[int],
    operations: list[Callable[[int, int], int]],
) -> bool:
    match numbers:
        case []:
            return total == current
        case [first, *rest]:
            return any(
                is_possible(total, op(current, first), rest, operations)
                for op in operations
            )

    assert False, "That was exhaustive, no?"


def calculate_answer1(equations: list[Equation]) -> int:
    return sum(
        equation.total
        for equation in equations
        if is_possible(
            equation.total,
            equation.numbers[0],
            equation.numbers[1:],
            [operator.add, operator.mul],
        )
    )


def concat(a: int, b: int) -> int:
    return int(f"{a}{b}")


def calculate_answer2(equations: list[Equation]) -> int:
    return sum(
        equation.total
        for equation in tqdm(equations)
        if is_possible(
            equation.total,
            equation.numbers[0],
            equation.numbers[1:],
            [operator.add, operator.mul, concat],
        )
    )

def main(path: str | Path | None):
    if path is None:
        path = Path(__file__).resolve().parents[3] / "inputs/year2024/day7/input.txt"
    with open(path) as f:
        string = f.read()

    data = parse_input(string)

    answer1 = calculate_answer1(data)
    print(f"{answer1 = }")

    answer2 = calculate_answer2(data)
    print(f"{answer2 = }")


if __name__ == "__main__":
    main(None)
