from __future__ import annotations
import itertools
from typing import Iterable

from year2024.utils.aoc import Solution


def parse_input(string: str) -> list[int]:
    return [int(c) for c in string.strip()]


def calculate_answer1(numbers: list[int]) -> int:
    length = sum(numbers)

    nums: list[int | None] = [None for i in range(length)]

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


class LinkedListItem[T]:
    def __init__(
        self,
        value: T,
        next: LinkedListItem[T] | None,
        prev: LinkedListItem[T] | None,
    ) -> None:
        self.next = next
        self.prev = prev
        self.value = value

    @staticmethod
    def from_iterable[U](
        items: Iterable[U],
    ) -> tuple[LinkedListItem[U], LinkedListItem[U]]:
        items_iter = iter(items)
        first = LinkedListItem(next(items_iter), None, None)
        last = first
        for item in items_iter:
            last = last.insert(item)

        return (first, last)

    def insert(self, value: T) -> LinkedListItem[T]:
        next = LinkedListItem(value, self.next, self)
        if self.next is not None:
            self.next.prev = next
        self.next = next

        return next

    def insert_before(self, value: T) -> LinkedListItem[T]:
        prev = LinkedListItem(value, next=self, prev=self.prev)
        if self.prev is not None:
            self.prev.next = prev
        self.prev = prev

        return prev

    def replace(self, value: T) -> LinkedListItem[T]:
        self.value = value

        return self

    def delete(self) -> None:
        if self.next is not None:
            self.next.prev = self.prev
        if self.prev is not None:
            self.prev.next = self.next


def count(id_and_count: list[tuple[int | None, int]]) -> int:
    def expand(x: tuple[int | None, int]) -> itertools.repeat[int | None]:
        return itertools.repeat(x[0], x[1])

    nums = enumerate(itertools.chain(*map(expand, id_and_count)))

    return sum(i * x for i, x in nums if x is not None)


def calculate_answer2(numbers: list[int]) -> int:

    thing = [(i // 2 if i % 2 == 0 else None, num) for i, num in enumerate(numbers)]

    j = len(numbers) - 1

    while j >= 0:
        print(j)
        thing2 = thing[j]
        if thing2[0] is None:
            j -= 1
            continue

        i = 0
        while i < j:
            if thing[i][0] is None and thing[i][1] >= thing2[1]:
                break

            i += 1

        if i < j:
            thing[i] = (None, thing[i][1] - thing2[1])
            thing[j] = (None, thing2[1])
            thing.insert(i, thing2)
            continue
        j -= 1

    print(thing)
    return count(thing)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=9)
