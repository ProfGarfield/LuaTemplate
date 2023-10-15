--
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- This module implements features related to ships:
--  When can ships unload onto beaches
--  What planes can use which carriers
--
--

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
local civlua = require("civlua")
local diplomacy = require("diplomacy")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local text = require("text")

-- Unloading Units onto beaches
-- Both the ship doing the unloading and the unit
-- being unloaded must satisfy these conditions
-- in order to be activated
-- Change the @LANDFALL message so there is no option
-- to unload a ship by sailing into a land tile
--[[
@LANDFALL
@title=Disembark
Shall we disembark, Sire,
and leave the ships behind?

Stay With Ships
Make Landfall
--]]
-- Loading Units onto ships:
-- The unit and the ship type must both satisfy the
-- conditions, which are determined based on the location
-- of the unit attempting to board the ship
-- (if the unit can't board a ship type, the type's carrying capacity
-- will be set to 0)
--These restrictions may not hold for the AI
-- beachShipSettings[unitType.id] = {
--  .restrictBeachUnload = boolean or number or nil
--      if false or nil, unit can unload onto any beach
--      if true, unit can never unload onto a "beach"
--      (but might be able to unload beside a foreign port, see below)
--      if 0 or positive number, the unit can not have expended
--      more than that many "full" movement points.  That is, can only unload if
--      unit.moveSpent <= beachShipSettings[unit.type.id].restrictBeachUnload*totpp.movementMultipliers.aggregate
--      if negative number, the unit can not have expended more than
--      that many 'atomic' movement points, that is
--      unit.moveSpent <= -beachShipSettings[unit.type.id].restrictBeachUnload
--
--  .restrictPeacePortUnload = boolean or number or nil
--      if false or nil, the unit can unload from a square adjacent to a city
--      owned by a civ with which the player is at peace (or allied) without penalty,
--      even if restrictBeachUnload is true
--      if true, the unit can only unload if it can unload onto a "beach"
--      if 0 or positive number, the unit can not have expended
--      more than that many "full" movement points.  That is, can only unload if
--      unit.moveSpent <= beachShipSettings[unit.type.id].restricPeacePortUnload*totpp.movementMultipliers.aggregate
--      if negative number, the unit can not have expended more than
--      that many 'atomic' movement points, that is
--      unit.moveSpent <= -beachShipSettings[unit.type.id].restricPeacePortUnload
--
--  .restrictAlliedPortUnload = boolean or number or nil
--      if false or nil, the unit can unload from a square adjacent to a city
--      owned by a civ with which the player is allied without penalty,
--      even if restrictBeachUnload and restrictPortUnload are true
--      if true, the unit can only unload if it can unload onto a "beach" or peace port
--      if 0 or positive number, the unit can not have expended
--      more than that many "full" movement points.  That is, can only unload if
--      unit.moveSpent <= beachShipSettings[unit.type.id].restricAlliedPortUnload*totpp.movementMultipliers.aggregate
--      if negative number, the unit can not have expended more than
--      that many 'atomic' movement points, that is
--      unit.moveSpent <= -beachShipSettings[unit.type.id].restricAlliedPortUnload
--
--  .beachUnloadPenalty = function(unit)-->void or number or nil
--      if nil, nothing is done when unloading the unit
--      if number is 0 or positive, set the moveSpent of that unit so that
--      that many full movement points are expended, unless more have already been expended
--      i.e.
--      unit.moveSpent = math.max(unit.moveSpent, beachShipSettings[unit.type.id].beachUnloadPenalty*totpp.movementMultipliers.aggregate)
--      if number is negative, set the move spent so that many atomic movement units have been spent
--      if function, that function will be run for the unit unloaded, then for the ship carrying it
--      If different behaviour is desired for unloading beside a port, check for that and change the
--      penalty applied within the function
--
--  .unloadCheckFunction = nil or function(unit) --> boolean
--      if function, the unit can only unload if the function returns true
--      (and all other conditions are met)
--      nil means no extra condition
--  
--  .unloadFailureMessage = nil or string or function(unit) --> string
--      Message to show if the unit can't unload.
--      The message for the ship is shown at the top of the message
--      box, and the message for the cargo is shown below that
--      if nil, a generic message is shown.
--      If string, the string is shown, with %STRING1 replaced by the unit
--      type name.
--      If function, the returned string is used for the message, with
--      %STRING1 replaced by the unit type name
--
--  .forbidBeachBoarding = nil or boolean
--      If true, a unit can't get onto a ship from the "beach",
--      unless that unit is adjacent to a city at peace or allied
--      with the unit's owner
--      false or nil means it can

--  .forbidPeacePortBoarding = nil or boolean
--      If true, a unit can't get onto a ship from a tile
--      adjacent to a city with which it is at peace with
--      (unless forbidBeachBoarding isn't active)
--      false or nil means the unit can load from a tile
--      adjacent to a city with which the owner is at peace
--
--  .forbidAlliedPortBoarding = nil or boolean
--      if true, a unit can't get onto a ship from a tile
--      adjacent to an ally's city (unless it is allowed to
--      board a ship from a beach or peace port)
--
--  .boardingCheckFunction = nil or function(boardingUnit,shipType) --> boolean
--      if nil, ignore this condition
--      if a function and it returns true, the unit can board (if other conditions
--      allow it).  If the function returns false, the unit can't board
--      The boardingUnit is the unit checking if it can board a ship, and
--      the ship type is the unit type that may be boarded
--
--  forbidBoarding = nil or table of unit types
--      units in this table (if it is supplied) can't board this transport
--      type, or this type of unit can't board the transport types listed
--      (depending on whether this setting is for a land unit or 
--      sea transport)
--      This is achieved by clearing the sleep status of any invalid cargo
--      when a ship is activated within a city (as well as forbidding the
--      other types of boarding)
--
--

local applyToAI = false -- if you want this stuff to apply to the AI, 

local shipCapacityList = {}
-- shipCapacityList[unitType.id] = nil or integer
-- supplies the default carrying capacity of each ship
-- if nil, the unit always has a capacity of 0


local navy = {}
gen.versionFunctions(navy,versionNumber,fileModified,"LuaCore".."\\".."navy.lua")

function navy.applySettingsToAI()
    applyToAI = true
end

function navy.registerShipCapacityList(sCList)
    if type(sCList) ~= "table" then
        error("navy.registerShipCapacityList: argument must be a table.  Received: "..tostring(sCList))
    end
    shipCapacityList = sCList
end

function navy.buildShipCapacityListFrom(rulesTable)
    local sCList = {}
    for unitID=0,civ.cosmic.numberOfUnitTypes-1 do
        local domain = tonumber(rulesTable["@UNITS"][unitID][2])
        if domain == 2 then
            local hold = tonumber(rulesTable["@UNITS"][unitID][10])
            if hold > 0 then
                sCList[unitID] = hold
            end
        end
    end
    return sCList
end

local beachShipSettings = {}

local forbidTransportTable = {}
-- forbidTransportTable[unitType1.id][unitType2.id] = nil or bool
-- if true, unitType1 can't transport or be transported by unitType2
for i=0,civ.cosmic.numberOfUnitTypes-1 do
    forbidTransportTable[i] = {}
end

local function validateBeachSettings(unitSettings,unitID)
    if type(unitID) ~= "number" then
        error("navy.validateBeachShipSettings: keys in the beachShipSettings table should be integers.  Received: "..tostring(unitID))
    end
    for key,value in pairs(unitSettings) do
        if key == "restrictBeachUnload" then
            if type(value) ~= "boolean" and type(value) ~= "number" and type(value) ~= "nil" then
            error("navy.validateBeachShipSettings: key "..key.." can only have boolean, number or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end
        elseif key == "restrictPeacePortUnload" then
            if type(value) ~= "boolean" and type(value) ~= "number" and type(value) ~= "nil" then
            error("navy.validateBeachShipSettings: key "..key.." can only have boolean, number or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end

        elseif key == "restrictAlliedPortUnload" then
            if type(value) ~= "boolean" and type(value) ~= "number" and type(value) ~= "nil" then
            error("navy.validateBeachShipSettings: key "..key.." can only have boolean, number or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end

        elseif key == "beachUnloadPenalty" then
            if type(value) ~= "function" and type(value) ~= "number" and type(value) ~= nil then
            error("navy.validateBeachShipSettings: key "..key.." can only have function(unit)-->void, number or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end
        elseif key == "unloadCheckFunction" then
            if type(value) ~= "function" and type(value) ~= nil then
            error("navy.validateBeachShipSettings: key "..key.." can only have function(unit)-->boolean, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end
        elseif key == "unloadFailureMessage" then
            if type(value) ~= "function" and type(value) ~= "string" and type(value) ~= nil then
            error("navy.validateBeachShipSettings: key "..key.." can only have function(unit)-->string, string or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end
        elseif key == "forbidBeachBoarding" then
            if type(value) ~= "boolean" and type(value) ~= "nil" then
            error("navy.validateBeachShipSettings: key "..key.." can only have boolean, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end

        elseif key == "forbidPeacePortBoarding" then
            if type(value) ~= "boolean" and type(value) ~= "nil" then
            error("navy.validateBeachShipSettings: key "..key.." can only have boolean, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end

        elseif key == "forbidAlliedPortBoarding" then
            if type(value) ~= "boolean" and type(value) ~= "nil" then
            error("navy.validateBeachShipSettings: key "..key.." can only have boolean, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end

        elseif key == "boardingCheckFunction" then
            if type(value) ~= "function" and type(value) ~= nil then
            error("navy.validateBeachShipSettings: key "..key.." can only have function(boardingUnit,shipType)-->boolean, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end
        elseif key == "forbidBoarding" then
            if type(value) ~= "table" and type(value) ~= nil then
            error("navy.validateBeachShipSettings: key "..key.." can only have table of unit types, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") gives this key a value of "..tostring(value))
            end
            for index, unitType in pairs(value) do
                if not civ.isUnitType(unitType) then
                    error("navy.validateBeachShipSettings: key "..key.." can only have table of unit types, or nil value.  However, the unit type with ID "..unitID.." ("..civ.getUnitType(unitID).name..") has a table where the key "..tostring(index).." has a value of "..tostring(unitType))
                end
            end
        else
            error("navy.validateBeachShipSettings: unit type with ID "..unitID.." ("
            ..civ.getUnitType(unitID).name..") has invalid key: "..key)
        end
    end
end


function navy.registerBeachShipSettings(settingsTable)
    if type(settingsTable) ~= "table" then
        error("navy.registerBeachShipSettings: argument must be a table.  Received: "..tostring(settingsTable))
    end
    for unitTypeID, unitSettings in pairs(settingsTable) do
        validateBeachSettings(unitSettings,unitTypeID)
        local forbidBoarding = unitSettings.forbidBoarding or {}
        for _,forbiddenUnitType in pairs(forbidBoarding) do
            forbidTransportTable[unitTypeID][forbiddenUnitType.id] = true
            forbidTransportTable[forbiddenUnitType.id][unitTypeID] = true
        end
    end
    beachShipSettings = settingsTable
end

local function resetShipHolds()
    for unitTypeID, capacity in pairs(shipCapacityList) do
        civ.getUnitType(unitTypeID).hold = capacity
    end
end

local canUnload = "state not linked"
-- canUnload[unit.id] = tileID or nil
-- a unit in this table can unload itself or carried units even
-- if it otherwise wouldn't be able to, as long
-- as it is still on the tile specified

-- if true, the unit can unload from the ship,
-- if string, unit can't unload, and that string
-- is the message
local function unitCanUnload(unit) --> true or string
    local adjacentPeaceCity = false
    local adjacentAlliedCity = false
    for _,tile in pairs(gen.getAdjacentTiles(unit.location)) do
        if tile.city and diplomacy.peaceTreatyExists(unit.owner,tile.city.owner) then
            adjacentPeaceCity = true
        end
        if tile.city and (diplomacy.allianceExists(unit.owner,tile.city.owner)
            or tile.city.owner == unit.owner) then
            adjacentPeaceCity = true
            adjacentAlliedCity = true
        end
    end
    local settings = beachShipSettings[unit.type.id] or {}
    local function getFailureMessage()
        local failureMessage = nil
        if type(settings.unloadFailureMessage) == "string" then
            failureMessage = settings.unloadFailureMessage
        elseif type(settings.unloadFailureMessage) == "function" then
            failureMessage = settings.unloadFailureMessage(unit)
        elseif unit.type.domain == 2 then
            failureMessage = "Our %STRING1 unit can't offload its cargo here."
        else 
            failureMessage = "Our %STRING1 unit can't unload here."
        end
        failureMessage = text.substitute(failureMessage,{unit.type.name})
        return failureMessage
    end
    if settings.unloadCheckFunction and not settings.unloadCheckFunction(unit) then
        return getFailureMessage()
    end
    if canUnload[unit.id] and gen.getTileId(unit.location) == canUnload[unit.id] then
        return true
    elseif (not settings.restrictBeachUnload) or (type(settings.restrictBeachUnload) == "number" and
        (unit.moveSpent <= settings.restrictBeachUnload*totpp.movementMultipliers.aggregate or
        unit.moveSpent <= -settings.restrictBeachUnload)) then
        return true
    elseif adjacentPeaceCity and (not settings.restrictPeacePortUnload or 
        (type(settings.restrictPeacePortUnload) == "number" and 
        (unit.moveSpent <= settings.restrictPeacePortUnload*totpp.movementMultipliers.aggregate or
        unit.moveSpent <= -settings.restrictPeacePortUnload))) then
        return true
    elseif adjacentAlliedCity and (not settings.restrictAlliedPortUnload or 
        (type(settings.restrictAlliedPortUnload) == "number" and 
        (unit.moveSpent <= settings.restrictAlliedPortUnload*totpp.movementMultipliers.aggregate or
        unit.moveSpent <= -settings.restrictAlliedPortUnload))) then
        return true
    end
    return getFailureMessage()
end

---@param unit unitObject
local function groundUnitActivatedAtSea(unit)
    if unit.owner.isHuman or applyToAI then
        local cargoUnloadResult = unitCanUnload(unit)
        local shipUnloadResult = unit.carriedBy and unitCanUnload(unit.carriedBy)
        --To prevent interference with the landAirCargo module
        --If the unit is carried by a land or air unit, this should
        --not apply, and the unit can always unload
        if unit.carriedBy and unit.carriedBy.type.domain ~= gen.c.domainSea then
            return
        end
        if cargoUnloadResult == true then
            canUnload[unit.id] = gen.getTileId(unit.location)
        end
        if shipUnloadResult == true then
            canUnload[unit.carriedBy.id] = gen.getTileId(unit.carriedBy.location)
        end
        if shipUnloadResult == nil then
            -- can always activate unit if it is not carriedBy anything
            return
        end
        if type(cargoUnloadResult) == "string" and type(shipUnloadResult) == "string" then
            local message = cargoUnloadResult.."\n^\n^"..shipUnloadResult
            text.simple(message,"Disembark")
            gen.setToSleeping(unit)
            gen.activate(unit.carriedBy)
            return
        elseif type(cargoUnloadResult) == "string" then
            local message = cargoUnloadResult
            text.simple(message,"Disembark")
            gen.setToSleeping(unit)
            gen.activate(unit.carriedBy)
            return
        elseif type(shipUnloadResult) == "string" then
            local message = shipUnloadResult
            text.simple(message,"Disembark")
            gen.setToSleeping(unit)
            gen.activate(unit.carriedBy)
            return
        else
            local cargoUnloadPenalty = (beachShipSettings[unit.type.id] or {}).beachUnloadPenalty
            local carryUnloadPenalty = ((unit.carriedBy and beachShipSettings[unit.carriedBy.type.id]) or {}).beachUnloadPenalty
            if type(cargoUnloadPenalty) == "function" then
                cargoUnloadPenalty(unit)
            elseif type(cargoUnloadPenalty) == "number" then
                if cargoUnloadPenalty >= 0 then
                    unit.moveSpent = math.max(unit.moveSpent, cargoUnloadPenalty*totpp.movementMultipliers.aggregate)
                else
                    unit.moveSpent = math.max(unit.moveSpent, -cargoUnloadPenalty)
                end
            end
            if type(carryUnloadPenalty) == "function" then
                carryUnloadPenalty(unit)
            elseif type(carryUnloadPenalty) == "number" then
                if carryUnloadPenalty >= 0 then
                    unit.carriedBy.moveSpent = math.max(unit.carriedBy.moveSpent, carryUnloadPenalty*totpp.movementMultipliers.aggregate)
                else
                    unit.carriedBy.moveSpent = math.max(unit.carriedBy.moveSpent, -carryUnloadPenalty)
                end
            end
            return
        end
    end
end

local function defaultBoardingCheck(boardingUnit,shipType)
    return true
end

local function groundUnitActivatedOnLand(unit)
    if unit.owner.isHuman or applyToAI then
        local adjacentPeaceCity = false
        local adjacentAlliedCity = false
        -- it appears that dead (or missing) units can be activated
        if unit.location.x > 65000 then
            return
        end
        for _,tile in pairs(gen.getAdjacentTiles(unit.location)) do
            if tile.city and diplomacy.peaceTreatyExists(unit.owner,tile.city.owner) then
                adjacentPeaceCity = true
            end
            if tile.city and (diplomacy.allianceExists(unit.owner,tile.city.owner)
                or tile.city.owner == unit.owner) then
                adjacentPeaceCity = true
                adjacentAlliedCity = true
            end
        end
        if unit.location.city then
            adjacentPeaceCity = true
            adjacentAlliedCity = true
        end
        local unitSettings = beachShipSettings[unit.type.id] or {}
        local unitBoardingCheckFn = unitSettings.boardingCheckFunction or defaultBoardingCheck
        for unitTypeId, holds in pairs(shipCapacityList) do
            local shipSettings = beachShipSettings[unitTypeId] or {}
            local shipBoardingCheckFn = shipSettings.boardingCheckFunction or defaultBoardingCheck
            local shipType = civ.getUnitType(unitTypeId) --[[@as unitTypeObject]]
            -- unit must pass one of the beach, peacePort or alliedPort checks and
            -- also both boarding check functions
            -- also can't be forbidden by the forbidTransportTable
            if ((not unitSettings.forbidBeachBoarding and not shipSettings.forbidBeachBoarding)
                or(adjacentPeaceCity and not unitSettings.forbidPeacePortBoarding and not shipSettings.forbidPeacePortBoarding)
                or(adjacentAlliedCity and not unitSettings.forbidAlliedPortBoarding and not shipSettings.forbidAlliedPortBoarding)
                )
                and unitBoardingCheckFn(unit,shipType) and shipBoardingCheckFn(unit,shipType)
                and not forbidTransportTable[unit.type.id][shipType.id]
                then
                shipType.hold = holds
            else
                shipType.hold = 0
            end
        end
    end
end


local function tileName(tile)
    if tile.city then
        return tile.city.name
    end
    return "("..text.coordinates(tile)..")"
end

local function moveOrDeleteForbiddenCargo(ship,cargo,previousTile)
    if previousTile.baseTerrain.type ~= 10 and (previousTile.defender == nil or previousTile.defender == cargo.owner) then
            cargo:teleport(previousTile)
            cargo.carriedBy = nil
            if cargo.owner.isHuman then
                text.simple("In this scenario, "..cargo.type.name.." units can't be transported by "..ship.type.name.." units.  Your "..cargo.type.name.." has been moved to "..tileName(previousTile)..".","Scenario Rules: Shipping")
            end
            return
    end
    if cargo.owner.isHuman then
        text.simple("In this scenario, "..cargo.type.name.." units can't be transported by "..ship.type.name.." units.  Since there is no friendly city in an adjacent square, your "..cargo.type.name.." unit has been deleted.","Scenario Rules: Shipping")
    end
    gen.deleteUnit(cargo)
end

function navy.beachSettingsUnitActivation(unit)
    if unit.type.domain ~= 0 then
        -- Ship holds don't need to be set to 0 when a sea or air unit is active
        resetShipHolds()
        local unitTypeID = unit.type.id
        if unit.type.domain == 2 and unit.type.hold > 0 and unit.location.baseTerrain.type ~= 10
            and (unit.owner.isHuman or applyToAI) then
            for unitOnLand in unit.location.units do
                if gen.isSleeping(unitOnLand) and forbidTransportTable[unitTypeID][unitOnLand.type.id] then
                    gen.setToNoOrders(unitOnLand)
                end
            end
        end
        -- moved to navy.onEnterTile
        --elseif unit.type.domain == 2 and unit.type.hold > 0 and (unit.owner.isHuman or applyToAI) then
        --    for unitOnTile in unit.location.units do
        --        if unitOnTile.carriedBy == unit and forbidTransportTable[unitTypeID][unitOnTile.type.id] then
        --            moveOrDeleteForbiddenCargo(unit,unitOnTile)
        --        end
        --    end
        --end
    elseif unit.location.baseTerrain.type == 10 then
        -- if the ground unit is activated at sea, ship holds should be normal
        resetShipHolds()
        groundUnitActivatedAtSea(unit)
    else
        -- the ground unit is activated on land, so consider ships individually
        groundUnitActivatedOnLand(unit)
    end
end


-- Carrier Units
-- If a unit is not within the carrierSettings table, it will either always
-- be a carrier, or never be a carrier
-- carrierSettings[unitType.id] = table with keys:
--  canNotUse = nil or table of unit types
--      units in this table can not land on the specified carrier
--      (if the unit is land/sea, this means the carrier does not have
--      carrier status when that unit is activated)
--  setPropertyFor = nil or table of tribes
--      the carrier property is always enabled for these tribes
--      (You can avoid air protected stacks for carriers by using
--      this and assigning a different carrier unit type to each tribe/alliance)
--  clearPropertyFor = nil or table of tribes
--      the carrier property is always disabled for these tribes
--      (not sure why you'd want this)
--  hold = integer or nil
--      The carrier can hold this many aircraft
--      nil means unlimited capacity
--

local carrierTable = {}
-- carrierTable[carrierTypeID] = table with keys
--      forbiddenUnits = {[unitTypeId] = bool or nil}
--          if true, the corresponding unit type can't use the carrier
--          (the carrier's carrier status will be removed)
--          if false or nil, the unit can use the carrier
--      enableTribes = {[tribeID] = bool or nil}
--          if true, the unit is always a carrier when this tribe is active
--          false or nil means follow forbiddenUnits
--      disableTribes = {[tribeID] = bool or nil}
--          if true, the unit is never a carrier when this tribe is active
--          false or nil means follow forbiddenUnits
--      hold = integer or math.huge
--          if integer, the carrier can hold this many aircraft
--          if nil, it can hold unlimited aircraft

function navy.registerCarrierSettings(cSettings)
    if type(cSettings) ~= "table" then
        error("navy.registerCarrierSettings: expected table as argument. Received: "..tostring(cSettings))
    end
    for unitTypeID, settings in pairs(cSettings) do
        if type(unitTypeID) ~= "number" then
            error("navy.registerCarrierSettings: table must have integers as keys.  Received: "..tostring(unitTypeID))
        end
        local canNotUse = settings.canNotUse or {}
        local setPropertyFor = settings.setPropertyFor or {}
        local clearPropertyFor = settings.clearPropertyFor or {}
        carrierTable[unitTypeID] = {forbiddenUnits = {}, enableTribes = {}, disableTribes = {}}
        for _,aircraftType in pairs(canNotUse) do
            carrierTable[unitTypeID].forbiddenUnits[aircraftType.id] = true
        end
        for _,tribe in pairs(setPropertyFor) do
            if gen.inTable(tribe,clearPropertyFor) then
                error("navy.registerCarrierSettings: "..civ.getUnitType(unitTypeID).name.." has tribe "..tribe.name.." in both the setPropertyFor and clearPropertyFor tables.")
            end
            carrierTable[unitTypeID].enableTribes[tribe.id] = true
        end
        for _,tribe in pairs(clearPropertyFor) do
            carrierTable[unitTypeID].disableTribes[tribe.id] = true
        end
        carrierTable[unitTypeID].hold = settings.hold or math.huge
    end
end

function navy.unitActivationSetCarrierStatus(unit,source,repeatedMove)
    local activeTribeID = unit.owner.id
    for unitTypeID, settings in pairs(carrierTable) do
        if settings.enableTribes[activeTribeID] then
            gen.giveCarryAir(civ.getUnitType(unitTypeID))
        elseif settings.disableTribes[activeTribeID] then
            gen.removeCarryAir(civ.getUnitType(unitTypeID))
        elseif settings.forbiddenUnits[unit.type.id] then
            gen.removeCarryAir(civ.getUnitType(unitTypeID))
        else
            gen.giveCarryAir(civ.getUnitType(unitTypeID))
        end
    end
end

function navy.onEnterTile(unit,previousTile,previousDomainSpec)
    local unitTypeID = unit.type.id
    if not (unit.owner.isHuman or applyToAI) then
        return
    end
    if unit.type.domain == 2 and unit.type.hold > 0 and not unit.location.city then
        for unitOnTile in unit.location.units do
            if unitOnTile.carriedBy == unit and forbidTransportTable[unitTypeID][unitOnTile.type.id] then
                moveOrDeleteForbiddenCargo(unit,unitOnTile,previousTile)
            end
        end
    end
    -- prevent aircraft carrier from departing with non-sleeping aircraft
    if carrierTable[unit.type.id] and previousTile.city then
        local carrying = 0
        local capacity = carrierTable[unit.type.id].hold
        for unitOnTile in unit.location.units do
            if unit ~= unitOnTile and unitOnTile.type.domain == 1 and 
                not (unitOnTile.carriedBy and unitOnTile.carriedBy ~= unit) then
                -- check if the unit can't be carried by the carrier, or if it is not sleeping
                if carrierTable[unit.type.id].forbiddenUnits[unitOnTile.type.id] or
                    (not gen.isSleeping(unitOnTile)) or (carrying >= capacity)  then
                    -- if so, teleport back into the city
                    unitOnTile:teleport(previousTile)
                else
                    -- otherwise, make it carriedBy the carrier
                    unitOnTile.carriedBy = unit
                    carrying = carrying + 1
                end
            end
        end
    end
    -- if carrier picks up unit from a different carrier, this moves it back
    if carrierTable[unit.type.id] then
        for unitOnTile in unit.location.units do
            if (unitOnTile.carriedBy and unitOnTile.carriedBy.location == previousTile)
                or (carrierTable[unit.type.id].forbiddenUnits[unitOnTile.type.id] and not unit.location.city) then
                unitOnTile:teleport(previousTile)
            end
        end
    end
    -- 
    if unit.type.domain == 1 and unit.moveSpent == unit.type.move then
        local carrierLandingAttempt = false
        local carriers = {}
        for unitOnTile in unit.location.units do
            if unitOnTile.type.domain == 1 and unitOnTile ~= unit and unitOnTile.carriedBy then
                carriers[unitOnTile.carriedBy.id] = 1 + (carriers[unitOnTile.carriedBy.id] or 0)
            end
        end
        for possibleCarrier in unit.location.units do
            if carrierTable[possibleCarrier.type.id] and 
                not carrierTable[possibleCarrier.type.id].forbiddenUnits[unit.type.id] then
                carrierLandingAttempt = true
                if (carriers[possibleCarrier.id] or 0) < carrierTable[possibleCarrier.type.id].hold then
                    unit.carriedBy = possibleCarrier
                    break
                end
            end
        end
        if carrierLandingAttempt and not unit.carriedBy then
            unit.domainSpec = previousDomainSpec+1
            if unit.owner.isHuman and unit.domainSpec < unit.type.range then
                text.simple("No ship has room for our "..unit.type.name.." unit, so it remains aloft.","Defense Minister")
            elseif unit.owner.isHuman then
                text.simple("No ship has room for our "..unit.type.name.." unit, so it has run out of fuel and crashed.","Defense Minister")
                gen.killUnit(unit)
            end
        end
    end
end
function navy.linkState(canUnloadTableFromState)
    if type(canUnloadTableFromState) == "table" then
        canUnload = canUnloadTableFromState
    else
        error("navy.linkState: table expected as argument.  Received: "..tostring(canUnloadTableFromState))
    end
end

-- clear the canUnload table each turn
function navy.onTurnMaintenance(turn)
---@diagnostic disable-next-line: param-type-mismatch
    for key,value in pairs(canUnload) do
        canUnload[key] = nil
    end
end


discreteEvents.linkStateToModules( function(state,stateTableKeys)
    local keyName = "navyModuleState"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    -- link the state table to the module
    state[keyName] = state[keyName] or {}
    navy.linkState(state[keyName])
end)

function discreteEvents.onActivateUnit(unit,source,repeatMove)
    navy.unitActivationSetCarrierStatus(unit,source,repeatMove)
    navy.beachSettingsUnitActivation(unit)
end

function discreteEvents.onEnterTilePriority(unit,previousTile,previousDomainSpec)
    navy.onEnterTile(unit,previousTile,previousDomainSpec)
end

function discreteEvents.onTurn(turn)
    navy.onTurnMaintenance(turn)
end

return navy

