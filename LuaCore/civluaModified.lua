-- A modified version of The Nameless One's civlua module
-- Fixed bugs in iterateTiles and isValidUnitLocation
local func = require "functions"

local yield = coroutine.yield

local domain = {ground = 0, air = 1, sea = 2}
local terrain = {desert = 0, plains = 1, grassland = 2, forest = 3, hills = 4, mountains = 5,
                 tundra = 6, glacier = 7, swamp = 8, jungle = 9, ocean = 10}

-- Wraps getting and setting of key `n` in table `t`.
local function property(t, n)
  return {get = function () return t[n] end,
          set = function (v) t[n] = v end}
end

-- When property `guard` is false, runs `f` and sets `guard` to true, otherwise does nothing. 
local function justOnce(guard, f)
  if not guard.get() then
    f()
    guard.set(true)
  end
end

-- Returns an iterator yielding all tiles on all maps.
local function iterateTiles()
  return coroutine.wrap(function ()
    local w, h, maps = civ.getMapDimensions()
    for z = 0, maps - 1 do
      for y = 0, h - 1 do
        for x = y & 1, w - 1, 2 do
          yield(civ.getTile(x, y,z))
        end
      end
    end
  end)
end

-- Returns an iterator yielding all tribes.
local function iterateTribes()
  return coroutine.wrap(function ()
    for i = 0, 7 do
      yield(civ.getTribe(i))
    end
  end)
end

-- Find a unit type by name.
local function findUnitType(name)
  for i = 0, civ.cosmic.numberOfUnitTypes - 1 do
    local unittype = civ.getUnitType(i)
    if unittype.name == name then
      return unittype
    end
  end
end

-- Find a city by name.
local function findCity(name)
  for city in civ.iterateCities() do
    if city.name == name then
      return city
    end
  end
end

-- Find a tribe by name.
local function findTribe(name)
  for i = 0, 7 do
    local tribe = civ.getTribe(i)
    if tribe.name == name then
      return tribe
    end
  end
end

-- Find the capital city of tribe `tribe`, if it exists.
local function findCapital(tribe)
  for city in civ.iterateCities() do
    if city.owner == tribe and city:hasImprovement(civ.getImprovement(1)) then
      return city
    end
  end
end

-- Returns true if `tile` is a valid location for a unit of type `unittype`, with owner `tribe`, false otherwise.
local function isValidUnitLocation(unittype, tribe, tile)
  if tile and unittype:canEnter(tile) and
    (tile.defender == nil or tile.defender == tribe) then
    local city = tile.city
    if unittype.domain == domain.sea then
      return (tile.terrainType % 16) == terrain.ocean or
        city ~= nil and city.coastal and city.owner == tribe
    else
      return ((tile.terrainType % 16) ~= terrain.ocean or unittype.domain == domain.air) and
        (city == nil or city.owner == tribe)
    end
  end
  return false
end

--[[
Create (a) unit(s) of type `unittype`, owned by tribe `tribe`. This is the Lua implementation of the CreateUnit action.
`locations` is a list of tile coordinates, like {{0, 0, 0}, {1, 1, 0}, ...}.
`options` is a table with any of the following keys:
- `count`, the number of units to create;
- `randomize`, randomize the list of locations;
- `inCapital`, create unit(s) in the tribe's capital city;
- `veteran`, sets the veteran flag on the created unit(s);
- `homeCity`, the home city for the unit(s).
--]]
local function createUnit(unittype, tribe, locations, options)
  options = options or {}
  local function getFirstValidLocation(locations)
    for _, v in ipairs(locations) do
      local tile = civ.getTile(table.unpack(v))
      if isValidUnitLocation(unittype, tribe, tile) then
        return tile
      end
    end
  end
  local function getLocation()
    if options.inCapital then
      local capital = findCapital(tribe)
      if isValidUnitLocation(capital.location) then
        return capital.location
      end
    else
      if options.randomize then
        locations = func.shuffle(locations)
      end
      return getFirstValidLocation(locations)
    end
  end
  local units = {}
  for i = 1, options.count or 1 do
    local location = getLocation()
    if location then
      local unit = civ.createUnit(unittype, tribe, location)
      unit.veteran = options.veteran
      unit.homeCity = options.homeCity
      table.insert(units, unit)
    end
  end
  return units
end

local function serialize_co(o)
  if type(o) == "number" or
     type(o) == "boolean" then
    yield(tostring(o))
  elseif type(o) == "string" then
    yield(string.format("%q", o))
  elseif type(o) == "table" then
    yield("{\r\n")
    for k, v in pairs(o) do
      yield("  [")
      serialize_co(k)
      yield("] = ")
      serialize_co(v)
      yield(",\r\n")
    end
    yield("}\r\n")
  elseif civ.isTile(o) then
    yield(string.format("civ.getTile(%d, %d, %d)", o.x, o.y, o.z))
  elseif civ.isUnit(o) then
    yield(string.format("civ.getUnit(%d)", o.id))
  elseif civ.isCity(o) then
    yield(string.format("civ.getCity(%d)", o.id))
  elseif civ.isTribe(o) then
    yield(string.format("civ.getTribe(%d)", o.id))
  elseif civ.isUnitType(o) then
    yield(string.format("civ.getUnitType(%d)", o.id))
  elseif civ.isImprovement(o) then
    yield(string.format("civ.getImprovement(%d)", o.id))
  elseif civ.isTech(o) then
    yield(string.format("civ.getTech(%d)", o.id))
  elseif civ.isWonder(o) then
    yield(string.format("civ.getWonder(%d)", o.id))
  else
    error("cannot serialize a " .. type(o))
  end
end

-- Return a string representation of object `o`.
local function serialize(o)
  local t = {"return "}
  for s in coroutine.wrap(function () serialize_co(o) end) do
    table.insert(t, s)
  end
  return table.concat(t)
end

-- Return a lua object from string `buffer`
local function unserialize(buffer)
  return load(buffer)()
end

return {domain = domain,
        terrain = terrain,
        property = property,
        justOnce = justOnce,
        iterateTiles = iterateTiles,
        iterateTribes = iterateTribes,
        findUnitType = findUnitType,
        findCity = findCity,
        findTribe = findTribe,
        findCapital = findCapital,
        isValidUnitLocation = isValidUnitLocation,
        createUnit = createUnit,
        serialize = serialize,
        unserialize = unserialize}

