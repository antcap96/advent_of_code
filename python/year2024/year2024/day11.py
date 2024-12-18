from __future__ import annotations

import functools
from collections import Counter, defaultdict
from collections.abc import Mapping

from year2024.utils.aoc import Solution


def parse_input(string: str) -> list[int]:
    return [int(stone) for stone in string.strip().split()]


def step(stones: Mapping[int, int]) -> defaultdict[int, int]:
    new_stones: defaultdict[int, int] = defaultdict(lambda: 0)

    for stone, count in stones.items():
        if stone == 0:
            new_stones[1] += count
        elif len(string := str(stone)) % 2 == 0:
            split_point = len(string) // 2
            new_stones[(int(string[split_point:]))] += count
            new_stones[(int(string[:split_point]))] += count
        else:
            new_stones[stone * 2024] += count

    return new_stones


def count_stones(stones: list[int], n: int) -> str:
    count_stones = Counter(stones)
    for _ in range(n):
        count_stones = step(count_stones)

    return str(sum(count_stones.values()))


solution = Solution(
    parse_input,
    functools.partial(count_stones, n=25),
    functools.partial(count_stones, n=75),
    day=11,
)
