--local gen = require("generalLibrary")
--local civlua = require("civlua")

-- Serialization code written by TheNamelessOne in civlua.lua
-- put it here to avoid worrying about dependencies 
-- also, modified a line, since I'm not trying to return the
-- serialized data
local yield = coroutine.yield
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
  elseif civ.isBaseTerrain(o) then
    yield(string.format("civ.getBaseTerrain(%d, %d)", o.map, o.type))
  elseif civ.isTerrain(o) then
    yield(string.format("civ.getTerrain(%d, %d, %d)", o.map, o.type, o.resource))
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
  -- local t = {"return "} -- original line
  local t = {""}
  for s in coroutine.wrap(function () serialize_co(o) end) do
    table.insert(t, s)
  end
  return table.concat(t)
end


local fileDestination = civ.getToTDir().."\\"..tostring(os.time()).."pasteGameData.lua"

local dialog = civ.ui.createDialog()
dialog:addText("Your game data will be copied and stored in the following file: "..fileDestination.." .  Do you wish to continue?")
dialog:addOption("No",1)
dialog:addOption("Yes",2)
local choice = dialog:show()
if choice == 1 then
    return
end


-- city data
-- cityList[cityID] = {
--  id=number  cityID number
--  name = string cityName
--  attributes = integer city.attributes
--  currentProduction = item (will be seriealized properly anyway)
--  knownTo = integer 
--  location ={int,int,int}
--  originalOwner = tribe
--  owner = tribe
--  shields = integer
--  size = integer
--  sizeForTribe = {[tribeID]=integer}
--  specialists = integer
--  turnsSinceCapture = integer
--  workers = integer
--  improvements = {[improvementID] = bool} true if improvement is in city, false/nil otherwise

-- }

local function toTriple(tile)
    if tile == nil then
        return nil
    end
    return {tile.x,tile.y,tile.z}
end

local cityList = {}

for city in civ.iterateCities() do
    cityList[city.id] = {id=city.id, name=city.name, attributes = city.attributes,
        currentProduction = city.currentProduction, knownTo = city.knownTo,
        location = toTriple(city.location), originalOwner = city.originalOwner, owner = city.owner,
        shields = city.shields, size = city.size, specialists = city.specialists,
        turnsSinceCapture = city.turnsSinceCapture, workers = city.workers}
    local sForTribe = {}
    for i=0,7 do
        if civ.getTribe(i) then
            sForTribe[i] = city.sizeForTribe[civ.getTribe(i)]
        end
    end
    cityList[city.id].sizeForTribe = sForTribe
    local cityImprovements = {}
    for i=0,35 do
        if city:hasImprovement(civ.getImprovement(i)) then
            cityImprovements[i]=true
        end
    end
    cityList[city.id].improvements = cityImprovements
end

-- will have to keep track of original unit id, in order to set carriedby
-- unitData
-- unitData[originalUnitId] = {
--  attributes = integer    -- this includes vet status
--  carriedById = integer or nil unit.carriedBy.id for original id
--  damage = integer
--  domainSpec = integer
--  gotoTile = {int,int,int} or nil
--  homeCity = {int,int,int} (city location) or nil
--  originalId = integer unit.id
--  location = {int,int,int}
--  moveSpent = integer
--  order = integer
--  owner = tribe
--  type = unitType
--  visibility = integer

local unitData = {}
for unit in civ.iterateUnits() do
    unitData[unit.id] = {attributes = unit.attributes, 
    -- for carriedBy, there are sometimes phantom units carrying other units, so check that the unitid
    -- of the carriedBy corresponds to a real unit
    carriedById = (unit.carriedBy and civ.getUnit(unit.carriedBy.id) and unit.carriedBy.id), damage = unit.damage,
        domainSpec = unit.domainSpec, gotoTile = toTriple(unit.gotoTile), homeCity = (unit.homeCity and toTriple(unit.homeCity.location)),
        originalId = unit.id, location = toTriple(unit.location), moveSpent = unit.moveSpent, order = unit.order,
        owner = unit.owner, type = unit.type, visibility = unit.visibility}
end

-- wonderData
-- wonderData[wonderID] = {
--  city = {int,int,int} or nil location of city 
--  destroyed = boolean
--  }

local wonderData = {}
for i=0,27 do
    wonderData[i] = {city = (civ.getWonder(i).city and toTriple(civ.getWonder(i).city.location)), destroyed = civ.getWonder(i).destroyed}
end

-- tileData
-- tileData[index] = {
--  baseTerrain = baseTerrain
--  fertility = integer
--  improvements = integer
--  landmass = integer
--  owner = tribe
--  river = boolean
--  terrain = terrain
--  visibility = integer
--  visibleImprovements = {[tribeID]=integer}
--  location = {int,int,int}
--  }
--
--

local mapWidth, mapHeight,maps = civ.getAtlasDimensions()
local tileData = {}
local tileIndex = 1
for x=0,mapWidth-1 do
    for y=0,mapHeight-1 do
        for z=0,maps-1 do
            if civ.getTile(x,y,z) then
                local tile = civ.getTile(x,y,z)
                tileData[tileIndex] = {baseTerrain = tile.baseTerrain,
                    fertility = tile.fertility, landmass = tile.landmass, owner = tile.owner,
                    improvements = tile.improvements,
                    river = tile.river, terrain = tile.terrain, visibility = tile.visibility,
                    location={x,y,z},
                }
                local vImprovements = {}
                for i=1,7 do
                    vImprovements[i]=tile.visibleImprovements[civ.getTribe(i)]
                end
                tileData[tileIndex].visibleImprovements = vImprovements
                tileIndex=tileIndex+1
            end
        end
    end
end


-- tribeData
-- tribeData[tribeID] = {
--  adjective=string
--  attitude = {[otherTribeID] = integer}
--  betrayals = integer
--  futureTechs = integer
--  government = integer
--  id = integer
--  money = integer
--  name = integer
--  patience = integer
--  reputation = {[otherTribeID]=integer}
--  researchProgress = integer
--  researching = techNil
--  treaties = {[otherTribeID]=integer}
--  technologies = {[techID]=boolNil true if tech owned}
--  leaderName = string tribe.leader.name
--  leaderFemale = bool tribe.leader.female

local tribeData = {}
for i=0,7 do
    local tribe = civ.getTribe(i)
    local aT = {}
    local repT = {}
    local treatiesT = {}
    for j=0,7 do
        aT[j]=tribe.attitude[civ.getTribe(j)]
        repT[j]=tribe.reputation[civ.getTribe(j)]
        treatiesT[j]=tribe.treaties[civ.getTribe(j)]
    end
    local techT = {}
    for j=0,255 do
        -- 253 is max number of techs, 0-252 is probably enough,
        -- but no harm in extras
        if civ.getTech(j) then
            techT[j]=tribe:hasTech(civ.getTech(j))
        end
    end
    tribeData[i] = {adjective = tribe.adjective, attitude=aT,betrayals = tribe.betrayals,
        futureTechs = tribe.futureTechs, government = tribe.government, id = tribe.id,
        money = tribe.money, name = tribe.name, patience = tribe.patience,
        reputation = repT, researching = tribe.researching, treaties = treatiesT,
        researchProgress = tribe.researchProgress,
        technologies = techT, leaderName = (tribe.leader and tribe.leader.name), leaderFemale = (tribe.leader and tribe.leader.female)}
        -- barbarians don't have a leader
end

-- paramsData

local paramsData = {
    marginalDefeat = civ.scen.params.marginalDefeat,
    marginalVictory = civ.scen.params.marginalVictory,
    maxTurns = civ.scen.params.maxTurns,
    name = civ.scen.params.name,
    objectivesProtagonist = civ.scen.params.objectivesProtagonist,
    startingYear = civ.scen.params.startingYear,
    techParadigm = civ.scen.params.techParadigm,
    yearIncrement = civ.scen.params.yearIncrement,
}



local writeToFile = ""
writeToFile = writeToFile.."local cityList = "..serialize(cityList).."\n"
writeToFile = writeToFile.."local unitData = "..serialize(unitData).."\n"
writeToFile = writeToFile.."local wonderData = "..serialize(wonderData).."\n"
writeToFile = writeToFile.."local tileData = "..serialize(tileData).."\n"
writeToFile = writeToFile.."local paramsData = "..serialize(paramsData).."\n"
writeToFile = writeToFile.."local tribeData = "..serialize(tribeData).."\n"
writeToFile = writeToFile.."local originalMapWidth = "..tostring(mapWidth).."\n"
writeToFile = writeToFile.."local originalMapHeight = "..tostring(mapHeight).."\n"
writeToFile = writeToFile.."local originalMapNumber = "..tostring(maps).."\n"
writeToFile = writeToFile.."setmetatable(_G,{})\n" -- this makes sure global variables/functions are allowed

writeToFile = writeToFile..[[print("To paste the game data saved in this file into your new game, run the command\nplaceData(topLeftTileDestinationX,topLeftTileDestinationY)\nThe topLeftTileDestination is the tile where the (0,0) tile of your original game should go.\nSo, if you want the (0,0) tile of your original game to be on the tile (20,10), type this command into the console:\npalceData(20,10)")]].."\n"

writeToFile = writeToFile..[[print("Note: transporters are replaced by pollution, since Lua can't place transporters.")]].."\n"

writeToFile = writeToFile..[===[

function placeData(topLeftTileDestinationX,topLeftTileDestinationY)
    local newMapWidth, newMapHeight, newMapNumber = civ.getAtlasDimensions()
    for i=0,newMapNumber-1 do
        if not civ.getMap(i).customResources then
            civ.ui.text("Map "..tostring(i).." does not have custom resource placement enabled.  Press CTRL+F8 to enable custom resource placement on each map, and then run placeData again.")
            return
        end
    end
    local xOffset = topLeftTileDestinationX -- add this offset to each original x value
    local yOffset = topLeftTileDestinationY -- add this offset to each original y value
--    if xOffset % 2 ~= yOffset % 2 then
--        civ.ui.text("You have chosen the tile ("..tostring(xOffset)..","..tostring(yOffset)..") as the destination for the top left corner of your original map.  It is OK to choose a tile that is not on the map, but you must choose X and Y coordinates that could be a valid tile.  The coordinates must both be even numbers or both be odd numbers.  You have chosen coordinates where one number is even and the other is odd.  Please run placeData again with appropriate choices for X and Y.")
--        return
--    end
    if xOffset % 2 ~= yOffset % 2 then
        civ.ui.text("You have chosen the tile ("..tostring(xOffset)..","..tostring(yOffset)..") as the destination for the top left corner of your original map.  You must choose X and Y coordinates that could be a valid tile.  The coordinates must both be even numbers or both be odd numbers.  You have chosen coordinates where one number is even and the other is odd.  Please run placeData again with appropriate choices for X and Y.")
        return
    end
-- for now, will only copy entire map, so don't have to worry about placing stuff that
-- falls off the map
    if newMapWidth < originalMapWidth then
        civ.ui.text("Your new map has a smaller width than the map you copied from.  At the moment, you must be able to fit your entire original map into the new map.  If you need to reduce the map size, contact Prof. Garfield in the Civfanatics forums.")
    end
    if newMapHeight < originalMapHeight then
        civ.ui.text("Your new map has a smaller height than the map you copied from.  At the moment, you must be able to fit your entire original map into the new map.  If you need to reduce the map size, contact Prof. Garfield in the Civfanatics forums.")
    end
    if newMapNumber < originalMapNumber then
        civ.ui.text("Your new game has a fewer maps than the game you copied from.  At the moment, you must be able to fit your entire original game into the new game.  If you need to remove maps, contact Prof. Garfield in the Civfanatics forums.")
    end
    if xOffset < 0 then
        civ.ui.text("You have chosen topLeftTileDestinationX to be less than 0.  This would place the Western part of your old map outside the new map.  At this time, this functionality is not provided.  If you need this functionality, contact Prof. Garfield in the Civfanatics forums.")
        return
    end
    if yOffset < 0 then
        civ.ui.text("You have chosen topLeftTileDestinationY to be less than 0.  This would place the northern part of your old map outside the new map.  At this time, this functionality is not provided.  If you need this functionality, contact Prof. Garfield in the Civfanatics forums.")
        return
    end
    if xOffset+originalMapWidth > newMapWidth then
        civ.ui.text("Your choice of topLeftTileDestinationX is too big.  This would place the Eastern part of your old map outside the new map.  At this time, this functionality is not provided.  If you need this functionality, contact Prof. Garfield in the Civfanatics forums.")
        return
    end
    if yOffset+originalMapHeight > newMapHeight then
        civ.ui.text("Your choice of topLeftTileDestinationY is too big.  This would place the Southern part of your old map outside the new map.  At this time, this functionality is not provided.  If you need this functionality, contact Prof. Garfield in the Civfanatics forums.")
        return
    end

    local function newTile(tileTriple)
        if tileTriple == nil then
            return nil
        end
        return civ.getTile(tileTriple[1]+xOffset,tileTriple[2]+yOffset, tileTriple[3])
    end
    local function findUnusedTile(mapNumber)
        local startX = 0
        local startY = 0
        if xOffset <= 0 then
            startX = newMapWidth-1
        end
        if yOffset <= 0 then
            startY = newMapHeight-1
        end
        if startX % 2 ~= startY % 2 then
            if startX > 0 then
                startX = startX -1
            else
                startX = startX + 1
            end
        end
        local function getNextTile(tile)
            local currentX = tile.x
            local currentY = tile.y
            local currentZ = tile.z
            local newX = currentX
            local newY = currentY
            local newZ = currentZ
            if xOffset <= 0 then
                newX = newX - 2
                if newX < 0 then
                    newX = newX+ newMapWidth - 1
                    if yOffset > 0 then
                        newY = newY -1
                    else
                        newY = newY +1
                    end
                    if newX % 2 ~= newY % 2 then
                        newX = newX -1
                    end
                end
            else
                newX = newX + 2
                if newX > newMapWidth -1 then
                    newX = 0
                    if yOffset > 0 then
                        newY = newY -1
                    else
                        newY = newY +1
                    end
                    if newX % 2 ~= newY % 2 then
                        newX = newX +1
                    end
                end
            end
            return civ.getTile(newX,newY,newZ)
        end
        local function getNextUnusedTile(currentTile)
            if currentTile.city then
                return getNextUnusedTile(getNextTile(currentTile))
            elseif currentTile.defender then 
                return getNextUnusedTile(getNextTile(currentTile))
            else
                return currentTile
            end
        end
        return getNextUnusedTile(civ.getTile(0,0,mapNumber))
    end
    local function placeCity(cityDatum)
        if cityDatum == nil then
            local destination = findUnusedTile(0)
            local newCity = civ.createCity(civ.getTribe(0),destination)
            newCity.name = "City To Delete"
            return
        end
        local destination = newTile(cityDatum.location)
        local newCity = civ.createCity(cityDatum.owner, destination)
        newCity.name = cityDatum.name
        newCity.attributes = cityDatum.attributes
        newCity.currentProduction = cityDatum.currentProduction
        newCity.knownTo = cityDatum.knownTo
        newCity.shields = cityDatum.shields
        newCity.size = cityDatum.size
        newCity.workers = cityDatum.workers
        newCity.specialists = cityDatum.specialists
        for i=0,7 do
            newCity.sizeForTribe[civ.getTribe(i)] = cityDatum.sizeForTribe[i]
        end
        for i=0,35 do
            if cityDatum.improvements[i] then
                newCity:addImprovement(civ.getImprovement(i))
            end
        end
        destination.owner = newCity.owner
        return
    end
    local function placeTile(tileDatum)
        local destination = newTile(tileDatum.location)
        destination.baseTerrain = tileDatum.baseTerrain
        destination.terrain = tileDatum.terrain
        destination.fertility= tileDatum.fertility
        if tileDatum.improvements & 0x82 == 0x82 then
            -- replace transporters with pollution
            -- since transporters can't be placed with Lua
            tileDatum.improvements = tileDatum.improvements & ~0x02
        end
        destination.improvements = tileDatum.improvements
        destination.landmass = tileDatum.landmass
        destination.owner = tileDatum.owner
        destination.river = tileDatum.river
        destination.visibility = tileDatum.visibility
        for i=1,7 do
            destination.visibleImprovements[civ.getTribe(i)]=tileDatum.visibleImprovements[i]
        end
    end
    local newUnitID = {}
    -- newUnitID[oldUnitID] = id of unit in new game
    -- places a unit, sometimes.  If placeCarriedBy is true,
    -- units with a carriedBy entry are placed.  If it is false,
    -- units without a carriedBy entry are placed
    -- (this allows the carrying units to be placed first)
    local function placeUnit(unitDatum, placeCarriedBy)
        if unitDatum.carriedById and not placeCarriedBy then
            return
        end
        if placeCarriedBy and not unitDatum.carriedById then
            return
        end
        local newUnit = civ.createUnit(unitDatum.type,unitDatum.owner,newTile(unitDatum.location))
        newUnit.attributes = unitDatum.attributes
        newUnit.damage = unitDatum.damage
        newUnit.domainSpec = unitDatum.domainSpec
        if unitDatum.gotoTile then
            newUnit.gotoTile = newTile(unitDatum.gotoTile)
        end
        newUnit.homeCity = nil
        if unitDatum.homeCity then
            newUnit.homeCity = newTile(unitDatum.homeCity).city
        end
        newUnitID[unitDatum.originalId] = newUnit.id
        newUnit.moveSpent = unitDatum.moveSpent
        newUnit.order = unitDatum.order
        newUnit.visibility = unitDatum.visibility
        if unitDatum.carriedById then
            newUnit.carriedBy = civ.getUnit(newUnitID[unitDatum.carriedById])
        end
        newUnit.location.owner = newUnit.owner
    end
    local function copyTribe(tribeDatum)
        local tribe = civ.getTribe(tribeDatum.id)
        for j=0,7 do
            tribe.attitude[civ.getTribe(j)]=tribeDatum.attitude[j]
            tribe.reputation[civ.getTribe(j)]=tribeDatum.reputation[j]
            tribe.treaties[civ.getTribe(j)]=tribeDatum.treaties[j]
        end
        tribe.adjective = tribeDatum.adjective
        tribe.betrayals = tribeDatum.betrayals
        tribe.futureTechs = tribeDatum.futureTechs
        tribe.government = tribeDatum.government
        tribe.money = tribeDatum.money
        tribe.name = tribeDatum.name
        tribe.patience = tribeDatum.patience
        tribe.researchProgress = tribeDatum.researchProgress
        tribe.researching = tribeDatum.researching
        -- barbarians don't have a leader
        if tribe.id > 0 then
            tribe.leader.name = tribeDatum.leaderName
            tribe.leader.female = tribeDatum.leaderFemale
        end
        for j=0,255 do
            -- 253 is max number of techs, 0-252 is probably enough,
            -- but no harm in extras
            if civ.getTech(j) then
                tribe:takeTech(civ.getTech(j))
                if tribeDatum.technologies[j] then
                    tribe:giveTech(civ.getTech(j))
                end
            end
        end
    end

    -- now, begin copy procedure
    -- take note of existing units, so they can be deleted
    local unitsToDelete = {}
    for unit in civ.iterateUnits() do
        unitsToDelete[#unitsToDelete+1] = unit
    end
    for i=0,7 do
        copyTribe(tribeData[i])
    end
    -- place tiles
    for _,tileDatum in pairs(tileData) do
        placeTile(tileDatum)
    end
    -- place cities
    local maxCityId = 0
    for index,cityDatum in pairs(cityList) do
        if index > maxCityId then
            maxCityId = index
        end
    end
    for i=0,maxCityId do
        if cityList[i] then
            placeCity(cityList[i])
        end
    end
    for i=0,27 do
        civ.getWonder(i).city = newTile(wonderData[i].city) and newTile(wonderData[i].city).city
        if civ.getWonder(i).destroyed then
            civ.getWonder(i):destroy()
        end
    end
    -- place units not carried by other units
    for _,unitDatum in pairs(unitData) do
        placeUnit(unitDatum,false)
    end
    for _,unitDatum in pairs(unitData) do
        placeUnit(unitDatum,true)
    end
    -- delete the original units
    for _,unit in pairs(unitsToDelete) do
        civ.deleteUnit(unit)
    end
    civ.scen.params.marginalDefeat = paramsData.marginalDefeat
    civ.scen.params.marginalVictory = paramsData.marginalVictory
    civ.scen.params.maxTurns = paramsData.maxTurns
    civ.scen.params.name = paramsData.name
    civ.scen.params.objectivesProtagonist = paramsData.objectivesProtagonist
    print("The starting year for this scenario is "..tostring(paramsData.startingYear))
    civ.scen.params.techParadigm = paramsData.techParadigm
    civ.scen.params.yearIncrement = paramsData.yearIncrement
    print("Everything Placed")


end

]===]

local file = io.open(fileDestination,"a")
io.output(file)
io.write(writeToFile)
io.close(file)
print("Game data written to "..fileDestination)




