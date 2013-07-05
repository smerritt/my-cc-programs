-- excavate a block that's MxN,
-- clearing up
--
-- usage: clearup M N H
--
-- goes M right, N forward, H up

local args = { ... }

-- if #args < 4 then
--   print "usage: clearup M N H"
--   exit()
-- end

box_width = tonumber(args[1])
box_depth = tonumber(args[2])
box_height = tonumber(args[3])

loadfile("util")()

function debug(text)
  -- comment out to silence
  print(text)
end

-- ensures clear air for N blocks
-- above the turtle
function eat_up(how_far)
  if how_far <= 0 then
    return
  end
  for i=1,how_far-1 do
    while turtle.detectUp() do
      turtle.digUp()
      sleep(0.1)
    end
    util.up()
  end
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.1)
  end
  util.down(how_far-1)
end

function eat_row(depth, height)
  for i=1,depth do
    turtle.dig()
    util.forward()
    eat_up(height-1)
  end
  util.back(depth)
end

function eat_room(width, depth, height)
  turtle.dig()
  util.forward()
  eat_up(height-1)
  for i=1,width-1 do
    eat_row(depth-1, height)
    turtle.turnRight()
    turtle.dig()
    util.forward()
    turtle.turnLeft()
    eat_up(height-1)
  end
  eat_row(depth-1, height)

  -- do a little dance
  turtle.up()
  for i=1,4 do
    turtle.turnRight()
  end
  turtle.down()

  turtle.turnLeft()
  util.forward(width-1)
  turtle.turnRight()
  turtle.back()
end

eat_room(box_width, box_depth, box_height)
