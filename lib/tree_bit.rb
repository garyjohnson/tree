require 'ruby2d'

class TreeBit

  attr_accessor :angle
  attr_accessor :parent_position
  attr_accessor :children
  attr_accessor :generation

  attr_accessor :line

  def initialize(world, tree, angle, parent_position, children, generation)
    @angle = angle
    @parent_position = parent_position
    @children = children
    @generation = generation
    @world = world
    @tree = tree

    @line = Line.new({ x1: 0, y1: 0,  x2: 0, y2: 0})
    @line.width = 0
    @line.color = TREE_GREEN
  end

  def draw(current_generation, passed_time, base_start, base_length, base_angle, grow_rate, thickness=nil)
    base_start ||= Point.new(@width / 2, 0)
    grow_rate ||= @tree.grow_rate

    start_length = @parent_position * base_length
    start_point = Point.new(base_start.x, base_start.y + start_length).rotated(base_start, base_angle)

    length = (age * grow_rate) / (@generation + 1)
    angle_degrees = (MAX_X_DRIFT * @angle) + base_angle
    end_point = Point.new(start_point.x, start_point.y + length).rotated(start_point, angle_degrees)

    @line.x1 = start_point.x
    @line.y1 = @world.screen_height - start_point.y
    @line.x2 = end_point.x
    @line.y2 = @world.screen_height - end_point.y

    thickness ||= (age * @tree.girth_rate) / (@generation + 1)
    thickness = [thickness, 1.0].max
    @line.width = thickness

    total_weight = @children.sum { |child| 1.0-child.parent_position }

    @children.each do |child|
      weight = (1.0-child.parent_position) / total_weight
      child.draw(current_generation, passed_time, start_point, length, angle_degrees, grow_rate, thickness * weight)
    end
  end

  def age
    return ((@tree.generation - @generation) * GENERATION_LENGTH) + @tree.passed_time
  end
end
