from year2024.day14 import calculate_answer1, calculate_answer2, parse_input

test_input = """
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-31
"""


def test_answer1():
    assert calculate_answer1(parse_input(test_input), (11, 7)) == 12


def test_answer2():
    assert calculate_answer2(parse_input(test_input), (11, 7)) == 12
