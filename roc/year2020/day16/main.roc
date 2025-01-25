app [main!] {
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path
import adventOfCode.Matrix

Ticket : List U64
Range : List { start : U64, end : U64 }

Data : { fields : Dict Str Range, tickets : List Ticket, my_ticket : Ticket }

parse_range : Str -> Result Range _
parse_range = |str|
    Str.split_on(str, " or ")
    |> List.map_try(
        |elem|
            when Str.split_on(elem, "-") is
                [first, second] ->
                    start = Str.to_u64? first
                    end = Str.to_u64? second
                    Ok({ start, end })

                _ -> Err(InvalidRange(elem)),
    )

parse_field : Str -> Result (Str, Range) _
parse_field = |str|
    when Str.split_on(str, ": ") is
        [name, range_str] ->
            range = parse_range? range_str
            Ok((name, range))

        _ -> Err(InvalidField(str))

parse_fields : Str -> Result (Dict Str Range) _
parse_fields = |str|
    Str.split_on(str, "\n")
    |> List.map_try(parse_field)
    |> Result.map_ok(Dict.from_list)

parse_ticket : Str -> Result Ticket _
parse_ticket = |str|
    Str.split_on(str, ",")
    |> List.map_try(Str.to_u64)

parse_my_ticket : Str -> Result Ticket _
parse_my_ticket = |str|
    when Str.split_on(str, "\n") is
        ["your ticket:", ticket_str] ->
            parse_ticket ticket_str

        _ -> Err(InvalidMyTicket(str))

parse_nearby_tickets : Str -> Result (List Ticket) _
parse_nearby_tickets = |str|
    Str.split_on(str, "\n")
    |> List.drop_first(1)
    |> List.map_try(parse_ticket)

parse_input : Str -> Result Data _
parse_input = |str|
    chunks = str |> Str.trim_end |> Str.split_on("\n\n")
    when chunks is
        [first, second, third] ->
            fields = parse_fields? first
            my_ticket = parse_my_ticket? second
            tickets = parse_nearby_tickets? third
            Ok({ fields, my_ticket, tickets })

        _ -> Err(UnexpectedNumberOfChunks(List.len(chunks)))

contains : Range, U64 -> Bool
contains = |range, number|
    List.any(range, |{ start, end }| number >= start and number <= end)

calc_answer1 : Data -> U64
calc_answer1 = |{ fields, tickets }|
    List.join(tickets)
    |> List.keep_if(
        |elem|
            !List.any(
                Dict.values(fields),
                |range| contains(range, elem),
            ),
    )
    |> List.sum

is_ok = |fields, ticket|
    ticket
    |> List.all(
        |elem|
            List.any(
                Dict.values(fields),
                |range| contains(range, elem),
            ),
    )

calc_answer2 : Data -> Result U64 _
calc_answer2 = |{ fields, my_ticket, tickets }|
    names = Dict.keys(fields)
    matrix = Matrix.from_list_of_list(
        tickets |> List.keep_if(|ticket| is_ok(fields, ticket)),
    )?
    possible_names = Matrix.walk_cols(
        matrix,
        names,
        |state, elem|
            state
            |> List.keep_if(
                |field|
                    Dict.get(fields, field)
                    |> Result.map_ok(|range| contains(range, elem))
                    |> Result.with_default(Bool.false),
            ),
    )
    ordered_names = simplify(possible_names)?

    List.map2(ordered_names, my_ticket, |field, value| (field, value))
    |> List.walk(
        1,
        |state, (field, value)|
            if Str.starts_with(field, "departure") then
                state * value
            else
                state,
    )
    |> Ok

simplify : List (List Str) -> Result (List Str) _
simplify = |possible_names|
    start = List.map(possible_names, CanBe)
    simplify2(start)

simplify2 : List [CanBe (List Str), MustBe Str] -> Result (List Str) _
simplify2 = |options|
    single_option = List.keep_oks(
        options,
        |lst|
            when lst is
                CanBe([elem]) -> Ok(elem)
                _ -> Err({}),
    )
    if List.len(single_option) == 0 then
        return Err(UnableToSimplify)
    else
        {}

    next = List.map(
        options,
        |lst|
            when lst is
                CanBe([elem]) -> MustBe(elem)
                CanBe(elems) -> CanBe(elems |> List.drop_if(|elem| List.contains(single_option, elem)))
                MustBe(elem) -> MustBe(elem),
    )
    finish_or_simplify(next, 0, [])

finish_or_simplify : List [CanBe (List Str), MustBe Str], U64, List Str -> Result (List Str) _
finish_or_simplify = |next, i, output|
    when List.get(next, i) is
        Ok(CanBe([one])) -> finish_or_simplify(next, i + 1, List.append(output, one))
        Ok(MustBe(one)) -> finish_or_simplify(next, i + 1, List.append(output, one))
        Err(OutOfBounds) -> Ok(output)
        Ok(CanBe(_)) -> simplify2(next)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day16.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.try(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

expect
    result = parse_field "departure location: 37-594 or 615-952"
    result == Ok(("departure location", [{ start: 37, end: 594 }, { start: 615, end: 952 }]))
expect
    result = parse_fields(
        """
        departure location: 37-594 or 615-952
        departure station: 50-562 or 573-968
        """,
    )
    expected_list = [
        ("departure location", [{ start: 37, end: 594 }, { start: 615, end: 952 }]),
        ("departure station", [{ start: 50, end: 562 }, { start: 573, end: 968 }]),
    ]
    result == Ok(Dict.from_list(expected_list))

test_input =
    """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(71)
