from __future__ import annotations

import copy

from year2024.utils.aoc import Solution


class VM:
    def __init__(self, a: int, b: int, c: int, program: list[int]) -> None:
        self.a = a
        self.b = b
        self.c = c
        self.ip = 0
        self.program = program
        self.output: list[int] = []

    def run(self) -> None:
        while self.ip < (len(self.program) - 1):
            self.step(
                self.program[self.ip],
                self.program[self.ip + 1],
            )
            self.ip += 2

    def combo_operand(self, operand: int) -> int:
        match operand:
            case 0 | 1 | 2 | 3:
                return operand
            case 4:
                return self.a
            case 5:
                return self.b
            case 6:
                return self.c
            case _:
                raise ValueError(f"Invalid operand {operand}")

    def adv(self, operand: int) -> None:
        self.a >>= self.combo_operand(operand)

    def bxl(self, operand: int) -> None:
        self.b ^= operand

    def bst(self, operand: int) -> None:
        self.b = self.combo_operand(operand) & 0x7

    def jnz(self, operand: int) -> None:
        if self.a != 0:
            self.ip = operand - 2

    def bxc(self, operand: int) -> None:
        self.b ^= self.c

    def out(self, operand: int) -> None:
        self.output.append(self.combo_operand(operand) & 0x7)

    def bdv(self, operand: int) -> None:
        self.b = self.a >> self.combo_operand(operand)

    def cdv(self, operand: int) -> None:
        self.c = self.a >> self.combo_operand(operand)

    def step(self, instruction: int, operand: int) -> None:
        match instruction:
            case 0:
                return self.adv(operand)
            case 1:
                return self.bxl(operand)
            case 2:
                return self.bst(operand)
            case 3:
                return self.jnz(operand)
            case 4:
                return self.bxc(operand)
            case 5:
                return self.out(operand)
            case 6:
                return self.bdv(operand)
            case 7:
                return self.cdv(operand)
            case _:
                raise ValueError(f"invalid instruction {instruction}")


def parse_register(name: str, string: str) -> int:
    return int(string.removeprefix(f"Register {name}: "))


def parse_program(string: str) -> list[int]:
    return [int(x) for x in string.removeprefix("Program: ").split(",")]


def parse_input(string: str) -> VM:
    regA, regB, regC, _, program = string.strip().splitlines()

    return VM(
        parse_register("A", regA),
        parse_register("B", regB),
        parse_register("C", regC),
        parse_program(program),
    )


def calculate_answer1(vm: VM) -> str:
    vm = copy.deepcopy(vm)
    vm.run()
    return ",".join(map(str, vm.output))


def pattern(vm: VM, num: int, i: int) -> int | None:
    for _ in range(8):
        vm2 = copy.deepcopy(vm)
        vm2.a = num
        vm2.run()

        if vm2.output[i] == vm2.program[i]:
            if i == 0:
                return num
            else:
                a = pattern(vm, num, i - 1)
                if a is not None:
                    return a
        num += 8**i


def calculate_answer2(vm: VM) -> str:
    n = len(vm.program) - 1
    num = pattern(vm, 8**n, n)
    assert num is not None
    return str(num)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=17)
