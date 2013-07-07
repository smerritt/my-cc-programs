-- sorting turtle!
--
-- usage: sort <N>, where N == number of items to match
-- items to match go in slots 1 through N
--
-- matching items go down, non-matching items go forward
--
-- if inventory below is full, it all goes forward

local args = { ... }
n_items = tonumber(args[1])
print("Sorting " .. tostring(n_items) .. " items")

-- see if currently-selected slot contains matching item
function matches()
  for slot=1,n_items do
    if turtle.compareTo(slot) then
      return true
    end
  end
  return false
end

function shipit()
  -- only keep 1 of each thing; there's no need to have
  -- a stack of diamonds for comparison
  for slot=1,n_items do
    turtle.select(slot)
    qty_to_drop = turtle.getItemCount(slot) - 1
    if qty_to_drop > 0 then
      turtle.dropDown(qty_to_drop)
    end
  end

  for slot=(n_items+1),16 do
    turtle.select(slot)
    if matches() then
      turtle.dropDown()
    end
  end
  for slot=(n_items+1),16 do
    turtle.select(slot)
    turtle.drop()
  end
end

while true do
  shipit()
  ticks_to_sleep = math.random(20, 200)
  sleep(ticks_to_sleep / 20.0)
end
