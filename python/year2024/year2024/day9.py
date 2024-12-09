from __future__ import annotations
from dataclasses import dataclass
import itertools

from year2024.utils.aoc import Solution


def parse_input(string: str) -> list[int]:
    return [int(c) for c in string.strip()]


def calculate_answer1(numbers: list[int]) -> int:
    length = sum(numbers)

    nums: list[int | None] = [None for _ in range(length)]

    at = 0
    for i, count in enumerate(numbers):
        if i % 2 == 0:
            for j in range(count):
                nums[at + j] = i // 2
        at += count

    i, j = 0, len(nums) - 1
    while j > i:
        if nums[i] is not None:
            i += 1
            continue
        if nums[j] is None:
            j -= 1
            continue

        nums[i], nums[j] = nums[j], nums[i]
    return sum(i * x for i, x in enumerate(nums) if x is not None)


def count(sections: list[Section]) -> int:
    def expand(x: Section) -> itertools.repeat[int | None]:
        return itertools.repeat(x.id_number, x.size)

    nums = enumerate(itertools.chain(*map(expand, sections)))

    return sum(i * x for i, x in nums if x is not None)


@dataclass
class Section:
    id_number: int | None
    size: int

    @staticmethod
    def empty():
        return Section(None, 0)


def expand_with_space(numbers: list[int]) -> list[Section]:
    output: list[Section] = []

    for i, number in enumerate(numbers):
        if i % 2 == 0:
            output.append(Section(i // 2, number))
        else:
            output.append(Section(None, number))
            output.extend([Section.empty()] * (number - 1))

    return output


def calculate_answer2(numbers: list[int]) -> int:
    nums = expand_with_space(numbers)

    min_idx: list[None | int] = [0] * 10

    current = len(nums) - 1
    while current >= 0:
        if nums[current].id_number is None:
            current -= 1
            continue

        i = min_idx[nums[current].size - 1]
        while (
            i is not None
            and i < current
            and not (nums[i].id_number is None and nums[i].size >= nums[current].size)
        ):
            i += 1

        if i is not None and i < current:
            delta = nums[i].size - nums[current].size
            if delta > 0:
                assert nums[i + 1] == Section.empty()
                nums[i + 1] = Section(None, delta)
            nums[i] = nums[current]
            nums[current] = Section(None, nums[current].size)
            for j in range(nums[current].size - 1, 10):
                existing = min_idx[j]
                min_idx[j] = existing if existing is None or existing > i else i
        else:
            for j in range(nums[current].size - 1, 10):
                min_idx[j] = None

        current -= 1

    return count(nums)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=9)
