require 'minitest/autorun'

class SignalThing
  attr_reader :input_data, :signal_length, :packet

  def initialize(input_data:, signal_length:)
    @input_data = input_data
    @signal_length = signal_length
    @packet = []
  end

  def run
    input_data.each_char.with_index do |x, i|
      if packet.length < signal_length
        packet << x
        next
      end
      return i if packet & packet == packet

      (packet << x).shift
    end
  end

  class SignalThingTest < Minitest::Test
    def test_the_test_data_for_part_one
      test_cases = [
        { data: 'mjqjpqmgbljsphdztnvjfqwrcgsmlb', expected: 7 },
        { data: 'bvwbjplbgvbhsrlpgdmjqwftvncz', expected: 5 },
        { data: 'nppdvjthqldpwncqszvftbrmjlhg', expected: 6 },
        { data: 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg', expected: 10 },
        { data: 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw', expected: 11 },
      ]

      test_cases.each do |test_case|
        signal_thing = SignalThing.new(input_data: test_case[:data], signal_length: 4)
        assert_equal(test_case[:expected], signal_thing.run, "#{test_case[:data]} was wrong...")
      end
    end

    def test_the_test_data_for_part_two
      test_cases = [
        { data: 'mjqjpqmgbljsphdztnvjfqwrcgsmlb', expected: 19 },
        { data: 'bvwbjplbgvbhsrlpgdmjqwftvncz', expected: 23 },
        { data: 'nppdvjthqldpwncqszvftbrmjlhg', expected: 23 },
        { data: 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg', expected: 29 },
        { data: 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw', expected: 26 },
      ]

      test_cases.each do |test_case|
        signal_thing = SignalThing.new(input_data: test_case[:data], signal_length: 14)
        assert_equal(test_case[:expected], signal_thing.run, "#{test_case[:data]} was wrong...")
      end
    end
  end
end

input_data = File.read(File.join(__dir__, 'input.dat'))
lengths = [4, 14]

lengths.each do |signal_length|
  signal_thing = SignalThing.new(input_data:, signal_length:)
  part = signal_length == 4 ? "One" : "Two"
  puts "Part #{part} Answer: #{signal_thing.run}"
end
