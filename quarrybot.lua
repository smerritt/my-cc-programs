-- take a quarry, an energy tesseract, and an unload chest and move it around
-- to get arbitrarily many resources
--
-- works well at high levels, but should also work underground, like
-- if you only want levels 20 and below
--
-- 99% supports resuming, but that 1% is a bitch to get right
BUCKET_SLOT = 1
ENDERCHEST_SLOT = 2
TESSERACT_SLOT = 3
ENG_TURTLE_SLOT = 4
QUARRY_SLOT = 5

-- first slot after reserved slots above
FIRST_ITEM_SLOT = 6

-- if we don't get any items at all for a long time, we might be above
-- a hole, so move it
INITIAL_ITEM_TIMEOUT = 180   -- seconds

-- after this long since the last item, it's time to pack it in and move
FINAL_ITEM_TIMEOUT = 30   -- seconds

-- sometimes, natural cobble generators happen, and we'll stick, so
-- let's have a cap on the number of items we'll take. if we get more
-- than this number, we're definitely in a cobble generator situation.
MAX_ITEMS = 9*9*256

-- parasitize quarry output when fuel is under this amount
--
-- NB: this probably won't work in the nether, so if you're quarrying
-- the nether, use a well-fueled turtle
FUEL_THRESHOLD = 1000

STATEFILE = 'quarrybot-state'

STATE_PLACING_QUARRY = 1
STATE_PLACING_ENDERCHEST = 2
STATE_MOVING_ABOVE_TESSERACT = 3
STATE_PLACING_TESSERACT = 4
STATE_RETURNING_FROM_PLACING_TESSERACT = 5
STATE_WAITING_FOR_INITIAL_ITEM = 6
STATE_WAITING_FOR_LAST_ITEM = 7
STATE_RETRIEVING_ENDERCHEST = 8
STATE_RETRIEVING_QUARRY = 9
STATE_MOVING_ATOP_TESSERACT = 10
STATE_MOVING_BEHIND_TESSERACT = 11
STATE_RETRIEVING_TESSERACT = 12
STATE_RETRIEVING_ENG_TURTLE = 13
STATE_MOVING = 14


loadfile("util")()

function debug(msg)
  print(msg)
end

function get_current_state()
  fh = fs.open(STATEFILE, "r")
  if not fh then
    return STATE_PLACING_QUARRY
  end
  state = tonumber(fh.readAll())
  fh.close()
  return state
end

function write_new_state(new_state)
  if new_state == nil then
    error("nil state? that's a bug.")
  end
  fh = fs.open(STATEFILE, "w")
  fh.write(tostring(new_state))
  fh.close()
end

-- Go from current state to success state if fn returns a truthy
-- value. If fn returns a falsy value and failure_state is given,
-- go to failure state.  Otherwise, do nothing.
function state_transition(fn, success_state, failure_state)
  if fn() then
    write_new_state(success_state)
    return true
  elseif failure_state ~= nil then
    write_new_state(failure_state)
    return true
  else
    return false
  end
end


function place_quarry()
  debug("place_quarry()")
  if turtle.getItemCount(QUARRY_SLOT) == 0 and turtle.detectDown() then
    -- if we got interrupted after placement but before writing the new
    -- state, we'll have no quarry but a block below us; this is okay.
    return true
  elseif turtle.getItemCount(QUARRY_SLOT) == 0 then
    error("No quarry in inventory or beneath me")
  end

  turtle.select(QUARRY_SLOT)
  return turtle.placeDown()
end


function place_enderchest()
  debug("place_enderchest()")
  if turtle.getItemCount(ENDERCHEST_SLOT) == 0 and turtle.detectUp() then
    -- if we got interrupted after placement but before writing the new
    -- state, we'll have no quarry but a block below us; this is okay.
    return true
  elseif turtle.getItemCount(ENDERCHEST_SLOT) == 0 then
    error("No ender chest in inventory or above me")
  end

  turtle.select(ENDERCHEST_SLOT)
  return turtle.placeUp()
end


function move_to_place_tesseract()
  debug("move_to_place_tesseract()")
  if turtle.detectDown() then
    -- if we are still above the quarry, move
    -- if we got interrupted, we might not be, though
    util.back(1)
  end
  return true
end


function place_tesseract()
  debug("place_tesseract()")
  if turtle.getItemCount(TESSERACT_SLOT) == 0 and turtle.detectDown() then
    -- if we got interrupted after placement but before writing the new
    -- state, we'll have no tesseract, but we will have a block below us
    return true
  elseif turtle.getItemCount(TESSERACT_SLOT) == 0 then
    error("No tesseract in inventory or beneath me")
  end

  turtle.select(TESSERACT_SLOT)
  return turtle.placeDown()
end


function return_from_placing_tesseract()
  debug("return_from_placing_tesseract()")
  if turtle.detectDown() then
    -- either above tesseract or quarry
    util.back(1)
    if turtle.detectDown() then
      -- now we're definitely above the tesseract
      util.forward(1)
    else
      -- we are now one behind the tesseract
      util.forward(2)
    end
  else
    -- we are one behind the tesseract
    util.forward(2)
  end
  return true
end


function wait_for_initial_item()
  debug("wait_for_initial_item()")
  slept = 0
  while slept < INITIAL_ITEM_TIMEOUT do
    -- ugh
    if turtle.getItemCount(ENDERCHEST_SLOT) > 0 then
      return true
    elseif turtle.getItemCount(TESSERACT_SLOT) > 0 then
      return true
    elseif turtle.getItemCount(QUARRY_SLOT) > 0 then
      return true
    else
      for i=FIRST_ITEM_SLOT,16 do
        if turtle.getItemCount(i) > 0 then
          return true
        end
      end
    end
    sleepytime = math.random(100) / 20.0  -- ticks --> s
    sleep(sleepytime)
    slept = slept + sleepytime
  end
  return false    -- didn't get squat
end


function wait_for_last_item()
  debug("wait_for_last_item()")
  time_since_last_item = 0
  total_items_moved = 0

  while (time_since_last_item < FINAL_ITEM_TIMEOUT and
         total_items_moved < MAX_ITEMS) do
    items_moved = 0

    items_moved = items_moved + _unload_slot_up(ENDERCHEST_SLOT)
    items_moved = items_moved + _unload_slot_up(TESSERACT_SLOT)
    items_moved = items_moved + _unload_slot_up(QUARRY_SLOT)
    for i=FIRST_ITEM_SLOT,16 do
      items_moved = items_moved + _unload_slot_up(i)
    end

    if items_moved > 0 then
      time_since_last_item = 0
      total_items_moved = total_items_moved + items_moved
      debug("Unloaded " .. tostring(items_moved) .. " items")
    end

    sleepytime = math.random(500) / 20.0  -- ticks --> s
    sleep(sleepytime)
    time_since_last_item = time_since_last_item + sleepytime
  end
  return true
end


function retrieve_enderchest()
  debug("retrieve_enderchest()")
  if turtle.getItemCount(ENDERCHEST_SLOT) == 0 and not turtle.detectUp() then
    error("No enderchest in inventory or above me")
  elseif turtle.detectUp() then
    turtle.select(ENDERCHEST_SLOT)
    turtle.digUp()
  end
  return true
end


function retrieve_quarry()
  debug("retrieve_quarry()")
  if turtle.getItemCount(QUARRY_SLOT) == 0 and not turtle.detectDown() then
    error("No quarry in inventory or above me")
  elseif turtle.detectDown() then
    turtle.select(QUARRY_SLOT)
    turtle.digDown()
  end
  return true
end


function move_atop_tesseract()
  debug("move_atop_tesseract()")
  if not turtle.detectDown() then
    -- we're above where the quarry was
    util.back(1)
  end
  return true
end


function move_behind_tesseract()
  debug("move_behind_tesseract()")
  if turtle.detectDown() then
    -- we're above the tesseract; go back 1
    util.back(1)
  end
  return true
end


function retrieve_tesseract()
  debug("retrieve_tesseract()")
  if turtle.getItemCount(ENG_TURTLE_SLOT) > 0 then
    turtle.select(ENG_TURTLE_SLOT)
    turtle.placeDown()
  end

  debug("turning on other turtle")
  handle = peripheral.wrap("bottom")
  if not handle then
    error("Failed to get handle to other turtle; can't turn it on!")
  end
  debug("handle = " .. tostring(handle))
  handle.turnOn()   -- returns nil no matter what. *sigh*

  turtle.select(TESSERACT_SLOT)
  while not turtle.suckDown() do
    debug(" didn't get tesseract; sleeping a second")
    sleep(1)
  end
  return true
end


function retrieve_eng_turtle()
  debug("retrieve_eng_turtle()")
  if turtle.getItemCount(ENG_TURTLE_SLOT) == 0 and not turtle.detectDown() then
    error("No eng turtle below me or in inventory!")
  elseif turtle.detectDown() then
    turtle.select(ENG_TURTLE_SLOT)
    return turtle.digDown()
  end
  return true
end


-- XXX some duplication with stripmine + spiralmine in this function
function munch_path()
  util.ingestUp(BUCKET_SLOT)  -- just in case
  sleep(1)  -- give gravel a chance to fall *and* give
            -- the player a chance to ctrl-t
  while turtle.detectUp() do
    util.ingestUp(BUCKET_SLOT)
    sleep(1)
  end

  util.ingest(BUCKET_SLOT)
  util.ingestDown(BUCKET_SLOT)
end


function advance()
  munch_path()
  util.forward(1)
end


function move_to_next_site()
  debug("move_to_next_site()")
  for i=1,11 do
    advance()
  end
  munch_path()   -- make sure quarry site is clear
  return true
end


-- utility function: unload slot to enderchest or consume for fuel;
-- returns number of items moved/consumed
function _unload_slot_up(slot)
  itemcount = turtle.getItemCount(slot)
  if itemcount == 0 then
    return 0
  elseif turtle.getFuelLevel() < FUEL_THRESHOLD then
    turtle.select(slot)
    turtle.refuel()       -- may fail; that's okay
  end
  util.unloadUp(slot)   -- NB: this works fine with an empty slot
  return itemcount
end


function main()
  while true do
    state = get_current_state()
    debug("In state " .. tostring(state))
    if state == STATE_PLACING_QUARRY then
      state_transition(place_quarry, STATE_PLACING_ENDERCHEST)
    elseif state == STATE_PLACING_ENDERCHEST then
      state_transition(place_enderchest, STATE_MOVING_ABOVE_TESSERACT)
    elseif state == STATE_MOVING_ABOVE_TESSERACT then
      state_transition(move_to_place_tesseract, STATE_PLACING_TESSERACT)
    elseif state == STATE_PLACING_TESSERACT then
      state_transition(place_tesseract, STATE_RETURNING_FROM_PLACING_TESSERACT)
    elseif state == STATE_RETURNING_FROM_PLACING_TESSERACT then
      state_transition(return_from_placing_tesseract, STATE_WAITING_FOR_INITIAL_ITEM)
    elseif state == STATE_WAITING_FOR_INITIAL_ITEM then
      state_transition(wait_for_initial_item, STATE_WAITING_FOR_LAST_ITEM,
                                              STATE_RETRIEVING_ENDERCHEST)
    elseif state == STATE_WAITING_FOR_LAST_ITEM then
      state_transition(wait_for_last_item, STATE_RETRIEVING_ENDERCHEST)
    elseif state == STATE_RETRIEVING_ENDERCHEST then
      state_transition(retrieve_enderchest, STATE_RETRIEVING_QUARRY)
    elseif state == STATE_RETRIEVING_QUARRY then
      state_transition(retrieve_quarry, STATE_MOVING_ATOP_TESSERACT)
    elseif state == STATE_MOVING_ATOP_TESSERACT then
      state_transition(move_atop_tesseract, STATE_MOVING_BEHIND_TESSERACT)
    elseif state == STATE_MOVING_BEHIND_TESSERACT then
      state_transition(move_behind_tesseract, STATE_RETRIEVING_TESSERACT)
    elseif state == STATE_RETRIEVING_TESSERACT then
      state_transition(retrieve_tesseract, STATE_RETRIEVING_ENG_TURTLE)
    elseif state == STATE_RETRIEVING_ENG_TURTLE then
      state_transition(retrieve_eng_turtle, STATE_MOVING)
    elseif state == STATE_MOVING then
      state_transition(move_to_next_site, STATE_PLACING_QUARRY)
    else
      error("Unknown state " .. tostring(state))
    end
    sleep(0.5)
  end
end


main()
