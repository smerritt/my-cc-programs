-- refresh code on this turtle

baseurl = "http://meat.andcheese.org/~spam/mc/"
listurl = baseurl .. "list"

resp = http.get(listurl)

line = resp.readLine()
while line do
  progurl = baseurl .. line
  progname = string.gsub(line, ".lua", "")
  print(progname)

  progresp = http.get(progurl)
  fh = fs.open(progname, "w")
  fh.write(progresp.readAll())
  fh.close()

  line = resp.readLine() 
end
