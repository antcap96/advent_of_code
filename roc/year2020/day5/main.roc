app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}
import pf.Stdout
import pf.Path

BoardingPass : { row : U64, col : U64 }

parse_row : List U8 -> Result U64 Str
parse_row = |lst|
    List.reverse(lst)
    |> List.map_with_index(|elem, index| (elem, index))
    |> List.walk_try(
        0,
        |state, (elem, index)|
            when elem is
                'B' -> Ok((state + (Num.pow_int(2, index))))
                'F' -> Ok(state)
                _ -> Err("invalid character in row '${Num.to_str(elem)}'"),
    )

parse_col : List U8 -> Result U64 Str
parse_col = |lst|
    List.reverse(lst)
    |> List.map_with_index(|elem, index| (elem, index))
    |> List.walk_try(
        0,
        |state, (elem, index)|
            when elem is
                'R' -> Ok((state + (Num.pow_int(2, index))))
                'L' -> Ok(state)
                _ -> Err("invalid character in row '${Num.to_str(elem)}'"),
    )

parse_boarding_pass : Str -> Result BoardingPass Str
parse_boarding_pass = |str|
    Str.to_utf8(str)
    |> List.split_at(7)
    |> |{ before, others }|
        row = parse_row(before)?
        col = parse_col(others)?
        Ok({ row, col })

parse_input : Str -> Result (List BoardingPass) Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_boarding_pass)

boarding_pass_id : BoardingPass -> U64
boarding_pass_id = |pass| pass.row * 8 + pass.col

calc_answer1 : List BoardingPass -> Result U64 Str
calc_answer1 = |lst|
    lst
    |> List.map(boarding_pass_id)
    |> List.max
    |> Result.map_err(|_| "List was empty")

calc_answer2 : List BoardingPass -> Result U64 Str
calc_answer2 = |lst|
    solutions =
        lst
        |> List.map(boarding_pass_id)
        |> List.walk(Dict.empty({}), add_new_seen)
        |> Dict.keep_if(|(_, state)| state == TwoNeighboors)
        |> Dict.to_list

    when solutions is
        [(solution, _)] -> Ok(solution)
        _ -> Err("Invalid number of solutions ${Inspect.to_str(solutions)}")

## Keep track of how many neighboors each boardingId has, or if the seat has been seen
## already
PossibleBoardingIds : Dict U64 [OneNeighboor, TwoNeighboors, Seen]
add_new_seen : PossibleBoardingIds, U64 -> PossibleBoardingIds
add_new_seen = |dict, board_id|
    neighboors = [board_id + 1, board_id - 1]

    neighboors
    |> List.walk(
        dict,
        |state, neighboor|
            when Dict.get(state, neighboor) is
                Err(KeyNotFound) -> state |> Dict.insert(neighboor, OneNeighboor)
                Ok(OneNeighboor) -> state |> Dict.insert(neighboor, TwoNeighboors)
                Ok(TwoNeighboors) -> crash("3 neighboors?")
                Ok(Seen) -> state,
    )
    |> Dict.insert(board_id, Seen)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day5.txt"))?

    parsed = parse_input(input)

    answer1 = Result.try(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.try(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

expect "BFFFBBFRRR" |> parse_boarding_pass == Ok({ row: 70, col: 7 })
expect "FFFBBBFRRR" |> parse_boarding_pass == Ok({ row: 14, col: 7 })
expect "BBFFBBFRLL" |> parse_boarding_pass == Ok({ row: 102, col: 4 })
