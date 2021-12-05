import gleam/list
import gleam/result
import gleam/string
import gleam_array

pub external fn should_equal(a, a) -> Nil =
  "gleam_stdlib" "should_equal"

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
