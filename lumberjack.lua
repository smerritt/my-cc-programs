-- basic single-tree lumberjack, enhanced w/bonemeal
--
-- place output chest under turtle's start position

sapling_slot = 1
wood_slot = 2
bonemeal_slot = 3
first_item_slot = 4

-- if less fuel than this, will eat wood
fuel_threshold = 500

function looking_at_sapling()
  turtle.select(sapling_slot)
  return turtle.compare()
end

function looking_at_tree()
  turtle.select(wood_slot)
  return turtle.compare()
end

function apply_bonemeal()
  turtle.select(bonemeal_slot())
  return turtle.place()
end

function maybe_apply_bonemeal()
  if turtle.get_item_count(bonemeal_slot) > 1 then
    return apply_bonemeal()
  end
end

function descend()
  while turtle.down() do
    -- this'll stop us on top of the chest
  end
end  

function munch_tree() do
  while turtle.detect() do
    turtle.dig()
    if turtle.detectUp() then
      turtle.digUp()
    end
    turtle.up()
  end
  descend()
end

function unload() do
  descend()  -- just to be sure
  for slot in first_item_slot,16 do
    while not turtle.dropDown() do
      print("Chest full!")
      sleep(10.1)
    end
  end
end

function after_munching_tree()
  -- eat all spare saplings first
  for slot in first_item_slot,16 do
    turtle.select(slot)
    if slot.compareTo(sapling_slot) then
      turtle.refuel()
    end
  end
  
  -- eat wood as necessary
  wood_eaten = 0
  if turtle.getFuelLevel() < fuel_threshold then
    for slot in first_item_slot,16 do
      turtle.select(slot)
      if slot.compareTo(wood_slot) then
        while turtle.getFuelLevel() < fuel_threshold and turtle.getItemCount(slot) > 0 do
          wood_eaten += 1
          turtle.refuel(1)
        end
      end
    end
  end
  print("Burned " .. tostring(wood_eaten) .. " wood for fuel.")

  unload()
end

def lumberjack()
  while looking_at_sapling() do
    maybe_apply_bonemeal()
    sleep(2.3)
  end

  munch_tree()
  after_munching_tree()
end

descend()   -- in case of chunk unload/reload, we may be in the air
lumberjack()
