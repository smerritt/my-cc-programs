-- dig some stairs
--
-- Usage: stairs <up|down> <quantity>

local args = { ... }

direction = args[1]
steps = tonumber(args[2])

if (direction ~= "up" and direction ~= "down") then
  print("usage: stairs <up|down> <how-many>")
  return
end

loadfile("util")()

function step(direction)
  if direction == "up" then
    move = turtle.up
    dig = turtle.digUp
  else
    move = turtle.down
    dig = turtle.digDown
  end

  turtle.dig()
  turtle.forward()

  dig()
  move()
  dig()
end


for _=1,steps do
  step(direction)
end
