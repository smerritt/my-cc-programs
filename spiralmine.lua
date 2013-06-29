-- mine three layers in an ever-expanding spiral (turtle in middle layer)
-- 
-- good for mining the top layers of the nether
--
-- works best on chunkloaded turtle

unload_chest_slot = 1
empty_bucket_chest_slot = 2
lava_bucket_chest_slot = 3

-- first slot after reserved slots above
first_item_slot = 4

-- when items get in this slot, unload
unload_sentinel_slot = 12

-- refuel when fuel is under this amount
fuel_threshold = 25


loadfile("util")()

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
    turtle.select(unload_chest_slot)
    turtle.digUp()  -- just in case
    if not turtle.placeUp() then
      error("maybe_unload: Error placing unload chest above!")
    end
    for slot in first_item_slot,16 do
      util.unloadUp(slot)
      sleep(0.2)  -- be gentle to the other side
    end
  end
end

-- Refuel turtle if fuel levels are too low
function maybe_refuel()
  if turtle.getFuelLevel() < fuel_threshold then
    turtle.digUp()  -- should be air above, but be robust if not
    maybe_unload()  -- ensure some empty slot for refueling
    util.refuel_from_chests(empty_bucket_chest_slot,
                            full_bucket_chest_slot,
                            util.find_empty_slot())
  end
end

-- Go one forward
function advance()
  if turtle.detectUp() then
    turtle.digUp()
  end
  if turtle.detect() then
    turtle.dig()
  end
  if turtle.detectDown() then
    turtle.digDown()
  end
  util.forward()
end

-- main function
function spiralmine()
  while true do
    maybe_unload()
    maybe_refuel()
    maybe_turn()
    advance()
  end
end

spiralmine()