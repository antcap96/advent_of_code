app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path

import adventOfCode.Matrix exposing [Matrix]

Cell : [Floor, Obstruction]
Direction : [North, East, South, West]
State : { position : (U64, U64), direction : Direction }
Data : { map : Matrix Cell, start_position : (U64, U64) }

initial_position : Matrix U8 -> Result (U64, U64) Str
initial_position = |matrix|
    Matrix.walk_with_index_until(
        matrix,
        Err(NotFound),
        |_, elem, i, j|
            if elem == '^' then
                Break(Ok((i, j)))
            else
                Continue(Err(NotFound)),
    )
    |> Result.map_err(|_| "Could not find inital position")

parse_input : Str -> Result Data Str
parse_input = |str|
    matrix =
        Str.trim_end(str)
        |> Str.split_on("\n")
        |> List.map(Str.to_utf8)
        |> Matrix.from_list_of_list
        |> Result.map_err? |_| "Inconsistent row size"

    map = matrix |> Matrix.map(|c| if c == '#' then Obstruction else Floor)

    start_position = initial_position(matrix)?

    Ok({ map, start_position })

rotate : Direction -> Direction
rotate = |dir|
    when dir is
        North -> East
        East -> South
        South -> West
        West -> North

next_position : State -> (U64, U64)
next_position = |{ position: (i, j), direction }|
    when direction is
        North -> (Num.sub_wrap(i, 1), j)
        East -> (i, Num.add_wrap(j, 1))
        South -> (Num.add_wrap(i, 1), j)
        West -> (i, Num.sub_wrap(j, 1))

step : Matrix Cell, State -> [Next State, Exited]
step = |map, state|
    (i, j) = next_position(state)

    when Matrix.get(map, i, j) is
        Err(OutOfBounds) -> Exited
        Ok(Floor) -> Next({ state & position: (i, j) })
        Ok(Obstruction) -> Next({ state & direction: rotate(state.direction) })

run : Matrix Cell, State, Set State -> [Exited (Set State), Looping]
run = |map, state, visited|
    when step(map, state) is
        Exited -> Exited(visited)
        Next(new_state) ->
            if Set.contains(visited, new_state) then
                Looping
            else
                run(map, new_state, Set.insert(visited, new_state))

calc_answer1 : Data -> Result U64 Str
calc_answer1 = |data|
    state = { position: data.start_position, direction: North }

    when run(data.map, state, Set.from_list([state])) is
        Looping -> Err("looped in answer1")
        Exited(set) -> Set.map(set, .position) |> Set.len |> Ok

is_loop_with_obstacle : Matrix Cell, State, Set State -> Bool
is_loop_with_obstacle = |matrix, state, visited|
    (i, j) = next_position(state)
    { matrix: new_matrix } = Matrix.replace(matrix, i, j, Obstruction)

    when run(new_matrix, state, visited) is
        Looping -> Bool.true
        _ -> Bool.false

run2 :
    {
        matrix : Matrix Cell,
        state : State,
        visited : Set State,
        visited_position : Set (U64, U64),
        count : U64,
    }
    -> U64
run2 = |{ matrix, state: current_state, visited: current_visited, visited_position: current_visited_position, count: current_count }|
    when step(matrix, current_state) is
        Exited -> current_count
        Next(state) ->
            visited = Set.insert(current_visited, state)
            visited_position = Set.insert(current_visited_position, state.position)
            count = if
                Set.contains(current_visited_position, state.position)
                or !is_loop_with_obstacle(matrix, current_state, current_visited)
            then
                current_count
            else
                current_count + 1
            run2(
                {
                    matrix,
                    state,
                    visited,
                    visited_position,
                    count,
                },
            )

calc_answer2 : Data -> U64
calc_answer2 = |data|
    state = { position: data.start_position, direction: North }
    run2(
        {
            matrix: data.map,
            state,
            visited: Set.empty({}),
            visited_position: Set.empty({}),
            count: 0,
        },
    )

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2024/day6/input.txt"))?

    parsed = parse_input(input)

    answer1 = Result.try(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.try(calc_answer1)

    value == Ok(41)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(6)

