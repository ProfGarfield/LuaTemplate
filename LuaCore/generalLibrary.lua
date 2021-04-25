-- The General Lua Library
-- This set of code is meant to provide basic functionality
-- in order to facilitate the writing of events and
-- other Civilization II Libraries

-- BRIEF DOCUMENTATION
-- More documentation about how these functions work can
-- be found at their definition.

-- Any function here that accepts a tile will also
-- accept a table {[1]=x,[2]=y,[3]=z}, a table 
-- {[1]=x,[2]=y} and assume z = 0, or a table
-- {x=x,y=y,z=z}, or a table {x=x,y=y} and assume
-- z = 0
--
-- LIST OF FUNCTIONS
-- * means planned but not implemented
-- # means needs testing
--
--
--gen.checkBits(integer,string)-->boolean
--gen.setBits(integer,string)-->integer
--gen.printBits(integer,numOfBits or nil) --> string
--gen.isBit1(integer,bitNumber)--> boolean
--gen.isBit0(integer,bitNumber)--> boolean
--gen.setBit1(integer,bitNumber)-->integer
--gen.setBit0(integer,bitNumber)-->integer
--gen.makeThresholdTable(table or nil)-->thresholdTable
--#applyWonderBonus(wonderObject or integer,tribeObject or integer)-->boolean
--#gen.toTile(tile or table)-->tile
--#gen.isMapFlat()-->boolean
--#gen.isMapRound()-->boolean
--#gen.declareMapFlat()-->void
--#gen.declareMapRound()-->void
--#gen.tileDist(locA,locB,zDist=0)-->integer
--#gen.distance(tileUnitCityA,tileUnitCityB,zDist=0)-->integer
--gen.hasIrrigation(tile)-->boolean
--gen.placeIrrigation(tile)-->void
--gen.removeIrrigation(tile)-->void
--#gen.hasMine(tile)-->boolean
--#gen.placeMine(tile)-->void
--#gen.placeMineUnderCity(tile)-->void
--#gen.removeMine(tile)-->void
--#gen.removeMineUnderCity(tile)-->void
--#gen.hasFarmland(tile)-->boolean
--#gen.placeFarmland(tile)-->void
--#gen.removeFarmland(tile)-->void
--#gen.hasAgriculture(tile)--> boolean
--#gen.improveAgriculture(tile) --> void
--#gen.degradeAgriculture(tile) --> void
--#gen.removeAgriculture(tile)--> void
--#gen.hasRoad(tile)-->boolean
--#gen.placeRoad(tile)-->void
--#gen.removeRoad(tile)-->void
--#gen.hasRailroad(tile)-->boolean
--#gen.placeRailroad(tile)-->void
--#gen.removeRailroad(tile)-->void
--#gen.hasTransportation(tile) --> boolean
--#gen.upgradeTransportation(tile) --> void
--#gen.degradeTransportation(tile) --> void
--#gen.removeTransportation(tile) -->void
--#gen.hasFortress(tile)-->boolean
--#gen.placeFortress(tile)-->void
--#gen.placeFortressForce(tile)-->void
--#gen.removeFortress(tile)-->void
--#gen.hasAirbase(tile)-->boolean
--#gen.placeAirbase(tile)-->void
--#gen.placeAirbaseForce(tile)-->void
--#gen.removeAirbase(tile)-->void
--#gen.hasPollution(tile)-->boolean
--#gen.placePollution(tile)-->void
--#gen.removePollution(tile)-->void
--#gen.removePollutionForce(tile)-->void
--#gen.hasTransporter(tile)-->boolean
--# NOTE: Can't placeTransporter
--#gen.removeTransporter(tile)-->void
--#gen.setTerrainType(tile,terrain)-->void
--#gen.isFortifying(unit)-->boolean
--#gen.setToFortifying(unit)-->void
--#gen.isFortified(unit)-->boolean
--#gen.setToFortified(unit)-->void
--#gen.isSleeping(unit)-->boolean
--#gen.setToSleeping(unit)-->void
--#gen.isBuildingFortress(unit) --> boolean
--#gen.setToBuildingFortress(unit)-->void
--#gen.isBuildingRoad(unit) --> boolean
--#gen.setToBuildingRoad(unit)-->void
--#gen.isIrrigating(unit)-->boolean
--#gen.setToIrrigating(unit)-->void
--#gen.isMining(unit)-->boolean
--#gen.setToMining(unit)-->void
--#gen.isTransformingTerrain(unit)-->boolean
--#gen.setToTransformingTerrain(unit)-->void
--#gen.isBuildingAirbase(unit)-->boolean
--#gen.setToBuildingAirbase(unit)-->void
--#gen.isBuildingTransporter(unit)-->boolean
--#gen.setToBuildingTransporter(unit)-->void
--#gen.isGoingTo(unit)-->boolean
--#gen.setToGoingTo(unit,tile)-->void
--#gen.isNoOrder(unit)-->boolean
--#gen.setToNoOrders(unit)-->void
--#gen.isWaiting(unit)-->bool
--#gen.setToWaiting(unit)-->void
--#gen.clearWaiting(unit)-->void
--#gen.isParadropped(unit)-->void
--#gen.setParadropped(unit)-->void
--#gen.clearParadropped(unit)-->void
--#gen.isMoved(unit)-->boolean
--#gen.setMoved(unit)-->void
--#gen.clearMoved(unit)-->void
--#gen.isSeeTwoSpaces(unitType)-->boolean
--#gen.giveSeeTwoSpaces(unitType)-->void
--#gen.removeSeeTowSpaces(unitType)-->void
--#gen.isIgnoreZOC(unitType)-->boolean
--#gen.giveIgnoreZOC(unitType)-->void
--#gen.removeIgnoreZOC(unitType)-->void
--#gen.isAmphibious(unitType)-->boolean
--#gen.giveAmpibious(unitType)-->void
--#gen.removeAmphibious(unitType)-->void
--#gen.isSubmarine(unitType)-->boolean
--#gen.giveSubmarine(unitType)-->void
--#gen.removeSubmarine(unitType)-->void
--#gen.isAttackAir(unitType)-->boolean
--#gen.giveAttackAir(unitType)-->void
--#gen.removeAttackAir(unitType)-->void
--#gen.isCoastal(unitType)-->boolean
--#gen.giveCoastal(unitType)-->void
--#gen.removeCoastal(unitType)-->void
--#gen.isIgnoreWalls(unitType)-->boolean
--#gen.giveIngoreWalls(unitType)-->void
--#gen.removeIgnoreWalls(unitType)-->void
--#gen.isCarryAir(unitType)-->boolean
--#gen.giveCarryAir(unitType)-->void
--#gen.removeCarryAir(unitType)-->void
--#gen.isParadrop(unitType)-->boolean
--#gen.giveParadrop(unitType)-->void
--#gen.removeParadrop(unitType)-->void
--#gen.isAlpine(unitType)-->boolean
--#gen.giveAlpine(unitType)-->void
--#gen.removeAlpine(unitType)-->void
--#gen.isBonusAgainstHorse(unitType)-->boolean
--#gen.giveBonusAgainstHorse(unitType)-->void
--#gen.removeBonusAgainstHorse(unitType)-->void
--#gen.isFreeSupportUnderFundamentalism(unitType)-->boolean
--#gen.giveFreeSupportUnderFundamentalism(unitType)-->void
--#gen.removeFreeSupportUnderFundamentalism(unitType)-->void
--#gen.isDestroyedAfterAttacking(unitType)-->boolean
--#gen.giveDestroyedAfterAttacking(unitType)-->void
--#gen.removeDestroyedAfterAttacking(unitType)-->void
--#gen.isBonusAgainstAir(unitType)-->boolean
--#gen.giveBonusAgainstAir(unitType)-->void
--#gen.removeBonusAgainstAir(unitType)-->void
--#gen.isSpotSubmarines(unitType)-->boolean
--#gen.giveSpotSubmarines(unitType)-->void
--#gen.removeSpotSubmarines(unitType)-->void
--
--#gen.isCivilDisorder(city)-->boolean
--#gen.setCivilDisorder(city)-->void
--#gen.clearCivilDisorder(city)-->void
--#gen.isWeLoveTheKing(city)-->boolean
--#gen.setWeLoveTheKing(city)-->void
--#gen.clearWeLoveTheKing(city)-->void
--#gen.isImprovementSold(city)-->boolean
--#gen.setImprovementSold(city)-->void
--#gen.clearImprovementSold(city)-->void
--#gen.isTechnologyStolen(city)-->boolean
--#gen.setTechnologyStolen(city)-->void
--#gen.clearTechnologyStolen(city)-->void
--#gen.isAutoBuild(city)-->boolean
--#gen.setAutoBuild(city)-->void
--#gen.clearAutoBuild(city)-->void
--#gen.isAttribute6(city)-->boolean
--#gen.setAttribute6(city)-->void
--#gen.clearAttribute6(city)-->void
--#gen.isAttribute7(city)-->boolean
--#gen.setAttribute7(city)-->void
--#gen.clearAttribute7(city)-->void
--#gen.isBuildCoastal(city)-->boolean
--#gen.setBuildCoastal(city)-->void
--#gen.clearBuildCoastal(city)-->void
--#gen.isAttribute9(city)-->boolean
--#gen.setAttribute9(city)-->void
--#gen.clearAttribute9(city)-->void
--#gen.isAttribute10(city)-->boolean
--#gen.setAttribute10(city)-->void
--#gen.clearAttribute10(city)-->void
--#gen.isAttribute11(city)-->boolean
--#gen.setAttribute11(city)-->void
--#gen.clearAttribute11(city)-->void
--#gen.isBuildHydroPlant(city)-->boolean
--#gen.setBuildHydroPlant(city)-->void
--#gen.clearBuildHydroPlant(city)-->void
--#gen.isAttribute13(city)-->boolean
--#gen.setAttribute13(city)-->void
--#gen.clearAttribute13(city)-->void
--#gen.isAttribute14(city)-->boolean
--#gen.setAttribute14(city)-->void
--#gen.clearAttribute14(city)-->void
--#gen.isAttribute15(city)-->boolean
--#gen.setAttribute15(city)-->void
--#gen.clearAttribute15(city)-->void
--#gen.isAttribute16(city)-->boolean
--#gen.setAttribute16(city)-->void
--#gen.clearAttribute16(city)-->void
--#gen.isUsedAirport(city)-->boolean
--#gen.setUsedAirport(city)-->void
--#gen.clearUsedAirport(city)-->void
--#gen.isAttribute18(city)-->boolean
--#gen.setAttribute18(city)-->void
--#gen.clearAttribute18(city)-->void
--#gen.isAttribute19(city)-->boolean
--#gen.setAttribute19(city)-->void
--#gen.clearAttribute19(city)-->void
--#gen.isAttribute20(city)-->boolean
--#gen.setAttribute20(city)-->void
--#gen.clearAttribute20(city)-->void
--#gen.isAttribute21(city)-->boolean
--#gen.setAttribute21(city)-->void
--#gen.clearAttribute21(city)-->void
--#gen.isBuildShips(city)-->boolean
--#gen.setBuildShips(city)-->void
--#gen.clearBuildShips(city)-->void
--#gen.isCityInvestigated(city)-->boolean
--#gen.setCityInvestigated(city)-->void
--#gen.clearCityInvestigated(city)-->void
--#gen.isAttribute24(city)-->boolean
--#gen.setAttribute24(city)-->void
--#gen.clearAttribute24(city)-->void
--#gen.isMilitaryAutoBuild(city)-->boolean
--#gen.setMilitaryAutoBuild(city)-->void
--#gen.clearMilitaryAutoBuild(city)-->void
--#gen.isDomesticAutoBuild(city)-->boolean
--#gen.setDomesticAutoBuild(city)-->void
--#gen.clearDomesticAutoBuild(city)-->void
--#gen.isObjective(city)-->boolean
--#gen.setObjective(city)-->void
--#gen.clearObjective(city)-->void
--#gen.isAttribute28(city)-->boolean
--#gen.setAttribute28(city)-->void
--#gen.clearAttribute28(city)-->void
--#gen.isMajorObjective(city)-->boolean
--#gen.setMajorObjective(city)-->void
--#gen.clearMajorObjective(city)-->void
--#gen.isUsedTransporter(city)-->boolean
--#gen.setUsedTransporter(city)-->void
--#gen.clearUsedTransporter(city)-->void
--#gen.isAttribute31(city)-->boolean
--#gen.setAttribute31(city)-->void
--#gen.clearAttribute31(city)-->void
--#gen.isAttribute32(city)-->boolean
--#gen.setAttribute32(city)-->void
--#gen.clearAttribute32(city)-->void
--
--#gen.wonderModifiedMoves(unit)-->integer
--#gen.maxMoves(unit) --> integer
--#gen.moveRemaining(unit) --> integer
--#gen.inPolygon(tile,tableOfCoordinates)-->bool
--#gen.cityCanSupportAnotherUnit(city)-->bool
--#gen.rehomeUnitsInCapturedCity(city,defender) --> void
--#gen.homeToNearestCity(unit)-->void
--#gen.activate(unit)-->void
--#gen.activateWithSource(unit,source)-->void
--#gen.linkActivationFunction(function(unit,source)-->void)-->void
--#gen.getActivationFunction()-->function(unit,source)
--#gen.getTileID(tileObject or int,int or nil,int or nil)-->int (by Knighttime, converts a tile/coordinates to a single integer as an ID number)
--#gen.getTileId(tileObject or int,int or nil,int or nil)-->int (by Knighttime, converts a tile/coordinates to a single integer as an ID number)
-- gen.getTileFromID(tileID) --> tileObject -- undoes gen.getTileID
-- gen.getTileFromId(tileID) --> tileObject -- undoes gen.getTileID
--#gen.unitTypeOnTile(tile,unitTypeOrTableOfUnitType)-->bool
--#gen.getAdjacentTiles(tile)-->tableOfTiles
--#gen.moveUnitAdjacent(unit,destRankFn=suitableDefault)-->tile or bool
--#gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile,destRankFn=suitableDefault)-->void
--#gen.clearAirProtection(tile)-->void
--#gen.clearAdjacentAirProtection(unit) -->void clears air protection for tiles adjacent to the unit that are not owned by the unit's owner
--#gen.inTable(object,table)--> bool
--#gen.copyTable(table)-->table
--#gen.errorForNilKey(table,tableName)-->void
--#gen.noNewKey(table,tableName)-->void
--#gen.noGlobal()
--#gen.linkState(stateTable)
--#gen.getState()-->table
--#gen.cityRadiusTiles(cityOrTileOrCoordTable) --> table
--#gen.getTilesInRadius(centre,radius,minRadius=0,maps=nil) --> table
--#gen.clearGapsInArray(table,lowestValue=1)
--#gen.playMusic(fileName)
--#gen.setMusicDirectory(path)
--#gen.getEphemeralTable()-->table
--#gen.linkGeneralLibraryState(stateTable) --> void
--#gen.limitedExecutions(key,maxTimes,limitedFunction)--> void
-- gen.justOnce(key,limitedFunction)-->void
--
--#gen.isSinglePlayerGame() --> boolean
--#gen.tableWrap(item)-->table
--#gen.tableWrap(item,needsWrapFn)-->table
--
--#gen.copyUnitAttributes(parent,child)-->void
--#gen.nearbyUnits(center,radius) --> iterator providing units
--
--#gen.setDeathFunctions(defeatFunction,deathFunction,deletionFunction) --> void
--#gen.defeatUnit(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->unit or nil
--#gen.killUnit(dyingUnit)-->void
--#gen.deleteUnit(deletedUnit,replacementUnit=nil)-->void
--#gen.replaceUnit(oldUnit,replacementType)--> unit
--#gen.makeAllowedTerrainFunction(allowedTilesTable) --> function(tile)-->bool
--#gen.nearbyUnoccupiedTiles(tile,distance,allowedTiles) --> table
--#gen.getRandomNearbyUnoccupiedTile(tile,distance,allowedTiles) --> tile
--#gen.isEmpty(table)-->bool
--#gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
--#gen.getRandomNearbyOpenTileForTribe(tile,distance,allowedTiles,tribe) --> tile
--#gen.createUnit(unitType,tribe,locations,options) --> table of units
-- gen.getTileProduction(tile,city) --> integer (food), integer(shields), integer(trade)
-- gen.computeBaseProduction(city)-->integer(food), integer(shields), integer(trade)
-- gen.persistentRandom(key) --> number between 0 and 1
-- gen.clearPersistentRandom(key) --> void
-- gen.getPersistentRandomTable() --> table
-- gen.mergeTableValues(table,table,...) --> table
--
-- FUNCTION IMPLEMENTATIONS
--

local gen = {}

-- gen.checkBits(integer,string)-->boolean
-- Compares the binary representation of an integer with
-- a string.  If the string has a 1 in a given place,
-- the binary representation of the integer should also
-- have a 1.  If the string has a 0 in a given place, the
-- binary representation should also have a 0. Any other
-- character in the string means the integer can have a
-- 0 or a 1.  If the integer representation is longer than
-- the string, the string is alligned with the smallest
-- part of the integer.
-- gen.checkBits(0b10101011,"xx10xwqp")-->true
-- gen.checkBits(0b10101011,"xx11xwqp")-->false
-- gen.checkBits(0b011110101011,"xx10xwqp")-->true
-- gen.checkBits(0b011110101011,"xx10xwqp")-->true
-- Helper function (provided to this library as checkBits and gen.checkBits)
-- note: lua does not actually accept integers specified in binary 
-- (though it does for hexidecimal)
--

local function checkBits(integer,bitString)
    local strlen = string.len(bitString)
    for i=1,strlen do
        local bitInt = 1<<(i-1)
        if bitString:sub(-i,-i) == "1" and integer & bitInt == 0 then
            -- ith bit isn't 1, but bitString specifies 1
            return false
        elseif bitString:sub(-i,-i) == "0" and integer & bitInt == bitInt then
            -- ith bit is 1, but bitString specifies 0
            return false
        end
    end
    -- if we get here, all specified bits match
    return true
end
gen.checkBits = checkBits

-- gen.setBits(integer,string)-->integer
-- sets binary bits in an integer to 1 or 0 based on
-- the information provided by a string.  Characters that 
-- are not 1 or 0 leave the corresponding bit unchanged
-- Last character of the string corresponds to the 1's bit
-- in the integer (string lines up to the least significant
-- part of the number)
-- gen.setBits(0b00000000,"xx10xxxx")-->0b00100000
-- gen.setBits(0b00000000,"xx10xx")-->0b00001000
-- gen.setBits(0b11111100,"xx0011xx")-->0b11001100
-- gen.setBits(0b10101011,"xx10xwqp")-->0b10101011
-- gen.setBits(0b10101011,"xx11xwqp")-->0b10111011
-- Helper function (provided to this library as setBits and gen.setBits)
-- note: lua does not actually accept integers specified in binary 
-- (though it does for hexidecimal)
local function setBits(integer,bitString)
    local strlen = string.len(bitString)
    for i=1,strlen do
        local bitInt = 1<<(i-1)
        if bitString:sub(-i,-i) == "1" then
            integer = integer | bitInt
        elseif bitString:sub(-i,-i) == "0" then
            integer = integer & ~bitInt
        end
    end
    return integer
end
gen.setBits = setBits

-- gen.printBits(integer,numOfBits or nil) --> string
-- prints the binary representation of integer,
-- including the numOfBits least significant bits
-- if numOfBits is nil, it defaults to 32
function gen.printBits(integer,numOfBits)
    if not numOfBits then
        numOfBits = 32
    end
    if type(integer)~= "number" or type(numOfBits) ~= "number" then
        error("gen.printBits requires integer arguments.")
    end
    local concatTable = {}
    for i=1,numOfBits do
        if integer & 1<<(numOfBits-i) == 0 then
            concatTable[i]="0"
        else
            concatTable[i]="1"
        end
    end
    return table.concat(concatTable)
end

-- gen.isBit1(integer,bitNumber)--> boolean
-- tells if bitNumber bit of integer is 1 
-- (1st bit is the bit for the ones position)
-- Helper Function (provided as local and in gen table)
local function isBit1(integer,bitNumber)
    return integer & 1<<(bitNumber-1) == 1<<(bitNumber-1)
end
gen.isBit1 = isBit1

-- gen.isBit0(integer,bitNumber)--> boolean
-- tells if bitNumber bit of integer is 0 
-- (1st bit is the bit for the ones position)
-- Helper Function (provided as local and in gen table)
local function isBit0(integer,bitNumber)
    return integer & 1<<(bitNumber-1) == 0
end
gen.isBit0 = isBit0

-- gen.setBit1(integer,bitNumber)-->integer
-- sets bitNumber bit of the integer to 1
-- (1st bit is the bit for the ones position)
-- Helper Function (provided as local and in gen table)
local function setBit1(integer,bitNumber)
	return integer | 1<<(bitNumber-1)
end
gen.setBit1 = setBit1

-- gen.setBit0(integer,bitNumber)-->integer
-- sets bitNumber bit of the integer to 0
-- (1st bit is the bit for the ones position)
-- Helper Function (provided as local and in gen table)
local function setBit0(integer,bitNumber)
	return integer & ~(1<<(bitNumber-1))
end
gen.setBit0 = setBit0

local thresholdTableMetatable = { __index = function(thresholdTable,key)
            if type(key) ~= "number" then
                return rawget(thresholdTable,key)
            else
                local bestIndexSoFar = -math.huge
                local bestValueSoFar = false
                for index,value in pairs(thresholdTable) do
                    if type(index) == "number" and key >= index and index >= bestIndexSoFar then
                        bestIndexSoFar = index
                        bestValueSoFar = value
                    end
                end
                return bestValueSoFar
            end
        end,}
-- A threshold table is a table where if a numerical key is indexed, and that
-- numerical key doesn't correspond to an index, the value of the largest
-- numerical index less than the key is used.
-- If there is no numerical index smaller than the key, false is returned
-- (nil is returned for non-numerical keys not in table)
-- Use an index -math.huge to provide values for arbitrarily small numerical keys
-- example 
-- myTable = gen.makeThresholdTable({[-1]=-1,[0]=0,[1]=1,})
-- myTable[-2] = false
-- myTable[-1] = -1
-- myTable[-0.6] = -1
-- myTable[3.5]=1
-- myTable["three"] = nil
-- myTable[0.5]=0
--
-- gen.makeThresholdTable(table or nil)-->thresholdTable
-- makes an input a threshold table or creates an empty thresholdTable
-- Also returns the table value
function gen.makeThresholdTable(inputTable)
    inputTable = inputTable or {}
    return setmetatable(inputTable,thresholdTableMetatable)
end

-- applyWonderBonus(wonderObject or integer,tribeObject or integer)-->boolean
-- gen.applyWonderBonus(wonderObject or integer,tribeObject or integer)-->boolean
-- returns true if the wonder has been built and is not
-- expired or destroyed 
-- integer means corresponding wonder/tribe id
local function applyWonderBonus(wonder,tribe)
    if type(wonder) == "number" then
        wonder = civ.getWonder(wonder)
    end
    if type(tribe) == "number" then
        tribe = civ.getTribe(tribe)
    end
    --check if expired
    for i=0,7 do
        if civ.getTribe(i) and wonder.expires and tribe:hasTech(wonder.expires) then
            return false
        end
    end
    if wonder.city and wonder.city.owner == tribe then
        return true
    else 
        return false
    end
end


-- toTile(tile or table)-->tile
-- gen.toTile(tile or table)-->tile
-- If given a tile object, returns the tile
-- If given coordinates for a tile, returns the tile
-- Causes error otherwise
-- Helper Function (provided to this library as toTile and gen.toTile)
--
local function toTile(input)
    if civ.isTile(input) then
        if civ.getTile(input.x,input.y,input.z) then
            return input
        else
            error("toTile: tile coordinates are ("..tostring(input.x)..","..tostring(input.y)..
            ","..tostring(input.z).." which does not correspond to a tile on the map.  "..
            "the game is known to return a 'false tile' for loser.location in unit killed if the"..
            " attacking unit was the loser, though this may happen elsewhere as well.")
        end
    elseif type(input) == "table" then
        local xVal = input[1] or input["x"]
        local yVal = input[2] or input["y"]
        local zVal = input[3] or input["z"] or 0
        if type(xVal)=="number" and type(yVal)=="number" and type(zVal)=="number" then
            if civ.getTile(xVal,yVal,zVal) then
                return civ.getTile(xVal,yVal,zVal)
            else
                error("Table with values {"..tostring(xVal)..","..tostring(yVal)..
                        ","..tostring(zVal).."} does not correspond to a valid tile.")
            end
        else
            error("Table did not correspond to tile coordinates")
        end
    else
        error("Did not receive a tile object or table of coordinates.")
    end
end
gen.toTile = toTile


-- by default, the map is considered flat
-- use gen.declareMapRound to say the map is round
-- with TOTPP v 16, we can access directly whether world is flat
-- reference to the variable flatMap has been removed in this
-- file, the variable itself is left to avoid errors
-- with the declareMap functions.
local flatMap = civ.game.rules.flatWorld
print(flatMap)
-- gen.isMapFlat()-->boolean
function gen.isMapFlat()
    return civ.game.rules.flatWorld
end

-- gen.isMapRound()-->boolean
function gen.isMapRound()
    return not civ.game.rules.flatWorld
end

-- gen.declareMapFlat()-->void
-- tells this module that the map should be considered flat
-- for things like distances and adjacent squares
-- no longer has practical effect, since above
-- functions access world shape directly with TOTPP v16
function gen.declareMapFlat()
    flatMap = true
end

-- gen.declareMapRound()-->void
function gen.declareMapRound()
    flatMap = false
end

-- tileDist(locA,locB,zDist=0)
-- gen.tileDist(locA,locB,zDist=0)
-- takes two tiles and a 'vertical distance' (0 if absent)
-- and computes the distance (1-norm, not Euclidean) between them
-- doesn't pre-process arguments like gen.distance, so might be slightly
-- quicker (though this probably will never matter)
local function tileDist(locA,locB,zDist)
    zDist = zDist or 0
    if civ.game.rules.flatWorld then
        return (math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2
    else
        local xMax,yMax,zMax=civ.getMapDimensions()
        return math.min((math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2,
            (xMax-math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2)
    end
end
gen.tileDist = tileDist

-- distance(tileUnitCityA,tileUnitCityB,zDist=0)-->integer
-- gen.distance(tileUnitCityA,tileUnitCityB,zDist=0)-->integer
-- returns the distance (1-norm, not Euclidean) (in terms of tiles, not coordinates) between 
-- objects A and B, that have a natural location (also converts doubles and triples of tables)
-- zDist is the number of tiles that one unit of z coordinate "distance" is equivalent to
local function distance(tileUnitCityA,tileUnitCityB,zDist)
    zDist = zDist or 0
    local locA = nil
    local locB = nil
    if type(tileUnitCityA)=="table" then
        locA=toTile(tileUnitCityA)
    elseif civ.isUnit(tileUnitCityA) or civ.isCity(tileUnitCityA) then
        locA=tileUnitCityA.location
    elseif civ.isTile(tileUnitCityA) then
        locA = tileUnitCityA
    else
        error("gen.distance: first argument must be a tile (or coordinates of a tile), or a unit or a city.")
    end
    if type(tileUnitCityB)=="table" then
        locB=toTile(tileUnitCityB)
    elseif civ.isUnit(tileUnitCityB) or civ.isCity(tileUnitCityB) then
        locB=tileUnitCityB.location
    elseif civ.isTile(tileUnitCityB) then
        locB = tileUnitCityB
    else
        error("gen.distance: second argument must be a tile (or coordinates of a tile), or a unit or a city.")
    end
    if civ.game.rules.flatWorld then
        return (math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2
    else
        local xMax,yMax,zMax=civ.getMapDimensions()
        return math.min((math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2,
            (xMax-math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2)
    end
end
gen.distance = distance

-- gen.hasIrrigation(tile)-->boolean
-- returns true if tile has irrigation but no farm
-- returns false otherwise
function gen.hasIrrigation(tile)
    tile = toTile(tile)
    local improvements = tile.improvements
    -- irrigation, but no mining, so not farmland
    return improvements & 0x04 == 0x04 and improvements & 0x08 == 0 
end

-- gen.placeIrrigation(tile)-->void
-- places irrigation on the tile provided
-- removes mines and farmland if present
-- does nothing if tile has a city
function gen.placeIrrigation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    end
    -- Set irrigation bit to 1
    tile.improvements = tile.improvements | 0x04
    -- Set mining bit to 0
    tile.improvements = tile.improvements & ~0x08
end

-- gen.removeIrrigation(tile)-->void
-- If tile has irrigation but no farmland, removes the irrigation
-- Does nothing to farmland
-- Does nothing if tile has a city
function gen.removeIrrigation(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.city or tile.improvements & 0x0C == 0x0C then
        return
    end
    -- set irrigation bit to 0
    tile.improvements = tile.improvements & ~0x04
end

-- gen.hasMine(tile)-->boolean
function gen.hasMine(tile) 
    tile = toTile(tile)
    local improvements = tile.improvements
    -- mining, but no irrigation, so not farmland
    return improvements & 0x08 == 0x08 and improvements & 0x04 == 0 
end

-- gen.placeMine(tile)-->void
-- places mines on the tile provided
-- removes irrigation and farmland if present
-- does nothing if tile has city
function gen.placeMine(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    -- set mining bit to 1
    tile.improvements = tile.improvements | 0x08
    -- set irrigation bit to 0
    tile.improvements = tile.improvements & ~0x04
end

-- gen.placeMineUnderCity(tile) --> void
-- places mine on a tile, even if a city is present
-- removes irrigation and farmland if present
function gen.placeMineUnderCity(tile)
    tile = toTile(tile)
    -- set mining bit to 1
    tile.improvements = tile.improvements | 0x08
    -- set irrigation bit to 0
    tile.improvements = tile.improvements & ~0x04
end

-- gen.removeMine(tile)-->void
-- if tile has mining but no farmland, removes mines
-- does nothing to farmland
-- does nothing if tile has a city
function gen.removeMine(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.city or tile.improvements & 0x0C == 0x0C then
        return
    end
    -- set irrigation bit to 0
    tile.improvements = tile.improvements & ~0x08
end

-- gen.removeMineUnderCity(tile)-->void
-- if tile has mining but no farmland, removes mines
-- does nothing to farmland
function gen.removeMineUnderCity(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.improvements & 0x0C == 0x0C then
        return
    end
    -- set mining bit to 0
    tile.improvements = tile.improvements & ~0x08

end
-- gen.hasFarmland(tile)-->boolean
function gen.hasFarmland(tile)
    tile = toTile(tile)
    return tile.improvements & 0x0C == 0x0C
end

-- gen.placeFarmland(tile)-->void
-- places farmland on a tile (removing mining)
-- does nothing if a city is present
function gen.placeFarmland(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    tile.improvements = tile.improvements | 0x0C
end

-- gen.removeFarmland(tile)-->void
-- removes farmland if present
-- does nothing to irrigation or mining
-- does nothing if city present
function gen.removeFarmland(tile) 
    tile = toTile(tile)
    if (not tile.city) and (tile.improvements & 0x0C == 0x0C) then
        tile.improvements = tile.improvements & ~0x0C
    end
end

-- gen.hasAgriculture(tile)-->bool
-- returns true if tile has irrigation or farmland
function gen.hasAgriculture(tile)
    tile = toTile(tile)
    return tile.improvements & 0x04 == 0x04
end

-- gen.improveAgriculture(tile) --> void
-- if tile has no irrigation, place irrigation (even if mining present)
-- if tile has irrigation, place farmland
-- if city do nothing
function gen.improveAgriculture(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasIrrigation(tile) then
        gen.placeFarmland(tile)
        return
    else
        gen.placeIrrigation(tile)
        return
    end
end

-- gen.degradeAgriculture(tile) --> void
-- if tile has farmland, reduce to irrigation
-- if tile has irrigation, remove
-- does nothing if city present
function gen.degradeAgriculture(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasFarmland(tile) then
        gen.placeIrrigation(tile)
        return
    else
        gen.removeIrrigation(tile)
    end
end

-- gen.removeAgriculture(tile) --> void
-- remove farmland and irrigation if present
-- do nothing to mining
-- do nothing if city present
function gen.removeAgriculture(tile)
    tile = toTile(tile)
    if (not tile.city) and gen.hasAgriculture(tile) then
        tile.improvements = tile.improvements & ~0x0C
    end
end


-- gen.hasRoad(tile)-->boolean
-- returns true if tile has a road
function gen.hasRoad(tile) 
    tile = toTile(tile)
    return tile.improvements & 0x10 == 0x10 
end

-- gen.placeRoad(tile)-->void
-- places a road on the tile
-- does nothing if city present
function gen.placeRoad(tile) 
    tile=toTile(tile)
    if tile.city then 
        return
    end
    tile.improvements = tile.improvements | 0x10
end

-- gen.removeRoad(tile)-->void
-- removes a road if there is a road but no rail
-- doesn't touch rail or cities
function gen.removeRoad(tile)
    tile = toTile(tile)
    if tile.city or (tile.improvements & 0x30 == 0x30) then
        return
    end
    tile.improvements = tile.improvements & ~0x10
end

-- gen.hasRailroad(tile)-->boolean
-- returns true if a tile has a railroad (and road)
function gen.hasRailroad(tile) 
    tile = toTile(tile)
    return tile.improvements & 0x30 == 0x30 

end

-- gen.placeRailroad(tile)-->void
-- places a railroad (and road) on a tile
-- does nothing if city is present
function gen.placeRailroad(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    tile.improvements = tile.improvements | 0x30
end

-- gen.removeRailroad(tile)-->void
-- removes railroad from a tile if it exits,
-- leaving road intact (if there is already road there)
-- does nothing if a city is present
function gen.removeRailroad(tile) 
    tile = toTile(tile)
    if (tile.improvements & 0x30 == 0x30) and (not tile.city) then
        tile.improvements = tile.improvements & ~0x20
    end
end
-- gen.hasTransportation(tile) --> boolean
-- returns true if tile has road or rail 
-- (but not if city, unless an event has placed a road)
function gen.hasTransportation(tile)
    tile = toTile(tile)
    return tile.improvements & 0x10 == 0x10 
end


-- gen.upgradeTransportation(tile) --> void
-- places railroad if road exists, otherwise places road
-- does nothing if city present
function gen.upgradeTransportation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasRoad(tile) then
        gen.placeRailroad(tile)
        return
    else
        gen.placeRoad(tile)
        return
    end
end

-- gen.degradeTransportation(tile) --> void
-- reduces railroad to road, if rail exists
-- if no rail but road, removes road
-- if no transportation, does nothing
-- if city does nothing
function gen.degradeTransportation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasRailroad(tile) then
        gen.removeRailroad(tile)
    else
        gen.removeRoad(tile)
    end
end

-- gen.removeTransportation(tile) -->void
-- removes road and rail, if it exists
-- does nothing if city present
function gen.removeTransportation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    else
        tile.improvements = tile.improvements & ~0x30
    end
end

-- gen.hasFortress(tile)-->boolean
function gen.hasFortress(tile)
    tile = toTile(tile)
    -- must be fortress, and not airbase
    return checkBits(tile.improvements,"x1xxxx0x")
end

-- gen.placeFortress(tile)-->void
-- places a fortress on a square, unless
-- there is already a city, transporter, or airbase on the tile
function gen.placeFortress(tile)
    tile = toTile(tile)
    if tile.city or isBit1(tile.improvements,2) then
        return
    end
    tile.improvements = setBits(tile.improvements,"x1xxxx0x")
end

-- gen.placeFortressForce(tile)-->void
-- places fortress (replacing airbase/transporter if necessary)
-- If city on tile, nothing happens
function gen.placeFortressForce(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    tile.improvements = setBits(tile.improvements,"x1xxxx0x")
    return
end

-- gen.removeFortress(tile)-->void
-- Checks that a fortress is in place (so as not to change
-- other terrain improvements), and if so, removes the fortress
function gen.removeFortress(tile) 
    tile = toTile(tile)
    if checkBits(tile.improvements,"x1xxxx0x") then
        tile.improvements = setBit0(tile.improvements,7)
    end
end

-- gen.hasAirbase(tile)-->boolean
function gen.hasAirbase(tile) 
    tile = toTile(tile)
    return checkBits(tile.improvements,"x1xxxx1x")
end

-- gen.placeAirbase(tile)--> void
-- places an airbase on a tile as long as there is not already
-- pollution, fortress, or transporter on the tile
-- does nothing if city present
function gen.placeAirbase(tile)
    tile = toTile(tile)
    local tileImprovements = tile.improvements
    if tile.city or isBit1(tileImprovements,7) or isBit1(tileImprovements,8) then
        return
    end
    tile.improvements = setBits(tile.improvements,"x1xxxx1x")
end

-- gen.placeAirbaseForce(tile)-->void
-- places airbase, removing fortress/transporter/pollution if necessary
-- if city on tile, nothing happens
function gen.placeAirbaseForce(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    tile.improvements = setBits(tile.improvements,"01xxxx1x")
end

-- gen.removeAirbase(tile)-->void
-- removes airbase, if one is on tile
-- (so that something else doesn't get removed)
-- nothing happens if tile is a city
function gen.removeAirbase(tile) 
    tile = toTile(tile)
    if checkBits(tile.improvements,"x1xxxx1x") and (not tile.city) then
        tile.improvements = setBits(tile.improvements,"00xxxx0x")
    end
end

-- gen.hasPollution(tile)-->boolean
function gen.hasPollution(tile) 
    tile = toTile(tile)
    return checkBits(tile.improvements,"1xxxxx0x")

end

-- gen.placePollution(tile)-->void
-- places pollution, unless the tile has a city, airbase
-- or transporter already on the tile
function gen.placePollution(tile) 
    tile = toTile(tile)
    if tile.city or isBit1(tile.improvements,2) then
        return
    end
    tile.improvements = setBits(tile.improvements,"1xxxxx0x")
end

-- gen.placePollutionForce(tile)-->void
-- places pollution, unless the tile has a city, 
-- transporters and airbases are removed
function gen.placePollution(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    if gen.hasFortress(tile) then
        tile.improvements = setBits(tile.improvements,"11xxxx0x")
    else
        tile.improvements = setBits(tile.improvements,"1xxxxx0x")
    end
end
-- gen.removePollution(tile)-->void
-- checks if tile has pollution, and if so, removes it
function gen.removePollution(tile) 
    tile = toTile(tile)
    if checkBits(tile.improvements,"1xxxxx0x") then
        tile.improvements = setBit0(tile.improvements,8)
    end
end

-- gen.hasTransporter(tile)-->boolean
function gen.hasTransporter(tile) 
    tile = toTile(tile)
    return checkBits(tile.improvements,"1xxxxx1x")
end

-- placing transporters doesn't work
--

-- gen.removeTransporter(tile)-->void
function gen.removeTransporter(tile) 
    tile = toTile(tile)
    if (not tile.city) and checkBits(tile.improvements,"1xxxxx1x") then
        tile.improvements = setBits(tile.improvements,"0xxxxx0x")
        return
    end
end

-- gen.setTerrainType(tile,terrainID)-->void
-- changes the terrain type of tile to terrainID
-- have this function, so that if
-- terrainType key functionality is changed, this
-- function can change instead of all code everywhere
function gen.setTerrainType(tile,terrainID)
    tile = toTile(tile)
    tile.terrainType = terrainID
end
--
-- gen.isFortifying(unit)-->boolean
function gen.isFortifying(unit) 
    return unit.order == 0x01
end

-- gen.setToFortifying(unit)-->void
function gen.setToFortifying(unit) 
    unit.order = 0x01
end

-- gen.isFortified(unit)-->boolean
function gen.isFortified(unit) 
    return unit.order == 0x02
end

-- gen.setToFortified(unit)-->void
function gen.setToFortified(unit) 
    unit.order = 0x02
end

-- gen.isSleeping(unit)-->boolean
function gen.isSleeping(unit) 
    return unit.order == 0x03
end

-- gen.setToSleeping(unit)-->void
function gen.setToSleeping(unit) 
    unit.order = 0x03
end
--
-- gen.isBuildingFortress(unit) --> boolean
function gen.isBuildingFortress(unit)
    return unit.order == 0x04
end


-- gen.setToBuildingFortress(unit)-->void
function gen.setToBuildingFortress(unit) 
    unit.order = 0x04
end
--
-- gen.isBuildingRoad(unit) --> boolean
function gen.isBuildingRoad(unit)
    return unit.order == 0x05
end

-- gen.setToBuildingRoad(unit)-->void
function gen.setToBuildingRoad(unit) 
    unit.order = 0x05
end


-- gen.isIrrigating(unit)-->boolean
function gen.isIrrigating(unit) 
    return unit.order == 0x06
end

-- gen.setToIrrigating(unit)-->void
function gen.setToIrrigating(unit) 
    unit.order = 0x06
end

-- gen.isMining(unit)-->boolean
function gen.isMining(unit) 
    return unit.order == 0x07
end

-- gen.setToMining(unit)-->void
function gen.setToMining(unit) 
    unit.order = 0x07
end

-- gen.isTransformingTerrain(unit)-->boolean
function gen.isTransformingTerrain(unit) 
    return unit.order == 0x08
end

-- gen.setToTransformingTerrain(unit)-->void
function gen.setToTransformingTerrain(unit) 
    unit.order = 0x08
end

-- gen.isCleaningPollution(unit)-->boolean
function gen.isCleaningPollution(unit) 
    return unit.order == 0x09
end

-- gen.setToCleaningPollution(unit)-->void
function gen.setToCleaningPollution(unit) 
    unit.order = 0x09
end
-- gen.isBuildingAirbase(unit)-->boolean
function gen.isBuildingAirbase(unit) 
    return unit.order == 0x0A
end

-- gen.setToBuildingAirbase(unit)-->void
function gen.setToBuildingAirbase(unit) 
    unit.order = 0x0a
end

-- gen.isBuildingTransporter(unit)-->boolean
function gen.isBuildingTransporter(unit) 
    return unit.order == 0x0B
end

-- gen.setToBuildingTransporter(unit)-->void
function gen.setToBuildingTransporter(unit) 
    unit.order = 0x0B
end

-- gen.isGoingTo(unit)-->boolean
function gen.isGoingTo(unit)
    return not not unit.gotoTile
end

-- gen.setToGoingTo(unit,tile or nil)-->void
-- gives the unit a goto order for the tile
-- if nil is submitted, and the unit already
-- has a goto order, the unit will be changed to no orders
-- (unit.gotoTile=nil results in an error)
-- if the unit has some other order, it will keep that order
-- note: this also accepts a table of coordinates as a tile
-- (just as all other tile functions do here)
function gen.setToGoingTo(unit,tile) 
    if tile == nil and unit.gotoTile then
        unit.order = 0xFF
        return
    elseif tile == nil then
        return
    end
    tile = toTile(tile)
    unit.gotoTile = tile
end

-- gen.isNoOrder(unit)-->boolean
function gen.isNoOrder(unit) 
    return unit.order == 0xFF
end

-- gen.setToNoOrders(unit)-->void
function gen.setToNoOrders(unit) 
    unit.order = 0xFF
end

-- gen.isWaiting(unit)-->bool
function gen.isWaiting(unit)
    return unit.attributes & 0x4000 == 0x4000
end
-- gen.setToWaiting(unit)-->void
function gen.setToWaiting(unit)
    unit.attributes = unit.attributes | 0x4000
end
-- gen.clearWaiting(unit)-->void
function gen.clearWaiting(unit)
    unit.attributes = unit.attributes & ~0x4000
end
-- gen.isParadropped(unit)-->boolean
function gen.isParadropped(unit)
    return isBit1(unit.attributes,5)
end
-- gen.setParadropped(unit)-->void
function gen.setParadropped(unit)
    unit.attributes = setBit1(unit.attributes,5)
end
-- gen.clearParadropped(unit)-->void
function gen.clearParadropped(unit)
    unit.attributes = setBit0(unit.attributes,5)
end
-- gen.isMoved(unit)-->boolean
-- game sets this flag when a unit moves (even if no move spent)
-- unit won't heal on next turn if this flag is set
function gen.isMoved(unit)
    return isBit1(unit.attributes,7)
end
-- gen.setMoved(unit)-->void
function gen.setMoved(unit)
    unit.attributes = setBit1(unit.attributes,7)
end
-- gen.clearMoved(unit)-->void
function gen.clearMoved(unit)
    unit.attributes = setBit0(unit.attributes,7)
end
--
-- gen.isSeeTwoSpaces(unitType)-->boolean
function gen.isSeeTwoSpaces(unitType) 
    return isBit1(unitType.flags,1)
end

-- gen.giveSeeTwoSpaces(unitType)-->void
function gen.giveSeeTwoSpaces(unitType) 
    unitType.flags = setBit1(unitType.flags,1)
end

-- gen.removeSeeTowSpaces(unitType)-->void
function gen.removeSeeTowSpaces(unitType) 
    unitType.flags = setBit0(unitType.flags,1)
end

-- gen.isIgnoreZOC(unitType)-->boolean
function gen.isIgnoreZOC(unitType) 
    return isBit1(unitType.flags,2)
end

-- gen.giveIgnoreZOC(unitType)-->void
function gen.giveIgnoreZOC(unitType) 
    unitType.flags = setBit1(unitType.flags,2)
end

-- gen.removeIgnoreZOC(unitType)-->void
function gen.removeIgnoreZOC(unitType) 
    unitType.flags = setBit0(unitType.flags,2)
end

-- gen.isAmphibious(unitType)-->boolean
function gen.isAmphibious(unitType) 
    return isBit1(unitType.flags,3)
end

-- gen.giveAmpibious(unitType)-->void
function gen.giveAmpibious(unitType) 
    unitType.flags = setBit1(unitType.flags,3)
end

-- gen.removeAmphibious(unitType)-->void
function gen.removeAmphibious(unitType) 
    unitType.flags = setBit0(unitType.flags,3)
end

-- gen.isSubmarine(unitType)-->boolean
function gen.isSubmarine(unitType) 
    return isBit1(unitType.flags,4)
end

-- gen.giveSubmarine(unitType)-->void
function gen.giveSubmarine(unitType)
   unitType.flags = setBit1(unitType.flags,4)
end

-- gen.removeSubmarine(unitType)-->void
function gen.removeSubmarine(unitType) 
    unitType.flags = setBit0(unitType.flags,4)
end

-- gen.isAttackAir(unitType)-->boolean
function gen.isAttackAir(unitType) 
    return isBit1(unitType.flags,5)
end

-- gen.giveAttackAir(unitType)-->void
function gen.giveAttackAir(unitType) 
    unitType.flags = setBit1(unitType.flags,5)
end

-- gen.removeAttackAir(unitType)-->void
function gen.removeAttackAir(unitType) 
    unitType.flags = setBit0(unitType.flags,5)
end

-- gen.isCoastal(unitType)-->boolean
function gen.isCoastal(unitType) 
    return isBit1(unitType.flags,6)
end

-- gen.giveCoastal(unitType)-->void
function gen.giveCoastal(unitType) 
    unitType.flags = setBit1(unitType.flags,6)
end

-- gen.removeCoastal(unitType)-->void
function gen.removeCoastal(unitType) 
    unitType.flags = setBit0(unitType.flags,6)
end

-- gen.isIgnoreWalls(unitType)-->boolean
function gen.isIgnoreWalls(unitType) 
    return isBit1(unitType.flags,7)
end

-- gen.giveIngoreWalls(unitType)-->void
function gen.giveIngoreWalls(unitType) 
    unitType.flags = setBit1(unitType.flags,7)
end

-- gen.removeIgnoreWalls(unitType)-->void
function gen.removeIgnoreWalls(unitType) 
    unitType.flags = setBit0(unitType.flags,7)
end

-- gen.isCarryAir(unitType)-->boolean
 function gen.isCarryAir(unitType) 
    return isBit1(unitType.flags,8)
end

-- gen.giveCarryAir(unitType)-->void
function gen.giveCarryAir(unitType) 
    unitType.flags = setBit1(unitType.flags,8)
end

-- gen.removeCarryAir(unitType)-->void
function gen.removeCarryAir(unitType) 
    unitType.flags = setBit0(unitType.flags,8)
end

-- gen.isParadrop(unitType)-->boolean
function gen.isParadrop(unitType) 
    return isBit1(unitType.flags,9)
end

-- gen.giveParadrop(unitType)-->void
function gen.giveParadrop(unitType) 
    unitType.flags = setBit1(unitType.flags,9)
end

-- gen.removeParadrop(unitType)-->void
function gen.removeParadrop(unitType) 
    unitType.flags = setBit0(unitType.flags,9)
end

-- gen.isAlpine(unitType)-->boolean
function gen.isAlpine(unitType) 
    return isBit1(unitType.flags,10)
end

-- gen.giveAlpine(unitType)-->void
function gen.giveAlpine(unitType) 
    unitType.flags = setBit1(unitType.flags,10)
end

-- gen.removeAlpine(unitType)-->void
function gen.removeAlpine(unitType) 
    unitType.flags = setBit0(unitType.flags,10)
end

-- gen.isBonusAgainstHorse(unitType)-->boolean
function gen.isBonusAgainstHorse(unitType) 
    return isBit1(unitType.flags,11)
end

-- gen.giveBonusAgainstHorse(unitType)-->void
function gen.giveBonusAgainstHorse(unitType) 
    unitType.flags = setBit1(unitType.flags,11)
end

-- gen.removeBonusAgainstHorse(unitType)-->void
function gen.removeBonusAgainstHorse(unitType) 
    unitType.flags = setBit0(unitType.flags,11)
end

-- gen.isFreeSupportUnderFundamentalism(unitType)-->boolean
function gen.isFreeSupportUnderFundamentalism(unitType) 
    return isBit1(unitType.flags,12)
end

-- gen.giveFreeSupportUnderFundamentalism(unitType)-->void
function gen.giveFreeSupportUnderFundamentalism(unitType) 
    unitType.flags = setBit1(unitType.flags,12)
end

-- gen.removeFreeSupportUnderFundamentalism(unitType)-->void
function gen.removeFreeSupportUnderFundamentalism(unitType) 
    unitType.flags = setBit0(unitType.flags,12)
end

-- gen.isDestroyedAfterAttacking(unitType)-->boolean
function gen.isDestroyedAfterAttacking(unitType) 
    return isBit1(unitType.flags,13)
end

-- gen.giveDestroyedAfterAttacking(unitType)-->void
function gen.giveDestroyedAfterAttacking(unitType) 
    unitType.flags = setBit1(unitType.flags,13)
end

-- gen.removeDestroyedAfterAttacking(unitType)-->void
function gen.removeDestroyedAfterAttacking(unitType) 
    unitType.flags = setBit0(unitType.flags,13)
end

-- gen.isBonusAgainstAir(unitType)-->boolean
function gen.isBonusAgainstAir(unitType) 
    return isBit1(unitType.flags,14)
end

-- gen.giveBonusAgainstAir(unitType)-->void
function gen.giveBonusAgainstAir(unitType) 
    unitType.flags = setBit1(unitType.flags,14)
end

-- gen.removeBonusAgainstAir(unitType)-->void
function gen.removeBonusAgainstAir(unitType) 
    unitType.flags = setBit0(unitType.flags,14)
end

-- gen.isSpotSubmarines(unitType)-->boolean
function gen.isSpotSubmarines(unitType) 
    return isBit1(unitType.flags,15)
end

-- gen.giveSpotSubmarines(unitType)-->void
function gen.giveSpotSubmarines(unitType) 
    unitType.flags = setBit1(unitType.flags,15)
end

-- gen.removeSpotSubmarines(unitType)-->void
function gen.removeSpotSubmarines(unitType) 
    unitType.flags = setBit0(unitType.flags,15)
end


-- gen.isCivilDisorder(city)-->boolean
function gen.isCivilDisorder(city)
	return isBit1(city.attributes,1)
end

-- gen.setCivilDisorder(city)-->void
function gen.setCivilDisorder(city)
	 city.attributes = setBit1(city.attributes,1)
end

-- gen.clearCivilDisorder(city)-->void
function gen.clearCivilDisorder(city)
	 city.attributes = setBit0(city.attributes,1)
end

-- gen.isWeLoveTheKing(city)-->boolean
function gen.isWeLoveTheKing(city)
	return isBit1(city.attributes,2)
end

-- gen.setWeLoveTheKing(city)-->void
function gen.setWeLoveTheKing(city)
	 city.attributes = setBit1(city.attributes,2)
end

-- gen.clearWeLoveTheKing(city)-->void
function gen.clearWeLoveTheKing(city)
	 city.attributes = setBit0(city.attributes,2)
end

-- gen.isImprovementSold(city)-->boolean
function gen.isImprovementSold(city)
	return isBit1(city.attributes,3)
end

-- gen.setImprovementSold(city)-->void
function gen.setImprovementSold(city)
	 city.attributes = setBit1(city.attributes,3)
end

-- gen.clearImprovementSold(city)-->void
function gen.clearImprovementSold(city)
	 city.attributes = setBit0(city.attributes,3)
end

-- gen.isTechnologyStolen(city)-->boolean
function gen.isTechnologyStolen(city)
	return isBit1(city.attributes,4)
end

-- gen.setTechnologyStolen(city)-->void
function gen.setTechnologyStolen(city)
	 city.attributes = setBit1(city.attributes,4)
end

-- gen.clearTechnologyStolen(city)-->void
function gen.clearTechnologyStolen(city)
	 city.attributes = setBit0(city.attributes,4)
end

-- gen.isAutoBuild(city)-->boolean
function gen.isAutoBuild(city)
	return isBit1(city.attributes,5)
end

-- gen.setAutoBuild(city)-->void
function gen.setAutoBuild(city)
	 city.attributes = setBit1(city.attributes,5)
end

-- gen.clearAutoBuild(city)-->void
function gen.clearAutoBuild(city)
	 city.attributes = setBit0(city.attributes,5)
end

-- gen.isAttribute6(city)-->boolean
function gen.isAttribute6(city)
	return isBit1(city.attributes,6)
end

-- gen.setAttribute6(city)-->void
function gen.setAttribute6(city)
	 city.attributes = setBit1(city.attributes,6)
end

-- gen.clearAttribute6(city)-->void
function gen.clearAttribute6(city)
	 city.attributes = setBit0(city.attributes,6)
end

-- gen.isAttribute7(city)-->boolean
function gen.isAttribute7(city)
	return isBit1(city.attributes,7)
end

-- gen.setAttribute7(city)-->void
function gen.setAttribute7(city)
	 city.attributes = setBit1(city.attributes,7)
end

-- gen.clearAttribute7(city)-->void
function gen.clearAttribute7(city)
	 city.attributes = setBit0(city.attributes,7)
end

-- gen.isBuildCoastal(city)-->boolean
function gen.isBuildCoastal(city)
	return isBit1(city.attributes,8)
end

-- gen.setBuildCoastal(city)-->void
function gen.setBuildCoastal(city)
	 city.attributes = setBit1(city.attributes,8)
end

-- gen.clearBuildCoastal(city)-->void
function gen.clearBuildCoastal(city)
	 city.attributes = setBit0(city.attributes,8)
end

-- gen.isAttribute9(city)-->boolean
function gen.isAttribute9(city)
	return isBit1(city.attributes,9)
end

-- gen.setAttribute9(city)-->void
function gen.setAttribute9(city)
	 city.attributes = setBit1(city.attributes,9)
end

-- gen.clearAttribute9(city)-->void
function gen.clearAttribute9(city)
	 city.attributes = setBit0(city.attributes,9)
end

-- gen.isAttribute10(city)-->boolean
function gen.isAttribute10(city)
	return isBit1(city.attributes,10)
end

-- gen.setAttribute10(city)-->void
function gen.setAttribute10(city)
	 city.attributes = setBit1(city.attributes,10)
end

-- gen.clearAttribute10(city)-->void
function gen.clearAttribute10(city)
	 city.attributes = setBit0(city.attributes,10)
end

-- gen.isAttribute11(city)-->boolean
function gen.isAttribute11(city)
	return isBit1(city.attributes,11)
end

-- gen.setAttribute11(city)-->void
function gen.setAttribute11(city)
	 city.attributes = setBit1(city.attributes,11)
end

-- gen.clearAttribute11(city)-->void
function gen.clearAttribute11(city)
	 city.attributes = setBit0(city.attributes,11)
end

-- gen.isBuildHydroPlant(city)-->boolean
function gen.isBuildHydroPlant(city)
	return isBit1(city.attributes,12)
end

-- gen.setBuildHydroPlant(city)-->void
function gen.setBuildHydroPlant(city)
	 city.attributes = setBit1(city.attributes,12)
end

-- gen.clearBuildHydroPlant(city)-->void
function gen.clearBuildHydroPlant(city)
	 city.attributes = setBit0(city.attributes,12)
end

-- gen.isAttribute13(city)-->boolean
function gen.isAttribute13(city)
	return isBit1(city.attributes,13)
end

-- gen.setAttribute13(city)-->void
function gen.setAttribute13(city)
	 city.attributes = setBit1(city.attributes,13)
end

-- gen.clearAttribute13(city)-->void
function gen.clearAttribute13(city)
	 city.attributes = setBit0(city.attributes,13)
end

-- gen.isAttribute14(city)-->boolean
function gen.isAttribute14(city)
	return isBit1(city.attributes,14)
end

-- gen.setAttribute14(city)-->void
function gen.setAttribute14(city)
	 city.attributes = setBit1(city.attributes,14)
end

-- gen.clearAttribute14(city)-->void
function gen.clearAttribute14(city)
	 city.attributes = setBit0(city.attributes,14)
end

-- gen.isAttribute15(city)-->boolean
function gen.isAttribute15(city)
	return isBit1(city.attributes,15)
end

-- gen.setAttribute15(city)-->void
function gen.setAttribute15(city)
	 city.attributes = setBit1(city.attributes,15)
end

-- gen.clearAttribute15(city)-->void
function gen.clearAttribute15(city)
	 city.attributes = setBit0(city.attributes,15)
end

-- gen.isAttribute16(city)-->boolean
function gen.isAttribute16(city)
	return isBit1(city.attributes,16)
end

-- gen.setAttribute16(city)-->void
function gen.setAttribute16(city)
	 city.attributes = setBit1(city.attributes,16)
end

-- gen.clearAttribute16(city)-->void
function gen.clearAttribute16(city)
	 city.attributes = setBit0(city.attributes,16)
end

-- gen.isUsedAirport(city)-->boolean
function gen.isUsedAirport(city)
	return isBit1(city.attributes,17)
end

-- gen.setUsedAirport(city)-->void
function gen.setUsedAirport(city)
	 city.attributes = setBit1(city.attributes,17)
end

-- gen.clearUsedAirport(city)-->void
function gen.clearUsedAirport(city)
	 city.attributes = setBit0(city.attributes,17)
end
gen.isAttribute17 = gen.isUsedAirport
gen.setAttribute17 = gen.setUsedAirport
gen.clearAttribute17 = gen.clearUsedAirport

-- gen.isAttribute18(city)-->boolean
function gen.isAttribute18(city)
	return isBit1(city.attributes,18)
end

-- gen.setAttribute18(city)-->void
function gen.setAttribute18(city)
	 city.attributes = setBit1(city.attributes,18)
end

-- gen.clearAttribute18(city)-->void
function gen.clearAttribute18(city)
	 city.attributes = setBit0(city.attributes,18)
end

-- gen.isAttribute19(city)-->boolean
function gen.isAttribute19(city)
	return isBit1(city.attributes,19)
end

-- gen.setAttribute19(city)-->void
function gen.setAttribute19(city)
	 city.attributes = setBit1(city.attributes,19)
end

-- gen.clearAttribute19(city)-->void
function gen.clearAttribute19(city)
	 city.attributes = setBit0(city.attributes,19)
end

-- gen.isAttribute20(city)-->boolean
function gen.isAttribute20(city)
	return isBit1(city.attributes,20)
end

-- gen.setAttribute20(city)-->void
function gen.setAttribute20(city)
	 city.attributes = setBit1(city.attributes,20)
end

-- gen.clearAttribute20(city)-->void
function gen.clearAttribute20(city)
	 city.attributes = setBit0(city.attributes,20)
end

-- gen.isAttribute21(city)-->boolean
function gen.isAttribute21(city)
	return isBit1(city.attributes,21)
end

-- gen.setAttribute21(city)-->void
function gen.setAttribute21(city)
	 city.attributes = setBit1(city.attributes,21)
end

-- gen.clearAttribute21(city)-->void
function gen.clearAttribute21(city)
	 city.attributes = setBit0(city.attributes,21)
end

-- gen.isBuildShips(city)-->boolean
function gen.isBuildShips(city)
	return isBit1(city.attributes,22)
end

-- gen.setBuildShips(city)-->void
function gen.setBuildShips(city)
	 city.attributes = setBit1(city.attributes,22)
end

-- gen.clearBuildShips(city)-->void
function gen.clearBuildShips(city)
	 city.attributes = setBit0(city.attributes,22)
end

-- gen.isCityInvestigated(city)-->boolean
function gen.isCityInvestigated(city)
	return isBit1(city.attributes,23)
end

-- gen.setCityInvestigated(city)-->void
function gen.setCityInvestigated(city)
	 city.attributes = setBit1(city.attributes,23)
end

-- gen.clearCityInvestigated(city)-->void
function gen.clearCityInvestigated(city)
	 city.attributes = setBit0(city.attributes,23)
end
gen.isAttribute23 = gen.isCityInvestigated
gen.setAttribute23 = gen.setCityInvestigated
gen.clearAttribute23 = gen.clearCityInvestigated

-- gen.isAttribute24(city)-->boolean
function gen.isAttribute24(city)
	return isBit1(city.attributes,24)
end


-- gen.setAttribute24(city)-->void
function gen.setAttribute24(city)
	 city.attributes = setBit1(city.attributes,24)
end

-- gen.clearAttribute24(city)-->void
function gen.clearAttribute24(city)
	 city.attributes = setBit0(city.attributes,24)
end

-- gen.isMilitaryAutoBuild(city)-->boolean
function gen.isMilitaryAutoBuild(city)
	return isBit1(city.attributes,25)
end

-- gen.setMilitaryAutoBuild(city)-->void
function gen.setMilitaryAutoBuild(city)
	 city.attributes = setBit1(city.attributes,25)
end

-- gen.clearMilitaryAutoBuild(city)-->void
function gen.clearMilitaryAutoBuild(city)
	 city.attributes = setBit0(city.attributes,25)
end

-- gen.isDomesticAutoBuild(city)-->boolean
function gen.isDomesticAutoBuild(city)
	return isBit1(city.attributes,26)
end

-- gen.setDomesticAutoBuild(city)-->void
function gen.setDomesticAutoBuild(city)
	 city.attributes = setBit1(city.attributes,26)
end

-- gen.clearDomesticAutoBuild(city)-->void
function gen.clearDomesticAutoBuild(city)
	 city.attributes = setBit0(city.attributes,26)
end

-- gen.isObjective(city)-->boolean
function gen.isObjective(city)
	return isBit1(city.attributes,27)
end

-- gen.setObjective(city)-->void
function gen.setObjective(city)
	 city.attributes = setBit1(city.attributes,27)
     -- objective flag overrides major objective flag, so 
     -- remove major objective flag if it exists
     city.attributes = setBit0(city.attributes,29)
end

-- gen.clearObjective(city)-->void
function gen.clearObjective(city)
	 city.attributes = setBit0(city.attributes,27)
end

-- gen.isAttribute28(city)-->boolean
function gen.isAttribute28(city)
	return isBit1(city.attributes,28)
end

-- gen.setAttribute28(city)-->void
function gen.setAttribute28(city)
	 city.attributes = setBit1(city.attributes,28)
end

-- gen.clearAttribute28(city)-->void
function gen.clearAttribute28(city)
	 city.attributes = setBit0(city.attributes,28)
end

-- gen.isMajorObjective(city)-->boolean
function gen.isMajorObjective(city)
	return isBit1(city.attributes,29)
end

-- gen.setMajorObjective(city)-->void
function gen.setMajorObjective(city)
	 city.attributes = setBit1(city.attributes,29)
     -- objective flag overrides major objective flag, so 
     -- remove it
     city.attributes = setBit0(city.attributes,27)
end

-- gen.clearMajorObjective(city)-->void
function gen.clearMajorObjective(city)
	 city.attributes = setBit0(city.attributes,29)
end

-- gen.isUsedTransporter(city)-->boolean
function gen.isUsedTransporter(city)
	return isBit1(city.attributes,30)
end
gen.isAttribute30 = gen.isUsedTransporter

-- gen.setUsedTransporter(city)-->void
function gen.setUsedTransporter(city)
	 city.attributes = setBit1(city.attributes,30)
end
gen.setAttribute30 = gen.setUsedTransporter

-- gen.clearUsedTransporter(city)-->void
function gen.clearUsedTransporter(city)
	 city.attributes = setBit0(city.attributes,30)
end
gen.clearAttribute30 = gen.clearUsedTransporter

-- gen.isAttribute31(city)-->boolean
function gen.isAttribute31(city)
	return isBit1(city.attributes,31)
end

-- gen.setAttribute31(city)-->void
function gen.setAttribute31(city)
	 city.attributes = setBit1(city.attributes,31)
end

-- gen.clearAttribute31(city)-->void
function gen.clearAttribute31(city)
	 city.attributes = setBit0(city.attributes,31)
end

-- gen.isAttribute32(city)-->boolean
function gen.isAttribute32(city)
	return isBit1(city.attributes,32)
end

-- gen.setAttribute32(city)-->void
function gen.setAttribute32(city)
	 city.attributes = setBit1(city.attributes,32)
end

-- gen.clearAttribute32(city)-->void
function gen.clearAttribute32(city)
	 city.attributes = setBit0(city.attributes,32)
end

--
--
-- gen.wonderModifiedMoves(unit)-->integer
-- returns the movement allowance of a unit after
-- taking into account nuclear power, wonders
-- returns atomic movement points
function gen.wonderModifiedMoves(unit)
    local fullHpMove = unit.type.move
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)) then
            fullHpMove = fullHpMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if applyWonderBonus(12,unit.owner) then
            fullHpMove = fullHpMove+2*totpp.movementMultipliers.aggregate
        end
        if applyWonderBonus(3,unit.owner) and not gen.isCoastal(unit.type) then
            fullHpMove = fullHpMove + totpp.movementMultipliers.aggregate
        end
    end
    return fullHpMove
end
--
-- maxMoves(unit)--> integer
-- gen.maxMoves(unit) --> integer
-- returns movement allowance for a unit after taking damage
-- into account, multiplied by the road/rail multiplier
-- Helper Function (provided as both local function and in table
function maxMoves(unit)
    local fullHpMove = unit.type.move
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)) then
            fullHpMove = fullHpMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if applyWonderBonus(12,unit.owner) then
            fullHpMove = fullHpMove+2*totpp.movementMultipliers.aggregate
        end
        if applyWonderBonus(3,unit.owner) and not gen.isCoastal(unit.type) then
            fullHpMove = fullHpMove + totpp.movementMultipliers.aggregate
        end
    end
    local moveAllowance = (unit.hitpoints*fullHpMove)//unit.type.hitpoints
    local moveMult = totpp.movementMultipliers.aggregate
    if moveAllowance % moveMult > 0 then
        moveAllowance = moveAllowance - moveAllowance % moveMult + moveMult
    end
    if unit.type.domain == 0 or unit.type.domain >= 3 then
        return math.min(math.max( moveAllowance,moveMult),fullHpMove)
    elseif unit.type.domain == 1 then
        return fullHpMove
    elseif unit.type.domain == 2 then
        return math.min(math.max( moveAllowance,2*moveMult),fullHpMove)
    end
end
gen.maxMoves = maxMoves

-- gen.moveRemaining(unit)
-- returns gen.maxMoves-unit.moveSpent
local function moveRemaining(unit)
    return maxMoves(unit)-unit.moveSpent
end
gen.moveRemaining = moveRemaining

--#gen.inPolygon(tile,tableOfCoordinates)-->bool
-- the table of coordinates defines the corners of the
-- polygon.  Returns true if the tile is within the
-- polygon defined by the table of coordinates, and
-- false otherwise.  Checking that the map is correct
-- must be done separately
-- the entry:
-- tableOfCoordinates.doesNotCrossThisX
-- sets an x coordinate that the polygon does not
-- cross.  If absent, 0 is used,
-- meaning the polygon shouldn't cross the date line
--
--
-- Method (not necessary to understand for use)
-- (Note: I will use the "regular" mathematical coordinate system
-- in this explanation and code (i.e. positive y is "up" or "north").
-- All this does is reflect the coordinate system across the X-axis,
-- but it makes it easier for me to reason about.)
-- Suppose a line L connects the point (x,y) to
-- another point (X,Y), and (X,Y) is not in the
-- polygon.  If (x,y) is strictly in the polygon, the line
-- L will cross the boundary of the polygon an odd number
-- of times.  If (x,y) is strictly outside the polygon,
-- L will cross the boundary of the polygon an even number of
-- times.
-- It is easy enough to check the case where (x,y) is actually
-- on the boundary of the polygon, but difficulty arises
-- if a side of the polygon overlaps L.
-- Hence, we must avoid that case.
-- Also, there is some trouble in practice when L crosses a
-- vertex of the polygon (since it will look like it is
-- crossing two line segments, when there should only be a single
-- crossing counted.
--
-- For ease of calculation, it makes sense to use vertical
-- and/or horizontal lines for L, but this makes the likelihood
-- of a polygon side overlapping with L very high, and
-- runs in to the corner problem.
--
-- To avoid this, we will check points four points (x+-e,y+-e)
-- where e is small.  If only integer coordinates are used for the
-- polygon, this eliminates overlapping L with polygon sides, and
-- the possibility that L crosses a polygon vertex.
-- If any of the four points are considered "in" the
-- polygon, the tile is considered in the polygon, and
-- true is returned.  With e sufficiently small, this is unlikely
-- to "catch" tiles that "shouldn't" be in the polygon
--
-- To compensate for crossing the date line, if any x coordinate is
-- less than tableOfCoordinates.doesNotCrossThisX, that x coordinate is
-- replaced by x+mapWidth for all calculations (both tile coordinate and
-- tile x value itself
-- Note that if doesNotCrossThisX has 0 value, no compensation is made
function gen.inPolygon(tile,tableOfCoordinates)
    -- polygon doesn't cross this x value
    local xBound = tableOfCoordinates.doesNotCrossThisX or 0
    local width,height,maps = civ.getMapDimensions()
    local function isNumericallyEqual(LHS,RHS)
        return math.abs(LHS-RHS) <= 1e-6
    end
    -- gets the Y value of the intersection of 
    -- L1 and L2, where
    -- L1 is defined as x=xStar
    -- L2 is the line through (x1,y1) and (x2,y2)
    local function getYStar(xStar,x1,y1,x2,y2)
        if x1==x2 then
            return nil
            -- the lines are parallel, either no solution
            -- or lines overlap
        end
        return ((y2-y1)/(x2-x1))*(xStar-x1)+y1
    end
    -- returns true if (a,b) is on the line
    -- segment defined by (x1,y1) and (x2,y2)
    -- note line segment, not entire line
    local function pointInSegment(a,b,x1,y1,x2,y2)
        local xLow,xHigh = math.min(x1,x2),math.max(x1,x2)
        local yLow,yHigh = math.min(y1,y2),math.max(y1,y2)
        local LHS = (b-y1)*(x2-x1)
        local RHS = (y2-y1)*(a-x1)
        if a<xLow or a>xHigh or b<yLow or b>yHigh then
            return false
        else
            return isNumericallyEqual(LHS,RHS)
        end
    end
    -- path(a,b) means the path from (a,b) to the point
    -- (a,-3) from here on
    -- returns true if path(a,b) crosses segment(x1,y1,x2,y2)
    local function pathCrossesSegment(a,b,x1,y1,x2,y2)
        -- case where the same point is entered twice
        if x1==x2 and y1==y2 then
            return isNumericallyEqual(a,x1) and isNumericallyEqual(b,y1)
        end
        local xLow,xHigh = math.min(x1,x2),math.max(x1,x2)
        -- I don't check for numerical equality here, since xi,yi should
        -- be integers, and a,b will be integers and a small perturbation 
        if a < xLow or a > xHigh then
            return false
        end
        -- here, the line (a,b) (a,-3) crosses the segment(x1,y1)(x2,y2),
        -- but we have to check if path(a,b) crosses the segment(x1,y1,x2,y2)
        -- first, get yStar
        local yStar = getYStar(a,x1,y1,x2,y2)
        -- since b>-3 (well, we can choose -math.huge instead of -3 for the end point
        -- it really doesn't matter), path(a,b) crosses segment(x1,y1,x2,y2) if 
        -- yStar <= b
        -- so check yStar<b and check for numerical equality also, just in case
        return (yStar < b) or isNumericallyEqual(b,yStar)
    end
    local e = 1e-3
    local point = {x=tile.x,y=tile.y}
    local numberOfVertices = #tableOfCoordinates
    if numberOfVertices == 0 then
        return false
    elseif numberOfVertices == 1 then
        return point.x == tableOfCoordinates[1][1] and point.y == tableOfCoordinates[1][2]
    end
    -- compensate for the x boundary
    if point.x < xBound then
        point.x = point.x+width
    end
    local northEast = {x=point.x+e,y=point.y+e}
    local northWest = {x=point.x-e,y=point.y+e}
    local southEast = {x=point.x+e,y=point.y-e}
    local southWest = {x=point.x-e,y=point.y-e}
    local northEastCrossings = 0
    local northWestCrossings = 0
    local southEastCrossings = 0
    local southWestCrossings = 0
    for i=1,numberOfVertices-1 do
        -- note, we'll deal with the segment between the last vertex and the first
        -- as a separate line
        local x1=tableOfCoordinates[i][1]
        -- compensate for x boundary
        if x1 < xBound then
            x1 = x1+width
        end
        local y1=tableOfCoordinates[i][2]
        local x2=tableOfCoordinates[i+1][1]
        -- compensate for x boundary
        if x2 < xBound then
            x2 = x2+width
        end
        local y2=tableOfCoordinates[i+1][2]
        if pointInSegment(point.x,point.y,x1,y1,x2,y2) then
            return true
        end
        if pathCrossesSegment(northEast.x,northEast.y,x1,y1,x2,y2) then
            northEastCrossings=northEastCrossings+1
        end
        if pathCrossesSegment(northWest.x,northWest.y,x1,y1,x2,y2) then
            northWestCrossings=northWestCrossings+1
        end
        if pathCrossesSegment(southEast.x,southEast.y,x1,y1,x2,y2) then
            southEastCrossings=southEastCrossings+1
        end
        if pathCrossesSegment(southWest.x,southWest.y,x1,y1,x2,y2) then
            southWestCrossings=southWestCrossings+1
        end
    end
    -- note, we'll deal with the segment between the last vertex and the first
    -- as a separate line
    local x1=tableOfCoordinates[numberOfVertices][1]
    if x1 < xBound then
        x1 = x1+width
    end
    local y1=tableOfCoordinates[numberOfVertices][2]
    local x2=tableOfCoordinates[1][1]
    if x2 < xBound then
        x2 = x2+width
    end
    local y2=tableOfCoordinates[1][2]
    if pointInSegment(point.x,point.y,x1,y1,x2,y2) then
        return true
    end
    if pathCrossesSegment(northEast.x,northEast.y,x1,y1,x2,y2) then
        northEastCrossings=northEastCrossings+1
    end
    if pathCrossesSegment(northWest.x,northWest.y,x1,y1,x2,y2) then
        northWestCrossings=northWestCrossings+1
    end
    if pathCrossesSegment(southEast.x,southEast.y,x1,y1,x2,y2) then
        southEastCrossings=southEastCrossings+1
    end
    if pathCrossesSegment(southWest.x,southWest.y,x1,y1,x2,y2) then
        southWestCrossings=southWestCrossings+1
    end
    -- if the number of crossings for any of these is odd, then we
    -- return true, since at least one of the four nearby coordinates
    -- is inside the polygon
    return (northEastCrossings % 2 == 1) or (northWestCrossings % 2 == 1)
        or (southEastCrossings % 2 == 1) or (southWestCrossings % 2 == 1)
end

-- gen.cityCanSupportAnotherUnit(city)-->bool
-- returns true if the city has enough production to support all existing
-- units and at least one other unit
-- Units that get free support under fundamentalism are still counted as
-- "supported", since they still take up a free support "slot" if they are
-- among the first 8 units supported by the city
function gen.cityCanSupportAnotherUnit(city)
    local unitsSupported = 0
    -- check that unit's location is a tile, otherwise dead units show
    -- up in the count
    for unit in civ.iterateUnits() do
        if unit.homeCity and unit.homeCity == city and unit.type.role <= 5 and
            civ.getTile(unit.location.x,unit.location.y,unit.location.z) then
            unitsSupported = unitsSupported +1
        end
    end
	local freeSupport = 0
	local govtNumber = city.owner.government
	if govtNumber <= 1 then
		-- anarchy or despotism
		freeSupport = city.size
	elseif govtNumber == 2 then
		-- monarchy
		freeSupport = civ.cosmic.supportMonarchy
	elseif govtNumber == 3 then
		-- communism
		freeSupport = civ.cosmic.supportCommunism
	elseif govtNumber == 4 then
		freeSupport = civ.cosmic.supportFundamentalism
	end
	return (freeSupport+city.totalShield - unitsSupported) > 0 
end

-- gen.rehomeUnitsInCapturedCity(city,defender) --> void
-- re-homes units in a captured city to other cities owned by
-- the same tribe, so that they are not disbanded
function gen.rehomeUnitsInCapturedCity(city,defender)
	local citySupportTable = {}
	for unit in civ.iterateUnits() do
    -- check that unit's location is a tile, otherwise dead units show
    -- up in the count
		if unit.homeCity and  civ.getTile(unit.location.x,unit.location.y,unit.location.z) and unit.type.role <= 5 then
			citySupportTable[unit.homeCity.id] = citySupportTable[unit.homeCity.id] or 0
			citySupportTable[unit.homeCity.id] = citySupportTable[unit.homeCity.id]+1
		end
	end
	local function canSupportAnotherUnit(city)
		local freeSupport = 0
		local govtNumber = city.owner.government
		if govtNumber <= 1 then
			-- anarchy or despotism
			freeSupport = city.size
		elseif govtNumber == 2 then
			-- monarchy
			freeSupport = civ.cosmic.supportMonarchy
		elseif govtNumber == 3 then
			-- communism
			freeSupport = civ.cosmic.supportCommunism
		elseif govtNumber == 4 then
			freeSupport = civ.cosmic.supportFundamentalism
		end
		-- make sure citySupportTable has an entry for this city
		citySupportTable[city.id] = citySupportTable[city.id] or 0
		return (freeSupport+city.totalShield - citySupportTable[city.id])> 0 	
    end
	for unit in civ.iterateUnits() do
		if unit.owner == defender and unit.homeCity == city and civ.getTile(unit.location.x,unit.location.y,unit.location.z) then
			local bestCitySoFar = nil
			local bestDistanceSoFar = 1000000
			for candidateCity in civ.iterateCities() do
				if candidateCity.owner == defender and canSupportAnotherUnit(candidateCity) 
					and tileDist(candidateCity.location,unit.location) <bestDistanceSoFar then
					bestCitySoFar = candidateCity
					bestDistanceSoFar = tileDist(bestCitySoFar.location,unit.location)
				end
			end
			unit.homeCity = bestCitySoFar
			if unit.type.role <= 5 then
				citySupportTable[bestCitySoFar.id]= (citySupportTable[bestCitySoFar.id] or 0)+1
			end
		end
	end
end

--#gen.homeToNearestCity(unit)-->void
--  finds the nearest city (of the same tribe) that can support another
--  unit, and sets the unit's home city to that city
--  if there is no suitable city, the unit's home city isn't changed
function gen.homeToNearestCity(unit)
    local bestDist = 1000000
    local bestCity = nil
    local function dist(unit,city)
        return tileDist(unit.location,city.location,0)
    end
    for city in civ.iterateCities() do
        if city.owner == unit.owner and dist(unit,city) < bestDist and
            gen.cityCanSupportAnotherUnit(city) then
            bestCity = city
            bestDist = dist(unit,city)
        end
    end
    if bestCity then
        unit.homeCity = bestCity
    end
end




-- gen.selectNextActiveUnit(activeUnit,source,customWeightFn)-->void
-- use as the first line inside the function given to
-- civ.scen.onActivateUnit(function(unit,source)-->void)
-- the line should be
--      gen.selectNextActiveUnit(unit,source,customWeightFn)
--      (note: if the arguments to function(unit,source)
--      arent called 'unit' and 'source', use the actual name)
-- Code sets all other units (owned by the same tribe)
-- to the wait order, except the next best unit
-- customWeightFn(unit,activeUnit)-->integer
-- gives 'weight' to each unit, and the unit with the lowest weight will
-- be activated next
-- By default, weight is +1 if unit is not same type as active unit
-- + 2 per square for distance between activeUnit and unit
-- + 10000 if on different maps
-- Units ordered to 'wait' are tracked, and won't be selected again until all
-- other units are also 'waiting'
--
-- No impact on AI tribes
-- 
-- This table keeps track of units manually ordered to wait
-- will not be preserved between save/load
local waitingUnits = {}
-- this makes sure the active unit is the one put into the waitingUnits table,
-- not the next unit the game would activate
local saveActiveUnit = nil

-- put in onKeyPress
--      if civ.getActiveUnit() and keyID == 87 then
--          gen.betterUnitManualWait()
--      end
function gen.betterUnitManualWait()
    if saveActiveUnit then
        waitingUnits[saveActiveUnit.id]=true
    end
end

-- this empties the waitingUnits table, so that units
-- will appear according to the weight function
function gen.clearManualWait()
    for key,value in pairs(waitingUnits) do
        waitingUnits[key] = nil
    end
end


function gen.selectNextActiveUnit(activeUnit,source,customWeightFn)
    if  (not civ.getCurrentTribe().isHuman) then
        -- If the AI is playing, we don't want to interfere
        return 
    end
    saveActiveUnit = activeUnit
    -- if unit activated manually, clear the manual wait for that unit
    if source then
        waitingUnits[activeUnit.id]=nil
    end
    local bestWaitingUnit = nil
    local bestWaitingValue = math.huge
    local bestNotWaitingUnit = nil
    local bestNotWaitingValue = math.huge
    local gotoUnitWithMovementLeft = false
    local function defaultWeightFunction(unit,activeUnit)
        local weight = 0
        if unit.type ~= activeUnit.type then
            weight = weight+1
        end
        if unit.location.z ~= activeUnit.location.z then
            weight = weight+10000
        end
        weight = weight+tileDist(unit.location,activeUnit.location)
        return weight
    end
    customWeightFn = customWeightFn or defaultWeightFunction


    local activeTribe = civ.getCurrentTribe()
    for unit in civ.iterateUnits() do
        if unit.owner== activeTribe and moveRemaining(unit) > 0 and unit ~=activeUnit then
            if unit.order & 0xFF == 0xFF then
                gen.setToWaiting(unit)
                if waitingUnits[unit.id] and customWeightFn(unit,activeUnit) < bestWaitingValue then
                    bestWaitingUnit = unit
                    bestWaitingValue = customWeightFn(unit,activeUnit)
                end
                if not waitingUnits[unit.id] and customWeightFn(unit,activeUnit) < bestNotWaitingValue then
                    
                    bestNotWaitingUnit = unit
                    bestNotWaitingValue = customWeightFn(unit,activeUnit)
                end
            elseif unit.gotoTile then
                gotoUnitWithMovementLeft=true
            end
        end
    end
    if not (bestNotWaitingUnit or bestWaitingUnit) then
        -- only one active unit left
        return
    end
    if gotoUnitWithMovementLeft then
        -- we want to process all units with goto orders first
        -- so don't clear the 'wait' command for any unit
        return
    end
    if not bestNotWaitingUnit then
        -- all units are waiting, so clear the waitingUnits table
        for index,value in pairs(waitingUnits) do
            waitingUnits[index]=false
        end
        gen.clearWaiting(bestWaitingUnit)
    else
        gen.clearWaiting(bestNotWaitingUnit)
    end
end

local activationFunction = function(unit,source) error("Use gen.linkActivationFunction to specify the function to be run when a unit is activated.") end



-- gen.activate(unit)-->void
-- use to activate a unit.  This assumes that the 'source' of the activation is true
-- (i.e. human generated).  Use gen.activateWithSource if false is needed (either sometimes or always)
function gen.activate(unit)
    unit:activate()
    activationFunction(unit,true)
end

--#gen.activateSource(unit,source)-->void
-- use to activate a unit and specify the source of the activation
function gen.activateWithSource(unit,source)
    unit:activate()
    activationFunction(unit,source)
end

--#gen.linkActivationFunction(function(unit,source)-->void)-->void
-- use to specify the code that should be run when a unit is
-- activated by gen.activate or gen.activateWtihSource
function gen.linkActivationFunction(activationFn)
    if type(activationFn) == "function" then
        activationFunction = activationFn
    else
        error("gen.linkActivationFunction requires a function as the argument.")
    end
end


--gen.getActivationFunction()-->function(unit,source)
--provides the unit activation function linked to the general library
function gen.getActivationFunction()
    return activationFunction
end


--gen.getTileID(tileObject or int,int or nil,int or nil)-->int (by Knighttime, converts a tile/coordinates to a single integer as an ID number)
-- Returns a single-value numeric key that uniquely identifies a tile on any map
--[[ by Knighttime, modified by Prof. Garfield ]]
function gen.getTileID (tileORX,y,z)
    local tile=nil
    if civ.isTile(tileORX) then
        tile = tileORX
    else
        tile = civ.getTile(tileORX,y,z or 0)
    end
	if tile == nil then
		error("ERROR: \"getTileID\" function called with an invalid tile or coordinates")
		return nil
	end
	local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
	local mapOffset = tile.z * mapWidth * mapHeight
	local tileOffset = tile.x + (tile.y * mapWidth)
	return mapOffset + tileOffset
end
gen.getTileId = gen.getTileID

-- gen.getTileFromID(tileID) --> tileObject
function gen.getTileFromID(ID)
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
gen.getTileFromId = gen.getTileFromID



--gen.unitTypeOnTile(tile,unitTypeOrTableOfUnitType)-->bool
--returns true if tile has any of the unit types listed in the table,
--false otherwise
function gen.unitTypeOnTile(tile,unitTypeTable)
    if civ.isUnitType(unitTypeTable) then
        unitTypeTable = {unitTypeTable}
    end
    for unit in tile.units do
        for __,unitType in pairs(unitTypeTable) do
            if unit.type == unitType then
                return true
            end
        end
    end
    return false
end

--#gen.getAdjacentTiles(tile)-->tableOfTiles
-- returns a table (indexed by integers) with all adjacent
-- tiles to the input tile
local function getAdjacentTiles(tile)
    tile = toTile(tile)
    local xVal,yVal,zVal = tile.x,tile.y,tile.z
    if civ.game.rules.flatWorld then
        return {civ.getTile(xVal-2,yVal,zVal),
                civ.getTile(xVal-1,yVal+1,zVal),
                civ.getTile(xVal,yVal+2,zVal),
                civ.getTile(xVal+1,yVal+1,zVal),
                civ.getTile(xVal+2,yVal,zVal),
                civ.getTile(xVal+1,yVal-1,zVal),
                civ.getTile(xVal,yVal-2,zVal),
                civ.getTile(xVal-1,yVal-1,zVal),}
    else
        local xMax,yMax,zMax = civ.getMapDimensions()
        return {civ.getTile((xVal-2)%xMax,yVal,zVal),
                civ.getTile((xVal-1)%xMax,yVal+1,zVal),
                civ.getTile((xVal)%xMax,yVal+2,zVal),
                civ.getTile((xVal+1)%xMax,yVal+1,zVal),
                civ.getTile((xVal+2)%xMax,yVal,zVal),
                civ.getTile((xVal+1)%xMax,yVal-1,zVal),
                civ.getTile((xVal)%xMax,yVal-2,zVal),
                civ.getTile((xVal-1)%xMax,yVal-1,zVal),}
    end
end
gen.getAdjacentTiles = getAdjacentTiles

-- gen.moveUnitAdjacent(unit,destRankFn=suitableDefault)-->tile or bool
-- Moves the unit to an adjacent tile, choosing the tile based on the 
-- destRankFn(unit,tile)--> integer or false
-- lower values mean preferred tiles, false means unit can't move to tile
-- default is prefer empty squares before squares with units on them
-- returns the tile the unit is moved to, or false if the unit can't be moved
local function moveUnitAdjacent(unit,destRankFn)
    local function defaultDestinationRank(theUnit,destTile)
        if (destTile.defender and destTile.defender ~=theUnit.owner) or(destTile.city and destTile.city.owner ~= theUnit.owner) or (not civ.canEnter(theUnit.type,destTile)) then
            return false
        end
        if destTile.defender then
            return 1
        else
            return 0
        end
    end
    destRankFn = destRankFn or defaultDestinationRank
    local bestTile = nil
    local bestRank = math.huge
    local tileList = getAdjacentTiles(unit.location)
    for __,destTile in pairs(tileList) do
        local rank = destRankFn(unit,destTile)
        if rank and rank < bestRank then
            bestTile = destTile
            bestRank = rank
        end
    end
    if bestTile then
        unit:teleport(bestTile)
        return bestTile
    else
        return false
    end
end
gen.moveUnitAdjacent = moveUnitAdjacent

--#gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile)-->void
-- isProtectingUnit(unit)-->bool
-- if true, the unit is a 'protecting' unit that must be moved
-- e.g. air units with range >= 2 in air protected stacks
-- isProtectedUnit(unit)-->bool
-- if true, the unit is a 'protected' unit, meaning that 'protecting' units
-- must be moved off square if one is on it
-- e.g. land and sea units in air protected stacks
-- isProtectedTile(tile)-->bool
-- if true, the protecting unit must be moved, if not it can stay
-- e.g. clear tiles are true in air protected stacks,
-- cities, airbases, tiles with carriers return false for air protected stacks

function gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile,destRankFn)
    -- if the tile has no defender, it is not protected
    if tile.defender == nil then
        return
    end
    -- if the tile is not protected, we don't need to check anything
    if not isProtectedTile(tile) then
        return
    end
    local protectedUnitOnTile = false
    for unit in tile.units do
        if isProtectedUnit(unit) then
            protectedUnitOnTile = true
            break
        end
    end
    -- if there are no protected units
    if not protectedUnitOnTile then
        return
    end
    for unit in tile.units do
        if isProtectingUnit(unit) then
            moveUnitAdjacent(unit,destRankFn)
        end
    end
end

--#gen.clearAirProtection(tile)-->void
-- A basic function to move air units protecting stacks
-- from a tile

function gen.makeClearAirProtection()
    local function isProtectedTile(tile)
        if tile.city or gen.hasAirbase(tile) then
            return false
        end
        for unit in tile.units do
            if gen.isCarryAir(unit.type) then
                return false
            end
        end
        return true
    end
    local function isProtectingUnit(unit)
        if unit.type.domain == 1 and unit.type.range >= 2 then
            return true
        else
            return false
        end
    end
    local function isProtectedUnit(unit)
        return not isProtectingUnit(unit)
    end
    local function tileHasGroundUnit(tile)
        for unit in tile.units do
            if isProtectedUnit(unit) then
                return true
            end
        end
        return false
    end
    local function tileRank(unit,tile)
        -- don't want an air unit to be moved to a
        -- city, airbase, or carrier
        if not isProtectedTile(tile) then
            return false
        end
        if (tile.defender and tile.defender ~=unit.owner) or
            (tile.city and tile.city.owner ~= unit.owner) or
            (not civ.canEnter(unit.type,tile)) then
            return false
        end
        if tile.defender == nil then
            return 0
        elseif tileHasGroundUnit(tile) then
            return 2
        else
            return 1
        end
    end
    return function(tile)  gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile,tileRank) end
end
local clearAirProtection = gen.makeClearAirProtection()
gen.clearAirProtection = clearAirProtection


--#gen.clearAdjacentAirProtection(unit) -->void 
--clears air protection for tiles adjacent to the unit that are not owned by the unit's owner
function gen.clearAdjacentAirProtection(unit)
    local tileList = getAdjacentTiles(unit.location)
    for __,tile in pairs(tileList) do
        if tile.defender and tile.defender ~= unit.owner then
            clearAirProtection(tile)
        end
    end
end

--#gen.inTable(object,table)--> bool
-- determines if the object is a value in the table
function gen.inTable(object,table)
    for key,value in pairs(table) do
        if value == object then
            return true
        end
    end
    return false
end

--#gen.copyTable(table)-->table
-- constructs (and returns) a new table with the same keys as the input
-- tables within the table are also copied
local function copyTable(table)
    if type(table) ~= "table" then
        return table
    end
    local newTable = {}
    for key,value in pairs(table) do
        newTable[key] = copyTable(value)
    end
    return newTable
end
gen.copyTable = copyTable


--#gen.errorForNilKey(table,tableName)-->void
-- generates an error when a key with a nil
-- value is accessed from the table
-- useful for debugging in certain circumstances
function gen.errorForNilKey(table,tableName)
    local mt = getmetatable(table) or {}
    setmetatable(table,mt)
    mt.__index = function(myTable,key) error("The "..tableName.." table doesn't have a value associated with "..tostring(key)..".") end
end
-- gen.noNewKey(table,tableName)-->void
-- generates an error if attempting to set a key in
-- a table that doesn't already exist
function gen.noNewKey(table,tableName)
    local mt = getmetatable(table) or {}
    setmetatable(table,mt)
    mt.__newindex = function(myTable,key)
        error("The "..tableName.." table can't accept values for indices that don't already exist.  Key value is: "..tostring(key))end
end

-- gen.noGlobal()
-- after gen.noGlobal is run, errors will be generated when trying to create a new
-- global variable, or when accessing a global variable that doesn't already exist
-- if you want to have a 'console' table to access certain functions from the console,
-- you should declare it (but you don't have to fill it) before running this function
function gen.noGlobal()
    gen.errorForNilKey(_G,"Global")
    gen.noNewKey(_G,"Global")
end

local state = "stateNotLinked"

-- gen.linkState(stateTable)
-- links the state table to the General Library
-- provides access to the state table so that
-- gen.getState() can provide it


function gen.linkState(stateTable)
    if type(stateTable) == "table" then
        state = stateTable
    else
        error("gen.linkState: linkState takes a table as an argument.")
    end
end

-- gen.getState()
-- returns the state table submitted to gen.linkState
-- If you're writing a module intended for use by others,
-- it is recommended that
-- you use a linkState system with a sub table, so that
-- table keys don't accidentally conflict
function gen.getState()
    return state
end

-- gen.cityRadiusTiles(cityOrTileOrCoordTable) --> table
--  returns a table of tiles around a center tile, the 
--  size of a city 'footprint'.  The indices are listed below
--  and are based on how city.workers determines which tiles
--  are worked
--
--      
--
--      #       #       #       #       #
--          #       #       #       #       #
--      #       #       #       #       #
--          #       20      13      #       #
--      #       12      8       9       #
--          19      7       1       14      #
--      #       6       21      2       #
--          18      5       3       15      #
--      #       11      4       10      #
--          #       17      16      #       #
--      #       #       #       #       #
--          #       #       #       #       #
--
--
function gen.cityRadiusTiles(input)
    if civ.isCity(input) then
        input = input.location
    end
    local tile = toTile(input)
    local xVal = tile.x
    local yVal = tile.y
    local zVal = tile.z
    if civ.game.rules.flatWorld then
        return {
        [1] = civ.getTile(xVal+1,yVal-1,zVal),
        [2] = civ.getTile(xVal+2,yVal,zVal),
        [3] = civ.getTile(xVal+1,yVal+1,zVal),
        [4] = civ.getTile(xVal,yVal+2,zVal),
        [5] = civ.getTile(xVal-1,yVal+1,zVal),
        [6] = civ.getTile(xVal-2,yVal,zVal),
        [7] = civ.getTile(xVal-1,yVal-1,zVal),
        [8] = civ.getTile(xVal,yVal-2,zVal),
        [9] = civ.getTile(xVal+2,yVal-2,zVal),
        [10] = civ.getTile(xVal+2,yVal+2,zVal),
        [11] = civ.getTile(xVal-2,yVal+2,zVal),
        [12] = civ.getTile(xVal-2,yVal-2,zVal),
        [13] = civ.getTile(xVal+1,yVal-3,zVal),
        [14] = civ.getTile(xVal+3,yVal-1,zVal),
        [15] = civ.getTile(xVal+3,yVal+1,zVal),
        [16] = civ.getTile(xVal+1,yVal+3,zVal),
        [17] = civ.getTile(xVal-1,yVal+3,zVal),
        [18] = civ.getTile(xVal-3,yVal+1,zVal),
        [19] = civ.getTile(xVal-3,yVal-1,zVal),
        [20] = civ.getTile(xVal-1,yVal-3,zVal),
        [21] = civ.getTile(xVal,yVal,zVal),
        }
    else
        local width,height,maps = civ.getMapDimensions()
        return {
        [1] = civ.getTile((xVal+1)%width,yVal-1,zVal),
        [2] = civ.getTile((xVal+2)%width,yVal,zVal),
        [3] = civ.getTile((xVal+1)%width,yVal+1,zVal),
        [4] = civ.getTile((xVal)%width,yVal+2,zVal),
        [5] = civ.getTile((xVal-1)%width,yVal+1,zVal),
        [6] = civ.getTile((xVal-2)%width,yVal,zVal),
        [7] = civ.getTile((xVal-1)%width,yVal-1,zVal),
        [8] = civ.getTile((xVal)%width,yVal-2,zVal),
        [9] = civ.getTile((xVal+2)%width,yVal-2,zVal),
        [10] = civ.getTile((xVal+2)%width,yVal+2,zVal),
        [11] = civ.getTile((xVal-2)%width,yVal+2,zVal),
        [12] = civ.getTile((xVal-2)%width,yVal-2,zVal),
        [13] = civ.getTile((xVal+1)%width,yVal-3,zVal),
        [14] = civ.getTile((xVal+3)%width,yVal-1,zVal),
        [15] = civ.getTile((xVal+3)%width,yVal+1,zVal),
        [16] = civ.getTile((xVal+1)%width,yVal+3,zVal),
        [17] = civ.getTile((xVal-1)%width,yVal+3,zVal),
        [18] = civ.getTile((xVal-3)%width,yVal+1,zVal),
        [19] = civ.getTile((xVal-3)%width,yVal-1,zVal),
        [20] = civ.getTile((xVal-1)%width,yVal-3,zVal),
        [21] = civ.getTile((xVal)%width,yVal,zVal),
        }
    end
end

    

-- gen.getTilesInRadius(centre,radius,minRadius=0,maps=nil) --> table
--      produces a table of nearby tiles to centre,
--      lower index means closer tile (or, same distance),
--      not counting z axis if multiple maps are used
--      starts at 1, no missing indices (if a tile doesn't exist, there
--      won't be an empty entry, the next tile will use that entry)
--      centre = a tile or table of coordinates 
--          central til around which we will find tiles
--      radius = integer
--          is the distance (in tiles, not coordinates) from the centre to the furthest
--          tiles desired
--      minRadius = integer
--          is the distance in tiles from the centre for the nearest tile to be
--          included (e.g. if you don't want centre itself, set minRadius to 1, if you
--          want a ring only, set minRadius to radius)
--      maps = nil or integer in 0-3 or table of integers
--          if nil, only get tiles from the map that centre is on
--          if integer, only get tiles from that map
--          if table of integers, tiles from all maps listed
--          e.g. {1,3} means get tiles from maps 1 and 3
--
--      
function gen.getTilesInRadius(centre,radius,minRadius,maps)
    centre = toTile(centre)
    local cX,cY,cZ = centre.x,centre.y,centre.z
    minRadius = minRadius or 0
    local doMap = {}
    if type(maps) == "number" then
        doMap[maps] = true
    elseif type(maps) == "table" then
        for __,mapNumber in pairs(maps) do
            doMap[mapNumber] = true
        end
    else
        doMap[centre.z] = true
    end
    local function addTileRing(centreX,centreY,rad,map,table,firstUnusedIndex,width) --> next unused index
        local index = firstUnusedIndex
        local twoDist = 2*rad
        if civ.game.rules.flatWorld then
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX+i,centreY+twoDist-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX+twoDist-i,centreY-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX-i,centreY-twoDist+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX-twoDist+i,centreY+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
        else
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX+i)%width,centreY+twoDist-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX+twoDist-i)%width,centreY-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX-i)%width,centreY-twoDist+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX-twoDist+i)%width,centreY+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
        end
        -- the central tile won't be captured above
        if rad==0 then
            local nextTile = civ.getTile(centreX,centreY,map)
            if nextTile then
                table[index] = nextTile
                index= index+1
            end
        end
        return index
    end
    local mapWidth,mapHeight,numberOfMaps = civ.getMapDimensions()
    local tableOfTiles = {}
    local nextIndex = 1
    for rad = minRadius,radius do
        for z = 0,numberOfMaps-1 do
            if doMap[z] then
                nextIndex= addTileRing(cX,cY,rad,z,tableOfTiles,nextIndex,mapWidth)
            end
        end
    end
    return tableOfTiles               
end

-- gen.clearGapsInArray(table,lowestValue=1)-->void
-- Re-indexes all integer keys and values
-- in a table, so that there are no gaps.
-- Starts at lowestValue, and maintains order
-- of integer keys
-- Non integer keys (including other numbers)
-- and integers below lowestValue are left unchanged
function gen.clearGapsInArray(table,lowestValue)
    lowestValue = lowestValue or 1
    local largestIndex = lowestValue-1
    for index,val in pairs(table) do
        if type(index) == "number" and index > largestIndex then
            largestIndex = index
        end
    end
    local nextIndex = lowestValue
    for i=lowestValue,largestIndex do
        if table[i] ~= nil then
            if nextIndex < i then
                table[nextIndex] = table[i]
                table[i] = nil
            end
            nextIndex = nextIndex+1
        end
    end
end

-- all integer values in the table are re-indexed so that they 
-- start at 1 and proceed without gaps
-- all other keys are ignored
function gen.makeArrayOneToN(table)
    local lowestIntKey = math.huge
    local highestIntKey = -math.huge
    local function isInt(number)
        return type(number)=="number" and number == math.floor(number)
    end
    local tempTable = {}
    for key,value in pairs(table) do
        if isInt(key) then
            if key < lowestIntKey then
                lowestIntKey = key
            end
            if key > highestIntKey then
                highestIntKey = key
            end
            tempTable[key] = value
            table[key] = nil
        end
    end
    local newIndex = 1
    for i=lowestIntKey,highestIntKey do
        if tempTable[i] ~= nil then
            table[newIndex] = tempTable[i]
            newIndex = newIndex+1
        end
    end
end

local musicFolder = ""
-- gen.playMusic(fileName)
function gen.playMusic(fileName)
    civ.playMusic(musicFolder.."\\"..fileName)
end

-- gen.setMusicDirectory(path)
function gen.setMusicDirectory(path)
    musicFolder = path
end

-- the ephemeralTable is a table for shared data
-- since it is not saved, it doesn't have to be serializeable,
-- so you don't have to worry about making keys and
-- values text or numbers
-- However, the information will not be preserved after a save and load
local ephemeralTable = {}
-- gen.getEphemeralTable()-->table
function gen.getEphemeralTable()
    return ephemeralTable
end

local genStateTable = "stateTableNotLinked"
-- gen.linkGeneralLibraryState(stateTable) --> void
-- links a sub table of the state table for the purposes of
-- providing a table for functions in the General Library
-- this is distinct from getState, which provides a state
-- 'visible' state table to the end user
function gen.linkGeneralLibraryState(stateTable)
    if type(stateTable) == "table" then
        genStateTable = stateTable
    else
        error("gen.linkGeneralLibraryState: linkGeneralLibraryState takes a table as an argument.")
    end
    genStateTable.limitedExecutions = genStateTable.limitedExecutions or {}
    genStateTable.persistentRandom = genStateTable.persistentRandom or {}
end

-- gen.limitedExecutions(key,maxTimes,limitedFunction)--> void
-- if the value at key is less than maxTimes, limitedFunction will execute,
-- and the value at key will increment by 1
-- Otherwise, don't execute limitedFunction
-- Note: limitedFunction()-->void
function gen.limitedExecutions(key,maxTimes,limitedFunction)
    genStateTable.limitedExecutions[key] = genStateTable.limitedExecutions[key] or 0
    if genStateTable.limitedExecutions[key] < maxTimes then
        genStateTable.limitedExecutions[key] = genStateTable.limitedExecutions[key]+1
        limitedFunction()
    end
end

-- gen.justOnce(key,limitedFunction) --> void
-- wrapper for gen.limitedExecutions with maxTimes being 1
function gen.justOnce(key,limitedFunction)
    gen.limitedExecutions(key,1,limitedFunction)
end

-- gen.isSinglePlayerGame() --> boolean
-- returns true if there is exactly one human player, false otherwise

function gen.isSinglePlayerGame()
    local humanMask = civ.game.humanPlayers
    -- not humanMask >= 0, so don't have to worry about negatives
    if humanMask == 0 then
        -- no human player, so not single player game
        return false
    end
    -- if there is exactly one human player, then humanMask
    -- will be a power of 2, and so will have an integer logarithm
    return (math.log(humanMask,2) == math.floor(math.log(humanMask,2)))
end


-- gen.tableWrap(item)-->table
-- if item is a table, return the table
-- otherwise, return a table with the item as element 1
-- This is useful so that the scenario designer doesn't have
-- to wrap a single element in a table
-- gen.tableWrap(item,needsWrapFn)-->table
--  needsWrapFn(item)-->bool
--  if true, item needs a wrapping table, if not, it doesn't
--  useful if you can distinguish between tables that represent other
--  data structures, and tables of such data structures
--

function gen.tableWrap(item,needsWrapFn)
    needsWrapFn = needsWrapFn or function(item) return type(item)~="table" end
    if needsWrapFn(item) then
        return {item}
    else
        return item
    end
end

--
-- gen.copyUnitAttributes(parent,child)-->void
-- copies the attributes of the 'parent' unit to the 'child' unit
-- all attributes accessible through lua are copied (except unit type,
-- and unit id number, and carriedBy)
--  Useful if a unit's type must be changed (by creating a new unit), but everything
--  else should stay the same
function gen.copyUnitAttributes(parent,child)
    child.owner = parent.owner
    child:teleport(parent.location)
    child.homeCity = parent.homeCity
    child.damage = parent.damage
    child.moveSpent = parent.moveSpent
    if parent.gotoTile then
        gen.setToGoingTo(child,parent.gotoTile)
    else
        child.order = parent.order
    end
    child.attributes = parent.attributes
    child.veteran = parent.veteran
    child.domainSpec = parent.domainSpec
end

-- gen.nearbyUnits(center,radius) --> iterator providing units
--      provides an iterator over all the units within radius
--      tiles of the center tile

function gen.nearbyUnits(center,radius)
    return coroutine.wrap(function ()
        for __,tile in pairs(gen.getTilesInRadius(center,radius,0,{0,1,2,3,})) do
            for unit in tile.units do
                coroutine.yield(unit)
            end
        end
    end)
end


--
--
--

local defeatFunction = nil
local deathFunction = nil 
local deletionFunction = nil
local deathOutsideCombat = nil
-- gen.setDeathFunctions(defeatFunction,deathFunction,deletionFunction) --> void
--      defeatFunction(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)--> nil or unit
--          function for when a unit is defeated either in game combat or in an event representing combat
--          if a unit is returned, that is a replacement unit for demotion
--      deathFunction(dyingUnit) --> void
--          for when a unit 'dies', either in standard or event combat, or through some other event 'kill'
--      deletionFunction(deletedUnit,replacingUnit=nil) --> void
--          maintenance for when a unit is deleted, either because of combat, death, replacement or some other 'administrative' situation.  If no replacing unit, the replacingUnit argument is nil
--  registers functions to be performed when a unit is defeated (either in game combat or events)
--  or deleted by events in some other way
--      deathNoCombatFn(dyingUnit) --> void
--          for when a unit dies, but not in combat or through the gen.defeatUnit function
function gen.setDeathFunctions(defeatFn,deathFn,deletionFn,deathNoCombatFn)
    defeatFunction = defeatFn
    deathFunction = deathFn
    deletionFunction = deletionFn
    deathOutsideCombat = deathNoCombatFn
end

-- gen.defeatUnit(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->unit or nil
--      "defeats" the loser, deletes the loser, and returns a unit if and only if the loser 
--      was demoted, otherwise nil is returned
function gen.defeatUnit(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    local survivor = defeatFunction(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    deathFunction(loser)
    deletionFunction(loser,survivor)
    civ.deleteUnit(loser)
    return survivor
end

-- gen.killUnit(dyingUnit)-->void
--      "kills" the dying unit
function gen.killUnit(dyingUnit)
    deathFunction(dyingUnit)
    deathOutsideCombat(dyingUnit)
    deletionFunction(dyingUnit,nil)
    civ.deleteUnit(dyingUnit)
    return
end

-- gen.deleteUnit(deletedUnit,replacementUnit=nil)-->void
--      deletes the deleted unit
--      if the unit is being 'replaced', the replacing unit must be provided
function gen.deleteUnit(deletedUnit,replacementUnit)-->void
    replacementUnit=replacementUnit or nil
    deletionFunction(deletedUnit,replacementUnit)
    civ.deleteUnit(deletedUnit)
    return
end

-- gen.replaceUnit(oldUnit,replacementType)--> unit
-- creates a unit to replace the old unit, 
-- copies the old unit's attributes, and
-- deletes the old unit (applying the deletion function)
-- returns the newly created unit
function gen.replaceUnit(oldUnit,replacementType)
    local newUnit = civ.createUnit(replacementType,oldUnit.owner,oldUnit.location)
    gen.copyUnitAttributes(oldUnit,newUnit)
    gen.deleteUnit(oldUnit,newUnit)
    return newUnit
end

-- gen.makeAllowedTerrainFunction(allowedTilesTable) --> function(tile)-->bool
--      converts a table of integer values into a function that returns
--      true if tile.terrainType%16 is a value in the table, and false otherwise
--      if nil is entered, all terrain is allowed
--
function gen.makeAllowedTerrainFunction(allowedTilesList)
    allowedTilesList = allowedTilesList or {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    local allowedTilesTable = {}
    for __,terrainID in pairs(allowedTilesList) do
        allowedTilesTable[terrainID] = true
    end
    local function allowedTile(tile)
        return allowedTilesTable[(tile.terrainType % 16)] or false
    end
    return allowedTile
end

-- 
-- gen.nearbyUnoccupiedTiles(tile,distance,allowedTiles) --> table
--      returns the table of nearby unoccupied tiles
--      Indices start at 1 without gaps, but tiles are in no particular order
--      tile is that you want to find other tiles near to (on same map)
--      distance is the number of squares away that you can search
--      allowetiles is either a table of integers such that a tile is acceptable if
--          possibleTile.terrainType % 16 appears as a value in the table
--      or a function allowedtiles(possibletile)-->bool
--          that returns true if the tile is allowed, and false if not
--      if nil is entered, all terrain is allowed
function gen.nearbyUnoccupiedTiles(centerTile,distance,allowedTiles)
    centerTile = toTile(centerTile)
    if type(allowedTiles) == "table" or type(allowedTiles) == "nil" then
        allowedTiles = gen.makeAllowedTerrainFunction(allowedTiles)
    end
    local newIndex = 1
    local tileList = {}
    for __,tile in pairs(gen.getTilesInRadius(centerTile,distance)) do
        if tile.defender == nil and tile.city == nil and allowedTiles(tile) then
            tileList[newIndex] = tile
            newIndex = newIndex+1
        end
    end
    return tileList
end

-- gen.getRandomNearbyUnoccupiedTile(tile,distance,allowedTiles) --> tile
--      returns a random square near tile, on the same map
--      tile is that you want to find other tiles near to (on same map)
--      returns nil if no suitable tile is found
--      distance is the number of squares away that you can search
--      allowetiles is either a table {[terraintype]=bool or nil}
--          such that a tile is acceptable if allowedtiles[possibletile.terraintype % 16] == true
--      or a function allowedtiles(possibletile)-->bool
--          that returns true if the tile is allowed, and false if not
--      if nil is entered, all terrain is allowed
function gen.getRandomNearbyUnoccupiedTile(tile,distance,allowedTiles)
    local tileList = gen.nearbyUnoccupiedTiles(tile,distance,allowedTiles)
    local numberOfTiles = #tileList
    if numberOfTiles > 0 then
        return tileList[math.random(1,numberOfTiles)]
    else
        return nil
    end
end

-- gen.isEmpty(table)-->bool
--      returns true if the table has no entries, and false otherwise
--      (I got this idea from stackoverflow, https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries )
function gen.isEmpty(table)
    return next(table) == nil
end
--  gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
--      returns a table of nearby tiles that are either unoccupied or occupied
--      by a specific tribe
--      centerTile is the tile that you want to find other tiles nearby to (on the same map)
--      distance is the number of squares away that you can search
--      allowedTiles is either a table of integers such that a tile is acceptable if
--          possibleTile.terrainType % 16 appears as a value in the table
--      or a function allowedTiles(possibleTile)-->bool
--          that returns true if the tile is allowed, and false if not
--      if nil is entered, all terrain is allowed
function gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
    centerTile = toTile(centerTile)
    if type(allowedTiles) == "table"  or type(allowedTiles) == "nil" then
        allowedTiles = gen.makeAllowedTerrainFunction(allowedTiles)
    end
    local newIndex = 1
    local tileList = {}
    for __,tile in pairs(gen.getTilesInRadius(centerTile,distance)) do
        if (tile.defender == nil or tile.defender == tribe) and
            (tile.city == nil or (tile.city and tile.city.owner == tribe)) and
            allowedTiles(tile) then
            tileList[newIndex] = tile
            newIndex = newIndex+1
        end
    end
    return tileList
end

-- gen.getRandomNearbyOpenTileForTribe(tile,distance,allowedTiles,tribe) --> tile
--      returns a random square near tile, on the same map, that is either
--      empty or only has units/city of the same tribe
--      tile is that you want to find other tiles near to (on same map)
--      returns nil if no suitable tile is found
--      distance is the number of squares away that you can search
--      allowetiles is either a table {[terraintype]=bool or nil}
--          such that a tile is acceptable if allowedtiles[possibletile.terraintype % 16] == true
--      or a function allowedtiles(possibletile)-->bool
--          that returns true if the tile is allowed, and false if not
--      tribe is the tribe that can be occupying 
--      if nil is entered, all terrain is allowed
function gen.getRandomNearbyOpenTileForTribe(centerTile,distance,allowedTiles,tribe)
    tileList = gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
    local numberOfTiles = #tileList
    if numberOfTiles > 0 then
        return tileList[math.random(1,numberOfTiles)]
    else
        return nil
    end
end

-- gen.createUnit(unitType,tribe,locations,options) --> table of units
--      This is a createUnit function, meant to supersede civlua.createUnit
--      returns a table of units, indexed by integers starting at 1 (unless no units were created
--      unitType is the type of unit to be created
--      tribe is the tribe that will own the unit(s)
--      locations is one of the following
--          a tile object
--          a table of 3 elements, (indexed by integers 1,2,3) corresponding to x,y,z coordinate
--          a table of tile objects (indexed by integers)
--          a table of coordinate triple tables (indexed by integers)
--      options is a table with the following keys
--          count = integer
--              the number of units to create
--              nil means 1
--          randomize = bool or nil
--              if true, randomize the list of locations
--              if false or nil, try to place at the tile with the smallest index in table first
--          scatter = bool or nil
--              if true, and if randomize is true, each unit is created on a random tile
--              in the location table
--          inCapital = bool or nil
--              if true, attempt to place in the capital before other locations
--              in case of multiple capitals, capitals are ranked with smallest city id first
--              randomize/scatter applies to list of capitals if this is selected
--          veteran = bool or fraction in 0-1 or integer or nil
--              if true, make the created unis veteran
--              if a fraction in 0-1, each unit created has that chance of being veteran
--              if number >= 1, this many of the count are veteran (take floor)
--              nil or false means no veterans
--          homeCity = city or true or nil
--              if city, that city is the home city
--              if true, the game selects the home city (probably the same way a city is chosen if you
--              create a unit by using the cheat menu)
--              if nil, no home city
--          overrideCanEnter = bool or nil
--              if true, unit will be placed even if unitType:canEnter(tile) returns false
--              false or nil means follow the restriction 
--              civ.canEnter appears to check if the terrain is impassible, or the unit can cross impassible
--          overrideDomain = bool or nil
--              if true, sea units can be created on land outside cities, and land units at sea
--              false or nil means units can only be created where they could travel naturally
--          overrideDefender = bool or nil
--              if true, unit can be placed on tiles with enemy units or cities
--              false or nil means the tile must have no enemy cities, and no enemy defender
--
--

function gen.createUnit(unitType,tribe,locations,options)
    options = options or {}
    -- must copyTable locations, in case that table is used for multiple things
    -- mutating the original table could cause errors that are difficult to diagnose
    -- note: copyTable returns the input for things that are not tables
    locations = gen.copyTable(locations)
    if civ.isTile(locations) then
        -- toTile(locations) so that an error will be thrown if an invalid tile
        -- is used (e.g. loser.location if the loser is an attacker)
        locations = {toTile(locations)}
    elseif type(locations) =="table" then
        -- must copy the table, just in case it is referenced again
        if type(locations[1]) == "number" then
            -- if first index is a number, the table represents a single coordinate triple
            -- if the table is of tiles or coordinate triples, the first element will be either
            -- a table, a tile, or nil
            locations = {toTile(locations)}
        else
            -- make all the locations tiles
            for key,loc in pairs(locations) do
                locations[key] = toTile(loc)
            end
        end
    else
        error("gen.createUnit: Invalid argument for locations (arg 3).")
    end
    local function checkCanEnter(tile)
        return civ.canEnter(unitType,tile) or options.overrideCanEnter
    end
    local function checkDomain(tile)
        if options.overrideDomain then
            return true
        elseif unitType.domain == 2 then
            -- sea unit
            return (tile.terrainType % 16) == 10 or (tile.city and tile.city.coastal)
        elseif unitType.domain == 0 then
            -- land unit
            return (tile.terrainType % 16) ~= 10
        else
            -- air unit
            return true
        end
    end
    local function checkDefender(tile)
        if options.overrideDefender then
            return true
        end
        if tile.city and (tile.city.owner ~= tribe) then
            return false
        end
        if tile.defender and tile.defender ~= tribe then
            return false
        end
        return true
    end
    local function isTileValid(tile)
        if not tile then
            return false
        end
        return checkCanEnter(tile) and checkDomain(tile) and checkDefender(tile)
    end
    local capitals = {}
    if options.inCapital then
        for city in civ.iterateCities() do
            if city.owner == tribe and city:hasImprovement(civ.getImprovement(1)) then
                capitals[city.id] = city.location
            end
        end
    end
    for key,loc in pairs(capitals) do
        if not isTileValid(loc) then
            capitals[key] = nil
        end
    end
    for key,loc in pairs(locations) do
        if not isTileValid(loc) then
            locations[key] = nil
        end
    end
    local placementTable = nil
    if gen.isEmpty(capitals) then
        placementTable = locations
    else
        placementTable = capitals
    end
    gen.makeArrayOneToN(placementTable)
    local returnUnits = {}
    if gen.isEmpty(placementTable) then
        print("No units placed, since no valid location.")
        return returnUnits
    end
    local numToPlace = options.count or 1
    local vetCount = 0 
    local vetChance = 0  
    if options.veteran == true then
        vetCount = numToPlace
        vetChance = 1
    elseif type(options.veteran) == "number" and options.veteran < 1 then
        vetCount = numToPlace
        vetChance = options.veteran
    elseif type(options.veteran) == "number" then
        vetCount = math.floor(options.veteran)
        vetChance = 1
    end
    local placementTile = nil
    local placementTableSize = #placementTable
    if options.randomize then
        placementTile = placementTable[math.random(1,placementTableSize)]
    else
        placementTile = placementTable[1]
    end
    for i=1,numToPlace do
        if options.scatter and options.randomize then
            placementTile = placementTable[math.random(1,placementTableSize)]
        end
        local newUnit = civ.createUnit(unitType,tribe,placementTile)
        returnUnits[i] = newUnit
        if i<=vetCount and (math.random() <= vetChance) then
            newUnit.veteran = true
        end
        if options.homeCity ~= true then
            -- if homeCity is true, the unit keeps the default home city it got when it was
            -- created
            -- if homeCity not specified, that means the unit has no home city, so next line works
            -- if homeCity is specified, next line works also
            newUnit.homeCity = options.homeCity
        end
    end
    return returnUnits
end

-- gen.getTileProduction(tile,city) --> integer (food), integer(shields), integer(trade)
-- returns the tile production values, presuming that the city
-- given is the one working the tile
-- That is to say, returns the values that would be seen on the tile in the city window
-- Doesn't check if that city is actually working the tile

local function getTileProduction(tile,city)
    tile = toTile(tile)
    local terrain = tile.terrain
    local baseTerrain = tile.baseTerrain
    local trade = terrain.trade
    local shields = terrain.shields
    local food = terrain.food
    if baseTerrain.type == 10 then
        -- the ocean has a different computation than
        -- other terrain in several areas
        -- road and river don't add trade to ocean
        -- colossus always adds trade to ocean, even if it doesn't
        -- have any trade production
        if civ.getWonder(2).city == city and applyWonderBonus(civ.getWonder(2),city.owner) then
            trade = trade+1
        end
        local tribeGovernment = city.owner.government
        if tribeGovernment >= 5 or (tribeGovernment >= 2 and gen.isWeLoveTheKing(city)) then
            -- republic/democracy bonus, wltkd for other gov'ts
            if trade >= 1 then
                trade = trade+1
            end
        elseif (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if trade >= 3 then
                trade = trade -1
            end
        end
        -- highways apply to ocean
        if (gen.hasRoad(tile) or tile.city) and city:hasImprovement(civ.getImprovement(25)) then
            trade = (3*trade)//2
        end

        -- shields
        -- mining doesn't increase ocean shield production

        -- apply offshore platform
        if city:hasImprovement(civ.getImprovement(31)) then
            shields = shields+1
        end
        -- King Richard's Crusade
        if civ.getWonder(8).city == city and applyWonderBonus(civ.getWonder(8),city.owner) then
            shields = shields+1
        end
        -- railroads apply to ocean
        if gen.hasRailroad(tile) or (tile.city and city.owner:hasTech(civ.getTech(67))) then
            shields = (3*shields)//2
        end
        -- despotism seems to happen after railroads
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if shields >= 3 then
                shields = shields -1
            end
        end
        -- irrigation doesn't increase food production on the ocean
        -- Farmland doesn't affect it either

        -- apply harbour
        if city:hasImprovement(civ.getImprovement(30)) then
            food = food+1
        end
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if food >= 3 then
                food = food -1
            end
        end

    else
        -- calculation for non-ocean tiles

        -- river adds 1 trade to all tiles (except ocean)
        if tile.river  then
            trade = trade+1
        end
        -- road
        -- If the tile has a road, it gets +1 trade if it already has some trade,
        -- or if totpp.roadTrade says it should (baseTerrain.type+1, since id starts counting
        -- at 0, but isBit1 starts counting from 1
        -- Oceans don't get +1 road trade, ever
        if (gen.hasRoad(tile) or tile.city) and (isBit1(totpp.roadTrade[tile.z],baseTerrain.type+1) or trade > 0) then 
            trade = trade+1
        end
        -- apply colossus
        if civ.getWonder(2).city == city and trade >= 1 and applyWonderBonus(civ.getWonder(2),city.owner) then
            -- colossus adds 1 trade to each tile that already has a trade arrow,
            -- (also adds 1 trade to ocean even if no trade arrow, see above)
            trade = trade+1
        end
        -- republic/democracy trade bonus happens before highways are applied
        -- despotism penalty happens before highways
        local tribeGovernment = city.owner.government
        if tribeGovernment >= 5 or (tribeGovernment >= 2 and gen.isWeLoveTheKing(city)) then
            -- republic/democracy bonus, wltkd for other gov'ts
            if trade >= 1 then
                trade = trade+1
            end
        elseif (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if trade >= 3 then
                trade = trade -1
            end
        end
        -- apply highways bonus
        if (gen.hasRoad(tile) or tile.city) and city:hasImprovement(civ.getImprovement(25)) then
            trade = (3*trade)//2
        end
        --shields
        -- Apply mine bonus.  
        -- A city gives the mine bonus only if the irrigation bonus is 0
        if gen.hasMine(tile) or (tile.city and baseTerrain.irrigateBonus == 0)  then
            shields = shields + baseTerrain.mineBonus
        end
        -- grasslands without shields don't produce shields, except with KRC, which gives +1
        -- Or, the 1 shield minimum from being on a city square
        if baseTerrain.type == 2 and not tile.grasslandShield then
            shields = 0
        end
        -- cities (except on ocean) guarantee 1 shield of production
        if tile.city then
            shields = math.max(1,shields)
        end
        -- KRC happens after 1 shield minimum, before the railroad bonus
        -- King Richard's Crusade
        if civ.getWonder(8).city == city and applyWonderBonus(civ.getWonder(8),city.owner) then
            shields = shields+1
        end
        if gen.hasRailroad(tile) or (tile.city and city.owner:hasTech(civ.getTech(67))) then
            shields = (3*shields)//2
        end
        -- despotism seems to happen after railroads
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if shields >= 3 then
                shields = shields -1
            end
        end
        -- tiles with city or irrigation get the irrigation bonus, regardless of whether
        -- the tile can actually be irrigated
        if tile.city or gen.hasIrrigation(tile) then
            food = food + baseTerrain.irrigateBonus
        end
        -- don't need refrigeration tech to take advantage of farm production, just supermarket
        -- city tile counts as farmland even without refrigeration
        if city:hasImprovement(civ.getImprovement(24)) and (tile.city or gen.hasFarmland(tile)) then
            food = (3*food)//2
        end
        -- 4 food production pre farmland results in 5 production after applying supermarket,
        -- meaning that the despotism penalty applies after supermarkets (6-1=5 instead of 3*3/2 = 4)
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if food >= 3 then
                food = food -1
            end
        end
    end
    return food, shields, trade
end
gen.getTileProduction = getTileProduction

-- gen.computeBaseProduction(city)-->integer(food), integer(shields), integer(trade)
-- Computes the resources harvested by the city from the terrain
-- includes superhighway/supermarket/railroad bonus, but not factories/powerplants
function gen.computeBaseProduction(city)
    local tileList = gen.cityRadiusTiles(city)
    local cityWorkers = city.workers
    local foodTotal = 0
    local shieldTotal = 0
    local tradeTotal = 0
    for workerIndex,tile in pairs(tileList) do
        if isBit1(cityWorkers,workerIndex) then
            local tileFood,tileShields,tileTrade = getTileProduction(tile,city)
            foodTotal = foodTotal+tileFood
            shieldTotal = shieldTotal+tileShields
            tradeTotal = tradeTotal+tileTrade
            --print(tile.x,tile.y,tileShields, shieldTotal)
        end
    end
    return foodTotal,shieldTotal,tradeTotal
end

-- gen.persistentRandom(key) --> number between 0 and 1
-- checks the persistentRandom table (within the state table)
-- for a value associated with key. If it exits, the value is
-- returned.  If it does not exist, a random number between
-- 0 and 1 is generated, stored in the table under the key,
-- and also returned
-- example of use: WWII scenario with seasons
-- You may want to have some games where the 1941 spring starts
-- in April, and other games where it starts in May.  When
-- determining whether to load winter or summer terrain stats during
-- 1941, you would use gen.persistentRandom("EarlySpring1941") < 0.5
-- as part of the season check in April, and load summer if the value is less than 0.5
-- and winter otherwise.  This way, each when each player starts their
-- game that month, they will all either get winter or summer terrain
function gen.persistentRandom(key)
    genStateTable.persistentRandom[key] = genStateTable.persistentRandom[key] or math.random()
    return genStateTable.persistentRandom[key]
end

-- gen.clearPersistentRandom(key) --> void
-- sets the value associated with the key in the
-- persistentRandom table.  This could either be for reuse of the key,
-- or to prevent the key from staying in the state table indefinitely
function gen.clearPersistentRandom(key)
    genStateTable.persistentRandom[key] = nil
end

-- gen.getPersistentRandomTable() --> table
-- returns the persistentRandom table
function gen.getPersistentRandomTable()
    return genStateTable.persistentRandom
end


-- gen.mergeTableValues(table,table,...) --> table
--  accepts an arbitrary number of tables as
--  arguments and returns a table with all
--  the values from all the tables.
--  Table keys are lost, and replaced by
--  integers starting at 1.
--  Duplicate values will appear multiple times
--
--
function gen.mergeTableValues(...)
    local argTable = {...}
    local output = {}
    local index = 1
    for __,table in pairs(argTable) do
        for __,value in pairs(table) do
            output[index] = value
            index=index+1
        end
    end
    return output
end
    
return gen
