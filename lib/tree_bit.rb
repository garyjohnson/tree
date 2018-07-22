require 'ruby2d'

class TreeBit

  attr_accessor :angle
  attr_accessor :parent_position
  attr_accessor :children
  attr_accessor :generation

  attr_accessor :line

  def initialize(angle, parent_position, children, generation)
    @angle = angle
    @parent_position = parent_position
    @children = children
    @generation = generation

    @line = Line.new({ x1: 0, y1: 0,  x2: 0, y2: 0})
    @line.width = 0
    @line.color = TREE_GREEN
  end
end
