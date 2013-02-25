-- Make a MxNxH box in front of the turtle
-- Usage: box <width> <depth> <height>
--      

local args = { ... }

box_width = tonumber(args[1])
box_depth = tonumber(args[2])
box_height = tonumber(args[3])

wall_height = box_height - 2

loadfile("util")()

-- moves the turtle up 1 so it is atop the floor
shell.run("floor", box_width, box_depth)
turtle.turnLeft()
util.back()

-- build left wall (leaves turtle pos unchanged)
shell.run("wall", box_depth, wall_height)

-- build roof
util.up(wall_height)   -- just above wall
util.forward()
turtle.turnRight()
shell.run("floor", box_width, box_depth) -- moves turtle up 1

-- get back in the box
util.back()
util.down(wall_height+1)
turtle.turnRight()
util.forward()
turtle.turnLeft()
util.forward()   -- now we're on the box edge

-- build rear wall (leaves turtle pos unchanged)
util.forward(box_depth-2)
shell.run("wall", box_width-1, wall_height)

-- build right wall
turtle.turnRight()
util.forward(box_width-3)
shell.run("wall", box_depth-1, wall_height)

-- build front wall
turtle.turnRight()
util.forward(box_depth-3)
shell.run("wall", box_width-2, wall_height)
