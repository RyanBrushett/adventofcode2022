class FirstPart
  def run
    count = 0

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      a, b = line.chomp.split(',')
      set_a = as_set(a)
      set_b = as_set(b)
      count += 1 if any_overlap?(set_a, set_b)
    end

    count
  end

  private

  def as_set(section)
    r_start, r_end = section.split('-')
    Set.new(r_start..r_end)
  end

  def any_overlap?(a, b)
    !(a & b).empty?
  end
end

p FirstPart.new.run
