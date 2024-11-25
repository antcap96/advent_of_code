app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

parseGroup : Str -> List (Set U8)
parseGroup = \str ->
    str
    |> Str.splitOn "\n"
    |> List.map \row -> Str.toUtf8 row |> Set.fromList

parseInput : Str -> List (List (Set U8))
parseInput = \str ->
    str |> Str.trimEnd |> Str.splitOn "\n\n" |> List.map parseGroup

setUnionCardinality : List (Set U8) -> U64
setUnionCardinality = \group ->
    group
    |> List.walk (Set.empty {}) \state, elem ->
        Set.union state elem
    |> Set.len

calcAnswer1 : List (List (Set U8)) -> U64
calcAnswer1 = \groups ->
    groups
    |> List.map setUnionCardinality
    |> List.sum

setIntersectionCardinality : List (Set U8) -> U64
setIntersectionCardinality = \group ->
    group
    |> List.walk None \state, elem ->
        when state is
            None -> Some elem
            Some inAll -> Some (Set.intersection inAll elem)
    |> \result ->
        when result is
            None -> 0
            Some set -> Set.len set

calcAnswer2 : List (List (Set U8)) -> U64
calcAnswer2 = \groups ->
    groups
    |> List.map setIntersectionCardinality
    |> List.sum

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day6.txt")

    parsed = parseInput input

    answer1 = calcAnswer1 parsed
    answer2 = calcAnswer2 parsed

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
    value = parseInput testInput |> calcAnswer1

    value == 11

expect
    value = parseInput testInput |> calcAnswer2

    value == 6
