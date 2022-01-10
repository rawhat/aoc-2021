import gleam/int
import gleam/io
import gleam/iterator.{Done, Next}
import gleam/list
import gleam/map
import gleam/option
import gleam/pair
import gleam/result
import gleam/set.{Set}
import gleam/string
import matrix.{Elements, Matrix, Point}
import util.{read_file}

pub fn parse_input(data: String) -> Matrix(Int) {
  data
  |> string.trim
  |> string.split(on: "\n")
  |> list.index_map(fn(row_index, row) {
    row
    |> string.trim
    |> string.to_graphemes
    |> list.index_map(fn(col_index, value) {
      assert Ok(height) = int.parse(value)
      #(#(col_index, row_index), height)
    })
  })
  |> list.flatten
  |> iterator.from_list
  |> matrix.from_iterator
}

pub fn get_offsets(values: List(Int)) -> List(Point) {
  values
  |> list.flat_map(fn(row_offset) {
    list.map(values, fn(col_offset) { #(col_offset, row_offset) })
  })
}

pub fn get_adjacents(
  points: Matrix(Int),
  position: Point,
  with_diagonal: Bool,
) -> List(Elements(Int)) {
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
        |> matrix.get(points, _)
        |> option.map(fn(num) { #(value, num) })
        |> option.to_result(Nil)
    }
  })
}

pub fn get_low_points(points: Matrix(Int)) -> List(Elements(Int)) {
  points
  |> matrix.to_iterator
  |> iterator.filter(fn(element) {
    let #(position, value) = element
    let adjacents = get_adjacents(points, position, True)
    list.all(adjacents, fn(elem) { pair.second(elem) > value })
  })
  |> iterator.to_list
}

pub fn part_one() {
  assert Ok(data) = read_file("./src/days/nine.txt")

  data
  |> parse_input
  |> get_low_points
  |> list.map(pair.second)
  |> list.fold(0, fn(a, b) { a + b + 1 })
  |> io.debug

  Nil
}

pub type BasinFinder {
  BasinFinder(visited: Set(Point), new_points: Set(Point))
}

pub fn find_basin(points: Matrix(Int), low_point: Point) -> List(Point) {
  iterator.unfold(
    from: BasinFinder(
      visited: set.new(),
      new_points: set.from_list([low_point]),
    ),
    with: fn(finder) {
      let BasinFinder(visited: visited, new_points: new_points) = finder

      case set.to_list(new_points) {
        [] -> Done
        new -> {
          let newly_visited =
            new
            |> list.flat_map(get_adjacents(points, _, False))
            |> list.filter(fn(adjacent) {
              case adjacent {
                #(_, value) if value == 9 -> False
                #(point, _) -> set.contains(visited, point) == False
              }
            })
          let new_basin =
            BasinFinder(
              visited: set.union(visited, new_points),
              new_points: newly_visited
              |> list.map(pair.first)
              |> set.from_list,
            )
          Next(element: new_basin, accumulator: new_basin)
        }
      }
    },
  )
  |> iterator.last
  |> result.map(fn(basin: BasinFinder) { set.to_list(basin.visited) })
  |> result.unwrap([])
}

pub fn part_two() {
  assert Ok(data) = read_file("./src/days/nine.txt")

  let inputs = parse_input(data)

  inputs
  |> get_low_points
  |> list.map(fn(elem) { find_basin(inputs, pair.first(elem)) })
  |> list.map(list.length)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, fn(a, b) { a * b })
  |> io.debug

  Nil
}
