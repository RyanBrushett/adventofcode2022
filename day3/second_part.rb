class SecondPart
  def self.run
    letters = ('a'..'z').to_a.concat(('A'..'Z').to_a)
    priorities = letters.each_with_object({}).with_index do |(letter, hash), index|
      hash[letter] = index + 1
    end
    sum = 0
    count = 0
    lines = []

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      lines << line.chomp
      count += 1
      next unless count == 3

      common_item = (lines[0].chars & lines[1].chars & lines[2].chars).first # exactly one as per instructions
      sum += priorities[common_item]
      count = 0
      lines = []
    end

    sum
  end
end

p SecondPart.run
