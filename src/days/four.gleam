import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/pair
import gleam/result
import gleam/set.{Set}
import gleam/string
import matrix.{Matrix, Point}
import util.{read_file}

pub type Board {
  Board(matrix: Matrix(Int), marked: Set(Point), won: Option(Int))
}

pub type Bingo {
  Bingo(numbers: List(Int), boards: List(Board))
}

pub fn build_board(input: String) -> Board {
  let board =
    input
    |> matrix.from_string
    |> matrix.to_iterator
    |> iterator.map(fn(p) {
      p
      |> pair.map_second(int.parse)
      |> pair.map_second(result.unwrap(_, 0))
    })
    |> matrix.from_iterator

  Board(board, set.new(), None)
}

pub fn parse_input(input: String) -> Bingo {
  assert Ok(#(numbers, boards)) = string.split_once(input, on: "\n")

  let bingo_numbers =
    numbers
    |> string.split(on: ",")
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))

  let bingo_boards =
    boards
    |> string.trim
    |> string.split(on: "\n\n")
    |> list.map(build_board)

  Bingo(bingo_numbers, bingo_boards)
}

pub fn mark_matching(board: Board, number: Int) -> Board {
  let Board(m, marked, won) = board
  let found =
    m
    |> matrix.to_iterator
    |> iterator.find(fn(tup) {
      case tup {
        #(_, value) if value == number -> True
        _ -> False
      }
    })

  case found {
    Ok(#(position, _)) -> Board(m, set.insert(marked, position), won)
    _ -> board
  }
}

pub fn mark_winner(board: Board, number: Int) -> Board {
  let Board(m, marked, _) = board

  let winner =
    matrix.rows(m)
    |> list.append(matrix.columns(m))
    |> list.find(fn(nums) { list.all(nums, set.contains(marked, _)) })

  case winner {
    Ok(_) -> Board(m, marked, Some(number))
    _ -> board
  }
}

pub fn draw_number(bingo: Bingo) -> Bingo {
  let Bingo([number, ..remaining_numbers], boards) = bingo

  let new_boards =
    boards
    |> list.map(mark_matching(_, number))
    |> list.map(mark_winner(_, number))

  Bingo(remaining_numbers, new_boards)
}

pub fn calculate_score(board: Board) -> Int {
  assert Board(values, marked, Some(winning_number)) = board

  let unmarked =
    values
    |> matrix.to_iterator
    |> iterator.filter(fn(tup) {
      let #(pos, _) = tup
      set.contains(marked, pos) == False
    })
    |> iterator.fold(
      0,
      fn(acc, tup) {
        let #(_, value) = tup
        acc + value
      },
    )

  unmarked * winning_number
}

pub fn calculate_winning_value(game: Bingo) -> Int {
  assert Ok(Ok(winner)) =
    game
    |> iterator.iterate(draw_number)
    |> iterator.map(fn(g) {
      let Bingo(_, boards) = g
      list.find(
        boards,
        fn(b) {
          case b {
            Board(_, _, Some(_)) -> True
            _ -> False
          }
        },
      )
    })
    |> iterator.drop_while(result.is_error)
    |> iterator.first

  calculate_score(winner)
}

pub fn calculate_last_winning_value(game: Bingo, player_count: Int) -> Int {
  #([], game)
  |> iterator.iterate(fn(tup) {
    let #(winners, game) = tup
    let Bingo(numbers, boards) = draw_number(game)

    let #(new_winners, losers) =
      list.partition(
        boards,
        fn(b) {
          case b {
            Board(_, _, Some(_)) -> True
            _ -> False
          }
        },
      )

    case list.length(new_winners) {
      0 -> #(winners, Bingo(numbers, boards))
      _ -> #(list.append(new_winners, winners), Bingo(numbers, losers))
    }
  })
  |> iterator.drop_while(fn(tup) {
    let winner_count =
      tup
      |> pair.first
      |> list.length

    winner_count != player_count
  })
  |> iterator.first
  |> result.map(pair.first)
  |> result.then(list.first)
  |> result.map(calculate_score)
  |> result.unwrap(-1)
}

pub fn calculate_last_winners_winning_value(game: Bingo) -> Int {
  let Bingo(_, boards) = game
  let player_count = list.length(boards)
  calculate_last_winning_value(game, player_count)
}

pub fn part_one() {
  assert Ok(text) = read_file("src/days/four.txt")
  let game = parse_input(text)

  game
  |> calculate_winning_value
  |> io.debug

  Nil
}

pub fn part_two() {
  assert Ok(text) = read_file("src/days/four.txt")
  let game = parse_input(text)

  game
  |> calculate_last_winners_winning_value
  |> io.debug

  Nil
}
