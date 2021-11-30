import gleam/dynamic
import gleam/io
import gleam/list
import gleam/option.{Option, Some}
import gleam/result
import gleam/string
import gleam/string_builder
import gleam_array.{Array}

pub type Matrix(a) {
  Matrix(Array(Array(a)))
}

pub fn from_string(contents: String) -> Matrix(String) {
  contents
  |> string.trim
  |> string.split(on: "\n")
  |> list.fold(
    gleam_array.new(),
    fn(matrix, line) {
      line
      |> string.trim
      |> string.split(" ")
      |> gleam_array.from_list
      |> gleam_array.push(matrix, _)
    },
  )
  |> Matrix
}

pub fn to_string(matrix: Matrix(a)) -> String {
  let builder = string_builder.from_string("")
  case matrix {
    Matrix(array) ->
      array
      |> gleam_array.fold(
        builder,
        fn(row, acc) {
          let value_strings =
            row
            |> gleam_array.map(fn(col, _) {
              col
              |> dynamic.from
              |> dynamic.string
              |> result.unwrap("?")
            })
            |> gleam_array.to_list
            |> string.join(" ")
          let row_builder =
            "["
            |> string_builder.from_string
            |> string_builder.append(value_strings)
            |> string_builder.append("]\n")
            |> string_builder.to_string
          string_builder.append(acc, row_builder)
        },
      )
      |> string_builder.to_string
  }
}

pub fn get(matrix: Matrix(a), location: #(Int, Int)) -> Option(a) {
  let #(x, y) = location
  case matrix {
    Matrix(arr) ->
      arr
      |> gleam_array.get(y)
      |> gleam_array.get(x)
      |> Some
  }
}

pub fn set(matrix: Matrix(a), location: #(Int, Int), value: a) -> Matrix(a) {
  let #(x, y) = location
  case matrix {
    Matrix(arr) -> {
      let row = gleam_array.get(arr, y)
      let updated = gleam_array.set(row, x, value)
      arr
      |> gleam_array.set(y, updated)
      |> Matrix
    }
  }
}
