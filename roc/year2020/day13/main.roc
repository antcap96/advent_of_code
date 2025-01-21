app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path

Data : { timestamp : U64, buses : List [X, Id U64] }

parse_input : Str -> Result Data Str
parse_input = |str|
    lines =
        str
        |> Str.trim_end
        |> Str.split_on("\n")

    when lines is
        [timestamp_str, buses_str] ->
            timestamp =
                Str.to_u64(timestamp_str)
                |> Result.map_err?(|_| "Failed to parse as number ${timestamp_str}")

            buses =
                List.map_try(
                    Str.split_on(buses_str, ","),
                    parse_bus_id,
                )?

            Ok({ timestamp, buses })

        _ -> Err("Expected 2 lines, got ${Num.to_str(List.len(lines))}")

parse_bus_id : Str -> Result [X, Id U64] Str
parse_bus_id = |elem|
    when elem is
        "x" -> Ok(X)
        _ ->
            Str.to_u64(elem)
            |> Result.map_ok(Id)
            |> Result.map_err(|_| "Failed to parse as number ${elem}")

minutes_until_next_bus = |timestamp, id|
    if (timestamp % id) == 0 then
        0
    else
        id - (timestamp % id)

calc_answer1 : Data -> U64
calc_answer1 = |data|
    result = List.walk(
        data.buses,
        { id: 0, minutes: Num.max_u64 },
        |state, elem|
            when elem is
                X -> state
                Id(id) ->
                    minutes = minutes_until_next_bus(data.timestamp, id)
                    if minutes <= state.minutes then
                        { id, minutes }
                    else
                        state,
    )

    result |> |{ id, minutes }| id * minutes

gcd = |a, b|
    if b != 0 then
        gcd(b, (a % b))
    else
        a

new_min_number = |{ min_number, id, repeating_rate, idx }|
    if minutes_until_next_bus(min_number, id) == (idx % id) then
        min_number
    else
        new_min_number(
            {
                min_number: (min_number + repeating_rate),
                id,
                repeating_rate,
                idx,
            },
        )

calc_answer2 : Data -> U64
calc_answer2 = |{ buses }|
    List.walk_with_index(
        buses,
        { min_number: 0, repeating_rate: 1 },
        |state, elem, idx|
            when elem is
                X -> state
                Id(id) ->
                    delta = gcd(id, state.repeating_rate)
                    repeating_rate = state.repeating_rate * (id // delta)

                    min_number = new_min_number(
                        {
                            min_number: state.min_number,
                            id,
                            repeating_rate: state.repeating_rate,
                            idx,
                        },
                    )
                    { min_number, repeating_rate },
    )
    |> .min_number

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day13.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    939
    7,13,x,x,59,x,31,19
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(295)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(1068781)

expect
    value =
        "17,x,13,19"
        |> Str.with_prefix("1\n") # this gets ignored
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(3417)

expect
    value =
        "67,7,59,61"
        |> Str.with_prefix("1\n") # this gets ignored
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(754018)

expect
    value =
        "67,x,7,59,61"
        |> Str.with_prefix("1\n") # this gets ignored
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(779210)

expect
    value =
        "67,7,x,59,61"
        |> Str.with_prefix("1\n") # this gets ignored
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(1261476)

expect
    value =
        "1789,37,47,1889"
        |> Str.with_prefix("1\n") # this gets ignored
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(1202161486)
