app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}

import pf.Stdout
import pf.Path

Instruction : [
    Acc I64,
    Jmp I64,
    Nop I64,
]

State : { acc : I64, ip : U64 }
starting_state : State
starting_state = { acc: 0, ip: 0 }

parse_input : Str -> Result (List Instruction) Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_row)

parse_row = |str|
    when Str.split_on(str, " ") is
        [op, amount_str] ->
            amount = Str.to_i64(amount_str) |> Result.map_err?(|_| "Invalid number '${amount_str}'")
            when op is
                "acc" -> Ok(Acc(amount))
                "jmp" -> Ok(Jmp(amount))
                "nop" -> Ok(Nop(amount))
                _ -> Err("Invalid op '${op}'")

        _ -> Err("Invalid row '${str}")

calc_answer1 = |instructions|
    final_state = run(instructions, starting_state, Set.empty({}))
    final_state.acc

run : List Instruction, State, Set U64 -> State
run = |instructions, state, seen|
    new_state = step(instructions, state)
    new_seen = Set.insert(seen, state.ip)
    if
        Set.contains(seen, new_state.ip)
        or new_state.ip
        == List.len(instructions)
    then
        new_state
    else
        run(instructions, new_state, new_seen)

step : List Instruction, State -> State
step = |instructions, state|
    when List.get(instructions, state.ip) is
        Err(OutOfBounds) -> crash("invalid index ${Num.to_str(state.ip)}")
        Ok(instruction) ->
            when instruction is
                Acc(amount) ->
                    {
                        ip: state.ip + 1,
                        acc: state.acc + amount,
                    }

                Jmp(amount) ->
                    {
                        ip: Num.add_wrap(state.ip, Num.to_u64(amount)),
                        acc: state.acc,
                    }

                Nop(_) ->
                    {
                        ip: state.ip + 1,
                        acc: state.acc,
                    }

calc_answer2 = |instructions|
    List.walk_with_index_until(
        instructions,
        0,
        |_, to_change, index|
            { list: new_instructions } = List.replace(instructions, index, swap_instruction(to_change))
            final_state = run(new_instructions, starting_state, Set.empty({}))
            if final_state.ip == List.len(instructions) then
                Break(final_state.acc)
            else
                Continue(0),
    )

swap_instruction = |instruction|
    when instruction is
        Nop(amount) -> Jmp(amount)
        Jmp(amount) -> Nop(amount)
        op -> op

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day8.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(5)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(8)
