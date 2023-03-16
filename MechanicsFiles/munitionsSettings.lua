
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local munitions = require("munitions")

local munitionSettings = {}
local object = require("object")
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(munitionSettings,versionNumber,fileModified,"MechanicsFiles".."\\".."munitionsSettings.lua")

-- This disables the workaround where air units
-- are left with 1 movement point, so they expend their range unit of range
-- (which wouldn't happen if their moveSpent was changed by event so they have
-- no more movement for the turn)
-- This is now corrected, but the option is enabled by default for backward compatibility
munitions.airCanHaveZeroMovement()

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
--      absent means 0 for land/sea, 1 "atomic" for air units (unless munitions.airCanHaveZeroMovement() is run)
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
--      absent means 0 for land/sea, 1 "atomic" for air units(unless munitions.airCanHaveZeroMovement() is run)
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




-- This is the primary attack specification table
local primaryAttackTable = {}
--[[
primaryAttackTable[gen.original.uBomber.id] = {
    generatedUnitType = gen.original.uCruiseMsl,
    moveCost = 4,
}
--]]





-- This is the secondary attack specification table
local secondaryAttackTable = {}
--[[
secondaryAttackTable[gen.original.uBomber.id] = {
    generatedUnitType = gen.original.uCruiseMsl,
    moveCost = 4,
}
--]]


local function primaryAttack(generatingUnit)
    return munitions.spawnUnit(generatingUnit,primaryAttackTable,gen.getActivationFunction())
end
munitionSettings.primaryAttack = primaryAttack

local function secondaryAttack(generatingUnit)
    return munitions.spawnUnit(generatingUnit,secondaryAttackTable,gen.getActivationFunction())
end
munitionSettings.secondaryAttack = secondaryAttack

local function activationReArm(unit)
    munitions.activationReArm(unit,primaryAttackTable,secondaryAttackTable)
end
munitionSettings.activationReArm = activationReArm


local function afterProductionReArm()
    munitions.afterProductionReArm(primaryAttackTable,secondaryAttackTable)
end
munitionSettings.afterProductionReArm = afterProductionReArm


local function payloadRestrictionCheck(carryingUnit)
    munitions.payloadRestrictionCheck(carryingUnit,primaryAttackTable)
    munitions.payloadRestrictionCheck(carryingUnit,secondaryAttackTable)
end
munitionSettings.payloadRestrictionCheck = payloadRestrictionCheck

local function keyPressPayloadRestrictionCheck(carryingUnit)
    civ.sleep(100)
    payloadRestrictionCheck(carryingUnit)
end
munitionSettings.keyPressPayloadRestrictionCheck = keyPressPayloadRestrictionCheck

local function onProdPayloadRestrictionCheck(carryingUnit)
    munitions.onProdPayloadRestrictionCheck(carryingUnit,primaryAttackTable)
    munitions.onProdPayloadRestrictionCheck(carryingUnit,secondaryAttackTable)
end
munitionSettings.onProdPayloadRestrictionCheck = onProdPayloadRestrictionCheck
local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar") 
if fileFound then
    function discreteEvents.onActivateUnit(unit,source,rep)
        activationReArm(unit)
    end
    function discreteEvents.onAfterProduction(turn,tribe)
        afterProductionReArm()   
    end
    function discreteEvents.onCityProduction(city,prod)
        if civ.isUnit(prod) then
            onProdPayloadRestrictionCheck(prod)
        end
    end
end

return munitionSettings
