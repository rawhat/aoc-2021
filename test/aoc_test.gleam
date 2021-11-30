import gleeunit
import gleam/io
import gleam/order
import gleam/string
import matrix

pub external fn should_equal(a, a) -> Nil =
  "gleam_stdlib" "should_equal"

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

  should_equal(m, expected)
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

  should_equal(m, expected)
}
