-- place some stairs
--
-- Usage: placestairs <up|down> <quantity>

local args = { ... }

direction = args[1]
steps = tonumber(args[2])

if (direction ~= "up" and direction ~= "down") then
  print("usage: placestairs <up|down> <how-many>")
  return
end

loadfile("util")()

if direction == "up" then
  move = util.up
else
  move = util.down
end

util.forward(2)
turtle.turnLeft()
turtle.turnLeft()
move()

function place_block()
  util.select_filled_slot_or_wait()
  turtle.place()
end

for _=1,steps do
  place_block()
  move()
  place_block()
  util.back()
end

place_block()
