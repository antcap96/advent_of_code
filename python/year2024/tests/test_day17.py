from year2024.day17 import solution

test_input1 = """
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"""


def test_answer1():
    assert solution.calculate_answer1(solution.parse_input(test_input1)) == 4635635210


def test_answer1_extra1():
    vm = solution.parse_input(
        """
Register A: 0
Register B: 0
Register C: 9

Program: 2,6"""
    )
    vm.run()
    assert vm.registers["B"] == 1


def test_answer1_extra2():
    vm = solution.parse_input(
        """
Register A: 10
Register B: 0
Register C: 0

Program: 5,0,5,1,5,4"""
    )
    vm.run()
    assert vm.out == [0, 1, 2]


def test_answer1_extra3():
    vm = solution.parse_input(
        """
Register A: 2024
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"""
    )
    vm.run()
    assert vm.out == [4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0]
    assert vm.registers["A"] == 0


def test_answer1_extra5():
    vm = solution.parse_input(
        """
Register A: 0
Register B: 29
Register C: 0

Program: 1,7"""
    )
    vm.run()
    assert vm.registers["B"] == 26


def test_answer1_extra6():
    vm = solution.parse_input(
        """
Register A: 0
Register B: 2024
Register C: 43690

Program: 4,0"""
    )
    vm.run()
    assert vm.registers["B"] == 44354


# def test_answer2():
#     assert solution.calculate_answer2(solution.parse_input(test_input1)) == 45
