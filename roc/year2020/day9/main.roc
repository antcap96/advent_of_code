app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

parseInput : Str -> Result (List U64) Str
parseInput = \str ->
    str |> Str.trimEnd
        |> Str.split "\n"
        |> List.mapTry parseRow

parseRow = \str ->
    Str.toU64 str |> Result.mapErr \_ -> "invalid number '$(str)'"

calcAnswer1 = \lst ->
    calcAnswer1Aux lst 25

calcAnswer1Aux = \lst, n ->
    List.sublist lst {start: n, len: (List.len lst) - n}
    |> List.walkWithIndexUntil 0 \_, elem, idx ->
            preamble = List.sublist lst {start :idx, len: n} |> Set.fromList

            when preambleContains preamble elem is
                Found -> Continue 0
                NotFound -> Break elem

preambleContains = \preamble, next ->
    Set.walkUntil preamble NotFound \_, elem ->
        if Set.contains preamble (Num.subWrap next elem) then
            Break Found
        else
            Continue NotFound


calcAnswer2 = \lst -> 
    calcAnswer2Aux lst 25

calcAnswer2Aux : List U64, U64 -> Result U64 Str
calcAnswer2Aux = \lst, n ->
    invalidNumber = calcAnswer1Aux lst n
    ans = List.walkUntil
        (List.range {start: At 0, end: Before (List.len lst)})
        NoSolution
        \_, start ->
            sublist = (List.sublist lst {start, len: (List.len lst)-start})
            (sum, min, max) = rangeSum sublist invalidNumber
            if sum == invalidNumber then
                Break (Solution (min, max))
            else
                Continue NoSolution
    when ans is
        Solution (finalMin, finalMax) -> Ok (finalMin + finalMax)
        NoSolution -> Err "failed to find solution"

rangeSum = \lst, maximum ->
    List.walkUntil
        lst
        (0, Num.maxU64, 0)
        \(total, min, max), elem ->
            newMin = Num.min min elem
            newMax = Num.max max elem
            nextTotal = total + elem
            if total + elem >= maximum then
                Break (nextTotal, newMin, newMax)
            else
                Continue (nextTotal, newMin, newMax)

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day9.txt")

    parsed = parseInput input

    answer1 = Result.map parsed calcAnswer1
    answer2 = Result.try parsed calcAnswer2

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
    35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map \lst -> calcAnswer1Aux lst 5 

    value == Ok 127

expect
    value =
        testInput
        |> parseInput
        |> Result.try \lst -> calcAnswer2Aux lst 5

    value == Ok 62
