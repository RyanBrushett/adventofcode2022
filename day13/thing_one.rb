require 'minitest/autorun'

class ThingOne
  attr_reader :packets
  def initialize
    @packets = []
    @results = []
  end

  def parse_and_run(input)
    pairs = input.chomp.split("\n\n")
    pairs.each_with_index do |pair, i|
      @packets = []
      pair.split("\n").each do |packet|
        @packets << eval(packet)
      end
      left = @packets.first
      right = @packets.last
      @results << i + 1 if compare_packets(left, right)
    end
    @results.sum
  end

  def compare_packets(left, right)
    return true if left.empty? && !right.empty?
    return false if right.empty? && !left.empty?
    left_item = left.shift
    right_item = right.shift
    case left_item
    when Integer
      if right_item.is_a?(Integer)
        res = left_item <=> right_item
        case res
        when -1
          return true
        when 0
          compare_packets(left, right)
        when 1
          return false
        end
      elsif right_item.is_a?(Array) # Left is integer, right is list
        left.unshift([left_item])
        right.unshift(right_item)
        compare_packets(left, right)
      elsif right_item.nil?
        return false
      end
    when Array
      if right_item.is_a?(Array)
        result = compare_packets(left_item, right_item)
        return result unless result.nil?
        compare_packets(left, right)
      else
        left.unshift(left_item)
        right.unshift([right_item])
        compare_packets(left, right)
      end
    end
  end

  class ThingOneTest < Minitest::Test
    INPUT_DATA = <<~DATA
      [1,1,3,1,1]
      [1,1,5,1,1]

      [[1],[2,3,4]]
      [[1],4]

      [9]
      [[8,7,6]]

      [[4,4],4,4]
      [[4,4],4,4,4]

      [7,7,7,7]
      [7,7,7]

      []
      [3]

      [[[]]]
      [[]]

      [1,[2,[3,[4,[5,6,7]]]],8,9]
      [1,[2,[3,[4,[5,6,0]]]],8,9]
    DATA

    def test_some_test_data
      small_test_input = <<~DATA
        [1,1,3,1,1]
        [1,1,5,1,1]

        [[1],[2,3,4]]
        [[1],4]
      DATA

      thing = ThingOne.new
      result = thing.parse_and_run(small_test_input)
      assert_equal 3, result
    end

    def test_some_more_test_data
      small_test_input = <<~DATA
        []
        [3]
      DATA

      thing = ThingOne.new
      result = thing.parse_and_run(small_test_input)
      assert_equal 1, result
    end

    def test_even_more_test_data
      small_test_input = <<~DATA
        [[4,4],4,4]
        [[4,4],4,4,4]

        [7,7,7,7]
        [7,7,7]
      DATA

      thing = ThingOne.new
      result = thing.parse_and_run(small_test_input)
      assert_equal 1, result
    end

    def test_the_test_data
      thing = ThingOne.new
      result = thing.parse_and_run(INPUT_DATA)
      assert_equal 13, result
    end
  end
end

input = File.read(File.join(__dir__, "input.dat"))
thing = ThingOne.new
result = thing.parse_and_run(input)
puts ""
puts ""
puts "Part 1: #{result}"
