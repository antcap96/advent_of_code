import operator
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


@dataclass
class Equation:
    total: int
    numbers: list[int]


@dataclass
class ReverseOperation:
    op: Callable[[int, int], int]
    is_possible: Callable[[int, int], bool]


def is_mul_possible(total: int, by: int) -> bool:
    return total % by == 0


reverse_add = ReverseOperation(operator.sub, operator.gt)
reverse_mul = ReverseOperation(operator.floordiv, is_mul_possible)


def parse_line(string: str) -> Equation:
    total_str, numbers_str = string.split(": ")
    numbers = [int(x) for x in numbers_str.split(" ")]

    return Equation(int(total_str), numbers)


def parse_input(string: str) -> list[Equation]:
    lines = string.strip().splitlines()
    return [parse_line(line) for line in lines]


def is_possible(
    current: int,
    numbers: list[int],
    operations: list[ReverseOperation],
) -> bool:
    match numbers:
        case [first]:
            return current == first
        case [*rest, last]:
            return any(
                is_possible(op.op(current, last), rest, operations)
                for op in operations
                if op.is_possible(current, last)
            )
        case []:
            raise ValueError("Empty numbers")

    assert False, "That was exhaustive, no?"


def calculate_answer1(equations: list[Equation]) -> int:
    return sum(
        equation.total
        for equation in equations
        if is_possible(
            equation.total,
            equation.numbers,
            [reverse_add, reverse_mul],
        )
    )


def concat(a: int, b: int) -> int:
    return int(f"{a}{b}")


def remove_suffix(a: int, b: int) -> int:
    return int(str(a).removesuffix(str(b)))


def ends_with(a: int, b: int) -> bool:
    return a > b and str(a).endswith(str(b))


reverse_concat = ReverseOperation(remove_suffix, ends_with)


def calculate_answer2(equations: list[Equation]) -> int:
    return sum(
        equation.total
        for equation in equations
        if is_possible(
            equation.total,
            equation.numbers,
            [reverse_add, reverse_mul, reverse_concat],
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
