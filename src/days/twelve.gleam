import gleam/io
import gleam/iterator
import gleam/list
import gleam/map.{Map}
import gleam/pair
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
  |> iterator.group(by: pair.first)
  |> map.map_values(fn(_, pairs) { list.map(pairs, pair.second) })
}

pub fn get_lowercase(path: Path) -> Path {
  list.filter(path, fn(letter) { string.lowercase(letter) == letter })
}

pub fn has_no_lowercase_multiples(path: Path) -> Bool {
  let lowercase_letters = get_lowercase(path)

  let unique_lowercase =
    lowercase_letters
    |> list.unique
    |> list.length

  list.length(lowercase_letters) == unique_lowercase
}

pub fn has_only_one_lowercase_multiple(path: Path) -> Bool {
  let lowercase_letters = get_lowercase(path)

  let unique_lowercase =
    lowercase_letters
    |> list.unique
    |> list.length

  let lowercase_count = list.length(lowercase_letters)
  let with_one_duplicate = lowercase_count - 1

  lowercase_count == unique_lowercase || with_one_duplicate == unique_lowercase
}

pub fn do_get_all_paths(
  graph: Paths,
  current_path: Path,
  validate: fn(Path) -> Bool,
) -> List(Path) {
  let [last_node, ..] = current_path

  case map.get(graph, last_node) {
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
