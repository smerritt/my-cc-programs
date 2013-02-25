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

return util
