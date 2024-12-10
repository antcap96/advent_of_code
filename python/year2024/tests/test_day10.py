from year2024.day10 import solution

test_input = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == 36


def test_answer2():
    assert solution.calculate_answer2(solution.parse_input(test_input)) == 81
