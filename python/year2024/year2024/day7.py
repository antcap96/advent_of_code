import functools
import operator
from collections.abc import Callable
from dataclasses import dataclass

from year2024.utils.aoc import Solution


@dataclass
class Equation:
    total: int
    numbers: list[int]


@dataclass
class ReverseOperation:
    apply: Callable[[int, int], int]
    valid: Callable[[int, int], bool]


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
                is_possible(op.apply(current, last), rest, operations)
                for op in operations
                if op.valid(current, last)
            )
        case []:
            raise ValueError("Empty numbers")
        case _:
            assert False, "That was exhaustive, no?"


def sum_of_possible(
    equations: list[Equation], operations: list[ReverseOperation]
) -> str:
    return str(
        sum(
            equation.total
            for equation in equations
            if is_possible(
                equation.total,
                equation.numbers,
                operations,
            )
        )
    )


def concat(a: int, b: int) -> int:
    return int(f"{a}{b}")


def remove_suffix(a: int, b: int) -> int:
    return int(str(a).removesuffix(str(b)))


def ends_with(a: int, b: int) -> bool:
    return a > b and str(a).endswith(str(b))


reverse_concat = ReverseOperation(remove_suffix, ends_with)


solution = Solution(
    parse_input,
    calculate_answer1=functools.partial(
        sum_of_possible, operations=[reverse_add, reverse_mul]
    ),
    calculate_answer2=functools.partial(
        sum_of_possible, operations=[reverse_add, reverse_mul, reverse_concat]
    ),
    day=7,
)


if __name__ == "__main__":
    solution.solve(None)
