import gleam/function
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/regex.{Match}
import gleam/set
import gleam/string
import matrix.{Matrix}
import util.{read_file}

pub type Fold {
  Vertical(Int)
  Horizontal(Int)
}

pub type Paper {
  Paper(dots: Matrix(Bool), folds: List(Fold))
}

pub fn parse_input(data: String) -> Paper {
  let [points, fold_string] = string.split(data, on: "\n\n")

  assert Ok(re) = regex.from_string("([xy])=(\\d+)$")

  let dots =
    points
    |> string.trim
    |> string.split(on: "\n")
    |> list.map(string.trim)
    |> list.map(string.split(_, on: ","))
    |> list.map(fn(line) {
      let [x, y] = line
      assert Ok(col) = int.parse(x)
      assert Ok(row) = int.parse(y)
      #(#(col, row), True)
    })
    |> iterator.from_list
    |> matrix.from_iterator
    |> matrix.fill_holes(with: fn(_) { False })

  let folds =
    fold_string
    |> string.trim
    |> string.split(on: "\n")
    |> list.map(fn(fold_info) {
      let [Match(submatches: [Some(direction), Some(index)], ..)] =
        regex.scan(re, fold_info)
      assert Ok(index_value) = int.parse(index)
      case direction {
        "x" -> Vertical(index_value)
        "y" -> Horizontal(index_value)
      }
    })

  Paper(dots, folds)
}

// The gist of the solution (I think) is that the folded values can be determined
// by the difference between the pivot value and the value in dimension of the
// pivot.
pub fn fold(dots: Matrix(Bool), fold: Fold) -> Matrix(Bool) {
  let updater = case fold {
    Vertical(column) -> fn(entry) {
      let #(#(col, _) as pos, value) = entry
      case col > column, value {
        True, True -> #(
          pair.map_first(pos, fn(value) { column - { value - column } }),
          value,
        )
        _, _ -> entry
      }
    }
    Horizontal(row) -> fn(entry) {
      let #(#(_, r) as pos, value) = entry
      case r > row, value {
        True, True -> #(
          pair.map_second(pos, fn(value) { row - { value - row } }),
          value,
        )
        _, _ -> entry
      }
    }
  }

  dots
  |> matrix.to_iterator
  |> iterator.map(updater)
  |> matrix.from_iterator
}

pub fn get_paper() -> Paper {
  assert Ok(data) = read_file("src/days/thirteen.txt")

  parse_input(data)
}

pub fn part_one() {
  let paper = get_paper()

  let Paper(dots, folds: [first_fold, ..]) = paper

  dots
  |> fold(first_fold)
  |> matrix.to_iterator
  |> iterator.filter(pair.second)
  |> iterator.to_list
  |> list.length
  |> io.debug

  Nil
}

pub fn part_two() {
  let paper = get_paper()

  io.print("\n\n")

  paper.folds
  |> list.fold(paper.dots, fold)
  |> matrix.to_iterator
  |> iterator.filter(fn(entry) {
    let #(#(col, row), _) = entry
    col <= 50 && row <= 20
  })
  |> matrix.from_iterator
  |> fn(dots) { Paper(dots, folds: []) }
  |> print_dots
  |> io.print

  Nil
}

pub fn print_dots(paper: Paper) -> String {
  matrix.to_digit_map(
    paper.dots,
    fn(value) {
      case option.unwrap(value, False) {
        True -> "#"
        False -> "."
      }
    },
  )
}
