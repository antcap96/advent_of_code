app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

strToNum = \row -> Result.mapErr (Str.toI64 row) \_ -> InvalidRow row

parseInput : Str -> Result (Set I64) [InvalidRow Str]
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.split ("\n")
    |> List.mapTry strToNum
    |> Result.map Set.fromList

entriesProduct : Set I64, I64, I64 -> [Found I64, NotFound]
entriesProduct = \numbers, total, count ->
    if count == 1 then
        if Set.contains numbers total then
            Found total
        else
            NotFound
    else
        numbers
        |> Set.walkUntil NotFound \_, elem ->
            when entriesProduct numbers (total - elem) (count - 1) is
                Found num -> Break (Found (elem * num))
                NotFound -> Continue NotFound

calcAnswer1 : Set I64 -> Result I64 [NotFound]
calcAnswer1 = \numbers ->
    when entriesProduct numbers 2020 2 is
        Found num -> Ok num
        NotFound -> Err NotFound

calcAnswer2 : Set I64 -> Result I64 [NotFound]
calcAnswer2 = \numbers ->
    when entriesProduct numbers 2020 3 is
        Found num -> Ok num
        NotFound -> Err NotFound

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day1.txt")

    parsed = parseInput input

    answer1 = Result.try parsed calcAnswer1
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

# Tests

testInput =
    """
    1721
    979
    366
    299
    675
    1456
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.try calcAnswer1
    value == Ok 514_579

expect
    value =
        testInput
        |> parseInput
        |> Result.try calcAnswer2
    value == Ok 241_861_950

