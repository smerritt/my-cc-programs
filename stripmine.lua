-- mine in a strip N long
-- TODO: unloading into ender chest

local args = { ... }

depth = tonumber(args[1])

loadfile("util")()

function unload()
  print("WRITE ME")
end

for i=1,depth-1 do
  shell.run("mineplus")
  unload()
  turtle.dig()
  turtle.forward()
end

shell.run("mineplus")
unload()

for i=1,depth-1 do
  util.back()
end
