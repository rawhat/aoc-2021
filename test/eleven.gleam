import days/eleven.{Cavern, Octopus}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/result
import matrix
import util.{should_equal}

fn test_data() -> String {
  "5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"
}

pub fn it_should_parse_the_input_test() {
  let energy_map =
    test_data()
    |> eleven.parse_energy_map

  energy_map
  |> matrix.get(#(0, 0))
  |> should_equal(Some(Octopus(5, False)))
}

pub fn it_should_perform_a_step_test() {
  let cavern =
    test_data()
    |> eleven.parse_energy_map

  cavern
  |> eleven.do_iteration
  |> pair.second
  |> matrix.to_digit_map(fn(octo: Octopus) { int.to_string(octo.energy) })
  |> should_equal(
    "6594254334
3856965822
6375667284
7252447257
7468496589
5278635756
3287952832
7993992245
5957959665
6394862637
",
  )
}

pub fn it_should_solve_part_one_test() {
  let cavern =
    test_data()
    |> eleven.parse_energy_map

  let #(flashes, final_cavern) =
    iterator.range(from: 0, to: 100)
    |> iterator.fold(
      #(0, cavern),
      fn(current, _) {
        let #(curr, cavern) = current
        let #(new_flashes, new_cavern) = eleven.do_iteration(cavern)

        #(curr + list.length(new_flashes), new_cavern)
      },
    )

  should_equal(flashes, 1656)
}
