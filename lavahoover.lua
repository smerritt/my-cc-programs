-- hoover up some lava
local args = { ... }

width = tonumber(args[1])
height = tonumber(args[2])

loadfile("util")()

turtle.select(1)

for i=1,width do
  for j=1,height do
    turtle.forward()
    turtle.placeDown()
    turtle.refuel()
  end
  for j=1,height do
    turtle.back()
  end

  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
end
