app [main!] {
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}

import pf.Stdout
import pf.Path

Memory : Dict U64 U64

parse_input : Str -> Result (List U64) _
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on(",")
    |> List.map_try(Str.to_u64)

unwrap = |result|
    when result is
        Ok ok -> ok
        Err _ -> crash "unwrap"

answer : List U64, U64 -> U64
answer = |numbers, stop_idx|
    last = List.last(numbers) |> unwrap
    size = List.len(numbers)
    numbers_without_last = List.drop_last(numbers, 1)
    memory = Dict.from_list(
        numbers_without_last |> List.map_with_index(|x, y| (x, y + 1)),
    )
    answer_aux({ stop_idx, idx: size, memory, previous: last })

answer_aux = |{ stop_idx, idx, memory, previous }|
    if idx == stop_idx then
        previous
    else
        after = next(idx, memory, previous)
        next_memory = memory |> Dict.insert(previous, idx)
        answer_aux({ stop_idx, idx: idx + 1, memory: next_memory, previous: after })

calc_answer1 : List U64 -> U64
calc_answer1 = |numbers|
    answer(numbers, 2020)

calc_answer2 : List U64 -> U64
calc_answer2 = |numbers|
    answer(numbers, 30000000)

next : U64, Memory, U64 -> U64
next = |turn, memory, previous|
    Dict.get(memory, previous)
    |> Result.map_ok(|idx| turn - idx)
    |> Result.with_default(0)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day15.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

expect
    value =
        "1,3,2"
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(1)
expect
    value =
        "2,1,3"
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(10)
expect
    value =
        "1,2,3"
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(27)
expect
    value =
        "2,3,1"
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(78)
expect
    value =
        "3,2,1"
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(438)
expect
    value =
        "3,1,2"
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(1836)
