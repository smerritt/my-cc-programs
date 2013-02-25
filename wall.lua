-- Make a MxN wall in front of the turtle
-- Usage: wall <width> <height>
--      

local args = { ... }

wall_width = tonumber(args[1])
wall_height = tonumber(args[2])

loadfile("util")()

function place_column(height)
  util.select_filled_slot_or_wait()
  util.place()
  for i=1,height-1 do
    util.up()
    util.place()
  end
  util.down(height-1)
end

function place_wall(width, height)
  for i=1,width-1 do
    place_column(height)
    turtle.turnRight()
    util.forward()
    turtle.turnLeft()
  end
  place_column(height)
  turtle.turnLeft()
  util.forward(width-1)
  turtle.turnRight()
end

place_wall(wall_width, wall_height)
