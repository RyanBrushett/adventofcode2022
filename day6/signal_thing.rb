class SignalThing
  require 'minitest/autorun'

  def run(data, problem_part:)
    case problem_part
    when "one"
      signal_length = 4
    when "two"
      signal_length = 14
    else
      signal_length = "wat"
    end

    chars = []
    char_count = 0
    data.each_char.with_index do |x, i|
      if chars.length < signal_length
        chars << x
        next
      end
      return i if chars & chars == chars
      (chars << x).shift
    end
  end

  class SignalThingTest < Minitest::Test
    def test_the_test_data_for_part_one
      test_cases = [
        {data: "mjqjpqmgbljsphdztnvjfqwrcgsmlb", expected: 7},
        {data: "bvwbjplbgvbhsrlpgdmjqwftvncz", expected: 5},
        {data: "nppdvjthqldpwncqszvftbrmjlhg", expected: 6},
        {data: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", expected: 10},
        {data: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", expected: 11},
      ]

      test_cases.each do |test_case|
        assert_equal(
          test_case[:expected],
          SignalThing.new.run(test_case[:data], problem_part: "one"),
          "#{test_case[:data]} was wrong...",
        )
      end
    end

    def test_the_test_data_for_part_two
      test_cases = [
        {data: "mjqjpqmgbljsphdztnvjfqwrcgsmlb", expected: 19},
        {data: "bvwbjplbgvbhsrlpgdmjqwftvncz", expected: 23},
        {data: "nppdvjthqldpwncqszvftbrmjlhg", expected: 23},
        {data: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", expected: 29},
        {data: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", expected: 26},
      ]

      test_cases.each do |test_case|
        assert_equal(
          test_case[:expected],
          SignalThing.new.run(test_case[:data], problem_part: "two"),
          "#{test_case[:data]} was wrong...",
        )
      end
    end
  end
end

input_data = File.read(File.join(__dir__, "input.dat"))
parts = %w(one two)

parts.each do |part|
  puts ""
  puts "Part #{part} Answer: #{SignalThing.new.run(input_data, problem_part: part)}"
  puts ""
end
