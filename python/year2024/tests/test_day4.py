from year2024.day4 import solution

test_input = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == 18


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == 9
