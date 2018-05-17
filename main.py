#!/usr/bin/env python

import random
import math
from collections import namedtuple
from dataclasses import dataclass
import arcade

sky_blue = (155,214,244)
tree_green = (0,0,0)

SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600
GENERATION_LENGTH = 5.0
MAX_X_DRIFT = 20.0
MAX_Y_DRIFT = 60.0
GROW_RATE = 5.0

Point = namedtuple('Point', ['x','y'])

@dataclass
class TreeBit():
    angle: float
    parent_position: float
    children: list
    generation: int

class TreeWindow(arcade.Window):

    shapes = None
    trunk = None
    generation = 0
    passed_time = 0.0
    end_bits = []
    all_bits = []

    def __init__(self, width, height):
        super().__init__(width, height)
        arcade.set_background_color(sky_blue)
        self.shapes = arcade.ShapeElementList()

        parent_position = random.random()
        self.trunk = TreeBit(angle=4.0, parent_position=0, children=[], generation=self.generation)
        self.end_bits.append(self.trunk)
        self.all_bits.append(self.trunk)

    def on_draw(self):
        arcade.start_render()

        self.draw_tree_bit(self.trunk)

    def draw_tree_bit(self, tree_bit, base_start=None, base_length=0, base_angle=0):
        start = base_start
        if start is None:
            start = Point(SCREEN_WIDTH / 2, 0)

        start_length = tree_bit.parent_position * base_length
        base_angle_radians = base_angle * 0.017453292519
        start_x = start.x + start_length * math.cos(base_angle_radians);
        start_y = start.y + start_length * math.sin(base_angle_radians);
        
        length = (((self.generation - tree_bit.generation) * GENERATION_LENGTH) + self.passed_time) * GROW_RATE
        angle_degrees = (MAX_X_DRIFT * tree_bit.angle) + base_angle

        angle_radians = angle_degrees * 0.017453292519
        end_x = start.x + length * math.cos(angle_radians);
        end_y = start.y + length * math.sin(angle_radians);
        thickness = (((self.generation - tree_bit.generation) * GENERATION_LENGTH) + self.passed_time) * (GROW_RATE * 0.1)

        print(f'draw line x:{start_x} y:{start_y} endx:{end_x}, endy:{end_y}')
        arcade.draw_line(start_x, start_y, end_x, end_y, tree_green, thickness)

        for child in tree_bit.children:
            self.draw_tree_bit(child, Point(start_x, start_y), length, angle_degrees)


    def update(self, delta_time):
        self.passed_time += delta_time
        if self.passed_time > GENERATION_LENGTH:
            self.passed_time = self.passed_time % GENERATION_LENGTH
            self._add_generation()


    def _add_generation(self):
        if self.generation >= 5:
            pass

        self.generation = self.generation + 1

        new_end_bits = []
        for end_bit in self.end_bits:
            for i in range(0, random.randint(0, 10-self.generation)):
                angle = (random.random() - 0.5) * 2
                parent_position = random.random()
                child = TreeBit(angle=angle, parent_position=parent_position, children=[], generation=self.generation)
                end_bit.children.append(child)
                new_end_bits.append(child)
                self.all_bits.append(child)

        self.end_bits = new_end_bits


def main():
    window = TreeWindow(SCREEN_WIDTH, SCREEN_HEIGHT)
    arcade.run()

if __name__ == "__main__":
    main()
