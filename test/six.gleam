import days/six.{age_and_reproduce, parse_input}
import gleam/iterator
import gleam/list
import gleam/map
import gleam/result
import util.{should_equal}

fn get_test_input() -> String {
  "3,4,3,1,2"
}

pub fn it_parses_input_test() {
  let fish = parse_input(get_test_input())

  let expected = map.from_list([#(1, 1), #(2, 1), #(3, 2), #(4, 1)])

  should_equal(fish, expected)
}

pub fn it_ages_and_reproduces_once_test() {
  let fish =
    get_test_input()
    |> parse_input
    |> age_and_reproduce

  let expected =
    map.from_list([
      #(0, 1),
      #(1, 1),
      #(2, 2),
      #(3, 1),
      #(4, 0),
      #(5, 0),
      #(6, 0),
      #(7, 0),
      #(8, 0),
    ])
  should_equal(fish, expected)
}

pub fn it_has_count_after_18_days_test() {
  let eighteen =
    get_test_input()
    |> parse_input
    |> iterator.iterate(age_and_reproduce)
    |> iterator.take(19)
    |> iterator.last
    |> result.unwrap(map.new())
    |> map.values
    |> list.fold(0, fn(sum, count) { sum + count })

  should_equal(eighteen, 26)
}

pub fn it_should_make_it_to_80_days_test() {
  let eighty =
    get_test_input()
    |> parse_input
    |> iterator.iterate(age_and_reproduce)
    |> iterator.take(81)
    |> iterator.last
    |> result.unwrap(map.new())
    |> map.values
    |> list.fold(0, fn(sum, count) { sum + count })

  should_equal(eighty, 5934)
}
