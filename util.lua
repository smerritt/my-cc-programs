-- turtle utility functions
-- you know, a bucket for stuff that doesn't really
-- go anywhere in particular but might be useful.

util = {}
-- selects the first slot with stuff in it
-- returns true if it found stuff, false otherwise
function util.select_filled_slot()
  for slot=1,16 do
    if turtle.getItemCount(slot) > 0 then
      turtle.select(slot)
      return true
    end
  end
  return false
end

-- selects the first slot with stuff in it
-- if no slot has stuff, blocks until one does
function util.select_filled_slot_or_wait()
  nmsg = 0

  while not util.select_filled_slot() do
    print("Waiting for refill (" .. nmsg .. ")")
    nmsg = nmsg + 1
    sleep(15)
  end
end

-- place a block below, blocking if we're out of blocks
function util.place_below()
  placed = turtle.placeDown()
  if not placed then
    util.select_filled_slot_or_wait()
    turtle.placeDown()
  end
end

-- place a block, blocking if we're out of blocks
function util.place()
  placed = turtle.place()
  if not placed then
    util.select_filled_slot_or_wait()
    turtle.place()
  end
end

-- sleep while retrying an action
-- args: ntimes: number of retries thus far
function util.retry_sleep(ntimes)
  duration = math.random(0.1, 0.1 * (2 ^ (ntimes - 1)))
  sleep(duration)
end


-- go back, even if there's something in the way
-- prints a message if there's something in the way
-- also works when there's lag
function util.back(n)
  n = n or 1
  for _=1,n do
    moved = turtle.back()
    tries = 1
    while not moved do
      print("Failed to move back(" .. tries .. "); waiting")
      util.retry_sleep(tries)
      tries = tries + 1
      moved = turtle.back()
    end
  end
end

-- go forward, even if there's something in the way
-- prints a message if there's something in the way
-- also works when there's lag
function util.forward(n)
  n = n or 1
  for _=1,n do
    moved = turtle.forward()
    tries = 1
    while not moved do
      print("Failed to move forward(" .. tries .. "); waiting")
      util.retry_sleep(tries)
      tries = tries + 1
      moved = turtle.forward()
    end
  end
end

-- go up, even if there's something in the way
-- prints a message if there's something in the way
-- also works when there's lag
function util.up(n)
  n = n or 1
  for _=1,n do
    moved = turtle.up()
    tries = 1
    while not moved do
      print("Failed to move up(" .. tries .. "); waiting")
      util.retry_sleep(tries)
      tries = tries + 1
      moved = turtle.up()
    end
  end
end

-- go down, even if there's something in the way
-- prints a message if there's something in the way
-- also works when there's lag
function util.down(n)
  n = n or 1
  for _=1,n do
    moved = turtle.down()
    tries = 1
    while not moved do
      print("Failed to move down(" .. tries .. "); waiting")
      util.retry_sleep(tries)
      tries = tries + 1
      moved = turtle.down()
    end
  end
end


-- ingest the block in front of the turtle. if it's lava, eat it.
-- requires a bucket in a slot, which defaults to 1.
--
-- may change the selected slot.
function util.ingest(bucket_slot)
  bucket_slot = bucket_slot or 1
  if turtle.detect() then
    -- solid block: dig it!
    --
    -- I have seen this get stuck when mining underwater, hence the limit
    -- something to do with flowing water blocks, maybe? it's weird.
    for i=1,10 do
      -- dig a bunch 
      if not (turtle.detect() and turtle.dig()) then break end
    end
  else
    -- turtle.detect() returns false for air, lava, and water, so try
    -- to eat it with a bucket
    turtle.select(bucket_slot)
    if turtle.place() then
      -- lava or water
      if not turtle.refuel() then
        -- looks like it was water; put it back (not that I care about
        -- preserving water; it's just that I want the empty bucket back)
        turtle.place()
      end
    end
  end
end

-- ingest the block under the turtle. if it's lava, eat it. requires a
-- bucket in a slot, which defaults to 1.
--
-- may change the selected slot.
function util.ingestDown(bucket_slot)
  bucket_slot = bucket_slot or 1
  if turtle.detectDown() then
    -- solid block: dig it!
    turtle.digDown()
  else
    -- turtle.detect() returns false for air, lava, and water, so try
    -- to eat it with a bucket
    turtle.select(bucket_slot)
    if turtle.placeDown() then
      -- lava or water
      if not turtle.refuel() then
        -- looks like it was water; put it back
        turtle.placeDown()
      end
    end
  end
end


-- find an empty slot
-- returns slot number
function util.find_empty_slot()
  for slot in 1,16 do
    if turtle.getItemCount(slot) == 0 then
      return slot
    end
  end
end

-- refuel via bucket-chest system
-- will block waiting for buckets
--
-- requires air above the turtle for chest placement
function util.refuel_from_chests(empty_bucket_chest_slot,
                                 full_bucket_chest_slot,
                                 empty_slot_for_bucket)
  -- put down the chest with the full lava buckets
  turtle.select(full_bucket_chest_slot)
  if not turtle.placeUp() then
    error("refuel_from_chests: Error placing full-bucket chest above!")
  end

  -- pull a lava bucket into the empty slot
  if turtle.getItemCount(empty_slot_for_bucket) > 0 then
    error("refuel_from_chests: Slot " .. tostring(empty_slot_for_bucket) .. " is not empty!")
  end
  turtle.select(empty_slot_for_bucket)
  
  tries = 0
  while not turtle.suckUp() do
    print("Couldn't pull from inventory above; waiting (try " .. 
          tostring(tries) .. ")")
    tries += 1
  end

  -- eat the bucket
  if not turtle.refuel() then
    error("refuel_from_chests: Got a non-fuel item from inventory above? WTF?")
  end

  -- send the empty bucket on its way
  turtle.select(full_bucket_chest_slot)
  if not turtle.digUp() then
    error("refuel_from_chests: Error retrieving full-bucket chest above!")
  end

  turtle.select(empty_bucket_chest_slot)
  if not turtle.placeUp() then
    error("refuel_from_chests: Error placing empty-bucket chest above!")
  end
  
  turtle.select(empty_slot_for_bucket)  -- kind of a misnomer at this point
  tries = 0
  while not turtle.dropUp() do
    print("Couldn't put bucket into inventory above; waiting (try " .. 
          tostring(tries) .. ")")
    tries += 1
  end

  turtle.select(empty_bucket_chest_slot)
  if not turtle.digUp() then
    error("refuel_from_chests: Error retrieving empty-bucket chest above!")
  end
end


-- unload items in <slot> into an inventory above the turtle,
-- will block if inventory is full.
--
-- NB: may change selected slot
function util.unloadUp(slot)
  if turtle.getItemCount(slot) == 0 then
    return true
  end

  turtle.select(slot)
  turtle.dropUp()
  while turtle.getItemCount(slot) > 0 do
    turtle.dropUp()
    print("Waiting for space in inventory above")
    sleep(8.1)
  end
end

return util

