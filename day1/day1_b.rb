class Day1B
  def self.run
    running_total = 0
    top_three = [0, 0, 0]

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      current = line.strip
      running_total += current.to_i # "".to_i == 0
      if current == "" || !line.include?("\n")
        top_three << running_total
        top_three = top_three.max(3)
        running_total = 0
      end
    end
    top_three.sum
  end
end

p Day1B.run
