require 'minitest/autorun'

class MySystem
  attr_reader :registers, :cycle_count, :instructions_queue, :current_instruction, :instruction_cycle_count, :sampled_values

  def initialize
    @registers = { x: 1 }
    @cycle_count = 0
    @instructions_queue = []
    @current_instruction = nil
    @instruction_cycle_count = 1
    @sampled_values = []
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

  def sample_cycle?
    [20, 60, 100, 140, 180, 220].include?(@cycle_count)
  end

  def call!
    loop do
      break if @current_instruction.nil? && @instructions_queue.empty?

      @cycle_count += 1
      @sampled_values << @registers[:x] * @cycle_count if sample_cycle?
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

  class MySystemTest < Minitest::Test
    def test_line_to_instruction
      sys = MySystem.new
      assert_equal({ op: "noop", reg: nil, value: 0 }, sys.line_to_instruction("noop"))
      assert_equal({ op: "add", reg: "x", value: 15 }, sys.line_to_instruction("addx 15"))
      assert_equal({ op: "add", reg: "x", value: -15 }, sys.line_to_instruction("addx -15"))
    end

    def test_the_small_test_data
      data = <<~DATA
        noop
        addx 3
        addx -5
      DATA

      sys = MySystem.new
      sys.make_instructions(data)
      sys.call!
      assert_equal 5, sys.cycle_count
      assert_equal -1, sys.registers[:x]
    end

    def test_the_bigger_data
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

      sys = MySystem.new
      sys.make_instructions(data)
      sys.call!
      assert_equal 13140, sys.sampled_values.sum
    end
  end
end

data = File.read(File.join(__dir__, "input.dat"))
sys = MySystem.new
sys.make_instructions(data)
sys.call!

puts ""
puts ""
puts "Part 1: #{sys.sampled_values.sum}"
