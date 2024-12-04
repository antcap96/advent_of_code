import os
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

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


def valid_delta(delta: int) -> bool:
    return 1 <= delta <= 3


def is_safe1(row: list[int]) -> bool:
    if row[1] > row[0]:
        sign = +1
    else:
        sign = -1

    for a, b in zip(row, row[1:]):
        delta = b - a
        if not valid_delta(delta * sign):
            return False

    return True


def calculate_answer1(data: Data) -> int:
    with ThreadPoolExecutor(num_cores) as pool:
        output = sum(pool.map(is_safe1, data))

    return output


def is_safe2(row: list[int]) -> bool:
    deltas = [b - a for b, a in zip(row, row[1:])]

    if sum(1 if x < 0 else 0 for x in deltas) > 2:
        deltas = [-x for x in deltas]
    else:
        row = [-x for x in row]

    failing = [i for i, x in enumerate(deltas) if not valid_delta(x)]

    match failing:
        case []:
            return True
        case [idx] if (
            # Remove last
            idx == len(row) - 2
            # Remove first
            or idx == 0
            # Remove idx
            or valid_delta(row[idx + 1] - row[idx - 1])
        ):
            return True
        case [first, second] if (
            # Must be consecutive
            second - first == 1
            # Remove second
            and valid_delta(row[first + 2] - row[first])
        ):
            return True
        case _:
            return False


def calculate_answer2(data: Data) -> int:
    with ThreadPoolExecutor(num_cores) as pool:
        output = sum(pool.map(is_safe2, data))

    return output


def main(path: str | Path | None):
    if path is None:
        path = (Path(__file__).parents[3] / "inputs/year2024/day2/input.txt").resolve()
    with open(path) as f:
        string = f.read()

    data = parse_input(string)

    answer1 = calculate_answer1(data)
    print(f"{answer1 = }")

    answer2 = calculate_answer2(data)
    print(f"{answer2 = }")


if __name__ == "__main__":
    main(None)
