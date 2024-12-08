import functools
from collections import defaultdict
from dataclasses import dataclass
from typing import Iterator

from year2024.utils.aoc import Solution

type OrderingRules = defaultdict[int, set[int]]


@dataclass
class Data:
    ordering_rules: OrderingRules
    update_pages: list[list[int]]


def ordering_rules_as_dict(
    rules: Iterator[tuple[int, int]],
) -> OrderingRules:
    output: OrderingRules = defaultdict(set)

    for before, after in rules:
        output[before].add(after)

    return output


def parse_ordering_rules(string: str) -> OrderingRules:
    def parse_row(row: str) -> tuple[int, int]:
        a, b = row.split("|")
        return (int(a), int(b))

    return ordering_rules_as_dict(map(parse_row, string.splitlines()))


def parse_update_pages(string: str) -> list[list[int]]:
    def parse_row(row: str) -> list[int]:
        numbers = row.split(",")
        return [int(x) for x in numbers]

    return list(map(parse_row, string.splitlines()))


def parse_input(string: str) -> Data:
    ordering_rules_str, update_pages_str = string.strip().split("\n\n")

    return Data(
        parse_ordering_rules(ordering_rules_str),
        parse_update_pages(update_pages_str),
    )


def is_sorted(rules: OrderingRules, row: list[int]) -> bool:
    pages = set(row)

    for page in reversed(row):
        pages.remove(page)
        if any(before in pages for before in rules[page]):
            return False

    return True


def calculate_answer1(data: Data) -> int:
    total = 0
    for pages in filter(
        functools.partial(is_sorted, data.ordering_rules),
        data.update_pages,
    ):
        total += pages[len(pages) // 2]

    return total


def total_ordering_rules(rules: OrderingRules) -> dict[int, set[int]]:
    output: dict[int, set[int]] = {}

    for page in rules:
        children(output, rules, page)

    return output


def children(output: dict[int, set[int]], rules: OrderingRules, page: int) -> set[int]:
    if page in output:
        return output[page]
    child_pages = rules[page]
    for child_page in child_pages.copy():
        child_pages.union(children(output, rules, child_page))

    output[page] = child_pages
    return child_pages


def filter_ordering_rules(rules: OrderingRules, pages: list[int]) -> OrderingRules:
    return defaultdict(
        set,
        {
            key: value.intersection(pages)
            for key, value in rules.items()
            if key in pages
        },
    )


def order_pages(rules: OrderingRules, pages: list[int]) -> list[int]:
    relevant_ordering_rules = total_ordering_rules(filter_ordering_rules(rules, pages))

    return sorted(pages, key=lambda x: len(relevant_ordering_rules[x]))


def calculate_answer2(data: Data) -> int:
    total = 0
    for pages in filter(
        lambda x: not is_sorted(data.ordering_rules, x),
        data.update_pages,
    ):
        total += order_pages(data.ordering_rules, pages)[len(pages) // 2]

    return total


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=5)


if __name__ == "__main__":
    solution.solve(None)
