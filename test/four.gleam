import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import gleeunit/should
import days/four.{Bingo, Board, mark_winner}
import matrix

const test_input = "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"

pub fn test_first_move_on_test_input_test() {
  let game = four.parse_input(test_input)
  let Bingo(_, boards) =
    iterator.range(0, 5)
    |> iterator.fold(game, fn(g, _) { four.draw_number(g) })

  let [marked_one, ..] =
    boards
    |> list.map(fn(board) {
      let Board(_, marked, _) = board
      marked
    })

  should.equal(
    marked_one,
    set.from_list([#(3, 0), #(3, 1), #(1, 2), #(4, 2), #(4, 3)]),
  )
}

pub fn mark_winner_with_valid_win_test() {
  let marked = set.from_list([#(0, 0), #(0, 1), #(0, 2), #(0, 3), #(0, 4)])

  let m =
    string.trim_left(
      "
14 21 17 24 4
10 16 15 9 19
18 8 23 26 20
22 11 13 6 5
2 0 12 3 7
",
    )
    |> matrix.from_string
    |> matrix.to_iterator
    |> iterator.map(fn(tup) { pair.map_second(tup, int.parse) })
    |> iterator.map(fn(tup) { pair.map_second(tup, result.unwrap(_, 0)) })
    |> matrix.from_iterator

  let winning_board = Board(m, marked, None)

  let Board(_, _, won) = mark_winner(winning_board, 123456)

  should.equal(won, Some(123456))
}

pub fn get_winner_test() {
  let game = four.parse_input(test_input)
  let value = four.calculate_winning_value(game)

  should.equal(value, 4512)
}

pub fn get_part_two_test() {
  let game = four.parse_input(test_input)
  let value = four.calculate_last_winners_winning_value(game)

  should.equal(value, 1924)
}
