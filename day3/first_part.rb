class FirstPart
  def self.run
    letters = ('a'..'z').to_a.concat(('A'..'Z').to_a)
    priorities = letters.each_with_object({}).with_index do |(letter, hash), index|
      hash[letter] = index + 1
    end
    sum = 0

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      first_half, second_half = line.chars.each_slice(line.length / 2).to_a

      common_item = (first_half & second_half).first # exactly one mistake per line
      sum += priorities[common_item]
    end

    sum
  end
end

p FirstPart.run
