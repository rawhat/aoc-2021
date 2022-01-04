import days/eight.{Entry, get_output_number, parse_entry}
import gleam/list
import util.{should_equal}

fn get_test_input() -> String {
  "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
}

fn sample_input() -> String {
  "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb |
fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec |
fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef |
cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega |
efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga |
gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf |
gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |
cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd |
ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg |
gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc |
fgae cfgab fg bagce"
}

fn test_entry() -> Entry {
  get_test_input()
  |> parse_entry
}

pub fn it_parses_an_entry_test() {
  let entry = test_entry()

  let first_input = ["a", "b", "c", "d", "e", "f", "g"]
  let first_output = ["b", "c", "d", "e", "f"]

  should_equal(list.at(entry.inputs, 0), Ok(first_input))
  should_equal(list.at(entry.outputs, 0), Ok(first_output))
}

pub fn it_gets_output_number_test() {
  let entry = test_entry()
  let output = get_output_number(entry)

  should_equal(output, 5353)
}
