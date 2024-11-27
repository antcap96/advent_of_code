app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
}

import pf.Stdout
import pf.Path exposing [Path]

Data : { timestamp : U64, buses : List [X, Id U64] }

parseInput : Str -> Result Data Str
parseInput = \str ->
    lines =
        str
        |> Str.trimEnd
        |> Str.splitOn "\n"

    when lines is
        [timestampStr, busesStr] ->
            timestamp =
                Str.toU64 timestampStr
                    |> Result.mapErr? \_ -> "Failed to parse as number $(timestampStr)"

            buses =
                List.mapTry?
                    (Str.splitOn busesStr ",")
                    parseBusId

            Ok { timestamp, buses }

        _ -> Err "Expected 2 lines, got $(Num.toStr (List.len lines))"

parseBusId : Str -> Result [X, Id U64] Str
parseBusId = \elem ->
    when elem is
        "x" -> Ok X
        _ ->
            Str.toU64 elem
            |> Result.map Id
            |> Result.mapErr \_ -> "Failed to parse as number $(elem)"

minutesUntilNextBus = \timestamp, id ->
    if (timestamp % id) == 0 then
        0
    else
        id - (timestamp % id)

calcAnswer1 : Data -> U64
calcAnswer1 = \data ->
    result = List.walk data.buses { id: 0, minutes: Num.maxU64 } \state, elem ->
        when elem is
            X -> state
            Id id ->
                minutes = minutesUntilNextBus data.timestamp id
                if minutes <= state.minutes then
                    { id, minutes }
                else
                    state

    result |> \{ id, minutes } -> id * minutes

gcd = \a, b ->
    if b != 0 then
        gcd b (a % b)
    else
        a

newMinNumber = \{ minNumber, id, repeatingRate, idx } ->
    if minutesUntilNextBus minNumber id == (idx % id) then
        minNumber
    else
        newMinNumber {
            minNumber: (minNumber + repeatingRate),
            id,
            repeatingRate,
            idx,
        }

calcAnswer2 : Data -> U64
calcAnswer2 = \{ buses } ->
    List.walkWithIndex
        buses
        { minNumber: 0, repeatingRate: 1 }
        \state, elem, idx ->
            when elem is
                X -> state
                Id id ->
                    delta = gcd id state.repeatingRate
                    repeatingRate = state.repeatingRate * (id // delta)
                    
                    minNumber = newMinNumber {
                        minNumber: state.minNumber,
                        id,
                        repeatingRate: state.repeatingRate,
                        idx,
                    }
                    { minNumber, repeatingRate }
    |> .minNumber

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day13.txt")

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
    939
    7,13,x,x,59,x,31,19
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (295)

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (1068781)

expect
    value =
        "17,x,13,19"
        |> Str.withPrefix "1\n" # this gets ignored
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (3417)

expect
    value =
        "67,7,59,61"
        |> Str.withPrefix "1\n" # this gets ignored
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (754018)

expect
    value =
        "67,x,7,59,61"
        |> Str.withPrefix "1\n" # this gets ignored
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (779210)

expect
    value =
        "67,7,x,59,61"
        |> Str.withPrefix "1\n" # this gets ignored
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (1261476)

expect
    value =
        "1789,37,47,1889"
        |> Str.withPrefix "1\n" # this gets ignored
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (1202161486)
