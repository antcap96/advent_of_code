import day1
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn answer1_test() {
  let input =
    "1721
979
366
299
675
1456"
  let assert Ok(contents) = day1.parse_inputs(input)

  day1.answer1(contents)
  |> should.equal(514_579)
}

pub fn answer2_test() {
  let input =
    "1721
979
366
299
675
1456"
  let assert Ok(contents) = day1.parse_inputs(input)

  day1.answer2(contents)
  |> should.equal(241_861_950)
}
