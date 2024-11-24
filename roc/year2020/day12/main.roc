app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
}

import pf.Stdout
import pf.Path exposing [Path]

Direction : [North, South, East, West]
Action : [North, South, East, West, Left, Right, Forward]

parseInput : Str -> Result (List (Action, U32)) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.split "\n"
    |> List.mapTry parseRow

parseRow : Str -> Result (Action, U32) Str
parseRow = \str ->
    { before, others } = List.split (Str.toUtf8 str) 1
    amount =
        (Str.fromUtf8 others)
            |> Result.try Str.toU32
            |> Result.mapErr? \_ -> "Failed to parse number of $(str)"

    action =
        when before is
            ['N'] -> Ok North
            ['S'] -> Ok South
            ['E'] -> Ok East
            ['W'] -> Ok West
            ['L'] -> Ok Left
            ['R'] -> Ok Right
            ['F'] -> Ok Forward
            _ -> Err "invalid action $(Inspect.toStr (Str.fromUtf8 before))"

    Result.map action \act -> (act, amount)

remainder = \x1, x2 ->
    temp = x1 % x2
    if temp < 0 then
        temp + x2
    else
        temp

rotate90 : Direction -> Direction
rotate90 = \direction ->
    when direction is
        North -> East
        East -> South
        South -> West
        West -> North

rotate180 : Direction -> Direction
rotate180 = \direction -> rotate90 (rotate90 direction)

rotate270 : Direction -> Direction
rotate270 = \direction -> rotate90 (rotate180 direction)

step : ((I64, I64), Direction), (Action, U32) -> ((I64, I64), Direction)
step = \((x, y), facing), (action, amount) ->
    (direction, distance) =
        when action is
            Left ->
                nextDirection =
                    when remainder (-amount // 90) 4 is
                        0 -> facing
                        1 -> rotate90 facing
                        2 -> rotate180 facing
                        3 -> rotate270 facing
                        _ -> crash "garantied by remainder"
                (nextDirection, 0)

            Right ->
                nextDirection =
                    when remainder (amount // 90) 4 is
                        0 -> facing
                        1 -> rotate90 facing
                        2 -> rotate180 facing
                        3 -> rotate270 facing
                        _ -> crash "garantied by remainder"
                (nextDirection, 0)

            Forward -> (facing, 0)
            North -> (North, Num.toI64 amount)
            South -> (South, Num.toI64 amount)
            East -> (East, Num.toI64 amount)
            West -> (West, Num.toI64 amount)

    when direction is
        North -> ((x, y + distance), North)
        South -> ((x, y - distance), South)
        East -> ((x + distance, y), East)
        West -> ((x - distance, y), West)

calcAnswer1 : List (Action, U32) -> U64
calcAnswer1 = \instructions ->
    ((x, y), _direction) = List.walk instructions ((0, 0), North) step
    Num.toU64 (Num.abs x) + Num.toU64 (Num.abs y)

# calcAnswer2 : List (Action, U32) -> U64

main =
    input = readFileToStr! (Path.fromStr "../../../inputs/year2020/day12.txt")

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
    F10
    N3
    F7
    R90
    F11
    """

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer1

    value == Ok (25)

# expect
#     value =
#         testInput
#         |> parseInput
#         |> Result.map calcAnswer2

#     value == Ok (26)
