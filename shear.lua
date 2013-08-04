-- Automatic sheep shearer
-- Sheep in front, inventory below


loadfile("util")()

-- Sleep a random, long amount of time
function rsleep()
  duration = math.random(10, 60)
  print("Sleeping for " .. tostring(duration) .. " seconds")
  sleep(duration)
end


function unload()
  for slot=1,16 do
    -- will wait for space
    util.unloadDown(slot)
  end
end  


-- main program
unload()
while true do
  if turtle.attack() then   -- shear
    sleep(2)        -- let the wool fall back down
  end
  turtle.suck()   -- you'd think we'd pick up the wool, but no
  unload()
  rsleep()
end

