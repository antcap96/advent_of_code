import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub type Cell {
  Open
  Tree
}

pub fn parse_row(str: String) -> Result(List(Cell), String) {
  str
  |> string.to_graphemes
  |> list.map(fn(char) {
    case char {
      "." -> Ok(Open)
      "#" -> Ok(Tree)
      _ -> Error("Invalid character '{char}'")
    }
  })
  |> result.all
}

pub fn parse_inputs(str: String) -> Result(List(List(Cell)), String) {
  str
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_row)
  |> result.all
}

pub fn answer1(entries: List(List(Cell))) {
  todo
}

pub fn answer2(entries: List(Entry)) {
  todo
}

fn list_get(lst, index) {
  case lst {
    [first, ..rest] ->
      case index {
        1 -> Some(first)
        _ -> list_get(rest, index - 1)
      }
    _ -> None
  }
}

pub fn main() {
  let assert Ok(contents) = simplifile.read("../../inputs/2020/day3.txt")

  let assert Ok(entries) = parse_inputs(contents)

  io.println("Answer1: " <> int.to_string(answer1(entries)))
  io.println("Answer2: " <> int.to_string(answer2(entries)))
}
