class Day1A
  def self.run
    running_total = 0
    max = -1

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      current = line.strip
      running_total += current.to_i
      if current == "" || !line.include?("\n")
        max = running_total if running_total > max
        running_total = 0
      end
    end
    max
  end
end

p Day1A.run
