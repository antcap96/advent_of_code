import day3
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn answer1_test() {
  let input =
    "..##.......
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
"
  let assert Ok(contents) = day3.parse_inputs(input)

  day3.answer1(contents)
  |> should.equal(7)
}

pub fn answer2_test() {
  let input =
    "..##.......
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
"
  let assert Ok(contents) = day3.parse_inputs(input)

  day3.answer2(contents)
  |> should.equal(336)
}
