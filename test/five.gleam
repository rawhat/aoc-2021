import gleam/io
import gleam/list
import gleam/string
import days/five.{
  Line, Point, do_part_one, get_line_points, is_horizontal_or_vertical, parse_input,
}
import util.{should_equal}

fn get_input() -> String {
  string.trim_left(
    "
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
",
  )
}

pub fn it_gets_the_points_for_a_line_test() {
  let line1 = Line(Point(1, 1), Point(1, 3))
  let line2 = Line(Point(9, 7), Point(7, 7))

  let line_1_points = get_line_points(line1)
  let line_2_points = get_line_points(line2)

  should_equal(line_1_points, [Point(1, 1), Point(1, 2), Point(1, 3)])

  should_equal(line_2_points, [Point(9, 7), Point(8, 7), Point(7, 7)])
}

pub fn it_parses_input_to_horizontal_lines_test() {
  let lines =
    get_input()
    |> parse_input
    |> list.filter(is_horizontal_or_vertical)
    |> list.flat_map(get_line_points)
    |> list.length

  should_equal(lines, 26)
}

pub fn it_counts_points_test() {
  let input = get_input()
  let more_than_two = do_part_one(input)

  should_equal(more_than_two, 5)
}

pub fn it_does_diagonal_lines_test() {
  let diag1 = Line(Point(1, 1), Point(3, 3))
  let diag2 = Line(Point(9, 7), Point(7, 9))

  let one_points = get_line_points(diag1)
  let two_points = get_line_points(diag2)

  should_equal(one_points, [Point(1, 1), Point(2, 2), Point(3, 3)])

  should_equal(two_points, [Point(9, 7), Point(8, 8), Point(7, 9)])
}
