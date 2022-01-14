import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/map.{Map}
import gleam/option
import gleam/result
import gleam/string
import gleam/string_builder
import util.{read_file}

pub fn parse_input(input: String) -> Map(Int, Int) {
  input
  |> string.trim
  |> string.split(on: ",")
  |> list.filter_map(int.parse)
  |> list.fold(
    map.new(),
    fn(m, fish) { map.update(m, fish, fn(opt) { option.unwrap(opt, 0) + 1 }) },
  )
}

pub fn age_and_reproduce(counts: Map(Int, Int)) -> Map(Int, Int) {
  let new_fish =
    counts
    |> map.get(0)
    |> result.unwrap(0)

  iterator.range(1, 9)
  |> iterator.map(fn(index) {
    let count =
      counts
      |> map.get(index)
      |> result.unwrap(0)

    #(index - 1, count)
  })
  |> iterator.to_list
  |> list.append([#(8, new_fish)])
  |> map.from_list
  |> map.update(6, fn(opt) { option.unwrap(opt, 0) + new_fish })
}

pub fn fish_at(initial: Map(Int, Int), days: Int) -> Int {
  initial
  |> iterator.iterate(age_and_reproduce)
  |> iterator.take(days + 1)
  |> iterator.last
  |> result.unwrap(map.new())
  |> map.values
  |> list.fold(0, fn(sum, count) { sum + count })
}

pub fn part_one() {
  assert Ok(file) = read_file("./src/days/six.txt")

  file
  |> parse_input
  |> fish_at(80)
  |> io.debug

  Nil
}

pub fn part_two() {
  assert Ok(file) = read_file("./src/days/six.txt")

  file
  |> parse_input
  |> fish_at(256)
  |> io.debug

  Nil
}
