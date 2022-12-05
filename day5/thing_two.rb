class ThingTwo
  MOVES_REGEX = %r{move (?<move_count>\d+) from (?<start>\d+) to (?<end>\d+)}

  def run
    #             [G] [W]         [Q]
    # [Z]         [Q] [M]     [J] [F]
    # [V]         [V] [S] [F] [N] [R]
    # [T]         [F] [C] [H] [F] [W] [P]
    # [B] [L]     [L] [J] [C] [V] [D] [V]
    # [J] [V] [F] [N] [T] [T] [C] [Z] [W]
    # [G] [R] [Q] [H] [Q] [W] [Z] [G] [B]
    # [R] [J] [S] [Z] [R] [S] [D] [L] [J]
    #  1   2   3   4   5   6   7   8   9

    stacks = [ [], [], [], [], [], [], [], [], [] ]
    %w(R G J B T V Z).each { |x| stacks[0].push(x) }
    %w(J R V L).each { |x| stacks[1].push(x) }
    %w(S Q F).each { |x| stacks[2].push(x) }
    %w(Z H N L F V Q G).each { |x| stacks[3].push(x) }
    %w(R Q T J C S M W).each { |x| stacks[4].push(x) }
    %w(S W T C H F).each { |x| stacks[5].push(x) }
    %w(D Z C V F N J).each { |x| stacks[6].push(x) }
    %w(L G Z D W R F Q).each { |x| stacks[7].push(x) }
    %w(J B W V P).each { |x| stacks[8].push(x) }

    File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
      next unless matches = line.match(MOVES_REGEX)
      landing_spot = matches[:end].to_i - 1 # zero-based arrays
      starting_spot = matches[:start].to_i - 1 # zero-based arrays
      move_count = matches[:move_count].to_i
      stacks[landing_spot].push(stacks[starting_spot].pop(move_count)).flatten!
    end

    stacks.map { |stack| stack.last }.join
  end
end

p ThingTwo.new.run
