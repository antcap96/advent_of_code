app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import pf.Stdout
import pf.Path exposing [Path]

Map : List (List [Tree, Open])

u8ToAscii : U8 -> Str
u8ToAscii = \bit ->
    when Str.fromUtf8 [bit] is
        Ok str -> str
        Err _ -> "\\x$(Num.toStr bit)"

parseInput : Str -> Result Map Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.split "\n"
    |> List.mapTry \row ->
        Str.toUtf8 row
        |> List.mapTry \elem ->
            when elem is
                '.' -> Ok Open
                '#' -> Ok Tree
                _ -> Err "invalid char '$(u8ToAscii elem)'"

rowGet : List [Tree, Open], U64 -> [Tree, Open]
rowGet = \row, index ->
    when List.get row (index % (List.len row)) is 
        Ok result -> result
        Err _ -> crash "impossible"

countTrees = \map, right, down ->
    List.walkWithIndex map 0 \state, row, index ->
        if (index % down == 0) && rowGet row (index * right // down) == Tree then
            state + 1
        else
            state

calcAnswer1 = \map -> 
    countTrees map 3 1


calcAnswer2 = \map ->
    slopes = [
        (1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
    
    List.map slopes \(right, down) ->
        countTrees map right down
    |> List.walk 1 \state, x -> state * x

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day3.txt")

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
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1
    value == Ok 7

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2
    value == Ok 336
