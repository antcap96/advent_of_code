from year2024.utils.aoc import Solution
from year2024.utils.matrix import Matrix


def parse_input(string: str) -> Matrix[int]:
    lines = string.strip().splitlines()
    return Matrix.from_list_of_list([[int(x) for x in line] for line in lines])


def count_nines(data: Matrix[int], start: tuple[int, int]) -> set[tuple[int, int]]:
    if data[start] == 9:
        return set([start])
    nines = set()

    i, j = start
    around = [
        (i - 1, j),
        (i + 1, j),
        (i, j - 1),
        (i, j + 1),
    ]
    for next in around:
        x = data.get(next)

        if x is not None and (x - data[start]) == 1:
            nines = nines.union(count_nines(data, next))

    return nines


def calculate_answer1(data: Matrix[int]) -> str:
    score = 0
    for i in range(data.rows):
        for j in range(data.cols):
            if data[i, j] != 0:
                continue

            score += len(count_nines(data, (i, j)))

    return str(score)


def count_ratings(data: Matrix[int], start: tuple[int, int]) -> int:
    if data[start] == 9:
        return 1
    nines = 0

    i, j = start
    around = [
        (i - 1, j),
        (i + 1, j),
        (i, j - 1),
        (i, j + 1),
    ]
    for next in around:
        x = data.get(next)

        if x is not None and (x - data[start]) == 1:
            nines += count_ratings(data, next)

    return nines


def calculate_answer2(data: Matrix[int]) -> str:
    score = 0
    for i in range(data.rows):
        for j in range(data.cols):
            if data[i, j] != 0:
                continue

            score += count_ratings(data, (i, j))

    return str(score)


solution = Solution(
    parse_input,
    calculate_answer1,
    calculate_answer2,
    day=10,
)
