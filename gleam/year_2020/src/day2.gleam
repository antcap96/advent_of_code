import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub type Policy {
  Policy(key: String, first: Int, second: Int)
}

pub type Entry {
  Entry(policy: Policy, password: String)
}

fn parse_policy(policy) {
  case policy |> string.split(" ") {
    [range, key] -> {
      case range |> string.split("-") {
        [first, second] -> {
          use first <- result.try(int.parse(first))
          use second <- result.try(int.parse(second))
          Ok(Policy(key, first, second))
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn parse_row(row) {
  case row |> string.split(": ") {
    [policy, password] -> {
      use policy <- result.try(parse_policy(policy))
      Ok(Entry(policy, password))
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

    let a = list_get(leters, entry.policy.first)
    let b = list_get(leters, entry.policy.second)
    case a, b {
      Some(y), Some(x) if y == entry.policy.key && x == entry.policy.key ->
        False
      Some(y), _ if y == entry.policy.key -> True
      _, Some(x) if x == entry.policy.key -> True
      _, _ -> False
    }
  })
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
  let assert Ok(contents) = simplifile.read("../../inputs/2020/day2.txt")

  let assert Ok(entries) = parse_inputs(contents)

  io.println("Answer1: " <> int.to_string(answer1(entries)))
  io.println("Answer2: " <> int.to_string(answer2(entries)))
}
