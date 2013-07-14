-- mine three layers in an ever-expanding spiral (turtle in middle layer)
-- 
-- good for mining the top layers of the nether
--
-- works best on chunkloaded turtle

bucket_slot = 1
unload_chest_slot = 2
lava_bucket_chest_slot = 3
empty_bucket_chest_slot = 4

-- first slot after reserved slots above
first_item_slot = 5

-- when items get in this slot, unload
unload_sentinel_slot = 13

-- refuel when fuel is under this amount
fuel_threshold = 1025


loadfile("util")()

function debug(msg)
  print(msg)
end

function maybe_turn()
  -- turn if we've hit a corner
  turtle.turnRight()
  if not turtle.detect() then
    turtle.turnLeft()
  end
end

-- Unload the turtle, but only if necessary
function maybe_unload()
  if turtle.getItemCount(unload_sentinel_slot) > 0 then
    unload()
  end
end

-- unconditional unload
function unload()
  turtle.select(unload_chest_slot)
  turtle.digUp()  -- just in case
  if not turtle.placeUp() then
    error("maybe_unload: Error placing unload chest above!")
  end
  for slot=first_item_slot,16 do
    util.unloadUp(slot)
    sleep(0.2)  -- be gentle to the other side
  end
  turtle.select(unload_chest_slot)
  if not turtle.digUp() then
    error("maybe_unload: Error retrieving unload chest!")
  end
end

-- Refuel turtle if fuel levels are too low
function maybe_refuel()
  if turtle.getFuelLevel() < fuel_threshold then
    print("refueling!")
    turtle.digUp()   -- should be air above, but be robust if not
    turtle.digDown() -- likewise for below
    util.refuel_from_chests(empty_bucket_chest_slot,
                            lava_bucket_chest_slot)
  end
end

-- Go one forward
function advance()
  util.ingestUp(bucket_slot)
  util.ingest(bucket_slot)
  util.ingestDown(bucket_slot)
  util.forward()
end

-- main function
function spiralmine(limit)
  dug = 0
  while ((limit <= 0) or (dug < limit)) do
    maybe_unload()
    maybe_refuel()
    maybe_turn()
    advance()
    dug = dug + 1
  end
  unload()
end

local args = { ... }
limit = 0
if args[1] ~= nil then
  limit = tonumber(args[1])
end

spiralmine(limit)
