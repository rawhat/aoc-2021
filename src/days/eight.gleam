import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/map.{Map}
import gleam/result
import gleam/string
import util.{read_lines}

pub type Wires =
  List(String)

pub type Entry {
  Entry(inputs: List(Wires), outputs: List(Wires))
}

const test_input = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"

pub fn get_wires(input: String) -> Wires {
  input
  |> string.to_graphemes
  |> list.sort(string.compare)
}

pub fn parse_entry(str: String) -> Entry {
  let [inputs, outputs] =
    str
    |> string.split(on: " | ")
    |> list.map(string.trim)
    |> list.map(string.split(_, on: " "))

  Entry(
    inputs: list.map(inputs, get_wires),
    outputs: list.map(outputs, get_wires),
  )
}

const unique_values = [2, 3, 4, 7]

pub fn is_unique_count(output: Wires) -> Bool {
  output
  |> list.length
  |> list.contains(unique_values, _)
}

pub fn part_one() {
  assert Ok(lines) = read_lines("./src/days/eight.txt")

  lines
  |> list.map(parse_entry)
  |> list.flat_map(fn(entry: Entry) { entry.outputs })
  |> list.filter(is_unique_count)
  |> list.length
  |> io.debug

  Nil
}

pub fn find_with(
  items: List(Wires),
  to_remove: Wires,
  count: Int,
) -> List(Wires) {
  items
  |> list.filter(fn(chars) {
    let removed =
      to_remove
      |> list.filter(fn(char) { list.contains(chars, char) == False })
      |> list.length

    removed == count
  })
}

pub fn find_without(items: List(Wires), to_remove: Wires) -> List(Wires) {
  find_with(items, to_remove, 0)
}

pub fn find_with_one(items: List(Wires), to_remove: Wires) -> List(Wires) {
  find_with(items, to_remove, 1)
}

fn remove(from: List(a), these: List(a)) -> List(a) {
  list.filter(from, fn(elem) { list.contains(these, elem) == False })
}

pub fn find_outputs(entry: Entry) -> Map(Wires, Int) {
  let Entry(inputs: inputs, ..) = entry

  let by_count =
    inputs
    |> iterator.from_list
    |> iterator.map(list.sort(_, string.compare))
    |> iterator.group(by: list.length)

  assert Ok([one]) = map.get(by_count, 2)
  assert Ok([four]) = map.get(by_count, 4)
  assert Ok([seven]) = map.get(by_count, 3)
  assert Ok([eight]) = map.get(by_count, 7)

  assert Ok(two_three_five) = map.get(by_count, 5)
  assert Ok(zero_six_nine) = map.get(by_count, 6)

  assert [nine] = find_without(zero_six_nine, four)
  assert [six] = find_with_one(zero_six_nine, seven)
  assert [zero] = remove(zero_six_nine, [six, nine])

  assert [three] = find_without(two_three_five, seven)
  assert [five] = find_with_one(two_three_five, six)
  assert [two] = remove(two_three_five, [three, five])

  [zero, one, two, three, four, five, six, seven, eight, nine]
  |> list.index_map(fn(i, digit) { #(digit, i) })
  |> map.from_list
}

pub fn get_output_number(entry: Entry) -> Int {
  let output_mapping = find_outputs(entry)

  entry.outputs
  |> list.filter_map(map.get(output_mapping, _))
  |> list.fold(
    "",
    fn(acc, digit) {
      digit
      |> int.to_string
      |> string.append(acc, _)
    },
  )
  |> int.parse
  |> result.unwrap(-1)
}

pub fn part_two() {
  assert Ok(lines) = read_lines("./src/days/eight.txt")

  lines
  |> list.map(parse_entry)
  |> list.map(get_output_number)
  |> list.fold(0, fn(a, b) { a + b })
  |> io.debug

  Nil
}
