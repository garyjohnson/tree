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
