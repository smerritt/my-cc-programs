-- lays an MxN floor
-- M across to the right, N deep

local args = { ... }

floor_width = tonumber(args[1])
floor_depth = tonumber(args[2])

-- selects the first slot with stuff in it
-- returns true if it found stuff, false otherwise
function select_filled_slot()
  for slot=1,16 do
    if turtle.getItemCount(slot) > 0 then
      turtle.select(slot)
      return true
    end
  end
  return false
end

function select_filled_slot_or_wait()
  nmsg = 0

  while not select_filled_slot() do
    print("Waiting for refill (" .. nmsg .. ")")
    nmsg = nmsg + 1
    sleep(15)
  end
end

function place_below()
  placed = turtle.placeDown()
  if not placed then
    select_filled_slot_or_wait()
    turtle.placeDown()
  end
end

function lay_line(length)
  for i=1,length-1 do
    place_below()
    turtle.forward()
  end
  place_below()
  for i=1,length-1 do
    ret = turtle.back()
    if not ret then
      sleep(0.1)
      turtle.back()
    end
  end
end

function lay_floor(width, depth)
  turtle.up()
  for i=1,width-1 do
    lay_line(depth) 
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
  end
  lay_line(depth)
end

lay_floor(floor_width, floor_depth)
