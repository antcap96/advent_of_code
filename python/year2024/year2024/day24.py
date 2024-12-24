from __future__ import annotations

from dataclasses import dataclass
from functools import cache
from typing import Literal

from year2024.utils.aoc import Solution

type Op = Literal["AND", "OR", "XOR"]


@dataclass
class Gate:
    input1: str
    input2: str
    op: Op

    def __eq__(self, other: object) -> bool:
        if isinstance(other, Gate):
            if self.op == other.op:
                if (self.input1 == other.input1 and self.input2 == other.input2) or (
                    self.input1 == other.input2 and self.input2 == other.input1
                ):
                    return True
            return False
        return NotImplemented


@dataclass(frozen=True)
class Data:
    start_values: dict[str, bool]
    connections: dict[str, Gate]

    def __hash__(self) -> int:
        return id(self)


def parse_start_values(string: str) -> dict[str, bool]:
    def parse_line(string: str) -> tuple[str, bool]:
        wire, state = string.split(": ")
        return (wire, state == "1")

    return dict(map(parse_line, string.splitlines()))


def parse_connections(string: str) -> dict[str, Gate]:
    def parse_line(string: str) -> tuple[str, Gate]:
        gate_str, wire = string.split(" -> ")
        input1, op, input2 = gate_str.split()
        assert op in ("OR", "AND", "XOR")
        return (wire, Gate(input1, input2, op))

    return dict(map(parse_line, string.splitlines()))


def parse_input(string: str) -> Data:
    start_values_str, connections_str = string.strip().split("\n\n")

    return Data(
        start_values=parse_start_values(start_values_str),
        connections=parse_connections(connections_str),
    )


@cache
def evaluate_wire(wire: str, data: Data) -> bool:
    if wire in data.start_values:
        return data.start_values[wire]
    gate = data.connections[wire]

    match gate.op:
        case "AND":
            return evaluate_wire(gate.input1, data) and evaluate_wire(gate.input2, data)
        case "OR":
            return evaluate_wire(gate.input1, data) or evaluate_wire(gate.input2, data)
        case "XOR":
            return evaluate_wire(gate.input1, data) ^ evaluate_wire(gate.input2, data)


def calculate_answer1(data: Data) -> str:
    outputs: dict[str, bool] = {}
    for wire in data.connections:
        if wire.startswith("z"):
            outputs[wire] = evaluate_wire(wire, data)

    num = sum(
        2 ** int(wire.removeprefix("z")) for wire, state in outputs.items() if state
    )

    return str(num)


seen = set()


def print_tree(wire: str, data: Data) -> None:
    if wire in data.start_values:
        return
    gate = data.connections[wire]
    if wire not in seen:
        print(f"{wire}: {gate}")
    seen.add(wire)
    if gate.input2 in data.connections:
        a = data.connections[gate.input2].input1
        b = data.connections[gate.input2].input1
        if (a.startswith("x") or a.startswith("y")) and (
            b.startswith("x") or b.startswith("y")
        ):
            print_tree(gate.input2, data)
            print_tree(gate.input1, data)
        else:
            print_tree(gate.input1, data)
            print_tree(gate.input2, data)
    else:
        print_tree(gate.input1, data)
        print_tree(gate.input2, data)


def is_base(wire: str) -> bool:
    return wire.startswith("x") or wire.startswith("y")


def identify_and_xor(data: Data) -> dict[str, str]:
    output: dict[str, str] = {}
    for wire, gate in data.connections.items():
        if is_base(gate.input1) and is_base(gate.input2):
            num = gate.input1.removeprefix("x").removeprefix("y")
            match gate.op:
                case "AND":
                    output[wire] = f"and_{num}"
                case "XOR":
                    output[wire] = f"xor_{num}"
                case "OR":
                    raise ValueError("Should not exits")

    return output


@dataclass
class Tree:
    name: str
    left: Tree | str
    right: Tree | str
    op: Op


def correct_tree(size: int) -> dict[str, Tree]:
    @cache
    def xor(i: int) -> Tree:
        return Tree(f"xor{i:02}", f"x{i:02}", f"y{i:02}", "XOR")

    @cache
    def and_(i: int) -> Tree:
        return Tree(f"and{i:02}", f"x{i:02}", f"y{i:02}", "AND")

    @cache
    def carry(i: int) -> Tree:
        if i == 1:
            return and_(i - 1)
        else:
            return Tree(f"carry{i:02}", temp(i - 1), and_(i - 1), "OR")

    @cache
    def temp(i: int) -> Tree:
        return Tree(f"carry{i:02}", xor(i), carry(i), "AND")

    @cache
    def z(i: int) -> Tree:
        if i == 0:
            return xor(i)
        return Tree(f"z{i:02}", xor(i), carry(i), "XOR")

    nodes = {f"z{size:02}": carry(size)}
    for i in range(size):
        nodes[f"z{i:02}"] = z(i)

    return nodes


def matches(data: Data, key: str, tree: Tree | str) -> tuple[str, Tree | str] | None:
    if isinstance(tree, str):
        if key == tree:
            return None
        else:
            return (key, tree)
    if key in data.start_values:
        return (key, tree)

    gate = data.connections[key]
    if gate.op != tree.op:
        return (key, tree)

    a = matches(data, gate.input1, tree.left)
    b = matches(data, gate.input1, tree.right)
    c = matches(data, gate.input2, tree.left)
    d = matches(data, gate.input2, tree.right)
    if a is not None and b is not None:
        if a[0] == gate.input1:
            return b
        else:
            return a
    elif c is not None and d is not None:
        if c[0] == gate.input2:
            return d
        else:
            return c
    else:
        return None


def calculate_answer2(data: Data) -> str:
    size = max(
        int(x.removeprefix("z")) for x in data.connections.keys() if x.startswith("z")
    )
    initial_connections = data.connections

    mapping = correct_tree(size)
    for i in range(size + 1):
        x = matches(data, f"z{i:02}", mapping[f"z{i:02}"])
        if x is not None:
            print(x[0])
            for key in data.connections:
                if matches(data, key, x[1]) is None:
                    break
            else:
                assert False
            cons = data.connections.copy()
            print(x[0], key)
            cons[x[0]], cons[key] = cons[key], cons[x[0]]
            data = Data(data.start_values, cons)

    difs = []
    for a in initial_connections:
        if initial_connections[a] != data.connections[a]:
            difs.append(a)

    return ",".join(sorted(difs))

    # print(uses)
    # Z_a = xor_a XOR carry_a
    # xor_a = x_a XOR y_a
    # carry_a = temp_(a-1) OR and_(a-1)
    # temp_a = xor_a AND carry_a
    # and_a = x_a AND y_a

    # carry_0 = False
    # temp_0 = False

    # indentified = identify_and_xor(data)

    # z = sorted([wire for wire in data.connections if wire.startswith("z")])
    # for wire in z:
    #     print(wire)
    #     print_tree(wire, data)


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=24)
