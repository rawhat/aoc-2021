import gleam/dynamic.{Dynamic}
import gleam/erlang/atom
import gleam/io
import gleam/option.{None, Option, Some}

pub external type Array(a)

external fn array_size(array: Array(a)) -> Int =
  "array" "size"

external fn new_array() -> Array(a) =
  "array" "new"

external fn array_from_list(l: List(a)) -> Array(a) =
  "array" "from_list"

external fn array_set(index: Int, value: a, arr: Array(a)) -> Array(a) =
  "array" "set"

external fn array_get(index: Int, arr: Array(a)) -> Dynamic =
  "array" "get"

external fn array_fold(
  reducer: fn(Int, a, b) -> b,
  initial: b,
  arr: Array(a),
) -> b =
  "array" "foldl"

external fn array_to_list(arr: Array(a)) -> List(a) =
  "array" "to_list"

external fn array_map(fn(Int, a) -> b, arr: Array(a)) -> Array(b) =
  "array" "map"

external fn array_to_tuple_list(arr: Array(a)) -> List(#(Int, a)) =
  "array" "to_orddict"

external fn array_from_tuple_list(l: List(#(Int, a))) -> Array(a) =
  "array" "from_orddict"

pub fn new() -> Array(a) {
  new_array()
}

pub fn from_list(l: List(a)) -> Array(a) {
  array_from_list(l)
}

pub fn to_list(arr: Array(a)) -> List(a) {
  array_to_list(arr)
}

pub fn size(arr: Array(a)) -> Int {
  array_size(arr)
}

pub fn set(arr: Array(a), index: Int, value: a) -> Array(a) {
  array_set(index, value, arr)
}

pub fn get(arr: Array(a), index: Int) -> Option(a) {
  let res = array_get(index, arr)

  assert Ok(undefined) = atom.from_string("undefined")

  case atom.from_dynamic(res) {
    Ok(value) if value == undefined -> None
    _ -> Some(dynamic.unsafe_coerce(res))
  }
}

pub fn fold(arr: Array(a), initial: b, reducer: fn(b, Option(a)) -> b) -> b {
  assert Ok(undefined) = atom.from_string("undefined")

  array_fold(
    fn(_, item, accum) {
      let dynamic_item =
        item
        |> dynamic.from
        |> atom.from_dynamic
      let item_value = case dynamic_item {
        Ok(value) if value == undefined -> None
        _ ->
          Some(
            item
            |> dynamic.from
            |> dynamic.unsafe_coerce,
          )
      }

      reducer(accum, item_value)
    },
    initial,
    arr,
  )
}

pub fn map(arr: Array(a), mapper: fn(a, Int) -> b) -> Array(b) {
  array_map(fn(index, item) { mapper(item, index) }, arr)
}

pub fn to_pairs(arr: Array(a)) -> List(#(Int, a)) {
  array_to_tuple_list(arr)
}

pub fn from_pairs(l: List(#(Int, a))) -> Array(a) {
  array_from_tuple_list(l)
}

pub fn push(arr: Array(a), value: a) -> Array(a) {
  let max = array_size(arr)
  set(arr, max, value)
}
