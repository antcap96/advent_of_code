app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
    adventOfCode: "../../package/main.roc",
}

import pf.Stdout
import pf.Path
import adventOfCode.Matrix exposing [Matrix]

Seat : [Floor, Empty, Occupied]

parse_input : Str -> Result (Matrix Seat) Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try?(parse_row)
    |> Matrix.from_list_of_list
    |> Result.map_err(|_| "Input isn't a square")

parse_row = |str|
    List.map_try(
        Str.to_utf8(str),
        |elem|
            when elem is
                '.' -> Ok(Floor)
                'L' -> Ok(Empty)
                '#' -> Ok(Occupied)
                _ -> Err("Invalid char '${Inspect.to_str(Str.from_utf8([elem]))}'"),
    )

count_ocuppied_around1 : Matrix Seat, U64, U64 -> U64
count_ocuppied_around1 = |matrix, row, col|
    around = [
        (Num.add_wrap(row, 1), Num.add_wrap(col, 1)),
        (Num.add_wrap(row, 1), col),
        (Num.add_wrap(row, 1), Num.sub_wrap(col, 1)),
        (row, Num.add_wrap(col, 1)),
        (row, Num.sub_wrap(col, 1)),
        (Num.sub_wrap(row, 1), Num.add_wrap(col, 1)),
        (Num.sub_wrap(row, 1), col),
        (Num.sub_wrap(row, 1), Num.sub_wrap(col, 1)),
    ]
    List.map(
        around,
        |(i, j)|
            when Matrix.get(matrix, i, j) is
                Ok(Occupied) -> 1
                _ -> 0,
    )
    |> List.sum

seat_rules1 = |state, adjacent_ocuppied|
    when state is
        Floor -> Floor
        Empty if adjacent_ocuppied == 0 -> Occupied
        Empty -> Empty
        Occupied if adjacent_ocuppied >= 4 -> Empty
        Occupied -> Occupied

step1 : Matrix Seat -> Matrix Seat
step1 = |matrix|
    Matrix.map_with_index(
        matrix,
        |elem, i, j|
            adjacent = count_ocuppied_around1(matrix, i, j)
            seat_rules1(elem, adjacent),
    )

run1 : Matrix Seat -> Matrix Seat
run1 = |matrix|
    new_matrix = step1(matrix)

    if matrix == new_matrix then
        matrix
    else
        run1(new_matrix)

calc_answer1 : Matrix Seat -> U64
calc_answer1 = |matrix|
    final_matrix = run1(matrix)
    Matrix.walk(
        final_matrix,
        0,
        |state, elem|
            if elem == Occupied then
                state + 1
            else
                state,
    )

is_ocupied_in_direction2 : Matrix Seat, (U64, U64), (U64, U64) -> Bool
is_ocupied_in_direction2 = |matrix, (at_i, at_j), (dir_i, dir_j)|
    next_i = Num.add_wrap(at_i, dir_i)
    next_j = Num.add_wrap(at_j, dir_j)
    when Matrix.get(matrix, next_i, next_j) is
        Ok(Occupied) -> Bool.true
        Ok(Floor) -> is_ocupied_in_direction2(matrix, (next_i, next_j), (dir_i, dir_j))
        _ -> Bool.false

count_ocuppied_around2 : Matrix Seat, U64, U64 -> U64
count_ocuppied_around2 = |matrix, row, col|
    around = [
        (1, 1),
        (1, 0),
        (1, Num.max_u64),
        (0, 1),
        (0, Num.max_u64),
        (Num.max_u64, 1),
        (Num.max_u64, 0),
        (Num.max_u64, Num.max_u64),
    ]
    List.count_if(
        around,
        |dir|
            is_ocupied_in_direction2(matrix, (row, col), dir),
    )

seat_rules2 = |state, adjacent_ocuppied|
    when state is
        Floor -> Floor
        Empty if adjacent_ocuppied == 0 -> Occupied
        Empty -> Empty
        Occupied if adjacent_ocuppied >= 5 -> Empty
        Occupied -> Occupied

step2 : Matrix Seat -> Matrix Seat
step2 = |matrix|
    Matrix.map_with_index(
        matrix,
        |elem, i, j|
            adjacent = count_ocuppied_around2(matrix, i, j)
            seat_rules2(elem, adjacent),
    )

run2 : Matrix Seat -> Matrix Seat
run2 = |matrix|
    new_matrix = step2(matrix)

    if matrix == new_matrix then
        matrix
    else
        run2(new_matrix)

calc_answer2 : Matrix Seat -> U64
calc_answer2 = |matrix|
    final_matrix = run2(matrix)
    Matrix.walk(
        final_matrix,
        0,
        |state, elem|
            if elem == Occupied then
                state + 1
            else
                state,
    )
main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day11.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
    """
    L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL
    """

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)

    value == Ok(37)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)

    value == Ok(26)
