require 'minitest/autorun'

class ThingOne
  attr_reader :packets

  class Packet
    include Comparable

    attr_reader :data
    def initialize(data)
      @data = data.map { |x| x.freeze}.freeze
    end

    def <=>(other_packet)
      return 0 if self.data == other_packet.data
      left_copy = Marshal.load(Marshal.dump(self.data))
      right_copy = Marshal.load(Marshal.dump(other_packet.data))
      compare_packets(left_copy, right_copy)
    end

    private

    def compare_packets(left, right)
      return -1 if left.empty? && !right.empty?
      return 1 if right.empty? && !left.empty?

      left_item = left.shift
      right_item = right.shift

      case left_item
      when Integer
        if right_item.is_a?(Integer)
          res = left_item <=> right_item
          case res
          when -1
            return -1
          when 0
            compare_packets(left, right)
          when 1
            return 1
          end
        elsif right_item.is_a?(Array) # Left is integer, right is list
          left.unshift([left_item])
          right.unshift(right_item)
          compare_packets(left, right)
        elsif right_item.nil?
          return 1
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
  end

  def initialize
    @packets = []
    @results = []
  end

  def parse_and_run_pt_one(input)
    pairs = input.chomp.split("\n\n")
    pairs.each_with_index do |pair, i|
      left, right = pair.split("\n").map { |packet| Packet.new(eval(packet)) }
      @results << i + 1 if left < right
    end
    @results.sum
  end

  def parse_and_run_pt_two(input)
    input += <<~DATA
      [[2]]
      [[6]]
    DATA
    raw_packets = input.chomp.split("\n").reject(&:empty?)
    @packets = raw_packets.map { |raw_packet| Packet.new(eval(raw_packet)) }
    sorted = @packets.sort
    low = sorted.find_index { |packet| packet.data == [[2]] } + 1
    high = sorted.find_index { |packet| packet.data == [[6]] } + 1
    low * high
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
      result = thing.parse_and_run_pt_one(small_test_input)
      assert_equal 3, result
    end

    def test_some_more_test_data
      small_test_input = <<~DATA
        []
        [3]
      DATA

      thing = ThingOne.new
      result = thing.parse_and_run_pt_one(small_test_input)
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
      result = thing.parse_and_run_pt_one(small_test_input)
      assert_equal 1, result
    end

    def test_the_test_data
      thing = ThingOne.new
      result = thing.parse_and_run_pt_one(INPUT_DATA)
      assert_equal 13, result
    end

    def test_known_from_part_one
      input = File.read(File.join(__dir__, "input.dat"))
      thing = ThingOne.new
      result = thing.parse_and_run_pt_one(input)
      assert_equal 5623, result
    end

    def test_part_two
      thing = ThingOne.new
      result = thing.parse_and_run_pt_two(INPUT_DATA)
      assert_equal 140, result
    end

    def test_known_from_part_two
      input = File.read(File.join(__dir__, "input.dat"))
      thing = ThingOne.new
      result = thing.parse_and_run_pt_two(input)
      assert_equal 20570, result
    end
  end
end

input = File.read(File.join(__dir__, "input.dat"))
thing = ThingOne.new
result_one = thing.parse_and_run_pt_one(input)
result_two = thing.parse_and_run_pt_two(input)
puts "Part 1: #{result_one}"
puts "Part 2: #{result_two}"
