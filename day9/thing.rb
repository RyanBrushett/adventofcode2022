require 'minitest/autorun'

class Thing
  attr_reader :head, :tail, :tail_visited_locations
  def initialize
    @head = Point.new
    @tail = Point.new
    @tail_visited_locations = [] << @tail.location
  end

  class Point
    attr_accessor :x, :y
    def initialize(x: 0, y: 0)
      @x = x
      @y = y
    end

    def jump_to(x:, y:)
      @x = x
      @y = y
    end

    def location
      {x: x, y: y}
    end

    def move(direction)
      case direction
      when "U"
        @y += 1
      when "L"
        @x -= 1
      when "R"
        @x += 1
      when "D"
        @y -= 1
      when "UR"
        @x += 1
        @y += 1
      when "UL"
        @x -= 1
        @y += 1
      when "DR"
        @x += 1
        @y -= 1
      when "DL"
        @x -= 1
        @y -= 1
      else
        "wat"
      end
    end

    def touching?(p)
      # X-axis is the same
      return true if x == p.x && y == p.y || x == p.x && y == p.y - 1 || x == p.x && y == p.y + 1
      # Y-axis is the same
      return true if y == p.y && x == p.x - 1 || y == p.y && x == p.x + 1
      # Diagonal touch. Boop!
      return true if [x - 1, y - 1] == [p.x, p.y] || [x + 1, y - 1] == [p.x, p.y] ||
        [x - 1, y + 1] == [p.x, p.y] || [x + 1, y + 1] == [p.x, p.y]
      false
    end
  end

  def call(line)
    direction, count = line.chomp.split(" ")
    count.to_i.times do
      head.move(direction)
      next if head.touching?(tail)
      big_jump = big_jump_calc(head, tail)
      big_jump.nil? ? tail.move(direction) : tail.move(big_jump)
      @tail_visited_locations |= [tail.location]
    end
  end

  def big_jump_calc(h, t)
    return "UR" if t.x == h.x - 1 && t.y == h.y - 2
    return "UR" if t.x == h.x - 2 && t.y == h.y - 1
    return "UL" if t.x == h.x + 1 && t.y == h.y - 2
    return "UL" if t.x == h.x + 2 && t.y == h.y - 1
    return "DR" if t.x == h.x - 1 && t.y == h.y + 2
    return "DR" if t.x == h.x - 2 && t.y == h.y + 1
    return "DL" if t.x == h.x + 1 && t.y == h.y + 2
    return "DL" if t.x == h.x + 2 && t.y == h.y + 1
    nil
  end

  class ThingTest < Minitest::Test
    def test_point_touching
      p1 = Point.new(x: 2, y: 2)
      p2 = Point.new(x: 2, y: 2)
      assert p1.touching?(p2)
      p2.jump_to(x: 0, y: 0)
      refute p1.touching?(p2)
      p2.jump_to(x: 2, y: 1)
      assert p1.touching?(p2)
      p2.jump_to(x: 2, y: 3)
      assert p1.touching?(p2)
      p2.jump_to(x: 1, y: 2)
      assert p1.touching?(p2)
      p2.jump_to(x: 3, y: 2)
      assert p1.touching?(p2)
      p2.jump_to(x: 3, y: 3)
      assert p1.touching?(p2)
      p2.jump_to(x: 1, y: 3)
      assert p1.touching?(p2)
      p2.jump_to(x: 3, y: 1)
      assert p1.touching?(p2)
      p2.jump_to(x: 1, y: 1)
      assert p1.touching?(p2)
    end

    def test_point_move
      p1 = Point.new
      p1.move("U")
      assert_equal({x: 0, y: 1}, p1.location)
      p1.move("R")
      assert_equal({x: 1, y: 1}, p1.location)
      p1.move("D")
      assert_equal({x: 1, y: 0}, p1.location)
      p1.move("L")
      assert_equal({x: 0, y: 0}, p1.location)
      p1.move("UR")
      assert_equal({x: 1, y: 1}, p1.location)
      p1.move("DR")
      assert_equal({x: 2, y: 0}, p1.location)
      p1.move("UL")
      assert_equal({x: 1, y: 1}, p1.location)
      p1.move("DL")
      assert_equal({x: 0, y: 0}, p1.location)
    end

    def test_the_test_data
      data = <<~DATA
        R 4
        U 4
        L 3
        D 1
        R 4
        D 1
        L 5
        R 2
      DATA
      thing = Thing.new
      assert_equal 1, thing.tail_visited_locations.size
      assert_equal({x: 0, y: 0}, thing.tail_visited_locations.first)
      data.each_line do |line|
        thing.call(line)
      end
      assert_equal 13, thing.tail_visited_locations.size
    end
  end
end

thing = Thing.new

File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
  thing.call(line)
end

puts ""
puts ""
puts "Part 1: #{thing.tail_visited_locations.size}"
