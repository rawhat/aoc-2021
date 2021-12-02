import gleam/io
import gleam/list
import util
import days/one
import days/two

pub fn main() {
  [
    #(one.part_one, "Day 1 Part 1: "),
    #(one.part_two, "Day 1 Part 2: "),
    #(two.part_one, "Day 2 Part 1: "),
    #(two.part_two, "Day 2 Part 2: "),
  ]
  |> list.each(fn(day) {
    case day {
      #(func, message) -> {
        io.print(message)
        func()
      }
    }
  })
}
