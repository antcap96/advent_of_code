from collections.abc import Generator
from functools import cache
import itertools
from year2024.utils.aoc import Solution

type Point = tuple[int, int]

numeric_pad: dict[Point, str] = {
    (0, 0): "7",
    (0, 1): "8",
    (0, 2): "9",
    (1, 0): "4",
    (1, 1): "5",
    (1, 2): "6",
    (2, 0): "1",
    (2, 1): "2",
    (2, 2): "3",
    (3, 1): "0",
    (3, 2): "A",
}

reverse_numeric_pad = {v: k for k, v in numeric_pad.items()}

directional_pad: dict[Point, str] = {
    (0, 1): "^",
    (0, 2): "A",
    (1, 0): "<",
    (1, 1): "v",
    (1, 2): ">",
}
reverse_directional_pad = {v: k for k, v in directional_pad.items()}


def parse_input(string: str) -> list[str]:
    return string.strip().splitlines()


def north(point: Point) -> Point:
    i, j = point
    return (i - 1, j)


def east(point: Point) -> Point:
    i, j = point
    return (i, j + 1)


def south(point: Point) -> Point:
    i, j = point
    return (i + 1, j)


def west(point: Point) -> Point:
    i, j = point
    return (i, j - 1)


def paths_aux(start: Point, end: Point, deny: list[Point]) -> list[list[str]]:
    output: list[list[str]] = []
    if start == end:
        return [[]]
    if end[0] > start[0]:
        if north(end) not in deny:
            paths = paths_aux(start, north(end), deny)
            for path in paths:
                path.append("v")
            output.extend(paths)
    elif end[0] < start[0]:
        if south(end) not in deny:
            paths = paths_aux(start, south(end), deny)
            for path in paths:
                path.append("^")
            output.extend(paths)
    if end[1] > start[1]:
        if west(end) not in deny:
            paths = paths_aux(start, west(end), deny)
            for path in paths:
                path.append(">")
            output.extend(paths)
    elif end[1] < start[1]:
        if east(end) not in deny:
            paths = paths_aux(start, east(end), deny)
            for path in paths:
                path.append("<")
            output.extend(paths)

    return output


def numeric_to_directional_aux(
    digit1: str,
    digit2: str,
) -> Generator[list[str]]:
    start = reverse_numeric_pad[digit1]
    end = reverse_numeric_pad[digit2]

    yield from map(lambda x: x + ["A"], paths_aux(start, end, deny=[(3, 0)]))


def directional_to_directional_aux(
    direction1: str,
    direction2: str,
) -> Generator[list[str]]:
    start = reverse_directional_pad[direction1]
    end = reverse_directional_pad[direction2]

    yield from map(lambda x: x + ["A"], paths_aux(start, end, deny=[(0, 0)]))


@cache
def directional_to_directional_aux_cost(
    direction1: str, direction2: str, level: int
) -> int:
    paths = directional_to_directional_aux(direction1, direction2)
    if level == 0:
        return min(len(path) for path in paths)

    min_cost = None
    for path in paths:
        cost = 0
        for direction1, direction2 in zip(itertools.chain(["A"], path), path):
            cost += directional_to_directional_aux_cost(
                direction1, direction2, level - 1
            )
        if min_cost is None or cost < min_cost:
            min_cost = cost

    assert min_cost is not None

    return min_cost


def chunk2(digit1: str, digit2: str, depth: int) -> int:
    part1 = numeric_to_directional_aux(digit1, digit2)

    min_cost = None
    for path in part1:
        cost = 0
        for direction1, direction2 in zip(itertools.chain(["A"], path), path):
            cost += directional_to_directional_aux_cost(
                direction1, direction2, depth - 1
            )
        if min_cost is None or cost < min_cost:
            min_cost = cost

    assert min_cost is not None

    return min_cost


def do_thing2(digits: str, depth: int) -> int:
    output = 0
    for digit1, digit2 in zip(itertools.chain(["A"], digits), digits):
        output += chunk2(digit1, digit2, depth)

    return output


def complexity2(string: str, depth: int) -> int:
    return int(string.replace("A", "")) * do_thing2(string, depth)


def calculate_answer1(codes: list[str]) -> str:
    return str(sum(complexity2(code, depth=2) for code in codes))


def calculate_answer2(codes: list[str]) -> str:
    return str(sum(complexity2(code, depth=25) for code in codes))


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=21)
