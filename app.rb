#!/usr/bin/env ruby

libdir = 'lib'
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'ruby2d'
require 'logger'
require 'tree'
require 'world'

def main
  world = World.new

  set width: world.screen_width, height: world.screen_height
  set background: world.background_color

  logger = Logger.new(world)
  tree = Tree.new(world, logger)

  tick = 0.0
  update do
    tick += 0.00001
    logger.clear
    logger.print "#{(get :fps).round(2)} FPS"

    tree.update(tick)

    tree.draw
    logger.draw
  end

  show
end

main
