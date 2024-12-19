from year2024.day19 import solution

test_input1 = """
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input1)) == "6"


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input1)) == "16"
