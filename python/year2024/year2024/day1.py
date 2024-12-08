from collections import Counter

from year2024.utils.aoc import Solution

type Data = list[tuple[int, int]]


def parse_input(string: str) -> Data:
    rows = string.strip().splitlines()

    def parse_row(string: str) -> tuple[int, int]:
        a, b = filter(lambda x: len(x) > 0, string.split(" "))
        return int(a), int(b)

    return [parse_row(row) for row in rows]


def separate_list(data: Data) -> tuple[list[int], list[int]]:
    return (
        [x[0] for x in data],
        [x[1] for x in data],
    )


def calculate_answer1(data: Data) -> int:
    list1, list2 = separate_list(data)
    list1.sort()
    list2.sort()
    return sum(abs(el1 - el2) for el1, el2 in zip(list1, list2))


def calculate_answer2(data: Data) -> int:
    list1, list2 = separate_list(data)

    counter = Counter(list2)

    similarity_score = 0

    for elem in list1:
        similarity_score += elem * counter.get(elem, 0)

    return similarity_score


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=1)

if __name__ == "__main__":
    solution.solve(None)
