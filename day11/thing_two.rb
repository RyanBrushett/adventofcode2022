require 'minitest/autorun'

class ThingTwo
  attr_accessor :monkeys

  MONKEY_ID_REGEX = %r{Monkey\s(?<id>\d+):}

  def parse(data)
    monkeys = []
    monkeys_data = data.split("\n\n")
    monkeys_data.each do |monke|
      attributes = monke.split("\n")
      matches = attributes.first.match(MONKEY_ID_REGEX)
      monkey = Monkey.new(matches[:id].to_i)
      attributes.each do |attribute|
        attribute = attribute.strip
        if attribute.start_with?("Starting items:")
          monkey.items = attribute.split("Starting items: ").last.split(", ").map(&:to_i)
        end
        if attribute.start_with?("Operation: ")
          monkey.operation = attribute.split("Operation: ").last.split("new = ").last
        end
        if attribute.start_with?("Test: divisible by ")
          monkey.test = attribute.split("Test: divisible by ").last.to_i
        end
        if attribute.start_with?("If true: throw to monkey ")
          monkey.true_case = attribute.split("If true: throw to monkey ").last.to_i
        end
        if attribute.start_with?("If false: throw to monkey ")
          monkey.false_case = attribute.split("If false: throw to monkey ").last.to_i
        end
      end
      monkeys << monkey
    end
    @monkeys = monkeys
  end

  def call!
    worry_management_value = monkeys.map(&:test).reduce(:*)
    10000.times do
      monkeys.each do |monkey|
        while !monkey.items.empty? do
          monkey.inspect_count += 1
          item = monkey.items.shift
          op = []
          monkey.operation.split(" ").each do |i|
            case i
            when "old"
              op << item
            when "*", "+", "-", "/"
              op << i
            else
              op << i.to_i
            end
          end
          new_value = op[0].send(op[1].to_sym, op[2]) % worry_management_value
          target = if new_value % monkey.test == 0
            monkeys.find { |m| m.id == monkey.true_case }
          else
            monkeys.find { |m| m.id == monkey.false_case }
          end
          target.items << new_value
        end
      end
    end
  end

  class Monkey
    attr_accessor :id, :items, :operation, :test, :true_case, :false_case, :inspect_count
    def initialize(id)
      @id = id
      @inspect_count = 0
    end
  end

  class ThingTwoTest < Minitest::Test
    TEST_DATA = <<~DATA
      Monkey 0:
        Starting items: 79, 98
        Operation: new = old * 19
        Test: divisible by 23
          If true: throw to monkey 2
          If false: throw to monkey 3

      Monkey 1:
        Starting items: 54, 65, 75, 74
        Operation: new = old + 6
        Test: divisible by 19
          If true: throw to monkey 2
          If false: throw to monkey 0

      Monkey 2:
        Starting items: 79, 60, 97
        Operation: new = old * old
        Test: divisible by 13
          If true: throw to monkey 1
          If false: throw to monkey 3

      Monkey 3:
        Starting items: 74
        Operation: new = old + 3
        Test: divisible by 17
          If true: throw to monkey 0
          If false: throw to monkey 1
    DATA

    def test_run
      thing = ThingTwo.new
      thing.parse(TEST_DATA)
      thing.call!
      inspect_count = thing.monkeys.map { |monkey| monkey.inspect_count }.max(2)
      assert_equal 2713310158, inspect_count.reduce(:*)
    end
  end
end

thing = ThingTwo.new
thing.parse(File.read(File.join(__dir__, "input.dat")))
thing.call!
monkey_biz = thing.monkeys.map { |monkey| monkey.inspect_count }.max(2).reduce(:*)

puts ""
puts ""
puts "Monkey Business: #{monkey_biz}"
