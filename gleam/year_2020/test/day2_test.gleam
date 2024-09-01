import day2
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn answer1_test() {
  let input =
    "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc"
  let assert Ok(contents) = day2.parse_inputs(input)

  day2.answer1(contents)
  |> should.equal(2)
}

pub fn answer2_test() {
  let input =
    "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc"
  let assert Ok(contents) = day2.parse_inputs(input)

  day2.answer2(contents)
  |> should.equal(1)
}
