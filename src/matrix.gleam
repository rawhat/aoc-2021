import gleam/dynamic
import gleam/int
import gleam/io
import gleam/iterator.{Iterator}
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/pair
import gleam/regex.{Regex}
import gleam/result
import gleam/string
import gleam/string_builder
import gleam_array.{Array}

pub type Matrix(a) {
  Matrix(elements: Array(Array(a)))
}

pub type Point =
  #(Int, Int)

pub type Elements(a) =
  #(Point, a)

fn from_string_with_re(data: String, re: Regex) -> Matrix(String) {
  data
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

pub fn from_character_map(character_map: String) -> Matrix(String) {
  assert Ok(re) = regex.from_string("(.)")

  from_string_with_re(character_map, re)
}

pub fn from_digit_map(digits: String) -> Matrix(String) {
  assert Ok(re) = regex.from_string("([0-9])")

  from_string_with_re(digits, re)
}

pub fn to_digit_map(
  matrix: Matrix(a),
  mapper: fn(Option(a)) -> String,
) -> String {
  let #(columns, rows) = get_dimensions(matrix)

  iterator.range(from: 0, to: rows)
  |> iterator.fold(
    string_builder.from_string(""),
    fn(str, row_index) {
      iterator.range(from: 0, to: columns)
      |> iterator.fold(
        str,
        fn(str, col_index) {
          matrix
          |> get(#(col_index, row_index))
          |> mapper
          |> string_builder.append(str, _)
        },
      )
      |> string_builder.append("\n")
    },
  )
  |> string_builder.to_string
  |> string.trim
}

pub fn from_string(contents: String) -> Matrix(String) {
  assert Ok(re) = regex.from_string("\\s*([0-9]+)\\s*")

  from_string_with_re(contents, re)
}

pub fn fill_holes(matrix: Matrix(a), with mapper: fn(Point) -> a) -> Matrix(a) {
  let #(columns, rows) = get_dimensions(matrix)

  iterator.range(from: 0, to: columns)
  |> iterator.flat_map(fn(column) {
    iterator.range(from: 0, to: rows)
    |> iterator.map(fn(row) { #(column, row) })
  })
  |> iterator.map(fn(point) {
    case get(matrix, point) {
      Some(value) -> #(point, value)
      None -> #(point, mapper(point))
    }
  })
  |> from_iterator
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
        |> gleam_array.map(fn(col_opt, _) {
          col_opt
          |> option.map(fn(col) {
            let col_dyn = dynamic.from(col)
            case dynamic.classify(col_dyn) {
              "String" ->
                col_dyn
                |> dynamic.string
                |> result.unwrap("-")
              "Int" ->
                col_dyn
                |> dynamic.int
                |> result.unwrap(-1)
                |> int.to_string
              _ -> "?"
            }
          })
          |> option.unwrap("?")
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

pub fn get(matrix: Matrix(a), location: Point) -> Option(a) {
  let #(x, y) = location
  case matrix {
    Matrix(arr) ->
      arr
      |> gleam_array.get(y)
      |> option.unwrap(gleam_array.new())
      |> gleam_array.get(x)
  }
}

pub fn get_adjacents(
  points: Matrix(a),
  position: Point,
  with_diagonal with_diagonal: Bool,
) -> List(Elements(a)) {
  let #(col, row) = position

  [#(-1, 0), #(0, -1), #(1, 0), #(0, 1)]
  |> fn(l) {
    case with_diagonal {
      True -> list.append(l, [#(-1, 1), #(-1, -1), #(1, -1), #(1, 1)])
      False -> l
    }
  }
  |> list.filter_map(fn(pos) {
    let #(col_offset, row_offset) = pos
    let adjacent = #(col + col_offset, row + row_offset)
    case adjacent {
      value if value == position -> Error(Nil)
      #(col, row) if col < 0 || row < 0 -> Error(Nil)
      value ->
        value
        |> get(points, _)
        |> option.map(fn(num) { #(value, num) })
        |> option.to_result(Nil)
    }
  })
}

pub fn set(matrix: Matrix(a), location: Point, value: a) -> Matrix(a) {
  let #(x, y) = location
  let Matrix(arr) = matrix
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

pub fn update(
  matrix: Matrix(a),
  location: Point,
  updater: fn(Option(a)) -> a,
) -> Matrix(a) {
  let existing = get(matrix, location)

  set(matrix, location, updater(existing))
}

pub fn from_iterator(iter: Iterator(Elements(a))) -> Matrix(a) {
  iterator.fold(
    iter,
    new(),
    fn(m, p) {
      let #(position, value) = p
      set(m, position, value)
    },
  )
}

pub fn to_iterator(matrix: Matrix(a)) -> Iterator(Elements(a)) {
  let #(col, row) = get_dimensions(matrix)
  iterator.range(from: 0, to: col)
  |> iterator.flat_map(fn(column) {
    iterator.range(from: 0, to: row)
    |> iterator.map(fn(r) { #(column, r) })
  })
  |> iterator.map(fn(pos) { #(pos, get(matrix, pos)) })
  |> iterator.filter(fn(entry) {
    case entry {
      #(_, Some(_)) -> True
      _ -> False
    }
  })
  |> iterator.map(fn(entry) {
    let #(pos, Some(value)) = entry
    #(pos, value)
  })
}

pub fn map(matrix: Matrix(a), mapper: fn(Point, a) -> b) -> Matrix(b) {
  matrix
  |> to_iterator
  |> iterator.map(fn(p) {
    let #(pos, value) = p
    let new_value = mapper(pos, value)
    #(pos, new_value)
  })
  |> from_iterator
}

pub fn get_row(matrix: Matrix(a), index: Int) -> List(a) {
  matrix
  |> to_iterator
  |> iterator.filter(fn(tup) {
    let #(#(_, row), _) = tup
    row == index
  })
  |> iterator.map(pair.second)
  |> iterator.to_list
}

pub fn get_column(matrix: Matrix(a), index: Int) -> List(a) {
  matrix
  |> to_iterator
  |> iterator.filter(fn(tup) {
    let #(#(column, _), _) = tup
    column == index
  })
  |> iterator.map(pair.second)
  |> iterator.to_list
}

pub fn rows(matrix: Matrix(a)) -> List(List(Point)) {
  let #(row_count, column_count) = get_dimensions(matrix)

  iterator.range(0, row_count)
  |> iterator.map(fn(row) {
    iterator.range(0, column_count)
    |> iterator.map(fn(col) { #(col, row) })
    |> iterator.to_list
  })
  |> iterator.to_list
}

pub fn columns(matrix: Matrix(a)) -> List(List(Point)) {
  let #(row_count, column_count) = get_dimensions(matrix)

  iterator.range(0, column_count)
  |> iterator.map(fn(col) {
    iterator.range(0, row_count)
    |> iterator.map(fn(row) { #(col, row) })
    |> iterator.to_list
  })
  |> iterator.to_list
}

pub fn get_dimensions(matrix: Matrix(a)) -> Point {
  let total_rows = gleam_array.sparse_size(matrix.elements)

  let total_columns =
    matrix.elements
    |> gleam_array.map(fn(opt, _) {
      opt
      |> option.unwrap(gleam_array.new())
      |> gleam_array.sparse_size
    })
    |> gleam_array.fold(
      0,
      fn(max, next) {
        next
        |> option.unwrap(0)
        |> int.max(max)
      },
    )

  #(total_columns, total_rows)
}
