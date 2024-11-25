app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

parseInput : Str -> Result (List U64) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.mapTry parseRow

parseRow = \str ->
    Str.toU64 str |> Result.mapErr \_ -> "invalid number '$(str)'"

calcAnswer1 = \lst ->
    { one: oneCount, three: threeCount } =
        List.sortAsc lst
        |> List.walk { one: 0, three: 0, prev: 0 } \{ one, three, prev }, elem ->
            if elem - prev == 1 then
                { one: one + 1, three, prev: elem }
            else if elem - prev == 3 then
                { one, three: three + 1, prev: elem }
            else
                { one, three, prev: elem }

    oneCount * (threeCount + 1)

calcAnswer2 : List U64 -> Result U64 Str
calcAnswer2 = \lst ->
    max = List.max lst |> Result.mapErr? \_ -> "empty list"
    (_, ans) = calcAnswer2Cache (Set.fromList lst |> Set.insert 0) (Dict.empty {}) 0 (max + 3)
    Ok ans

calcAnswer2Cache = \set, cache, elem, stop ->
    if elem == stop then
        (cache, 1)
    else if !(Set.contains set elem) then
        (cache, 0)
    else
        when Dict.get cache elem is
            Ok count -> (cache, count)
            Err KeyNotFound ->
                (cache1, possibilities1) = calcAnswer2Cache set cache (elem + 1) stop
                (cache2, possibilities2) = calcAnswer2Cache set cache1 (elem + 2) stop
                (cache3, possibilities3) = calcAnswer2Cache set cache2 (elem + 3) stop
                possibilities = possibilities1 + possibilities2 + possibilities3
                (cache3 |> Dict.insert elem possibilities, possibilities)

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day10.txt")

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
    16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4
    """

testInput2 =
    """
    28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (7 * 5)

expect
    value =
        testInput2
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (22 * 10)

expect
    value =
        testInput
        |> parseInput
        |> Result.try calcAnswer2

    value == Ok 8

expect
    value =
        testInput2
        |> parseInput
        |> Result.try calcAnswer2

    value == Ok 19208
