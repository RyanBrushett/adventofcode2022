require 'set'

class Thing2
  attr_reader :visits, :knots
  def initialize
    @knots = []
    10.times { @knots << Knot.new({ x: 0, y: 0 }) }
    @visits = Set[]
  end

  class Knot
    attr_accessor :next, :location
    def initialize(location)
      @location = location
    end
  end

  def touching?(head, tail)
    return true if head[:x] == tail[:x] && head[:y] == tail[:y]
    return true if head[:x] == tail[:x] && (head[:y] - tail[:y]).abs == 1
    return true if head[:y] == tail[:y] && (head[:x] - tail[:x]).abs == 1
    return true if (head[:x] - tail[:x]).abs == 1 && (head[:y] - tail[:y]).abs == 1
    false
  end

  # Rather than reacting to the movements of the knot ahead,
  # drag along the knot behind accordingly.
  def move_next(loc, next_loc)
    diff_x = loc[:x] - next_loc[:x]
    diff_y = loc[:y] - next_loc[:y]

    if diff_x.abs >= 2
      next_loc[:x] += diff_x / diff_x.abs
      next_loc[:y] += diff_y / diff_y.abs if diff_y.abs > 0
    else
      next_loc[:y] += diff_y / diff_y.abs
      next_loc[:x] += diff_x / diff_x.abs if diff_x.abs > 0
    end

    next_loc
  end

  def run
    # Keep track of the next knot from H -> T
    next_knot = nil
    knots.reverse.each do |knot|
      knot.next = next_knot
      next_knot = knot
    end

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      direction, count = line.split(" ")

      count.to_i.times do
        head = knots.first
        case direction
        when "L"
          head.location[:x] -= 1
        when "R"
          head.location[:x] += 1
        when "U"
          head.location[:y] += 1
        when "D"
          head.location[:y] -= 1
        else
          "wat"
        end

        knots.each do |knot|
          if knot.next.nil? # Is tail
            visits.add([knot.location[:x], knot.location[:y]])
          else
            loc = knot.location
            next_loc = knot.next.location
            knot.next.location = move_next(loc, next_loc) unless touching?(loc, next_loc)
          end
        end
      end
    end

    visits.size
  end
end

puts "Part 2: #{Thing2.new.run}"
