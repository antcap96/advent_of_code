app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path

import adventOfCode.Matrix exposing [Matrix]
import adventOfCode.HeapQueue exposing [HeapQueue]

Cell : [Floor, Obstruction]
Direction : [North, East, South, West]
State : { at : (U64, U64), direction : Direction }
Data : { maze : Matrix Cell, start : (U64, U64), target : (U64, U64) }

parse_input : Str -> Result Data Str
parse_input = |str|
    matrix =
        Str.trim_end(str)
        |> Str.split_on("\n")
        |> List.map(Str.to_utf8)
        |> Matrix.from_list_of_list
        |> try(Result.map_err, |_| "Inconsistent row size")

    maze = matrix |> Matrix.map(|c| if c == '#' then Obstruction else Floor)

    start =
        (Matrix.find_first_index(matrix, |c| c == 'S'))
        |> try(Result.map_err, |_| "Could not find inital position")

    target =
        (Matrix.find_first_index(matrix, |c| c == 'E'))
        |> try(Result.map_err, |_| "Could not find target")

    Ok({ maze, start, target })

right : Direction -> Direction
right = |dir|
    when dir is
        North -> East
        East -> South
        South -> West
        West -> North

left : Direction -> Direction
left = |dir|
    when dir is
        East -> North
        South -> East
        West -> South
        North -> West

next_position : (U64, U64), Direction -> (U64, U64)
next_position = |(i, j), direction|
    when direction is
        North -> (Num.sub_wrap(i, 1), j)
        East -> (i, Num.add_wrap(j, 1))
        South -> (Num.add_wrap(i, 1), j)
        West -> (i, Num.sub_wrap(j, 1))

disjktra_step :
    {
        queue : HeapQueue { at : (U64, U64), direction : Direction, cost : U64 },
        visited : Set State,
        maze : Matrix Cell,
        finish : (U64, U64),
    }
    -> U64
disjktra_step = |{ queue, visited, maze, finish }|
    (new_queue, maybe_item) = HeapQueue.pop(queue)
    when maybe_item is
        Err(HeapEmpty) -> Num.max_u64
        Ok(item) ->
            if Set.contains(visited, { at: item.at, direction: item.direction }) then
                disjktra_step({ queue: new_queue, visited, maze, finish })
            else if item.at == finish then
                item.cost
            else
                new_set = Set.insert(visited, { at: item.at, direction: item.direction })

                queue2 =
                    [
                        { at: next_position(item.at, item.direction), cost: item.cost + 1, direction: item.direction },
                        { at: item.at, cost: item.cost + 1000, direction: left(item.direction) },
                        { at: item.at, cost: item.cost + 1000, direction: right(item.direction) },
                    ]
                    |> List.walk(
                        new_queue,
                        |state, entry|
                            (i, j) = entry.at
                            if Matrix.get(maze, i, j) == Ok(Floor) then
                                HeapQueue.insert(state, entry)
                            else
                                state,
                    )

                disjktra_step({ queue: queue2, visited: new_set, maze, finish })

disjktra :
    {
        maze : Matrix Cell,
        start : (U64, U64),
        finish : (U64, U64),
    }
    -> U64
disjktra = |{ maze, start, finish }|
    ordering = |{ cost: cost1 }, { cost: cost2 }| Num.compare(cost1, cost2)
    queue = HeapQueue.empty(ordering)
    visited = Set.empty({})

    queue1 = HeapQueue.insert(queue, { cost: 0, at: start, direction: East })
    disjktra_step({ queue: queue1, visited, maze, finish })

calc_answer1 : Data -> U64
calc_answer1 = |data|
    disjktra({ maze: data.maze, start: data.start, finish: data.target })

final_step = |visited_from, finish|
    x = Set.union(
        final_step_aux(visited_from, { at: finish, direction: North }),
        final_step_aux(visited_from, { at: finish, direction: East }),
    )

    x |> Set.map(.at)

final_step_aux : Dict State (List State), State -> Set State
final_step_aux = |visited_from, state|
    Dict.get(visited_from, state)
    |> Result.with_default([])
    |> List.walk(
        Set.from_list([state]),
        |set, elem|
            if Set.contains(set, elem) then
                set
            else
                Set.union(set, final_step_aux(visited_from, elem)),
    )

disjktra_step2 :
    {
        queue : HeapQueue { at : (U64, U64), direction : Direction, cost : U64, from : State },
        visited_from : Dict State (List State),
        costs : Dict State U64,
        maze : Matrix Cell,
        finish : (U64, U64),
        final_cost : Result U64 [Unknown],
    }
    -> U64
disjktra_step2 = |{ queue, costs, visited_from, maze, finish, final_cost }|
    (new_queue, maybe_item) = HeapQueue.pop(queue)

    when maybe_item is
        Err(_) -> Num.max_u64
        Ok(item) ->
            if (Result.map_ok(final_cost, |c| item.cost > c)) |> Result.with_default(Bool.false) then
                Set.len(final_step(visited_from, finish))
            else if
                (
                    Dict.get(costs, { at: item.at, direction: item.direction })
                    |> Result.map_ok(|c| item.cost > c)
                )
                |> Result.with_default(Bool.false)
            then
                disjktra_step2({ queue: new_queue, visited_from, costs, maze, finish, final_cost })
            else
                new_final_cost =
                    if item.at == finish and Result.is_err(final_cost) then
                        Ok(item.cost)
                    else
                        final_cost

                state_pair = { at: item.at, direction: item.direction }
                new_visited_from =
                    Dict.insert(
                        visited_from,
                        state_pair,
                        (
                            Dict.get(visited_from, state_pair)
                            |> Result.with_default([])
                            |> List.append(item.from)
                        ),
                    )

                new_costs = Dict.insert(costs, state_pair, item.cost)

                queue2 =
                    [
                        { from: state_pair, at: next_position(item.at, item.direction), cost: item.cost + 1, direction: item.direction },
                        { from: state_pair, at: item.at, cost: item.cost + 1000, direction: left(item.direction) },
                        { from: state_pair, at: item.at, cost: item.cost + 1000, direction: right(item.direction) },
                    ]
                    |> List.walk(
                        new_queue,
                        |state, entry|
                            (i, j) = entry.at
                            if Matrix.get(maze, i, j) == Ok(Floor) then
                                HeapQueue.insert(state, entry)
                            else
                                state,
                    )

                disjktra_step2({ queue: queue2, costs: new_costs, visited_from: new_visited_from, maze, finish, final_cost: new_final_cost })

disjktra2 :
    {
        maze : Matrix Cell,
        start : (U64, U64),
        finish : (U64, U64),
    }
    -> U64
disjktra2 = |{ maze, start, finish }|
    ordering = |{ cost: cost1 }, { cost: cost2 }| Num.compare(cost1, cost2)
    queue = HeapQueue.empty(ordering)
    costs = Dict.empty({})
    visited_from = Dict.empty({})

    queue1 = HeapQueue.insert(queue, { cost: 0, at: start, direction: East, from: { at: start, direction: East } })
    disjktra_step2({ queue: queue1, visited_from, costs, maze, finish, final_cost: Err(Unknown) })

calc_answer2 : Data -> U64
calc_answer2 = |data|
    disjktra2({ maze: data.maze, start: data.start, finish: data.target })

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2024/day16/input.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input1 =
    """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

test_input2 =
    """
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """

expect
    value =
        test_input1
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(7036)

expect
    value =
        test_input2
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(11048)

expect
    value =
        test_input1
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(45)
expect
    value =
        test_input2
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(64)
