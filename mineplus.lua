-- mines down in a + shape
-- returns to start

loadfile("util")()

function munch()
  if turtle.detectDown() then
    turtle.digDown()
  end

  went_down = turtle.down()
  if not went_down then
    -- probably bedrock
    print("done; returning to surface")
    return
  end

  for i=1,4 do
    if turtle.detect() then
      turtle.dig()
    end
    turtle.turnRight()
  end

  -- as grows the stack, so goes the turtle
  munch()
  turtle.up()
end

munch()
