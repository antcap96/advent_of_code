app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

Instruction : [
    Acc I64,
    Jmp I64,
    Nop I64,
]

State : { acc : I64, ip : U64 }
startingState : State
startingState = { acc: 0, ip: 0 }

parseInput : Str -> Result (List Instruction) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.mapTry parseRow

parseRow = \str ->
    when Str.splitOn str " " is
        [op, amountStr] ->
            amount = Str.toI64 amountStr |> Result.mapErr? \_ -> "Invalid number '$(amountStr)'"
            when op is
                "acc" -> Ok (Acc amount)
                "jmp" -> Ok (Jmp amount)
                "nop" -> Ok (Nop amount)
                _ -> Err "Invalid op '$(op)'"

        _ -> Err "Invalid row '$(str)"

calcAnswer1 = \instructions ->
    finalState = run instructions startingState (Set.empty {})
    finalState.acc

run : List Instruction, State, Set U64 -> State
run = \instructions, state, seen ->
    newState = step instructions state
    newSeen = Set.insert seen state.ip
    if
        Set.contains seen newState.ip
        || newState.ip
        == List.len instructions
    then
        newState
    else
        run instructions newState newSeen

step : List Instruction, State -> State
step = \instructions, state ->
    when List.get instructions state.ip is
        Err OutOfBounds -> crash "invalid index $(Num.toStr state.ip)"
        Ok instruction ->
            when instruction is
                Acc amount ->
                    {
                        ip: state.ip + 1,
                        acc: state.acc + amount,
                    }

                Jmp amount ->
                    {
                        ip: Num.addWrap state.ip (Num.toU64 amount),
                        acc: state.acc,
                    }

                Nop _ ->
                    {
                        ip: state.ip + 1,
                        acc: state.acc,
                    }

calcAnswer2 = \instructions ->
    List.walkWithIndexUntil instructions 0 \_, toChange, index ->
        { list: newInstructions } = List.replace instructions index (swapInstruction toChange)
        finalState = run newInstructions startingState (Set.empty {})
        if finalState.ip == List.len instructions then
            Break finalState.acc
        else
            Continue 0

swapInstruction = \instruction ->
    when instruction is
        Nop amount -> Jmp amount
        Jmp amount -> Nop amount
        op -> op

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day8.txt")

    parsed = parseInput input

    answer1 = Result.map parsed calcAnswer1
    answer2 = Result.map parsed calcAnswer2

    Stdout.line! "Answer1: $(Inspect.toStr answer1)"
    Stdout.line! "Answer2: $(Inspect.toStr answer2)"

readFileToStr : Path -> Task Str [ReadFileErr Str]
readFileToStr = \path ->
    path
    |> Path.readUtf8
    |> Task.mapErr # Make a nice error message
        \fileReadErr ->
            pathStr = Path.display path

            when fileReadErr is
                FileReadErr _ readErr ->
                    readErrStr = Inspect.toStr readErr
                    ReadFileErr "Failed to read file:\n\t$(pathStr)\nWith error:\n\t$(readErrStr)"

                FileReadUtf8Err _ _ ->
                    ReadFileErr "I could not read the file:\n\t$(pathStr)\nIt contains characters that are not valid UTF-8."

testInput =
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
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok 5

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok 8
