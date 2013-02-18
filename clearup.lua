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
    turtle.up()
  end
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.1)
  end
  for i=1,how_far-1 do
    -- the turtle doesn't always make it down,
    -- even if there's clear air. lag?
    ret = turtle.down()
    if not ret then
      sleep(0.1)
      turtle.down()
    end
  end
end

function eat_row(depth, height)
  for i=1,depth do
    turtle.dig()
    turtle.forward()
    eat_up(height-1)
  end
  for i=1,depth do
    -- lag makes this loop not always work, perhaps?
    -- certainly something breaks it
    ret = turtle.back()
    if not ret then
      sleep(0.1)
      turtle.back()
    end
  end
end

function eat_room(width, depth, height)
  turtle.dig()
  turtle.forward()
  eat_up(height-1)
  for i=1,width do
    eat_row(depth-1, height)
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
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
  for i=1,width-1 do
    turtle.forward()
  end
  turtle.turnRight()
  turtle.back()
end

eat_room(box_width, box_depth, box_height)
