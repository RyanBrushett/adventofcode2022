class SignalThing
  require 'minitest/autorun'
  def run(data)
    chars = []
    char_count = 0
    data.each_char.with_index do |x, i|
      if chars.length < 4
        chars << x
        next
      end
      return i if chars & chars == chars
      (chars << x).shift
    end
  end

  class SignalThingTest < Minitest::Test
    def test_the_test_data
      test_cases = [
        {data: "mjqjpqmgbljsphdztnvjfqwrcgsmlb", expected: 7},
        {data: "bvwbjplbgvbhsrlpgdmjqwftvncz", expected: 5},
        {data: "nppdvjthqldpwncqszvftbrmjlhg", expected: 6},
        {data: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", expected: 10},
        {data: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", expected: 11},
      ]

      test_cases.each do |test_case|
        assert_equal(
          test_case[:expected], SignalThing.new.run(test_case[:data]),
          "#{test_case[:data]} was wrong...",
        )
      end
    end
  end
end

puts ""
puts "Answer: #{SignalThing.new.run(File.read(File.join(__dir__, "input.dat")))}"
puts ""
