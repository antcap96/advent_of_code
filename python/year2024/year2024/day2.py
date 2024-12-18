import os
from concurrent.futures import ThreadPoolExecutor

from year2024.utils.aoc import Solution

num_cores = os.cpu_count()

type Data = list[list[int]]


def parse_line(string: str) -> list[int]:
    return [int(s) for s in string.split()]


def parse_input(string: str) -> Data:
    lines = string.strip().splitlines()
    non_empty_lines = filter(lambda x: len(x) > 0, lines)
    with ThreadPoolExecutor(num_cores) as pool:
        output = list(pool.map(parse_line, non_empty_lines))

    return output


def is_valid_delta(delta: int) -> bool:
    return 1 <= delta <= 3


def is_safe1(row: list[int]) -> bool:
    if row[1] > row[0]:
        sign = +1
    else:
        sign = -1

    for a, b in zip(row, row[1:]):
        delta = b - a
        if not is_valid_delta(delta * sign):
            return False

    return True


def calculate_answer1(data: Data) -> str:
    with ThreadPoolExecutor(num_cores) as pool:
        output = sum(pool.map(is_safe1, data))

    return str(output)


def is_safe2(row: list[int]) -> bool:
    return is_safe2_decreasing(row) or is_safe2_decreasing([-x for x in row])


def is_safe2_decreasing(row: list[int]) -> bool:
    deltas = [a - b for b, a in zip(row, row[1:])]

    failing = [idx for idx, delta in enumerate(deltas) if not is_valid_delta(delta)]

    match failing:
        case []:
            return True
        case [idx] if (
            # Remove last
            idx == len(row) - 2
            # Remove first
            or idx == 0
            # Remove idx
            or is_valid_delta(row[idx + 1] - row[idx - 1])
        ):
            return True
        case [first, second] if (
            # Must be consecutive
            second - first == 1
            # Remove second
            and is_valid_delta(row[first + 2] - row[first])
        ):
            return True
        case _:
            return False


def calculate_answer2(data: Data) -> str:
    with ThreadPoolExecutor(num_cores) as pool:
        output = sum(pool.map(is_safe2, data))

    return str(output)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=2)


if __name__ == "__main__":
    solution.solve(None)
