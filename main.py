#!/usr/bin/env python

import random
from collections import namedtuple
from dataclasses import dataclass
import arcade

sky_blue = (155,214,244)
tree_green = (0,0,0)

SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600
GENERATION_LENGTH = 1
MAX_X_DRIFT = 20.0
MAX_Y_DRIFT = 60.0

Point = namedtuple('Point', ['x','y'])

@dataclass
class TreeBit():
    end_point: Point
    children: list
    vertices: arcade.VertexBuffer
    generation: int

class TreeWindow(arcade.Window):

    shapes = None
    trunk = None
    generation = 1
    passed_time = 0.0
    end_bits = []

    def __init__(self, width, height):
        super().__init__(width, height)
        arcade.set_background_color(sky_blue)
        self.shapes = arcade.ShapeElementList()

        self.trunk = self._create_treebit((SCREEN_WIDTH / 2) + 10, 60, self.generation)
        self.end_bits.append(self.trunk)

    def on_draw(self):
        arcade.start_render()
        self.shapes.draw()

    def update(self, delta_time):
        self.passed_time += delta_time
        if self.passed_time > GENERATION_LENGTH:
            self.passed_time = self.passed_time % GENERATION_LENGTH
            self._add_generation()

    def _add_generation(self):
        if self.generation >= 10:
            pass

        new_end_bits = []
        for end_bit in self.end_bits:
            for i in range(0, random.randint(0, 10-self.generation)):
                x = end_bit.end_point.x + (((random.random() - 0.5) * 2) * MAX_X_DRIFT)
                y = end_bit.end_point.y + (random.random() * MAX_Y_DRIFT)
                child = self._create_treebit(x, y, self.generation, end_bit)
                end_bit.children.append(child)
                new_end_bits.append(child)

        self.end_bits = new_end_bits
        self.generation = self.generation + 1

    def _start_point(self):
        return Point(SCREEN_WIDTH / 2, 0)

    def _create_treebit(self, x, y, generation, parent = None):
        start = None
        if parent is None:
            start = self._start_point()
        else:
            start = parent.end_point

        end = Point(x=x, y=y)
        vertices = arcade.create_line(start.x, start.y, end.x, end.y, tree_green, 5)
        self.shapes.append(vertices)
        return TreeBit(end_point=end, children=[], vertices=vertices, generation=generation)


def main():
    window = TreeWindow(SCREEN_WIDTH, SCREEN_HEIGHT)
    arcade.run()

if __name__ == "__main__":
    main()
