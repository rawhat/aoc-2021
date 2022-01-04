import days/nine.{
  find_basin, get_adjacents, get_low_points, get_offsets, parse_input,
}
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/pair
import matrix.{Elements, Matrix}
import util.{should_equal}

pub fn get_test_data() -> Matrix(Int) {
  "2199943210
3987894921
9856789892
8767896789
9899965678"
  |> parse_input
}

pub fn it_should_parse_input_test() {
  let input = get_test_data()

  matrix.get(input, #(0, 0))
  |> should_equal(Some(2))
}

pub fn it_should_find_adjacent_values_test() {
  let input = get_test_data()

  get_adjacents(input, #(0, 0), True)
  |> list.map(pair.second)
  |> should_equal([1, 3, 9])
}

pub fn get_low_points_test() {
  let input = get_test_data()

  input
  |> get_low_points
  |> list.map(pair.first)
  |> should_equal([#(1, 0), #(9, 0), #(2, 2), #(6, 4)])
}

pub fn it_should_get_offsets_test() {
  [-1, 1]
  |> get_offsets
  |> should_equal([#(-1, -1), #(1, -1), #(-1, 1), #(1, 1)])

  get_test_data()
  |> get_adjacents(#(0, 0), False)
  |> list.map(pair.first)
  |> should_equal([#(1, 0), #(0, 1)])
}

pub fn it_should_find_basins_test() {
  get_test_data()
  |> find_basin(#(0, 0))
  |> should_equal([#(0, 0), #(0, 1), #(1, 0)])
}
