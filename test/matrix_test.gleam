import gleam/function
import gleam/io
import gleam/iterator
import gleam/option
import matrix
import util.{should_equal}

pub fn it_should_parse_digit_map_test() {
  "123
456
789"
  |> matrix.from_digit_map
  |> matrix.to_digit_map(option.unwrap(_, "."))
  |> should_equal("123
456
789")
}

pub fn it_should_parse_character_map_test() {
  [#(#(0, 0), True), #(#(1, 1), True)]
  |> iterator.from_list
  |> matrix.from_iterator
  |> io.debug
  |> matrix.fill_holes(with: fn(_) { False })
  |> matrix.to_digit_map(fn(value) {
    case option.unwrap(value, False) {
      True -> "#"
      False -> "."
    }
  })
  |> should_equal("#.
.#")
}
