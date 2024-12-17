from __future__ import annotations
import copy
from dataclasses import dataclass
from typing import Literal
from year2024.utils.aoc import Solution


class VM:
    def __init__(self, a: int, b: int, c: int, program: list[int]) -> None:
        self.registers: dict[Literal["A", "B", "C", "IP"], int] = {
            "A": a,
            "B": b,
            "C": c,
            "IP": 0,
        }
        self.program = program
        self.out: list[int] = []

    def run(self) -> None:
        while self.registers["IP"] < (len(self.program) - 1):
            instruction_class = instruction_of(self.program[self.registers["IP"]])
            instruction = instruction_class.with_operand(
                self.program[self.registers["IP"] + 1]
            )
            # print(
            #     self.registers,
            #     self.program[self.registers["IP"] : (self.registers["IP"] + 2)],
            #     instruction,
            # )
            instruction.apply(self)


class ComboOperand:
    def __init__(self, operand: int) -> None:
        self.operand = operand

    def get(self, vm: VM) -> int:
        match self.operand:
            case 0 | 1 | 2 | 3:
                return self.operand
            case 4:
                return vm.registers["A"]
            case 5:
                return vm.registers["B"]
            case 6:
                return vm.registers["C"]
            case _:
                raise ValueError(f"Invalid operand {self.operand}")

    def __repr__(self) -> str:
        match self.operand:
            case 0 | 1 | 2 | 3:
                return str(self.operand)
            case 4:
                return "rA"
            case 5:
                return "rB"
            case 6:
                return "rC"
            case _:
                raise ValueError(f"Invalid operand {self.operand}")


@dataclass
class Adv:
    operand: ComboOperand

    @staticmethod
    def with_operand(operand: int) -> Adv:
        return Adv(ComboOperand(operand))

    def apply(self, vm: VM) -> None:
        vm.registers["A"] = vm.registers["A"] // (2 ** self.operand.get(vm))
        vm.registers["IP"] += 2


@dataclass
class Bxl:
    operand: int

    @staticmethod
    def with_operand(operand: int) -> Bxl:
        return Bxl(operand)

    def apply(self, vm: VM) -> None:
        vm.registers["B"] ^= self.operand
        vm.registers["IP"] += 2


@dataclass
class Bst:
    operand: ComboOperand

    @staticmethod
    def with_operand(operand: int) -> Bst:
        return Bst(ComboOperand(operand))

    def apply(self, vm: VM) -> None:
        vm.registers["B"] = self.operand.get(vm) & 0x7
        vm.registers["IP"] += 2


@dataclass
class Jnz:
    operand: int

    @staticmethod
    def with_operand(operand: int) -> Jnz:
        return Jnz(operand)

    def apply(self, vm: VM) -> None:
        if vm.registers["A"] == 0:
            vm.registers["IP"] += 2
        else:
            vm.registers["IP"] = self.operand


@dataclass
class Bxc:
    operand: int

    @staticmethod
    def with_operand(operand: int) -> Bxc:
        return Bxc(operand)

    def apply(self, vm: VM) -> None:
        vm.registers["B"] ^= vm.registers["C"]
        vm.registers["IP"] += 2


@dataclass
class Out:
    operand: ComboOperand

    @staticmethod
    def with_operand(operand: int) -> Out:
        return Out(ComboOperand(operand))

    def apply(self, vm: VM) -> None:
        vm.out.append(self.operand.get(vm) & 0x7)
        vm.registers["IP"] += 2


@dataclass
class Bdv:
    operand: ComboOperand

    @staticmethod
    def with_operand(operand: int) -> Bdv:
        return Bdv(ComboOperand(operand))

    def apply(self, vm: VM) -> None:
        vm.registers["B"] = vm.registers["A"] // (2 ** self.operand.get(vm))
        vm.registers["IP"] += 2


@dataclass
class Cdv:
    operand: ComboOperand

    @staticmethod
    def with_operand(operand: int) -> Cdv:
        return Cdv(ComboOperand(operand))

    def apply(self, vm: VM) -> None:
        vm.registers["C"] = vm.registers["A"] // (2 ** self.operand.get(vm))
        vm.registers["IP"] += 2


def instruction_of(i: int):
    match i:
        case 0:
            return Adv
        case 1:
            return Bxl
        case 2:
            return Bst
        case 3:
            return Jnz
        case 4:
            return Bxc
        case 5:
            return Out
        case 6:
            return Bdv
        case 7:
            return Cdv
        case _:
            raise ValueError(f"invalid instruction {i}")


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


def calculate_answer1(vm: VM) -> int:
    vm = copy.deepcopy(vm)
    vm.run()
    return int("".join(map(str, vm.out)))


def sum_from_is(lst: list[int]) -> int:
    return (8 ** (len(lst) - 1)) + sum(x * 8**i for i, x in enumerate(lst))


def pattern(vm: VM, lst: list[int], i: int) -> list[int] | None:
    for j in range(8):
        lst_ = copy.copy(lst)
        lst_[i] = j
        num = sum_from_is(lst_)
        vm2 = copy.deepcopy(vm)
        vm2.registers["A"] = num
        vm2.run()

        if vm2.out[i] == vm2.program[i]:
            if i == 0:
                return lst_
            else:
                a = pattern(vm, lst_, i - 1)
                if a is not None:
                    return a


def calculate_answer2(vm: VM) -> int:
    result = pattern(vm, [0] * 16, 15)
    assert result is not None
    num = sum_from_is(result)
    return num


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=17)
