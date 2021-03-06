-- mines straight down, comes back up

function debug(msg)
  print(msg)
end

function munch()
  while turtle.suckDown() do
    -- nothing
  end
  turtle.digDown()

  wentDown = turtle.down()
  if not wentDown then
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
