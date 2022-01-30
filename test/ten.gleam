import days/ten
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should

pub fn test_input() -> String {
  "[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"
}

pub fn it_should_parse_lines_test() {
  test_input()
  |> string.split(on: "\n")
  |> list.map(ten.parse_line)
  |> list.filter(result.is_error)
  |> should.equal([// Ok(_),
    // Ok(_),
    Error("}"), // Ok(_),
    Error(")"), Error("]"), // Ok(_),
    Error(")"), Error(">")])
  // Ok(_),
}

pub fn it_should_score_incompletes_test() {
  let completed =
    test_input()
    |> string.split(on: "\n")
    |> list.map(ten.parse_line)
    |> list.filter_map(fn(x) { x })
    |> list.map(ten.complete_line(_, []))

  completed
  |> should.equal([
    ["}", "}", "]", "]", ")", "}", ")", "]"],
    [")", "}", ">", "]", "}", ")"],
    ["}", "}", ">", "}", ">", ")", ")", ")", ")"],
    ["]", "]", "}", "}", "]", "}", "]", "}", ">"],
    ["]", ")", "}", ">"],
  ])

  let scores =
    completed
    |> list.map(ten.score_line(_, 0))

  scores
  |> should.equal([288957, 5566, 1480781, 995444, 294])

  let middle = list.length(scores) / 2

  scores
  |> list.sort(int.compare)
  |> list.at(middle)
  |> should.equal(Ok(288957))
}
