class Game

  def tick(world)
    new_cells = apply_rules(world)
    new_world = World.new
    new_cells.each { |c| new_world << c }
    new_world
  end

  private
  def apply_rules(world)
    new_cells = []
    rules.each do |rule|
      new_cells << rule.apply(world)
    end

    new_cells.flatten.uniq
  end

  def rules
    [
      TwoNeighboursLivesRule.new,
      ThreeNeighboursLivesRule.new
    ]
  end

end

class World
  attr_reader :coordinates

  def <<(coordinate)
    @coordinates.add coordinate
  end

  def initialize
    @coordinates = Set.new
  end

  def empty?
    @coordinates.empty?
  end
end

Coordinate = Struct.new(:x, :y) do
  def neighbours
    n = []
    (-1..1).each do |dx|
      (-1..1).each do |dy|
        n << Coordinate.new(x + dx, y + dy) unless dx == 0 && dy == 0
      end
    end

    n
  end
end

class TwoNeighboursLivesRule
  def apply(world)
    new_coordinates = []
    world.coordinates.each do |coordinate, cell|
      alive_neighbour_count = coordinate.neighbours.select { |n| world.coordinates.include?(n) }.count
      new_coordinates << coordinate if alive_neighbour_count == 2
    end

    new_coordinates
  end
end

class ThreeNeighboursLivesRule
  def apply(world)
    neighbours = world.coordinates.flat_map { |coordinate, cell| coordinate.neighbours }
    counts = Hash[neighbours.group_by { |x| x }.map { |k,v| [k, v.count] }]
    live_cells = counts.select { |k, v| v == 3 }
    live_cells.keys
  end
end

describe Game do
  let(:game) { Game.new }
  describe "#tick" do
    context "when given an empty world" do
      it "returns an empty world" do
        world  = World.new
        result = game.tick(world)
        result.should be_empty
      end
    end

    context "when given a world with one cell" do
      it "returns an empty world" do
        world = World.new
        world << Coordinate.new(1, 1)
        result = game.tick(world)
        result.should be_empty
      end
    end

    context "when given a world with three adjacent cells" do
      it "lets the middle cell live to the next generation" do
        world = World.new
        world << Coordinate.new(1, 1)
        world << Coordinate.new(1, 2)
        world << Coordinate.new(1, 3)

        result = game.tick(world)
        result.coordinates.should include Coordinate.new(1, 2)
      end
    end
  end
end

describe World do
  describe "on initialize" do
    it "is empty" do
      World.new.should be_empty
    end
  end

  describe "#<<" do
    it "adds a cell at coordinates" do
      world = World.new
      world << Coordinate.new(1, 1)
      world.should_not be_empty
    end
  end
end

describe TwoNeighboursLivesRule do
  describe "#apply" do
    context "when given a world with three adjacent cells" do
      it "returns only the middle cell" do
        world = World.new
        world << Coordinate.new(1, 1)
        world << Coordinate.new(1, 2)
        world << Coordinate.new(1, 3)

        rule = TwoNeighboursLivesRule.new
        cells = rule.apply(world)
        cells.should == [Coordinate.new(1, 2)]
      end
    end
  end
end

describe ThreeNeighboursLivesRule do
  describe "#apply" do
    context "given a dead cell with three live neighbours" do
      it "is alive in the next generation " do
        world = World.new
        world << Coordinate.new(1, 2)
        world << Coordinate.new(2, 1)
        world << Coordinate.new(3, 2)

        rule = ThreeNeighboursLivesRule.new
        cells = rule.apply(world)
        cells.should == [Coordinate.new(2, 2)]
      end

    end
  end
end

describe Coordinate do
  describe "#neighbours" do
    it "returns the 8 cells surrounding the coordinate" do
      coordinate = Coordinate.new(1, 2)
      coordinate.neighbours.count.should == 8
    end
  end
end

describe "Play" do
  describe "blinker" do
    it "blinks" do
      world = World.new
      world << Coordinate.new(1, 1)
      world << Coordinate.new(1, 2)
      world << Coordinate.new(1, 3)

      current_world = world
      10.times do
        game = Game.new
        current_world = game.tick(current_world)
        puts current_world.coordinates.to_a
        puts ""
      end
    end
  end
end
