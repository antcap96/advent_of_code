from year2024.day2 import parse_input, calculate_answer1, calculate_answer2
from io import StringIO

test_input = StringIO("""
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
""")


def test_answer1():
    assert calculate_answer1(parse_input(test_input)) == 2


def test_answer2():
    assert calculate_answer2(parse_input(test_input)) == 4


def test_answer2_1():
    assert calculate_answer2(parse_input(StringIO("1 2 10 3 4"))) == 1


def test_answer2_2():
    assert calculate_answer2(parse_input(StringIO("4 3 10 2 1"))) == 1


def test_answer2_3():
    assert calculate_answer2(parse_input(StringIO("1 2 10 3 10"))) == 0


def test_answer2_4():
    assert calculate_answer2(parse_input(StringIO("4 3 10 2 10"))) == 0


def test_answer2_5():
    assert calculate_answer2(parse_input(StringIO("0 3 2 1 0"))) == 1


def test_answer2_6():
    assert calculate_answer2(parse_input(StringIO("4 3 2 1 10"))) == 1
