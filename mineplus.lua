-- mines down in a + shape
-- returns to start

loadfile("util")()

bucket_slot = 1

function debug(msg)
  print(msg)
end

function munchAround(bucket_slot)
  for i=1,4 do
    util.ingest(bucket_slot)
    turtle.turnRight()
  end
end

function munch()
  munchAround(bucket_slot)
  util.ingestDown(bucket_slot)

  wentDown = turtle.down()
  if not wentDown then
    munchAround(bucket_slot)
    -- probably bedrock
    print("done; returning to surface")
    return
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
