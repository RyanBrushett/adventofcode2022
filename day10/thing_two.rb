require 'minitest/autorun'

class MySystemTwo
  attr_reader :registers, :cycle_count, :instructions_queue, :current_instruction, :instruction_cycle_count

  def initialize
    @registers = { x: 1 }
    @cycle_count = 0
    @instructions_queue = []
    @current_instruction = nil
    @instruction_cycle_count = 1
  end

  def make_instructions(data)
    data.each_line do |line|
      instruction = line_to_instruction(line.strip)
      @instructions_queue.unshift(instruction)
    end
  end

  def reset_instruction
    @instruction_cycle_count = 1
    @current_instruction = nil
  end

  def line_to_instruction(line)
    if line.start_with?("noop")
      { op: "noop", reg: nil, value: 0 }
    elsif line.start_with?("add")
      i, val = line.split(" ")
      { op: "add", reg: i.chars.last, value: val.to_i }
    end
  end

  def call!
    loop do
      break if @current_instruction.nil? && @instructions_queue.empty?

      x_val = @registers[:x]
      if (x_val - 1..x_val + 1).include?(cycle_count % 40)
        print "#"
      else
        print "."
      end

      @cycle_count += 1
      print "\n" if (cycle_count % 40).zero?

      @current_instruction = @instructions_queue.pop if @current_instruction.nil?

      case @current_instruction[:op]
      when "noop"
        reset_instruction
      when "add"
        if @instruction_cycle_count != 2 # Operation takes two cycles to finish
          @instruction_cycle_count += 1
          next
        end
        target = @current_instruction[:reg]
        @registers[target.to_sym] += @current_instruction[:value]
        reset_instruction
      else
        'wat'
      end
    end
  end

  class MySystemTwoTest < Minitest::Test
    def test_some_drawing
      data = <<~DATA
        addx 15
        addx -11
        addx 6
        addx -3
        addx 5
        addx -1
        addx -8
        addx 13
        addx 4
        noop
        addx -1
        addx 5
        addx -1
        addx 5
        addx -1
        addx 5
        addx -1
        addx 5
        addx -1
        addx -35
        addx 1
        addx 24
        addx -19
        addx 1
        addx 16
        addx -11
        noop
        noop
        addx 21
        addx -15
        noop
        noop
        addx -3
        addx 9
        addx 1
        addx -3
        addx 8
        addx 1
        addx 5
        noop
        noop
        noop
        noop
        noop
        addx -36
        noop
        addx 1
        addx 7
        noop
        noop
        noop
        addx 2
        addx 6
        noop
        noop
        noop
        noop
        noop
        addx 1
        noop
        noop
        addx 7
        addx 1
        noop
        addx -13
        addx 13
        addx 7
        noop
        addx 1
        addx -33
        noop
        noop
        noop
        addx 2
        noop
        noop
        noop
        addx 8
        noop
        addx -1
        addx 2
        addx 1
        noop
        addx 17
        addx -9
        addx 1
        addx 1
        addx -3
        addx 11
        noop
        noop
        addx 1
        noop
        addx 1
        noop
        noop
        addx -13
        addx -19
        addx 1
        addx 3
        addx 26
        addx -30
        addx 12
        addx -1
        addx 3
        addx 1
        noop
        noop
        noop
        addx -9
        addx 18
        addx 1
        addx 2
        noop
        noop
        addx 9
        noop
        noop
        noop
        addx -1
        addx 2
        addx -37
        addx 1
        addx 3
        noop
        addx 15
        addx -21
        addx 22
        addx -6
        addx 1
        noop
        addx 2
        addx 1
        noop
        addx -10
        noop
        noop
        addx 20
        addx 1
        addx 2
        addx 2
        addx -6
        addx -11
        noop
        noop
        noop
      DATA

      sys = MySystemTwo.new
      sys.make_instructions(data)
      sys.call!
    end
  end
end

data = File.read(File.join(__dir__, "input.dat"))
sys = MySystemTwo.new
sys.make_instructions(data)


puts ""
puts ""
puts "Part 2: #{sys.call!}"
