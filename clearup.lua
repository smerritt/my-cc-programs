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

rows = tonumber(args[1])
rowlen = tonumber(args[2])
height = tonumber(args[3])

function debug(text)
  -- comment out to silence
  print(text)
end

function eat_up()
  for i=1,height-2 do
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
  for i=1,height-2 do
    turtle.down()
  end
end

function eat_row()
  for i=1,rowlen-1 do
    turtle.dig()
    turtle.forward()
    eat_up()
  end
  for i=1,rowlen-1 do
    turtle.back()
  end
end

function eat_grid()
  turtle.dig()
  turtle.forward()
  eat_up()
  for i=1,rows-1 do
    eat_row()
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    eat_up()
  end
  eat_row()

  -- do a little dance
  turtle.up()
  for i=1,4 do
    turtle.turnRight()
  end
  turtle.down()

  turtle.turnLeft()
  for i=1,rows-1 do
    turtle.forward()
  end
  turtle.turnRight()
  turtle.back()
end

eat_grid()
