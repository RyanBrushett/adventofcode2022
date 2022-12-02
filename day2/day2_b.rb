class Day2B
  PLAYS = {
    "A" => { # rock
      "X" => 3, # Lose: scissors
      "Y" => 4, # Draw: rock
      "Z" => 8, # Win: paper
    },
    "B" => { # paper
      "X" => 1, # Lose: rock
      "Y" => 5, # Draw: paper
      "Z" => 9, # Win: scissors
    },
    "C" => { # scissors
      "X" => 2, # Lose: paper
      "Y" => 6, # Draw: scissors
      "Z" => 7, # Win: Rock
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

p Day2B.run
