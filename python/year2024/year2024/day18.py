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


def dfs(maze: Matrix[Cell], start: Point, target: Point) -> list[Point] | None:
    return dfs_aux(maze, start, target, [], 0)


def dfs_aux(
    maze: Matrix[Cell], start: Point, target: Point, so_far: list[Point], step: int
) -> list[Point] | None:
    if start == target:
        return so_far[:step]

    if len(so_far) > step:
        so_far[step] = start
    else:
        so_far.append(start)

    neighboors = [
        (start[0] + 1, start[1]),
        (start[0], start[1] + 1),
        (start[0] - 1, start[1]),
        (start[0], start[1] - 1),
    ]

    for neighboor in neighboors:
        if maze.get(neighboor) == Cell.Floor and neighboor not in reversed(so_far):
            result = dfs_aux(maze, neighboor, target, so_far, step + 1)
            if result is not None:
                return result


def calculate_answer1(
    blocks: list[Point], shape: Point = (71, 71), bytes: int = 1024
) -> str:
    maze = create_maze(blocks[:bytes], shape)

    result = dfs(maze, (0, 0), (shape[0] - 1, shape[1] - 1))
    assert result is not None
    return str(len(result))


def calculate_answer2(blocks: list[Point], shape: Point = (71, 71)) -> str:
    maze = Matrix([Cell.Floor] * shape[0] * shape[1], rows=shape[0], cols=shape[1])
    path = dfs(maze, (0, 0), (shape[0] - 1, shape[1] - 1))
    assert path is not None
    path = set(path)
    for block in blocks:
        maze[block] = Cell.Wall
        if block in path:
            path = dfs(maze, (0, 0), (shape[0] - 1, shape[1] - 1))
            if path is None:
                return ",".join(map(str, block))
            else:
                path = set(path)
    raise ValueError("Nerver blocked")


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=18)
