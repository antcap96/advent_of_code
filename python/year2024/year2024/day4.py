import re

from year2024.utils.aoc import Solution


def parse_input(string: str) -> list[str]:
    return string.strip().splitlines()


def iterate_0(data: list[str]) -> list[str]:
    return data


def iterate_45(data: list[str]) -> list[str]:
    cols = len(data)
    rows = len(data[0])

    output: list[str] = []
    for i in range(cols + rows):
        # j ∈ [0, cols)
        #
        # i - j ∈ [0, rows)
        # = -j  ∈ [-i, rows - i)
        # =  j  ∈ (i - rows, i]
        # =  j  ∈ [i - rows + 1, i + 1)
        #
        # j ∈ [0, cols) ∩ [i - rows + 1, i + 1)
        j_range = range(max(0, i - rows + 1), min(cols, i + 1))
        output.append("".join([data[i - j][j] for j in j_range]))

    return output


def iterate_270(data: list[str]) -> list[str]:
    cols = len(data)
    rows = len(data[0])

    output: list[str] = []
    for i in range(cols):
        output.append("".join([data[j][i] for j in range(rows)]))

    return output


def iterate_315(data: list[str]) -> list[str]:
    cols = len(data)
    rows = len(data[0])

    output: list[str] = []
    for i in range(rows - 1, -cols, -1):
        # j ∈ [0, cols)
        #
        # i + j ∈ [0, rows)
        # j     ∈ [-i, rows -i)
        #
        # j ∈ [0, cols) ∩ [-i, rows - i)
        j_range = range(max(0, -i), min(cols, rows - i))
        output.append("".join([data[i + j][j] for j in j_range]))

    return output


def count_occurrences(haystack: str, needle: str) -> int:
    return len(re.findall(needle, haystack))


def calculate_answer1(data: list[str]) -> int:
    iter_functions = [
        iterate_0,
        iterate_45,
        iterate_270,
        iterate_315,
    ]

    count = 0
    for iter_func in iter_functions:
        count += sum(count_occurrences(line, "XMAS") for line in iter_func(data))
        count += sum(count_occurrences(line, "SAMX") for line in iter_func(data))

    return count


def contains_MAS(s1: str, s2: str, s3: str) -> bool:
    string = f"{s1}{s2}{s3}"
    return string == "MAS" or string == "SAM"


def calculate_answer2(data: list[str]) -> int:
    rows = len(data)
    cols = len(data[0])

    count = 0
    for i in range(rows - 2):
        for j in range(cols - 2):
            if (
                # Both diagonals contain MAS or SAM
                contains_MAS(data[i][j], data[i + 1][j + 1], data[i + 2][j + 2])
                and contains_MAS(data[i][j + 2], data[i + 1][j + 1], data[i + 2][j])
            ):
                count += 1

    return count


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=4)


if __name__ == "__main__":
    solution.solve(None)
