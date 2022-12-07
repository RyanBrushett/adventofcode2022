require 'minitest/autorun'
require 'pathname'

class Thing
  attr_reader :directories
  MINIMUM_FREE_SPACE = 30000000
  TOTAL_DISK_SPACE = 70000000

  def initialize
    @pwd = Pathname.new("/")
    @directories = [Directory.new("/")] # There's 100% a better way to do this
  end

  # a bit smarter than an attr_reader
  def pwd
    @pwd.to_s
  end

  def size
    @used_space ||= @directories.first.size
  end

  def unused_space
    TOTAL_DISK_SPACE - size
  end

  def need_to_free
    MINIMUM_FREE_SPACE - unused_space
  end

  def pwd=(x)
    @pwd = Pathname.new(x).cleanpath
  end

  def directory_abs
    @directories.map(&:abs)
  end

  def sum_of_small_dirs
    sum = 0
    @directories.each do |dir|
      sum += dir.size if dir.size < 100000
    end

    sum
  end

  def dir_to_free_space
    result_dir = nil
    @directories.each do |dir|
      if dir.size > need_to_free
        if result_dir.nil?
          result_dir = dir
        elsif dir.size < result_dir.size
          result_dir = dir
        end
      end
    end

    result_dir
  end

  def run(data)
    data.each_line do |line|
      parse_line(line)
    end
  end

  def parse_line(line)
    if line.start_with?("$")
      run_command(line)
    elsif line.start_with?("dir")
      dir = line.split(" ").last
      add_or_touch(dir)
    else # It's a file
      size, name = line.split(" ")
      add_file(size, name)
    end
  end

  def add_file(size, name)
    file = YayFile.new(size.to_i, File.join(pwd, name))
    @directories.find{ |d| d.abs == pwd }.ls << file
  end

  def add_or_touch(dir)
    absolute_path = File.join(pwd, dir)
    return if @directories.find { |d| d.abs == absolute_path }
    new_dir = Directory.new(absolute_path)
    @directories.find{ |d| d.abs == new_dir.parent }.ls << new_dir
    @directories << new_dir
  end

  def run_command(line)
    # TODO: I can probably make this more efficient
    command_parts = line.split(" ")
    case command_parts.length
    when 3
      ChangeDirCommand.new(command_parts[2], self).call # TODO get rid of this
    when 2
      ListCommand.new.call # Get rid of this
    else
      raise "wat"
    end
  end

  class Directory
    attr_accessor :ls
    attr_reader :abs, :name
    def initialize(abs)
      @ls = []
      @abs = abs
      @name = Pathname.new(abs).basename.to_s
    end

    def parent
      Pathname.new(abs).parent.to_s
    end

    def size
      @size ||= ls.sum(&:size)
    end

    def ls_names
      ls.map(&:name)
    end
  end

  class YayFile
    attr_reader :name, :size, :abs
    def initialize(size, abs)
      @size = size
      @abs = abs
      @name = Pathname.new(abs).basename.to_s
    end
  end

  class ChangeDirCommand # TODO get rid of this
    attr_reader :arg
    def initialize(arg, fs)
      @arg = arg
      @fs = fs
    end

    def call
      if arg == "/"
        @fs.pwd = "/"
      else
        new_path = File.join(@fs.pwd, arg)
        @fs.pwd = new_path
      end
      @fs.pwd
    end
  end

  class ListCommand
    def call; end # Do I even need this? No.
  end

  class ThingTest < Minitest::Test
    INPUT_DATA = <<~DATA
      $ cd /
      $ ls
      dir a
      14848514 b.txt
      8504156 c.dat
      dir d
      $ cd a
      $ ls
      dir e
      29116 f
      2557 g
      62596 h.lst
      $ cd e
      $ ls
      584 i
      $ cd ..
      $ cd ..
      $ cd d
      $ ls
      4060174 j
      8033020 d.log
      5626152 d.ext
      7214296 k
    DATA

    def test_parse_change_dir_command
      thing = Thing.new
      thing.parse_line("$ cd a")
      assert_equal "/a", thing.pwd
      thing.parse_line("$ cd b")
      assert_equal "/a/b", thing.pwd
      thing.parse_line("$ cd c")
      assert_equal "/a/b/c", thing.pwd
      thing.parse_line("$ cd ..")
      assert_equal "/a/b", thing.pwd
      thing.parse_line("$ cd /")
      assert_equal "/", thing.pwd
    end

    def test_parse_dir_lines
      small_input_data = <<~DATA
        $ cd /
        $ ls
        dir b
        $ cd b
        $ ls
        dir a
      DATA

      thing = Thing.new
      thing.run(small_input_data)
      assert_equal ["/", "/b", "/b/a"], thing.directory_abs
      assert_equal 1, thing.directories.first.ls.length
      assert_equal "/b", thing.directories.first.ls.first.abs
      assert_equal "/b/a", thing.directories.first.ls.first.ls.first.abs
    end

    def test_parse_file_lines
      small_input_data = <<~DATA
        $ cd /
        $ ls
        dir a
        14848514 b.txt
        $ cd a
        $ ls
        123 hello.txt
      DATA

      thing = Thing.new
      thing.run(small_input_data)
      root = thing.directories.first
      assert_equal ["/", "/a"], thing.directory_abs
      assert_equal 2, root.ls.length # all under root dir
      assert_equal ["a", "b.txt"].sort, root.ls_names.sort
      dir_a = root.ls.find { |d| d.abs == "/a" }
      assert_equal 1, dir_a.ls_names.length
    end

    def test_thing_size
      small_input_data = <<~DATA
      $ cd /
      $ ls
      25 b.txt
      100 hello.txt
      DATA

      thing = Thing.new
      thing.run(small_input_data)
      assert_equal 125, thing.size
    end

    def test_calc_sum_of_small_dirs
      thing = Thing.new
      thing.run(INPUT_DATA)
      assert_equal 95437, thing.sum_of_small_dirs
    end

    def test_calc_need_to_free
      thing = Thing.new
      thing.run(INPUT_DATA)
      assert_equal 48381165, thing.directories.first.size
      assert_equal 21618835, thing.unused_space
      assert_equal 8381165, thing.need_to_free
    end

    def test_dir_to_free_space
      thing = Thing.new
      thing.run(INPUT_DATA)
      dir = thing.dir_to_free_space
      assert_equal "d", dir.name
      assert_equal 24933642, dir.size
    end
  end
end

thing = Thing.new
File.foreach(File.join(__dir__, "input.dat")).each_entry do |line|
  thing.parse_line(line)
end

puts ""
puts "Part 1 output: "
p thing.sum_of_small_dirs
puts ""

puts "Part 2 output: "
p thing.dir_to_free_space.size
puts ""
puts ""
