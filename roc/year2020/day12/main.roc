app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path exposing [Path]
import adventOfCode.Point2D exposing [Point2D]

Direction : [North, South, East, West]
Action : [North, South, East, West, Left, Right, Forward]
Position : Point2D (Integer Signed64)
State1 : (Position, Direction)
State2 : { ship : Position, waypoint : Position }

parseInput : Str -> Result (List (Action, U32)) Str
parseInput = \str ->
    str
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.mapTry parseRow

parseRow : Str -> Result (Action, U32) Str
parseRow = \str ->
    { before, others } = List.splitAt (Str.toUtf8 str) 1
    amount =
        (Str.fromUtf8 others)
            |> Result.try Str.toU32
            |> Result.mapErr? \_ -> "Failed to parse number of $(str)"

    action =
        # Matching on the list was crashing the compiler, so I'm converting it to a
        # string first
        when Str.fromUtf8 before is
            Ok "N" -> Ok North
            Ok "S" -> Ok South
            Ok "E" -> Ok East
            Ok "W" -> Ok West
            Ok "L" -> Ok Left
            Ok "R" -> Ok Right
            Ok "F" -> Ok Forward
            _ -> Err "invalid action $(Inspect.toStr (Str.fromUtf8 before))"

    Result.map action \act -> (act, amount)

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

rotate : Direction, Int * -> Direction
rotate = \facing, amount ->
    when amount is
        1 -> rotate90 facing
        2 -> rotate180 facing
        3 -> rotate270 facing
        _ -> facing

move : Position, Direction, I64 -> Position
move = \(x, y), direction, distance ->
    when direction is
        North -> (x, y + distance)
        South -> (x, y - distance)
        East -> (x + distance, y)
        West -> (x - distance, y)

step1 : State1, (Action, U32) -> State1
step1 = \state, (action, amount) ->
    (position, facing) = state

    nextPosition =
        when action is
            Forward -> move position facing (Num.toI64 amount)
            North -> move position North (Num.toI64 amount)
            East -> move position East (Num.toI64 amount)
            South -> move position South (Num.toI64 amount)
            West -> move position West (Num.toI64 amount)
            Left -> position
            Right -> position

    nextFacing =
        when action is
            Left -> rotate facing (4 - (amount // 90))
            Right -> rotate facing (amount // 90)
            Forward -> facing
            North -> facing
            East -> facing
            South -> facing
            West -> facing

    (nextPosition, nextFacing)

calcAnswer1 : List (Action, U32) -> I64
calcAnswer1 = \instructions ->
    (pos, _direction) = List.walk instructions ((0, 0), East) step1
    Point2D.modulo pos

step2 : State2, (Action, U32) -> State2
step2 = \{ ship, waypoint }, (action, amount) ->
    when action is
        Left -> { ship, waypoint: Point2D.rotateAroundOrigin waypoint (4 - (amount // 90)) }
        Right -> { ship, waypoint: Point2D.rotateAroundOrigin waypoint (amount // 90) }
        North -> { ship, waypoint: move waypoint North (Num.toI64 amount) }
        East -> { ship, waypoint: move waypoint East (Num.toI64 amount) }
        South -> { ship, waypoint: move waypoint South (Num.toI64 amount) }
        West -> { ship, waypoint: move waypoint West (Num.toI64 amount) }
        Forward -> { ship: Point2D.add ship (Point2D.mul waypoint (Num.toI64 amount)), waypoint }

calcAnswer2 : List (Action, U32) -> I64
calcAnswer2 = \instructions ->
    { ship } = List.walk instructions { ship: (0, 0), waypoint: (10, 1) } step2
    Point2D.modulo ship

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

expect
    value =
        testInput
        |> parseInput
        |> Result.map calcAnswer2

    value == Ok (286)
