import gleeunit
import gleam/string
import days/one
import gleeunit/should

pub fn part_two_sample_test() {
  let test_case = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

  should.equal(one.solve_two(test_case), 5)
}
