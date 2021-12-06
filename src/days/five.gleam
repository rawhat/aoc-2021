import gleam/int
import gleam/io
import gleam/iterator.{Done, Next}
import gleam/list
import gleam/map.{Map}
import gleam/option.{None, Some}
import gleam/pair
import gleam/string
import matrix
import util.{read_file}

pub type Point {
  Point(x: Int, y: Int)
}

// With pt 2... maybe this should be cases of Horizontal, Vertical, and
// Diagonal?
pub type Line {
  Line(from: Point, to: Point)
}

pub fn parse_point(text: String) -> Point {
  assert [x_str, y_str] = string.split(text, on: ",")

  assert Ok(x) = int.parse(x_str)
  assert Ok(y) = int.parse(y_str)

  Point(x, y)
}

pub fn parse_line(line: String) -> Line {
  assert [start_string, end_string] = string.split(line, on: " -> ")

  let from = parse_point(start_string)
  let to = parse_point(end_string)

  Line(from, to)
}

pub fn parse_input(input: String) -> List(Line) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(parse_line)
}

pub fn is_horizontal(line: Line) -> Bool {
  let Line(Point(_, y1), Point(_, y2)) = line

  y1 == y2
}

pub fn is_vertical(line: Line) -> Bool {
  let Line(Point(x1, _), Point(x2, _)) = line

  x1 == x2
}

pub fn is_horizontal_or_vertical(line: Line) -> Bool {
  list.any([is_horizontal, is_vertical], fn(f) { f(line) })
}

pub fn get_range(from: Int, to: Int, other_size: Int) -> List(Int) {
  case from, to {
    _, _ if from == to ->
      0
      |> iterator.repeat
      |> iterator.take(other_size + 1)
    _, _ if from < to -> iterator.range(0, to - from + 1)
    _, _ if from > to -> iterator.range(0, to - from - 1)
  }
  |> iterator.to_list
}

pub fn get_line_points(line: Line) -> List(Point) {
  let Line(Point(x1, y1) as p1, Point(x2, y2) as p2) = line

  let x_range = get_range(x1, x2, int.max(y2 - y1, y1 - y2))
  let y_range = get_range(y1, y2, int.max(x2 - x1, x1 - x2))

  let diffs = list.zip(x_range, y_range)

  list.map(
    diffs,
    fn(diff) {
      let #(x, y) = diff
      Point(x1 + x, y1 + y)
    },
  )
}

pub fn get_point_counts(lines: List(Line)) -> Map(Point, Int) {
  lines
  |> list.flat_map(get_line_points)
  |> list.fold(
    map.new(),
    fn(point_counts, point) {
      map.update(
        point_counts,
        point,
        fn(count) {
          case count {
            Some(existing) -> existing + 1
            None -> 1
          }
        },
      )
    },
  )
}

pub fn do_part_one(input: String) -> Int {
  input
  |> parse_input
  |> list.filter(is_horizontal_or_vertical)
  |> get_point_counts
  |> map.values
  |> list.filter(fn(n) { n >= 2 })
  |> list.length
  |> io.debug
}

pub fn part_one() {
  assert Ok(input) = read_file("src/days/five.txt")

  do_part_one(input)

  Nil
}

pub fn part_two() {
  assert Ok(input) = read_file("src/days/five.txt")

  input
  |> parse_input
  |> get_point_counts
  |> map.values
  |> list.filter(fn(n) { n >= 2 })
  |> list.length
  |> io.debug

  Nil
}
