app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}
import pf.Stdout
import pf.Path

parse_group : Str -> List (Set U8)
parse_group = |str|
    str
    |> Str.split_on("\n")
    |> List.map(|row| Str.to_utf8(row) |> Set.from_list)

parse_input : Str -> List (List (Set U8))
parse_input = |str|
    str |> Str.trim_end |> Str.split_on("\n\n") |> List.map(parse_group)

set_union_cardinality : List (Set U8) -> U64
set_union_cardinality = |group|
    group
    |> List.walk(
        Set.empty({}),
        |state, elem|
            Set.union(state, elem),
    )
    |> Set.len

calc_answer1 : List (List (Set U8)) -> U64
calc_answer1 = |groups|
    groups
    |> List.map(set_union_cardinality)
    |> List.sum

set_intersection_cardinality : List (Set U8) -> U64
set_intersection_cardinality = |group|
    group
    |> List.walk(
        None,
        |state, elem|
            when state is
                None -> Some(elem)
                Some(in_all) -> Some(Set.intersection(in_all, elem)),
    )
    |> |result|
        when result is
            None -> 0
            Some(set) -> Set.len(set)

calc_answer2 : List (List (Set U8)) -> U64
calc_answer2 = |groups|
    groups
    |> List.map(set_intersection_cardinality)
    |> List.sum

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day6.txt"))?

    parsed = parse_input(input)

    answer1 = calc_answer1(parsed)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = calc_answer2(parsed)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    abc

    a
    b
    c

    ab
    ac

    a
    a
    a
    a

    b
    """

expect
    value = parse_input(test_input) |> calc_answer1

    value == 11

expect
    value = parse_input(test_input) |> calc_answer2

    value == 6
