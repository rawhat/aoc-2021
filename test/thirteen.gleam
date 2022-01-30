import days/thirteen.{Paper}
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import gleeunit/should
import matrix.{Matrix}

fn get_input() -> Paper {
  "6,10
  0,14
  9,10
  0,3
  10,4
  4,11
  6,0
  6,12
  4,1
  0,13
  10,12
  3,4
  3,0
  8,4
  1,10
  2,14
  8,10
  9,0

  fold along y=7
  fold along x=5"
  |> thirteen.parse_input
}

fn expected_matrix(visual: String) -> Matrix(Bool) {
  visual
  |> matrix.from_character_map
  |> matrix.map(fn(_, value) {
    case value {
      "#" -> True
      _ -> False
    }
  })
}

pub fn it_should_parse_input_test() {
  let Paper(dots, ..) = get_input()

  "...#..#..#.
....#......
...........
#..........
...#....#.#
...........
...........
...........
...........
...........
.#....#.##.
....#......
......#...#
#..........
#.#........"
  |> expected_matrix
  |> should.equal(dots)
}

pub fn it_should_fold_test() {
  let Paper(dots, folds: [next_fold, ..]) = get_input()

  let expected =
    "#.##..#..#.
#...#......
......#...#
#...#......
.#.#..#.###
...........
..........."

  dots
  |> thirteen.fold(next_fold)
  |> fn(m) -> String {
    m
    |> matrix.to_digit_map(fn(value) {
      case option.unwrap(value, False) {
        True -> "#"
        False -> "."
      }
    })
    |> string.to_graphemes
    |> list.take(83)
    |> string.join(with: "")
  }
  |> should.equal(expected)

  Nil
}
