from year2024.day13 import solution

test_input = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input)) == "480"


def test_answer2():
    assert (
        solution.calculate_answer2(solution.parse_input(test_input)) == "875318608908"
    )


def test_answer1_extra():
    assert solution.calculate_answer1(
        solution.parse_input(
            "Button A: X+3, Y+3\nButton B: X+5, Y+5\nPrize: X=13, Y=13"
        )
    ) == str(1 * 3 + 2 * 1)
    assert solution.calculate_answer1(
        solution.parse_input(
            "Button A: X+10, Y+10\nButton B: X+3, Y+3\nPrize: X=106, Y=106"
        )
    ) == str(10 * 3 + 2 * 1)
    assert solution.calculate_answer1(
        solution.parse_input(
            "Button A: X+7, Y+7\nButton B: X+3, Y+3\nPrize: X=17, Y=17"
        )
    ) == str(2 * 3 + 1 * 1)
    assert (
        solution.calculate_answer1(
            solution.parse_input(
                "Button A: X+7, Y+7\nButton B: X+3, Y+3\nPrize: X=10, Y=16"
            )
        )
        == "0"
    )
    assert (
        solution.calculate_answer1(
            solution.parse_input(
                "Button A: X+1, Y+1\nButton B: X+2, Y+2\nPrize: X=10, Y=16"
            )
        )
        == "0"
    )
