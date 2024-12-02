import os
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

num_cores = os.cpu_count()

type Data = list[list[int]]


def parse_line(string: str) -> list[int]:
    return [int(s) for s in string.split()]


def parse_input(lines: str) -> Data:
    print(list(lines))
    non_empty_lines = filter(lambda x: len(x) > 0, lines)
    with ThreadPoolExecutor(num_cores) as pool:
        output = list(pool.map(parse_line, non_empty_lines))

    return output


def is_safe1(row: list[int]) -> bool:
    if row[1] > row[0]:
        sign = +1
    else:
        sign = -1

    for a, b in zip(row, row[1:]):
        delta = b - a
        if not 1 <= (delta * sign) <= 3:
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

    failing = [i for i, x in enumerate(deltas) if not 1 <= x <= 3]

    match failing:
        case []:
            return True
        case [idx] if idx == len(row) - 2 or idx == 0:
            return True
        case [idx]:
            if (1 <= (row[idx + 2] - row[idx]) <= 3) or (
                1 <= (row[idx + 1] - row[idx - 1]) <= 3
            ):
                return True
            return False
        case [first, second]:
            if second - first != 1:
                return False
            if 1 <= (row[first + 2] - row[first]) <= 3:
                return True
            return False
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
