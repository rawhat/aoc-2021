import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import util.{read_file}

pub fn parse_input(input: String) -> List(Int) {
  input
  |> string.trim
  |> string.split(on: ",")
  |> list.map(fn(row) {
    assert Ok(value) = int.parse(row)
    value
  })
}

pub fn calculate_movement_cost(
  numbers: List(Int),
  destination: Int,
  increasing: Bool,
) -> Int {
  list.fold(
    numbers,
    0,
    fn(cost, value) {
      let abs = int.absolute_value(value - destination)
      let amount = case increasing {
        False -> abs
        True ->
          iterator.range(1, abs + 1)
          |> iterator.fold(0, fn(sum, num) { sum + num })
      }
      cost + amount
    },
  )
}

// brute force
pub fn find_cheapest_movements(
  positions: List(Int),
  increasing: Bool,
) -> #(Int, Int) {
  let sorted = list.sort(positions, by: int.compare)
  assert Ok(min) = list.first(sorted)
  assert Ok(max) = list.last(sorted)

  iterator.range(min, max)
  |> iterator.fold(
    #(0, 0),
    fn(acc, num) {
      let #(_, cost) = acc
      let next_cost = calculate_movement_cost(positions, num, increasing)
      case next_cost, cost {
        _, 0 -> #(num, next_cost)
        _, _ if next_cost < cost -> #(num, next_cost)
        _, _ -> acc
      }
    },
  )
}

pub fn part_one() {
  assert Ok(input) = read_file("./src/days/seven.txt")

  input
  |> parse_input
  |> find_cheapest_movements(False)
  |> io.debug

  Nil
}

// oof, slow...
pub fn part_two() {
  assert Ok(input) = read_file("./src/days/seven.txt")

  input
  |> parse_input
  |> find_cheapest_movements(True)
  |> io.debug

  Nil
}
