-- mines down in a + shape
-- returns to start

loadfile("util")()

bucket_slot = 1
enderchest_slot = 2

function debug(msg)
  print(msg)
end

function ingest()
  if turtle.detect() then
    -- solid block: dig it!
    --
    -- I have seen this get stuck when mining underwater, hence the limit
    -- something to do with flowing water blocks, maybe? it's weird.
    for i=1,10 do
      debug("digging solid block " .. tostring(i))
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


function ingestDown()
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


function munch()
  ingestDown()

  wentDown = turtle.down()
  if not wentDown then
    -- probably bedrock
    print("done; returning to surface")
    return
  end

  for i=1,4 do
    ingest()
    turtle.turnRight()
  end

  -- as grows the stack, so goes the turtle
  munch()
  wentUp = turtle.up()
  while not wentUp do
    print("Failed to go up; retrying")
    sleep(0.1)
    turtle.digUp()   -- in case of gravel
    wentUp = turtle.up()
  end
end

if turtle.getFuelLevel() < 150 then
  print(string.format("Not enough fuel: %d < 150", turtle.getFuelLevel()))
  return
else
  munch()
end
