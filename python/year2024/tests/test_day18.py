from year2024.day18 import calculate_answer1, calculate_answer2, solution

test_input1 = """
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"""


def test_answer1():
    assert (
        calculate_answer1(solution.parse_input(test_input1), shape=(7, 7), bytes=12)
        == "22"
    )


def test_answer2():
    assert calculate_answer2(solution.parse_input(test_input1), shape=(7, 7)) == "6,1"
