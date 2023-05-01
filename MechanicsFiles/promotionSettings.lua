
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local promotion = require("promotion"):minVersion(2)
local object = require("object")
local rules = require("rules"):minVersion(1)
local promotionSettings = {}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(promotionSettings,versionNumber,fileModified,"MechanicsFiles".."\\".."promotionSettings.lua")

-- promotionChanceTable[unitType.id] = number in 0-1 or nil
--      the value is the chance of promotion
--      nil means use defaultPromotionChance
local defaultPromotionChance = 0.5
local promotionChanceTable = {}
-- created by the rules module
promotionChanceTable = rules.promotionChanceTable or {}


--promotionChanceFunction(loser,winner,aggressor,victim,loserVetStatus,winnerVetStatus,loserTile,aggressorVetStatus,victimVetStatus)-->number
--  This function determines the chance that a winner has of being promoted
--  through civ ii combat.  You can make this as simple or as complicated as
--  you like, tailoring the chance to the circumstances,
--  using some or all the available inputs.  By default, the 
--  promotionChanceTable declared above is used.
local function promotionChanceFunction(loser,winner,aggressor,victim,loserVetStatus,winnerVetStatus,loserTile,aggressorVetStatus,victimVetStatus)
    return promotionChanceTable[winner.type.id] or defaultPromotionChance
end
promotionSettings.promotionChanceFunction = promotionChanceFunction




-- Some basic functionality for demoting a unit into another unit upon defeat
-- is provided here
-- demotionTable[unitType.id] = nil (unit destroyed) or table with these keys
--      .replacementUnitType = unitType
--          the unit type that will replace the demoted unit
--          error if nil
--      .destroyIfKilledBy = unitType or table of unitType
--          if these units kill the demoted unit, don't replace with anything
--          nil means demote for all winners
--      .demoteOnlyIfKilledBy = unitType or table of unitType
--          destroy the unit if it isn't killed by one of these unit types
--          nil means demote for all winners
--          only one of destroyIfKilledBy and demoteOnlyIfKilledBy should exist per unit
--      .demoteOnlyIfVeteran = bool
--          if true, destroy the loser if it isn't a veteran unit
--          false or nil means non vets can be demoted
--      .vetStatus = "preserve" or "give" or "remove" or nil
--          if "preserve", then demoted unit has same veteran status as before demotion
--          if "give", the unit gains veteran status upon demotion
--          if "remove", the unit loses veteran status (if it has it) upon demotion
--          nil means "preserve"
--      .damage = integer or nil
--          sets the amount of damage for the demoted unit
--          nil means no damage
local demotionTable = {}
-- created by the rules module
demotionTable = rules.demotionTable


local demotionFunction = promotion.makeBasicDemotionFunction(demotionTable)
-- If you need functionality beyond the basicDemotionFunction, comment the above line,
-- and uncomment (and write) the function below
-- Note: demotionFunction shouldn't delete the unit being demoted
--demotionFunction(loser,winner,loserTile,loserVetStatus,winnerVetStatus)--> unit or false
--      loserVetStatus and winnerVetStatus are the veteran statuses before combat
--      (the winner could be promoted as a result of combat, in which case winnerVetStatus
--      and winner.veteran will not match)
--
--      if the unit is demoted, create the replacement unit, apply any changes
--      (gen.copyUnitAttributes(parent,child) might be useful) and return the replacement unit
--local function demotionFunction(loser,winner,loserTile,loserVetStatus,winnerVetStatus)
--    return false
--end

function promotionSettings.customizeCombatPromotion(loser,winner,aggressor,victim,loserTile,aggressorVetStatus,victimVetStatus)
    promotion.customVetChance(loser,winner,aggressor,victim,loserTile,victimVetStatus,aggressorVetStatus,promotionChanceFunction)
end


function promotionSettings.demotionFunction(loser,winner,loserLocation,loserVetStatus,winnerVetStatus)
    return promotion.unitDemotion(loser,winner,demotionFunction,loserLocation,loserVetStatus,winnerVetStatus)
end

-- Basic Unit Upgrades
--
-- upgradeInfoTable[upgradingUnit.type.id] = upgradeInfo

-- upgradeInfo = table with following keys
--      alternateUpgradeCondition = upgradeInfo
--          If there are several upgrade conditions (for example, defeating different units
--          leads do different upgrades) place the alternate upgrade info
--          as the value to this key (if there are more than two upgradeInfo, "chain" each
--          upgrade info into the next alternateUpgradeCondition key
--      defeatedUnitTypes = table of unitType or nil
--          the defeated unit must be one of these unit types in order to trigger the upgrade
--          nil means all units count, except for any units listed in defeatedUnitTypes for
--          any alternateUpgradeCondition
--          only one alternateUpgradeCondition can have a nil defeatedUnitTypes
--      excludedUnitTypes = table of unitType or nil
--          units in this table won't promote the winning unit if defeated
--          nil means no units are excluded
--          only valid if defeatedUnitTypes is nil
--      upgradeUnitType = unitType
--          The unit type that replaces the old unit
--          value must exist for this key
--      upgradeChance = number in [0,1]
--          chance that the unit will be upgraded
--      nonVetUpgrade = bool or nil
--          if true, a unit that is not already veteran is eligible to be upgraded
--          false or nil means only a veteran can upgrade
--      clearVetStatus = bool or nil
--          If true, veteran status is lost upon upgrade, if it exists
--      giveVetStatus = bool or nil
--          If true, veteran status is given upon upgrade, even if it doesn't already exist
--      healUnit = true or integer or nil
--          If true, set the damage of the upgrade unit to 0
--          If integer, reduce damage to the upgrade unit by the value (negative value means
--              damage unit, but unit will always be left with at least 1 hp)
--          false or nil means preserve the current amount of damage the unit has
--      preserveHP = bool or nil
--          if true, the upgraded unit's hp is set to the old unit's hp, instead of damage
--          This is done before healing/hurting in the previous key
--      spendMove = true or integer or nil
--          if true, spend all the unit's remaining movement points
--          if integer, spend this many movement points ('atomic' movement points, i.e.
--          1 fraction of a movement point) (if negative, restore movement)
--          if nil, the moveSpent is preserved from the old unit
--      spendMoveMult = number or nil
--          multiply number by totpp.movementMultipliers.aggregate and take floor
--              then use this value for spendMove
--              could be useful if the aggregate movement multiplier changes with the seasons
--          nil means do nothing
--      upgradeMessage = string or nil
--          This message is shown to the player when their unit is upgraded
--          nil means no message
--          %STRING1 is the name of the old unit type
--          %STRING2 is the name of the upgraded unit type
--
--
local upgradeOnlyAfterStandardCombat = false
-- set to true if you don't want upgrade checks when a unit 'defeats' another
-- unit through events, but only when a unit wins a 'standard' civilization ii battle


local upgradeInfoTable = {}
-- generated by rules module
upgradeInfoTable = rules.upgradeInfoTable
-- if you need more or different functionality than is provided by the basic upgrade function, 
-- provide the following two functions:
-- upgradeChanceFunction(winner,loser,loserTile,loserVetStatus,winnerVetStatus)-->number,unitType,promotionInfoTable
--      determines the chance of the winner upgrading, and if so, what unit type the winner
--      will be
--      if number returned is 0, the other two returned values can be nil
--      unitType is the unit type that the unit will be upgraded to
--      promotionInfoTable is a table of anything else the upgradeFunction might need
--          keys and values should be integers and strings
--          table can have no values if nothing must be provided

-- upgradeFunction(unitToUpgradeID,replacementTypeID,promotionInfoTable) --> unit
--      actually performs the upgrade, including deleting the original unit
--      must return the newly created unit
--      the function gen.replaceUnit(oldUnit,replacementType) might be useful here

local basicUpgradeChanceFunction, basicUpgradeFunction = promotion.buildBasicUpgrade(upgradeInfoTable)
local upgradeChanceFunction = basicUpgradeChanceFunction
local upgradeFunction = basicUpgradeFunction

function promotionSettings.checkForUpgradeCombat(loser,winner,loserTile,loserVetStatus,winnerVetStatus)
    -- if upgrades can occur at times other than standard combat, checkForUpgradeDefeat
    -- will make the check, even for combat
    if upgradeOnlyAfterStandardCombat then
        promotion.checkForUpgrade(winner,loser,upgradeChanceFunction,loserTile,loserVetStatus,winnerVetStatus)
    end
end

function promotionSettings.checkForUpgradeDefeat(loser,winner,loserTile,loserVetStatus,winnerVetStatus)
    if not upgradeOnlyAfterStandardCombat then
        promotion.checkForUpgrade(winner,loser,upgradeChanceFunction,loserTile,loserVetStatus,winnerVetStatus)
    end
end

-- if active unit is provided, and the active unit is upgraded, 
-- the replacement for the activeUnit is returned (so that unitActivation
-- code doesn't cause errors)
function promotionSettings.performPendingUpgrades(activeUnit)
    return promotion.performPendingUpgrades(upgradeFunction,activeUnit)
end

-- Override production veteran status

-- if prod isn't a unit, do nothing
-- if prod is a unit, and 
--      unitVetTable[prod.type.id] == nil then
--          proceed as normal
--      unitVetTable[prod.type.id] == true then
--          make the unit veteran, even if barracks, port, airport is not in city
--      unitVetTable[prod.type.id] == false then
--          the unit is not a veteran, even if city has barracks/sun tzu/lighthouse/port/airport
--      unitVetTable[prod.type.id] == improvementObject then
--          the unit is veteran if and only if the city has improvementObject
--      unitVetTable[prod.type.id] == wonderObject then
--          the unit is veteran if and only if the tribe controls the wonder


local unitVetTable = {}

--local function overrideProdVetStatus(city,prod)
--    return promotion.overrideProductionVetStatus(city,prod,unitVetTable)
--end
local function overrideProdVetStatus(city,prod)
    local extraVetChance = 0 -- use this if you want to have production veteran
    -- modification without replacing the rules_lst.txt features
    -- Note: extraVetChance has no effect if there is no
    -- @LSTPRODUCTIONVETERANSTATUS section in the rules_lst
    return rules.productionVeteranReplacement(city,prod,extraVetChance)
end
promotionSettings.overrideProdVetStatus = overrideProdVetStatus


return promotionSettings
