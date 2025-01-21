app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path
import adventOfCode.Point2D exposing [Point2D]

Direction : [North, South, East, West]
Action : [North, South, East, West, Left, Right, Forward]
Position : Point2D (Integer Signed64)
State1 : (Position, Direction)
State2 : { ship : Position, waypoint : Position }

parse_input : Str -> Result (List (Action, U32)) Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_row)

parse_row : Str -> Result (Action, U32) Str
parse_row = |str|
    { before, others } = List.split_at(Str.to_utf8(str), 1)
    amount =
        (Str.from_utf8(others))
        |> Result.try(Str.to_u32)
        |> Result.map_err?(|_| "Failed to parse number of ${str}")

    action =
        # Matching on the list was crashing the compiler, so I'm converting it to a
        # string first
        when Str.from_utf8(before) is
            Ok("N") -> Ok(North)
            Ok("S") -> Ok(South)
            Ok("E") -> Ok(East)
            Ok("W") -> Ok(West)
            Ok("L") -> Ok(Left)
            Ok("R") -> Ok(Right)
            Ok("F") -> Ok(Forward)
            _ -> Err("invalid action ${Inspect.to_str(Str.from_utf8(before))}")

    Result.map_ok(action, |act| (act, amount))

rotate90 : Direction -> Direction
rotate90 = |direction|
    when direction is
        North -> East
        East -> South
        South -> West
        West -> North

rotate180 : Direction -> Direction
rotate180 = |direction| rotate90(rotate90(direction))

rotate270 : Direction -> Direction
rotate270 = |direction| rotate90(rotate180(direction))

rotate : Direction, Int * -> Direction
rotate = |facing, amount|
    when amount is
        1 -> rotate90(facing)
        2 -> rotate180(facing)
        3 -> rotate270(facing)
        _ -> facing

move : Position, Direction, I64 -> Position
move = |(x, y), direction, distance|
    when direction is
        North -> (x, y + distance)
        South -> (x, y - distance)
        East -> (x + distance, y)
        West -> (x - distance, y)

step1 : State1, (Action, U32) -> State1
step1 = |state, (action, amount)|
    (position, facing) = state

    next_position =
        when action is
            Forward -> move(position, facing, Num.to_i64(amount))
            North -> move(position, North, Num.to_i64(amount))
            East -> move(position, East, Num.to_i64(amount))
            South -> move(position, South, Num.to_i64(amount))
            West -> move(position, West, Num.to_i64(amount))
            Left -> position
            Right -> position

    next_facing =
        when action is
            Left -> rotate(facing, (4 - (amount // 90)))
            Right -> rotate(facing, (amount // 90))
            Forward -> facing
            North -> facing
            East -> facing
            South -> facing
            West -> facing

    (next_position, next_facing)

calc_answer1 : List (Action, U32) -> I64
calc_answer1 = |instructions|
    (pos, _direction) = List.walk(instructions, ((0, 0), East), step1)
    Point2D.modulo(pos)

step2 : State2, (Action, U32) -> State2
step2 = |{ ship, waypoint }, (action, amount)|
    when action is
        Left -> { ship, waypoint: Point2D.rotate_around_origin(waypoint, (4 - (amount // 90))) }
        Right -> { ship, waypoint: Point2D.rotate_around_origin(waypoint, (amount // 90)) }
        North -> { ship, waypoint: move(waypoint, North, Num.to_i64(amount)) }
        East -> { ship, waypoint: move(waypoint, East, Num.to_i64(amount)) }
        South -> { ship, waypoint: move(waypoint, South, Num.to_i64(amount)) }
        West -> { ship, waypoint: move(waypoint, West, Num.to_i64(amount)) }
        Forward -> { ship: Point2D.add(ship, Point2D.mul(waypoint, Num.to_i64(amount))), waypoint }

calc_answer2 : List (Action, U32) -> I64
calc_answer2 = |instructions|
    { ship } = List.walk(instructions, { ship: (0, 0), waypoint: (10, 1) }, step2)
    Point2D.modulo(ship)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day12.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    F10
    N3
    F7
    R90
    F11
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(25)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(286)
