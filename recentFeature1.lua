--require("unitDataTestingSuite")
local traits = require("traits")
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(2)
local discreteEvents = require("discreteEventsRegistrar")
local changeRules = require("changeRules")
local keyboard = require("keyboard")
local civlua   = require("civlua")
local text     = require("text")
local unitData = require("unitData")
---@module "tribeData"
local tribeData = require("tribeData")
local aStarCiv  = require("aStarCiv")
--local counter   = require("counter")
local delayedAction = require("delayedAction")
local diplomacy     = require("diplomacy")
local object        = require("object")
local changeRules   = require("changeRules")

--local flag = require("flag")

--[[
discreteEvents.onCityProcessingComplete(function (turn, tribe)
    if tribe:hasTech(gen.original.aCommunism) then
        gen.justOnce("communismDiscovered"..tostring(tribe.id),function()
            tribe.government = gen.c.govtCommunism
        end)
    end
end)
--]]

--[[
local treasuries = {[0]=0,0,0,0,0,0,0,0,}

discreteEvents.onActivateUnit(function(unit,source,repeatMove)
    for id=0,7 do
        treasuries[id] = civ.getTribe(id).money
    end
end)

discreteEvents.onCityTaken(function (city, defender)
    city.owner.money = treasuries[city.owner.id]
    defender.money = treasuries[defender.id]
    local plunderValue = 50
    local transferAmount = math.min(defender.money, plunderValue)
    city.owner.money = city.owner.money + transferAmount
    defender.money = defender.money - transferAmount
end)
]]
--[[
local movementSounds = {
    ["default"] = "Movepiece_reg.wav",
    [gen.original.uSettlers.id] = "Movepiece_alt.wav",
    [gen.original.uFreight.id] = "Diesel.wav",
}
local currentMoveSound = nil
local soundFolder = gen.getScenarioDirectory().."\\Sound"



discreteEvents.onActivateUnit(function(unit,source,repeatMove)
    local moveSound = movementSounds[unit.type.id] or movementSounds["default"]
    if moveSound ~= currentMoveSound then
        local soundFile, err = io.open(soundFolder.."\\"..moveSound,"rb")
        if err then
            error("Error opening sound file '"..moveSound.."': "..err)
            return
        end
        local fileContent = soundFile:read("*a")
        soundFile:close()
        io.open(soundFolder.."\\Movpiece.wav","wb"):write(fileContent):close()
        currentMoveSound = moveSound
    end
end)
]]
--[[
local function healUnitIfApplicable(unit,tribe)
    if unit.owner ~= tribe then
        return
    end
    if gen.isMoved(unit) then
        return
    end
    local healFraction = 0.5
    if unit.type.domain == gen.c.domainSea then
        healFraction = 0.25
    end
    local healQuantity = math.ceil(unit.type.hitpoints * healFraction)
    unit.damage = math.max(0,unit.damage - healQuantity)
    gen.setMoved(unit)
end

discreteEvents.onTribeTurnBegin(function(turn,tribe)
    for unit in civ.iterateUnits() do
        healUnitIfApplicable(unit,tribe)     
    end
end)
--]]


local artilleryRangeTable = {
    [gen.original.uArtillery.id] = 3,
    [gen.original.uCannon.id] = 2,
    [gen.original.uHowitzer.id] = 4,
}
local targetMarker = "pollution"

--[[
Determines if a unit is an artillery unit, and, if so, returns the range of the unit.
---@param unit unitObject
---@return integer|false Returns the range of the unit if it is an artillery unit, otherwise returns false.
local function getArtilleryRange(unit)
    return artilleryRangeTable[unit.type.id] or false
end

---@type unitObject|nil
local mostRecentActiveUnit = nil

---@type number|nil
local artilleryVPressTime = nil


---@type unitObject|nil
local artillerySelectingTarget = nil

local function cancelTargetSelection()
    gen.removeAllMarkers(nil,targetMarker)
    if civ.isUnit(artillerySelectingTarget) then
        ---@cast artillerySelectingTarget unitObject
        gen.setToNoOrders(artillerySelectingTarget)
        artillerySelectingTarget = nil
    end
end

discreteEvents.onActivateUnit(function (unit, source, repeatMove)
    if civ.isUnit(artillerySelectingTarget) then
        cancelTargetSelection()
    end
    mostRecentActiveUnit = unit
end)


discreteEvents.onKeyPress(function(keyCode)
    local activeUnit = mostRecentActiveUnit
    if artillerySelectingTarget and not gen.isSleeping(artillerySelectingTarget) then
        artillerySelectingTarget = nil
    end
    -- The artillery is selecting a target
    if civ.isUnit(artillerySelectingTarget) and keyCode == keyboard.k then
        ---@cast artillerySelectingTarget unitObject       
        local targetTile = civ.getCurrentTile()
        if os.time() - artilleryVPressTime > 10 then
            local choice = text.menu({"Yes","No"},"Do you wish to fire on these coordinates ("..text.coordinates(targetTile)..")?","Confirm Artillery Order")
            if choice == 2 then
                cancelTargetSelection()
                return
            end
        end
        if targetTile.defender == nil or targetTile.defender == artillerySelectingTarget.owner then
            civ.ui.text("This tile is not a valid target.")
            return
        end
        if gen.distance(artillerySelectingTarget.location,targetTile) > getArtilleryRange(artillerySelectingTarget) then
            civ.ui.text("This tile is out of range.")
            return
        end
        for unit in targetTile.units do
            unit.damage = unit.damage + 3
        end
        gen.spendMovementPoints(artillerySelectingTarget,1)
        gen.removeAllMarkers(artillerySelectingTarget.owner,targetMarker)
        if gen.moveRemaining(artillerySelectingTarget) > 0 then
            artillerySelectingTarget:activate()
        end
        artillerySelectingTarget = nil
        return
    end
    if civ.isUnit(artillerySelectingTarget) and keyCode == keyboard.v then
        cancelTargetSelection()
        return
    end
    if civ.isUnit(artillerySelectingTarget) then
        return
    end
    if not civ.isUnit(activeUnit) then
        return
    end
    ---@cast activeUnit unitObject
    local artilleryRange = getArtilleryRange(activeUnit)
    if not artilleryRange then
        return
    end
    if keyCode == keyboard.v then
        artillerySelectingTarget = activeUnit
        artilleryVPressTime = os.time()
        for _,tile in pairs(gen.getTilesInRadius(activeUnit.location,artilleryRange)) do
            if tile.defender ~= nil and tile.defender ~= activeUnit.owner then
                gen.placeMarker(tile,artillerySelectingTarget.owner,targetMarker)
            end
        end
        gen.showAllMarkers(targetMarker)
    end
end)

discreteEvents.onScenarioLoaded(function()
    gen.removeAllMarkers(nil,targetMarker)
end)
discreteEvents.onTribeTurnEnd(function()
    gen.removeAllMarkers(nil,targetMarker)
end)
discreteEvents.onActivateUnit(function (unit, source, repeatMove)
end)
]]





--[[
flag.define("trueThenFalse",true)
flag.define("falseThenTrue",false)
flag.define("trueThenTrue",true)
flag.define("falseThenFalse",false)

counter.define("0Then1.5",0)
counter.define("1.5Then0",1.5)
counter.define("0Then0",0)
counter.define("1.5Then1.5",1.5)

discreteEvents.onKeyPress(function(keyCode)
    if keyCode == keyboard.nine then
        flag.setFalse("trueThenFalse")
        flag.setTrue("falseThenTrue")
        counter.add("0Then1.5",1.5)
        counter.subtract("1.5Then0",1.5)
    end
    if keyCode == keyboard.eight then
        local message = ""
        message = message .. "trueThenFalse: " .. tostring(flag.value("trueThenFalse")) .. "\n^"
        message = message .. "falseThenTrue: " .. tostring(flag.value("falseThenTrue")) .. "\n^"
        message = message .. "trueThenTrue: " .. tostring(flag.value("trueThenTrue")) .. "\n^"
        message = message .. "falseThenFalse: " .. tostring(flag.value("falseThenFalse")) .. "\n^"
        message = message .. "0Then1.5: " .. tostring(counter.value("0Then1.5")) .. "\n^"
        message = message .. "1.5Then0: " .. tostring(counter.value("1.5Then0")) .. "\n^"
        message = message .. "0Then0: " .. tostring(counter.value("0Then0")) .. "\n^"
        message = message .. "1.5Then1.5: " .. tostring(counter.value("1.5Then1.5")) .. "\n^"
        text.simple(message)
    end
end)





local data = require("data")
rawset(_G,"data",data)

--]]
--[[
data.defineFlag("anyFlagTest",false,"onTurn")

data.definePhrase("anyPhraseTest","","onTurn")

data.definePhrase("enumeratedPhrasesTest","phrase1","onTurn",{"phrase1","phrase2","phrase3",["phrase4"]="phrase5",["phrase6"]=false})

--[[
discreteEvents.onKeyPress(function (keyCode)
    if keyCode == keyboard.nine then
        civ.ui.text(tostring(data.flagGetValue("anyFlagTest")))
        data.flagSetValue("anyFlagTest",not data.flagGetValue("anyFlagTest"))
        civ.ui.text(tostring(data.flagGetValue("anyFlagTest")))
        data.flagSetValue("anyFlagTest",not data.flagGetValue("anyFlagTest"))
        civ.ui.text(tostring(data.flagGetValue("anyFlagTest")))
    end
end)
--]]

    
--[[
local wonderData = require("wonderData")
local improvementData = require("improvementData")
local unitTypeData = require("unitTypeData")
local terrainData = require("terrainData")
local baseTerrainData = require("baseTerrainData")
local techData = require("techData")

wonderData.defineCounter("test",0,0,100,"increment","onTurn",-1)
improvementData.defineCounter("test",0,0,100,"increment","onTurn",-1)
unitTypeData.defineCounter("test",0,0,100,"increment","onTurn",-1)
terrainData.defineCounter("test",0,0,100,"increment","onTurn",-1)
baseTerrainData.defineCounter("test",0,0,100,"increment","onTurn",-1)
techData.defineCounter("test",0,0,100,"increment","onTurn",-1)

discreteEvents.onKeyPress(function (keyCode)
    if keyCode == keyboard.nine then
        wonderData.counterSetValue(civ.getWonder(11),"test",10)
        improvementData.counterSetValue(civ.getImprovement(11),"test",10)
        unitTypeData.counterSetValue(civ.getUnitType(11),"test",10)
        terrainData.counterSetValue(gen.getTerrainFromID(11),"test",10)
        baseTerrainData.counterSetValue(gen.getBaseTerrainFromID(8),"test",10)
        techData.counterSetValue(civ.getTech(11),"test",10)
    end
    if keyCode == keyboard.eight then
        local message = ""
        message = message .. "Wonder: " .. tostring(wonderData.counterGetValue(civ.getWonder(11),"test")) .. "\n^"
        message = message .. "Improvement: " .. tostring(improvementData.counterGetValue(civ.getImprovement(11),"test")) .. "\n^"
        message = message .. "UnitType: " .. tostring(unitTypeData.counterGetValue(civ.getUnitType(11),"test")) .. "\n^"
        message = message .. "Terrain: " .. tostring(terrainData.counterGetValue(gen.getTerrainFromID(11),"test")) .. "\n^"
        message = message .. "BaseTerrain: " .. tostring(baseTerrainData.counterGetValue(gen.getBaseTerrainFromID(8),"test")) .. "\n^"
        message = message .. "Tech: " .. tostring(techData.counterGetValue(civ.getTech(11),"test")) .. "\n^"
        text.simple(message)
    end
end)
--]]

--[[
---@type unitObject|nil
local possiblePillager = nil
---@type tileObject|nil
local possiblePillagedTile = nil
---@type bitmask|nil
local possiblePillagedTileImprovements = nil
discreteEvents.onActivateUnit(function(unit)
    if gen.isCanImproveTiles(unit.type) then
        possiblePillager = nil
        possiblePillagedTile = nil
        possiblePillagedTileImprovements = nil
    else
        possiblePillager = unit
        possiblePillagedTile = unit.location
        possiblePillagedTileImprovements = unit.location.improvements
    end
end)

discreteEvents.onFinalOrderGiven(function(unit)
    if possiblePillager ~= unit or possiblePillagedTile ~= unit.location then
        possiblePillager = nil
        possiblePillagedTile = nil
        possiblePillagedTileImprovements = nil
        return
    end
    if possiblePillagedTileImprovements == nil then
        possiblePillager = nil
        possiblePillagedTile = nil
        possiblePillagedTileImprovements = nil
        return
    end
    -- can only get here if the possible pillaged tile isn't nil
    ---@cast possiblePillagedTile tileObject
    possiblePillagedTile.improvements = possiblePillagedTileImprovements
    possiblePillager = nil
    possiblePillagedTile = nil
    possiblePillagedTileImprovements = nil
    return
end)
--]]

--for x = 0,1000 do for y = 0,1000 do for z = 0,3 do local tile = civ.getTile(x,y,z) if tile then local imp = tile.improvements if imp & 0x40 == 0x40 and imp | ~0x02 == ~0x02 then tile.improvements = imp & ~0x40 end end end end end

--[[
local germanHomeCities = {
    [gen.getTileID(object.lBERLIN)] = true,
    [gen.getTileID(object.lCologne)] = true,
    [gen.getTileID(object.lStettin)] = true,
}

discreteEvents.onTribeTurnBegin(function (turn, tribe)
    if tribe ~= object.pAxis then
        return
    end
    for unit in civ.iterateUnits() do
        if unit.owner == tribe and unit.type == object.uForcedLabor and germanHomeCities[gen.getTileID(unit.location)] then
            unit.location.city.shields = unit.location.city.shields + 5
        end
    end
end)
]]