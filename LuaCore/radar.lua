--
local versionNumber = 3
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
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


-- a radarStatsTable has the final statistics for a radar sweep
-- radarStatsTable = {
--      alwaysDetectThreshold = number
--          for a return signal (S) above this, the radar station will always detect
--      neverDetectThreshold = number
--          for a return signal (S) below this, the radar station will never detect
--      maxSurfaceRange = integer
--          radar won't detect a surface unit on tile beyond this many squares away, even
--          if the cross section makes it detectable
--      maxAirRange = integer
--          radar won't detect an air unit on a tile beyond this many squares away, even
--          if the cross section makes it detectable
--      accuracyRating = 0-1 or true
--          if true, radar reveals the units on the tile (sets the visibility,
--          the game determines the unit actually visible)
--          if number, that is the chance that the radar places the marker on the correct tile
--      map0 = bool or radarStatsTable
--      map1 = bool or radarStatsTable
--      map2 = bool or radarStatsTable
--      map3 = bool or radarStatsTable
--          if true, radar detects on relevant map
--          if false or nil, it does not
--          if radarStatsTable, radar detects on map, but uses
--          numbers from that table instead of the main one
--          (these radarStatsTables don't need the mapX keys)
--          any absent keys default to keys in the main radarStatsTable
--



local gen = require("generalLibrary"):minVersion(1)
local text = require("text")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
---@module "data"
local data = require("data"):minVersion(2)

local radar = {}
gen.versionFunctions(radar,versionNumber,fileModified,"LuaCore".."\\".."radar.lua")

local radarMarkerAir = "radar marker not set.  Use radar.setMarkers"
local radarMarkerSurface = "radar marker not set.  Use radar.setMarkers"

-- radar.setMarkers(airMarker,surfaceMarker)
-- Sets the radar markers, with possible distinction for air and surface
--  Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
--  Note: air and surface markers don't HAVE to correspond to air and ground/sea units, they just
--  have different cross section functions

function radar.setMarkers(airMarker,surfaceMarker)
    if not gen.markerOptions[airMarker] then
        error("radar.setMarkers: The argument "..tostring(airMarker).." is not a valid marker name.  "
        ..gen.validMarkerOptionsList)
    end
    if not gen.markerOptions[surfaceMarker] then
        error("radar.setMarkers: The argument "..tostring(surfaceMarker).." is not a valid marker name.  "
        ..gen.validMarkerOptionsList)
    end
    radarMarkerAir = airMarker
    radarMarkerSurface = surfaceMarker
end

-- placeRadarMark(intruderTile,markerType,accuracy,scanningTribe,
--                  sourceTile,maxDistance) -> markedTile
--  places a radar mark for the intruderTile, and returns the tile that was marked
--  if accuracy is true (the boolean), the unit stack on intruderTile is revealed instead
--  otherwise, accuracy is a number in (0,1]
--  if the accuracy calculation would place a radar marker outside the maximum distance
--  the radar can detect, that tile is excluded from the options

local function placeRadarMark(intruderTile,markerType,accuracy,scanningTribe,sourceTile,maxDistance)
    if accuracy == true then
        gen.revealUnitStack(intruderTile,scanningTribe)
        return
    end
    local distanceFromTile = math.random()//accuracy 
    -- example: if accuracy =0.4, 
    -- 0-0.4 -> distanceFromTile=0 40%
    -- 0.4-0.8 -> distanceFromTile = 1 40%
    -- 0.8-1 -> distanceFromTile = 2 20%
    local eligibleTiles = gen.getTilesInRadius(intruderTile,distanceFromTile,distanceFromTile)
    for i,tile in pairs(eligibleTiles) do
        if tile.city or tile.defender == scanningTribe or (gen.tileDist(sourceTile,tile) > maxDistance) then
            -- don't place a marker on a city, or on a tile occupied by the scanning tribe
            -- or a tile the radar station can't scan anyway
            eligibleTiles[i] = nil
        end
    end
    gen.clearGapsInArray(eligibleTiles)
    local numberOfEligibleTiles = #eligibleTiles
    if #eligibleTiles == 0 then
        -- no eligible tiles in entire ring, so use the intruder tile, which should always be available
        gen.placeMarker(intruderTile,scanningTribe,markerType)
        return intruderTile
    end
    local chosenTile = eligibleTiles[math.random(1,#eligibleTiles)]
    gen.placeMarker(chosenTile,scanningTribe,markerType)
    return chosenTile
end


-- radar.sweep(sourceTile, radarStats, radarOwner, 
--              tileAirCrossSectionFn,tileSurfaceCrossSectionFn) --> table of marked tiles
--  sourceTile = tileObject
--      centre of the radar sweep
--  radarStats = radarStatsTable
--  radarOwner = tribeObject
--  tileAirCrossSectionFn(tile) --> number
--      converts a tile to a cross section number, for the "air" units on the tile
--      (this is just a category, some other separation can be used by changing
--      the function appropriately)
--      based on the units on the tile.        
--  tileSurfaceCrossSectionFn(tile) --> number
--      converts a tile to a cross section number, for the "air" units on the tile
--      (this is just a category, some other separation can be used by changing
--      the function appropriately)
--      based on the units on the tile.        



function radar.sweep(sourceTile, radarStats, radarOwner,
                    tileAirCrossSectionFn, tileSurfaceCrossSectionFn)
    local _,_,maps = civ.getAtlasDimensions()
    local mapStats = {}
    for i=0,maps-1 do
        local mapKey = "map"..tostring(i)
        if type(radarStats[mapKey]) == "table" then
            mapStats[i] = radarStats[mapKey]
        elseif radarStats[mapKey] then
            mapStats[i] = radarStats
        end
    end
    local function signalDetected(crossSection,distance,sAlways,sNever)
        local signal = crossSection/(distance*distance*distance*distance)
        if signal <= sNever then
            return false
        elseif signal >= sAlways then
            return true
        else
            return math.random()*(sAlways-sNever) < signal - sNever
        end
    end
    local detectionTiles = {}
    for i=0,maps-1 do
        if mapStats[i] then
        
            local surfaceMax = mapStats[i].maxSurfaceRange or radarStats.maxSurfaceRange
            local airMax = mapStats[i].maxAirRange or radarStats.maxAirRange
            local accuracy = mapStats[i].accuracyRating or radarStats.accuracyRating
            local alwaysDetect = mapStats[i].alwaysDetectThreshold or radarStats.alwaysDetectThreshold
            local neverDetect = mapStats[i].neverDetectThreshold or radarStats.neverDetectThreshold
            local tiles = gen.getTilesInRadius(sourceTile,math.max(surfaceMax,airMax),0,i)
            for _,tile in pairs(tiles) do
                if not tile.city and tile.defender and tile.defender ~= radarOwner then
                    local distance = gen.tileDist(tile,sourceTile)
                    if distance <= surfaceMax then
                        local crossSection = tileSurfaceCrossSectionFn(tile)
                        if signalDetected(crossSection,distance,alwaysDetect,neverDetect) then
                            local markedTile = placeRadarMark(tile,radarMarkerSurface,accuracy,
                            radarOwner,sourceTile,surfaceMax)
                            detectionTiles[gen.getTileId(markedTile)] = true
                        end
                    end
                    if distance <= airMax then
                        local crossSection = tileAirCrossSectionFn(tile)
                        if signalDetected(crossSection,distance,alwaysDetect,neverDetect) then
                            local markedTile = placeRadarMark(tile,radarMarkerAir,accuracy,
                            radarOwner,sourceTile,airMax)
                            detectionTiles[gen.getTileId(markedTile)] = true
                        end
                    end
                end
            end
        end
    end
    local markedTiles = {}
    local markedIndex = 1
    for tileID,_ in pairs(detectionTiles) do
        markedTiles[markedIndex] = gen.getTileFromId(tileID)
        markedIndex = markedIndex+1
    end
    return markedTiles
end

-- radar.clearAllMarkers(tribe=nil)
-- clears all radar markers for the tribe
-- if no tribe is selected, all markers are cleared
function radar.clearAllMarkers(tribe)
    if radarMarkerSurface ~= radarMarkerSurface then
        gen.removeAllMarkers(tribe,radarMarkerSurface)
        gen.removeAllMarkers(tribe,radarMarkerAir)
    else
        gen.removeAllMarkers(tribe.radarMarkerAir)
    end
end

-- radar.showMarker(tile,tribe,surfaceTop=false)
function radar.showMarker(tile,tribe,surfaceTop)
    if surfaceTop then
        gen.showMarker(tile,tribe,radarMarkerAir)
        gen.showMarker(tile,tribe,radarMarkerSurface)
    else
        gen.showMarker(tile,tribe,radarMarkerSurface)
        gen.showMarker(tile,tribe,radarMarkerAir)
    end
end


-- radar.showAirMarker(tile,tribe)
function radar.showAirMarker(tile,tribe)
        gen.showMarker(tile,tribe,radarMarkerAir)
end


-- radar.showSurfaceMarker(tile,tribe)
function radar.showSurfaceMarker(tile,tribe)
        gen.showMarker(tile,tribe,radarMarkerSurface)
end




-- radar.showAllMarkers(tribe,surfaceTop)
--  makes all markers visible for all players,
--  with the radar marks applied last
--  if surfaceTop is true, then the surface radar marker is applied
--  last, and will be visible if it conflicts with the air marker
--  (though both markers will still be on top of all other markers)
--  if false or nil, the air marker is applied last
function radar.showAllMarkers(tribe,surfaceTop)
    if radarMarkerAir == radarMarkerSurface then
        gen.showMarkerOnAllTiles(tribe,radarMarkerAir)
    elseif surfaceTop then
        gen.showMarkerOnAllTiles(tribe,radarMarkerAir)
        gen.showMarkerOnAllTiles(tribe,radarMarkerSurface)
    else
        gen.showMarkerOnAllTiles(tribe,radarMarkerSurface)
        gen.showMarkerOnAllTiles(tribe,radarMarkerAir)
    end
end

-- radar.clearMarkersOnTile(tile,tribe=nil)
-- clears the radar marker(s) on the tile for the tribe
-- if no tribe is selected, all radar markers are cleared
function radar.clearMarkersOnTile(tile,tribe)
    if tribe then
        gen.removeMarker(tile,tribe,radarMarkerAir)
        gen.removeMarker(tile,tribe,radarMarkerSurface)
        return
    else
        for i=0,7 do
            if civ.getTribe(i) then
                gen.removeMarker(tile,civ.getTribe(i),radarMarkerAir)
                gen.removeMarker(tile,civ.getTribe(i),radarMarkerSurface)
            end
        end
        return
    end
end

-- radar.tileHasMarker(tile,tribe)
-- returns true if tile has a radar marker (either surface or air), and false otherwise
function radar.tileHasMarker(tile,tribe)
    return gen.hasMarker(tile,tribe,radarMarkerAir) or gen.hasMarker(tile,tribe,radarMarkerSurface)
end

-- radar.tileHasSurfaceMarker(tile,tribe)
-- returns true if the tile has a surface marker, and false otherwise
-- note: this will return true if an air unit was detected, but air and surface markers are the same
function radar.tileHasSurfaceMarker(tile,tribe)
    return gen.hasMarker(tile,tribe,radarMarkerSurface)
end

-- radar.tileHasAirMarker(tile,tribe)
-- returns true if the tile has an air marker, and false otherwise
-- note: this will return true if a surface unit was detected, but air and surface markers are the same
function radar.tileHasAirMarker(tile,tribe)
    return gen.hasMarker(tile,tribe,radarMarkerAir)
end

-- radar.isMarkerVisible(tile,tribe)
-- returns true if a radar marker( either surface or air) is currently visible on the tile, false othrewise
function radar.isMarkerVisible(tile,tribe)
    return gen.isMarkerVisible(tile,tribe,radarMarkerAir) or gen.isMarkerVisible(tile,tribe,radarMarkerSurface)
end

-- radar.isSurfaceMarkerVisible(tile,tribe)
-- returns true if the surface marker exists and is visible, and false otherwise
-- note: this will return true if an air unit was detected, but air and surface share the same marker
function radar.isSurfaceMarkerVisible(tile,tribe)
    return gen.isMarkerVisible(tile,tribe,radarMarkerSurface)
end

-- radar.isAirMarkerVisible(tile,tribe)
-- returns true if the air marker exists and is visible, and false otherwise
-- note: this will return true if a surface unit was detected, but air and surface share the same marker
function radar.isAirMarkerVisible(tile,tribe)
    return gen.isMarkerVisible(tile,tribe,radarMarkerAir)
end

-- radar.hideAirMarker(tile,tribe)
-- hides the air radar marker if it is visible (and exists)
-- if a surface detection was made, and air and surface share the same marker, the marker is hidden
function radar.hideAirMarker(tile,tribe)
    gen.hideMarker(tile,tribe,radarMarkerAir)
end

-- radar.hideSurfaceMarker(tile,tribe)
-- hides the surface radar marker if it is visible (and exists)
-- if an air detection was made, and air and surface share the same marker, the marker is hidden
function radar.hideSurfaceMarker(tile,tribe)
    gen.hideMarker(tile,tribe,radarMarkerSurface)
end

-- radar.hideMarker(tile,tribe)
-- hides, but does not remove, all radar markers on the tile
function radar.hideMarker(tile,tribe)
    gen.hideMarker(tile,tribe,radarMarkerAir)
    gen.hideMarker(tile,tribe,radarMarkerSurface)
end

-- radar.hideAllAirMarkers(tribeOrNil)
function radar.hideAllAirMarkers(tribeOrNil)
    gen.hideAllMarkers(tribeOrNil,radarMarkerAir)
end
-- radar.hideAllSurfaceMarkers(tribeOrNil)
function radar.hideAllSurfaceMarkers(tribeOrNil)
    gen.hideAllMarkers(tribeOrNil,radarMarkerSurface)
end
-- radar.hideAllMarkers(tribeOrNil)
function radar.hideAllMarkers(tribeOrNil)
    if radarMarkerSurface == radarMarkerAir then
        gen.hideAllMarkers(tribeOrNil,radarMarkerSurface)
    else
        gen.hideAllMarkers(tribeOrNil,radarMarkerSurface)
        gen.hideAllMarkers(tribeOrNil,radarMarkerAir)
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
-- helper function for radar.calibrate
local function updateCalibration(calibrationSoFar,calibrationModifier)
    if calibrationModifier.crossSection then
        calibrationSoFar.crossSection = calibrationSoFar.crossSection - calibrationModifier.crossSection
    end
    if calibrationModifier.range then
        calibrationSoFar.range = calibrationSoFar.range + calibrationModifier.range
    end
    if calibrationModifier.unreliableDetectionFactor then
        calibrationSoFar.unreliableDetectionFactor = calibrationSoFar.unreliableDetectionFactor - calibrationModifier.unreliableDetectionFactor
    end
    if calibrationModifier.accuracy and type(calibrationSoFar.accuracy) == "number" then
        if calibrationModifier.accuracy == true then
            calibrationSoFar.accuracy = true
        else
            calibrationSoFar.accuracy = calibrationSoFar.accuracy + calibrationModifier.accuracy
        end
    end
    if calibrationModifier.maxSurfaceRange then
        calibrationSoFar.maxSurfaceRange = calibrationSoFar.maxSurfaceRange + calibrationModifier.maxSurfaceRange
    end
    if calibrationModifier.maxAirRange then
        calibrationSoFar.maxAirRange = calibrationSoFar.maxAirRange + calibrationModifier.maxAirRange
    end
end

-- transforms a radarCalibration into a table with these keys:
--      alwaysDetectThreshold = number
--          for a return signal (S) above this, the radar station will always detect
--      neverDetectThreshold = number
--          for a return signal (S) below this, the radar station will never detect
--      maxSurfaceRange = integer
--          radar won't detect a surface unit on tile beyond this many squares away, even
--          if the cross section makes it detectable
--      maxAirRange = integer
--          radar won't detect an air unit on a tile beyond this many squares away, even
--          if the cross section makes it detectable
--      accuracyRating = 0.1-1 or true
--          if true, radar reveals the units on the tile (sets the visibility,
--          the game determines the unit actually visible)
--          if number, that is the chance that the radar places the marker on the correct tile
function radar.calibrate(radarCalibration,scanningTribe)
    local calibrationSoFar = {
        crossSection = radarCalibration.crossSection,
        range = radarCalibration.range,
        unreliableDetectionFactor = radarCalibration.unreliableDetectionFactor,
        accuracy = radarCalibration.accuracy,
        maxSurfaceRange = radarCalibration.maxSurfaceRange,
        maxAirRange = radarCalibration.maxAirRange,
    }
    if radarCalibration.tribeModifier and radarCalibration.tribeModifier[scanningTribe.id] then
        updateCalibration(calibrationSoFar, radarCalibration.tribeModifier[scanningTribe.id])
    end
    if radarCalibration.techModifier then
        for techID,calibModifier in pairs(radarCalibration.techModifier) do
            if scanningTribe:hasTech(civ.getTech(techID)) then
                updateCalibration(calibrationSoFar,calibModifier)
            end
        end
    end
    if radarCalibration.flagModifier then
        for flagKey, calibModifier in pairs(radarCalibration.flagModifier) do
            if data.flagGetValue(flagKey) then
                updateCalibration(calibrationSoFar,calibModifier)
            end
        end
    end
    local radarStats = {}
    radarStats.alwaysDetectThreshold = calibrationSoFar.crossSection/(calibrationSoFar.range^4)
    radarStats.neverDetectThreshold = radarStats.alwaysDetectThreshold*calibrationSoFar.unreliableDetectionFactor
    radarStats.maxSurfaceRange = calibrationSoFar.maxSurfaceRange
    radarStats.maxAirRange = calibrationSoFar.maxAirRange
    if type(calibrationSoFar.accuracy) == true then
        radarStats.accuracyRating = true
    else
        radarStats.accuracyRating = math.min(1,math.max(0.1,calibrationSoFar.accuracy))
    end
    return radarStats
end

-- radar.makeRadarStats(radarInfo,tile,tribe)
--  takes an entry from the radarTable, a tile, and a tribe,
--  and produces a "radarStats" table for use with radar.sweep

function radar.makeRadarStats(radarInfo,scanTile,scanTribe)
    if radarInfo.sameMapScan then
        local radarStats = radar.calibrate(radarInfo.sameMapScan,scanTribe)
        radarStats.map0 = false
        radarStats.map1 = false
        radarStats.map2 = false
        radarStats.map3 = false
        radarStats["map"..tostring(scanTile.z)] = true
        return radarStats
    end
    if radarInfo.allMapScan then
        local radarStats = radar.calibrate(radarInfo.allMapScan,scanTribe)
        radarStats.map0 = true
        radarStats.map1 = true
        radarStats.map2 = true
        radarStats.map3 = true
        return radarStats
    end
    local radarStats = {alwaysDetectThreshold = math.huge,
                        neverDetectThreshold = math.huge,
                        maxSurfaceRange = 0,
                        maxAirRange = 0,
                        accuracyRating = 0.1,
                    }
    for scanMap = 0,3 do
        local scanMapStr = tostring(scanMap)
        local fromMapStr = tostring(scanTile.z)
        if radarInfo["scanMap"..scanMapStr.."From"..fromMapStr] then
---@diagnostic disable-next-line: assign-type-mismatch
            radarStats["map"..scanMapStr] = radar.calibrate(radarInfo["scanMap"..scanMapStr.."From"..fromMapStr])
        else
---@diagnostic disable-next-line: assign-type-mismatch
            radarStats["map"..scanMapStr] = false
        end
    end
    return radarStats
end

-- calibrationModifierTable[key] = valueValidationFn(value,infoString) --> true or error
--      if key is a valid key for a calibrationModifier, the function checks if
--      the value is valid, and returns an error if it is not.
--      infoString is some extra information about where the error is
local calibrationModifierTable = {}
calibrationModifierTable["crossSection"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid calibrationModifier table ("..infoString..") key: 'crossSection', value: "..tostring(value)..".  Value must be a number or nil.") 
    end
    return true
end

calibrationModifierTable["range"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid calibrationModifier table ("..infoString..") key: 'range', value: "..tostring(value)..".  Value must be a number or nil.") 
    end
    return true
end

calibrationModifierTable["unreliableDetectionFactor"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid calibrationModifier table ("..infoString..") key: 'unreliableDetectionFactor', value: "..tostring(value)..".  Value must be a number or nil.") 
    end
    return true
end

calibrationModifierTable["accuracy"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" and value ~= true then
        error("invalid calibrationModifier table ("..infoString..") key: 'accuracy', value: "..tostring(value)..".  Value must be a number, nil, or true.") 
    end
    return true
end

calibrationModifierTable["maxSurfaceRange"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid calibrationModifier table ("..infoString..") key: 'maxSurfaceRange', value: "..tostring(value)..".  Value must be a number, or nil.") 
    end
    return true
end

calibrationModifierTable["maxAirRange"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid calibrationModifier table ("..infoString..") key: 'maxAirRange', value: "..tostring(value)..".  Value must be a number, or nil.") 
    end
    return true
end

local function validateCalibrationModifier(calibMod,infoString)
    for key,value in pairs(calibMod) do
        if calibrationModifierTable[key] then
            calibrationModifierTable[key](value,infoString)
        else
            error("invalid calibrationModifier table ("..infoString..") key: '"..key.."' is not a valid key for a calibrationModifier table.")
        end
    end
end

local function numberWithin(low,high,number)
    return type(number) == "number" and number >= low and number <= high
end


-- calibrationKeyValidation[key] = function(value,infoString) --> true or error
--      returns true if the value corresponding to key is valid, otherwise throws error
local calibrationKeyValidation = {}
calibrationKeyValidation["crossSection"] = function(value,infoString)
    if type(value) ~= "number" then
        error("invalid radarCalibration table ("..infoString.." key: 'crossSection', value: "..tostring(value)..".  Value must be a number.")
    end
    return true
end

calibrationKeyValidation["range"] = function(value,infoString)
    if type(value) ~= "number" then
        error("invalid radarCalibration table ("..infoString.." key: 'range', value: "..tostring(value)..".  Value must be a number.")
    end
    return true
end

calibrationKeyValidation["unreliableDetectionFactor"] = function(value,infoString)
    if not numberWithin(0,1,value) then
        error("invalid radarCalibration table ("..infoString.." key: 'unreliableDetectionFactor', value: "..tostring(value)..".  Value must be a number between 0 and 1.")
    end
    return true
end

calibrationKeyValidation["accuracy"] = function(value,infoString)
    if value ~= true and not numberWithin(0.1,1,value) then
        error("invalid radarCalibration table ("..infoString.." key: 'accuracy', value: "..tostring(value)..".  Value must be a number between 0.1 and 1, or true.")
    end
    return true
end

calibrationKeyValidation["maxSurfaceRange"] = function(value,infoString)
    if type(value) ~= "number" then
        error("invalid radarCalibration table ("..infoString.." key: 'maxSurfaceRange', value: "..tostring(value)..".  Value must be a number.")
    end
    return true
end

calibrationKeyValidation["maxAirRange"] = function(value,infoString)
    if type(value) ~= "number" then
        error("invalid radarCalibration table ("..infoString.." key: 'maxAirRange', value: "..tostring(value)..".  Value must be a number.")
    end
    return true
end

calibrationKeyValidation["tribeModifier"] = function(value,infoString)
    if type(value) ~= "table" and type(value) ~= "nil" then
        error("Invalid radarCalibration table ("..infoString.." key: tribeModifier, value: "..tostring(value)..".  Value must be a table or nil.")
    end
    for tribeID, calibMod in pairs((value or {})) do
        validateCalibrationModifier(calibMod,infoString..">tribeModifier")
    end
    return true
end
calibrationKeyValidation["techModifier"] = function(value,infoString)
    if type(value) ~= "table" and type(value) ~= "nil" then
        error("Invalid radarCalibration table ("..infoString.." key: techModifier, value: "..tostring(value)..".  Value must be a table or nil.")
    end
    for techID, calibMod in pairs((value or {})) do
        validateCalibrationModifier(calibMod,infoString..">techModifier")
    end
    return true
end
calibrationKeyValidation["flagModifier"] = function(value,infoString)
    if type(value) ~= "table" and type(value) ~= "nil" then
        error("Invalid radarCalibration table ("..infoString.." key: flagModifier, value: "..tostring(value)..".  Value must be a table or nil.")
    end
    for flagKey, calibMod in pairs((value or {})) do
        validateCalibrationModifier(calibMod,infoString..">flagModifier")
    end
    return true
end

local mandatoryCalibrationKeys = {
"crossSection",
"range",
"unreliableDetectionFactor",
"accuracy",
"maxSurfaceRange",
"maxAirRange",
}

local function validateRadarCalibration(radCalib,infoString)
    for _,reqKey in pairs(mandatoryCalibrationKeys) do
        if not radCalib[reqKey] then
            error("invalid radarCalibration table ("..infoString..") key "..reqKey.." is missing.")
        end
    end
    for key,value in pairs(radCalib) do
        if calibrationKeyValidation[key] then
            calibrationKeyValidation[key](value,infoString)
        else
            error("invalid radarCalibration table ("..infoString..") key: '"..key.."' is not a valid key for a radarCalibration table.")
        end
    end
end

local function verifyList(table,checkFn,infoString,itemName)
    for key,value in pairs(table) do
        if not checkFn(value) then
            error(infoString.." is not a table of "..itemName..".  The key: "..tostring(key).." has a value of "..tostring(value)..")")
        end
    end
    return true
end

local function isTileEquivalent(value)
    local input = value
    if civ.isTile(input) then
        if civ.getTile(input.x,input.y,input.z) then
            return true
        else
            return false
        end
    elseif type(input) == "table" then
        local xVal = input[1] or input["x"]
        local yVal = input[2] or input["y"]
        local zVal = input[3] or input["z"] or 0
        if type(xVal)=="number" and type(yVal)=="number" and type(zVal)=="number" then
            if civ.getTile(xVal,yVal,zVal) then
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end
    

local radarInfoValidation = {}
radarInfoValidation["station"] = function(value,infoString)
    if civ.isUnitType(value) or civ.isImprovement(value)
        or value == "city" or civ.isTile(value) then
        return true
    end
    if type(value) == "table" then
        verifyList(value,isTileEquivalent,infoString..">station","tile")
        return true
    end
    error("invalid radar data table ("..infoString..") key: 'station' must be a unitType, improvementType, string with value \"city\", tile, or table of tiles.  Instead received "..tostring(value))
end

radarInfoValidation["tribes"] = function(value,infoString)
    if civ.isTribe(value) or type(value) == "nil" then
        return true
    end
    if type(value) =="table" then
        verifyList(value,civ.isTribe,infoString..">tribes","tribe")
        return true
    end
    error("invalid radar data table ("..infoString..") key: 'tribes' must be a tribe object, table of tribe objects, or nil.  Instead received "..tostring(value))
end

radarInfoValidation["flag"] = function(value,infoString)
    if type(value) ~= "string" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'flag' must be a string or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["tech"] = function(value,infoString)
    if type(value) ~= "table" and not civ.isTech(value) and type(value) ~= nil then
        error("invalid radar data table ("..infoString..") key: 'tech' must be a tech object, table of tech objects, or nil.  Received "..tostring(value))
    end
    if type(value) == "table" then
        verifyList(value,civ.isTech,infoString,"tech object")
    end
    return true
end

radarInfoValidation["techNumber"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'techNumber' must be a number or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["moveCost"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'moveCost' must be a number or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["moneyCost"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'moneyCost' must be a number or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["scanEffectFn"] = function(value,infoString)
    if type(value) ~= "function" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'scanEffectFn' must be a function or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["canScanFn"] = function(value,infoString)
    if type(value) ~= "function" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'canScanFn' must be a function or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["scanKey"] = function(value,infoString)
    if type(value) ~= "number" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'scanKey' must be a number or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["groupScan"] = function(value,infoString)
    if type(value) ~= "boolean" and type(value) ~= "nil" then
        error("invalid radar data table ("..infoString..") key: 'groupScan' must be a boolean or nil.  Received "..tostring(value))
    end
    return true
end

radarInfoValidation["sameMapScan"] = function(value,infoString)
    if type(value) ~= "nil" then
        validateRadarCalibration(value,infoString..">sameMapScan")
    end
    return true
end

radarInfoValidation["allMapScan"] = function(value,infoString)
    if type(value) ~= "nil" then
        validateRadarCalibration(value,infoString..">allMapScan")
    end
    return true
end

for X = 0,3 do
    for Y = 0,3 do
        local key = "scanMap"..tostring(X).."From"..tostring(Y)
        radarInfoValidation[key] = function(value,infoString)
            if type(value) ~= "nil" then
                validateRadarCalibration(value,infoString..">"..key)
            end
            return true
        end
    end
end

radarInfoValidation["secretTileTable"] = function(value,infoString)
    if type(value) == "table" or type(value) == "nil" then
        return true
    else
        error("something went wrong in post processing ("..infoString..") the scecretTileTable is not a talbe or nil.  Received: "..tostring(value))
    end
end

function radar.postProcessRadarData(radarData)
    if type(radarData.station) == "table" or civ.isTile(radarData.station) then
        local tileTable = radarData.station
        if civ.isTile(tileTable) then
            tileTable = {tileTable}
        end
        radarData.secretTileTable = {}
        for _,tile in pairs(tileTable) do
            radarData.secretTileTable[gen.getTileID(gen.toTile(tile))] = true
        end
    end
end



-- radar.validateRadarData(radarData,infoString) --> void or error
--  throws an error if the radar data table is invalid
function radar.validateRadarData(radarData,infoString)
    if not radarData.station then
        error("invalid radar data ("..infoString..").  Key: station must not be nil.")
    end
    for key,value in pairs(radarData) do
        if radarInfoValidation[key] then
            radarInfoValidation[key](value,infoString)
        else
            error("invalid radar data ("..infoString.."). Key: "..tostring(key).." is not a valid key for radar data.")
        end
    end
end

local function addToTable(newItem,table)
    table[#table+1] = newItem
end


function radar.stationCanScan(radarData,unitOrTile,tribe)
    if civ.isUnitType(radarData.station) then
        if unitOrTile.type ~= radarData.station then
            return false
        end
        if radarData.canScanFn and not radarData.canScanFn(unitOrTile) then
            return false
        end
    end
    if radarData.station == "city" then
        if (not unitOrTile.city or unitOrTile.city.owner ~= tribe) then
            return false
        end
        if radarData.canScanFn and not radarData.canScanFn(unitOrTile.city) then
            return false
        end
    end
    if civ.isImprovement(radarData.station) then
        if not unitOrTile.city then
            return false
        elseif unitOrTile.city.owner ~= tribe then
            return false
        elseif not unitOrTile.city:hasImprovement(radarData.station) then
            return false
        end
        if radarData.canScanFn and not radarData.canScanFn(unitOrTile.city) then
            return false
        end
    end
    if civ.isTile(radarData.station) or type(radarData.station) == "table" then
        if not radarData.secretTileTable[gen.getTileID(unitOrTile)] then
            return false
        end
        if radarData.canScanFn and not radarData.canScanFn(unitOrTile) then
            return false
        end
    end
    if radarData.tribes and not gen.inTable(tribe,radarData.tribes) then
        return false
    end
    if radarData.flag and not data.flagGetValue(radarData.flag) then
        return false
    end
    if radarData.tech then
        local techTable = radarData.tech
        if civ.isTech(techTable) then
            techTable = {techTable}
        end
        local techNumber = radarData.techNumber or #techTable
        local ownedTechs = 0
        for _,tech in pairs(techTable) do
            if tribe:hasTech(tech) then
                ownedTechs = ownedTechs +1
            end
        end
        if ownedTechs < techNumber then
            return false
        end
    end
    return true
end

local function trackContactTiles(existingTable,newTiles)
    existingTable.noRadarSweep = nil -- this way, we can tell if no sweep ever happens
    for _,tile in pairs(newTiles) do
        existingTable[gen.getTileID(tile)] = true
    end
end

local function makeContactTilesList(existingTable)
    if existingTable.noRadarSweep then
        return nil
    end
    local listTable =  {}
    local index = 1
    for tileID,_ in pairs(existingTable) do
        listTable[index] = gen.getTileFromId(tileID)
        index = index+1
    end
    return listTable
end
        

function radar.buildKeyPressAndGroupScanFunctions(radarTable,airCrossSectionFn,surfaceCrossSectionFn)
    -- eligibleScanKeys[scanKeyID] = true
    -- table catalogues keyIDs that are used for scanning
    local eligibleScanKeys = {}
    -- unitScanTable[scanKeyID][unit.type.id] = table of radarData
    -- this is checked if there is an active unit when the key is pressed
    -- the table is of all radarData corresponding to that unit type (and scanKey)
    local unitScanTable = {}
    -- cityScanTable[scanKeyID] = table of radarData
    -- this is checked if there is no active unit, and the current tile is a city
    -- table is of all stations of improvementObject or "city" (and scanKey)
    local cityScanTable = {}
    -- tileScanTable[scanKeyID][tileID] = table of radarData
    -- this is checked if there is no active unit
    -- table is of all stations that include the tile with tileID (and scanKey)
    local tileScanTable = {}

    -- tables for group scan data
    -- groupScanUnit[unit.type.id] = table of radarData
    local groupScanUnit = {}
    -- groupScanCity = table of radarData
    local groupScanCity = {}
    -- groupScanTile[tileID] = table of radarData
    local groupScanTile = {}

    for key,radarData in pairs(radarTable) do
        radar.validateRadarData(radarData,key)
        radar.postProcessRadarData(radarData)
        if radarData.scanKey then
            local scanKeyID = radarData.scanKey
            eligibleScanKeys[scanKeyID] = true
            if civ.isUnitType(radarData.station) then
                unitScanTable[scanKeyID] = unitScanTable[scanKeyID] or {}
                unitScanTable[scanKeyID][radarData.station.id] =unitScanTable[scanKeyID][radarData.station.id] or {} 
                addToTable(radarData,unitScanTable[scanKeyID][radarData.station.id])
            end
            if civ.isImprovement(radarData.station) or radarData.station == "city" then
                cityScanTable[scanKeyID] = cityScanTable[scanKeyID] or {}
                addToTable(radarData,cityScanTable[scanKeyID])
            end
            if civ.isTile(radarData.station) or type(radarData.station) == "table" then
                local tileTable = radarData.station
                if civ.isTile(tileTable) then
                    tileTable = {tileTable}
                end
                tileScanTable[scanKeyID] = tileScanTable[scanKeyID] or {}
                for _,tile in pairs(tileTable) do
                    local tileID = gen.getTileID(gen.toTile(tile))
                    tileScanTable[scanKeyID][tileID] = tileScanTable[scanKeyID][tileID] or {}
                    addToTable(radarData,tileScanTable[scanKeyID][tileID])
                end
            end
        end
        if radarData.groupScan then
            if civ.isUnitType(radarData.station) then
                groupScanUnit[radarData.station.id] = groupScanUnit[radarData.station.id] or {}
                addToTable(radarData,groupScanUnit[radarData.station.id])
            elseif civ.isImprovement(radarData.station) or radarData.station == "city" then
                addToTable(radarData,groupScanCity)
            elseif civ.isTile(radarData.station) or type(radarData.station) == "table" then
                local tileTable = radarData.station
                if civ.isTile(tileTable) then
                    tileTable = {tileTable}
                end
                for _,tile in pairs(tileTable) do
                    local tileID = gen.getTileID(gen.toTile(tile))
                    groupScanTile[tileID] = groupScanTile[tileID] or {}
                    addToTable(radarData,groupScanTile[tileID])
                end
            end
        end
    end

    -- keyPressFn(keyID) --> table of tiles or nil
    -- if a radar scan happens, a table of tiles (possibly empty) where markers
    -- are placed is returned
    -- if no radar scan happens, nil is returned
    local function keyPressFn(keyID)
        if not eligibleScanKeys[keyID] then
            return nil
        end
        local scanKeyID = keyID
        local contactTiles = {["noRadarSweep"] = true}
        if civ.getActiveUnit() then
            local activeUnit = civ.getActiveUnit()
            if not unitScanTable[scanKeyID] then
                return nil
            elseif not unitScanTable[scanKeyID][activeUnit.type.id] then
                return nil
            end
            local scanTile = activeUnit.location
            local scanTribe = activeUnit.owner
            for _,radarData in pairs(unitScanTable[scanKeyID][activeUnit.type.id]) do
                if radar.stationCanScan(radarData,activeUnit,scanTribe) then
                    local newContacts = radar.sweep(scanTile,radar.makeRadarStats(radarData,scanTile,scanTribe),
                        scanTribe,airCrossSectionFn,surfaceCrossSectionFn)
                    trackContactTiles(contactTiles,newContacts)
                    if radarData.scanEffectFn then
                        radarData.scanEffectFn(activeUnit)
                    end
                    if radarData.moneyCost then
                        scanTribe.money = math.max(0,scanTribe.money - radarData.moneyCost)
                    end
                    if radarData.moveCost then
                        gen.spendMovementPoints(activeUnit,radarData.moveCost)
                    end
                end
            end
            return makeContactTilesList(contactTiles)
        else
            local scanTile = civ.getCurrentTile()
            local tileID = gen.getTileID(scanTile)
            local scanTribe = civ.getCurrentTribe()
            if scanTile.city and cityScanTable[scanKeyID] then
                for _,radarData in pairs(cityScanTable[scanKeyID]) do
                    if radar.stationCanScan(radarData,scanTile,scanTribe) then
                        local newTiles = radar.sweep(scanTile,radar.makeRadarStats(radarData,scanTile,scanTribe),
                            scanTribe,airCrossSectionFn,surfaceCrossSectionFn)
                        trackContactTiles(contactTiles,newTiles)
                        if radarData.scanEffectFn then
                            radarData.scanEffectFn(scanTile.city)
                        end
                        if radarData.moneyCost then
                            scanTribe.money = math.max(0,scanTribe.money - radarData.moneyCost)
                        end
                    end
                end
            end
            if tileScanTable[scanKeyID] and tileScanTable[scanKeyID][tileID] then
                for _,radarData in pairs(tileScanTable[scanKeyID][tileID]) do
                    if radar.stationCanScan(radarData,scanTile,scanTribe) then
                        local newTiles = radar.sweep(scanTile,radar.makeRadarStats(radarData,scanTile,scanTribe),
                            scanTribe,airCrossSectionFn,surfaceCrossSectionFn)
                        trackContactTiles(contactTiles,newTiles)
                        if radarData.moneyCost then
                            scanTribe.money = math.max(0,scanTribe.money - radarData.moneyCost)
                        end
                        if radarData.scanEffectFn then
                            radarData.scanEffectFn(scanTile.city)
                        end
                    end
                end
            end
            return makeContactTilesList(contactTiles)
        end
    end

    local function groupScanFn(scanTribe)
        local contactTiles = {["noRadarSweep"]=true}
        for unit in civ.iterateUnits() do
            if unit.owner == scanTribe and groupScanUnit[unit.type.id] then
                for _,radarData in pairs(groupScanUnit[unit.type.id]) do
                    if radar.stationCanScan(radarData,unit,scanTribe) then
                        local scanTile = unit.location
                        local newTiles = radar.sweep(scanTile,radar.makeRadarStats(radarData,scanTile,scanTribe),
                            scanTribe,airCrossSectionFn,surfaceCrossSectionFn)
                        trackContactTiles(contactTiles,newTiles)
                        if radarData.scanEffectFn then
                            radarData.scanEffectFn(unit)
                        end
                        if radarData.moveCost then
                            gen.spendMovementPoints(unit,radarData.moveCost)
                        end
                        if radarData.moneyCost then
                            scanTribe.money = math.max(0,scanTribe.money - radarData.moneyCost)
                        end
                    end
                end
            end
        end
        for city in civ.iterateCities() do
            if city.owner == scanTribe then
                for _,radarData in pairs(groupScanCity) do
                    local scanTile = city.location
                    if radar.stationCanScan(radarData,scanTile,scanTribe) then
                        local newTiles = radar.sweep(scanTile,radar.makeRadarStats(radarData,scanTile,scanTribe),
                            scanTribe,airCrossSectionFn,surfaceCrossSectionFn)
                        trackContactTiles(contactTiles,newTiles)
                        if radarData.scanEffectFn then
                            radarData.scanEffectFn(scanTile.city)
                        end
                        if radarData.moneyCost then
                            scanTribe.money = math.max(0,scanTribe.money - radarData.moneyCost)
                        end
                    end
                end
            end
        end
        for tileID,dataTable in pairs(groupScanTile) do
            local scanTile = gen.getTileFromID(tileID)
            for _,radarData in pairs(dataTable) do
                if radar.stationCanScan(radarData,scanTile,scanTribe) then
                    local newTiles = radar.sweep(scanTile,radar.makeRadarStats(radarData,scanTile,scanTribe),
                        scanTribe,airCrossSectionFn,surfaceCrossSectionFn)
                    trackContactTiles(contactTiles,newTiles)
                    if radarData.scanEffectFn then
                        radarData.scanEffectFn(scanTile.city)
                    end
                    if radarData.moneyCost then
                        scanTribe.money = math.max(0,scanTribe.money - radarData.moneyCost)
                    end
                end
            end
        end
        return makeContactTilesList(contactTiles)
    end

    return keyPressFn, groupScanFn
end



    


return radar
