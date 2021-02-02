-- Split string `s` on delimiter `sep`
local function split(s, sep)
   local fields = {}
   local pattern = string.format("([^%s]+)", sep)
   string.gsub(s, pattern, function(c)
      table.insert(fields, c)
   end)
   return table.unpack(fields)
end

-- Split string `s` into lines
local function splitlines(s)
   return split(s, "\r\n")
end

local function swap(a, i, j)
  a[i], a[j] = a[j], a[i]
end

-- Shuffle table `t` in place
local function shuffle(t)
  local i = #t
  while i > 1 do
    local ix = math.random(i)
    swap(t, ix, i)
    i = i - 1
  end
  return t
end

return {split = split,
        splitlines = splitlines,
        swap = swap,
        shuffle = shuffle}
