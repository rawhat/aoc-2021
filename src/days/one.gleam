import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import util.{read_lines}

fn get_numbers() -> List(Int) {
  "src/days/one.txt"
  |> read_lines
  |> result.unwrap([])
  |> list.map(fn(line) {
    assert Ok(num) = int.parse(line)
    num
  })
}

fn get_increases(nums: List(Int)) {
  nums
  |> list.fold(
    #(0, None),
    fn(previous, num) {
      case previous {
        #(increases, Some(prev)) if num > prev -> #(increases + 1, Some(num))
        #(increases, Some(_)) | #(increases, None) -> #(increases, Some(num))
      }
    },
  )
}

pub fn part_one() {
  get_numbers()
  |> get_increases
  |> pair.first
  |> io.debug

  Nil
}

pub fn solve_two(numbers: List(Int)) -> Int {
  numbers
  |> list.window(3)
  |> list.map(list.fold(_, 0, fn(sum, next) { sum + next }))
  |> get_increases
  |> pair.first
}

pub fn part_two() {
  get_numbers()
  |> solve_two
  |> io.debug

  Nil
}
