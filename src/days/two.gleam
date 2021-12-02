import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import util.{read_lines}

pub type Movement {
  Forward(Int)
  Down(Int)
  Up(Int)
}

pub fn get_movements(lines: List(String)) -> List(Movement) {
  list.map(
    lines,
    fn(line) {
      assert [movement, amount] = string.split(line, on: " ")
      assert Ok(num) = int.parse(amount)
      case movement {
        "forward" -> Forward(num)
        "down" -> Down(num)
        "up" -> Up(num)
      }
    },
  )
}

pub fn determine_position(movements: List(Movement)) -> #(Int, Int) {
  list.fold(
    movements,
    #(0, 0),
    fn(acc, movement) {
      case acc, movement {
        #(horizontal, depth), Forward(num) -> #(horizontal + num, depth)
        #(horizontal, depth), Down(num) -> #(horizontal, depth + num)
        #(horizontal, depth), Up(num) -> #(horizontal, depth - num)
      }
    },
  )
}

pub fn calculate_aim_and_position(movements: List(Movement)) -> #(Int, Int, Int) {
  list.fold(
    movements,
    #(0, 0, 0),
    fn(acc, movement) {
      case acc, movement {
        #(horizontal, depth, aim), Forward(num) -> #(
          horizontal + num,
          depth + aim * num,
          aim,
        )
        #(horizontal, depth, aim), Down(num) -> #(horizontal, depth, aim + num)
        #(horizontal, depth, aim), Up(num) -> #(horizontal, depth, aim - num)
      }
    },
  )
}

pub fn part_one() {
  assert Ok(lines) = read_lines("./src/days/two.txt")
  lines
  |> get_movements
  |> determine_position
  |> fn(tup) { pair.first(tup) * pair.second(tup) }
  |> io.debug

  Nil
}

pub fn part_two() {
  assert Ok(lines) = read_lines("./src/days/two.txt")
  lines
  |> get_movements
  |> calculate_aim_and_position
  |> fn(triple) {
    assert #(horizontal, depth, _) = triple
    horizontal * depth
  }
  |> io.debug

  Nil
}
