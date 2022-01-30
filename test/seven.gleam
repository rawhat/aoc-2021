import days/seven.{calculate_movement_cost, parse_input}
import gleeunit/should

const input = "16,1,2,0,4,2,7,1,2,14"

pub fn calculates_correct_movement_cost_test() {
  let cost =
    input
    |> parse_input
    |> calculate_movement_cost(2, False)

  should.equal(cost, 37)
}
