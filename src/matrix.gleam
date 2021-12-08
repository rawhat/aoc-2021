import gleam/dynamic
import gleam/int
import gleam/io
import gleam/iterator.{Done, Iterator, Next}
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/pair
import gleam/regex
import gleam/result
import gleam/string
import gleam/string_builder
import gleam_array.{Array}

pub type Matrix(a) {
  Matrix(elements: Array(Array(a)))
}

pub fn from_string(contents: String) -> Matrix(String) {
  assert Ok(re) = regex.from_string("\\s*([0-9]+)\\s*")

  contents
  |> string.trim
  |> string.split(on: "\n")
  |> list.fold(
    gleam_array.new(),
    fn(matrix, line) {
      line
      |> string.trim
      |> regex.split(re, content: _)
      |> list.filter(fn(s) { string.is_empty(s) == False })
      |> list.map(string.trim)
      |> gleam_array.from_list
      |> gleam_array.push(matrix, _)
    },
  )
  |> Matrix
}

pub fn to_string(matrix: Matrix(a)) -> String {
  let builder = string_builder.from_string("")
  let Matrix(array) = matrix

  let #(columns, _) = get_dimensions(matrix)

  array
  |> gleam_array.fold(
    builder,
    fn(acc, maybe_row) {
      let row = case maybe_row {
        None ->
          iterator.range(0, columns)
          |> iterator.map(fn(_) {
            "__"
            |> dynamic.from
            |> dynamic.unsafe_coerce
          })
          |> iterator.to_list
          |> gleam_array.from_list
        Some(arr) -> arr
      }
      let value_strings =
        row
        |> gleam_array.map(fn(col, _) {
          let col_dyn = dynamic.from(col)
          case dynamic.classify(col_dyn) {
            "String" ->
              col_dyn
              |> dynamic.string
              |> result.unwrap("--")
            "Int" ->
              col_dyn
              |> dynamic.int
              |> result.unwrap(-1)
              |> int.to_string
            _ -> "??"
          }
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

pub fn new() -> Matrix(a) {
  Matrix(gleam_array.new())
}

pub fn get(matrix: Matrix(a), location: #(Int, Int)) -> Option(a) {
  let #(x, y) = location
  case matrix {
    Matrix(arr) ->
      arr
      |> gleam_array.get(y)
      |> option.unwrap(gleam_array.new())
      |> gleam_array.get(x)
  }
}

pub fn set(matrix: Matrix(a), location: #(Int, Int), value: a) -> Matrix(a) {
  let #(x, y) = location
  case matrix {
    Matrix(arr) -> {
      let row =
        arr
        |> gleam_array.get(y)
        |> option.unwrap(gleam_array.new())
        |> gleam_array.set(x, value)
      let updated = gleam_array.set(row, x, value)
      arr
      |> gleam_array.set(y, updated)
      |> Matrix
    }
  }
}

pub fn from_iterator(iter: Iterator(#(#(Int, Int), a))) -> Matrix(a) {
  iterator.fold(
    iter,
    new(),
    fn(m, p) {
      let #(position, value) = p
      set(m, position, value)
    },
  )
}

pub fn iterate(matrix: Matrix(a)) -> Iterator(#(#(Int, Int), a)) {
  iterator.unfold(
    from: #(matrix, 0, 0),
    with: fn(acc) {
      let #(matrix, x, y) = acc
      case get(matrix, #(x, y)), get(matrix, #(0, y + 1)) {
        Some(value), _ ->
          Next(element: #(#(x, y), value), accumulator: #(matrix, x + 1, y))
        None, Some(value) ->
          Next(element: #(#(0, y + 1), value), accumulator: #(matrix, 1, y + 1))
        None, None -> Done
      }
    },
  )
}

pub fn get_row(matrix: Matrix(a), index: Int) -> List(a) {
  matrix
  |> iterate
  |> iterator.filter(fn(tup) {
    let #(#(_, row), _) = tup
    row == index
  })
  |> iterator.map(pair.second)
  |> iterator.to_list
}

pub fn get_column(matrix: Matrix(a), index: Int) -> List(a) {
  matrix
  |> iterate
  |> iterator.filter(fn(tup) {
    let #(#(column, _), _) = tup
    column == index
  })
  |> iterator.map(pair.second)
  |> iterator.to_list
}

pub fn get_dimensions(matrix: Matrix(a)) -> #(Int, Int) {
  let Matrix(values) = matrix

  let rows = gleam_array.size(values)
  let columns =
    values
    |> gleam_array.get(0)
    |> option.unwrap(gleam_array.new())
    |> gleam_array.size

  #(rows, columns)
}

pub fn rows(matrix: Matrix(a)) -> List(List(#(Int, Int))) {
  let #(row_count, column_count) = get_dimensions(matrix)

  iterator.range(0, row_count)
  |> iterator.map(fn(row) {
    iterator.range(0, column_count)
    |> iterator.map(fn(col) { #(col, row) })
    |> iterator.to_list
  })
  |> iterator.to_list
}

pub fn columns(matrix: Matrix(a)) -> List(List(#(Int, Int))) {
  let #(row_count, column_count) = get_dimensions(matrix)

  iterator.range(0, column_count)
  |> iterator.map(fn(col) {
    iterator.range(0, row_count)
    |> iterator.map(fn(row) { #(col, row) })
    |> iterator.to_list
  })
  |> iterator.to_list
}
