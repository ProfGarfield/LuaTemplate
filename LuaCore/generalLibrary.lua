local versionNumber = 3
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


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
-- gen.requireIfAvailable(fileName) --> boolean, modulePrefix
--      Attempts to require the module called fileName
--      returns true, modulePrefix if the module is found
--      returns false, nil if no module is found
--      makes an error if there is a problem loading the module
--      Note: if you change the function name here, the function
--      can be copied and pasted if you don't want to require
--      the general library
local civlua = require("civlua")
local gen = {}
function gen.requireIfAvailable(fileName)
    if package.loaded[fileName] then
        return true, require(fileName)
    else
        for _,searcher in ipairs(package.searchers) do
            local loader = searcher(fileName)
            if type(loader) == 'function' then
                return true, require(fileName)
            end
        end
        return false, nil
    end
end
--
--gen.checkBits(integer,string)-->boolean
--gen.setBits(integer,string)-->integer
--gen.printBits(integer,numOfBits or nil) --> string
--gen.isBit1(integer,bitNumber)--> boolean
--gen.isBit0(integer,bitNumber)--> boolean
--gen.setBit1(integer,bitNumber)-->integer
--gen.setBit0(integer,bitNumber)-->integer
--gen.makeThresholdTable(table or nil)-->thresholdTable
--applyWonderBonus(wonderObject or integer,tribeObject or integer)-->boolean
--gen.isWonderActiveForTribe(wonderObject or integer,tribeObject or integer)-->boolean
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
--#gen.removeSeeTwoSpaces(unitType)-->void
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
--  gen.getRandomTileInPolygon(polygonTableOfCoordinates,map=0,maxAttempts=100) -> tile (inspired by Pablostuka)
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
--      Stuff below hasn't been documented on website
--
--  gen.original is a table of objects with keys based on 
--  the name of the item in the original game
--
--
-- gen.isTileRevealed(tile,tribe) -> boolean
-- gen.revealTile(tile,tribe) -> void
-- gen.coverTile(tile,tribe) -> void
-- gen.isCityCharted(city,tribe) --> bool
-- gen.chartCity(city,tribe,visibleSize=nil) --> void
-- gen.unchartCity(city,tribe) --> void
-- gen.isIrrigationCharted(tile,tribe) --> bool
-- gen.chartIrrigation(tile,tribe) --> void
-- gen.unchartIrrigation(tile,tribe) --> void
-- gen.isMineCharted(tile,tribe) --> bool
-- gen.chartMine(tile,tribe) --> void
-- gen.unchartMine(tile,tribe) --> void
-- gen.isFarmlandCharted(tile,tribe) --> bool
-- gen.chartFarmland(tile,tribe) --> void
-- gen.unchartFarmland(tile,tribe) --> void
-- gen.isRoadCharted(tile,tribe) --> bool
-- gen.chartRoad(tile,tribe) --> void
-- gen.unchartRoad(tile,tribe) --> void
-- gen.isRailroadCharted(tile,tribe) --> bool
-- gen.chartRailroad(tile,tribe) --> void
-- gen.unchartRailroad(tile,tribe) --> void
-- gen.unchartTransportation(tile,tribe) --> void
-- gen.isFortressCharted(tile,tribe) --> bool
-- gen.chartFortress(tile,tribe) --> void
-- gen.unchartFortress(tile,tribe) --> void
-- gen.isAirbaseCharted(tile,tribe) --> bool
-- gen.chartAirbase(tile,tribe) --> void
-- gen.unchartAirbase(tile,tribe) --> void
-- gen.isPollutionCharted(tile,tribe) --> bool
-- gen.chartPollution(tile,tribe) --> void
-- gen.unchartPollution(tile,tribe) --> void
-- gen.isTransporterCharted(tile,tribe) --> bool
-- gen.chartTransporter(tile,tribe) --> void
-- gen.unchartTransporter(tile,tribe) --> void
-- gen.chartTruthfully(tile,tribe) --> void
-- gen.isInvisibleUntilAttack(unitType) --> bool
-- gen.giveInvisibleUntilAttack(unitType) --> void
-- gen.removeInvisibleUntilAttack(unitType) --> void
-- gen.isNonDisbandable(unitType) --> bool
-- gen.giveNonDisbandable(unitType) --> void
-- gen.removeNonDisbandable(unitType) --> void
-- gen.isZeroRangeAirUnitDamageOverride(unitType) --> bool
-- gen.giveZeroRangeAirUnitDamageOverride(unitType) --> void
-- gen.removeZeroRangeAirUnitDamageOverride(unitType) --> void
-- gen.isCannotBuyOffBarbarian(unitType) --> bool
-- gen.giveCannotBuyOffBarbarian(unitType) --> void
-- gen.removeCannotBuyOffBarbarian(unitType) --> void
-- gen.isCanCrossImpassableTerrain(unitType) --> bool
-- gen.giveCanCrossImpassableTerrain(unitType) --> void
-- gen.removeCanCrossImpassableTerrain(unitType) --> void
-- gen.isBarbarianWillNotExpire(unitType) --> bool
-- gen.giveBarbarianWillNotExpire(unitType) --> void
-- gen.removeBarbarianWillNotExpire(unitType) --> void
-- gen.isOverrideSPR(unitType) --> bool
-- gen.giveOverrideSPR(unitType) --> void
-- gen.removeOverrideSPR(unitType) --> void
-- gen.isReducePopulationWhenBuilt(unitType) --> bool
-- gen.giveReducePopulationWhenBuilt(unitType) --> void
-- gen.removeReducePopulationWhenBuilt(unitType) --> void
-- gen.isRequiresFoodSupport(unitType) --> bool
-- gen.giveRequiresFoodSupport(unitType) --> void
-- gen.removeRequiresFoodSupport(unitType) --> void
-- gen.isCanFoundCities(unitType) --> bool
-- gen.giveCanFoundCities(unitType) --> void
-- gen.removeCanFoundCities(unitType) --> void
-- gen.isCanImproveTiles(unitType)--> bool
-- gen.giveCanImproveTiles(unitType,ignoreError=false) --> void
-- gen.removeCanImproveTiles(unitType,ignoreError=false) --> void
-- gen.makeDataTable(inputTable={},tableName="unnamed data table") --> dataTable
-- gen.forbidReplacement(dataTable) --> void
-- gen.allowReplacement(dataTable) --> void
-- gen.forbidNewKeys(dataTable) --> void
-- gen.allowNewKeys(dataTable) --> void
-- gen.forbidNilValueAccess(dataTable) --> void
-- gen.allowNilValueAccess(dataTable) --> void
-- gen.setScenarioDirectory(directoryPath) --> void
-- gen.getScenarioDirectory() --> string
-- gen.isStateSavable(item) --> boolean
-- gen.calculateWeight(item,weightTable,extraArgument=nil) --> number or false
-- gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction,getTopX,changeOrder,functionName,extraArgument)
-- gen.getBiggestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil
-- gen.getSmallestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil
-- gen.placeMarker(tile,tribe,markerOption)
-- gen.removeMarker(tile,tribe,markerOption) --> void
-- gen.maintainTileMarkerTable() --> void
-- gen.removeAllMarkers(tribeOrNil,markerTypeOrNil) --> void
-- gen.showAllMarkersOnTile(tile,topMarkerTypeOrNil,secondMarkerTypeOrNil) --> void
-- gen.showAllMarkers(topMarkerTypeOrNil) --> void
-- gen.hasMarker(tile,tribe,markerType)
-- gen.isMarkerVisible(tile,tribe,markerType)
-- gen.hideMarker(tile,tribe,markerType)
-- gen.hideAllMarkers(tribeOrNil,markerTypeOrNil)
-- gen.showMarker(tile,tribe,markerType)
-- gen.showMarkerOnAllTiles(tribe,markerType)
-- gen.setOutOfRangeMessage(textOrFunction,title=nil) --> void
-- gen.outOfRangeMessage(unit) --> void
-- gen.activateRangeForLandAndSea(restoreRangeFn=nil,applyToAI=false)
-- gen.spendMovementPoints(unit,points,multiplier=totpp.movementMultipliers.aggregate,maxSpent=255,minSpent=0) -> void
-- gen.getBearing(compassPoint,compassCentre) --> string | Inspired by Pablostuka
-- gen.tableToString(table) --> string
--  gen.describeAllowableData(validDataInfo) --> string
-- gen.validateFunctionArgument(data,moduleName,functionName,argumentNumber, argumentName,validDataInfo,extraInfo=nil) --> void or error
-- gen.versionFunctions(moduleTable,versionNumber,fileMod,moduleFileName) -->void
-- gen.registerEventsLuaVersion(versionNumber,fileMod,regressionNumber)
-- gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable) --> newItemFunction, isDataTypeFunction
--getRandomTileInPolygon(polygonTableOfCoordinates,map=0,maxAttempts=100)
--
--
--
-- FUNCTION IMPLEMENTATIONS
--


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
-- gen.isWonderActiveForTribe(wonderObject or integer,tribeObject or integer)-->boolean
-- returns true if the wonder has been built and is not
-- expired or destroyed 
-- integer means corresponding wonder/tribe id
-- revisions by Knighttime, 2021-11-12
local function applyWonderBonus(wonder,tribe)
    if type(wonder) == "number" then
        wonder = civ.getWonder(wonder)
    end
    if type(tribe) == "number" then
        tribe = civ.getTribe(tribe)
    end
    --check if expired
	-- Kn: If barbarians (tribe 0) are the first to acquire a wonder expiration tech,
	--   the in-game popup appears announcing that this cancels the effect of the wonder.
	--   But it doesn't actually do so! The wonder continues to function until a
	--   non-barbarian tribe acquires the tech, so the loop below starts with 1.
    for i=1,7 do
        if civ.getTribe(i) and wonder.expires and civ.hasTech(civ.getTribe(i), wonder.expires) then
            return false
        end
    end
    if wonder.city and wonder.city.owner == tribe then
        return true
    else 
        return false
    end
end
gen.isWonderActiveForTribe = applyWonderBonus

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
        error("gen.distance: first argument must be a tile (or coordinates of a tile), or a unit or a city. Received: "..tostring(tileUnitCityA))
    end
    if type(tileUnitCityB)=="table" then
        locB=toTile(tileUnitCityB)
    elseif civ.isUnit(tileUnitCityB) or civ.isCity(tileUnitCityB) then
        locB=tileUnitCityB.location
    elseif civ.isTile(tileUnitCityB) then
        locB = tileUnitCityB
    else
        error("gen.distance: second argument must be a tile (or coordinates of a tile), or a unit or a city. Received: "..tostring(tileUnitCityB))
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


-- gen.gameMechanicDistance(itemOnMap1,itemOnMap2)
--  provides a distance measure that is believed to be used
--  for internal distance calculations (such as caravan payments
--  or city corruption)
--  This distance is scaled to match the "Communism Palace Distance",
--  (based on the corruption work by Knighttime)
--  Diagonal movement is "1" distance, corner to corner is 1.5 (rounded down)
function gen.gameMechanicDistance(tileUnitCityA,tileUnitCityB)
    local locA = nil
    local locB = nil
    if type(tileUnitCityA)=="table" then
        locA=toTile(tileUnitCityA)
    elseif civ.isUnit(tileUnitCityA) or civ.isCity(tileUnitCityA) then
        locA=tileUnitCityA.location
    elseif civ.isTile(tileUnitCityA) then
        locA = tileUnitCityA
    else
        error("gen.gameMechanicDistance: first argument must be a tile (or coordinates of a tile), or a unit or a city.")
    end
    if type(tileUnitCityB)=="table" then
        locB=toTile(tileUnitCityB)
    elseif civ.isUnit(tileUnitCityB) or civ.isCity(tileUnitCityB) then
        locB=tileUnitCityB.location
    elseif civ.isTile(tileUnitCityB) then
        locB = tileUnitCityB
    else
        error("gen.gameMechanicDistance: second argument must be a tile (or coordinates of a tile), or a unit or a city.")
    end
    local xMax,yMax,zMax=civ.getAtlasDimensions()
    local xDiff = nil
    if civ.game.rules.flatWorld then
        xDiff = math.abs(locA.x-locB.x)
    else
        xDiff = math.min(math.abs(locA.x-locB.x),xMax-math.abs(locA.x-locB.x))
    end
    local yDiff = math.abs(locA.y-locB.y)
    local dist = math.floor(math.min(xDiff,yDiff)+(math.abs(xDiff-yDiff)*0.5*1.5))
    return dist
end



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
function gen.placePollutionForce(tile) 
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

-- gen.removeSeeTwoSpaces(unitType)-->void
-- Note: The typo is preserved, on the off chance that
-- someone used it
function gen.removeSeeTowSpaces(unitType) 
    unitType.flags = setBit0(unitType.flags,1)
end
gen.removeSeeTwoSpaces = gen.removeSeeTowSpaces

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
-- bug fixed by Knighttime
local function moveRemaining(unit)
	local actualMoveSpent = unit.moveSpent
	if actualMoveSpent < 0 then
		actualMoveSpent = actualMoveSpent + 256
	end
    return maxMoves(unit)-actualMoveSpent
end
gen.moveRemaining = moveRemaining




-- computeBoundingRectangle(polygonTableOfCoordinates) -->{xMin=number,xMax=number,yMin=number,yMax=number,xBound}
--  computes x and y values which are guaranteed to have all valid polygon tiles
--  within them.  xBoundary is the value of doesNotCrossThisX, and 
--  xBoundary <= xMin, xMax <= mapWidth+xBoundary
--  calculations using this info should undo the xBoundary offset if relevant.
local function computeBoundingRectangle(polygonTable)
    local output = {}
    output.xBoundary = polygonTable.doesNotCrossThisX or 0
    local xBound = output.xBoundary
    local width,height,maps = civ.getAtlasDimensions()
    local xMin,yMin,xMax,yMax=width-1+xBound,height-1,0+xBound,0
    for _,coord in ipairs(polygonTable) do
        local x = coord[1]
        if x < xBound then
            x=x+width
        end
        if x < xMin then
            xMin = x
        end
        if x > xMax then
            xMax = x
        end
        local y = coord[2]
        if y < yMin then
            yMin = y
        end
        if y > yMax then
            yMax = y
        end
    end
    output.xMin = xMin
    output.xMax = xMax
    output.yMin = yMin
    output.yMax = yMax
    return output
end


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


--  gen.getRandomTileInPolygon(polygonTableOfCoordinates,map=0,maxAttempts=100) -> tile
--      generates a random tile within the polygon defined
--      by the table of coordinates (same as used by gen.inPolygon
--      and generated by the PolygonScript.lua)
--      map is the map of the tile generated (0 by default)
--      this code is probabalistic, so after maxAttempts, the first
--      polygon coordinate is returned, and a text box displayed.
--      The console prints the polygon that caused the issue
--
--  Inspired by Pablostuka
function gen.getRandomTileInPolygon(polygonTable,map,maxAttempts)
    map = map or 0
    maxAttempts = maxAttempts or 100
    local width,height,maps = civ.getAtlasDimensions()
    local boundary = computeBoundingRectangle(polygonTable)
    for i=0,maxAttempts do
        local xRand = nil
        local yRand = nil
        repeat
            xRand = math.random(boundary.xMin,boundary.xMax)
            xRand = xRand % width
            yRand = math.random(boundary.yMin,boundary.yMax)
        until yRand % 2 == xRand % 2
        local randomTile = civ.getTile(xRand,yRand,map)
        if gen.inPolygon(randomTile,polygonTable) then
            return randomTile
        end
    end
    print("gen.getRandomTileInPolygon did not find a tile in the polygon below in "..maxAttempts.." tries.")
    print("If this is a frequent occurrence, you should either increase maxAttempts or devise a")
    print("New method for getting a random tile from this polygon")
    print(gen.tableToString(polygonTable))
    civ.ui.text("gen.getRandomTileInPolygon failed for a polygon, and a suitable default was used instead.  There is more information in the console.  If this message appears regularly, you should contact the scenario creator.")
    return civ.getTile(polygonTable[1][1],polygonTable[1][2],map)

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
local getTileId = gen.getTileId
local getTileID = gen.getTileId

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
local getTileFromId = gen.getTileFromId
local getTileFromID = gen.getTileFromId



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
    local mt = getmetatable(_G) or {}
    setmetatable(_G,mt)
    mt.__index = function(myTable,key) 
        error("\nThe variable name '"..key.."' doesn't match any available local variables.\n"
        .."Consider the following possibilities:\n"
        .."Is '"..key.."' misspelled?\n"
        .."Was '"..key.."' misspelled on the line where it was defined?\n"
        .."(That is, was 'local "..key.."' misspelled?)\n"
        .."Was 'local "..key.."' defined inside a lower level code block?\n"
        .."For example:\n"
        .."if x > 3 then\n"
        .."    local "..key.." = 3\n"
        .."else\n"
        .."    local "..key.." = x\n"
        .."end\n"
        .."print("..key..")\n"
        .."If so, define '"..key.."' before the code block:\n"
        .."local "..key.." = nil -- add this line\n"
        .."if x > 3 then\n"
        .."    "..key.." = 3 -- remove local from this line\n"
        .."else\n"
        .."    "..key.." = x -- remove local from this line\n"
        .."end\n"
        .."print("..key..")\n"
        .."If you really did mean to access a global variable, write:\n"
        .."_global."..key.."\n"
        .."If you are trying to work in the console, use the command:\n"
        .."console.restoreGlobal()\n"
        .."to restore access to global variables (locals don't work well in the console)")
    end

    mt.__newindex = function(myTable,key)
        error("\nYou appear to have forgotten to put \'local\' before '"..key.."' the first time you used it.\n"
        .."If you really did mean to make a global variable, write:\n"
        .."_global."..key.."\n"
        .."If you are trying to define a variable in the console, use the command:\n"
        .."console.restoreGlobal()\n"
        .."to restore access to global variables (locals don't work well in the console)")
    end
    print('Global variables are disabled')
end



function gen.restoreGlobal()
    local mt = getmetatable(_G) or {}
    setmetatable(_G,mt)
    mt.__index = nil
    mt.__newindex = nil
    print("You can now use global variables, including in the console.")
end
if rawget(_G,"console") then
    _G.console.restoreGlobal = gen.restoreGlobal
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
    if type(radius) ~= "number" or math.floor(radius) ~= radius then
        error("gen.getTilesInRadius: radius (argument 2) must be an integer.  Received: "..tostring(radius))
    end
    if type(minRadius) ~= "number" or math.floor(minRadius) ~= minRadius then
        error("gen.getTilesInminRadius: minRadius (argument 2) must be an integer.  Received: "..tostring(minRadius))
    end
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
    genStateTable.tileMarkerTable = genStateTable.tileMarkerTable or {}
end

local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    discreteEvents:minVersion(1)
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "designerState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        gen.linkState(state[keyName])
    end
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "generalLibraryState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        gen.linkGeneralLibraryState(state[keyName])
    end
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
    local tileList = gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
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
        -- pollution occurs after highway bonus
        -- 6 trade  -> 9 (highway) -> 5 (pollution) observed
        -- 6 trade -> 3 (pollution) -> 4 (highway) NOT observed
        if gen.hasPollution(tile) then
            trade = trade - (trade//2)
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
        -- despotism is applied before pollution
        -- 6 ->5 (despotism)->3 (pollution) observed
        -- 6 ->3 (pollution) -> 2 (despotism) not observed
        if gen.hasPollution(tile) then
            shields = shields - (shields//2)
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
        -- harbour is applied before pollution
        -- 7 ->8 (harbour) -> 4 (Pollution) observed
        -- 7 -> 4 (pollution) ->5 (harbour) Not observed
        -- despotism is applied before pollution
        -- 6 ->5 (despotism)->3 (pollution) observed
        -- 6 ->3 (pollution) -> 2 (despotism) not observed
        if gen.hasPollution(tile) then
            food = food - (food//2)
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
        -- Well known highways happen after republic/democracy bonus.  They also happen after despotism
        -- penalty.  4 trade square (3+1 for road) becomes 4 after highway and despotism,
        --  4->3 (despotism)->4(highway)  Observed`
        --  4 -> 6 (highway) -> 5 (despotism) Not observed
        -- apply highways bonus
        if (gen.hasRoad(tile) or tile.city) and city:hasImprovement(civ.getImprovement(25)) then
            trade = (3*trade)//2
        end
        -- pollution occurs after highway bonus
        -- 6 trade (5+road) -> 9 (highway) -> 5 (pollution) observed
        -- 6 trade -> 3 (pollution) -> 4 (highway) NOT observed
        if gen.hasPollution(tile) then
            trade = trade - (trade//2)
        end

        -- pollution occurs after despotism penalty, since 6 ->5 ->3 and not 6->3->2
        -- a bit more detail is below with the pollution penalty for food
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
        -- pollution occurs after despotism penalty, since 6 ->5 ->3 and not 6->3->2
        -- a bit more detail is below with the pollution penalty for food
        if gen.hasPollution(tile) then
            shields = shields - (shields//2)
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

        -- pollution occurs after farmland, since 6 food before farm becomes 9 with farm then
        -- 5 after pollution.  Pollution before farm would mean 6 becomes 3 with pollution, then
        -- 4 after pollution
        -- pollution occurs after despotism.  6 food becomes 5 with despotism, becomes 3 after pollution
        -- If pollution were factored before despotism, 6 would become 3, which would become 2,
        -- 6->5->3 holds with and without farmland
        if gen.hasPollution(tile) then
            food = food - (food//2)
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


-- Not yet documented below here

gen.original = {}


gen.original.aAdvancedFlight          = civ.getTech(0)
gen.original.aAlphabet                = civ.getTech(1)
gen.original.aAmphibiousWarfare       = civ.getTech(2)
gen.original.aAstronomy               = civ.getTech(3)
gen.original.aAtomicTheory            = civ.getTech(4)
gen.original.aAutomobile              = civ.getTech(5)   --Automobile
gen.original.aBanking                 = civ.getTech(6)
gen.original.aBridgeBuilding          = civ.getTech(7)   --Bridge Building
gen.original.aBronzeWorking           = civ.getTech(8)
gen.original.aCeremonialBurial        = civ.getTech(9)
gen.original.aChemistry               = civ.getTech(10)
gen.original.aChivalry                = civ.getTech(11)
gen.original.aCodeofLaws              = civ.getTech(12)
gen.original.aCombinedArms            = civ.getTech(13)
gen.original.aCombustion              = civ.getTech(14)
gen.original.aCommunism               = civ.getTech(15)
gen.original.aComputers               = civ.getTech(16)
gen.original.aConscription            = civ.getTech(17)
gen.original.aConstruction            = civ.getTech(18)
gen.original.aCorporation             = civ.getTech(19)
gen.original.aCurrency                = civ.getTech(20)
gen.original.aDemocracy               = civ.getTech(21)
gen.original.aEconomics               = civ.getTech(22)
gen.original.aElectricity             = civ.getTech(23)
gen.original.aElectronics             = civ.getTech(24)
gen.original.aEngineering             = civ.getTech(25)
gen.original.aEnvironmentalism        = civ.getTech(26)
gen.original.aEspionage               = civ.getTech(27)
gen.original.aExplosives              = civ.getTech(28)
gen.original.aFeudalism               = civ.getTech(29)
gen.original.aFlight                  = civ.getTech(30)
gen.original.aFundamentalism          = civ.getTech(31)
gen.original.aFusionPower             = civ.getTech(32)
gen.original.aGeneticEngineering      = civ.getTech(33)
gen.original.aGuerrillaWarfare        = civ.getTech(34)
gen.original.aGunpowder               = civ.getTech(35)
gen.original.aHorsebackRiding         = civ.getTech(36)
gen.original.aIndustrialization       = civ.getTech(37)
gen.original.aInvention               = civ.getTech(38)
gen.original.aIronWorking             = civ.getTech(39)
gen.original.aLaborUnion              = civ.getTech(40)
gen.original.aLaser                   = civ.getTech(41)
gen.original.aLeadership              = civ.getTech(42)
gen.original.aLiteracy                = civ.getTech(43)
gen.original.aMachineTools            = civ.getTech(44)
gen.original.aMagnetism               = civ.getTech(45)
gen.original.aMapMaking               = civ.getTech(46)
gen.original.aMasonry                 = civ.getTech(47)
gen.original.aMassProduction          = civ.getTech(48)
gen.original.aMathematics             = civ.getTech(49)
gen.original.aMedicine                = civ.getTech(50)
gen.original.aMetallurgy              = civ.getTech(51)
gen.original.aMiniaturization         = civ.getTech(52)
gen.original.aMobileWarfare           = civ.getTech(53)
gen.original.aMonarchy                = civ.getTech(54)
gen.original.aMonotheism              = civ.getTech(55)
gen.original.aMysticism               = civ.getTech(56)
gen.original.aNavigation              = civ.getTech(57)
gen.original.aNuclearFission          = civ.getTech(58)
gen.original.aNuclearPower            = civ.getTech(59)
gen.original.aPhilosophy              = civ.getTech(60)
gen.original.aPhysics                 = civ.getTech(61)
gen.original.aPlastics                = civ.getTech(62)
gen.original.aPlumbing                = civ.getTech(63)
gen.original.aPolytheism              = civ.getTech(64)
gen.original.aPottery                 = civ.getTech(65)
gen.original.aRadio                   = civ.getTech(66)
gen.original.aRailroad                = civ.getTech(67)
gen.original.aRecycling               = civ.getTech(68)
gen.original.aRefining                = civ.getTech(69)
gen.original.aRefrigeration           = civ.getTech(70)
gen.original.aRepublic                = civ.getTech(71)
gen.original.aRobotics                = civ.getTech(72)
gen.original.aRocketry                = civ.getTech(73)
gen.original.aSanitation              = civ.getTech(74)
gen.original.aSeafaring               = civ.getTech(75)
gen.original.aSpaceFlight             = civ.getTech(76)
gen.original.aStealth                 = civ.getTech(77)
gen.original.aSteamEngine             = civ.getTech(78)
gen.original.aSteel                   = civ.getTech(79)
gen.original.aSuperconductor          = civ.getTech(80)
gen.original.aTactics                 = civ.getTech(81)
gen.original.aTheology                = civ.getTech(82)
gen.original.aTheoryofGravity         = civ.getTech(83)
gen.original.aTrade                   = civ.getTech(84)
gen.original.aUniversity              = civ.getTech(85)
gen.original.aWarriorCode             = civ.getTech(86)
gen.original.aWheel                   = civ.getTech(87)
gen.original.aWriting                 = civ.getTech(88)
gen.original.aFutureTechnology        = civ.getTech(89)
gen.original.aUserDefTechA            = civ.getTech(90)
gen.original.aUserDefTechB            = civ.getTech(91)
gen.original.aUserDefTechC            = civ.getTech(92)
gen.original.aExtraAdvance1           = civ.getTech(93)
gen.original.aExtraAdvance2           = civ.getTech(94)
gen.original.aExtraAdvance3           = civ.getTech(95)
gen.original.aExtraAdvance4           = civ.getTech(96)
gen.original.aExtraAdvance5           = civ.getTech(97)
gen.original.aExtraAdvance6           = civ.getTech(98)
gen.original.aExtraAdvance7           = civ.getTech(99)
gen.original.uSettlers                = civ.getUnitType(0)
gen.original.uEngineers               = civ.getUnitType(1)   --Engineers
gen.original.uWarriors                = civ.getUnitType(2)
gen.original.uPhalanx                 = civ.getUnitType(3)
gen.original.uArchers                 = civ.getUnitType(4)
gen.original.uLegion                  = civ.getUnitType(5)
gen.original.uPikemen                 = civ.getUnitType(6)
gen.original.uMusketeers              = civ.getUnitType(7)
gen.original.uFanatics                = civ.getUnitType(8)
gen.original.uPartisans               = civ.getUnitType(9)
gen.original.uAlpineTroops            = civ.getUnitType(10)
gen.original.uRiflemen                = civ.getUnitType(11)
gen.original.uMarines                 = civ.getUnitType(12)
gen.original.uParatroopers            = civ.getUnitType(13)
gen.original.uMechInf                 = civ.getUnitType(14)
gen.original.uHorsemen                = civ.getUnitType(15)
gen.original.uChariot                 = civ.getUnitType(16)
gen.original.uElephant                = civ.getUnitType(17)
gen.original.uCrusaders               = civ.getUnitType(18)
gen.original.uKnights                 = civ.getUnitType(19)
gen.original.uDragoons                = civ.getUnitType(20)
gen.original.uCavalry                 = civ.getUnitType(21)
gen.original.uArmor                   = civ.getUnitType(22)
gen.original.uCatapult                = civ.getUnitType(23)
gen.original.uCannon                  = civ.getUnitType(24)
gen.original.uArtillery               = civ.getUnitType(25)
gen.original.uHowitzer                = civ.getUnitType(26)
gen.original.uFighter                 = civ.getUnitType(27)
gen.original.uBomber                  = civ.getUnitType(28)
gen.original.uHelicopter              = civ.getUnitType(29)
gen.original.uStlthFtr                = civ.getUnitType(30)
gen.original.uStlthBmbr               = civ.getUnitType(31)
gen.original.uTrireme                 = civ.getUnitType(32)
gen.original.uCaravel                 = civ.getUnitType(33)
gen.original.uGalleon                 = civ.getUnitType(34)
gen.original.uFrigate                 = civ.getUnitType(35)
gen.original.uIronclad                = civ.getUnitType(36)
gen.original.uDestroyer               = civ.getUnitType(37)
gen.original.uCruiser                 = civ.getUnitType(38)
gen.original.uAEGISCruiser            = civ.getUnitType(39)
gen.original.uBattleship              = civ.getUnitType(40)
gen.original.uSubmarine               = civ.getUnitType(41)
gen.original.uCarrier                 = civ.getUnitType(42)
gen.original.uTransport               = civ.getUnitType(43)
gen.original.uCruiseMsl               = civ.getUnitType(44)
gen.original.uNuclearMsl              = civ.getUnitType(45)   --Nuclear Msl
gen.original.uDiplomat                = civ.getUnitType(46)
gen.original.uSpy                     = civ.getUnitType(47)   --Spy
gen.original.uCaravan                 = civ.getUnitType(48)
gen.original.uFreight                 = civ.getUnitType(49)   --Freight
gen.original.uExplorer                = civ.getUnitType(50)
gen.original.uExtraLand               = civ.getUnitType(51)
gen.original.uExtraShip               = civ.getUnitType(52)
gen.original.uExtraAir                = civ.getUnitType(53)
gen.original.iNothing                 = civ.getImprovement(0)
gen.original.iPalace                  = civ.getImprovement(1)
gen.original.iBarracks                = civ.getImprovement(2)
gen.original.iGranary                 = civ.getImprovement(3)
gen.original.iTemple                  = civ.getImprovement(4)
gen.original.iMarketPlace             = civ.getImprovement(5)
gen.original.iLibrary                 = civ.getImprovement(6)
gen.original.iCourthouse              = civ.getImprovement(7)
gen.original.iCityWalls               = civ.getImprovement(8)
gen.original.iAqueduct                = civ.getImprovement(9)
gen.original.iBank                    = civ.getImprovement(10)
gen.original.iCathedral               = civ.getImprovement(11)
gen.original.iUniversity              = civ.getImprovement(12)
gen.original.iMassTransit             = civ.getImprovement(13)
gen.original.iColosseum               = civ.getImprovement(14)
gen.original.iFactory                 = civ.getImprovement(15)
gen.original.iManufacturingPlant      = civ.getImprovement(16)
gen.original.iSDIDefense              = civ.getImprovement(17)
gen.original.iRecyclingCenter         = civ.getImprovement(18)
gen.original.iPowerPlant              = civ.getImprovement(19)
gen.original.iHydroPlant              = civ.getImprovement(20)
gen.original.iNuclearPlant            = civ.getImprovement(21)
gen.original.iStockExchange           = civ.getImprovement(22)
gen.original.iSewerSystem             = civ.getImprovement(23)
gen.original.iSupermarket             = civ.getImprovement(24)
gen.original.iSuperhighways           = civ.getImprovement(25)
gen.original.iResearchLab             = civ.getImprovement(26)
gen.original.iSAMMissileBattery       = civ.getImprovement(27)
gen.original.iCoastalFortress         = civ.getImprovement(28)
gen.original.iSolarPlant              = civ.getImprovement(29)
gen.original.iHarbor                  = civ.getImprovement(30)
gen.original.iOffshorePlatform        = civ.getImprovement(31)
gen.original.iAirport                 = civ.getImprovement(32)
gen.original.iPoliceStation           = civ.getImprovement(33)
gen.original.iPortFacility            = civ.getImprovement(34)
gen.original.iTransporter             = civ.getImprovement(35)
gen.original.wPyramids                = civ.getWonder(0)
gen.original.wHangingGardens          = civ.getWonder(1)
gen.original.wColossus                = civ.getWonder(2)
gen.original.wLighthouse              = civ.getWonder(3)
gen.original.wGreatLibrary            = civ.getWonder(4)
gen.original.wOracle                  = civ.getWonder(5)
gen.original.wGreatWall               = civ.getWonder(6)
gen.original.wSunTzusWarAcademy       = civ.getWonder(7)
gen.original.wKingRichardsCrusade     = civ.getWonder(8)
gen.original.wMarcoPolosEmbassy       = civ.getWonder(9)
gen.original.wMichelangelosChapel     = civ.getWonder(10)
gen.original.wCopernicusObservatory   = civ.getWonder(11)
gen.original.wMagellansExpedition     = civ.getWonder(12)
gen.original.wShakespearesTheatre     = civ.getWonder(13)
gen.original.wLeonardosWorkshop       = civ.getWonder(14)
gen.original.wJSBachsCathedral        = civ.getWonder(15)
gen.original.wIsaacNewtonsCollege     = civ.getWonder(16)
gen.original.wAdamSmithsTradingCo     = civ.getWonder(17)
gen.original.wDarwinsVoyage           = civ.getWonder(18)
gen.original.wStatueofLiberty         = civ.getWonder(19)
gen.original.wEiffelTower             = civ.getWonder(20)
gen.original.wWomensSuffrage          = civ.getWonder(21)
gen.original.wHooverDam               = civ.getWonder(22)
gen.original.wManhattanProject        = civ.getWonder(23)
gen.original.wUnitedNations           = civ.getWonder(24)
gen.original.wApolloProgram           = civ.getWonder(25)
gen.original.wSETIProgram             = civ.getWonder(26)
gen.original.wCureforCancer           = civ.getWonder(27)
gen.original.bDesert                  =civ.getBaseTerrain(0,0)  --Drt
gen.original.bPlains                  =civ.getBaseTerrain(0,1)  --Pln
gen.original.bGrassland               =civ.getBaseTerrain(0,2)  --Grs
gen.original.bForest                  =civ.getBaseTerrain(0,3)  --For
gen.original.bHills                   =civ.getBaseTerrain(0,4)  --Hil
gen.original.bMountains               =civ.getBaseTerrain(0,5)  --Mou
gen.original.bTundra                  =civ.getBaseTerrain(0,6)  --Tun
gen.original.bGlacier                 =civ.getBaseTerrain(0,7)  --Gla
gen.original.bSwamp                   =civ.getBaseTerrain(0,8)  --Swa
gen.original.bJungle                  =civ.getBaseTerrain(0,9)  --Jun
gen.original.bOcean                   =civ.getBaseTerrain(0,10)  --Oce
gen.original.tDesert                  =civ.getTerrain(0,0,0)
gen.original.tOasis                   =civ.getTerrain(0,0,1) -- Fish Resource
gen.original.tDesertOil               =civ.getTerrain(0,0,2) -- Whale Resource
gen.original.tPlains                  =civ.getTerrain(0,1,0)
gen.original.tBuffalo                 =civ.getTerrain(0,1,1) -- Fish Resource
gen.original.tWheat                   =civ.getTerrain(0,1,2) -- Whale Resource
gen.original.tGrassland               =civ.getTerrain(0,2,0)
gen.original.tForest                  =civ.getTerrain(0,3,0)
gen.original.tPheasant                =civ.getTerrain(0,3,1) -- Fish Resource
gen.original.tSilk                    =civ.getTerrain(0,3,2) -- Whale Resource
gen.original.tHills                   =civ.getTerrain(0,4,0)
gen.original.tCoal                    =civ.getTerrain(0,4,1) -- Fish Resource
gen.original.tWine                    =civ.getTerrain(0,4,2) -- Whale Resource
gen.original.tMountains               =civ.getTerrain(0,5,0)
gen.original.tGold                    =civ.getTerrain(0,5,1) -- Fish Resource
gen.original.tIron                    =civ.getTerrain(0,5,2) -- Whale Resource
gen.original.tTundra                  =civ.getTerrain(0,6,0)
gen.original.tGame                    =civ.getTerrain(0,6,1) -- Fish Resource
gen.original.tFurs                    =civ.getTerrain(0,6,2) -- Whale Resource
gen.original.tGlacier                 =civ.getTerrain(0,7,0)
gen.original.tIvory                   =civ.getTerrain(0,7,1) -- Fish Resource
gen.original.tGlacierOil              =civ.getTerrain(0,7,2) -- Whale Resource
gen.original.tSwamp                   =civ.getTerrain(0,8,0)
gen.original.tPeat                    =civ.getTerrain(0,8,1) -- Fish Resource
gen.original.tSpice                   =civ.getTerrain(0,8,2) -- Whale Resource
gen.original.tJungle                  =civ.getTerrain(0,9,0)
gen.original.tGems                    =civ.getTerrain(0,9,1) -- Fish Resource
gen.original.tFruit                   =civ.getTerrain(0,9,2) -- Whale Resource
gen.original.tOcean                   =civ.getTerrain(0,10,0)
gen.original.tFish                    =civ.getTerrain(0,10,1) -- Fish Resource
gen.original.tWhales                  =civ.getTerrain(0,10,2) -- Whale Resource


-- gen.isTileRevealed(tile,tribe) -> boolean
-- returns true if tile is revealed, false otherwise
function gen.isTileRevealed(tile,tribe)
    tile = toTile(tile)
    return isBit1(tile.visibility,tribe.id+1)
end

-- gen.revealTile(tile,tribe) -> void
-- makes tile visible to tribe
function gen.revealTile(tile,tribe)
    tile = toTile(tile)
    tile.visibility = gen.setBit1(tile.visibility,tribe.id+1)
end

-- gen.coverTile(tile,tribe) -> void
-- covers a tile so it isn't visible to tribe (if it ever was)
function gen.coverTile(tile,tribe)
    tile = toTile(tile)
    tile.visibility = gen.setBit0(tile.visibility,tribe.id+1)
end

-- gen.isUnitStackVisible(unitOrTile,tribe,emptyTileReturnValue=nil) --> boolean or emptySquareReturnValue
-- if unit provided, returns true if that unit is visible to tribe, and false if not
-- a tribe's units are visible to it (even though unit.visibility doesn't show this)
-- if tile provided, returns true if there are units on the tile and the tribe can see them,
-- false if units are on the tile and the tribe can't see them, and
-- returns emptyTileReturnValue (default nil) if there are no units on the tile
-- 
function gen.isUnitStackVisible(unitOrTile,tribe,emptyTileReturnValue)
    if civ.isUnit(unitOrTile) then
        return (unitOrTile.owner == tribe) or isBit1(unitOrTile.visibility,tribe.id+1)
    end
    if civ.isTile(unitOrTile) then
        if not unitOrTile.defender then
            return emptyTileReturnValue
        end
        local unit = unitOrTile.units()
        return (unit.owner == tribe) or isBit1(unit.visibility,tribe.id+1)
    end
    error("gen.isUnitStackVisibile: first argument must be a unit or a tile.  Received: "..tostring(unitOrTile))
end


-- gen.revealUnitStack(unitOrTile,tribe) --> void
-- if unit provided, reveals that unit and all other units on the tile
-- to the tribe
-- if tile, reveals all units on the tile (if any are present)
function gen.revealUnitStack(unitOrTile,tribe)
    local tile = nil
    if civ.isUnit(unitOrTile) then
        tile = unitOrTile.location
    else
        tile = toTile(unitOrTile)
    end
    for unit in tile.units do
        unit.visibility = setBit1(unit.visibility,tribe.id+1)
    end
end

-- gen.hideUnitStack(unitOrTile,tribe) --> void
-- if unit provided, hides the unit and all other units on the tile from tribe
-- if tile provided, hides all units on the tile (if any are present)
function gen.hideUnitStack(unitOrTile,tribe)
    local tile = nil
    if civ.isUnit(unitOrTile) then
        tile = unitOrTile.location
    else
        tile = toTile(unitOrTile)
    end
    for unit in tile.units do
        unit.visibility = setBit0(unit.visibility,tribe.id+1)
    end
end
--
--
--
--
-- gen.isCityCharted(city,tribe) --> bool
-- returns true if city is "knownTo" tribe (that is,
-- will appear on the map if the tile is visible), false otherwise
function gen.isCityCharted(city,tribe)
    return isBit1(city.knownTo,tribe.id+1) and city.sizeForTribe[tribe] ~= 0
end

-- gen.chartCity(city,tribe,visibleSize=nil) --> void
-- makes city visible to tribe on the map, setting it to visibleSize if provided.
-- If city.sizeForTribe[tribe] == 0 (the default value) after this, it is set to 1
-- since a city does not appear if city.sizeForTribe[tribe] == 0
-- does not change the visibility of the tile
function gen.chartCity(city,tribe,visibleSize)
    if visibleSize then
        city.sizeForTribe[tribe] = visibleSize
    end
    city.sizeForTribe[tribe] = math.max(1,city.sizeForTribe[tribe])
    city.knownTo = setBit1(city.knownTo,tribe.id+1)
end

-- gen.unchartCity(city,tribe) --> void
-- makes a city invisible to tribe (but doesn't cover the tile in black)
-- by changing the knownTo field
function gen.unchartCity(city,tribe) 
    city.knownTo = setBit0(city.knownTo,tribe.id+1)
end





local function buildChartingFunctions(name,bitString)
    gen["is"..name.."Charted"] = function(tile,tribe)
        tile = toTile(tile)
        return checkBits(tile.visibleImprovements[tribe],bitString)
    end
    gen["chart"..name] = function(tile,tribe)
        tile = toTile(tile)
        tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],bitString)
    end
    local unBitString = string.gsub(bitString,"1","0")
    gen["unchart"..name] = function(tile,tribe)
        tile = toTile(tile)
        if checkBits(tile.visibleImprovements[tribe],bitString) then
            tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],unBitString)
        end
    end
end


-- gen.isIrrigationCharted(tile,tribe) --> bool
-- returns true if tribe sees Irrigation on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartIrrigation(tile,tribe) --> void
-- charts Irrigation on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartIrrigation(tile,tribe) --> void
-- uncharts Irrigation on the tribe's map of tile, if Irrigation has been charted.
-- If Irrigation is not charted, the chart remains unchanged
buildChartingFunctions("Irrigation","hgfe01ba")

-- gen.isMineCharted(tile,tribe) --> bool
-- returns true if tribe sees Mine on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartMine(tile,tribe) --> void
-- charts Mine on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartMine(tile,tribe) --> void
-- uncharts Mine on the tribe's map of tile, if Mine has been charted.
-- If Mine is not charted, the chart remains unchanged
buildChartingFunctions("Mine","hgfe10ba")

-- gen.isFarmlandCharted(tile,tribe) --> bool
-- returns true if tribe sees Farmland on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartFarmland(tile,tribe) --> void
-- charts Farmland on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartFarmland(tile,tribe) --> void
-- uncharts Farmland on the tribe's map of tile, if Farmland has been charted.
-- If Farmland is not charted, the chart remains unchanged
buildChartingFunctions("Farmland","hgfe11ba")

-- gen.isRoadCharted(tile,tribe) --> bool
-- returns true if tribe sees Road on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartRoad(tile,tribe) --> void
-- charts Road on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartRoad(tile,tribe) --> void
-- uncharts Road on the tribe's map of tile, if Road has been charted.
-- If Road is not charted, the chart remains unchanged
buildChartingFunctions("Road","hgf1dcba")

-- gen.isRailroadCharted(tile,tribe) --> bool
-- returns true if tribe sees Railroad on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartRailroad(tile,tribe) --> void
-- charts Railroad on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartRailroad(tile,tribe) --> void
-- uncharts Railroad on the tribe's map of tile, if Railroad has been charted.
-- If Railroad is not charted, the chart remains unchanged
buildChartingFunctions("Railroad","hg11dcba")
gen.unchartRailroad = function(tile,tribe)
    tile = toTile(tile)
    if checkBits(tile.visibleImprovements[tribe],"hg11dcba") then
        tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],"hg0edcba")
    end
end
-- gen.unchartTransportation(tile,tribe) --> void
-- uncharts road and railroad on the tribe's map of tile
function gen.unchartTransportation(tile,tribe)
    tile = toTile(tile)
    tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],"hg00dcba")
end

-- gen.isFortressCharted(tile,tribe) --> bool
-- returns true if tribe sees Fortress on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartFortress(tile,tribe) --> void
-- charts Fortress on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartFortress(tile,tribe) --> void
-- uncharts Fortress on the tribe's map of tile, if Fortress has been charted.
-- If Fortress is not charted, the chart remains unchanged
buildChartingFunctions("Fortress","h1fedc0a")

-- gen.isAirbaseCharted(tile,tribe) --> bool
-- returns true if tribe sees Airbase on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartAirbase(tile,tribe) --> void
-- charts Airbase on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartAirbase(tile,tribe) --> void
-- uncharts Airbase on the tribe's map of tile, if Airbase has been charted.
-- If Airbase is not charted, the chart remains unchanged
buildChartingFunctions("Airbase","h1fedc1a")

-- gen.isPollutionCharted(tile,tribe) --> bool
-- returns true if tribe sees Pollution on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartPollution(tile,tribe) --> void
-- charts Pollution on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartPollution(tile,tribe) --> void
-- uncharts Pollution on the tribe's map of tile, if Pollution has been charted.
-- If Pollution is not charted, the chart remains unchanged
buildChartingFunctions("Pollution","1gfedc0a")

-- gen.isTransporterCharted(tile,tribe) --> bool
-- returns true if tribe sees Transporter on the tile, and false otherwise
-- does not consider if tile is revealed to the tribe
-- gen.chartTransporter(tile,tribe) --> void
-- charts Transporter on the tribe's map of tile, uncharting any conflicting improvements
-- gen.unchartTransporter(tile,tribe) --> void
-- uncharts Transporter on the tribe's map of tile, if Transporter has been charted.
-- If Transporter is not charted, the chart remains unchanged
buildChartingFunctions("Transporter","1gfedc1a")

-- gen.chartTruthfully(tile,tribe) --> void
function gen.chartTruthfully(tile,tribe)
    gen.revealTile(tile,tribe)
    if tile.city then
        gen.chartCity(tile.city,tribe,tile.city.size)
    end
    tile.visibleImprovements[tribe] = tile.improvements
end


function buildAdvancedFlags(name,bitNumber)
    gen["is"..name] = function(unitType)
        return isBit1(unitType.advancedFlags,bitNumber)
    end
    gen["give"..name] = function(unitType)
        unitType.advancedFlags = setBit1(unitType.advancedFlags,bitNumber)
    end
    gen["remove"..name] = function(unitType)
        unitType.advancedFlags = setBit0(unitType.advancedFlags,bitNumber)
    end
end

-- gen.isInvisibleUntilAttack(unitType) --> bool
-- gen.giveInvisibleUntilAttack(unitType) --> void
-- gen.removeInvisibleUntilAttack(unitType) --> void
buildAdvancedFlags("InvisibleUntilAttack",1)

-- gen.isNonDisbandable(unitType) --> bool
-- gen.giveNonDisbandable(unitType) --> void
-- gen.removeNonDisbandable(unitType) --> void
buildAdvancedFlags("NonDisbandable",2)

-- gen.isZeroRangeAirUnitDamageOverride(unitType) --> bool
-- gen.giveZeroRangeAirUnitDamageOverride(unitType) --> void
-- gen.removeZeroRangeAirUnitDamageOverride(unitType) --> void
buildAdvancedFlags("ZeroRangeAirUnitDamageOverride",3)

-- gen.isCannotBuyOffBarbarian(unitType) --> bool
-- gen.giveCannotBuyOffBarbarian(unitType) --> void
-- gen.removeCannotBuyOffBarbarian(unitType) --> void
buildAdvancedFlags("CannotBuyOffBarbarian",4)

-- gen.isCanCrossImpassableTerrain(unitType) --> bool
-- gen.giveCanCrossImpassableTerrain(unitType) --> void
-- gen.removeCanCrossImpassableTerrain(unitType) --> void
buildAdvancedFlags("CanCrossImpassableTerrain",5)

-- gen.isBarbarianWillNotExpire(unitType) --> bool
-- gen.giveBarbarianWillNotExpire(unitType) --> void
-- gen.removeBarbarianWillNotExpire(unitType) --> void
buildAdvancedFlags("BarbarianWillNotExpire",7)


-- gen.isOverrideSPR(unitType) --> bool
-- gen.giveOverrideSPR(unitType) --> void
-- gen.removeOverrideSPR(unitType) --> void
buildAdvancedFlags("OverrideSPR",8)

function buildAdvancedSettlerFlags(name,bitNumber)
    gen["is"..name] = function(unitType)
        -- a ~= b is xor when a and b are booleans
        return unitType.role == 5 ~= isBit1(unitType.advancedFlags,bitNumber)
    end
    gen["give"..name] = function(unitType)
        if unitType.role == 5 then
            -- if settler, the functionality is default, so set flag to 0
            unitType.advancedFlags = setBit0(unitType.advancedFlags,bitNumber)
        else
            -- if not settler, the functionality is not default, so set flag to 1
            unitType.advancedFlags = setBit1(unitType.advancedFlags,bitNumber)
        end
    end
    gen["remove"..name] = function(unitType)
        if unitType.role == 5 then
            -- if settler, the functionality is default, so set flag to 1 to remove it
            unitType.advancedFlags = setBit1(unitType.advancedFlags,bitNumber)
        else
            -- if not settler, the functionality is not default, so set flag to 0 to remove it
            unitType.advancedFlags = setBit0(unitType.advancedFlags,bitNumber)
        end
    end
end

--gen.isReducePopulationWhenBuilt(unitType) --> bool
--gen.giveReducePopulationWhenBuilt(unitType) --> void
--gen.removeReducePopulationWhenBuilt(unitType) --> void
buildAdvancedSettlerFlags("ReducePopulationWhenBuilt",10)

--gen.isRequiresFoodSupport(unitType) --> bool
--gen.giveRequiresFoodSupport(unitType) --> void
--gen.removeRequiresFoodSupport(unitType) --> void
buildAdvancedSettlerFlags("RequiresFoodSupport",11)


--gen.isCanFoundCities(unitType) --> bool
--gen.giveCanFoundCities(unitType) --> void
--gen.removeCanFoundCities(unitType) --> void
buildAdvancedSettlerFlags("CanFoundCities",12)


-- gen.isCanImproveTiles(unitType)--> bool
gen.isCanImproveTiles = function(unitType)
    return unitType.role == 5 and isBit0(unitType.advancedFlags,13)
end
-- gen.giveCanImproveTiles(unitType,ignoreError=false) --> void
-- bestows the ability to improve tiles to units with settler role
-- units without settler role produce an error, unless ignoreError
-- is set to true
gen.giveCanImproveTiles = function(unitType,ignoreError)
    if unitType.role == 5 then
        -- if settler, the functionality is default, so set flag to 0
        unitType.advancedFlags = setBit0(unitType.advancedFlags,13)
    elseif not ignoreError then
        error("gen.giveCanImproveTiles: only units with the settler role (unitType.role == 5) can be given the ability to improve tiles.  If you wish to suppress this error and have gen.giveCanImproveTiles simply do nothing when applied to non-settler role units, use\ngen.giveCanImproveTiles(unitType,true)")
    end
end
-- gen.removeCanImproveTiles(unitType,ignoreError=false) --> void
-- removes the ability to improve tiles from units with settler role
-- units without settler role produce an error, unless ignoreError
-- is set to true
gen.removeCanImproveTiles = function(unitType,ignoreError)
    if unitType.role == 5 then
        -- if settler, the functionality is default, so set flag to 1 to remove it
        unitType.advancedFlags = setBit1(unitType.advancedFlags,13)
    elseif not ignoreError then
        error("gen.removeCanImproveTiles: only units with the settler role (unitType.role == 5) can be given the ability to improve tiles.  If you wish to suppress this error and have gen.giveCanImproveTiles simply do nothing when applied to non-settler role units, use\ngen.removeCanImproveTiles(unitType,true)")
    end
end

-- gen.makeDataTable(inputTable={},tableName="unnamed data table) --> dataTable
--  makes a 'dataTable', which functions as a table, but with the ability to disable
--  overwriting values for existing keys
--  adding new keys
--  requesting nil values (values for keys that don't exist)
--  this functionality is achieved with a metatable
function gen.makeDataTable(inputTable,tableName)
    inputTable = inputTable or {}
    tableName = tableName or "unnamed data table"
    if type(tableName) ~= "string" then
        error("gen.makeDataTable: tableName argument (arg 2) must be a string.")
    end
    local metatable = {}
    metatable.dataRecord = {}
    for key,value in pairs(inputTable) do
        metatable.dataRecord[key] = value
        inputTable[key] = nil
    end
    metatable.type = "dataTable"
    metatable.forbidReplacement = false
    metatable.forbidNilValueAccess = false
    metatable.forbidNewKeys = false
    metatable.__newindex = function(inputTbl,key,value)
        if metatable.dataRecord[key] ~= nil then
            if metatable.forbidReplacement then
                error("gen.makeDataTable: the table "..tableName.." can't have the values for existing keys reassigned.  The key "..tostring(key).." has already been assigned a value of "..tostring(metatable.dataRecord[key]).." and is now being assigned the value of "..tostring(value).." .")
            else
                metatable.dataRecord[key] = value
            end
        else
            if metatable.forbidNewKeys then
                error("gen.makeDataTable: the table "..tableName.." can't have values assigned to keys that do not already have values.  The key "..tostring(key).." has not already been assigned a value.")
            else
                metatable.dataRecord[key] = value
            end
        end
    end
    metatable.__index = function(inputTbl,key)
        local val = metatable.dataRecord[key]
        if val == nil and metatable.forbidNilValueAccess then
            error("gen.makeDataTable: the table "..tableName.." is not allowed to access values for keys that don't exist.  The key "..tostring(key).." does not have a value associated with it.")
        else
            return val
        end
    end
    metatable.__pairs = function(inputTbl)
        return pairs(metatable.dataRecord)
    end
    metatable.__ipairs = function(inputTbl)
        return ipairs(metatable.dataRecord)
    end

    inputTable = setmetatable(inputTable,metatable)
    return inputTable
end

-- gen.forbidReplacement(dataTable) --> void
function gen.forbidReplacement(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.forbidReplacement: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidReplacement = true
end

-- gen.allowReplacement(dataTable) --> void
function gen.allowReplacement(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.allowReplacement: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidReplacement = false
end


-- gen.forbidNewKeys(dataTable) --> void
function gen.forbidNewKeys(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.forbidNewKeys: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNewKeys = true
end

-- gen.allowNewKeys(dataTable) --> void
function gen.allowNewKeys(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.allowNewKeys: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNewKeys = false
end

-- gen.forbidNilValueAccess(dataTable) --> void
function gen.forbidNilValueAccess(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.forbidNilValueAccess: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNilValueAccess = true
end

-- gen.allowNilValueAccess(dataTable) --> void
function gen.allowNilValueAccess(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.allowNilValueAccess: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNilValueAccess = false
end

local scenarioDirectory = nil

-- gen.setScenarioDirectory(directoryPath) --> void
function gen.setScenarioDirectory(directory)
    if type(directory) == "string" then
        scenarioDirectory = directory
    else
        error("gen.setScenarioDirectory expects a string as the argument.")
    end
end

-- gen.getScenarioDirectory() --> string
function gen.getScenarioDirectory()
    if scenarioDirectory then
        return scenarioDirectory
    else
        error("gen.getScenarioDirectory: scenario directory path has not been set.  Use gen.setScenarioDirectory in your events.lua file.  If you are using the Lua Scenario Template, there should be a local variable named scenarioFolder.  Try the line:\n gen.setScenarioDirectory(scenarioFolder)")
    end
end

-- gen.isStateSavable(item) --> boolean
--  An item is "state savable" if it is either
--  nil
--  a number
--  a string
--  a boolean
--  a table with keys that are numbers or strings
--    and with values that are also state savable
--  Note: table can't have a metatable
function gen.isStateSavable(item)
  if type(item) == "table" then
    if getmetatable(item) then
        return false
    end
    for key,value in pairs(item) do
      if type(key) ~= "number" and type(key) ~="string" then
        return false
      end
      if not gen.isStateSavable(value) then
        return false
      end
    end
    return true
  elseif type(item) == "number" then
    return true
  elseif type(item) == "string" then
    return true
  elseif type(item) == "nil" then
    return true
  elseif type(item) == "boolean" then
    return true
  else
    return false
  end  
end

-- gen.calculateWeight(item,weightTable,extraArgument=nil) --> number or false
-- weightTable has functions as keys, and numbers or false as values
--      {[keyFunc(item,extraArgument)-->boolean] = number or boolean or string or function(item) -> number}
--      for each key in the weight table, apply keyFunc to the item
--      if keyFunc(item,extraArgument) then
--          if the value is a number, add the number to the weight
--          if the value is a string add item[value] to the weight
--          if the value is a function, add value(item,extraArgument) to the weight
--          if the value is false, return 'false' as the weight
--          if the value is true, do nothing
--      else
--          if the value is a number, do nothing
--          if the value is false, do nothing
--          if the value is a string, do nothing
--          if the value is true, return 'false' as the weight
--      
--      That is, false means that keyFunc must not apply to the item
--      while true means that keyFunc must apply to the item
--
--      default weight is 0
--
local function calculateWeight(item,weightTable,extraArgument)
    local defaultWeight = 0
    for keyFunc, value in pairs(weightTable) do
        if keyFunc(item,extraArgument) then
            if type(value) == "number" then
                defaultWeight = defaultWeight + value
            elseif value == false then
                return false
            elseif type(value) == "string" then
                defaultWeight = defaultWeight + item[value]
            elseif type(value) == "function" then
                local v = value(item,extraArgument)
                if v == false then
                    return false
                end
                defaultWeight = defaultWeight + v
            elseif type(value) == "boolean" then
            else
                error("gen.calculateWeight: weightTable (2nd argument) values must be numbers, booleans, strings or functions.  Received: "..tostring(value))
            end
        else
            if value == true then
                return false
            end
        end
    end
    return defaultWeight
end
gen.calculateWeight = calculateWeight

-- takes a new item and a new weight, and sorts them
-- into the sortedItems and sortedWeights list
-- if changeOrder(weight1,weight2) is true,
-- weight2 should be before weight1
-- changeOrder(nil,weight2) should always be true
-- If at the end there are more than maxLength items in the
-- list, the last item is removed

local function bubbleUp(sortedItems,sortedWeights,maxLength,newItem,newWeight,changeOrder)
    sortedItems[maxLength+1] = newItem
    sortedWeights[maxLength+1] = newWeight
    for i=maxLength,1,-1 do
        if changeOrder(sortedWeights[i],sortedWeights[i+1]) then
            sortedItems[i],sortedItems[i+1] = sortedItems[i+1],sortedItems[i]
            sortedWeights[i],sortedWeights[i+1] = sortedWeights[i+1],sortedWeights[i]
        else
            break
        end
    end
    sortedItems[maxLength+1] = nil
    sortedWeights[maxLength+1] = nil
end


-- gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction,getTopX,changeOrder,functionName,extraArgument)
--      wrap this to construct
--      gen.getBiggestWeight and gen.getSmallestWeight
--      listOrIterator
--          if iterator, returns the items for consideration
--          if table, each item is a value in the table, and the table consists only of those values
--      weightTableOrWeightFunction
--          if weightTable, use gen.calculateWeight(item,weightTable,extraArgument) as the weight function
--          a weightFunction(item,extraArgument) must return either a number or false.  When false is returned,
--          the item is not considered at all
--      getTopX
--          if absent, the item with the largest weight is returned, or nil if no valid item is found
--          if integer, a table with that number of items is returned, with index 1 associated with the
--          item of the largest weight, 2 the next highest weight and so on.  If there are fewer valid
--          items, the corresponding values are nil
--      changeOrder function
--          if changeOrder(weight1,weight2) is true,
--          weight2 should be before weight1
--          changeOrder(nil,weight2) should always be true
--      functionName string

function gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction,getTopX,changeOrder,functionName,extraArgument)
    local weightFunction = nil 
    if type(weightTableOrWeightFunction) == "table" then
        weightFunction = function(item,extraArgument) return calculateWeight(item,weightTableOrWeightFunction,extraArgument) end
    elseif type(weightTableOrWeightFunction) == "function" then
        weightFunction = weightTableOrWeightFunction
    else
        error(functionName..": second argument must be either a table or a function(item)->(number or false).  Received: "..tostring(weightTableOrWeightFunction))
    end
    local iterator = nil
    if type(listOrIterator) == "function" then
        -- iterator provided
        iterator = listOrIterator
    elseif type(listOrIterator) == "table" then
        -- table provided
        iterator = coroutine.wrap( function() for _,item in pairs(listOrIterator) do coroutine.yield(item) end end)
    else
        error(functionName..": first argument must either be an iterator (a type of function), or a table.  Received: "..tostring(listOrIterator))
    end
    local maxLength = getTopX or 1
    local sortedItems = {}
    local sortedWeights = {}
    for item in iterator do
        local weight = weightFunction(item,extraArgument)
        if weight then
            bubbleUp(sortedItems,sortedWeights,maxLength,item,weight,changeOrder)
        end
    end
    if getTopX then
        return sortedItems,sortedWeights
    else
        return sortedItems[1],sortedWeights[1]
    end
end


-- gen.getBiggestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil
--      listOrIterator
--          if iterator, returns the items for consideration
--          if table, each item is a value in the table, and the table consists only of those values
--      weightTableOrWeightFunction
--          if weightTable, use gen.calculateWeight(item,weightTable) as the weight function
--          a weightFunction must return either a number or false.  When false is returned,
--          the item is not considered at all
--      getTopX
--          if absent, the item with the largest weight is returned, or nil if no valid item is found
--          if integer, a table with that number of items is returned, with index 1 associated with the
--          item of the largest weight, 2 the next highest weight and so on.  If there are fewer valid
--          items, the corresponding values are nil
--          as a second return value, a weight or table of weights (or nil) is returned
function gen.getBiggestWeights(listOrIterator,weightTableOrWeightFunction,getTopX,extraArgument)
    local changeFunction = function(weight1,weight2)
        return (type(weight2) == "number") and (weight1 == nil or weight1 < weight2)
    end
    local functionName = "gen.getBiggestWeights"
    return gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction, getTopX, changeFunction, functionName,extraArgument)
end

-- gen.getSmallestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil
--      listOrIterator
--          if iterator, returns the items for consideration
--          if table, each item is a value in the table, and the table consists only of those values
--      weightTableOrWeightFunction
--          if weightTable, use gen.calculateWeight(item,weightTable) as the weight function
--          a weightFunction must return either a number or false.  When false is returned,
--          the item is not considered at all
--      getTopX
--          if absent, the item with the smallest weight is returned, or nil if no valid item is found
--          if integer, a table with that number of items is returned, with index 1 associated with the
--          item of the largest weight, 2 the next highest weight and so on.  If there are fewer valid
--          items, the corresponding values are nil
--          as a second return value, a weight or table of weights (or nil) is returned
function gen.getSmallestWeights(listOrIterator,weightTableOrWeightFunction,getTopX,extraArgument)
    local changeFunction = function(weight1,weight2)
        return (type(weight2) == "number") and (weight1 == nil or weight1 > weight2)
    end
    local functionName = "gen.getSmallestWeights"
    return gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction, getTopX, changeFunction, functionName,extraArgument)
end



--
-- These are the options for markers, and the relevant charting functions
-- entries 4 and 5 are conflicting markers
local markerOptions = {}
markerOptions["irrigation"]={gen.isIrrigationCharted, gen.chartIrrigation,gen.unchartIrrigation, "mine","farmland"}
markerOptions["mine"]={gen.isMineCharted, gen.chartMine,gen.unchartMine,"irrigation","farmland"}
markerOptions["farmland"]={gen.isFarmlandCharted, gen.chartFarmland,gen.unchartFarmland,"irrigation","mine"}
markerOptions["road"]={gen.isRoadCharted, gen.chartRoad,gen.unchartRoad}
markerOptions["railroad"]={gen.isRailroadCharted, gen.chartRailroad,gen.unchartRailroad}
markerOptions["fortress"]={gen.isFortressCharted, gen.chartFortress,gen.unchartFortress,"airbase"}
markerOptions["airbase"]={gen.isAirbaseCharted, gen.chartAirbase,gen.unchartAirbase,"fortress"}
markerOptions["pollution"]={gen.isPollutionCharted, gen.chartPollution,gen.unchartPollution,"transporter"}
markerOptions["transporter"]={gen.isTransporterCharted, gen.chartTransporter,gen.unchartTransporter,"pollution"}

gen.markerOptions = markerOptions

local validMarkerOptionsList = 'Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".'
gen.validMarkerOptionsList = validMarkerOptionsList

-- tileMarkerInfo = {[tribe.id] = {"originalChart"=bitmask, "markerOption"=trueNil}}
-- if tileMarkerInfo[tribe.id]["markerOption"] is true, then a marker has been placed on that
-- tile, and not been removed by a function.
-- If the marker is not visible, the tribe must have recently observed the tile,
-- so originalChart will be updated to true chart if this is noticed

-- genStateTable.tileMarkerTable is initialized in gen.linkGeneralLibraryState
local function updateTileMarkerTable(tileMarkerInfo,tile)
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        local tribe = civ.getTribe(tribeID)
        for key,val in pairs(tribeMarkerInfo) do
            if key ~= "originalChart" then
                -- 1st entry in markerOptions[key] is the isImprovementCharted function,
                -- so, if it is not, the tile must have been observed by the relevant player
                -- (since the key is nil if the tile is not marked by the relevant key)
                -- or there is a conflicting marker
                if not markerOptions[key][1](tile,tribe) then
                    local conflictKey1 = markerOptions[key][4]
                    local conflictKey2 = markerOptions[key][5]
                    if (conflictKey1 and tribeMarkerInfo[conflictKey1] and 
                        markerOptions[conflictKey1][1](tile,tribe)) then
                    elseif (conflictKey2 and tribeMarkerInfo[conflictKey2] and 
                        markerOptions[conflictKey2][1](tile,tribe)) then
                    else
                        tribeMarkerInfo["originalChart"] = tile.improvements
                    end
                end
            end
        end
    end
end
-- markExists(tileMarkerInfo) --> boolean
-- returns true if a tribe has a mark on this tile, false otherwise
local function markExists(tileMarkerInfo)
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        for key, val in pairs(tribeMarkerInfo) do
            if key ~= "originalChart" then
                return true
            end
        end
    end
    return false
end

-- gen.placeMarker(tile,tribe,markerOption)
function gen.placeMarker(tile,tribe,markerOption)
    markerOption = string.lower(markerOption)
    local tileID = gen.getTileId(tile)
    genStateTable.tileMarkerTable[tileID] = genStateTable.tileMarkerTable[tileID] or {}
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    tileMarkerInfo[tribe.id] = tileMarkerInfo[tribe.id] or {["originalChart"]=tile.visibleImprovements[tribe]}
    --civ.ui.text(markerOption.." placed, originalChart: "..tileMarkerInfo[tribe.id]["originalChart"])
    -- markerOptions[key] are the charting functions (to chart, we want number 2)
    local chartingFunctions= markerOptions[markerOption]
    if not chartingFunctions then
        error("gen.placeMarker: the markerOption \""..markerOption.."\" is invalid.  Attempting to place marker on tile: "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    tileMarkerInfo[tribe.id][markerOption] = true
    chartingFunctions[2](tile,tribe)
end


-- removes the markerOption marker for tribe from tile, if it exists
-- gen.removeMarker(tile,tribe,markerOption) --> void
function gen.removeMarker(tile,tribe,markerOption)
    markerOption = string.lower(markerOption)
    local tileID = getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    if not tileMarkerInfo then
        return
    end
    updateTileMarkerTable(tileMarkerInfo,tile)
    -- markerOptions[key] are the charting functions
    local chartingFunctions= markerOptions[markerOption]
    if not chartingFunctions then
        error("gen.removeMarker: the markerOption \""..markerOption.."\" is invalid.  Attempting to remove marker on tile: "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    if not tileMarkerInfo[tribe.id] then
        return
    end
    tileMarkerInfo[tribe.id][markerOption] = nil
    -- show the original chart, then add back any other markers
    tile.visibleImprovements[tribe] = tileMarkerInfo[tribe.id]["originalChart"]
    for key,val in pairs(tileMarkerInfo[tribe.id]) do
        if key ~= "originalChart" then
            markerOptions[key][2](tile,tribe)
        end
    end
    --civ.ui.text(markerOption.." removed, originalChart: "..tileMarkerInfo[tribe.id]["originalChart"])
    -- if removing this eliminates all marks, then clear the data
    if not markExists(tileMarkerInfo) then
        genStateTable.tileMarkerTable[tileID] = nil
        return
    end
end

-- gen.maintainTileMarkerTable() --> void
-- check the marker table for any marker data that can be removed
-- and remove it
function gen.maintainTileMarkerTable()
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable) do
        updateTileMarkerTable(tileMarkerInfo,getTileFromId(tileID))
        if not markExists(tileMarkerInfo) then
            genStateTable.tileMarkerTable[tileID] = nil
        end
    end
end

-- gen.removeMarkersFromTile(tile,tribeOrNil) --> void
--      removes all markers on tile for the tribe
--      if tribe is omitted, removes markers for all tribes
function gen.removeMarkersFromTile(tile,tribe)
    local tileID = getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        if (tribe and tribe.id == tribeID) or not tribe then
            tile.visibleImprovements[civ.getTribe(tribeID)] = tribeMarkerInfo["originalChart"]
            tileMarkerInfo[tribeID] = nil
        end
    end
    if not markExists(tileMarkerInfo) then
        genStateTable.tileMarkerTable[tileID] = nil
    end
end

-- gen.removeAllMarkers(tribeOrNil,markerTypeOrNil) --> void
-- removes all markers of markerType for tribe
-- if tribe not specified, removes all markerType markers for all tribes
-- if markerType not specified, removes all markers for tribe
-- if neither specified, removes all markers for all tribes
function gen.removeAllMarkers(tribe,markerType)
    markerType = markerType and string.lower(markerType)
    local tileMarkerTable = genStateTable.tileMarkerTable
    if not markerType then
        for tileID, tileMarkerInfo in pairs(tileMarkerTable) do
            gen.removeMarkersFromTile(getTileFromId(tileID),tribe)
        end
        return
    end
    if not markerOptions[markerType] then
        error("gen.removeAllMarkers: the markerType \""..markerType.."\" is invalid.  Attempting to remove markers  for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    if tribe then
        for tileID, tileMarkerInfo in pairs(tileMarkerTable) do
            gen.removeMarker(getTileFromId(tileID),tribe,markerType)
        end
        return
    end
    for tileID, tileMarkerInfo in pairs(tileMarkerTable) do
        for i=0,7 do
            local t = civ.getTribe(i)
            if t then
                gen.removeMarker(getTileFromId(tileID),t,markerType)
            end
        end
    end
    return
end


local function displayMarks(tile,tileMarkerInfo,topMarkerType,secondMarkerType)
    if not tileMarkerInfo then
        return
    end
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        local tribe = civ.getTribe(tribeID)
        for key,val in pairs(tribeMarkerInfo) do
            if key ~= "originalChart" then
                markerOptions[key][2](tile,tribe)
            end
        end
        if secondMarkerType and tribeMarkerInfo[secondMarkerType] then
            markerOptions[secondMarkerType][2](tile,tribe)
        end
        if topMarkerType and tribeMarkerInfo[topMarkerType] then
            markerOptions[topMarkerType][2](tile,tribe)
        end
    end
end



-- gen.showAllMarkersOnTile(tile,topMarkerTypeOrNil,secondMarkerTypeOrNil) --> void
-- reapplies the charting functions for all markers
-- on the tile for all players.  If topMarkerType isnt
-- nil, that marker type is applied again last, in case
-- there are conflicting markers
-- the secondMarkerType is applied just before the top marker type
function gen.showAllMarkersOnTile(tile,topMarkerType,secondMarkerType)
    topMarkerType = topMarkerType and string.lower(topMarkerType)
    secondMarkerType = secondMarkerType and string.lower(topMarkerType)
    local tileID = getTileID(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    if topMarkerType and (not markerOptions[topMarkerType]) then
        error("gen.showAllMarkersOnTile: the topMarkerType \""..tostring(topMarkerType).."\" id invalid.  Attempting to show markers for tile "..tostring(tile)..".  "..validMarkerOptionsList)
    end
    if secondMarkerType and (not markerOptions[secondMarkerType]) then
        error("gen.showAllMarkersOnTile: the secondMarkerType \""..tostring(secondMarkerType).."\" id invalid.  Attempting to show markers for tile "..tostring(tile)..".  "..validMarkerOptionsList)
    end
    displayMarks(tile,tileMarkerInfo,topMarkerType,secondMarkerType)
end

-- gen.showAllMarkers(topMarkerTypeOrNil,secondMarkerTypeOrNil) --> void
-- reapplies the charting functions for all markers
-- on all tiles for all players.  If topMarkerType isn't nil,
-- that marker type is applied last again, in case there
-- are conflicting markers
-- the secondMarkerType is applied just before the top marker type
function gen.showAllMarkers(topMarkerType,secondMarkerType)
    topMarkerType = topMarkerType and string.lower(topMarkerType)
    secondMarkerType = secondMarkerType and string.lower(secondMarkerType)
    if topMarkerType and (not markerOptions[topMarkerType]) then
        error("gen.showAllMarkers: the topMarkerType \""..tostring(topMarkerType).."\" id invalid.  "..validMarkerOptionsList)
    end
    if secondMarkerType and (not markerOptions[secondMarkerType]) then
        error("gen.showAllMarkers: the secondMarkerType \""..tostring(secondMarkerType).."\" id invalid.  "..validMarkerOptionsList)
    end
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable) do
        local tile = getTileFromId(tileID)
        displayMarks(tile,tileMarkerInfo,topMarkerType,secondMarkerType)
    end
end

-- gen.hasMarker(tile,tribe,markerType)
-- returns true if tile has a marker of markerType for tribe
function gen.hasMarker(tile,tribe,markerType)
    markerType = string.lower(markerType)
    if not markerOptions[markerType] then
        error("gen.hasMarker: the markerType \""..markerType.."\" is invalid.  Attempting to check for a marker at "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    local tileID = gen.getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID] or {}
    return not not (tileMarkerInfo[tribe.id] and tileMarkerInfo[tribe.id][markerType])
end

-- gen.isMarkerVisible(tile,tribe,markerType)
-- returns true if the tile has the markerType and the markerType is charted, false otherwise
function gen.isMarkerVisible(tile,tribe,markerType)
    markerType = string.lower(markerType)
    if not markerOptions[markerType] then
        error("gen.hasMarker: the markerType \""..markerType.."\" is invalid.  Attempting to check for a marker at "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    return gen.hasMarker(tile,tribe,markerType) and markerOptions[markerType][1](tile,tribe)
end

-- gen.hideMarker(tile,tribe,markerType)
-- uncharts the marker for the tribe, but does not remove the marker
-- does nothing if the tribe doesn't have that marker
-- or if the marker is already hidden
function gen.hideMarker(tile,tribe,markerType)
    markerType = string.lower(markerType)
    if not markerOptions[markerType] then
        error("gen.hasMarker: the markerType \""..markerType.."\" is invalid.  Attempting to check for a marker at "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    -- (gen.isMarkerVisible checks if the marker is actually there)
    if not gen.isMarkerVisible(tile,tribe,markerType) then 
        return
    end
    -- show the original chart, then add back any other markers
    local tileID = gen.getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID] or {}
    tile.visibleImprovements[tribe] = tileMarkerInfo[tribe.id]["originalChart"]
    for key,val in pairs(tileMarkerInfo[tribe.id]) do
        if key ~= "originalChart" and key ~= markerType then
            markerOptions[key][2](tile,tribe)
        end
    end
end

-- gen.hideAllMarkersOnTile(tile,tribe)
-- hides all markers on a given tile for the given tribe
function gen.hideAllMarkersOnTile(tile,tribe)
    for key,_ in pairs(markerOptions) do
        gen.hideMarker(tile,tribe,key)
    end
end


-- gen.hideAllMarkers(tribeOrNil,markerTypeOrNil)
-- hides all markers of the given type for that tribe
-- if tribe not specified, hides all markers of given type for
-- all tribes
-- if markerType not specified, hides markers of all types

function gen.hideAllMarkers(tribeOrNil,markerTypeOrNil)
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable) do
        if tribeOrNil then
            if markerTypeOrNil then
                gen.hideMarker(getTileFromID(tileID),tribeOrNil,markerTypeOrNil)
            else
                gen.hideAllMarkersOnTile(getTileFromID(tileID),tribeOrNil)
            end
        else
            for i=0,7 do
                local tribe = civ.getTribe(i)
                if tribe then
                    if markerTypeOrNil then
                        gen.hideMarker(getTileFromID(tileID),tribe,markerTypeOrNil)
                    else
                        gen.hideAllMarkersOnTile(getTileFromID(tileID),tribe)
                    end
                end
            end
        end
    end
end

-- gen.showMarker(tile,tribe,markerType)
-- shows the markerType for the tribe on the tile, if the marker is on the tile
function gen.showMarker(tile,tribe,markerType)
    if gen.hasMarker(tile,tribe,markerType) then
        markerOptions[markerType][2](tile,tribe)
    end
end
-- gen.showMarkerOnAllTiles(tribe,markerType)
function gen.showMarkerOnAllTiles(tribe,markerType)
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable) do
        gen.showMarker(getTileFromID(tileID),tribe,markerType)
    end
end




local outOfRangeMessageFn = function(unit)
    local message =  "Your aircraft has run out of fuel.  Fighter and Missile units must return to a city or Carrier at the end of each turn.  Bomber units must return at the end of their second turn."
    local dialog = civ.ui.createDialog()
    dialog.title = "Civ Rules: Fuel"
    dialog:addText(message)
    dialog:show()
    return
end

-- gen.setOutOfRangeMessage(textOrFunction,title=nil) --> void
-- if textOrFunction is a string, the text is shown when a unit is 
-- lost due to being out of range, and title is the box title
-- (if this is governed by events and not standard movement)
-- %STRING1 substitutes for the unit type's name
--
-- if textOrFunction is a function(unit) --> void
-- the function is trusted to generate the loss of fuel message
function gen.setOutOfRangeMessage(textOrFunction,title)
    if type(textOrFunction) == "string" then
        local function fuelMessage(unit)
            if type(title) ~= "string" and type(title) ~= "nil" then
                error("gen.setOutOfRangeMessage: second argument should be a string or nil.  Received: "..tostring(title))
            end
            local message = string.gsub(textOrFunction,"%%STRING1",unit.type.name)
            local dialog = civ.ui.createDialog()
            dialog.title = title
            dialog:addText(message)
            dialog:show()
            return
        end
        outOfRangeMessageFn = fuelMessage
        return
    end
    if type(textOrFunction) == "function" then
        outOfRangeMessageFn = textOrFunction
    end
    error("gen.setOutOfRangeMessage: First argument should be a string or a function(unit)-->void.  Received: "..tostring(textOrFunction))
end

-- gen.outOfRangeMessage(unit) --> void
-- shows the out of range message for a unit
function gen.outOfRangeMessage(unit)
    outOfRangeMessageFn(unit)
end

local rangeLimitsForLandAndSea = false
local rangeLimitsForLandAndSeaAI = false
local restoreRangeFunction = function(unit)
    return unit.location.city or gen.hasAirbase(unit.location)
end

-- gen.activateRangeForLandAndSea(restoreRangeFn=nil,applyToAI=false)
-- restoreRangeFn(unit) --> bool governs when a unit's range is restored
-- and is checked when entering the tile and also after the unit has been
-- given its last order for the turn (i.e. when the unit has all movement
-- expended and the next unit is activated, or at the end of the turn if it
-- still has movement points e.g. if sleeping).  
-- If true, range is restored, if false it is not
-- By default, range is restored in city squares and on airbases
-- If you want to clear movement points (like for air units) do it in this function
-- Land and Sea units must now abide by range limitations set in rules.txt (if they are not 0)
-- if applyToAI is true, the AI will lose units when it violates these limits
function gen.activateRangeForLandAndSea(restoreRangeFn,applyToAI)
    if rangeLimitsForLandAndSea then
        print("WARNING gen.activateRangeForLandAndSea: this function appears to have been run more than once, so nothing further was done.  If you don't have range for land and sea, seek help from Prof. Garfield.")
        return
    end
    if not fileFound then
        print("WARNING gen.activateRangeForLandAndSea: discreteEventsRegistrar.lua was not found, so range for land and sea was not activated.")
        return
    end
    for i=0, civ.cosmic.numberOfUnitTypes-1 do
        local unitType = civ.getUnitType(i)
        if unitType.range > 0 and unitType.domain ~= 1 and (unitType.role == 5 or unitType.role == 7) then
            error("gen.activateRangeForLandAndSea: The unit type "..unitType.name.." ("..tostring(i)..") has been assigned a range of "..tostring(unitType.range).." along with a role of "..tostring(unitType.role)..".  However, settler and trade units (roles 5 and 7) can't be given these limitations (since they use domainSpec for their special roles.")
        end
    end
    rangeLimitsForLandAndSea = true
    rangeLimitsForLandAndSeaAI = applyToAI or false
    if restoreRangeFn then
        restoreRangeFunction = restoreRangeFn
        if type(restoreRangeFn) ~= "function" then
            error("gen.activateRangeForLandAndSea: the first argument must be either nil or a function(unit)-->bool.  Received "..tostring(restoreRangeFn))
        end
    end
    function discreteEvents.onFinalOrderGiven(unit)
        local unitType = unit.type
        if not (unit.owner.isHuman or rangeLimitsForLandAndSeaAI) then
            return
        end
        if unitType.domain == 1 or unitType.range == 0 then
            return
        end
        unit.domainSpec = unit.domainSpec+1
        if restoreRangeFunction(unit) then
            unit.domainSpec = 0
        end
        if unit.domainSpec >= unitType.range then
            outOfRangeMessageFn(unit)
            for possibleCargo in unit.location.units do
                if possibleCargo.carriedBy == unit then
                    gen.killUnit(possibleCargo)
                end
            end
            gen.killUnit(unit)
        end
    end
    function discreteEvents.onEnterTile(unit,previousTile)
        local unitType = unit.type
        if not (unit.owner.isHuman or rangeLimitsForLandAndSeaAI) then
            return
        end
        if unitType.domain == 1 or unitType.range == 0 then
            return
        end
        if restoreRangeFunction(unit) then
            unit.domainSpec = 0
        end
    end
    function discreteEvents.onTribeTurnEnd(turn,tribe)
        if not(tribe.isHuman or rangeLimitsForLandAndSeaAI) then
            return
        end
        for unit in civ.iterateUnits() do
            local unitType = unit.type
            if unit.owner == tribe and unitType.domain ~= 1 and unitType.range ~= 0
                and moveRemaining(unit) > 0 then
                unit.moveSpent = moveRemaining(unit)
                unit.domainSpec = unit.domainSpec + 1
                if restoreRangeFunction(unit) then
                    unit.domainSpec = 0
                end
                if unit.domainSpec >= unitType.range then
                    outOfRangeMessageFn(unit)
                    for possibleCargo in unit.location.units do
                        if possibleCargo.carriedBy == unit then
                            gen.killUnit(possibleCargo)
                        end
                    end
                    gen.killUnit(unit)
                end
            end
        end
    end
end

-- gen.spendMovementPoints(unit,points,multiplier=totpp.movementMultipliers.aggregate,maxSpent=255,minSpent=0) -> void
-- increases the expended movement points of the unit
-- by default, full unit movement points are used, but a different multiplier can be specified
-- e.g. 1 if you want to spend atomic movement points
-- If the unit has a range (either natural or through the land and sea extension) and
-- uses up all its movement for the current turn, its domainSpec is incremented by 1
-- and the unit is killed if it is out of range.
-- (exceptions: if the unit is the currently active unit and is a land or sea unit
-- with range, it won't increment domainSpec, since that is caught immediately
-- afterward with onFinalOrderGiven; a unit that has already spent its full movement
-- allowance before the modifier is applied also won't increment)
-- if points is negative, movement is restored to the unit
-- if points is a fraction, math.floor(points*multiplier) is used
-- final move spent is bound between maxSpent and minSpent, which are by default
-- 255 and 0 respectively
function gen.spendMovementPoints(unit,points,multiplier,maxSpent,minSpent)
    maxSpent = maxSpent or 255
    minSpent = minSpent or 0
    multiplier = multiplier or totpp.movementMultipliers.aggregate
	local actualMoveSpent = unit.moveSpent
	if actualMoveSpent < 0 then
		actualMoveSpent = actualMoveSpent + 256
	end
    local doNotIncrement = false
    local unitType = unit.type
    if actualMoveSpent >= unitType.move then
        doNotIncrement = true
    end
    actualMoveSpent = actualMoveSpent + math.floor(points*multiplier)
    actualMoveSpent = math.min(math.max(actualMoveSpent,minSpent),maxSpent)
    unit.moveSpent = actualMoveSpent
    if actualMoveSpent < unitType.move or unitType.range == 0 or 
        (unitType.domain ~= 1 and not(unit.owner.isHuman or rangeLimitsForLandAndSeaAI)) then
        return
    end
    if unitType.domain ~= 1 and unit == civ.getActiveUnit() then
        doNotIncrement = true
    end
    if not doNotIncrement then
        unit.domainSpec = unit.domainSpec + 1
    end
    if restoreRangeFunction(unit) then
        unit.domainSpec = 0
    end
    if unit.domainSpec >= unitType.range then
        outOfRangeMessageFn(unit)
        for possibleCargo in unit.location.units do
            if possibleCargo.carriedBy == unit then
                gen.killUnit(possibleCargo)
            end
        end
        gen.killUnit(unit)
    end
end

-- gen.getBearing(compassPoint,compassCentre) --> string | Inspired by Pablostuka
-- Returns one of "N","S","NW","NE","SW","SE" based on the locations
-- of the compassPoint and compassCentre
-- e.g. gen.getBearing(Madrid,Paris) --> SW
--      Madrid is South-West of Paris
--      We're finding the location of Madrid relative to Paris, hence
--      Paris is at the compass centre and we're looking for the
--      bearing of the compass point in the direction of Madrid
--      gen.getBearing(Paris,Madrid) --> NE
--      Paris is North-East of Madrid
-- compassPoint and compassCentre can be units, cities, or tiles

function gen.getBearing(compassPoint,compassCentre)
    if type(compassPoint) == "table" then
        compassPoint = toTile(compassPoint)
    elseif civ.isTile(compassPoint) then
        compassPoint = compassPoint
    elseif civ.isUnit(compassPoint) then
        compassPoint = compassPoint.location
    elseif civ.isCity(compassPoint) then
        compassPoint = compassPoint.location
    else
        error("gen.getBearing: first argument must be a tile (or coordinates of a tile) or a unit or a city.  Received: "..tostring(compassPoint))
    end
    if type(compassCentre) == "table" then
        compassCentre = toTile(compassCentre)
    elseif civ.isTile(compassCentre) then
        compassCentre = compassCentre
    elseif civ.isUnit(compassCentre) then
        compassCentre = compassCentre.location
    elseif civ.isCity(compassCentre) then
        compassCentre = compassCentre.location
    else
        error("gen.getBearing: second argument must be a tile (or coordinates of a tile) or a unit or a city.  Received: "..tostring(compassPoint))
    end
    
    local compass = ""
    
    if compassPoint.y > compassCentre.y then   
        compass = "S"   
    elseif compassPoint.y < compassCentre.y then   
        compass = "N"       
    end   
    
    if civ.game.rules.flatWorld then
        if compassPoint.x > compassCentre.x then   
            compass = compass.."E"   
        elseif compassPoint.x < compassCentre.x then   
            compass = compass.."W"       
        end   
    else
        local mapWidth,_,_ = civ.getAtlasDimensions()
        local xDiff = math.abs(compassPoint.x-compassCentre.x)
        if xDiff <= (mapWidth - xDiff) then
            -- Shortest distance does not cross date line
            if compassPoint.x > compassCentre.x then   
                compass = compass.."E"   
            elseif compassPoint.x < compassCentre.x then   
                compass = compass.."W"       
            end   
        else
            -- Shortest distance crosses dateline
            -- so the larger x is actually to the west
            if compassPoint.x > compassCentre.x then
                compass = compass.."W"
            elseif compassPoint.x < compassCentre.x then   
                compass = compass.."E"       
            end   
        end
    end
    return compass
end

-- gen.tableToString(table)
-- returns a string showing values in a table
function gen.tableToString(table)
    local str = civlua.serialize(table)
    str = string.sub(str,8,-1)
    str = string.gsub(str,"\n\r"," ")
    str = string.gsub(str,"\n"," ")
    return str
end


-- Data Validator
--  validDataInfo = {
--      ["nil"] = true or nil
--          if this key is true, the data can be nil
--      ["boolean"] = true, "true", "false", or nil
--          if this key is true, the data can be a boolean
--          if this key is "true", only true is allowed (false is not)
--          if this key is "false", only false is allowed (true is not)
--      ["function"] = true, string or nil
--          if this key is true or string, the data can be a function
--          the string describes the function e.g. function(unit) --> number
--          (the function is not tested)
--      ["number"] = {minVal=numberNil, maxVal = numberNil, integer=trueNil} or true
--          if this key is true, the data can be a number
--          the keys in the table specify minimum and maximum values, and whether
--          the number must be an integer
--          note: math.huge and -math.huge are considered both numbers and integer here
--      ["string"] = true or {[validString] = truthy}
--          if true, the data can be any string
--          if table, the data must be one of the keys in the table
--      ["table"] = string or true or {[1]=function(table)-->true or string,[2]=string}
--          if string, any table is accepted, and the string describes the kind of table needed
--          if true, any table is accepted, and the description is a table
--          if table, [1] is a function returns that true if the table is accepted,
--          and the problem with the table if it is not
--          [2] is the description of the table required
--      ["userdata"] = {[dataTypeName]=isDataTypeFn}
--          this table is a table of each of the allowable data types, with the
--          key being the name, and the function checking if it is that type
--          being the value
--  }
local vDIKeys = {["nil"]=true,["boolean"]=true,["function"]=true,["number"]=true,
    ["string"]=true,["table"]=true,["userdata"]=true,}
function gen.checkValidDataInfo(validDataInfo)
    for key,val in pairs(validDataInfo) do
        if not vDIKeys[key] then
            error("gen.checkValidDataInfo: submitted validDataInfo has a bad key: "..key)
        end
    end
end

--  gen.describeAllowableData(validDataInfo) --> string
--  takes a validDataInfo, and returns a string describing the validData
function gen.describeAllowableData(validDataInfo)
    local desc = ""
    if validDataInfo["nil"] then
        desc = desc.."nil, "
    end
    if validDataInfo["boolean"] == true then
        desc = desc.."boolean, "
    elseif validDataInfo["boolean"] == "true" then
        desc = desc.."true, "
    elseif validDataInfo["boolean"] == "false" then
        desc = desc.."false, "
    end
    if type(validDataInfo["function"]) == "string" then
        desc = desc..validDataInfo["function"]..", "
    elseif validDataInfo["function"] == true then
        desc = desc.."function, "
    end
    if validDataInfo["number"] == true then
        desc = desc.."number, "
    elseif validDataInfo["number"] then
        local number = "number"
        if validDataInfo["number"].integer then
            number = "integer"
        end
        if validDataInfo["number"].minVal and validDataInfo["number"].maxVal then
            desc = desc..number.." between "..tostring(validDataInfo["number"].minValue)
            .." and "..tostring(validDataInfo["number"].maxValue)..", "
        elseif validDataInfo["number"].minVal then
            desc = desc..number.." at least "..tostring(validDataInfo["number"].minValue)..", "
        elseif validDataInfo["number"].maxVal then
            desc = desc..number.." at most "..tostring(validDataInfo["number"].maxValue)..", "
        else
            desc = desc..number..", "
        end
    end
    if validDataInfo["string"] == true then
        desc = desc.."string, "
    elseif type(validDataInfo["string"]) == "table" then
        for validString,_ in pairs(validDataInfo["string"]) do
            desc = desc..'"'..validString..'", '
        end
    end
    if validDataInfo["table"] == true then
        desc = desc.."table, "
    elseif type(validDataInfo["table"]) == "string" then
        desc = desc..validDataInfo["table"]..", "
    elseif type(validDataInfo["table"]) == "table" then
        desc = desc..validDataInfo["table"][2]..", "
    end
    if type(validDataInfo["userdata"]) == "table" then
        for dataTypeName,_ in pairs(validDataInfo["userdata"]) do
            desc = desc..dataTypeName..", "
        end
    end
    return desc
end

-- gen.validateFunctionArgument(data,moduleName,functionName,argumentNumber, argumentName,validDataInfo,extraInfo=nil) --> void or error
--  This validates a function argument, and provides an error if that is wrong
--      data is the actual argument
--      moduleName is the name of the module the function is in
--      functionName is the name of the function making the error
--      argumentNumber is the place of the argument in the function call
--      validDataInfo is the table determining what is a valid argument
--      extraInfo is any extra information that might be useful for debugging
function gen.validateFunctionArgument(data,moduleName,functionName,argumentNumber,argumentName,validDataInfo,extraInfo)
    gen.checkValidDataInfo(validDataInfo)
    local dataType = type(data)
    local vDI = validDataInfo[dataType]
    local function constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName,
                extraInfo, tableReturnInfo)
        local tostringResult = tostring(data)
        if type(data) == "table" then
            tostringResult = gen.tableToString(data)
        elseif type(data) == "string" then
            tostringResult = 'string<"'..data..'">'
        end
        local errorMessage = "module: "..moduleName.."; function: "..functionName.."; argument number: "
            ..tostring(argumentNumber).."; argument name: "..argumentName.."; "
        if extraInfo then
            errorMessage = errorMessage.."; extra information: "..extraInfo.."; "
        end
        errorMessage = errorMessage.."Expected :"..gen.describeAllowableData(validDataInfo)
            .."; Received: "..tostringResult
        if tableReturnInfo then
            errorMessage = errorMessage.."; Reported table problem: "..tableReturnInfo
        end
        return errorMessage
    end
    if not vDI then
        error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    end
    if dataType == "nil" then
        -- if nil isn't allowed, it is caught in not vDI
        return
    elseif dataType == "boolean" then
        if (vDI == true or tostring(data) == vDI) then
            return
        else
            error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo))
        end
    elseif dataType == "function" then
        -- The function is not checked beyond the fact that it is a function
        -- If the function isn't allowed, it is caught in not vDI
        return
    elseif dataType == "number" then
        if vDI == true then
            return
        end
        local minVal = vDI.minVal or -math.huge
        local maxVal = vDI.maxVal or math.huge
        local notInteger = not vDI.integer
        if data >= minVal and data <= maxVal and (notInteger or data == math.floor(data)) then
            return
        end
        error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    elseif dataType == "string" then
        if vDI == true or vDI[data] then
            return
        end
        error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    elseif dataType == "table" then
        if vDI == true or type(vDI) == "string" then
            -- don't check anything specific about the table
            return 
        end
        local errorString = vDI[1](data)
        if type(errorString) == "string" then
            error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo,errorString))
        end
    elseif dataType == "userdata" then
        for dataTypeName,isDataTypeFn in pairs(vDI) do
            if isDataTypeFn(data) then
                return
            end
        end
        error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    else
        error(constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    end
end

-- gen.versionFunctions(moduleTable,versionNumber,fileMod,moduleFileName) -->void
-- provides module with 
--      module:minVersion(vNumber)
--          causes an error if the module's versionNumber is below vNumber
--      module:recommendedVersion(vNumber)
--          prints a warning to the console if the module's versionNumber is below vNumber
--  moduleTable: the table that has the module functions 
--  versionNumber: the module's current version number
--  fileMod: a boolean telling if the file has been modified by the scenario designer
--  moduleFileName: the module's file name

function gen.versionFunctions(moduleTable,vNum,fileMod,moduleFileName)
    local minVersion = function(self,minVersion)
        if vNum < minVersion then
            local message = "The "..moduleFileName.." file is out of date.  It is version "..tostring(vNum)..
            ", but one of your other files needs version "..tostring(minVersion).." or later.  "
            .."You should download the most recent version of the Lua Scenario Template, and replace "
            ..moduleFileName.." with the updated version."
            if fileMod then
                message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
                .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."

            end
            error(message)
        end
        return self
    end
    local recommendedVersion = function(self,recVersion)
        if vNum < recVersion then
            local message = "WARNING: The "..moduleFileName.." is out of date.  It is version "..tostring(vNum)..
            ", but one of your files recommends version "..tostring(recVersion).." or later.  "
            if fileMod then
                message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
                .."  Replacing this file will remove those changes.  This is not a mandatory update, so you (probably) don't have to make any changes.  However, you may still wish to bring code in from the new file for extra features."
            else
                message = message.." The fileModified variable at the top of the file does not indicate that you have made any changes to this file.  If this is actually the case, you can replace it with the most recent version from the Lua Scenario Template without any problem."
            end
            print(message.."\n")
        end
        return self
    end
    if moduleTable.minVersion or moduleTable.recommendedVersion or moduleTable.getVersion then
        error("gen.versionFunctions: this module has already assigned the minVersion, recommendedVersion or version keys.")
    end
    moduleTable.minVersion = minVersion
    moduleTable.recommendedVersion = recommendedVersion
    moduleTable.getVersion = vNum
end

gen.versionFunctions(gen,versionNumber,fileModified,"LuaCore".."\\".."generalLibrary.lua")

-- gen.registerEventsLuaVersion(versionNumber,fileMod,regressionNumber)
--  registers version information for the events.lua file
--  versionNumber is the events.lua verison number
--  fileMod is a boolean that should be true if events.lua has been modified by the scenario designer
--  regressionNumber is incremented if events.lua has functionality removed
local eventsVersion = {}
function gen.registerEventsLuaVersion(vNum,fileMod,regressionNumber)
    eventsVersion.versionNumber = vNum
    eventsVersion.fileModified = fileMod
    eventsVersion.regressionNumber = regressionNumber
end

function gen.minEventsLuaVersion(minVersion,regNum,fileName)
    if gen.isEmpty(eventsVersion) then
        print("WARNING: "..fileName.." expects to use version "..tostring(minVersion).." of the Lua Scenario Template, but no version of events.lua has been registered.  If you are using the Lua Scenario Template, this means your events.lua file is out of date.  If you are not, you can suppress this warning by adding the following line the first time in your code that you require the general library:\ngen.registerEventsLuaVersion("..minVersion..",false,"..regNum)
        return
    end
    if minVersion > eventsVersion.versionNumber then
        local message = "The events.lua file is out of date.  It is version "..tostring(eventsVersion.versionNumber)
        ..", but one of your other files needs version "..tostring(minVersion).." or later.  "
        .."You should download the most recent version of the Lua Scenario Template, and replace "
        .."events.lua with the updated version."
        if eventsVersion.fileModified then
            message = message.."\nIMPORTANT WARNING: it appears you've changed events.lua for your scenario."
            .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."
        end
        if regNum > eventsVersion.regressionNumber then
            message = message.."\nIMPORTANT WARNING: it appears that events.lua has had some sort of functionality removed or changed.  Seek advice before updating."
        end
        error(message)
    end
end

function gen.validateTableValue(tableDescription,key,value,validDataInfo,extraInfo)
    gen.checkValidDataInfo(validDataInfo)
    local data = value
    local dataType = type(data)
    local vDI = validDataInfo[dataType]
    local function constructErrorMessage(data,tableDescription,key,extraInfo, tableReturnInfo)
        local tostringResult = tostring(data)
        if type(data) == "table" then
            tostringResult = gen.tableToString(data)
        elseif type(data) == "string" then
            tostringResult = 'string<"'..data..'">'
        end
        local errorMessage = tableDescription..": key: "..tostring(key).."; "
        errorMessage = errorMessage.."Expected :"..gen.describeAllowableData(validDataInfo)
            .."; Received: "..tostringResult
        if tableReturnInfo then
            errorMessage = errorMessage.."; Reported table problem: "..tableReturnInfo
        end
        if extraInfo then
            errorMessage = errorMessage.."; extra information: "..extraInfo
        end
        return errorMessage
    end
    if not vDI then
        error(constructErrorMessage(data,tableDescription,key, extraInfo))
    end
    if dataType == "nil" then
        -- if nil isn't allowed, it is caught in not vDI
        return
    elseif dataType == "boolean" then
        if (vDI == true or tostring(data) == vDI) then
            return
        else
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
        end
    elseif dataType == "function" then
        -- The function is not checked beyond the fact that it is a function
        -- If the function isn't allowed, it is caught in not vDI
        return
    elseif dataType == "number" then
        if vDI == true then
            return
        end
        local minVal = vDI.minVal or -math.huge
        local maxVal = vDI.maxVal or math.huge
        local notInteger = not vDI.integer
        if data >= minVal and data <= maxVal and (notInteger or data == math.floor(data)) then
            return
        end
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
    elseif dataType == "string" then
        if vDI == true or vDI[data] then
            return
        end
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
    elseif dataType == "table" then
        if vDI == true or type(vDI) == "string" then
            -- don't check anything specific about the table
            return 
        end
        local errorString = vDI[1](data)
        if type(errorString) == "string" then
            error(constructErrorMessage(data,tableDescription,key, extraInfo,errorString))
        end
    elseif dataType == "userdata" then
        for dataTypeName,isDataTypeFn in pairs(vDI) do
            if isDataTypeFn(data) then
                return
            end
        end
        error(constructErrorMessage(data,tableDescription,key, extraInfo))
    else
        error(constructErrorMessage(data,tableDescription,key, extraInfo))
    end
end

-- gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable) -->
--      newItemFunction(table) --> dataType,
--          creates (and validates) a new instance of the data type
--      isDataTypeFunction(value) --> boolean,
--          creates a function that checks if a value is the dataType
--      dataTypeMetatable
--          the metatable for the data type
--
--  dataName = string
--      the name of the data type
--  specificKeyTable={[key] = validDataInfo}
--      gives allowable keys, and the valid kinds of data they can be
--
--  generalKeyTable={[function(possibleKey)-->bool]=validDataInfo}
--      if a key isn't in the specificKeyTable, the key is checked against
--      each key function in this table, and, if there is a match, uses
--      that validDataInfo
--      if no match here or in specificKeyTable, the key is invalid, generating an error
--  defaultValueTable = {[key]=value}
--      when a new dataType is generated, if the key is not specified, use the value in this table
--  fixedKeyTable = {[key] = true}
--      if true, the key can't be changed after the data is created

function gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable)
    specificKeyTable = gen.copyTable(specificKeyTable)
    for key,vDI in pairs(specificKeyTable) do
        gen.checkValidDataInfo(vDI)
    end
    generalKeyTable = gen.copyTable(generalKeyTable)
    for key,vDI in pairs(generalKeyTable) do
        gen.checkValidDataInfo(vDI)
        if not vDI["nil"] then
            error("gen.createDataType: (creating "..dataName..") keys defined by the generalKeyTable must be allowed to have nil values.")
        end
    end
    defaultValueTable = gen.copyTable(defaultValueTable)
    fixedKeyTable = gen.copyTable(fixedKeyTable)
    local function validDataInfoForKey(key)
        if specificKeyTable[key] then
            return specificKeyTable[key]
        end
        for keyCheckFn,vDI in pairs(generalKeyTable) do
            if keyCheckFn(key) then
                return vDI
            end
        end
        return false
    end
    for key,value in pairs(defaultValueTable) do
        local vDI = validDataInfoForKey(key)
        if not vDI then
            error("gen.createDataType: (creating "..dataName..") the key "..tostring(key).." in the defaultValueTable is not a valid key for this data type.")
        end
        gen.validateTableValue("gen.createDataType (creating "..dataName..")",key,value,vDI)
    end
    for key,_ in pairs(fixedKeyTable) do
        local vDI = validDataInfoForKey(key)
        if not vDI then
            error("gen.createDataType: (creating "..dataName.." the key "..tostring(key).." in the fixedKeyTable is not a valid key for this data type.")
        end
    end
    local uniqueTableForDataType = {}
    local mt = {}
    mt.trueTableKey = uniqueTableForDataType
    mt.__index = function(t,key)
        if validDataInfoForKey(key) then
            return t[uniqueTableForDataType][key]
        else
            error(dataName..".index: the key "..tostring(key).." is not a valid key for "..dataName)
        end
    end
    mt.__newindex = function(t,key,value)
        local vDI = validDataInfoForKey(key)
        if not vDI then
            error(dataName..".index: the key "..tostring(key).." is not a valid key for "..dataName)
        end
        if fixedKeyTable[key] then
            error(dataName..".newIndex: the key "..tostring(key).." can't be changed after the "..dataName.." is created.")
        end
        gen.validateTableValue(dataName,key,value,vDI)
        t[uniqueTableForDataType][key] = value
    end
    mt.__pairs = function(t)
        return pairs(t[uniqueTableForDataType])
    end
    mt.__ipairs = function(t)
        return ipairs(t[uniqueTableForDataType])
    end
    local function newItemFunction(table)
        local newData = {}
        newData[uniqueTableForDataType] = {}
        for key,value in pairs(defaultValueTable) do
            newData[uniqueTableForDataType][key] = value
        end
        for key,value in pairs(table) do
            local vDI = validDataInfoForKey(key)
            if not vDI then
                error("new "..dataName..": the key "..tostring(key).." is invalid.")
            end
            gen.validateTableValue("new "..dataName,key,value,vDI)
            newData[uniqueTableForDataType][key] = value
        end
        for key,vDI in pairs(specificKeyTable) do
            local value = newData[uniqueTableForDataType][key]
            gen.validateTableValue("new "..dataName,key,value,vDI,"(note: the most likely cause of this error is that this key can't be nil, a default value for the key was not provided when designing the constructor, and the key's value was not provided.")
        end
        setmetatable(newData,mt)
        return newData
    end

    local function isDataTypeFunction(value)
        return getmetatable(value) == mt
    end
    return newItemFunction, isDataTypeFunction, mt
end

-- gen.valueSatisfiesValidDataInfo(value,validDataInfo)--> boolean
--  returns true if value satisfies VDI, false otherwise
function gen.valueSatisfiesValidDataInfo(value,validDataInfo)
    local data = value
    local dataType = type(data)
    local vDI = validDataInfo[dataType]
    if not vDI then
        return false
    end
    if dataType == "nil" then
        -- if nil isn't allowed, it is caught in not vDI
        return true
    elseif dataType == "boolean" then
        if (vDI == true or tostring(data) == vDI) then
            return true
        else
            return false
        end
    elseif dataType == "function" then
        -- The function is not checked beyond the fact that it is a function
        -- If the function isn't allowed, it is caught in not vDI
        return true
    elseif dataType == "number" then
        if vDI == true then
            return true
        end
        local minVal = vDI.minVal or -math.huge
        local maxVal = vDI.maxVal or math.huge
        local notInteger = not vDI.integer
        if data >= minVal and data <= maxVal and (notInteger or data == math.floor(data)) then
            return true
        end
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
    elseif dataType == "string" then
        if vDI == true or vDI[data] then
            return true
        end
        return false
    elseif dataType == "table" then
        if vDI == true or type(vDI) == "string" then
            -- don't check anything specific about the table
            return true
        end
        local errorString = vDI[1](data)
        if type(errorString) == "string" then
            return false
        end
    elseif dataType == "userdata" then
        for dataTypeName,isDataTypeFn in pairs(vDI) do
            if isDataTypeFn(data) then
                return true
            end
        end
        return false
    else
        return false
    end
end



-- gen.tableOfVDI(validDataInfo) --> validDataInfo
--  takes a validDataInfo, and returns a validDataInfo where
--  the valid data is a table where all values are of the
--  submitted validDataInfo
function gen.tableOfVDI(vDI)
    gen.checkValidDataInfo(validDataInfo)
    local vDI = gen.copyTable(vDI)
    local function analysisFn(table)
        for key,value in pairs(table) do
            if not gen.valueSatisfiesValidDataInfo(value,vDI) then
                return "The key "..tostring(key).." has an invalid value of "..tostring(value).."."
            end
        end
        return true
    end
    return {["table"]={analysisFn,"A table with these values "..gen.describeAllowableData(vDI)}}
end

-- gen.vDIOrTableOfVDI(validDataInfo) --> validDataInfo
--  takes a validDataInfo, and returns a validDataInfo
--  that also allows a table with the same validDataInfo fore each value
--  validDataInfo can't include any tables
--
function gen.vDIOrTableOfVDI(vDI)
    gen.checkValidDataInfo(vDI)
    local vDI = gen.copyTable(vDI)
    if vDI["table"] then
        error("gen.vDIOrTableOfVDI: validDataInfo has a table as a kind of valid data.  This is invalid for this function.  You can use gen.tableOfVDI, or write a custom vDI.")
    end
    local function analysisFn(table)
        for key,value in pairs(table) do
            if not gen.valueSatisfiesValidDataInfo(value,vDI) then
                return "The key "..tostring(key).." has an invalid value of "..tostring(value).."."
            end
        end
        return true
    end
    local vDICopy = gen.copyTable(vDI)
    vDICopy["table"]={analysisFn,"A table with these values "..gen.describeAllowableData(vDI)}
    return vDICopy
end

    

            






if rawget(_G,"console") then
    _G["console"].gen = gen
end

return gen
