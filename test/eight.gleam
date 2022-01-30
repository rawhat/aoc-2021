import days/eight.{Entry, get_output_number, parse_entry}
import gleam/list
import gleeunit/should

fn get_test_input() -> String {
  "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
}

fn test_entry() -> Entry {
  get_test_input()
  |> parse_entry
}

pub fn it_parses_an_entry_test() {
  let entry = test_entry()

  let first_input = ["a", "b", "c", "d", "e", "f", "g"]
  let first_output = ["b", "c", "d", "e", "f"]

  should.equal(list.at(entry.inputs, 0), Ok(first_input))
  should.equal(list.at(entry.outputs, 0), Ok(first_output))
}

pub fn it_gets_output_number_test() {
  let entry = test_entry()
  let output = get_output_number(entry)

  should.equal(output, 5353)
}
