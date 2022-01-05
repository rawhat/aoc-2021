import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import util.{read_lines}

pub fn validate_and_pop(
  char: String,
  stack: List(String),
) -> Result(List(String), String) {
  case char, stack {
    _, [] -> Ok([char])
    ")", ["(", ..rest] | "]", ["[", ..rest] | "}", ["{", ..rest] | ">", [
      "<",
      ..rest
    ] -> Ok(rest)
    ")", _ | "]", _ | "}", _ | ">", _ -> Error(char)
    _, _ -> Ok([char, ..stack])
  }
}

pub fn validate_line(
  values: List(String),
  stack: List(String),
) -> Result(List(String), String) {
  case values {
    [] -> Ok(stack)
    [next, ..rest] ->
      case validate_and_pop(next, stack) {
        Ok(new_stack) -> validate_line(rest, new_stack)
        Error(failing_char) -> Error(failing_char)
      }
  }
}

pub fn parse_line(line: String) -> Result(List(String), String) {
  line
  |> string.to_graphemes
  |> validate_line([])
}

pub fn part_one() {
  assert Ok(lines) = read_lines("./src/days/ten.txt")

  lines
  |> list.map(parse_line)
  |> list.filter_map(fn(res) {
    case res {
      Ok(_) -> Error(Nil)
      Error(failing_char) -> Ok(failing_char)
    }
  })
  |> list.map(fn(char) {
    case char {
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    }
  })
  |> list.fold(0, fn(a, b) { a + b })
  |> io.debug

  Nil
}

pub fn complete_line(
  stack: List(String),
  to_complete: List(String),
) -> List(String) {
  case stack {
    [] -> list.reverse(to_complete)
    ["(", ..rest] -> complete_line(rest, [")", ..to_complete])
    ["{", ..rest] -> complete_line(rest, ["}", ..to_complete])
    ["[", ..rest] -> complete_line(rest, ["]", ..to_complete])
    ["<", ..rest] -> complete_line(rest, [">", ..to_complete])
  }
}

pub fn score_line(line: List(String), score: Int) -> Int {
  case line {
    [] -> score
    [")", ..rest] -> score_line(rest, score * 5 + 1)
    ["]", ..rest] -> score_line(rest, score * 5 + 2)
    ["}", ..rest] -> score_line(rest, score * 5 + 3)
    [">", ..rest] -> score_line(rest, score * 5 + 4)
  }
}

pub fn part_two() {
  assert Ok(lines) = read_lines("./src/days/ten.txt")

  let scores =
    lines
    |> list.map(parse_line)
    |> list.filter_map(fn(x) { x })
    |> list.map(complete_line(_, []))
    |> list.map(score_line(_, 0))
    |> list.sort(int.compare)

  scores
  |> list.at(list.length(scores) / 2)
  |> io.debug

  Nil
}
