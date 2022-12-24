require 'minitest/autorun'
require 'pry-byebug'

class Thing
  attr_reader :sensors
  COORDINATE_REGEX = %r{^Sensor at x=(?<sensor_x>-?\d+), y=(?<sensor_y>-?\d+): closest beacon is at x=(?<beacon_x>-?\d+), y=(?<beacon_y>-?\d+)}

  def initialize
    @sensors = Set.new
  end

  def parse(input)
    lines = input.chomp.split("\n")
    lines.each do |line|
      matches = line.match(COORDINATE_REGEX)
      beacon = Beacon.new(matches[:beacon_x].to_i, matches[:beacon_y].to_i)
      sensor = Sensor.new(matches[:sensor_x].to_i, matches[:sensor_y].to_i, beacon)
      @sensors.add(sensor)
    end
  end

  def find_sensor(x, y)
    @sensors.find { |sensor| sensor.point == [x, y]}
  end

  def find_by_beacon_point(x, y)
    @sensors.find { |sensor| sensor.beacon.point == [x, y]}
  end

  def num_in_row_covered(y)
    count = -1 # off-by-one errors are so bad.
    x_range = (min_x..max_x)
    x_range.each do |x|
      point = [x, y]
      @sensors.each do |sensor|
        if sensor.within_range?(*point)
          count += 1
          break
        end
      end
    end
    count
  end

  private

  def max_x
    @max_x ||= edge(axis: "x", extreme: :max)
  end

  def min_x
    @min_x ||= edge(axis: "x", extreme: :min)
  end

  def max_y
    @max_y ||= edge(axis: "y", extreme: :max)
  end

  def min_y
    @min_y ||= edge(axis: "y", extreme: :min)
  end

  def edge(axis:, extreme:)
    p = axis == "x" ? 0 : 1
    val = 0
    modifier = extreme == :min ? -1 : 1

    @sensors.each do |sensor|
      s = sensor.point[p] + (modifier * sensor.max_distance)
      b = sensor.beacon.point[p]  + (modifier * sensor.max_distance)
      val = [val, s, b].send(extreme)
    end
    val
  end

  class Sensor
    attr_reader :beacon, :max_distance

    def initialize(x, y, beacon)
      @x = x
      @y = y
      @beacon = beacon
      @max_distance = calc_max_distance
    end

    def point
      [@x, @y]
    end

    def within_range?(x, y)
      distance_from_point(x, y) <= @max_distance
    end

    private

    def distance_from_point(x, y)
      (@x - x).abs + (@y - y).abs
    end

    def calc_max_distance
      return @max_distance if @max_distance
      b_x = beacon.point[0]
      b_y = beacon.point[1]
      distance_from_point(b_x, b_y)
    end
  end

  class Beacon
    def initialize(x, y)
      @x = x
      @y = y
    end

    def point
      [@x, @y]
    end
  end

  class ThingTest < Minitest::Test
    INPUT_DATA = <<~DATA
      Sensor at x=2, y=18: closest beacon is at x=-2, y=15
      Sensor at x=9, y=16: closest beacon is at x=10, y=16
      Sensor at x=13, y=2: closest beacon is at x=15, y=3
      Sensor at x=12, y=14: closest beacon is at x=10, y=16
      Sensor at x=10, y=20: closest beacon is at x=10, y=16
      Sensor at x=14, y=17: closest beacon is at x=10, y=16
      Sensor at x=8, y=7: closest beacon is at x=2, y=10
      Sensor at x=2, y=0: closest beacon is at x=2, y=10
      Sensor at x=0, y=11: closest beacon is at x=2, y=10
      Sensor at x=20, y=14: closest beacon is at x=25, y=17
      Sensor at x=17, y=20: closest beacon is at x=21, y=22
      Sensor at x=16, y=7: closest beacon is at x=15, y=3
      Sensor at x=14, y=3: closest beacon is at x=15, y=3
      Sensor at x=20, y=1: closest beacon is at x=15, y=3
    DATA

    def test_some_test_input
      thing = Thing.new
      thing.parse(INPUT_DATA)
      assert_equal 14, thing.sensors.count
      assert_equal 26, thing.num_in_row_covered(10)
    end
  end
end

input = File.read(File.join(__dir__, "input.dat"))
thing = Thing.new
thing.parse(input)
puts "Part 1: #{thing.num_in_row_covered(2000000)}"
