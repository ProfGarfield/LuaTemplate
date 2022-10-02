--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- Log and Report important events
-- This module provides functionality for logging important
-- events in a game, and printing out a log as a text file on
-- demand.  It also provides a means to view these logs in game
-- and go to each combat location for a report
--
-- linkage and information
--
-- log.linkState(tableInStateTable)
-- log.setGeographyTable(table)
-- log.setUnitTypeShortNameTable(table)
-- log.setTribeShortNameTable(table)
--
-- event types that can be logged and reported
-- 
-- log.onUnitKilled(winner,loser)
-- log.onNegotiation(talker,listener)
-- log.onSchism(tribe)
-- log.onCityTaken(city,defender)
-- log.onCityProduction(city,prod)
-- log.onCentauriArrival(tribe)
-- log.onCityDestroyed(city)
-- log.onBribeUnit(unit,previousOwner)
-- log.onGameEnds(reason)
-- log.onKeyPress(keyCode)
-- log.onActivateUnit(unit,source)
-- log.onCityFounded(city)
-- log.configure.unitProduction(unitType,maxReports)
-- log.configure.improvementProduction(improvement,maxReports)


local text = require("text")

local gen = require("generalLibrary"):minVersion(1)
local log = {}
gen.versionFunctions(log,versionNumber,fileModified,"LuaCore".."\\".."log.lua")

local geographyTable = {}
-- the short name tables (indexed by ID numbers)
-- provide alternate names for units to better
-- fit reports
local unitTypeShortNameTable = {}
local tribeShortNameTable = {}
local attackMadeSinceInfoLastGathered = false

local function setGeographyTable(table)
    if type(table) ~= "table" then
        error("setGeographyTable takes a table as an argument")
    end
    geographyTable = table
    return
end
log.setGeographyTable = setGeographyTable

local function setUnitTypeShortNameTable(table)
    if type(table) ~= "table" then
        error("setUnitTypeShortNameTable takes a table as an argument")
    end
    unitTypeShortNameTable = table
    return
end
log.setUnitTypeShortNameTable = setUnitTypeShortNameTable

local function setTribeShortNameTable(table)
    if type(table) ~= "table" then
        error("setTribeShortNameTable takes a table as an argument")
    end
    tribeShortNameTable = table
    return
end
log.setTribeShortNameTable = setTribeShortNameTable
local logState = "logState not linked"
local combatLog = "logState not linked"
local citiesCapturedAndDestroyedLog = "logState not linked"
local eventLog = "logState not linked"
local eventCounter = "logState not linked"
local casualtyCounter = "logState not linked"
local hideUnitInCasualtyReport = "logState not linked"
local markerRemovalInfoTable = "logState not linked"


local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        logState = tableInStateTable
        logState.combatLog = logState.combatLog or {}
        combatLog = logState.combatLog
        logState.citiesCatpuredAndDestroyedLog = logState.citiesCatpuredAndDestroyedLog or {}
        citiesCapturedAndDestroyedLog = logState.citiesCatpuredAndDestroyedLog
        logState.eventLog = logState.eventLog or {}
        eventLog = logState.eventLog
        logState.eventCounter = logState.eventCounter or {}
        eventCounter = logState.eventCounter
        for i=0,7 do
            eventCounter[i] = eventCounter[i] or {}
        end
        logState.casualtyCounter = logState.casualtyCounter or {}
        casualtyCounter = logState.casualtyCounter
        logState.hideUnitInCasualtyReport = logState.hideUnitInCasualtyReport or {}
        hideUnitInCasualtyReport = logState.hideUnitInCasualtyReport
        for i=0,7 do
            casualtyCounter[i] = casualtyCounter[i] or {}
            hideUnitInCasualtyReport[i] = hideUnitInCasualtyReport[i] or {}
        end
        logState.markerRemovalInfoTable = logState.markerRemovalInfoTable or {}
        markerRemovalInfoTable = logState.markerRemovalInfoTable
    else
        error("linkState: linkState takes a table as an argument.")
    end
end

log.linkState = linkState



local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "logState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkState(state[keyName])
    end
end




local markerTypeString = nil
local markerSafeTile = nil
local markerSpotterUnit = nil
local allowedStrings = {["pollution"]=true, ["railroad"]=true, ["fortress"]=true, ["farmland"]=true,}

-- markerType is one of these four strings
-- "pollution" "railroad" "fortress" "farmland"
-- safe tile is the center of 9 tiles where units can be safely teleported while vision of the radar marker is being given to the radar user.
local function setCombatMarkerParameters(typeString,safeTile,spotterUnit)
    if allowedStrings[typeString] then
        markerTypeString = typeString
    else
        error([[setCombatMarkerParameters: typeString must be one of "pollution", "railroad", "fortress", "farmland"]])
    end
    if civ.isTile(safeTile) then
        markerSafeTile = safeTile
    else
        error([[setCombatMarkerParameters: safeTile must be a tile.]])
    end
    if civ.isUnitType(spotterUnit) then
        markerSpotterUnit = spotterUnit
    else
        error([[setCombatMarkerParameters: spotterUnit must be a unitType.]])
    end
end
log.setCombatMarkerParameters = setCombatMarkerParameters

    
    

local function getTileId (tile)
	if tile == nil then
		print("ERROR: \"getTileId\" function called with an invalid tile (input parameter is nil)")
		return nil
	end
	local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
	local mapOffset = tile.z * mapWidth * mapHeight
	local tileOffset = tile.x + (tile.y * mapWidth)
	return mapOffset + tileOffset
end


-- combatRecord Specification
-- table with following values
--  .turn = integer
--      the turn number that the combat took place in
--  .aggressorTribeID = integer
--      the ID of the tribe that made the attack
--  .aggressorUnitTypeID = integer
--      the ID of the unit type that made the attack
--  .aggressorWin = bool
--      true if the aggressor won the battle
--  .victimTribeID = integer
--      the ID of the tribe that was attacked
--  .victimUnitTypeID = integer
--      the ID of the unit type that was attacked
--  .victimWin = bool
--      true if the victim won the battle
--  .victimLocation = {integer,integer,integer}
--          table of the coordinates of the victim
--

local function onUnitKilled(winner,loser)
    attackMadeSinceInfoLastGathered =true
    casualtyCounter[loser.owner.id][loser.type.id] = 1 + (casualtyCounter[loser.owner.id][loser.type.id] or 0)
    local newCombatRecord = {turn=civ.getTurn()}
    local aggressor = nil
    local victim = nil
    if winner.owner == civ.getCurrentTribe() then
        aggressor = winner
        victim = loser
        newCombatRecord.aggressorWin = true
        newCombatRecord.victimWin = false
    else
        aggressor = loser
        victim = winner
        newCombatRecord.aggressorWin = false
        newCombatRecord.victimWin = true
    end
    newCombatRecord.aggressorTribeID = aggressor.owner.id
    newCombatRecord.aggressorUnitTypeID = aggressor.type.id
    newCombatRecord.victimTribeID = victim.owner.id
    newCombatRecord.victimUnitTypeID = victim.type.id
    newCombatRecord.victimLocation = {victim.location.x,victim.location.y,victim.location.z}
    combatLog[#combatLog+1] = newCombatRecord
end
log.onUnitKilled=onUnitKilled

-- combat log for when both sides survive
local function onCombatNoKill(attacker,defender)
    attackMadeSinceInfoLastGathered =true
    --casualtyCounter[loser.owner.id][loser.type.id] = 1 + (casualtyCounter[loser.owner.id][loser.type.id] or 0)
    local newCombatRecord = {turn=civ.getTurn()}
    local aggressor = attacker
    local victim = defender
    newCombatRecord.aggressorWin = true -- set to true, since both survived
    newCombatRecord.victimWin = true -- set to true, since both survived
    newCombatRecord.aggressorTribeID = aggressor.owner.id
    newCombatRecord.aggressorUnitTypeID = aggressor.type.id
    newCombatRecord.victimTribeID = victim.owner.id
    newCombatRecord.victimUnitTypeID = victim.type.id
    newCombatRecord.victimLocation = {victim.location.x,victim.location.y,victim.location.z}
    combatLog[#combatLog+1] = newCombatRecord
end
log.onCombatNoKill=onCombatNoKill
-- cityCapturedRecord
--  .capturingTribeID = integer
--  .losingTribeID = integer
--  .turn = integer
--  .wasDestroyed = bool
--  .cityName = string
--  .cityLocation = {integer,integer,integer}

local function onCityTaken(city,defender)
    local cityCapturedRecord = {}
    cityCapturedRecord.capturingTribeID = civ.getCurrentTribe().id
    cityCapturedRecord.losingTribeID = defender.id
    cityCapturedRecord.turn = civ.getTurn()
    cityCapturedRecord.wasDestroyed = false
    cityCapturedRecord.cityName = city.name
    cityCapturedRecord.cityLocation = {city.location.x,city.location.y,city.location.z}
    citiesCapturedAndDestroyedLog[#citiesCapturedAndDestroyedLog+1] = cityCapturedRecord
end
log.onCityTaken = onCityTaken

local function onCityDestroyed(city)
    local cityCapturedRecord = {}
    cityCapturedRecord.capturingTribeID = civ.getCurrentTribe().id
    cityCapturedRecord.losingTribeID = city.owner.id
    cityCapturedRecord.turn = civ.getTurn()
    cityCapturedRecord.wasDestroyed = true
    cityCapturedRecord.cityName = city.name
    cityCapturedRecord.cityLocation = {city.location.x,city.location.y,city.location.z}
    citiesCapturedAndDestroyedLog[#citiesCapturedAndDestroyedLog+1] = cityCapturedRecord
end
log.onCityDestroyed = onCityDestroyed

-- purges any casualty information that is more than a turn old
-- for the selected tribe
local function purgeCasualtyInfo(tribe)
    local tribeID = tribe.id
    local turn = civ.getTurn()
    local function combatRecordOld(combatRecord)
        return combatRecord.victimTribeID == tribeID and
                    (((turn - combatRecord.turn) > 1) or 
                    (((turn-combatRecord.turn) == 1) and combatRecord.aggressorTribeID <= tribeID))
    end
    if type(combatLog) ~= "table" then
        error("purgeCasualtyInfo: log.linkState does not appear to have been called.")
    else
        for index,combatRecord in pairs(combatLog) do
            if combatRecordOld(combatRecord) then
                combatLog[index] = nil
            end
        end
    end
end
log.purgeCasualtyInfo = purgeCasualtyInfo

-- gatherVictimCombatInfo(tribe)--> tableOfCombatInfo
-- purges old combat information from the combat log, then
-- gathers all combat information from the last turn for
-- which tribe was attacked
local function gatherVictimCombatInfo(tribe)
    purgeCasualtyInfo(tribe)
    local tribeID = tribe.id
    local tribeCombatTable = {}
    local tribeCTIndex = 1
    for index,combatRecord in pairs(combatLog) do
        if combatRecord.victimTribeID == tribeID then
            tribeCombatTable[tribeCTIndex] = combatRecord
            tribeCTIndex=tribeCTIndex+1
        end
    end
    return tribeCombatTable
end


-- gatherAggressorCombatInfo(tribe)--> tableOfCombatInfo
-- purges old combat information from the combat log, then
-- gathers all combat information from the last turn for
-- which tribe was the attacker
local function gatherAggressorCombatInfo(tribe)
    purgeCasualtyInfo(tribe)
    local tribeID = tribe.id
    local tribeCombatTable = {}
    local tribeCTIndex = 1
    local turn = civ.getTurn()
    for index,combatRecord in pairs(combatLog) do
        if combatRecord.aggressorTribeID == tribeID and combatRecord.turn == turn then
            tribeCombatTable[tribeCTIndex] = combatRecord
            tribeCTIndex=tribeCTIndex+1
        end
    end
    return tribeCombatTable
end

local function makeCombatSummary(tableOfCombatInfo)
    local unitTypeLosses = {}
    local unitTypeSurvival = {}
    -- unitTypeSurvival[a][b] = number of survivors of unitTypeID a for tribeID b
    for index,combatRecord in pairs(tableOfCombatInfo) do
        if combatRecord.aggressorWin then
            unitTypeSurvival[combatRecord.aggressorUnitTypeID] = unitTypeSurvival[combatRecord.aggressorUnitTypeID] or {}
            unitTypeSurvival[combatRecord.aggressorUnitTypeID][combatRecord.aggressorTribeID] =
            (unitTypeSurvival[combatRecord.aggressorUnitTypeID][combatRecord.aggressorTribeID] or 0) +1
        else
            unitTypeLosses[combatRecord.aggressorUnitTypeID] = unitTypeLosses[combatRecord.aggressorUnitTypeID] or {}
            unitTypeLosses[combatRecord.aggressorUnitTypeID][combatRecord.aggressorTribeID] =
            (unitTypeLosses[combatRecord.aggressorUnitTypeID][combatRecord.aggressorTribeID] or 0) +1
        end
        if combatRecord.victimWin then
            unitTypeSurvival[combatRecord.victimUnitTypeID] = unitTypeSurvival[combatRecord.victimUnitTypeID] or {}
            unitTypeSurvival[combatRecord.victimUnitTypeID][combatRecord.victimTribeID] = 
            (unitTypeSurvival[combatRecord.victimUnitTypeID][combatRecord.victimTribeID] or 0) +1
        else
            unitTypeLosses[combatRecord.victimUnitTypeID] = unitTypeLosses[combatRecord.victimUnitTypeID] or {}
            unitTypeLosses[combatRecord.victimUnitTypeID][combatRecord.victimTribeID] = 
            (unitTypeLosses[combatRecord.victimUnitTypeID][combatRecord.victimTribeID] or 0) +1
        end
    end
    return unitTypeLosses, unitTypeSurvival
end

local function makeWinLossTable(unitTypeLosses,unitTypeSurvival)
    -- if ith tribe has units involved in combat, then tribeNeedsColumn[i]=true
    local tribeNeedsColumn = {}
    local dataTable = {[1]={["unitType"]="Unit Type"},[2]={["unitType"]="Dead-Engagements"},
            [3]={["unitType"]="All Units"}}
    local dataTableIndex = 4
    local totalSurvived = {[0]=0,0,0,0,0,0,0,0,}
    local totalDead = {[0]=0,0,0,0,0,0,0,0,}
    local unitTypeID = 0
    for unitTypeID=0,127 do
        if (not hideUnitInCasualtyReport[civ.getCurrentTribe().id][unitTypeID]) and (
            unitTypeLosses[unitTypeID] or unitTypeSurvival[unitTypeID]) then
            unitTypeLosses[unitTypeID] = unitTypeLosses[unitTypeID] or {}
            unitTypeSurvival[unitTypeID] = unitTypeSurvival[unitTypeID] or {}

            local unitFullName = civ.getUnitType(unitTypeID).name
            dataTable[dataTableIndex] = dataTable[dataTableIndex] or {}
            dataTable[dataTableIndex]["unitType"] = unitTypeShortNameTable[unitTypeID] or unitFullName
            for i=0,7 do
                local die = unitTypeLosses[unitTypeID][i] or 0
                local live = unitTypeSurvival[unitTypeID][i] or 0
                tribeNeedsColumn[i] = tribeNeedsColumn[i] or die>0 or live>0
                dataTable[dataTableIndex]["tribe"..tostring(i)]=tostring(die).."-"..tostring(live+die)
                totalSurvived[i]=totalSurvived[i]+live
                totalDead[i]=totalDead[i]+die
            end
            dataTableIndex=dataTableIndex+1
        end
    end
    for i=0,7 do
        dataTable[1]["tribe"..tostring(i)] = tribeShortNameTable[i] or civ.getTribe(i).name
        dataTable[2]["tribe"..tostring(i)] = "D-E"
        dataTable[3]["tribe"..tostring(i)] = tostring(totalDead[i]).."-"..tostring(totalSurvived[i]+totalDead[i])
    end
    local columnTable = {
        {column="unitType",allign = "center"},
    }
    for i=0,7 do
        if tribeNeedsColumn[i] then
            columnTable[#columnTable+1] = {column="tribe"..tostring(i),allign="center"}
        end
    end
    return dataTable,columnTable,totalDead,totalSurvived
end


local function countDeadAndSurvived(combatInfo,useAggressorPOV)
    local survivedCount = 0
    local deadCount = 0
    for __,combatRecord in pairs(combatInfo) do
        if useAggressorPOV then
            if combatRecord.aggressorWin then
                survivedCount = survivedCount+1
            else
                deadCount = deadCount+1
            end
        else
            if combatRecord.victimWin then
                survivedCount = survivedCount+1
            else
                deadCount = deadCount+1
            end
        end
    end
    return deadCount,survivedCount
end

local function countDeadAndSurvivedByRegion(regionInOrganizedCombatInfo,useAggressorPOV)
    local deadCount = 0
    local survivedCount = 0
    for tileID,combatRecordInTile in pairs(regionInOrganizedCombatInfo) do
        local deadInTile,survivedInTile = countDeadAndSurvived(combatRecordInTile,useAggressorPOV)
        deadCount = deadCount+deadInTile
        survivedCount=survivedCount+survivedInTile
    end
    return deadCount,survivedCount
end


-- Every battle is assigned a region for organizational purposes.
-- The region is determined by means of a "Geography Table"
--
-- A geographyTable is a table indexed by strings, with the 
-- following possible values
-- geographyTable["My Region Name"] = function(tile)-->boolean
--      The tile is considered in My Region Name if the function
--      returns true, and not in the region if the function returns false
-- geographyTable["My First Landmark Name"] = tile object
-- geographyTable["My Second Landmark Name"] = {integer,integer,integer}
-- geographyTable["My Third Landmark Name"] = {integer,integer,table of integers}
-- geographyTable["My Fourth Landmark Name"] = {integer,integer}
--      If the tile is not in any region, then it is placed in a 'region' "near"
--      a landmark.  A landmark described as a tile or as an integer triple
--      is only a landmark on a single map
--      A landmark described by a pair of integers is good for all maps
--      A landmark of the form {integer,integer,table of integers} is a
--      landmark for all the map numbers in table of integers




-- log.combatReportFunction() is how this function is accessed in events.lua
-- CRFArgValues gives the values needed to make the function work correctly
local CRFArgValues = {}
local landmarkRegionPrefix = "Near "-- "Near "
local function resetCRFArgValues()
    CRFArgValues.applicableTribe = civ.getCurrentTribe()
    CRFArgValues.pageType = "Open Report"
    CRFArgValues.victimReport = false
    CRFArgValues.aggressorReport = false
    CRFArgValues.currentRegion = nil
    CRFArgValues.currentTileOrderNumber = nil
end

local function bestRegion(tile,geoTable)
    geoTable = geoTable or geographyTable
    
    if type(tile)=="table" then
        tile = civ.getTile(tile[1],tile[2],tile[3])
    end
    local bestLandmark = "Map "..tostring(tile.z)
    local bestDistanceSoFar = 10000
    local function betterDistance(landmarkValue)
        local tileZ = tile.z
        local landmarkZ = landmarkValue.z or landmarkValue[3]
        if type(landmarkZ)=="table" then
            if landmarkZ[1] == tileZ or landmarkZ[2] == tileZ or
                landmarkZ[3] == tileZ or landmarkZ[4] == tileZ then
                landmarkZ = tileZ
            end
        end
        if landmarkZ ~= tileZ then
            return false
        end
        local tileX = tile.x
        local tileY = tile.y
        local landmarkX = landmarkValue.x or landmarkValue[1]
        local landmarkY = landmarkValue.y or landmarkValue[2]
        local dist = math.abs(tileX-landmarkX)+math.abs(tileY-landmarkY)
        if dist < bestDistanceSoFar then
            bestDistanceSoFar = dist
            return true
        end
    end
    for regionName,value in pairs(geoTable) do
        if type(value) == "function" and value(tile) then
            return regionName
        elseif type(value) ~= "function" and betterDistance(value) then
            bestLandmark = regionName
        end
    end
    for city in civ.iterateCities() do
        if betterDistance(city.location) then
            bestLandmark = city.name.." ("..tostring(city.id)..")"
        end
    end
    return landmarkRegionPrefix..bestLandmark
end


local function sortCombatInfoByTile(combatInfo)
    local sortedCombatInfo = {}
    for __,combatRecord in pairs(combatInfo) do
        local tileCoord = combatRecord.victimLocation
        local tileID = getTileId(civ.getTile(tileCoord[1],tileCoord[2],tileCoord[3]))
        sortedCombatInfo[tileID] = sortedCombatInfo[tileID] or {}
        local tileCombatInfo = sortedCombatInfo[tileID]
        tileCombatInfo[#tileCombatInfo+1]=combatRecord
    end
    return sortedCombatInfo
end


local function sortCombatInfoByRegion(combatInfo,geoTable)
    geoTable = geoTable or geographyTable
    local sortedCombatInfo = {}
    for __,combatRecord in pairs(combatInfo) do
        local region = bestRegion(combatRecord.victimLocation,geoTable)
        sortedCombatInfo[region] = sortedCombatInfo[region] or {}
        local regionCombatInfo = sortedCombatInfo[region]
        regionCombatInfo[#regionCombatInfo+1]= combatRecord
    end
    return sortedCombatInfo
end

local function sortCombatInfoByRegionAndTile(combatInfo,geoTable)
    geoTable= geoTable or geographyTable
    local sortedCombatInfo = sortCombatInfoByRegion(combatInfo,geoTable)
    for region,combatInfoTable in pairs(sortedCombatInfo) do
        sortedCombatInfo[region] = sortCombatInfoByTile(combatInfoTable,geoTable)
    end
    return sortedCombatInfo
end

local organizedCombatInfoDefense= {}
-- regionOrderTableDefense is the order in which regions will be displayed
-- to the user
local regionOrderTableDefense= {}
-- tileOrderTableDefense[n] is the n'th tile to be shown
-- if the player is going from tile to tile
-- format is {[1]=regionKey,[2]=tileID,regionKey=regionKey,tileID=tileID}
local tileOrderTableDefense = {}
local function getOrganizedCombatInfoForLastTurn()
    organizedCombatInfoDefense=sortCombatInfoByRegionAndTile(gatherVictimCombatInfo(civ.getCurrentTribe()))
    regionOrderTableDefense = {}
    tileOrderTableDefense={}
    local tileOrderIndex = 1
    local regionAlreadyProcessed = {}
    local function smallestKey(table)
        local bestSoFar = math.huge
        for key,val in pairs(table) do
            if key<bestSoFar then
                bestSoFar = key
            end
        end
        return bestSoFar
    end
    local function remainingRegionWithSmallestKey(table)
        local bestRegionSoFar = nil
        local bestKeySoFar = math.huge
        for regionName,tableWithKeys in pairs(table) do
            if not(regionAlreadyProcessed[regionName]) then
                local smalKey = smallestKey(tableWithKeys)
                if smalKey<bestKeySoFar then
                    bestKeySoFar = smalKey
                    bestRegionSoFar=regionName
                end
            end
        end
        if bestRegionSoFar then
            regionAlreadyProcessed[bestRegionSoFar] = true
        end
        return bestRegionSoFar
    end
    local nextRegionToInput = remainingRegionWithSmallestKey(organizedCombatInfoDefense)
    while nextRegionToInput do
        regionOrderTableDefense[#regionOrderTableDefense+1]=nextRegionToInput
        for key,value in pairs(organizedCombatInfoDefense[nextRegionToInput]) do
            tileOrderTableDefense[tileOrderIndex] = {[1]=nextRegionToInput,[2]=key,regionKey=nextRegionToInput,tileID=key}
            tileOrderIndex=tileOrderIndex+1
        end
        nextRegionToInput = remainingRegionWithSmallestKey(organizedCombatInfoDefense)
    end
end


local organizedCombatInfoAttack= {}
-- regionOrderTableAttack is the order in which regions will be displayed
-- to the user
local regionOrderTableAttack= {}
-- tileOrderTableAttack[n] is the n'th tile to be shown
-- if the player is going from tile to tile
-- format is {[1]=regionKey,[2]=tileID,regionKey=regionKey,tileID=tileID}
local tileOrderTableAttack = {}
local function getOrganizedAttackInfo()
    attackMadeSinceInfoLastGathered=false
    organizedCombatInfoAttack=sortCombatInfoByRegionAndTile(gatherAggressorCombatInfo(civ.getCurrentTribe()))
    regionOrderTableAttack = {}
    tileOrderTableAttack={}
    local tileOrderIndex = 1
    local regionAlreadyProcessed = {}
    local function smallestKey(table)
        local bestSoFar = math.huge
        for key,val in pairs(table) do
            if key<bestSoFar then
                bestSoFar = key
            end
        end
        return bestSoFar
    end
    local function remainingRegionWithSmallestKey(table)
        local bestRegionSoFar = nil
        local bestKeySoFar = math.huge
        for regionName,tableWithKeys in pairs(table) do
            if not(regionAlreadyProcessed[regionName]) then
                local smalKey = smallestKey(tableWithKeys)
                if smalKey<bestKeySoFar then
                    bestKeySoFar = smalKey
                    bestRegionSoFar=regionName
                end
            end
        end
        if bestRegionSoFar then
            regionAlreadyProcessed[bestRegionSoFar] = true
        end
        return bestRegionSoFar
    end
    local nextRegionToInput = remainingRegionWithSmallestKey(organizedCombatInfoAttack)
    while nextRegionToInput do
        regionOrderTableAttack[#regionOrderTableAttack+1]=nextRegionToInput
        for key,value in pairs(organizedCombatInfoAttack[nextRegionToInput]) do
            tileOrderTableAttack[tileOrderIndex] = {[1]=nextRegionToInput,[2]=key,regionKey=nextRegionToInput,tileID=key}
            tileOrderIndex=tileOrderIndex+1
        end
        nextRegionToInput = remainingRegionWithSmallestKey(organizedCombatInfoAttack)
    end
end
local combatReportFunction = nil

local automaticallyShowMap = false
local justAutomaticallyClosed = false

local function setHiddenUnitTypes()
    local checkboxNameTable = {}
    for i=0,127 do
        if civ.getUnitType(i) then
            checkboxNameTable[i] = civ.getUnitType(i).name
        end
    end
    local checkboxStatusTable = hideUnitInCasualtyReport[civ.getCurrentTribe().id]
    local menuText = "Select all units that should NOT appear in the combat report."
    local menuTitle = "Customize Combat Report"
    text.checkboxMenu(checkboxNameTable,checkboxStatusTable,menuText,menuTitle)
end

-- copied from radar module to be used to mark combat locations

-- Returns the tile associated with a unique identifier integer
-- (undoes Knighttime's getTileID)
-- Return nil if no tile corresponds to the ID
local function getTileFromId(ID)
    local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
    local baseMapOffset = mapWidth*mapHeight
    local z = math.floor(ID/baseMapOffset)
    if z < 0 or z >3 then
        print("getTileFromID: did not receive a valid ID")
        return nil
    end
    local tileOffset = ID % baseMapOffset
    local y = math.floor(tileOffset/mapWidth)
    local x = tileOffset % mapWidth
    return civ.getTile(x,y,z)
end

-- adds tile (x,y,z) to tileTable if that tile exists
-- if allMaps is true, adds tile (x,y) for maps 0-3 if they exist
local function addTileToTable(x,y,z,tileTable,allMaps)
    if allMaps then
        for i=0,3 do
            if civ.getTile(x,y,i) then
                table.insert(tileTable,civ.getTile(x,y,i))
            end
        end
    else
        if civ.getTile(x,y,z) then
            table.insert(tileTable,civ.getTile(x,y,z))
        end
    end
end

--tileRing(tile,int,table,bool)
-- Center tile is the tile at the center of the ring
-- dist means the distance (in unit movement points) from the center tile
-- tileTable is the table to add the tiles to
-- useAllMaps is true if you want to get the tile from all maps in the game,
-- false means only the map corresponding to centerTile
local function tileRing(centerTile,dist,tileTable,useAllMaps)
    local twodist = 2*dist
    local x = centerTile.x
    local y = centerTile.y
    local z = centerTile.z
    -- start at 1 instead of 0 since i=0 yields the last tile in 
    -- the previous loop (or, the 4 loop in the case of the first)
    for i=1,twodist do
        addTileToTable(x+i,y+twodist-i,z,tileTable,useAllMaps)
    end
    for i=1,twodist do
        addTileToTable(x+twodist-i,y-i,z,tileTable,useAllMaps)
    end
    for i=1,twodist do
        addTileToTable(x-i,y-twodist+i,z,tileTable,useAllMaps)
    end
    for i=1,twodist do
        addTileToTable(x-twodist+i,y+i,z,tileTable,useAllMaps)
    end
    if dist == 0 then
        -- above code fails to capture center tile if dist is 0
        addTileToTable(x,y,z,tileTable,useAllMaps)
    end
end

-- puts all tiles within dist of centerTile into tileTable (tileTable indexed by integers)
-- allMaps is a bool that when true gets tiles from every map, not just the one where centerTile is
local function diamond(centerTile,dist,tileTable,allMaps)
    for i=0,dist do
        tileRing(centerTile,i,tileTable,allMaps)
    end
end
-- removalInfo = {tileImprovements = int, tribe0Vision = bool, tribe1Vision = bool, tribe2Vision = bool, ..., tribe7Vision = bool}
-- tileImprovements is the integer specifying what the improvements for a particular tile should be
--      (since they may have to be changed to place the radar marker)
-- tribeIVision means that the tribe had units close enough to see the radar marker being placed, and so a spotter unit will have to be created for that tribe to clear the vision.


-- tile is the tile where the radar marker will be placed
-- markerType is one of these four strings
-- "pollution" "railroad" "fortress" "farmland"
-- safe tile is the center of 9 tiles where units can be safely teleported while vision of the radar marker is being given to the radar user.
-- removalInfoTable is the state table that stores the info needed to remove the radar marker
local function placeRadarMarker(tile, radarTribe, markerType, safeTile, removalInfoTable, spotterUnit)
    if tile.city then
        -- Will not place radarMarker on a city in any circumstances
        -- Other conditions should be guarded against elsewhere
        return
    end
    if tile.improvements & 2 == 2 then
        -- won't place combat marker on squares that have a 'city' flag (airbase/transporter) since that
        -- complicates things
        return
    end
    local tileId = getTileId(tile)
    -- save the existing tile improvements
    -- If this tile already has an entry in removalInfoTable, it probably has a radar marker
    -- so we don't want to replace any data in the table (but we may add more).  If nothing
    -- at this particular tile entry, save the existing tile improvements.
    removalInfoTable[tileId] = removalInfoTable[tileId] or {tileImprovements = tile.improvements}
    local withinTwoSquares = {}
    -- If a tribe has units on the same map within 2 squares, it is possible they will see
    -- the radar marker, and, therefore, will need a spotter created when that
    -- marker is removed
    diamond(tile, 2, withinTwoSquares, false)
    for __, nearTile in pairs(withinTwoSquares) do
        if nearTile.defender then
            removalInfoTable[tileId]["tribe"..tostring(nearTile.defender.id).."Vision"] = true
        end
    end
    -- the radar tribe will also need a spotter when the marker is removed
    removalInfoTable[tileId]["tribe"..tostring(radarTribe.id).."Vision"] = true
    -- move all units on square and surrounding squares to the safe are
    -- we'll need to create a spotter unit so that the radar marker will show
    local nineSquares = {}
    diamond(tile,1,nineSquares,false)
    local nineSafeSquares = {}
    diamond(safeTile,1,nineSafeSquares,false)
    for i=1,9 do
        if nineSquares[i] then
            for unit in nineSquares[i].units do
                civ.teleportUnit(unit,nineSafeSquares[i])
            end
        end
    end
    -- now place the radar marker
    local lowerCaseMarkerType = string.lower(markerType)
    if lowerCaseMarkerType == "pollution" then
        if tile.improvements & 2 == 2 then
            -- remove the 'city' flag, because that would make it a transporter
            tile.improvements = tile.improvements & -3
        end
        -- set the -128 bit to put out the pollution/marker
        tile.improvements = tile.improvements | -128
    elseif lowerCaseMarkerType == "farmland" then
        -- make sure the 4 and 8 bits are set to 1
        tile.improvements = tile.improvements | 12
    elseif lowerCaseMarkerType == "railroad" then
        -- make sure the 16 and 32 bits are set to 1
        tile.improvements = tile.improvements | 48
    elseif lowerCaseMarkerType == "fortress" then
        if tile.improvements & 2 == 2 then
            -- remove the 'city' flag, since otherwise it would be an airbase
            tile.improvements = tile.improvements & -3
        end
        -- make sure the 64 bit is set to 1
        tile.improvements = tile.improvements | 64
    else
       error(tostring(markerType).." is not a valid radar marker type.",2)
    end 
    -- create and delete the spotter unit
    civ.deleteUnit(civ.createUnit(spotterUnit,radarTribe,tile))
    -- return the nearby units to their proper squares
    for i=1,9 do
        for unit in nineSafeSquares[i].units do
            civ.teleportUnit(unit,nineSquares[i])
        end
    end
end
local function markCombatLocations(tribeCombatTable)
    local markerTribe = civ.getCurrentTribe()
    for __,combatRecord in pairs(tribeCombatTable) do
        local loc = combatRecord.victimLocation
        local tile = civ.getTile(loc[1],loc[2],loc[3])
        placeRadarMarker(tile, markerTribe, markerTypeString, markerSafeTile, markerRemovalInfoTable, markerSpotterUnit)
    end
end

local function hasRadarMarker(tile, markerType)
    if tile.city then
        -- if the tile has a city, then it definitely doesn't have a radar marker
        return false
    end
    local lowerCaseMarkerType = string.lower(markerType)
    if lowerCaseMarkerType == "pollution" then
        -- pollution flag is the -128 bit
        -- transporter flag is the -128 bit and the 2 bit together, so must exclude the case where both
        -- the -128 bit and the 2 bit are both set to 1
        return tile.improvements & -126 == -128
    elseif lowerCaseMarkerType == "farmland" then
        -- farmland flag is the 4 bit (irrigation flag) and the 8 bit (mining flag)
        -- both set to 1 at the same time
        return tile.improvements & 12 == 12
    elseif lowerCaseMarkerType == "railroad" then
        -- railroad flag is the 32 bit, but it also needs the road flag (the 16 bit) set in order to display
        -- so we check if those two bits together are both set to 1
        return tile.improvements & 48 == 48
    elseif lowerCaseMarkerType == "fortress" then
        -- fortress flag is the 64 bit
        -- airbase flag is the 64 bit and the 2 bit together, so must exclude the case where both
        -- the 64 bit and the 2 bit are both set to 1
        return tile.improvements & 66 == 64
    else
        error(tostring(markerType).." is not a valid radar marker type.",2)
    end
end
local function removeRadarMarker(tile,markerType,safeTile,removalInfoTable,spotterUnit)
    if hasRadarMarker(tile,markerType) then
        local tileId = getTileId(tile)
        local nineSquares = {}
        diamond(tile,1,nineSquares,false)
        local nineSafeSquares = {}
        diamond(safeTile,1,nineSafeSquares,false)
        -- remove nearby units in preparation for 'spotters'
        local removalInfo = removalInfoTable[tileId]
        if removalInfo then
            for i=1,9 do
                if nineSquares[i] then
                    for unit in nineSquares[i].units do
                        civ.teleportUnit(unit,nineSafeSquares[i])
                    end
                end
            end
            -- restore improvements that existed before the radar marker was placed
           tile.improvements = removalInfo.tileImprovements
            -- put spotter units for each tribe that might have 'seen' the radar marker
            for i=0,7 do
                if removalInfo["tribe"..tostring(i).."Vision"] then
                    civ.deleteUnit(civ.createUnit(spotterUnit,civ.getTribe(i),tile))
                end
            end
            -- return units to their proper square
            for i=1,9 do
                for unit in nineSafeSquares[i].units do
                    civ.teleportUnit(unit,nineSquares[i])
                end
            end
        else
            -- if no removal info, just clear the tile as best possible
            if string.lower(markerType) == "railroad" then
                tile.improvements = tile.improvements & -33
            elseif string.lower(markerType) == "pollution" then
                tile.improvements = tile.improvements & 127
            elseif string.lower(markerType) == "farmland" then
                tile.improvements = tile.improvements & -9
            elseif string.lower(markerType) == "fortress" then
                tile.improvements = tile.improvements &-65
            end
        end
        removalInfoTable[tileId] = nil
        return
    else
        return
    end --if hasRadarMarker
end
local function removeAllCombatMarkers()
    local markerType = markerTypeString
    local removalInfoTable = markerRemovalInfoTable
    local spotterUnit = markerSpotterUnit
    local safeTile = markerSafeTile
    local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
    for z = 0,mapQuantity do
        for y=0,mapHeight do
            for x = 0,mapWidth do
                if x%2==y%2 and civ.getTile(x,y,z) then
                    local tile = civ.getTile(x,y,z)
                    if hasRadarMarker(tile, markerType) then
                        removeRadarMarker(tile,markerType,safeTile,removalInfoTable,spotterUnit)
                    end
                end
            end
        end
    end
end
log.removeAllCombatMarkers = removeAllCombatMarkers

local function openReportFunction()
    local menuTable = {}
    menuTable[1] = "Review attacks made against us since last turn."
    menuTable[2] = "Review the attacks we've made this turn."
    if automaticallyShowMap then
        menuTable[4] = "Do not return to map before viewing a tile report."
    else
        menuTable[4] = "Return to map view before viewing a tile report."
    end
    local lastCaptureRecord = citiesCapturedAndDestroyedLog[#citiesCapturedAndDestroyedLog]
    if lastCaptureRecord and ( (lastCaptureRecord.capturingTribeID > civ.getCurrentTribe().id
        and lastCaptureRecord.turn >= (civ.getTurn()-1)) or
        (lastCaptureRecord.turn == civ.getTurn())) then
        menuTable[3] = "REVIEW LIST OF CAPTURED CITIES."
    else
        menuTable[3] = "Review list of captured cities."
    end

    menuTable[10] = "Close Report"
    menuTable[12] = "Hide certain units in the combat report"
    if markerTypeString then
        menuTable[6] = "Mark Locations Where We've Been Attacked."
        menuTable[7] = "Mark Locations We've Attacked this Turn."
        menuTable[8] = "Clear Combat Location Marks."
    end
    menuTable[16] = "Increase lines per window to "..tostring(text.getLinesPerWindow()+1).."."
    menuTable[17] = "Decrease lines per window to "..tostring(text.getLinesPerWindow()-1).."."
    local choice = text.menu(menuTable,"","Combat Reporting",false)
    if choice == 17 then
        text.setLinesPerWindow(text.getLinesPerWindow()-1)
        return openReportFunction()
    elseif choice == 16 then
        text.setLinesPerWindow(text.getLinesPerWindow()+1)
        return openReportFunction()
    elseif choice == 10 then
        return
    elseif choice == 12 then
        setHiddenUnitTypes()
        return openReportFunction()
    elseif choice == 4 then
        automaticallyShowMap = not automaticallyShowMap
        return openReportFunction()
    elseif choice == 3 then
        CRFArgValues.pageType = "City Capture Report"
        return combatReportFunction()
    elseif choice == 2 then
        CRFArgValues.pageType = "Turn Summary"
        CRFArgValues.victimReport = false
        CRFArgValues.aggressorReport = true
        return combatReportFunction()
    elseif choice == 1 then
        CRFArgValues.pageType = "Turn Summary"
        CRFArgValues.victimReport = true
        CRFArgValues.aggressorReport = false
        return combatReportFunction()
    elseif choice == 6 then
        markCombatLocations(gatherVictimCombatInfo(civ.getCurrentTribe()))
        return combatReportFunction()
    elseif choice == 7 then
        markCombatLocations(gatherAggressorCombatInfo(civ.getCurrentTribe()))
        return combatReportFunction()
    elseif choice == 8 then
        removeAllCombatMarkers()
        return combatReportFunction()
    end
end

local function turnSummaryFunction()
    local tribeCombatTable = nil
    local boxTitle = nil
    if CRFArgValues.aggressorReport then
        tribeCombatTable = gatherAggressorCombatInfo(civ.getCurrentTribe())
        boxTitle = "Summary of Attacks We've Made This Turn" 
    elseif CRFArgValues.victimReport then
        tribeCombatTable = gatherVictimCombatInfo(civ.getCurrentTribe())
        boxTitle = "Summary of Attacks Against Us Since Last Turn"
    end
    local dataTable,columnTable,totalDead,totalSurvived = 
        makeWinLossTable(makeCombatSummary(tribeCombatTable))
    local pageMenu = {}
    pageMenu[1] = "See Details by Region"
    pageMenu[2] = "See Details by Tile"
    local choice = text.tabulationWithOptions(dataTable,columnTable,boxTitle,4,3,
            "Back to report options","Close Report",pageMenu,pageMenu)
    if choice == -1 then
        -- back to report options
        CRFArgValues.pageType = "Open Report"
        combatReportFunction()
    elseif choice == 0 then
        -- close report
        return
    elseif choice == 1 then
        -- open the region choice
        CRFArgValues.pageType = "Choose Region"
        return combatReportFunction()
    elseif choice == 2 then
        -- open the individual tile list
        CRFArgValues.pageType = "Choose From All Tiles"
        return combatReportFunction()
    end
end

local function chooseRegionFunction()
    local organizedCombatInfo = nil
    local regionOrderTable = nil
    local tileOrderTable = nil
    if CRFArgValues.aggressorReport then
        organizedCombatInfo = organizedCombatInfoAttack
        regionOrderTable = regionOrderTableAttack
        tileOrderTable = tileOrderTableAttack
    elseif CRFArgValues.victimReport then
        organizedCombatInfo = organizedCombatInfoDefense
        regionOrderTable = regionOrderTableDefense
        tileOrderTable = tileOrderTableDefense
    else
        error("chooseRegionFunction: neither attack nor defense chosen")
    end
    local menuOffset = 2
    local menuTable = {}
    menuTable[1] = "Back to Report Options"
    menuTable[2] = "Close"
    for key,regionName in pairs(regionOrderTable) do
        local deadCount,survivedCount = countDeadAndSurvivedByRegion(organizedCombatInfo[regionName],
                                            CRFArgValues.aggressorReport)
        menuTable[key+menuOffset] = regionName.." Losses: "..tostring(deadCount).."  Victories: "..tostring(survivedCount)
    end
    local menuText = "For what region do you want a combat report?"
    local choice = text.menu(menuTable,menuText,"Choose Region")
    local choice = choice -menuOffset
    if choice == 1-menuOffset then
        CRFArgValues.pageType = "Open Report"
        return combatReportFunction()
    elseif choice == 2-menuOffset then
        return
    else
        CRFArgValues.currentRegion = regionOrderTable[choice]
        CRFArgValues.pageType = "Region Summary"
        return combatReportFunction()
    end
end

local function gatherOrganizedRegionCombatInfo(organizedRegionTable)
    local regionCombatTable = {}
    local regionCTIndex = 1
    for tileID,tableOfCombatRecords in pairs(organizedRegionTable) do
        for __,combatRecord in pairs(tableOfCombatRecords) do
            regionCombatTable[regionCTIndex] = combatRecord
            regionCTIndex=regionCTIndex+1
        end
    end
    return regionCombatTable
end


local function centerViewOnCurrentTileOrderNumber()
    local organizedCombatInfo = nil
    local regionOrderTable = nil
    local tileOrderTable = nil
    if CRFArgValues.aggressorReport then
        organizedCombatInfo = organizedCombatInfoAttack
        regionOrderTable = regionOrderTableAttack
        tileOrderTable = tileOrderTableAttack
    else
        organizedCombatInfo = organizedCombatInfoDefense
        regionOrderTable = regionOrderTableDefense
        tileOrderTable = tileOrderTableDefense
    end
    local regionKeyTileID=tileOrderTable[CRFArgValues.currentTileOrderNumber]
    local region,tileID = regionKeyTileID.regionKey,regionKeyTileID.tileID
    local triple = organizedCombatInfo[region][tileID][1].victimLocation
    civ.ui.centerView(civ.getTile(triple[1],triple[2],triple[3]))
    return
end

local function regionSummaryFunction()
    local tribeCombatTable = nil
    local boxTitle = nil
    local isLandmarkRegion = false
    if CRFArgValues.aggressorReport then
        tribeCombatTable = gatherOrganizedRegionCombatInfo(organizedCombatInfoAttack[CRFArgValues.currentRegion])
        boxTitle = "Summary of Attacks We've Made This Turn" 
    elseif CRFArgValues.victimReport then
        tribeCombatTable = gatherOrganizedRegionCombatInfo(organizedCombatInfoDefense[CRFArgValues.currentRegion])
        boxTitle = "Summary of Attacks Against Us Since Last Turn"
    end
    if CRFArgValues.currentRegion:sub(1,landmarkRegionPrefix:len())==landmarkRegionPrefix then
        isLandmarkRegion = true
        boxTitle = boxTitle.." "..CRFArgValues.currentRegion
    else
        boxTitle = boxTitle.." in "..CRFArgValues.currentRegion
    end
    local dataTable,columnTable,totalDead,totalSurvived = 
        makeWinLossTable(makeCombatSummary(tribeCombatTable))
    local pageMenu = {}
    pageMenu[2] = "See Details by Tile"
    local choice = text.tabulationWithOptions(dataTable,columnTable,boxTitle,4,3,
            "Back to report options","Close Report",pageMenu,pageMenu)
    if choice == -1 then
        -- back to report options
        CRFArgValues.pageType = "Open Report"
        combatReportFunction()
    elseif choice == 0 then
        -- close report
        return
   --  elseif choice == 1 then
   --      -- open the region choice
   --      CRFArgValues.pageType = "Choose Region"
   --      combatReportFunction()
    elseif choice == 2 then
        -- open the individual tile list
        CRFArgValues.pageType = "Choose Tile In Region"
        combatReportFunction()
    end
end

local function chooseRegionTileFunction()
    local tileOrderTable = nil
    local combatInfoByTile = nil
    if CRFArgValues.aggressorReport then
        combatInfoByTile = organizedCombatInfoAttack[CRFArgValues.currentRegion]
        tileOrderTable = tileOrderTableAttack
    else
        combatInfoByTile = organizedCombatInfoDefense[CRFArgValues.currentRegion]
        tileOrderTable = tileOrderTableDefense
    end
    local menuOffset = 2
    local menuTable = {}
    menuTable[1] = "Back to Region Summary"
    menuTable[2] = "Close"

    for i=1,#tileOrderTable do
        if tileOrderTable[i].regionKey == CRFArgValues.currentRegion then
            local combatInfo = combatInfoByTile[tileOrderTable[i].tileID]
            local deadCount,survivedCount = countDeadAndSurvived(combatInfo,CRFArgValues.aggressorReport)
            local triple = combatInfo[1]["victimLocation"]
            local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..")"
            menuTable[i+menuOffset] = tileName.." Losses: "..tostring(deadCount).." Victories: "..tostring(survivedCount)
        end
    end
    --for tileID,combatInfo in pairs(combatInfoByTile) do
    --    local deadCount,survivedCount = countDeadAndSurvived(combatInfo,CRFArgValues.aggressorReport)
    --    local triple = combatInfo[1]["victimLocation"]
    --    local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..")"
    --    menuTable[tileID+menuOffset] = tileName.." Losses: "..tostring(deadCount).." Victories: "..tostring(survivedCount)
    --end
    local menuText = "For what tile do you want a combat report?"
    local choice = text.menu(menuTable,menuText,"Choose Tile")
    local choice = choice -menuOffset
    if choice == 1-menuOffset then
        CRFArgValues.pageType = "Open Report"
        return combatReportFunction()
    elseif choice == 2-menuOffset then
        return
    end
    --for key,regionTileIDPair in pairs(tileOrderTable) do
    --    if regionTileIDPair.tileID == choice then
    --        CRFArgValues.currentTileOrderNumber = key
    --        break
    --    end
    --end
    CRFArgValues.currentTileOrderNumber = choice
    CRFArgValues.pageType = "Tile in Region Report"
    centerViewOnCurrentTileOrderNumber()
    if automaticallyShowMap then
        return
    else
        return combatReportFunction()
    end
end


local function tileInRegionReport()
    local tileOrderTable = nil
    if CRFArgValues.aggressorReport then 
        tileOrderTable = tileOrderTableAttack
    else
        tileOrderTable = tileOrderTableDefense
    end
    local tileID = tileOrderTable[CRFArgValues.currentTileOrderNumber].tileID
    local tileCombatInfo = nil
    local organizedCombatInfo = nil
    local combatTile = nil
    if CRFArgValues.aggressorReport then
        organizedCombatInfo = organizedCombatInfoAttack
        tileCombatInfo = organizedCombatInfoAttack[CRFArgValues.currentRegion][tileID]
        local triple = tileCombatInfo[1]["victimLocation"]
        local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..")"
        boxTitle = "Attacks Made Into "..tileName.." This Turn"
        combatTile = civ.getTile(triple[1],triple[2],triple[3])
    else
        organizedCombatInfo = organizedCombatInfoDefense
        tileCombatInfo = organizedCombatInfoDefense[CRFArgValues.currentRegion][tileID]
        local triple = tileCombatInfo[1]["victimLocation"]
        local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..")"
        boxTitle = "Attacks Made Into "..tileName.." Since Last Turn"
        combatTile = civ.getTile(triple[1],triple[2],triple[3])
    end
    --civ.ui.centerView(combatTile)
    --if automaticallyShowMap and not justAutomaticallyClosed then
    --    justAutomaticallyClosed = true
    --    return
    --end
    justAutomaticallyClosed = false
    local dataTable,columnTable,totalDead,totalSurvived = makeWinLossTable(makeCombatSummary(tileCombatInfo))
    local pageMenu = {}
    pageMenu[1] = "Close Report"
    pageMenu[2] = "Back to Region"
    pageMenu[3] = "Report Options"
    local choice = text.tabulationWithOptions(dataTable,columnTable,boxTitle,4,3,
        "Previous Tile In Region","Next Tile in Region",pageMenu,pageMenu)
    if choice == -1 then
        -- previous tile in region
        if tileOrderTable[CRFArgValues.currentTileOrderNumber-1].regionKey == CRFArgValues.currentRegion then
            CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber -1
        else
            while tileOrderTable[CRFArgValues.currentTileOrderNumber+1].regionKey 
                == CRFArgValues.currentRegion do
                CRFArgValues.currentTileOrderNumber=CRFArgValues.currentTileOrderNumber+1
            end
        end
        centerViewOnCurrentTileOrderNumber()
        if automaticallyShowMap then
            return
        else
            return combatReportFunction()
        end

        --local prospectiveNextTileID = tileOrderTable[CRFArgValues.currentTileOrderNumber-1]
        --if organizedCombatInfo[CRFArgValues.currentRegion][prospectiveNextTileID] then
        --    CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber-1
        --    if automaticallyShowMap then
        --        return
        --    else
        --        return combatReportFunction()
        --    end
        --else
        --    while organizedCombatInfo[CRFArgValues.currentRegion]
        --        [tileOrderTable[CRFArgValues.currentTileOrderNumber+1]] do
        --        CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber+1
        --    end
        --    if automaticallyShowMap then
        --        return
        --    else
        --        return combatReportFunction()
        --    end
        --end
    elseif choice == 0 then
        -- next tile in region
        if tileOrderTable[CRFArgValues.currentTileOrderNumber+1] and tileOrderTable[CRFArgValues.currentTileOrderNumber+1].regionKey == CRFArgValues.currentRegion then
            CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber +1
        else
            while tileOrderTable[CRFArgValues.currentTileOrderNumber-1] and tileOrderTable[CRFArgValues.currentTileOrderNumber-1].regionKey 
                == CRFArgValues.currentRegion do
                CRFArgValues.currentTileOrderNumber=CRFArgValues.currentTileOrderNumber-1
            end
        end
        centerViewOnCurrentTileOrderNumber()
        if automaticallyShowMap then
            return
        else
            return combatReportFunction()
        end
        --local prospectiveNextTileID = tileOrderTable[CRFArgValues.currentTileOrderNumber+1]
        --if organizedCombatInfo[CRFArgValues.currentRegion][prospectiveNextTileID] then
        --    CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber+1
        --    if automaticallyShowMap then
        --        return
        --    else
        --        return combatReportFunction()
        --    end
        --else
        --    while organizedCombatInfo[CRFArgValues.currentRegion]
        --        [tileOrderTable[CRFArgValues.currentTileOrderNumber-1]] do
        --        CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber-1
        --    end
        --    if automaticallyShowMap then
        --        return
        --    else
        --        return combatReportFunction()
        --    end
        --end
    elseif choice == 1 then
        -- close
        return
    elseif choice == 2 then
        --back to region
        CRFArgValues.pageType = "Region Summary"
        return combatReportFunction()
    elseif choice == 3 then
        -- back to report options
        CRFArgValues.pageType = "Open Report"
        return combatReportFunction()
    end
end

local function chooseFromAllTiles()
    local organizedCombatInfo = nil
    local regionOrderTable = nil
    local tileOrderTable = nil
    if CRFArgValues.aggressorReport then
        organizedCombatInfo = organizedCombatInfoAttack
        regionOrderTable = regionOrderTableAttack
        tileOrderTable = tileOrderTableAttack
    else
        organizedCombatInfo = organizedCombatInfoDefense
        regionOrderTable = regionOrderTableDefense
        tileOrderTable = tileOrderTableDefense
    end
    local menuOffset = 2
    local menuTable = {}
    menuTable[1] = "Back to Turn Summary"
    menuTable[2] = "Close"
    for i=1,#tileOrderTable do
        local regionTileID = tileOrderTable[i]
        local region = regionTileID.regionKey
        local tileID = regionTileID.tileID
        local combatInfo = organizedCombatInfo[region][tileID]
        local deadCount,survivedCount = countDeadAndSurvived(combatInfo,CRFArgValues.aggressorReport)
        local triple = combatInfo[1]["victimLocation"]
        local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..")"
        menuTable[i+menuOffset] = tileName..regionTileID.regionKey.." Losses: "..tostring(deadCount).." Victories: "..tostring(survivedCount)
    end
    local menuText = "For what tile do you want a combat report?"
    local choice = text.menu(menuTable,menuText,"Choose Tile")
    local choice = choice -menuOffset
    if choice == 1-menuOffset then
        CRFArgValues.pageType = "Turn Summary"
        return combatReportFunction()
    elseif choice == 2-menuOffset then
        return
    end
    CRFArgValues.currentTileOrderNumber = choice
    CRFArgValues.pageType = "Tile From All Report"
    centerViewOnCurrentTileOrderNumber()
    if automaticallyShowMap then
        return
    else
        return combatReportFunction()
    end
end

local function tileFromAllReport()
    local organizedCombatInfo = nil
    local tileOrderTable = nil
    local boxTitlePostfix = nil
    if CRFArgValues.aggressorReport then
        organizedCombatInfo = organizedCombatInfoAttack
        tileOrderTable = tileOrderTableAttack
        boxTitlePostfix = " This Turn"
    else
        organizedCombatInfo = organizedCombatInfoDefense
        tileOrderTable = tileOrderTableDefense
        boxTitlePostfix = " Since Last Turn"
    end
    local regionTileID = tileOrderTable[CRFArgValues.currentTileOrderNumber]
    local tileCombatInfo = organizedCombatInfo[regionTileID.regionKey]
            [regionTileID.tileID]
    local triple = tileCombatInfo[1]["victimLocation"]
    local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..") "..regionTileID.regionKey
    local boxTitle = "Attacks Made Into "..tileName..boxTitlePostfix
    local combatTile = civ.getTile(triple[1],triple[2],triple[3])
    --civ.ui.centerView(combatTile)
    --if automaticallyShowMap and not justAutomaticallyClosed then
    --    justAutomaticallyClosed = true
    --    return
    --end
    justAutomaticallyClosed = false
    local dataTable,columnTable,totalDead,totalSurvived = makeWinLossTable(makeCombatSummary(tileCombatInfo))
    local pageMenu = {}
    pageMenu[1] = "Close Report"
    pageMenu[2] = "Back to Turn Summary"
    pageMenu[3] = "Report Options"
    local choice = text.tabulationWithOptions(dataTable,columnTable,boxTitle,4,3,
        "Previous Tile","Next Tile",pageMenu,pageMenu)
    if choice == -1 then
        --previous tile
        if CRFArgValues.currentTileOrderNumber > 1 then
            CRFArgValues.currentTileOrderNumber=CRFArgValues.currentTileOrderNumber-1
        else
            CRFArgValues.currentTileOrderNumber=#tileOrderTable
        end
        centerViewOnCurrentTileOrderNumber()
        if automaticallyShowMap then
            return
        else
            return combatReportFunction()
        end
    elseif choice == 0 then
        -- next tile
        if tileOrderTable[CRFArgValues.currentTileOrderNumber+1] then
            CRFArgValues.currentTileOrderNumber = CRFArgValues.currentTileOrderNumber+1
        else
            CRFArgValues.currentTileOrderNumber = 1
        end
        centerViewOnCurrentTileOrderNumber()
        if automaticallyShowMap then
            return
        else
            return combatReportFunction()
        end
    elseif choice == 1 then
        -- close
        return
    elseif choice == 2 then
        -- back to turn summary
        CRFArgValues.pageType = "Turn Summary"
        return combatReportFunction()
    elseif choice == 3 then
        -- back to report options
        CRFArgValues.pageType = "Open Report"
        return combatReportFunction()
    end
end


local function cityCaptureReport()
    local tabulationData = {}
    local totalCities = #citiesCapturedAndDestroyedLog
    for i=totalCities,1,-1 do
        local cityCapturedRecord = citiesCapturedAndDestroyedLog[i]
        local cityName = cityCapturedRecord.cityName
        local triple = cityCapturedRecord.cityLocation
        local tileName = "("..tostring(triple[1])..","..tostring(triple[2])..","..tostring(triple[3])..")"
        local losingTribeAdjective = civ.getTribe(cityCapturedRecord.losingTribeID).adjective
        local capturingTribeName = civ.getTribe(cityCapturedRecord.capturingTribeID).name
        local turnsAgo = civ.getTurn()-cityCapturedRecord.turn
        local timing = nil
        if cityCapturedRecord.capturingTribeID > civ.getCurrentTribe().id then
            turnsAgo = turnsAgo-1
        end
        if turnsAgo == 0 then
            timing = " since our last turn."
        elseif turnsAgo == 1 then
            timing = " one turn ago."
        elseif turnsAgo == 2 then
            timing = " 2 turns ago."
        else
            timing = " "..tostring(turnsAgo).." turns ago."
        end
        tabulationData[totalCities+1-i] = {}
        if cityCapturedRecord.wasDestroyed then
            tabulationData[totalCities+1-i][1] = cityName.." "..tileName.." ("..losingTribeAdjective..") destroyed by the "..capturingTribeName..timing
        else
            tabulationData[totalCities+1-i][1] = cityName.." "..tileName.." ("..losingTribeAdjective..") captured by the "..capturingTribeName..timing
        end
    end
    if #tabulationData == 0 then
        tabulationData[1] = {}
        tabulationData[1][1] = "No cities have been captured or destroyed."
    end
    text.simpleTabulation(tabulationData,"City Capture History")
    CRFArgValues.pageType = "Open Report"
    return combatReportFunction()
end






    










combatReportFunction = function()
    if civ.getCurrentTribe() ~= CRFArgValues.applicableTribe then
        resetCRFArgValues()
        getOrganizedCombatInfoForLastTurn()
        getOrganizedAttackInfo()
    end
    if attackMadeSinceInfoLastGathered then
        getOrganizedAttackInfo()
    end
    local functionState = CRFArgValues.pageType
    if functionState == "Open Report" then
        --Choose between reviewing previous turn's attacks or
        --reviewing results of attacks made this turn
        --can toggle option(s)
        --
        return openReportFunction()
    elseif functionState == "Turn Summary" then
        -- overall summary of combat results
        --
        -- choose between selecting from tiles individually
        -- and getting reports based on region
        return turnSummaryFunction()
    elseif functionState == "Choose Region" then
        -- regions are available to choose from,
        -- with total victories and losses for each one
        return chooseRegionFunction()
    elseif functionState == "Region Summary" then
        -- overall summary of the chosen region
        -- can choose to look at individual tiles or choose
        -- a different region
        return regionSummaryFunction()
    elseif functionState == "Choose Tile In Region" then
        -- tiles are available to choose from, with
        -- total victories and losses for each one
        -- can go back to choose region, or choose tiles
        return chooseRegionTileFunction()
    elseif functionState == "Tile in Region Report" then
        -- report for an individual tile, arrived at from
        -- a region report selection
        return tileInRegionReport()
    elseif functionState == "Choose From All Tiles" then
        -- shows a list of all tiles with combat, and the
        -- wins and losses.  Region not relevant
        return chooseFromAllTiles()
    elseif functionState == "Tile From All Report" then
        -- report for an individual tile, arrived at from
        -- a selection from the list of all tiles
        return tileFromAllReport()
    elseif functionState == "City Capture Report" then
        -- shows the history of all cities captured and destroyed
        return cityCaptureReport()
    else
        error("combatReportFunction: function state has value "..functionState)
    end
end
log.combatReportFunction = combatReportFunction




return log
























