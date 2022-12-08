require 'minitest/autorun'
require 'matrix'

class Thing
  attr_reader :grid, :vis_count

  def initialize
    @grid = []
    @vis_count = 0
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
      if edge?(x, y)
        @vis_count += 1
        next
      end
      next if hidden?(e, x, y, mtx.row(x), mtx.column(y))
      @vis_count += 1
    end
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
  end
end

input_data = File.read(File.join(__dir__, "input.dat"))
thing = Thing.new
thing.run(input_data)
puts ""
puts ""
puts "Part 1: #{thing.vis_count}"
