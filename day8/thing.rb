require 'minitest/autorun'
require 'matrix'

class Thing
  attr_reader :grid, :vis_count, :highest_look_score

  def initialize(part: "one")
    @grid = []
    @vis_count = 0
    @highest_look_score = 0
    @part = part
  end

  def run(data)
    data.each_line do |line|
      grid << line.chomp.split('').map(&:to_i)
    end

    vis_count = 0
    mtx = Matrix.rows(grid)
    @x_max = mtx.row_count - 1
    @y_max = mtx.column_count - 1

    mtx.each_with_index do |e, x, y|
      case @part
      when "one"
        if edge?(x, y)
          @vis_count += 1
          next
        end
        next if hidden?(e, x, y, mtx.row(x), mtx.column(y))
        @vis_count += 1
      when "two"
        look_score = calc_look_score(e, x, y, mtx)
        @highest_look_score = look_score > highest_look_score ? look_score : highest_look_score
      else
        "wat"
      end
    end
  end

  def calc_look_score(e, x, y, mtx)
    look_left = 0
    look_right = 0
    look_up = 0
    look_down = 0
    row = mtx.row(x)
    column = mtx.column(y)

    (y).downto(0).each do |i|
      next if y == i
      look_left += 1
      break if row[i] >= e
    end

    row[y + 1..].each do |i|
      look_right += 1
      break if i >= e
    end

    (x).downto(0).each do |i|
      next if x == i
      look_up += 1
      break if column[i] >= e
    end

    column[x + 1..].each do |i|
      look_down += 1
      break if i >= e
    end

    look_down * look_left * look_right * look_up
  end

  def edge?(x, y)
    x == 0 || y == 0 || x == @x_max || y == @y_max
  end

  def hidden?(e, x, y, row, column)
    check_hidden_left = column[0..x - 1].any? { |i| i >= e }
    check_hidden_right = column[x + 1..].any? { |i| i >= e }
    check_hidden_up = row[0..y - 1].any? { |i| i >= e }
    check_hidden_down = row[y + 1..].any? { |i| i >= e }
    check_hidden_up && check_hidden_down && check_hidden_left && check_hidden_right
  end

  class TestThing < Minitest::Test
    def test_data
      data = <<~DATA
        012
        345
        678
      DATA
      thing = Thing.new
      thing.run(data)
      refute thing.edge?(1, 1)
      assert thing.edge?(0, 0)
      assert thing.edge?(2, 2)
    end

    def test_the_test_data
      data = <<~DATA
        30373
        25512
        65332
        33549
        35390
      DATA

      thing = Thing.new
      thing.run(data)
      assert_equal 21, thing.vis_count
    end

    def test_the_test_data_part_two
      data = <<~DATA
        30373
        25512
        65332
        33549
        35390
      DATA

      thing = Thing.new(part: "two")
      thing.run(data)
      assert_equal 8, thing.highest_look_score
    end
  end
end

input_data = File.read(File.join(__dir__, "input.dat"))
thing_one = Thing.new
thing_two = Thing.new(part: "two")
thing_one.run(input_data)
thing_two.run(input_data)
puts ""
puts ""
puts "Part 1: #{thing_one.vis_count}"
puts "Part 2: #{thing_two.highest_look_score}"
puts ""
puts ""
