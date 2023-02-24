
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local gen = require("generalLibrary"):minVersion(1)
local func = require("functions")
--usage example
--[=[

local function doOnCityProduction(city,prod)
    if civ.isUnit(prod) then
        munitions.onProdPayloadRestrictionCheck(prod,munitionSpecificationTable)
    end
end
local function doOnActivation(unit,source)
    munitions.payloadRestrictionCheck(unit,munitionSpecificationTable)
end
local function doOnKeyPress(keyID)
  if keyID == 75 --[[k]] and civ.getActiveUnit() then
       munitions.doMunition(civ.getActiveUnit(), munitionSpecificationTable,doOnActivation)
       return
  end
   if keyID == 72 --[[h]] and civ.getActiveUnit() then
       civ.sleep(100)
       munitions.payloadRestrictionCheck(civ.getActiveUnit(),munitionSpecificationTable)
   end
end
--]=]
-- Note the return so other stuff isn't done with the new
-- active unit
-- keyID == 72 not needed unless payload restriction is used 


-- we use the state table to keep track of the units (or, rather, the unit id numbers) that 
-- generated munitions
local munitionState = "munitionStateNotLinked"

-- links the state table with this module
local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        munitionState = tableInStateTable
        -- this table is indexed by the unit ID numbers of munitions that were generated,
        munitionState.munitionIDGeneratorID = munitionState.munitionIDGeneratorID or {}
        -- this table keeps track of the unit type that generated the munition,
        -- as a backup check
        munitionState.munitionIDGeneratorTypeID = munitionState.munitionIDGeneratorTypeID or {}
    else
        error("linkState: linkState takes a table as an argument.")
    end
end


local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "munitionsState"
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

local function unitDeathMaintenance(dyingUnit)
    local dyingUnitID = dyingUnit.id
    munitionState.munitionIDGeneratorID[dyingUnit.id] = nil
    munitionState.munitionIDGeneratorTypeID[dyingUnit.id] = nil
    for unitID,generatorID in pairs(munitionState.munitionIDGeneratorID) do
        if generatorID == dyingUnitID then
            munitionState.munitionIDGeneratorID[unitID] = nil
        end
    end
end

-- returns the unit that generated the munition, if it exists
-- returns nil if there is no unit (or the unit can't be confirmed)
local function getShooter(unit)
    local shooterID = munitionState.munitionIDGeneratorID[unit.id]
    local shooterTypeID = munitionState.munitionIDGeneratorTypeID[unit.id]
    if shooterID and civ.getUnit(shooterID) and shooterTypeID and
        (civ.getUnit(shooterID).type == civ.getUnitType(shooterTypeID)) then
        return civ.getUnit(shooterID)
    else
        return nil
    end
end

local function linkMunitionAndShooter(munition,shooter)
    munitionState.munitionIDGeneratorID[munition.id]=shooter.id
    munitionState.munitionIDGeneratorTypeID[munition.id]=shooter.type.id
end







local leaveAirWithOneMovementPoint = true 
-- this is the workaround where air units
-- are left with 1 movement point, so they expend their range unit of range
-- (which wouldn't happen if their moveSpent was changed by event so they have
-- no more movement for the turn)
-- This is now corrected, but the option is enabled by default for backward compatibility

-- disables the above workaround
local function airCanHaveZeroMovement()
    leaveAirWithOneMovementPoint = false
end



--specificationTable[unitType.id]={
--
-- goldCost = integer or nil
--      amount of gold it costs to generate a unit
--      absent means 0
-- minTreasury = integer or nil
--      minimum amount of gold in treasury to generate a unit
--      absent means refer to gold cost
--      (tribe will generate and be set to 0 if treasury is less than goldCost)
-- treasuryFailMessage = string or nil
--      A message to be displayed if the unit fails to spawn a unit due to an 
--      insufficient treasury
--      nil means no message

-- There are three ways to specify move costs, in full movement points,
-- in "atomic" movement points, and as a fraction of total movement points for the
-- unit type.  Use only one kind per unit type

-- moveCost = integer or nil
--      movement points to be expended generating the unit
--      "full" movement points
--      absent means 0
-- minMove = integer or nil
--      minimum remaining movement points to be allowed to generate a unit
--      "full" movement points
--      absent means any movement points for land/sea, 2 "atomic" for air units
-- postGenMinMove = integer or nil
--      a unit will be left with at least this many movement points after
--      the generation function
--      absent means 0 for land/sea, 1 "atomic" for air units
-- moveCostAtomic = integer or nil
--      movement points to be expended generating the unit
--      refers to the unit.moveSpent movement points
--      absent means 0
-- minMoveAtomic = integer or nil
--      minumum remaining movement points to be allowed to generate a unit
--      referes to the unit.moveSpent movement points
--      absent means any movement points for land, 2 "atomic" for air units
-- postGenMinMoveAtomic = integer or nil
--      a unit will be left with at least this many movement points after
--      the generation function
--      absent means 0 for land/sea, 1 "atomic" for air units
-- moveCostFraction = number in [0,1] or nil
--      fraction of unit's total movement points expended generating the unit
--      round up to nearest "atomic" movement point
--      absent means 0
-- minMoveFraction = number in [0,1] or nil
--      fraction of unit's total movement points that must remain to be allowed
--      to generate a unit
--      absent means any movement points for land, 2 "atomic" for air units
--      round up to nearest "atomic" movement point
-- postGenMinMoveFraction = number in [0,1] or nil
--      a unit will be left with at least this many movement points after
--      the generation function, round up to nearest "atomic" move point
--      absent means 0 for land/sea, 1 "atomic" for air units
-- roundFractionFull = bool or nil
--      fractional movement cost and minimum are rounded up to full movement point
--      instead of atomic movement point
--      nil/false means don't
-- roundFractionFullDown = bool or nil
--      fractional cost and minimum are rounded down to full move point
--      nil/false means don't
-- minMoveFailMessage = string or nil
--      a message to be displayed if a unit is not generated due to insufficient
--      movement points.
--      nil means no message

-- allowedTerrainTypes = table of integers or nil
--      a unit may only be generated if the tile it is standing on
--      corresponds to one of numbers in the table
--      nil means the unit can be generated on any terrain type
-- terrainTypeFailMessage = string or nil
--      message to be displayed if a unit is not generated due to standing
--      on the incorrect terrain

-- requiredTech = tech object or nil
--      the generating civ must have this technology in order to generate
--      the unit
--      nil means no requirement
-- techFailMessage = string or nil
--      message to be displayed if a unit is not generated due to not having
--      the correct technology

-- payload = boolean or nil
--      if true, unit must have a home city in order to generate munitions
--      and generating munitions sets the home city to NONE
-- payloadFailMessage = string or nil
--      message to be displayed if a unit is not generated due to the 
--      payload restriction
-- payloadRestrictionCheck = nil or function(unit)-->boolean
--      If function returns false, the home city is not valid for giving the
--      unit a payload.  This will be checked when the unit is activated, when
--      the unit is given a new home city with the 'h' key and when the unit
--      tries to generate a munition
--      nil means no restriction
-- payloadRestrictionMessage = nil or string
--      message to show if a unit fails the payloadRestrictionCheck
-- reArmingTileFunction = nil or function(tile)--> city or false
--      if function returns false for the tile the unit is on, the unit will not re-arm
--      if the function returns a city, the unit will rearm using that city as the home city
--      nil means it will attempt to re-arm in any city, and use that city as the home
--      as long as the city has extra support available
--      no effect if not a payload unit
-- noPayloadActivationMessage = nil or function(unit)-->string or nil
--      If this unit is activated without a home city, determine if a
--      message should be shown to warn the player.
--      No message will be shown if a unit is not a payload unit
--      Default is message shown when activated in a city
--      If you don't want a message under any circumstances, provide a function 
--      function(unit) return nil end
--      
--

-- canGenerateFunction = nil or function(unit)-->boolean 
--      This function applied to the generating unit must return true in order
--      for a unit to be spawned.  All other conditions still apply.
--      any failure message should be part of canGenerateFunction
--      absent means no extra conditions

-- generateUnitFunction = nil or function(unit)-->table of unit
--      This function creates the unit or units to be generated
--      and returns a table containing those units
--      Ignore any specifications prefixed with * if this is used
--      nil means use other specifications

--*generatedUnitType = unitType
--      The type of unit to be generated
--      can't be nil unless generateUnitFunction is used instead

--*giveVeteran = bool or nil
--      generated unit(s) given veteran status if true
--      nil or false means don't give vet status
--      if true, overrides copyVeteranStatus

--*copyVeteranStatus = bool or nil
--      generated unit(s) copy veteran status of generating unit if true
--      nil or false means don't give vet status

--*setHomeCityFunction = nil or function(generatingUnit)-->cityObject
--      determines what home city the spawned unit should have
--      nil means a home city of NONE

--*numberToGenerate = nil or number or thresholdTable or function(generatingUnit)-->number
--      if nil, generate 1 unit in all circumstances
--      if integer, generate that many units (generate 0 if number less than 0)
--      if number not integer, generate floor(number), and 1 more with
--      probability number-floor(number)
--      if thresholdTable, use remaining hp as the key, to get the number to create
--      if function, get the number as the returned value of the function 

-- activate = bool or nil
--      Activates one of the generated units if true.  If generateUnitFunction was used,
--      the unit at index 1 is activated, if index 1 has a value.  (if not, any unit in
--      the list might be chosen)
--      
--  successMessage = string or nil
--  message to show if a unit (or units) is created
--
--spawnUnit(generatingUnit,specificationTable,unitActivationCode)-->table of unitCreated

local function spawnUnit(generatingUnit,specificationTable,onUnitActivateFn)
    if not specificationTable[generatingUnit.type.id] then
        return {}
    end
    local specification = specificationTable[generatingUnit.type.id]
    --
    -- Check if Unit can be generated
    --
    if specification.minTreasury and generatingUnit.owner.money < specification.minTreasury then
        if specification.treasuryFailMessage then
            civ.ui.text(func.splitlines(specification.treasuryFailMessage))
        end
        return {}
    end
    if specification.goldCost and not specification.minTreasury and generatingUnit.owner.money < specification.goldCost then
        if specification.treasuryFailMessage then
            civ.ui.text(func.splitlines(specification.treasuryFailMessage))
        end
        return {}
    end
    local minAtomicMoves = 0
    if generatingUnit.type.domain == 1 then
        minAtomicMoves = 2
    end
    if specification.minMove then
        minAtomicMoves = specification.minMove*totpp.movementMultipliers.aggregate
    elseif specification.minMoveAtomic then
        minAtomicMoves = specification.minMoveAtomic
    elseif specification.minMoveFraction then
        local fraction = specification.minMoveFraction
        if specification.roundFractionFullDown then
            minAtomicMoves=math.floor(fraction*(gen.wonderModifiedMoves(generatingUnit))/totpp.movementMultipliers.aggregate)*totpp.movementMultipliers.aggregate
        elseif specification.roundFractionFull then
            minAtomicMoves=math.ceil(fraction*(gen.wonderModifiedMoves(generatingUnit))/totpp.movementMultipliers.aggregate)*totpp.movementMultipliers.aggregate
        else
            minAtomicMoves=math.ceil(fraction*gen.wonderModifiedMoves(generatingUnit))
        end
    end
    if gen.moveRemaining(generatingUnit) < minAtomicMoves then
        if specification.minMoveFailMessage then
            civ.ui.text(func.splitlines(specification.minMoveFailMessage))
        end
        return {}
    end
    if specification.allowedTerrainTypes then
        local terrainType = generatingUnit.location.terrainType % 16
        local onAllowedTerrainType = false
        for __, terrainIndex in pairs(specification.allowedTerrainTypes) do
            if terrainIndex == terrainType then
                onAllowedTerrainType = true
                break
            end
        end
        if not onAllowedTerrainType then
            if specification.terrainTypeFailMessage then
                civ.ui.text(func.splitlines(specification.terrainTypeFailMessage))
            end
            return {}
        end
    end
    if specification.requiredTech then
        if not generatingUnit.owner:hasTech(specification.requiredTech) then
            if specification.techFailMessage then
                civ.ui.text(func.splitlines(specification.techFailMessage))
            end
            return {}
        end
    end
    if specification.payload then
        if generatingUnit.homeCity == nil then
            if specification.payloadFailMessage then
                civ.ui.text(func.splitlines(specification.payloadFailMessage))
            end
            return {}
        end
        if specification.payloadRestrictionCheck then
            if specification.payloadRestrictionCheck(generatingUnit) == false then
                if specification.payloadRestrictionMessage then
                    civ.ui.text(func.splitlines(specification.payloadRestrictionMessage))
                end
                generatingUnit.homeCity = nil
                return {}
            end
        end
    end
    if specification.canGenerateFunction then
        if specification.canGenerateFunction(generatingUnit) == false then
            return {}
        end
    end
    --
    -- Generate Units Section
    --
    local unitTable = {}
    if specification.generateUnitFunction then
        unitTable = specification.generateUnitFunction(generatingUnit)
        if unitTable[1] == nil then
            for index,unit in pairs(unitTable) do
                unitTable[1] = unit
                unitTable[index] = nil
            end
        end
    else
        local numToGenerate = nil
        local specNum = specification.numberToGenerate
        if specNum == nil then
            specNum = 1
        end
        if type(specNum) == "function" then
            specNum = specNum(generatingUnit)
        end
        if type(specNum) == "table" then
            specNum = specNum[generatingUnit.hitpoints]
        end
        local extra = 0
        if (specNum - math.floor(specNum)) > math.random() then
            extra = 1
        end
        numToGenerate = math.floor(specNum)+extra
        for i=1,numToGenerate do
            local newUnit = civ.createUnit(specification.generatedUnitType,
                generatingUnit.owner,generatingUnit.location)
            newUnit.veteran = specification.giveVeteran or false
            newUnit.veteran = newUnit.veteran or (specification.copyVeteranStatus and generatingUnit.veteran)
            newUnit.homeCity = nil
            if specification.setHomeCityFunction then
                newUnit.homeCity = specification.setHomeCityFunction(generatingUnit)
            end
            unitTable[i] = newUnit
        end
    end
    --
    -- Pay For Units Generated Section
    --
    if specification.goldCost then
        generatingUnit.owner.money =math.max(0, generatingUnit.owner.money - specification.goldCost)
    end
    local atomicMoveCost = 0
    if specification.moveCost then
        atomicMoveCost = specification.moveCost*totpp.movementMultipliers.aggregate
    elseif specification.moveCostAtomic then
        atomicMoveCost = specification.moveCostAtomic
    elseif specification.moveCostFraction then
        local fraction = specification.moveCostFraction
        if specification.roundFractionFullDown then
            atomicMoveCost=math.floor(fraction*(gen.wonderModifiedMoves(generatingUnit))/totpp.movementMultipliers.aggregate)*totpp.movementMultipliers.aggregate
        elseif specification.roundFractionFull then
            atomicMoveCost=math.ceil(fraction*(gen.wonderModifiedMoves(generatingUnit))/totpp.movementMultipliers.aggregate)*totpp.movementMultipliers.aggregate
        else
            atomicMoveCost=math.ceil(fraction*gen.wonderModifiedMoves(generatingUnit))
        end
    end
    local afterGenMinMoveAtomic = 0
    if generatingUnit.type.domain == 1 and leaveAirWithOneMovementPoint then
        afterGenMinMoveAtomic = 1
    end
    if specification.postGenMinMove then
        afterGenMinMoveAtomic=specification.postGenMinMove*totpp.movementMultipliers.aggregate
    elseif specification.postGenMinMoveAtomic then
        afterGenMinMoveAtomic = specification.postGenMinMoveAtomic
    elseif specification.postGenMinMoveFraction then
        local fraction = specification.postGenMinMoveFraction
        if specification.roundFractionFullDown then
            afterGenMinMoveAtomic=math.floor(fraction*(gen.wonderModifiedMoves(generatingUnit))/totpp.movementMultipliers.aggregate)*totpp.movementMultipliers.aggregate
        elseif specification.roundFractionFull then
            afterGenMinMoveAtomic=math.ceil(fraction*(gen.wonderModifiedMoves(generatingUnit))/totpp.movementMultipliers.aggregate)*totpp.movementMultipliers.aggregate
        else
            afterGenMinMoveAtomic=math.ceil(fraction*gen.wonderModifiedMoves(generatingUnit))
        end
    end
    local maxMoveSpentAtomic = gen.maxMoves(generatingUnit)-afterGenMinMoveAtomic
    --[[
	local actualMoveSpent = generatingUnit.moveSpent
	if actualMoveSpent < 0 then
		actualMoveSpent = actualMoveSpent + 256
	end
    generatingUnit.moveSpent = math.min(maxMoveSpentAtomic,actualMoveSpent+atomicMoveCost)
    --]]
    gen.spendMovementPoints(generatingUnit,atomicMoveCost,1,maxMoveSpentAtomic,0)
    if specification.payload then
        generatingUnit.homeCity = nil
    end
    if unitTable[1] and specification.activate then
        unitTable[1]:activate()
        onUnitActivateFn(unitTable[1],true)
    end
    if specification.successMessage then
        civ.ui.text(func.splitlines(specification.successMessage))
    end
    for __,newMunitionUnit in pairs(unitTable) do
        linkMunitionAndShooter(newMunitionUnit,generatingUnit)
    end
    return unitTable
end

local function payloadRestrictionCheck(carryingUnit,specificationTable)
    if carryingUnit.homeCity and specificationTable[carryingUnit.type.id] and specificationTable[carryingUnit.type.id].payloadRestrictionCheck and not specificationTable[carryingUnit.type.id].payloadRestrictionCheck(carryingUnit) then
        carryingUnit.homeCity = nil
        if specificationTable[carryingUnit.type.id].payloadRestrictionMessage then
            civ.ui.text(func.splitlines(specificationTable[carryingUnit.type.id].payloadRestrictionMessage))
        end
    end
end

local function onProdPayloadRestrictionCheck(carryingUnit,specificationTable)
    if carryingUnit.homeCity and specificationTable[carryingUnit.type.id] and specificationTable[carryingUnit.type.id].payloadRestrictionCheck and not specificationTable[carryingUnit.type.id].payloadRestrictionCheck(carryingUnit) then
        carryingUnit.homeCity = nil
    end
end

local function defaultReArmingTileFunction(tile)
    if tile.city and gen.cityCanSupportAnotherUnit(tile.city) then
        return tile.city
    else
        return false
    end
end
local function automaticReArming(unit,primarySpecificationTable,secondarySpecificationTable)
    if unit.homeCity then
        return
    end
    primarySpecificationTable = primarySpecificationTable or {}
    secondarySpecificationTable = secondarySpecificationTable or {}
    if primarySpecificationTable[unit.type.id] and primarySpecificationTable[unit.type.id].payload then
        local reArmFn = primarySpecificationTable[unit.type.id].reArmingTileFunction or defaultReArmingTileFunction
        local reArmResult = reArmFn(unit.location)
        if civ.isCity(reArmResult) then
            unit.homeCity = reArmResult
            if primarySpecificationTable[unit.type.id].payloadRestrictionCheck then
                if not (primarySpecificationTable[unit.type.id].payloadRestrictionCheck(unit)) then
                    unit.homeCity = nil
                end
            end
        end
    end
    if secondarySpecificationTable[unit.type.id] and secondarySpecificationTable[unit.type.id].payload then
        local reArmFn = secondarySpecificationTable[unit.type.id].reArmingTileFunction or defaultReArmingTileFunction
        local reArmResult = reArmFn(unit.location)
        if civ.isCity(reArmResult) then
            unit.homeCity = reArmResult
            if secondarySpecificationTable[unit.type.id].payloadRestrictionCheck then
                if not (secondarySpecificationTable[unit.type.id].payloadRestrictionCheck(unit)) then
                    unit.homeCity = nil
                end
            end
        end
    end
end

local function defaultNoPayloadPrimaryMessage(unit)
    if unit.location.city and (not unit.homeCity) then
        return "Our "..unit.type.name.." unit has no home city.  It will be unable to use its primary munition attack until it is given a home city."
    else
        return nil
    end
end
local function defaultNoPayloadSecondaryMessage(unit)
    if unit.location.city and (not unit.homeCity) then
        return "Our "..unit.type.name.." unit has no home city.  It will be unable to use its secondary munition attack until it is given a home city."
    else
        return nil
    end
end

local function afterProductionReArm(primarySpecificationTable,secondarySpecificationTable)
    local activeTribe = civ.getCurrentTribe()
    for unit in civ.iterateUnits() do
        if unit.owner == activeTribe then
            automaticReArming(unit,primarySpecificationTable,secondarySpecificationTable)
        end
    end
end

local function activationReArm(unit,primarySpecificationTable,secondarySpecificationTable)
    automaticReArming(unit,primarySpecificationTable,secondarySpecificationTable)
    if unit.homeCity then
        return
    end
    primarySpecificationTable = primarySpecificationTable or {}
    secondarySpecificationTable = secondarySpecificationTable or {}
    if  primarySpecificationTable[unit.type.id] and primarySpecificationTable[unit.type.id].payload then
        local messageFn = primarySpecificationTable[unit.type.id].noPayloadActivationMessage or defaultNoPayloadPrimaryMessage
        local message = messageFn(unit)
        if message then
            civ.ui.text(message)
            return
        end
    end
    if  secondarySpecificationTable[unit.type.id] and secondarySpecificationTable[unit.type.id].payload then
        local messageFn = secondarySpecificationTable[unit.type.id].noPayloadActivationMessage or defaultNoPayloadSecondaryMessage
        local message = messageFn(unit)
        if message then
            civ.ui.text(message)
            return
        end
    end

end
local munitions = {
    linkState=linkState,
    unitDeathMaintenance=unitDeathMaintenance,
    getShooter=getShooter,
    spawnUnit=spawnUnit,
    doMunition=spawnUnit,
    payloadRestrictionCheck=payloadRestrictionCheck,
    onProdPayloadRestrictionCheck = onProdPayloadRestrictionCheck,
    afterProductionReArm = afterProductionReArm,
    activationReArm = activationReArm,
    airCanHaveZeroMovement = airCanHaveZeroMovement,

}

gen.versionFunctions(munitions,versionNumber,fileModified,"LuaCore".."\\".."munitions.lua")
return munitions





