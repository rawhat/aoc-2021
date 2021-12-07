import gleam/io
import gleam/list
import util
import days/one
import days/two
import days/three
import days/four
import days/five
import days/six

pub fn main() {
  [
    #(one.part_one, "Day 1 Part 1: "),
    #(one.part_two, "Day 1 Part 2: "),
    #(two.part_one, "Day 2 Part 1: "),
    #(two.part_two, "Day 2 Part 2: "),
    #(three.part_one, "Day 3 Part 1: "),
    #(three.part_two, "Day 3 Part 2: "),
    #(four.part_one, "Day 4 Part 1: "),
    #(four.part_two, "Day 4 Part 2: "),
    #(five.part_one, "Day 5 Part 1: "),
    #(five.part_two, "Day 5 Part 2: "),
    #(six.part_one, "Day 6 Part 1: "),
    #(six.part_two, "Day 6 Part 2: "),
  ]
  |> list.each(fn(day) {
    case day {
      #(func, message) -> {
        io.print(message)
        let runtime = util.runtime_in_microseconds(func)
        io.print("  Execution time (in microseconds): ")
        io.debug(runtime)
      }
    }
  })
}
