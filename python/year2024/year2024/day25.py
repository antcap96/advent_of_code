from dataclasses import dataclass
from year2024.utils.aoc import Solution


@dataclass
class Key:
    height: list[int]


@dataclass
class Lock:
    height: list[int]


def parse_chunk(chunk: str) -> Key | Lock:
    lines = chunk.splitlines()
    heights = []
    if all(c == "." for c in lines[0]):
        item = "."
    else:
        item = "#"

    for i in range(len(lines[0])):
        for j, line in enumerate(lines):
            if line[i] != item:
                heights.append(j)
                break

    if item == ".":
        return Lock(heights)
    else:
        return Key(heights)


def parse_input(string: str) -> list[Key | Lock]:
    chunks = string.strip().split("\n\n")

    return [parse_chunk(chunk) for chunk in chunks]


def calculate_answer1(data: list[Key | Lock]) -> str:
    keys = list(filter(lambda x: isinstance(x, Key), data))
    locks = list(filter(lambda x: isinstance(x, Lock), data))

    count = 0
    for key in keys:
        for lock in locks:
            for h1, h2 in zip(key.height, lock.height):
                if h2 < h1:
                    break
            else:
                count += 1

    return str(count)

def calculate_answer2(data: list[Key | Lock]) -> str:
    return "*"

solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=25)


solution.solve(None)
