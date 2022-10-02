
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local radar = require("radar")
local gen = require("generalLibrary"):minVersion(1)
local object = require("object")
local keyboard = require("keyboard")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local text = require("text")
local flag = require("flag")
local radarSettings = {}
gen.versionFunctions(radarSettings,versionNumber,fileModified,"MechanicsFiles".."\\".."radarSettings.lua")

-- comment out this next line to use this radar system
if true then return radarSettings end

-- This module implements a basic radar system
-- Each unit has a radar "cross section" which determines
-- how visible the unit is to radar in general
--
--
-- A radar station receives a return signal which depends on
-- the target's cross section and the distance from the
-- station to the target
-- C = cross section
-- D = distance
-- S = signal returned
-- S = C/(D^4)
--
-- More effective radar stations can detect smaller signals
-- (in this model, there is no distinction between a more
-- powerful transmitter and a better receiver)
-- https://en.wikipedia.org/wiki/Radar#Principles
--
-- So, to influence detectability, the intruder can only change the
-- cross section of the unit (perhaps by technology), while the
-- radar station must change the signal it can detect.  Complete stealth
-- consists of a 0 cross section.
--
-- In this model, each tile has a cross section, built from the cross
-- sections of the units on the tile.  This could just be the maximum
-- cross section, or it might add them up, or add them up and take the
-- square root.  There are some options.  So a single airplane might
-- not be detected, but several could be.
--
-- There are 2 classes of units.  "Surface" units and "Air" units.
-- These are just categories that can mean whatever you like, but by
-- default, surface units are domain 0 and 2, while air units are domain 1
-- Radar detects these 2 groups differently.
--
-- A radar station's characteristics will have a signal threshold
-- over which it will always detect the intruder, and a signal
-- threshold below which it will never detect the intruder.  Between that,
-- there is a chance of detection which increases with the cross section.
-- E.g. if the S_neverDetect is 1, and S_alwaysDetect is 2, and S_received
-- is 1.65, there is a 65% chance of detection.
-- 
-- Radar stations are sometimes inaccurate.  They will occasionally place the
-- radar marker on a different square than the one where the target is.
-- In this model, that effect is governed by a single number, which is the
-- chance that the marker is placed exactly on target.  If it is not placed
-- on target, it has an equal chance of being placed 1 square away, and 2 squares
-- away and so on, until there is no chance left.  A couple examples will be more clear:
--
-- .9:
-- 90% chance marker is placed on correct tile
-- 10% chance marker is placed one tile off (1.25% chance for each of 8 surrounding tiles)
--
-- .4:
-- 40% chance marker is placed on correct tile
-- 40% chance marker is placed one tile off (5% chance for each of the 8 tiles)
-- 20% chance marker is placed two tiles off (1.25% chance for each of 16 tiles 2 squares away)
--
-- Radar stations also have a maximum range (e.g. curvature of the Earth).  This can be different
-- for surface vs air units, and for different maps.
--
-- This radar model will never detect units in cities, nor attempt to place markers
-- on city squares

-- This table offers basic cross sectional information for individual unit types
-- A unit not in this list has no radar visibility
-- A unit's cross section will never be 
-- unitCrossSection[unitType.id] = {
--      base = number
--          This is the basic cross section of the unit type
--          absent means 0
--      tribeBonus = {[tribe.id] = number}
--          subtract the number from the base cross section if the
--          unit is owned by the corresponding tribe
--          (a negative number means a penalty for that tribe)
--          absent means 0
--      techBonus = {[technology.id] = number}
--          if the tribe has the given technology, the cross section is
--          reduced by this amount
--          absent means 0
--      generalModifier = function(unit) --> number
--          subtract the result of this function 
--      surface = bool
--          if true, this unit is in the 'surface' category,
--          if false, it is not
--          if absent, unit is surface if domain is 0 or 2
--      air = bool
--          if true, this unit is in the 'air' category
--          if false, it is not
--          if absent, unit is air if domain is 1
--      minCrossSection = number
--          A unit's cross section will never be less than this
--          absent means 0
--  }
--
--

local unitCrossSection = {}
--[[
unitCrossSection[gen.original.uBattleship.id] = {
    base = 10000,
    surface = true,
}
unitCrossSection[gen.original.uFighter.id] = {
    base = 5000,
    surface = false,
    air = true,
}
unitCrossSection[gen.original.uStlthFtr.id] = {
    base = 0,
    surface = false,
    air = true,
}
--]]



-- Settings
local airRadarMarker = "pollution"
local surfaceRadarMarker = "pollution"
radar.setMarkers(airRadarMarker,surfaceRadarMarker)

-- Tile Cross Section Options
local tileCrossSectionSystemAir = "max" -- the tile's cross section is the largest cross section of the units on the tile
--local tileCrossSectionSystemAir = "sum" -- the tile's cross section is the sum of the cross sections on the tile
--local tileCrossSectionSystemAir = "rootSum" -- the tile's cross section is the square root of the sum of the cross sections on the tile
--local tileCrossSectionSystemAir = "sumAdjacent" -- the tile's cross section is the sum of the units on the tile and that of the units on adjacent tiles (so a group of units still triggers even if they are a bit spread out).  If no units are on a tile, it doesn't trigger, even if there are some on adjacent tiles.
--local tileCrossSectionSystemAir = "rootSumAdjacent" -- the tile's cross section is the sum of the units on the tile and that of the units on adjacent tiles (so a group of units still triggers even if they are a bit spread out)  If no units are on a tile, it doesn't trigger, even if there are some on adjacent tiles.

local tileCrossSectionSystemSurface = "max" -- the tile's cross section is the largest cross section of the units on the tile
--local tileCrossSectionSystemSurface = "sum" -- the tile's cross section is the sum of the cross sections on the tile
--local tileCrossSectionSystemSurface = "rootSum" -- the tile's cross section is the square root of the sum of the cross sections on the tile
--local tileCrossSectionSystemSurface = "sumAdjacent" -- the tile's cross section is the sum of the units on the tile and that of the units on adjacent tiles (so a group of units still triggers even if they are a bit spread out).  If no units are on a tile, it doesn't trigger, even if there are some on adjacent tiles.
--local tileCrossSectionSystemSurface = "rootSumAdjacent" -- the tile's cross section is the sum of the units on the tile and that of the units on adjacent tiles (so a group of units still triggers even if they are a bit spread out).  If no units are on a tile, it doesn't trigger, even if there are some on adjacent tiles.

local function surfaceCrossSection(tile)
    local maxSoFar = 0
    local sumSoFar = 0
    local radius = 0
    local system = tileCrossSectionSystemSurface
    if system == "sumAdjacent" or system == "rootSumAdjacent" then
        radius = 1
    end
    for unit in gen.nearbyUnits(tile,radius) do
        local crossSectionInfo = unitCrossSection[unit.type.id] or {}
        local surface = crossSectionInfo.surface
        if surface == nil then
            surface = unit.type.domain ~= 1
        end
        local map = tile.z
        local crossSection = 0
        if surface and unit.location.z == map then
            crossSection = crossSectionInfo.base or 0
            local tribeBonus = crossSectionInfo.tribeBonus or {}
            crossSection = crossSection - (tribeBonus[unit.owner.id] or 0)
            local techBonus = crossSectionInfo.techBonus or {}
            for techID, bonus in pairs(techBonus) do
                if unit.owner:hasTech(civ.getTech(techID)) then
                    crossSection = crossSection - bonus
                end
            end
            if crossSectionInfo.generalModifier then
                crossSection = crossSection - crossSectionInfo.generalModifier(unit)
            end
            crossSection = math.max(crossSection,(crossSectionInfo.minCrossSection or 0))
        end
        if crossSection > maxSoFar then
            maxSoFar = crossSection
        end
        sumSoFar = sumSoFar + crossSection
    end
    if system == "max" then
        return maxSoFar
    elseif system == "sum" or system == "sumAdjacent" then
        return sumSoFar
    elseif system == "rootSum" or system == "rootSumAdjacent" then
        return math.sqrt(sumSoFar)
    else
        error("radarSettings:surfaceCrossSection: the tileCrossSectionSystemSurface parameter doesn't have an acceptable value.  It's value is "..tostring(system)..".  Acceptable values are 'max', 'sum', 'sumAdjacent', 'rootSum', 'rootSumAdjacent'.")
    end
end

local function airCrossSection(tile)
    local maxSoFar = 0
    local sumSoFar = 0
    local radius = 0
    local system = tileCrossSectionSystemAir
    if system == "sumAdjacent" or system == "rootSumAdjacent" then
        radius = 1
    end
    for unit in gen.nearbyUnits(tile,radius) do
        local crossSectionInfo = unitCrossSection[unit.type.id] or {}
        local air = crossSectionInfo.air
        if air == nil then
            air = unit.type.domain == 1
        end
        local map = tile.z
        local crossSection = 0
        if air and unit.location.z == map then
            crossSection = crossSectionInfo.base or 0
            local tribeBonus = crossSectionInfo.tribeBonus or {}
            crossSection = crossSection - (tribeBonus[unit.owner.id] or 0)
            local techBonus = crossSectionInfo.techBonus or {}
            for techID, bonus in pairs(techBonus) do
                if unit.owner:hasTech(civ.getTech(techID)) then
                    crossSection = crossSection - bonus
                end
            end
            if crossSectionInfo.generalModifier then
                crossSection = crossSection - crossSectionInfo.generalModifier(unit)
            end
            crossSection = math.max(crossSection,(crossSectionInfo.minCrossSection or 0))
        end
        if crossSection > maxSoFar then
            maxSoFar = crossSection
        end
        sumSoFar = sumSoFar + crossSection
    end
    if system == "max" then
        return maxSoFar
    elseif system == "sum" or system == "sumAdjacent" then
        return sumSoFar
    elseif system == "rootSum" or system == "rootSumAdjacent" then
        return math.sqrt(sumSoFar)
    else
        error("radarSettings:airCrossSection: the tileCrossSectionSystemAir parameter doesn't have an acceptable value.  It's value is "..tostring(system)..".  Acceptable values are 'max', 'sum', 'sumAdjacent', 'rootSum', 'rootSumAdjacent'.")
    end
end

--  this data type describes modifications to the standard radar calibration,
--  e.g. for specific tribes or extra techs
--  Numbers are added or subtracted from the relevant radar calibration.
--  Positive numbers always improve the radar effectiveness, while negative numbers
--  reduce it.  (i.e. crossSection is subtracted, but range is added)
-- calibrationModifier = {
--      crossSection = number
--          if the modifier is active, the detectable cross section is reduced by this amount
--          nil means do not modify
--      range = number
--          if the modifier is active, the effective range is increased by this many tiles
--          nil means do not modify
--      unreliableDetectionFactor = number (final number between 0 and 1)
--          if the modifier is active, the unreliableDetectionFactor is reduced by this amount
--          nil means do not modify
--          factor above 1 counts as factor of 1, factor below 0 counts as 0
--      accuracy = number 0-1 or true
--          if the modifier is active and a number, the accuracy is increased by this amount
--          if the modifier is true, accuracy becomes true, and reveals the stack
--          nil means do not modify
--          final accuracy above 1 counts as accuracy of 1 factor below 0.1 counts as 0.1
--
--      maxSurfaceRange = number
--          if the modifier is active, maxSurfaceRange is increased by this amount
--          nil means do not modify
--      maxAirRange = number
--          if the modifier is active, maxAirRange is increased by this amount
--          nil means do not modify
-- }
                
-- radarCalibration = {
--      crossSection = number (lower is better)
--      range = number  (higher is better)
--          The radar station will always detect a signal of the given
--          crossSection and range, but this will be the cutoff for 100% detection
--      unreliableDetectionFactor = number from 0-1 (lower is better)
--          Determines the signal threshold for occasional detection.
--          If range=10 and crossSection=10,000, and unreliableDetectionFactor = 0.8,
--          then occasional detection at range=10 starts with a crossSection = 8,000
--          at 9,000, there is 50% detection chance, and 9,500 has a 75% chance
--      accuracy = number from 0.1-1 or true (higher is better)
--          gives the accuracy of the radar station (as explained in the model description)
--          min of 0.1, above 1 counts as 1
--      maxSurfaceRange = integer
--          radar station can't detect surface units beyond this range, even if the
--          signal is strong enough
--      maxAirRange = integer
--          radar station can't detect air units beyond this range, even if the signal is strong enough
--      tribeModifier = {[tribe.id] = calibrationModifier}
--          applies modifiers based on the scanning tribe
--          absent means no tribe modifier
--      techModifier = {[technology.id] = calibrationModifier}
--          applies modifiers when the scanning tribe has the relevant technology
--          absent means no tech modifier
--      flagModifier = {[flagKey] = calibrationModifier}
--          if the flag corresponding to the flagKey is true, the modifier is applied
--          absent means no flag modifier
--
--
--      
--          
-- }

--  This table provides information to build the radar station data
--  There should be at most one entry per station/tribe combination
--  
-- radarTable[anyIndex] = {
--      station = unitType or improvementObject or "city"
--              or table of tiles
--          if unitType, the unitType acts as the radar station
--          if improvementObject, cities with that improvement act as the radar station
--          if "city" then all cities act as radar stations
--          if table of tiles, those tiles act as radar stations, regardless of ownership
--          (e.g. satellite imaging)
--          a table of tiles can be a table of tables that can be converted to tiles with gen.toTile
--          a single tileObject can be the station, but a table convertable to a tile with gen.toTile
--          must be wrapped in another table
--      tribes = table of tribeObject
--          These tribes can use this radar system if they own the corresponding station
--          (or, regardless of ownership if the 'stations' are tiles
--          nil means all tribes can use
--      flag = flagKeyString
--          The flag with the given string must be true to use this station
--          nil means no flag requirement
--      tech = tech or table of tech or nil
--      techNumber = integer or nil
--          player must have techNumber of the techs listed in order to use this station type
--          if techNumber is nil, all techs must be acquired
--          if tech is nil, there is no requirement
--      moveCost = number or nil
--          for units, this is the movement point cost to use the radar system
--          (in full movement points)
--          nil means no cost
--      moneyCost = number or nil
--          this is the gold cost to use the radar system
--          (if there is not enough gold, the scan happens anyway, and the treasury is reduced to 0,
--          use canScanFn to implement min treasury if desired)
--          nil means no cost
--      scanEffectFn = function(unit/city/tile) -> void
--          this function is run after a radar scan, and applies supplemental
--          effects (e.g. extra costs)
--          nil means nothing extra happens 
--      canScanFn = function(unit/city/tile) -> boolean
--          this function determines if the unit/city/tile
--          in question can perform the radar scan.  If true, it can,
--          if false it can't (and doesn't pay any costs)
--          nil means no extra requirement
--      scanKey = integer (keyCode -- use the keyboard module)
--          if unit type, this manually activates the active unit's radar scan
--          if improvement/city/tile, if there is no active unit, this key checks
--          the current tile for a possible radar scan
--          if nil, the scan can't be activated individually
--      groupScan = bool or nil
--          if true, this station participates in the group radar scan
--          when it is activated.
--          false or nil means it doesn't participate in the group scan
--
--      sameMapScan = radarCalibration
--          if this is key is used, the radar scans only the map the scanner is on
--          using the supplied radar calibration
--      allMapScan = radarCalibration
--          if this key is used, all maps are scanned using the supplied radar calibration
--
--      scanMapXFromY = radarCalibration
--          this series of keys supplies the radar calibration for scanning map X from map Y
--          any absent keys means that no scan is conducted between those maps
--
--      secretTileTable = {[tileID] = true}
--          post processing entry.  tiles from station are entered here, for more efficient use
--          in program
--
--
--      

local radarTable = {}

--[[
radarTable["airport"] = {
    station = gen.original.iAirport,
    --tech = gen.original.aRadio,
    moneyCost = 5,
    scanKey = keyboard.u,
    groupScan = true,
    sameMapScan = {crossSection = 1, range = 6, unreliableDetectionFactor = 1, accuracy = 1, maxSurfaceRange = 5, maxAirRange = 10},
    --tech = {gen.original.aAdvancedFlight, gen.original.aEnvironmentalism, gen.original.aAtomicTheory},
    --techNumber = 2,
}
flag.define("testingFlag",false)

radarTable["tiles"] = {
    station = {civ.getTile(99,37,0),civ.getTile(99,37,1)},
    flag = "testingFlag",
    allMapScan = {crossSection = 1, range = 6, unreliableDetectionFactor = 1, accuracy = 1, maxSurfaceRange = 5, maxAirRange = 10},
    --scanMap0From1 = {crossSection = 1, range = 6, unreliableDetectionFactor = 1, accuracy = 1, maxSurfaceRange = 5, maxAirRange = 10},
    scanKey = keyboard.k,
    tribes = {civ.getTribe(1)},
}

radarTable["frigate"] = {
    station = gen.original.uFrigate,
    moneyCost = 10,
    moveCost = 3,
    allMapScan = {crossSection = 1, range = 6, unreliableDetectionFactor = 1, accuracy = 1, maxSurfaceRange = 5, maxAirRange = 10},
    scanKey = keyboard.k
}

--]]


local keyPressFunction, groupScanFunction = radar.buildKeyPressAndGroupScanFunctions(radarTable, airCrossSection, surfaceCrossSection)

flag.define("noGroupScanThisTurn",true,"radarSettings")
function discreteEvents.onTribeTurnBegin(turn,tribe)
    flag.setTrue("noGroupScanThisTurn","radarSettings")
end

local function radarKey()
    local tribe = civ.getCurrentTribe()
    local tile = civ.getCurrentTile()
    local menuTable = {}
    menuTable[1] = "Do Nothing"
    if flag.value("noGroupScanThisTurn","radarSettings") then
        menuTable[2] = "Perform the group radar scan for this turn."
    end
    local jointMarker = airRadarMarker == surfaceRadarMarker
    if jointMarker then
        if radar.tileHasMarker(tile,tribe) and radar.isMarkerVisible(tile,tribe) then
            menuTable[3] = "Hide radar marker."
        end
        if radar.tileHasMarker(tile,tribe) and not radar.isMarkerVisible(tile,tribe) then
            menuTable[4] = "Show radar marker."
        end
        if radar.tileHasMarker(tile,tribe) then
            menuTable[5] = "Remove radar marker."
        end
        menuTable[6] = "Hide all radar markers."
        menuTable[7] = "Show all radar markers."
        menuTable[8] = "Remove all radar markers."
    else
        if radar.tileHasAirMarker(tile,tribe) and radar.isAirMarkerVisible(tile,tribe) then
            menuTable[13] = "Hide radar air marker."
        end
        if radar.tileHasSurfaceMarker(tile,tribe) and radar.isSurfaceMarkerVisible(tile,tribe) then
            menuTable[14] = "Hide radar surface marker."
        end
        if radar.tileHasAirMarker(tile,tribe) and not radar.isAirMarkerVisible(tile,tribe) then
            menuTable[15] = "Show radar air marker."
        end
        if radar.tileHasSurfaceMarker(tile,tribe) and radar.isSurfaceMarkerVisible(tile,tribe) then
            menuTable[16] = "Show radar surface marker."
        end
        menuTable[17] = "Hide all radar air markers."
        menuTable[18] = "Hide all radar surface markers."
        menuTable[19] = "Show all radar markers, with air priority."
        menuTable[20] = "Show all radar markers, with surface priority."
        menuTable[21] = "Remove all radar markers."
    end
    local choice = text.menu(menuTable,"","Radar Options")
    if choice == 1 then
        return
    elseif choice == 2 then
        flag.setFalse("noGroupScanThisTurn","radarSettings")
        local scannedTiles = groupScanFunction(civ.getCurrentTribe())
        if not scannedTiles then
            return
        end
        local numberScannedTiles = #scannedTiles
        if numberScannedTiles == 0 then
            text.simple("There are no radar contacts.","Radar")
            return
        end
        for key,val in pairs(scannedTiles) do
            scannedTiles[key] = "("..text.coordinates(val)..")"
        end
        if numberScannedTiles == 1 then
            text.simple("Radar contact at "..scannedTiles[1]..".","Radar")
            return
        else
            text.simple("Radar contacts detected at these coordinates:\n^"..text.niceList(scannedTiles)..".","Radar")
            return
        end
        return
    elseif choice == 3 then
        radar.hideMarker(tile,tribe)
    elseif choice == 4 then
        radar.showMarker(tile,tribe)
    elseif choice == 5 then
        radar.clearMarkersOnTile(tile,tribe)
    elseif choice == 6 then
        radar.hideAllMarkers(tribe)
    elseif choice == 7 then
        radar.showAllMarkers(tribe)
    elseif choice == 8 then
        local secondMenuTable = {}
        local secondMenuText = "Are you sure you wish to remove all the radar markers?  You will not be able to restore them."
        secondMenuTable[1] = "No, don't remove the markers."
        secondMenuTable[2] = "Yes, I'm sure."
        local secondChoice = text.menu(secondMenuTable,secondMenuText,"Confirm")
        if secondChoice == 2 then
            radar.clearAllMarkers(tribe)
        end
    elseif choice == 13 then
        radar.hideAirMarker(tile,tribe)
    elseif choice == 14 then
        radar.hideSurfaceMarker(tile,tribe)
    elseif choice == 15 then
        radar.showAirMarker(tile,tribe)
    elseif choice == 16 then
        radar.showSurfaceMarker(tile,tribe)
    elseif choice == 17 then
        radar.hideAllAirMarkers(tribe)
    elseif choice == 18 then
        radar.hideAllSurfaceMarkers(tribe)
    elseif choice == 19 then
        radar.showAllMarkers(tribe,false)
    elseif choice == 20 then
        radar.showAllMarkers(tribe,true)
    elseif choice == 21 then
        local secondMenuTable = {}
        local secondMenuText = "Are you sure you wish to remove all the radar markers?  You will not be able to restore them."
        secondMenuTable[1] = "No, don't remove the markers."
        secondMenuTable[2] = "Yes, I'm sure."
        local secondChoice = text.menu(secondMenuTable,secondMenuText,"Confirm")
        if secondChoice == 2 then
            radar.clearAllMarkers(tribe)
        end
    end
end


        


function discreteEvents.onKeyPress(keyID)
    if keyID == keyboard.three then
        radarKey()
        return
    end
    local scannedTiles = keyPressFunction(keyID)
    -- this means no radar sweep took place
    if not scannedTiles then
        return
    end
    local numberScannedTiles = #scannedTiles
    if numberScannedTiles == 0 then
        text.simple("There are no radar contacts.","Radar")
        return
    end
    for key,val in pairs(scannedTiles) do
        scannedTiles[key] = "("..text.coordinates(val)..")"
    end
    if numberScannedTiles == 1 then
        text.simple("Radar contact at "..scannedTiles[1]..".","Radar")
        return
    else
        text.simple("Radar contacts detected at these coordinates:\n^"..text.niceList(scannedTiles)..".","Radar")
        return
    end
end

function discreteEvents.onTribeTurnEnd(turn,tribe)
    radar.clearAllMarkers(tribe)
end
return radarSettings
