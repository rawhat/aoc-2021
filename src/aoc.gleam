import gleam/io
import util

pub fn main() {
  let res = util.read_lines("/home/alex/gleams/aoc-2021/src/aoc.gleam")
  io.debug(res)
  io.println("Hello from aoc!")
}
