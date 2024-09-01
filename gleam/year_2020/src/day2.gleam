import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Policy {
  Policy(key: String, first: Int, second: Int)
}

pub type Entry {
  Entry(policy: Policy, password: String)
}

fn parse_row(row) {
  case row |> string.split(": ") {
    [begin, password] -> {
      case begin |> string.split(" ") {
        [range, key] -> {
          case range |> string.split("-") {
            [first, second] -> {
              use first <- result.try(int.parse(first))
              use second <- result.try(int.parse(second))
              Ok(Entry(Policy(key, first, second), password))
            }
            _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn parse_inputs(str) {
  str
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_row)
  |> result.all
}

pub fn answer1(entries: List(Entry)) {
  entries
  |> list.count(fn(entry) {
    let leters = entry.password |> string.to_graphemes
    let count = leters |> list.count(fn(c) { c == entry.policy.key })
    { count >= entry.policy.first } && { count <= entry.policy.second }
  })
}

pub fn answer2(entries: List(Entry)) {
  entries
  |> list.count(fn(entry) {
    let leters = entry.password |> string.to_graphemes
    leters
    |> list.index_fold(False, fn(state, char, index) {
      case
        char == entry.policy.key
        && {
          { index + 1 } == entry.policy.first
          || { index + 1 } == entry.policy.second
        }
      {
        True -> !state
        False -> state
      }
    })
  })
}

pub fn main() {
  let assert Ok(contents) = simplifile.read("../../inputs/2020/day2.txt")

  let assert Ok(entries) = parse_inputs(contents)

  io.println("Answer1: " <> int.to_string(answer1(entries)))
  io.println("Answer2: " <> int.to_string(answer2(entries)))
}
