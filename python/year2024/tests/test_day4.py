from year2024.day4 import parse_input, calculate_answer1, calculate_answer2

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
    assert calculate_answer1(parse_input(test_input)) == 18


def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 9
