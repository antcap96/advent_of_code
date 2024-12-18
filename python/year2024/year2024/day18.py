from __future__ import annotations
from enum import Enum
from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix

type Point = tuple[int, int]


class Cell(Enum):
    Floor = "."
    Wall = "#"


def parse_point(string: str) -> Point:
    a, b = string.split(",")
    return int(a), int(b)


def parse_input(string: str) -> list[Point]:
    lines = string.strip().splitlines()

    return [parse_point(line) for line in lines]


def create_maze(blocks: list[Point], shape: Point) -> Matrix[Cell]:
    maze = Matrix([Cell.Floor] * shape[0] * shape[1], rows=shape[0], cols=shape[1])
    for block in blocks:
        maze[block] = Cell.Wall

    return maze


def disjktra(maze: Matrix[Cell], start: Point, target: Point) -> int | None:
    to_visit: set[Point] = set()
    visited: set[Point] = set()
    to_visit.add(start)

    i = 0
    while len(to_visit) > 0:
        next_to_visit = set()
        for p in to_visit:
            visited.add(p)

            if p == target:
                return i

            neighboors = [
                (p[0] - 1, p[1]),
                (p[0], p[1] - 1),
                (p[0] + 1, p[1]),
                (p[0], p[1] + 1),
            ]
            for neighboor in neighboors:
                if maze.get(neighboor) == Cell.Floor and neighboor not in visited:
                    next_to_visit.add(neighboor)

        to_visit = next_to_visit
        i += 1


def calculate_answer1(
    blocks: list[Point], shape: Point = (71, 71), bytes: int = 1024
) -> int:
    maze = create_maze(blocks[:bytes], shape)

    result = disjktra(maze, (0, 0), (shape[0] - 1, shape[1] - 1))
    assert result is not None
    return result


def calculate_answer2(
    blocks: list[Point], shape: Point = (71, 71), bytes: int = 1024
) -> str:
    maze = Matrix([Cell.Floor] * shape[0] * shape[1], rows=shape[0], cols=shape[1])
    for i, block in enumerate(blocks):
        print(i)
        maze[block] = Cell.Wall
        if disjktra(maze, (0, 0), (shape[0] - 1, shape[1] - 1)) is None:
            return ",".join(map(str, block))
    raise ValueError("Nerver blocked")


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=18)
