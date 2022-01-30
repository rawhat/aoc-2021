import days/twelve
import gleam/erlang/atom
import gleam/list
import gleam/map
import gleam/set
import gleam/string
import gleeunit/should
import util.{should_contain}

external fn test_with_timeout(timeout: Int, func: fn() -> Nil) -> Nil =
  "erl_util" "test_with_timeout"

pub fn it_should_convert_to_map_test() {
  let data = "start-A
start-b
A-c
A-b
b-d
A-end
b-end"

  data
  |> twelve.parse_input
  |> should.equal(map.from_list([
    #("start", ["A", "b"]),
    #("A", ["c", "b", "end"]),
    #("b", ["A", "d", "end"]),
    #("c", ["A"]),
    #("d", ["b"]),
  ]))
}

pub fn it_should_get_paths_test() {
  let data = "start-A
start-b
A-c
A-b
b-d
A-end
b-end"

  data
  |> twelve.parse_input
  |> twelve.get_all_paths(twelve.has_no_lowercase_multiples)
  |> list.map(string.join(_, with: ","))
  |> should_contain([
    "start,A,b,A,c,A,end", "start,A,b,A,end", "start,A,b,end", "start,A,c,A,b,A,end",
    "start,A,c,A,b,end", "start,A,c,A,end", "start,A,end", "start,b,A,c,A,end", "start,b,A,end",
    "start,b,end",
  ])
}

pub fn it_should_calculate_complex_examples_test() {
  "dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"
  |> twelve.parse_input
  |> twelve.get_all_paths(twelve.has_no_lowercase_multiples)
  |> list.length
  |> should.equal(19)

  "fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"
  |> twelve.parse_input
  |> twelve.get_all_paths(twelve.has_no_lowercase_multiples)
  |> list.length
  |> should.equal(226)
}

pub fn it_should_validate_no_multiple_with_no_multiple_test() {
  ["A", "B", "c", "d", "e"]
  |> twelve.has_no_lowercase_multiples
  |> should.equal(True)
}

pub fn it_should_validate_no_multiple_with_multiple_test() {
  ["A", "B", "c", "c", "d", "e"]
  |> twelve.has_no_lowercase_multiples
  |> should.equal(False)
}

pub fn it_should_validate_no_multiple_with_one_multiple_test() {
  ["A", "B", "c", "d", "e"]
  |> twelve.has_only_one_lowercase_multiple
  |> should.equal(True)
}

pub fn it_should_validate_one_multiple_with_one_multiple_test() {
  ["A", "B", "c", "c", "d", "e"]
  |> twelve.has_only_one_lowercase_multiple
  |> should.equal(True)
}

pub fn it_should_validate_one_multiple_with_multiple_multiples_test() {
  ["A", "B", "c", "c", "d", "d", "e"]
  |> twelve.has_only_one_lowercase_multiple
  |> should.equal(False)
}

pub fn it_should_validate_one_multiple_with_cycle_i_had_test() {
  ["start", "A", "b", "A", "b", "A", "b"]
  |> twelve.has_only_one_lowercase_multiple
  |> should.equal(False)
}

pub fn it_should_do_the_complex_one_test_() {
  test_with_timeout(
    3600,
    fn() {
      "fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"
      |> twelve.parse_input
      |> twelve.get_all_paths(twelve.has_only_one_lowercase_multiple)
      |> list.length
      |> should.equal(3509)
    },
  )
}
