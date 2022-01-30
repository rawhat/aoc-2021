import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam_array
import gleeunit/should

pub fn should_contain(actual: List(a), expected: List(a)) -> Nil {
  expected
  |> list.each(fn(exp) {
    actual
    |> list.contains(exp)
    |> should.be_true
  })

  Nil
}

pub external fn read_file(name: String) -> Result(String, String) =
  "file" "read_file"

pub fn read_lines(file_path: String) -> Result(List(String), String) {
  file_path
  |> read_file
  |> result.map(fn(contents) {
    contents
    |> string.trim
    |> string.split(on: "\n")
  })
}

pub external fn time_function(func: fn() -> Nil) -> #(Int, Nil) =
  "timer" "tc"

pub fn runtime_in_microseconds(func: fn() -> Nil) -> Int {
  func
  |> time_function
  |> pair.first
}
