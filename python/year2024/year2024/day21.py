from collections.abc import Generator, Iterable, Iterator
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


# def paths(start: Point, end: Point, deny: list[Point]) -> list[str]:
#     return ["".join(path) for path in paths_aux(start, end, deny)]


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
def directional_string2(directions: str) -> list[str]:
    outputs: list[str] = [""]
    for direction1, direction2 in zip(itertools.chain(["A"], directions), directions):
        new_outputs = []
        for path in directional_to_directional_aux(direction1, direction2):
            for so_far in outputs:
                new_outputs.append(so_far + "".join(path))

        outputs = new_outputs

    return outputs


def directional_string(path: list[str]) -> list[list[str]]:
    outputs: list[list[str]] = [[]]
    for direction1, direction2 in zip(itertools.chain(["A"], path), path):
        new_outputs = []
        for path in directional_to_directional_aux(direction1, direction2):
            for so_far in outputs:
                new_outputs.append(so_far + path)

        outputs = new_outputs

    return outputs


def chunk(digit1: str, digit2: str) -> list[str]:
    part1 = numeric_to_directional_aux(digit1, digit2)
    part2 = itertools.chain(*(directional_string(path) for path in part1))
    part3 = itertools.chain(*(directional_string(path) for path in part2))
    return min(part3, key=len)


def trim(iterator: Iterable[list[str]]) -> Iterable[list[str]]:
    all_ = list(iterator)
    min_len = min(len(path) for path in all_)
    return filter(lambda x: len(x) == min_len, all_)


def trim2(iterator: Iterable[str]) -> Iterable[str]:
    all_ = list(iterator)
    min_len = min(len(path) for path in all_)
    return filter(lambda x: len(x) == min_len, all_)


def chunk2(digit1: str, digit2: str) -> str:
    part1 = numeric_to_directional_aux(digit1, digit2)
    part1 = list(map(lambda x: "".join(x), part1))
    for i in range(25):
        print(i)
        part1 = trim2(part1)
        part1 = list(part1)
        print(len(part1))
        print(part1)
        part1 = itertools.chain(*[directional_string2(path) for path in part1])
    return min(part1, key=len)


def do_thing(digits: str) -> list[str]:
    output: list[str] = []
    for digit1, digit2 in zip(itertools.chain(["A"], digits), digits):
        output.extend(chunk(digit1, digit2))

    return output


def do_thing2(digits: str) -> str:
    output: str = ""
    for digit1, digit2 in zip(itertools.chain(["A"], digits), digits):
        output += chunk2(digit1, digit2)

    return output


def complexity(string: str) -> int:
    return int(string.replace("A", "")) * len(do_thing(string))


def calculate_answer1(codes: list[str]) -> str:
    return str(sum(complexity(code) for code in codes))


solution = Solution(parse_input, calculate_answer1, calculate_answer1, day=21)
