app [main!] {
    # pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br",
    pf: platform "/home/antonio-pc/Antonio/roc/basic-cli/platform/main.roc",
}
import pf.Stdout
import pf.Path

Map : List (List [Tree, Open])

u8_to_ascii : U8 -> Str
u8_to_ascii = |bit|
    when Str.from_utf8([bit]) is
        Ok(str) -> str
        Err(_) -> "\\x${Num.to_str(bit)}"

parse_input : Str -> Result Map Str
parse_input = |str|
    str
    |> Str.trim_end
    |> Str.split_on("\n")
    |> List.map_try(parse_row)

parse_row = |row|
    Str.to_utf8(row)
    |> List.map_try(
        |elem|
            when elem is
                '.' -> Ok(Open)
                '#' -> Ok(Tree)
                _ -> Err("invalid char '${u8_to_ascii(elem)}'"),
    )

row_get : List [Tree, Open], U64 -> [Tree, Open]
row_get = |row, index|
    when List.get(row, (index % (List.len(row)))) is
        Ok(result) -> result
        Err(_) -> crash("impossible")

count_trees = |map, right, down|
    List.walk_with_index(
        map,
        0,
        |state, row, index|
            if (index % down == 0) and row_get(row, (index * right // down)) == Tree then
                state + 1
            else
                state,
    )

calc_answer1 = |map|
    count_trees(map, 3, 1)

calc_answer2 = |map|
    slopes = [
        (1, 1),
        (3, 1),
        (5, 1),
        (7, 1),
        (1, 2),
    ]

    List.map(
        slopes,
        |(right, down)|
            count_trees(map, right, down),
    )
    |> List.walk(1, |state, x| state * x)

main! = |_args|
    input = Path.read_utf8!(Path.from_str("../../../inputs/year2020/day3.txt"))?

    parsed = parse_input(input)

    answer1 = Result.map_ok(parsed, calc_answer1)
    Stdout.line!("Answer1: ${Inspect.to_str(answer1)}")?

    answer2 = Result.map_ok(parsed, calc_answer2)
    Stdout.line!("Answer2: ${Inspect.to_str(answer2)}")

test_input =
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
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer1)
    value == Ok(7)

expect
    value =
        test_input
        |> parse_input
        |> Result.map_ok(calc_answer2)
    value == Ok(336)
