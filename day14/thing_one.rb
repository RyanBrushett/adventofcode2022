require 'minitest/autorun'
require 'pry-byebug'

class ThingOne
  attr_reader :rock_points, :sand_rest_points

  SAND_START = [500, 0]

  def initialize
    @rock_points = Set.new
    @sand_rest_points = Set.new
    @lowest_rock_point = [0,0]
  end

  def parse(input)
    lines = input.split("\n")
    point_collection = lines.map do |line|
      raw_points = line.split(" -> ")
      points = raw_points.map do |raw_point|
        x, y = raw_point.split(',')
        [x.to_i, y.to_i]
      end
      points.each_cons(2).each { |a, b| @rock_points.merge(interpolate(a, b)) }
    end
    @lowest_rock_point = @rock_points.max { |a, b| a[1] <=> b[1] }
  end

  def run_sand
    time_to_stop = false
    until time_to_stop
      grain = SAND_START
      loop do
        new_point = move_sand(grain)
        if new_point.nil?
          @sand_rest_points.add(grain)
          break
        end
        if new_point[1] > @lowest_rock_point[1]
          time_to_stop = true
          break
        end
        grain = new_point
      end
    end
  end

  def move_sand(grain)
    down_point = { down: [grain[0], grain[1] + 1] }
    left_down = { left_down: [grain[0] - 1, grain[1] + 1] }
    right_down = { right_down: [grain[0] + 1, grain[1] + 1] }

    direction = nil
    [down_point, left_down, right_down].each do |point|
      point.each do |k, v|
        direction = k unless @rock_points.include?(v) || @sand_rest_points.include?(v)
        break if direction
      end
      break if direction
    end

    case direction
    when :down
      down_point[direction]
    when :left_down
      left_down[:left_down]
    when :right_down
      right_down[:right_down]
    else
      nil
    end
  end

  private

  def interpolate(p1, p2)
    points = Set.new
    x_values = []
    y_values = []
    if p1[0] < p2[0]
      (p1[0]..p2[0]).each { |x| x_values << x }
    else
      p1[0].downto(p2[0]).sort.each { |x| x_values << x }
    end

    if p1[1] < p2[1]
      (p1[1]..p2[1]).each { |y| y_values << y }
    else
      p1[1].downto(p2[1]).sort.each { |y| y_values << y }
    end
    x_values.each do |x|
      y_values.each do |y|
        points.add([x, y])
      end
    end
    points
  end

  class ThingOneTest < Minitest::Test
    INPUT_DATA = <<~DATA
      498,4 -> 498,6 -> 496,6
      503,4 -> 502,4 -> 502,9 -> 494,9
    DATA

    def test_the_test_data
      thing = ThingOne.new
      thing.parse(INPUT_DATA)
      thing.run_sand
      assert_equal 24, thing.sand_rest_points.count
    end
  end
end

input = File.read(File.join(__dir__, "input.dat"))
thing = ThingOne.new
thing.parse(input)
thing.run_sand
puts "Part 1: #{thing.sand_rest_points.count}"
