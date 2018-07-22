require_relative 'tree_bit.rb'
require_relative 'point.rb'

TREE_GREEN = '#3B6A45'

MAX_X_DRIFT = 20.0
MAX_Y_DRIFT = 60.0
GENERATION_LENGTH = 1.0
MAX_GENERATIONS = 100

DEFAULT_GROW_RATE = 25.0
DEFAULT_GIRTH_RATE = 1.0
GROW_RATE_DRIFT = 2.0
GIRTH_RATE_DRIFT = 0.25

class Tree

  def initialize(width, height, logger)
    @width = width
    @height = height
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
    @trunk = TreeBit.new(angle=0, parent_position=0, children=[], generation=@generation)
    @end_bits.push @trunk
    @all_bits.push @trunk
  end

  def draw
    draw_tree_bit @trunk
  end

  def update(delta_time)
    @passed_time += delta_time
    @total_passed_time += delta_time
    if @generation < MAX_GENERATIONS && @passed_time > GENERATION_LENGTH
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
      end_range = @random.rand(1..25)
      break if end_range <= 1

      (1..end_range).each do |i|
        angle = @random.rand(-1.0..1.0)
        parent_position = @random.rand(1.0)
        child = TreeBit.new(angle=angle, parent_position=parent_position, children=[], generation=@generation)
        end_bit.children.push(child)
        new_end_bits.push(child)
        @all_bits.push(child)
      end

      @end_bits = new_end_bits
    end
  end

  def draw_tree_bit(tree_bit, base_start=nil, base_length=0, base_angle=0, grow_rate=nil, girth_rate=nil)
    if base_start == nil
      base_start = Point.new(@width / 2, 0)
    end
    if grow_rate == nil
      grow_rate = @grow_rate
    end
    if girth_rate == nil
      girth_rate = @girth_rate
    end

    start_length = tree_bit.parent_position * base_length
    start_point = Point.new(base_start.x, base_start.y + start_length).rotated(base_start, base_angle)

    age = tree_bit_age(tree_bit)

    length = (age * grow_rate) / (tree_bit.generation + 1)
    angle_degrees = (MAX_X_DRIFT * tree_bit.angle) + base_angle

    end_point = Point.new(start_point.x, start_point.y + length).rotated(start_point, angle_degrees)
    thickness = (age * girth_rate) / (tree_bit.generation + 1)
    thickness = [thickness, 1.0].max

    tree_bit.line.x1 = start_point.x
    tree_bit.line.y1 = @height-start_point.y
    tree_bit.line.x2 = end_point.x
    tree_bit.line.y2 = @height-end_point.y
    tree_bit.line.width = thickness

    total_weight = 0.0
    tree_bit.children.each do |bit|
      total_weight += 1.0-bit.parent_position
    end

    tree_bit.children.each do |child|
      #weight = (1.0-child.parent_position) / total_weight
      #draw_tree_bit(child, start_point, length, angle_degrees, grow_rate * (1.0+weight), girth_rate * (1.0+weight))
      draw_tree_bit(child, start_point, length, angle_degrees)
    end
  end

  def tree_bit_age(tree_bit)
    return ((@generation - tree_bit.generation) * GENERATION_LENGTH) + @passed_time
  end
end
