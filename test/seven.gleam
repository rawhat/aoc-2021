import days/seven.{calculate_movement_cost, find_cheapest_movements, parse_input}
import util.{should_equal}

const input = "16,1,2,0,4,2,7,1,2,14"

pub fn calculates_correct_movement_cost_test() {
  let cost =
    input
    |> parse_input
    |> calculate_movement_cost(2, False)

  should_equal(cost, 37)
}
