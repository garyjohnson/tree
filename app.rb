#!/usr/bin/env ruby

require 'ruby2d'

SKY_BLUE = '#009AE3'
TREE_GREEN = '#3B6A45'

SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600
MAX_X_DRIFT = 20.0
MAX_Y_DRIFT = 60.0
GENERATION_LENGTH = 1.0
MAX_GENERATIONS = 100

DEFAULT_GROW_RATE = 25.0
DEFAULT_GIRTH_RATE = 1.0
GROW_RATE_DRIFT = 2.0
GIRTH_RATE_DRIFT = 0.25

DEFAULT_FONT = 'slkscr.ttf'
DEFAULT_FONT_SIZE = 20
DEFAULT_FONT_SPACING = 5

class Tree

  @random

  @trunk
  @end_bits
  @all_bits

  attr_accessor :generation
  @passed_time
  @total_passed_time

  @grow_rate
  @girth_rate
  @logger

  def initialize(logger)
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
      end_range = @random.rand(1..8)
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
      base_start = Point.new(SCREEN_WIDTH / 2, 0)
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

    tree_bit.line.x1 = start_point.x
    tree_bit.line.y1 = SCREEN_HEIGHT-start_point.y
    tree_bit.line.x2 = end_point.x
    tree_bit.line.y2 = SCREEN_HEIGHT-end_point.y
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

class Point

  attr_accessor :x
  attr_accessor :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def rotated(origin, angle)
    angle_radians = angle * 0.017453292519
    s = Math.sin(angle_radians)
    c = Math.cos(angle_radians)

    x = @x - origin.x
    y = @y - origin.y

    new_x = x * c - y * s
    new_y = x * s + y * c

    return Point.new(new_x + origin.x, new_y + origin.y)
  end

end

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

class Logger

  @messages
  @used_texts
  @unused_texts

  def initialize()
    @messages = []
    @used_texts = []
    @unused_texts = []
  end

  def print(text)
    @messages.push text
  end

  def clear
    @used_texts.each do |text|
      @unused_texts << text
      @used_texts.delete text
    end
    @unused_texts.each do |text|
      text.x = 0
      text.y = 0
      text.text = ''
    end
    @messages.clear
  end

  def draw
    text_height = DEFAULT_FONT_SIZE + DEFAULT_FONT_SPACING
    y_pos = SCREEN_HEIGHT - (@messages.length * text_height)
    @messages.each do |message|
      text = get_or_create_text
      text.x = 0
      text.y = y_pos
      text.text = message
      y_pos += text_height
    end
  end

  def get_or_create_text
    text = @unused_texts.first
    if text != nil
      @unused_texts.delete text
    else
      text = Text.new(size: DEFAULT_FONT_SIZE, font: DEFAULT_FONT)
    end

    @used_texts << text
    return text
  end

end

def main
  set width: SCREEN_WIDTH, height: SCREEN_HEIGHT
  set background: SKY_BLUE
  logger = Logger.new()
  tree = Tree.new(logger)

  tick = 0.0
  update do
    tick += (1.0/100000.0)
    logger.clear
    tree.update(tick)
    tree.draw

    logger.print "#{(get :fps).round(2)} FPS"
    logger.draw
  end

  show
end

main
