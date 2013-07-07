-- mine in a strip N long
-- TODO: refueling

local args = { ... }
depth = tonumber(args[1])

loadfile("util")()

-- bucket slot is 1 in mineplus, so we can't use that
unload_chest_slot = 2
first_item_slot = 3

function unload()
  turtle.digUp()  -- just in case
  turtle.select(unload_chest_slot)
  if not turtle.placeUp() then
    error("Failed placing ender chest above me")
  end

  for slot=first_item_slot,16 do
    util.unloadUp(slot)
  end

  turtle.select(unload_chest_slot)
  if not turtle.digUp() then
    error("Failed to retrieve ender chest above me")
  end

  -- here's where the refueling would happen
end

function mineplus()
  success = shell.run("mineplus")
  if not success then
    error("Error running mineplus; bailing out!")
  end
end

for i=1,depth-1 do
  mineplus()
  unload()
  turtle.dig()
  turtle.forward()
end

mineplus()
unload()

for i=1,depth-1 do
  util.back()
end
