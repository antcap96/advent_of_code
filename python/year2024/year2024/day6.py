from __future__ import annotations

import enum
from dataclasses import dataclass
from pathlib import Path

from year2024.utils.matrix import Matrix


@dataclass
class Data:
    map: Matrix[Cell]
    starting_position: tuple[int, int]


class Cell(enum.Enum):
    Floor = "."
    Obstruction = "#"


class Direction(enum.Enum):
    North = "N"
    East = "E"
    South = "S"
    West = "W"

    def rotate(self) -> Direction:
        match self:
            case Direction.North:
                return Direction.East
            case Direction.East:
                return Direction.South
            case Direction.South:
                return Direction.West
            case Direction.West:
                return Direction.North


@dataclass(unsafe_hash=True)
class State:
    position: tuple[int, int]
    direction: Direction

    def next_position(self) -> tuple[int, int]:
        match self.direction:
            case Direction.North:
                return (self.position[0] - 1, self.position[1])
            case Direction.East:
                return (self.position[0], self.position[1] + 1)
            case Direction.South:
                return (self.position[0] + 1, self.position[1])
            case Direction.West:
                return (self.position[0], self.position[1] - 1)

    def rotate(self) -> State:
        return State(self.position, self.direction.rotate())


def parse_input(string: str) -> Data:
    lines = string.strip().splitlines()
    guard = None

    map: list[list[Cell]] = []
    for i, line in enumerate(lines):
        map.append([Cell.Obstruction if x == "#" else Cell.Floor for x in line])
        j = line.find("^")
        if j != -1:
            guard = i, j

    assert guard is not None

    return Data(Matrix.from_list_of_list(map), guard)


def step(map: Matrix[Cell], state: State) -> State | None:
    try_position = state.next_position()
    match map.get(try_position):
        case None:
            return None
        case Cell.Floor:
            return State(try_position, state.direction)
        case Cell.Obstruction:
            return state.rotate()


def calculate_answer1(data: Data) -> int:
    visited: set[tuple[int, int]] = set()

    state = State(data.starting_position, Direction.North)
    while state is not None:
        visited.add(state.position)
        state = step(data.map, state)

    return len(visited)


def is_loop_with_obstacle(map: Matrix[Cell], starting_state: State) -> bool:
    next_position = starting_state.next_position()
    before = map[next_position]
    map[next_position] = Cell.Obstruction

    visited: set[State] = set()
    state: State | None = starting_state
    while state is not None and state not in visited:
        visited.add(state)
        state = step(map, state)

    map[next_position] = before

    return state is not None


def calculate_answer2(data: Data) -> int:
    visited: set[tuple[int, int]] = set()
    loop_positions: set[tuple[int, int]] = set()

    state = State(data.starting_position, Direction.North)
    while state is not None:
        print(len(visited), len(loop_positions), state)
        visited.add(state.position)
        next_position = state.next_position()
        if (
            data.map.get(next_position) == Cell.Floor
            and next_position not in loop_positions
            and next_position not in visited
            and is_loop_with_obstacle(data.map, state)
        ):
            loop_positions.add(next_position)
        state = step(data.map, state)
    print(sorted(list(loop_positions)))
    return len(loop_positions)


def main(path: str | Path | None):
    if path is None:
        path = (Path(__file__).parents[3] / "inputs/year2024/day6/input.txt").resolve()
    with open(path) as f:
        string = f.read()

    data = parse_input(string)

    answer1 = calculate_answer1(data)
    print(f"{answer1 = }")

    answer2 = calculate_answer2(data)
    print(f"{answer2 = }")


if __name__ == "__main__":
    main(None)
