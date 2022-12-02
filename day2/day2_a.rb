class Day2A
  PLAYS = {
    "A" => {
      "X" => 4,
      "Y" => 8,
      "Z" => 3,
    },
    "B" => {
      "X" => 1,
      "Y" => 5,
      "Z" => 9,
    },
    "C" => {
      "X" => 7,
      "Y" => 2,
      "Z" => 6,
    },
  }
  def self.run
    score = 0

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      opp, me = line.split
      score += PLAYS[opp][me]
    end

    score
  end
end

p Day2A.run
