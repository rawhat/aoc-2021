import gleam/int
import gleam/io
import gleam/iterator.{Next}
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/result
import matrix.{Matrix, Point}
import util.{read_file}

pub type Octopus {
  Octopus(energy: Int, has_flashed: Bool)
}

pub type Cavern =
  Matrix(Octopus)

pub fn parse_energy_map(data: String) -> Cavern {
  data
  |> matrix.from_digit_map
  |> matrix.to_iterator
  |> iterator.map(fn(p) {
    let #(pos, value) = p
    assert Ok(energy) = int.parse(value)
    #(pos, Octopus(energy, False))
  })
  |> matrix.from_iterator
}

pub fn increment_energy(cavern: Cavern) -> Cavern {
  cavern
  |> matrix.to_iterator
  |> iterator.map(fn(entry) {
    let #(pos, Octopus(energy, _)) = entry
    #(pos, Octopus(energy + 1, False))
  })
  |> matrix.from_iterator
}

pub fn increment_energies(cavern: Cavern, points: List(Point)) -> Cavern {
  list.fold(
    points,
    cavern,
    fn(curr, point) {
      matrix.update(
        curr,
        point,
        fn(opt) {
          let Some(Octopus(energy, has_flashed) as octo) = opt
          case has_flashed {
            False -> Octopus(energy + 1, False)
            _ -> octo
          }
        },
      )
    },
  )
}

pub fn find_flashes(cavern: Cavern) -> List(Point) {
  cavern
  |> matrix.to_iterator
  |> iterator.filter(fn(entry) {
    let #(_, Octopus(energy, has_flashed)) = entry
    energy > 9 && has_flashed == False
  })
  |> iterator.map(pair.first)
  |> iterator.to_list
}

pub fn make_flash(cavern: Cavern, point: Point) -> Cavern {
  matrix.update(
    cavern,
    point,
    fn(opt) {
      assert Some(Octopus(_, False)) = opt

      Octopus(0, True)
    },
  )
}

pub fn do_flashes(
  cavern: Cavern,
  to_flash: List(Point),
  flashes: List(Point),
) -> #(List(Point), Cavern) {
  case to_flash {
    [] -> #(flashes, cavern)
    [flash, ..next_flashes] ->
      case matrix.get(cavern, flash), list.contains(flashes, flash) {
        Some(Octopus(_, True)), _ | _, True ->
          do_flashes(cavern, next_flashes, flashes)
        _, _ -> {
          let flashed = make_flash(cavern, flash)
          let adjacents =
            flashed
            |> matrix.get_adjacents(flash, with_diagonal: True)
            |> list.map(pair.first)
          let incremented = increment_energies(flashed, adjacents)
          let new_flashes =
            adjacents
            |> list.filter_map(fn(pos) {
              case matrix.get(incremented, pos) {
                Some(Octopus(energy, False)) if energy > 9 -> Ok(pos)
                _ -> Error(Nil)
              }
            })
          do_flashes(
            incremented,
            list.append(next_flashes, new_flashes),
            [flash, ..flashes],
          )
        }
      }
  }
}

pub fn do_iteration(cavern: Cavern) -> #(List(Point), Cavern) {
  let incremented = increment_energy(cavern)

  incremented
  |> find_flashes
  |> do_flashes(incremented, _, [])
}

pub fn part_one() {
  assert Ok(data) = read_file("src/days/eleven.txt")

  let cavern = parse_energy_map(data)

  iterator.range(from: 0, to: 100)
  |> iterator.fold(
    #(0, cavern),
    fn(current, _) {
      let #(curr, cavern) = current
      let #(new_flashes, new_cavern) = do_iteration(cavern)

      #(curr + list.length(new_flashes), new_cavern)
    },
  )
  |> pair.first
  |> io.debug

  Nil
}

pub fn part_two() {
  assert Ok(data) = read_file("src/days/eleven.txt")

  let cavern = parse_energy_map(data)

  iterator.unfold(
    from: cavern,
    with: fn(current) {
      let new_cavern =
        current
        |> do_iteration
        |> pair.second

      Next(element: new_cavern, accumulator: new_cavern)
    },
  )
  |> iterator.take_while(fn(cavern) {
    cavern
    |> matrix.to_iterator
    |> iterator.any(fn(entry) {
      let #(_, Octopus(_, has_flashed)) = entry
      case has_flashed {
        False -> True
        True -> False
      }
    })
  })
  |> iterator.to_list
  |> list.length
  |> fn(l) { l + 1 }
  |> io.debug

  Nil
}
