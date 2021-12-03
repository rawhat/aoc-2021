import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/map.{Map}
import gleam/option.{None, Some}
import gleam/pair
import gleam/string
import util.{read_lines}

pub type BinaryValue {
  Zero
  One
}

pub type Binary {
  Binary(List(BinaryValue))
}

pub fn binary_to_decimal(binary: Binary) -> Int {
  let Binary(values) = binary

  values
  |> list.reverse
  |> list.index_fold(
    0.0,
    fn(current, digit, index) {
      let value = case digit {
        Zero -> 0.0
        One -> 1.0
      }
      let converted = value *. float.power(2.0, int.to_float(index))
      current +. converted
    },
  )
  |> float.round
}

pub fn generate_binaries(input: List(String)) -> List(Binary) {
  list.map(
    input,
    fn(row) {
      row
      |> string.trim
      |> string.to_graphemes
      |> list.map(fn(num) {
        case num {
          "0" -> Zero
          "1" -> One
        }
      })
      |> Binary
    },
  )
}

pub fn count_bits(binaries: List(Binary)) -> List(#(Int, Int)) {
  binaries
  |> list.fold(
    map.new(),
    fn(m, binary) {
      let Binary(values) = binary

      list.index_fold(
        values,
        m,
        fn(m, value, position) {
          map.update(
            m,
            position,
            fn(existing) {
              case value, existing {
                Zero, None -> #(1, 0)
                One, None -> #(0, 1)
                Zero, Some(tup) -> pair.map_first(tup, fn(v) { v + 1 })
                One, Some(tup) -> pair.map_second(tup, fn(v) { v + 1 })
              }
            },
          )
        },
      )
    },
  )
  |> map.to_list
  |> list.sort(fn(i, j) { int.compare(pair.first(i), pair.first(j)) })
  |> list.map(pair.second)
}

pub fn get_gamma_and_epsilon_rates(
  counts: List(#(Int, Int)),
) -> #(Binary, Binary) {
  counts
  |> list.fold(
    #([], []),
    fn(rates, counts) {
      let #(gamma, epsilon) = rates
      case counts {
        #(zeroes, ones) if zeroes > ones -> #([Zero, ..gamma], [One, ..epsilon])
        _ -> #([One, ..gamma], [Zero, ..epsilon])
      }
    },
  )
  |> pair.map_first(fn(l) {
    l
    |> list.reverse
    |> Binary
  })
  |> pair.map_second(fn(l) {
    l
    |> list.reverse
    |> Binary
  })
}

pub fn part_one() {
  assert Ok(lines) = read_lines("./src/days/three.txt")

  lines
  |> generate_binaries
  |> count_bits
  |> get_gamma_and_epsilon_rates
  |> fn(tup) {
    let #(gamma, epsilon) = tup

    binary_to_decimal(gamma) * binary_to_decimal(epsilon)
  }
  |> io.debug

  Nil
}

pub type Equipment {
  OxygenGenerator
  CO2Scrubber
}

pub fn get_equipment_rating(
  binaries: List(Binary),
  index: Int,
  equipment: Equipment,
) -> Binary {
  case binaries {
    [rating] -> rating
    candidates -> {
      let counts = count_bits(binaries)
      assert Ok(count) = list.at(counts, index)
      let match = case count, equipment {
        #(zeroes, ones), OxygenGenerator if ones >= zeroes -> One
        _, OxygenGenerator -> Zero
        #(zeroes, ones), CO2Scrubber if zeroes <= ones -> Zero
        _, CO2Scrubber -> One
      }
      let valid_candidates =
        list.filter(
          candidates,
          fn(candidate) {
            let Binary(values) = candidate
            assert Ok(value) = list.at(values, index)
            value == match
          },
        )
      get_equipment_rating(valid_candidates, index + 1, equipment)
    }
  }
}

pub fn get_life_support_rating(lines: List(String)) -> Int {
  let binaries = generate_binaries(lines)

  let oxygen_rating = get_equipment_rating(binaries, 0, OxygenGenerator)
  let co2_rating = get_equipment_rating(binaries, 0, CO2Scrubber)

  binary_to_decimal(oxygen_rating) * binary_to_decimal(co2_rating)
}

pub fn part_two() {
  assert Ok(lines) = read_lines("./src/days/three.txt")

  let life_support_rating = get_life_support_rating(lines)

  io.debug(life_support_rating)

  Nil
}
