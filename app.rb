#!/usr/bin/env ruby

require 'ruby2d'
require_relative 'lib/logger.rb'
require_relative 'lib/tree.rb'

SKY_BLUE = '#009AE3'

SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600

def main
  set width: SCREEN_WIDTH, height: SCREEN_HEIGHT
  set background: SKY_BLUE

  logger = Logger.new()
  tree = Tree.new(SCREEN_WIDTH, SCREEN_HEIGHT, logger)

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
