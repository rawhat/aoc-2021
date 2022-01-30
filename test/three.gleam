import gleam/map
import days/three.{
  Binary, One, OxygenGenerator, Zero, count_bits, generate_binaries, get_equipment_rating,
  get_gamma_and_epsilon_rates, get_life_support_rating,
}
import gleeunit/should

const input = ["00100", "11110"]

const test_input = [
  "00100", "11110", "10110", "10111", "10101", "01111", "00111", "11100", "10000",
  "11001", "00010", "01010",
]

pub fn builds_binary_from_strings_test() {
  let binaries = generate_binaries(input)

  let expected = [
    Binary([Zero, Zero, One, Zero, Zero]),
    Binary([One, One, One, One, Zero]),
  ]

  should.equal(binaries, expected)
}

pub fn counts_bits_by_column_test() {
  let binaries = generate_binaries(input)
  let counts = count_bits(binaries)

  let expected = [#(1, 1), #(1, 1), #(0, 2), #(1, 1), #(2, 0)]

  should.equal(counts, expected)
}

pub fn rates_test() {
  let binaries = generate_binaries(test_input)
  let counts = count_bits(binaries)
  let rates = get_gamma_and_epsilon_rates(counts)

  let expected = #(
    Binary([One, Zero, One, One, Zero]),
    Binary([Zero, One, Zero, Zero, One]),
  )

  should.equal(rates, expected)
}

pub fn oxygen_rating_test() {
  let binaries = generate_binaries(test_input)

  let oxygen_rating = get_equipment_rating(binaries, 0, OxygenGenerator)

  let expected = Binary([One, Zero, One, One, One])

  should.equal(oxygen_rating, expected)
}

pub fn part_two_test() {
  let life_support_rating = get_life_support_rating(test_input)

  should.equal(life_support_rating, 230)
}
