import gleeunit
import gleam/int
import gleam/io
import gleam/iterator
import gleam/order
import gleam/pair
import gleam/result
import gleam/string
import gleeunit/should
import matrix

pub fn main() {
  gleeunit.main()
}

const sample_text = "
1 2 3 4
5 6 7 8
9 10 11 12
"

pub fn generate_from_string_test() {
  let m =
    sample_text
    |> matrix.from_string
    |> matrix.to_string

  let expected = string.trim_left("
[1 2 3 4]
[5 6 7 8]
[9 10 11 12]
")

  should.equal(m, expected)
}

pub fn set_at_value_test() {
  let m =
    sample_text
    |> matrix.from_string
    |> matrix.set(#(0, 0), "0")
    |> matrix.set(#(1, 1), "0")
    |> matrix.set(#(2, 2), "0")
    |> matrix.to_string

  let expected = string.trim_left("
[0 2 3 4]
[5 0 7 8]
[9 10 0 12]
")

  should.equal(m, expected)
}

pub fn iterating_should_modify_values_test() {
  let mapped =
    sample_text
    |> matrix.from_string
    |> matrix.to_iterator
    |> iterator.map(fn(tup) { pair.map_second(tup, int.parse) })
    |> iterator.map(fn(tup) { pair.map_second(tup, result.unwrap(_, 0)) })
    |> iterator.map(fn(tup) { pair.map_second(tup, fn(v) { v * 2 }) })
    |> matrix.from_iterator
    |> matrix.to_string

  let expected = string.trim_left("
[2 4 6 8]
[10 12 14 16]
[18 20 22 24]
")

  should.equal(mapped, expected)
}
