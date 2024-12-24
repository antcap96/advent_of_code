import functools

from year2024.utils.aoc import Solution
import networkx as nx

type Graph = dict[str, list[str]]


def parse_edge(line: str) -> tuple[str, str]:
    a, b = line.split("-")
    return a, b


def add_edge(graph: Graph, edge: tuple[str, str]) -> None:
    graph.setdefault(edge[0], []).append(edge[1])
    graph.setdefault(edge[1], []).append(edge[0])


def parse_input(string: str) -> Graph:
    lines = string.strip().splitlines()

    graph: dict[str, list[str]] = {}
    for line in lines:
        add_edge(graph, parse_edge(line))

    return graph


def clique3(graph: Graph, start: str) -> set[tuple[str, str, str]]:
    cliques = set()
    neighboors = graph[start]

    for neighboor in neighboors:
        for neighboor2 in (n for n in graph[neighboor] if n != start):
            if start in graph[neighboor2]:
                cliques.add(tuple(sorted([start, neighboor, neighboor2])))

    return cliques


def calculate_answer1(graph: Graph) -> str:
    cliques = functools.reduce(
        set.union, (clique3(graph, node) for node in graph if node.startswith("t"))
    )
    return str(len(cliques))


def calculate_answer2(graph: Graph) -> str:
    G = nx.Graph()
    for start, ends in graph.items():
        for end in ends:
            G.add_edge(start, end)

    cliques = nx.find_cliques(G)
    max_clique = max(cliques, key=len)
    return ",".join(sorted(max_clique))


solution = Solution(parse_input, calculate_answer1, calculate_answer2, day=23)
