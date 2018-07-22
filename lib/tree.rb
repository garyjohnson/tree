require 'tree_bit'
require 'point'

TREE_GREEN = '#3B6A45'

MAX_X_DRIFT = 20.0
MAX_Y_DRIFT = 60.0
GENERATION_LENGTH = 1.0

DEFAULT_GROW_RATE = 25.0
DEFAULT_GIRTH_RATE = 1.0
GROW_RATE_DRIFT = 2.0
GIRTH_RATE_DRIFT = 0.25
MAX_BRANCHES = 25

class Tree

  attr_accessor :grow_rate
  attr_accessor :girth_rate
  attr_accessor :passed_time
  attr_accessor :generation

  def initialize(world, logger)
    @world = world
    @logger = logger
    @random = Random.new

    @end_bits = []
    @all_bits = []
    @generation = 0
    @passed_time = 0.0
    @total_passed_time = 0.0

    @grow_rate = (DEFAULT_GROW_RATE + (@random.rand(-0.5..0.5) * GROW_RATE_DRIFT))
    @girth_rate = (DEFAULT_GIRTH_RATE + (@random.rand(-0.5..0.5) * GIRTH_RATE_DRIFT))

    parent_position = @random.rand 1.0
    @trunk = TreeBit.new(@world, self, angle=0, parent_position=0, children=[], generation=@generation)
    @end_bits.push @trunk
    @all_bits.push @trunk
  end

  def draw
    origin=Point.new(@world.screen_width / 2, 0)
    @trunk.draw(@generation, @passed_time, base_start=origin, base_length=0, base_angle=0, grow_rate=@grow_rate)
  end

  def update(delta_time)
    @passed_time += delta_time
    @total_passed_time += delta_time
    if @passed_time > GENERATION_LENGTH
      @passed_time = @passed_time % GENERATION_LENGTH
      add_generation
    end

    @logger.print "#{@all_bits.length} tree bits"
    @logger.print "generation #{@generation}"
    @logger.print "grow rate: #{@grow_rate.round(6)}"
    @logger.print "girth rate: #{@girth_rate.round(6)}"
  end

  private

  def add_generation
    @generation += 1

    new_end_bits = []
    @end_bits.each do |end_bit|
      end_range = @random.rand(1..MAX_BRANCHES)
      break if end_range <= 1

      (1..end_range).each do |i|
        angle = @random.rand(-1.0..1.0)
        parent_position = @random.rand(1.0)
        child = TreeBit.new(@world, self, angle=angle, parent_position=parent_position, children=[], generation=@generation)
        end_bit.children.push(child)
        new_end_bits.push(child)
        @all_bits.push(child)
      end

      @end_bits = new_end_bits
    end
  end

end
