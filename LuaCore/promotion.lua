--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- This module deals with units being 'promoted' to other units, 'demoted' (instead of destroyed) to other units, and any other related functionality.
--
--
--  Functionality
--  Change Promotion Chances
--  Promotions for Munitions Users
--  Promoting Units to a new unit type upon combat victory
--  Demoting units to a new unit type upon defeat (instead of destroying the unit)
--
local gen = require("generalLibrary"):minVersion(1)
local text = require("text")
local munition = require("munitions")
local gamePromotionChance = 0.5 -- Don't change this, it is here so there are not a lot of 'magic' 0.5 floating around
local civlua = require("civluaModified")
--local eventTools = require("eventTools")

local promotion = {}
gen.versionFunctions(promotion,versionNumber,fileModified,"LuaCore".."\\".."promotion.lua")
local promotionState = "promotionStateNotLinked"

-- links the state table with this module
local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        promotionState = tableInStateTable
        promotionState.pendingPromotions = promotionState.pendingPromotions or {}
    else
        error("linkState: linkState takes a table as an argument.")
    end
end
promotion.linkState = linkState

local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "promotion"
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

local cancelledPromotionMessageFn = function(winner,loser)
    return "In this scenario, there is a reduced chance for gaining promotion.  Unfortunately, your "..winner.type.name.." unit has not been promoted to "..text.getVeteranTitle().." status."
end

local function setCancelledPromotionMessage(stringOrFn)
    local canPrFn = nil
    if type(stringOrFn) == "string" then
        canPrFn = function(winner,loser) return text.substitute(stringOrFn,{winner.type.name,loser.type.name}) end
    elseif type(stringOrFn) == "function" then
        canPrFn = stringOrFn
    end
    cancelledPromotionMessageFn = canPrFn
end
promotion.setCancelledPromotionMessage = setCancelledPromotionMessage

local eventPromotionMessageFn = function(winner,loser)
    return "For valor in combat, our "..winner.type.name.." unit has been promoted to "..text.getVeteranTitle().." status."
end

-- customVetChance(loser,winner,aggressor,victim,loserTile,victimVetStatus,aggressorVetStatus,promotionChanceFn)
-- promotionChanceFn(loser,winner,aggressor,victim,loserVetStatus,winnerVetStatus,loserTile,aggressorVetStatus,victimVetStatus)
-- The promotionChanceFn determines the likelihood that the winner of combat will be promoted to veteran status
-- if it is not already veteran. If the winner was promoted by the game, but should not have been promoted based
-- on the alternate promotion probability, a message will be displayed to the player, if the player is human.
-- If the probability is increased, a promotion message will also be displayed to the player, if human
-- if promotionChanceFn isn't specified, or returns nil, then the default promotion chance is used.
local function customVetChance(loser,winner,aggressor,victim,loserTile,victimVetStatus,aggressorVetStatus,promotionChanceFn)
    local winnerVetStatus = nil
    local loserVetStatus = nil
    local loserTile = nil
    if loser == victim then
        loserVetStatus = victimVetStatus
        winnerVetStatus = aggressorVetStatus
    else
        winnerVetStatus = victimVetStatus
        loserVetStatus = aggressorVetStatus
    end

    -- if no promotion chance function provided, or the winner was veteran before combat,
    -- then no need to do anything else
    if (not promotionChanceFn) or winnerVetStatus then
        return
    end
    local promotionChance = promotionChanceFn(loser,winner,aggressor,victim,loserVetStatus,winnerVetStatus,loserTile,aggressorVetStatus,victimVetStatus)
    -- if the function returns nil, then regular promotion applies
    if not promotionChance then
        return
    end
    if promotionChance < gamePromotionChance and winner.veteran then
        -- might have to remove recently bestowed vet status
        if math.random() < (gamePromotionChance-promotionChance)/gamePromotionChance then
            -- this is the case where the game promotes a unit to vet status, but
            -- the unit should not have been promoted based on the promotion chance for this
            -- unit in these circumstances
            winner.veteran = false
            -- if the player is human, we may want a cancelled promotion message
            if winner.owner.isHuman then
                if winner.owner == civ.getCurrentTribe() then
                    -- human is the active player
                    text.simple(cancelledPromotionMessageFn(winner,loser),"Defense Minister")
                elseif gen.isSinglePlayerGame() and winner.owner == civ.game.humanTribe then
                -- if there is only one human player, show the message even if it is another player's turn
                    text.simple(cancelledPromotionMessageFn(winner,loser),"Defense Minister")
                end
            end
        end
    elseif promotionChance > gamePromotionChance and (not winner.veteran) then
        -- might have to bestow veteran status
        if math.random() < (promotionChance-gamePromotionChance)/(1-gamePromotionChance) then
            -- this is the case where the game doesn't promote a unit but
            -- the unit should have been promoted based on the promotion chance for this
            -- unit in these circumstances
            winner.veteran = true
            -- if the player is human, we may want a promotion message
            if winner.owner.isHuman then
                if winner.owner == civ.getCurrentTribe() then
                    -- human is the active player
                    text.simple(eventPromotionMessageFn(winner,loser),"Defense Minister")
                elseif gen.isSinglePlayerGame() and winner.owner == civ.game.humanTribe then
                -- if there is only one human player, show the message even if it is another player's turn
                    text.simple(eventPromotionMessageFn(winner,loser),"Defense Minister")
                end
            end
        end
    end
end
promotion.customVetChance = customVetChance


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

local function makeBasicDemotionFunction(demotionTable)
    local newDemotionTable = {}
    for unitTypeID,demotionInfo in pairs(demotionTable) do
        if demotionInfo.destroyIfKilledBy and demotionInfo.demoteOnlyIfKilledBy then
            error("makeBasicDemotionFunction: the demotion information for "..civ.getUnitType(unitTypeID).name.." units has both a destroyIfKilledBy key and a demoteOnlyIfKilledBy key, but only one of these is allowed per unit.")
        end
        demotionInfo.destroyIfKilledBy = demotionInfo.destroyIfKilledBy and gen.tableWrap(demotionInfo.destroyIfKilledBy)
        demotionInfo.demoteOnlyIfKilledBy = demotionInfo.demoteOnlyIfKilledBy and gen.tableWrap(demotionInfo.demoteOnlyIfKilledBy)
        demotionInfo.vetStatus = demotionInfo.vetStatus or "preserve"
        local validVetStatus = {["preserve"]=true,["give"]=true,["remove"]=true,}
        if not validVetStatus[demotionInfo.vetStatus] then
            error("makeBasicDemotionFunction: "..tostring(demotionInfo.vetStatus).." is not a valid value for the vetStatus key.  Valid values are \"preserve\", \"give\",\"remove\" and nil.")
        end
        newDemotionTable[unitTypeID] = {}
        --newDemotionTable[unitTypeID].replaceIfKilledBy[winner.type.id]
        --  if value true, replace the unit, if false, don't
        newDemotionTable[unitTypeID].replaceIfKilledBy = {}
        -- metatable handles default case
        local mt = getmetatable(newDemotionTable[unitTypeID].replaceIfKilledBy)
        if demotionInfo.demoteOnlyIfKilledBy then
            -- default case is kill loser
            setmetatable(newDemotionTable[unitTypeID].replaceIfKilledBy,{__index = function(myTable,key)
            return false end})
        else
            -- default case is demote loser
            setmetatable(newDemotionTable[unitTypeID].replaceIfKilledBy,{__index = function(myTable,key)
            return true end})

        end
        if demotionInfo.destroyIfKilledBy then
            for __,winnerUnitType in pairs (demotionInfo.destroyIfKilledBy) do
                newDemotionTable[unitTypeID].replaceIfKilledBy[winnerUnitType.id] = false
            end
        end
        if demotionInfo.demoteOnlyIfKilledBy then
            for __,winnerUnitType in pairs(demotionInfo.demoteOnlyIfKilledBy) do
                newDemotionTable[unitTypeID].replaceIfKilledBy[winnerUnitType.id] = true
            end
        end
        if not demotionInfo.replacementUnitType then
            error("makeBasicDemotionFunction: the demotion information for "..civ.getUnitType(unitTypeID).name.." does not specify a replacement unit type.")
        end
        newDemotionTable[unitTypeID].replacementUnitType = demotionInfo.replacementUnitType
        newDemotionTable[unitTypeID].vetStatus = demotionInfo.vetStatus
        newDemotionTable[unitTypeID].damage = demotionInfo.damage or 0
        newDemotionTable[unitTypeID].demoteOnlyIfVeteran = demotionInfo.demoteOnlyIfVeteran
    end
    local function demotionFunction(loser,winner,loserTile,loserVetStatus,winnerVetStatus)
        local loserTypeID = loser.type.id
        if not (newDemotionTable[loserTypeID] and
                newDemotionTable[loserTypeID].replaceIfKilledBy and
                newDemotionTable[loserTypeID].replaceIfKilledBy[winner.type.id]) then
            return false
        end
        local nDTVal = newDemotionTable[loserTypeID]
        if nDTVal.demoteOnlyIfVeteran and (not loserVetStatus) then
            return false
        end
        local demotedUnit = civ.createUnit(newDemotionTable[loserTypeID].replacementUnitType,loser.owner,loserTile)
        gen.copyUnitAttributes(loser,demotedUnit)
        -- note, need to do this so if the attacker is demoted, the replacement ends up
        -- in the right place.
        demotedUnit:teleport(loserTile)
        if nDTVal.vetStatus == "give" then
            demotedUnit.veteran = true
        elseif nDTVal.vetStatus == "remove" then
            demotedUnit.veteran = false
        end
        demotedUnit.damage = nDTVal.damage
        return demotedUnit
    end
    return demotionFunction

end
promotion.makeBasicDemotionFunction = makeBasicDemotionFunction

-- unitDemotion(loser,winner,demotionFunction,loserTile,loserVetStatus,winnerVetStatus) --> unit or nil
--  loser and winner are unit types
--  demotionFunction(loser,winner,loserTile,loserVetStatus,winnerVetStatus)-->unit or false
--  this does not kill the loser, that is assumed to happen elsewhere
local function unitDemotion(loser,winner,demotionFunction,loserTile,loserVetStatus,winnerVetStatus)
    return (demotionFunction(loser,winner,loserTile,loserVetStatus,winnerVetStatus) or nil)
end
promotion.unitDemotion = unitDemotion

-- if improvement/wonder, return prod and do nothing
-- if unit, replace unit and delete original, returning
-- new unit for use later in production event
-- (deleting and replacing is an easy way to avoid barracks
-- vet status, since the new unit is bestowed with veteran status
-- after the cityProductionEvent takes place)
local function clearProductionVetStatus(city,prod) --> prod
    if civ.isUnit(prod) then
        local replacement = civ.createUnit(prod.type,city.owner,city.location)
        gen.copyUnitAttributes(prod,replacement)
        replacement.veteran = false
    else
        return prod
    end
end
promotion.clearProductionVetStatus = clearProductionVetStatus

-- overrideProductionVetStatus(city,prod,unitVetTable) --> unit or improvementObject or WonderObject
--      returns the recently produced object (necessary, since in some circumstances the unit will be replaced)
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

local function overrideProductionVetStatus(city,prod,unitVetTable)
    if civ.isUnit(prod) then
        local value = unitVetTable[prod.type.id]
        if value == nil then
            return prod
        elseif value == true then
            prod.veteran = true
            return prod
        elseif value == false then
            return clearProductionVetStatus(city,prod)
        elseif civ.isImprovement(value) then
            if city:hasImprovement(value) then
                prod.veteran = true
                return prod
            else
                return clearProductionVetStatus(city,prod)
            end
        elseif civ.isWonder(value) then
            if value.city and value.city.owner == city.owner then
                prod.veteran = true
                return prod
            else
                return clearProductionVetStatus(city,prod)
            end
        else
            error("overrideProductionVetStatus: the unitVetTable has an ineligible value associated with the unittype "..prod.type.name..".")
        end
    else
        return prod
    end
end
promotion.overrideProductionVetStatus = overrideProductionVetStatus


-- unit promotions happen as an activateUnit event,
-- this way the combat 'winner' doesn't get deleted in 
-- the middle of events in a stack kill or something
-- We can declare promotions, and add them to a 'promotion
-- queue.
-- upgradeChanceFn(winner,loser,loserTile,loserVetStatus,winnerVetStatus)-->number,unitType,promotionInfoTable
--      determines the chance of the winner upgrading, and, if so, what unit type the
--      winner will be promoted to
--      the table is any extra information that the actual promotion function might need


local function checkForUpgrade(winner,loser,upgradeChanceFn,loserTile,loserVetStatus,winnerVetStatus)
    local upgradeChance,upgradeUnitType,promotionInfoTable = upgradeChanceFn(winner,loser,loserTile,loserVetStatus,winnerVetStatus)
    local function winnerUpgradeNotPending(winner)
        for key,value in pairs(promotionState.pendingPromotions) do
            if value.unitID == winner.id then
                return false
            end
        end
        return true
    end
    if math.random()<upgradeChance and civ.isUnitType(upgradeUnitType) and winnerUpgradeNotPending(winner) then
        promotionState.pendingPromotions[#promotionState.pendingPromotions+1] = {unitID = winner.id,replacementTypeID = upgradeUnitType.id, promotionInfoTable = promotionInfoTable}
        --eventTools.guaranteeUnitActivation(winner.owner)
        -- activateUnitBackstop made available by onGetFormattedDate renders guaranteeUnitActivation unnecessary
    end
end
promotion.checkForUpgrade = checkForUpgrade

local function defaultUpgradeFunction(unitToUpgradeID,replacementTypeID,promotionInfoTable)
    local oldUnit = civ.getUnit(unitToUpgradeID)
    local newUnit = civ.createUnit(civ.getUnitType(replacementTypeID),oldUnit.owner,oldUnit.location)
    gen.copyUnitAttributes(oldUnit,newUnit)
    if oldUnit.owner.isHuman and civ.getCurrentTribe() == oldUnit.owner then
        text.simple(text.substitute("Through valour in combat, our %STRING1 unit has become a %STRING2 unit.",{oldUnit.type.name,newUnit.type.name}),"Defense Minister")
    end
    gen.deleteUnit(oldUnit,newUnit)
end

local function performPendingUpgrades(upgradeFunction)
    upgradeFunction = upgradeFunction or defaultUpgradeFunction
    for i=1,(#promotionState.pendingPromotions) do
        local promotionInfo = promotionState.pendingPromotions[i]
        upgradeFunction(promotionInfo.unitID,promotionInfo.replacementTypeID,promotionInfo.promotionInfoTable)
        promotionState.pendingPromotions[i] = nil
    end
end
promotion.performPendingUpgrades = performPendingUpgrades

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
--      stackKillUpgrade = bool
--          if true, every unit killed in a stack provides a chance
--          for an upgrade
--          nil or false means that upgrades are only checked for
--          if the loser unit has 0 hp or less
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

        



-- basicUpgradeData[winner.type.id][loser.type.id] = table with keys
--          upgradeUnitType = unitType
--          stackKillUpgrade = bool or nil
--          upgradeChance = number in [0,1]
--          nonVetUpgrade = bool or nil
--          clearVetStatus = bool or nil
--          giveVetStatus = bool or nil
--          healUnit = bool or integer or nil
--          preserveHP = bool or nil
--          spendMove = bool, integer, or nil
--          spendMoveMult = number or nil
--          upgradeMessage = string or nil
--
local basicUpgradeData = {}

local makeUpgradeInfoError = false

local function checkUpgradeInfo(upgradeInfo,tableKey,nilDefeatedUnitTypes,defeatedUnitTypesTable)
    nilDefeatedUnitTypes = nilDefeatedUnitTypes or false
    defeatedUnitTypesTable = defeatedUnitTypesTable or {}
    local defeatedUnitTypes = upgradeInfo.defeatedUnitTypes
    if type(defeatedUnitTypes) ~= "table" and type(defeatedUnitTypes) ~= "nil" then
        makeUpgradeInfoError = true
        print(civ.getUnitType(tableKey).name..":defeatedUnitTypes must be nil or a table.")
    end
    if defeatedUnitTypes == nil and nilDefeatedUnitTypes then
        makeUpgradeInfoError = true
        print(civ.getUnitType(tableKey).name..":defeatedUnitTypes can only be nil for one upgrade condition")
    elseif defeatedUnitTypes == nil then
        nilDefeatedUnitTypes = true
    elseif type(defeatedUnitTypes) == "table" then
        for __,unitType in pairs(defeatedUnitTypes) do
            if defeatedUnitTypesTable[unitType] then
                print(civ.getUnitType(tableKey).name..": defeatedUnitTypes duplicates the unit "..unitType.name)
                makeUpgradeInfoError = true
            elseif not civ.isUnitType(unitType) then
                print(civ.getUnitType(tableKey).name..": defeatedUnitTypes has a non unit type as an entry ("..tostring(unitType)..")")
                makeUpgradeInfoError = true
            end
            defeatedUnitTypesTable[unitType] = true
        end
    end
    if upgradeInfo.excludedUnitTypes and upgradeInfo.defeatedUnitTypes then
        print(civ.getUnitType(tableKey).name..": defeatedUnitTypes must be nil to use excludedUnitTypes")
        makeUpgradeInfoError = true
    end
    if upgradeInfo.excludedUnitTypes then
        for __,unitType in pairs(upgradeInfo.excludedUnitTypes) do
            if not civ.isUnitType(unitType) then
                print(civ.getUnitType(tableKey).name..": excludedUnitTypes has a non unit type as an entry ("..tostring(unitType)..")")
                makeUpgradeInfoError = true
            end
        end
    end
    if not type(upgradeInfo.upgradeChance) == "number" then
        print(civ.getUnitType(tableKey).name..": upgradeChance is not a number.")
        makeUpgradeInfoError = true
    end
    if upgradeInfo.healUnit and type(upgradeInfo.healUnit) ~="boolean" and (type(upgradeInfo.healUnit)~="number" or
        math.floor(upgradeInfo.healUnit) ~= upgradeInfo.healUnit) then
        print(civ.getUnitType(tableKey).name..": healUnit must be a boolean or an integer.")
        makeUpgradeInfoError = true
    end
    if upgradeInfo.spendMove and type(upgradeInfo.spendMove) ~= "boolean" and (type(upgradeInfo.spendMove)~="number" or
        math.floor(upgradeInfo.spendMove) ~= upgradeInfo.spendMove) then
        print(civ.getUnitType(tableKey).name..": spendMove must be a boolean or an integer.")
        makeUpgradeInfoError = true
    end
    if upgradeInfo.spendMoveMult and type(upgradeInfo.spendMoveMult)~="number" then
        print(civ.getUnitType(tableKey).name..": spendMoveMult must be an integer.")
        makeUpgradeInfoError = true
    end
    if upgradeInfo.upgradeMessage and type(upgradeInfo.upgradeMessage)~="string" then
        print(civ.getUnitType(tableKey).name..": upgradeMessage must be a string.")
        makeUpgradeInfoError = true
    end
    if upgradeInfo.alternateUpgradeCondition then
        checkUpgradeInfo(upgradeInfo.alternateUpgradeCondition,tableKey,nilDefeatedUnitTypes,defeatedUnitTypesTable)
    end
end

local function validateUpgradeInfoTable(upgradeInfoTable)
    for key,value in pairs(upgradeInfoTable) do
        checkUpgradeInfo(value,key)
    end
    if makeUpgradeInfoError then
        error("promotion.validateUpgradeInfoTable: the submitted upgrade information table does not appear to be valid.  See the above messages for error details.")
    end
end


-- buildBasicUpgrade(upgradeInfoTable)-->upgradeChanceFunction,upgradeFunction

local function buildBasicUpgrade(upgradeInfoTable)
    validateUpgradeInfoTable(upgradeInfoTable)
    -- save the upgrade info with nil for defeated unit types for last
    local nilDefeatedUnitTypesUpgradeInfo = nil
    local function buildUpgradeData(upgradeInfo)
        local upgradeData = {}
        for __,keyString in pairs({
            "upgradeUnitType", 
            "upgradeChance", 
            "nonVetUpgrade", 
            "stackKillUpgrade",
            "clearVetStatus", 
            "giveVetStatus", 
            "healUnit", 
            "preserveHP", 
            "spendMove", 
            "spendMoveMult", 
            "upgradeMessage", 
            }) do
            upgradeData[keyString] = upgradeInfo[keyString]
        end
        return upgradeData
    end
    local function buildUpgradeDataForWinner(winnerTypeID,upgradeInfo,nilUpgradeInfo)
        basicUpgradeData[winnerTypeID] = basicUpgradeData[winnerTypeID] or {}
        if upgradeInfo.defeatedUnitTypes == nil then
            nilUpgradeInfo = upgradeInfo
        else
            local upgrdData = buildUpgradeData(upgradeInfo)
            for __,unitType in pairs(upgradeInfo.defeatedUnitTypes) do
                basicUpgradeData[winnerTypeID][unitType.id]=upgrdData
            end
        end
        if upgradeInfo.alternateUpgradeCondition then
            return buildUpgradeDataForWinner(winnerTypeID,upgradeInfo.alternateUpgradeCondition,nilUpgradeInfo)
        elseif nilUpgradeInfo then
            local upgrdData = buildUpgradeData(nilUpgradeInfo)
            for i=0,civ.cosmic.numberOfUnitTypes do
                if not gen.inTable(civ.getUnitType(i),nilUpgradeInfo.excludedUnitTypes or {}) then
                    basicUpgradeData[winnerTypeID][i] = basicUpgradeData[winnerTypeID][i] or upgrdData
                end
            end
            return
        else
            return
        end
    end
    for unitID,upgradeInfo in pairs(upgradeInfoTable) do
        buildUpgradeDataForWinner(unitID,upgradeInfo,nil)
    end
    local function upgradeChanceFunction(winner,loser,loserTile,loserVetStatus,winnerVetStatus)
        local upgradeInfo = nil
        if basicUpgradeData[winner.type.id] and basicUpgradeData[winner.type.id][loser.type.id] then
            upgradeInfo = basicUpgradeData[winner.type.id][loser.type.id]
        else
            return 0,nil,nil
        end
        if (loser.damage < loser.type.hitpoints) and (not upgradeInfo.stackKillUpgrade) then
            return 0,nil,nil
        end
        if not (winnerVetStatus or upgradeInfo.nonVetUpgrade) then
            -- unit can't upgrade since it wasn't veteran before combat
            return 0,nil,nil
        end
        return upgradeInfo.upgradeChance,upgradeInfo.upgradeUnitType,{winnerTypeID = winner.type.id,loserTypeID = loser.type.id}
    end
    local function upgradeFunction(unitToUpgradeID,replacementTypeID,promotionInfoTable)
        local uDT = basicUpgradeData[promotionInfoTable.winnerTypeID][promotionInfoTable.loserTypeID]
        local oldUnit = civ.getUnit(unitToUpgradeID)
        local newHP = nil
        if uDT.preserveHP then
            newHP = oldUnit.hitpoints
            if type(uDT.healUnit) == "number" then
                newHP = newHP+uDT.healUnit
            end
        end
        local upgradedUnit = gen.replaceUnit(oldUnit,civ.getUnitType(replacementTypeID))
        if uDT.clearVetStatus then
            upgradedUnit.veteran = false
        end
        if uDT.giveVetStatus then
            upgradedUnit.veteran = true
        end
        local newDamage = upgradedUnit.damage
        if newHP then
            newDamage = math.max(0,upgradedUnit.type.hitpoints - newHP)
        elseif uDT.healUnit == true then
            newDamage = 0
        elseif type(uDT.healUnit) == "number" then
            newDamage = math.max(0,newDamage - uDT.healUnit)
            newDamage = math.min(newDamage,upgradedUnit.type.hitpoints -1)
        end
        upgradedUnit.damage = newDamage
        local spendMove = nil
        if uDT.spendMoveMult then
            spendMove = math.floor(uDT.spendMoveMult*totpp.movementMultipliers.aggregate)
        elseif uDT.spendMove == true then
            spendMove = upgradedUnit.type.move - upgradedUnit.moveSpent
        elseif type(uDT.spendMove) =="number" then
            spendMove = uDT.spendMove
        else
            spendMove = 0
        end
        upgradedUnit.moveSpent = math.min(255,upgradedUnit.moveSpent+spendMove)
        if uDT.upgradeMessage and upgradedUnit.owner == civ.getCurrentTribe() and upgradedUnit.owner.isHuman then
            text.simple(text.substitute(uDT.upgradeMessage,{civ.getUnitType(promotionInfoTable.winnerTypeID).name,upgradedUnit.type.name}),"Defense Minister")
        end
    end
    return upgradeChanceFunction, upgradeFunction
end
promotion.buildBasicUpgrade = buildBasicUpgrade






























return promotion
