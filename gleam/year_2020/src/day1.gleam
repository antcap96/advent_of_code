import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn parse_inputs(str) {
  str
  |> string.trim
  |> string.split("\n")
  |> list.map(int.parse)
  |> result.all
  |> result.map(set.from_list)
}

fn entries_product(numbers, total, count) {
  case count {
    1 ->
      case set.contains(numbers, total) {
        True -> Some(total)
        False -> None
      }
    _ -> {
      numbers
      |> set.map(fn(a) {
        entries_product(numbers, total - a, count - 1)
        |> option.map(fn(n) { a * n })
      })
      |> set.to_list
      |> option.values
      |> list.first
      |> option.from_result
    }
  }
}

pub fn answer1(numbers) {
  case entries_product(numbers, 2020, 2) {
    None -> panic as "found no pairs"
    Some(n) -> n
  }
}

pub fn answer2(numbers) {
  case entries_product(numbers, 2020, 3) {
    None -> panic as "found no triplets"
    Some(n) -> n
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read("../../inputs/2020/1/input.txt")

  let assert Ok(numbers) = parse_inputs(contents)

  io.println("Answer1: " <> int.to_string(answer1(numbers)))
  io.println("Answer2: " <> int.to_string(answer2(numbers)))
}
