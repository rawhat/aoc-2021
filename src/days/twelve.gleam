import gleam/function
import gleam/io
import gleam/iterator
import gleam/list
import gleam/map.{Map}
import gleam/option
import gleam/pair
import gleam/regex
import gleam/set.{Set}
import gleam/string
import util.{read_file}

pub type Path =
  List(String)

pub type Paths =
  Map(String, List(String))

pub fn parse_input(data: String) -> Paths {
  data
  |> string.trim
  |> string.split(on: "\n")
  |> iterator.from_list
  |> iterator.map(string.trim)
  |> iterator.map(string.split(_, on: "-"))
  |> iterator.flat_map(fn(tup) {
    let [src, dest] = tup
    case src, dest {
      "start", _ | _, "end" -> [#(src, dest)]
      _, "start" | "end", _ -> [#(dest, src)]
      _, _ -> [#(src, dest), #(dest, src)]
    }
    |> iterator.from_list
  })
  |> iterator.to_list
  |> set.from_list
  |> set.to_list
  |> iterator.from_list
  |> iterator.group(by: pair.first)
  |> map.map_values(fn(_, pairs) { list.map(pairs, pair.second) })
}

// count lower case letters, if count > 2 for any, false
fn multiple_lowercase_entries(path: Path) -> Int {
  path
  |> list.fold(
    map.new(),
    fn(paths, ltr) {
      case string.lowercase(ltr) == ltr {
        False -> paths
        True ->
          map.update(
            paths,
            ltr,
            fn(opt) {
              opt
              |> option.map(fn(v) { v + 1 })
              |> option.unwrap(1)
            },
          )
      }
    },
  )
  |> map.filter(fn(_, value) { value > 1 })
  |> map.size
}

pub fn has_no_lowercase_multiples(path: Path) -> Bool {
  multiple_lowercase_entries(path) == 0
}

pub fn has_only_one_lowercase_multiple(path: Path) -> Bool {
  multiple_lowercase_entries(path) <= 1
}

pub fn do_get_all_paths(
  graph: Paths,
  current_path: Path,
  validate: fn(Path) -> Bool,
) -> List(Path) {
  let [last_node, ..] = current_path

  case map.get(graph, last_node) {
    // this should be "end", since it has no destinations
    Error(_) -> [current_path]
    Ok(destinations) ->
      destinations
      |> iterator.from_list
      |> iterator.map(fn(destination) { [destination, ..current_path] })
      |> iterator.filter(validate)
      |> iterator.fold(
        [],
        fn(paths, path) {
          graph
          |> do_get_all_paths(path, validate)
          |> list.append(paths, _)
        },
      )
  }
}

pub fn get_all_paths(graph: Paths, validate: fn(Path) -> Bool) -> List(Path) {
  graph
  |> do_get_all_paths(["start"], validate)
  |> list.map(list.reverse)
}

pub fn get_data() -> Paths {
  assert Ok(data) = read_file("src/days/twelve.txt")

  parse_input(data)
}

pub fn part_one() {
  get_data()
  |> get_all_paths(has_no_lowercase_multiples)
  |> list.length
  |> io.debug

  Nil
}

pub fn part_two() {
  get_data()
  |> get_all_paths(has_only_one_lowercase_multiple)
  |> list.length
  |> io.debug

  Nil
}
