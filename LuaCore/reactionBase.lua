--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- This file is not intended to be changed by the scenario creator

local text = require("text")

local civlua = require("civlua")
local gen = require("generalLibrary"):minVersion(1)

--[[
Usage Information





--]]
--
--


-- canReact(triggerUnit,reactingUnit)--> string or false
-- if unit can react, it returns a string with the reaction category,
-- if it can't it returns false
--
-- hitProbability(triggerUnit,reactingUnit) --> number
-- returns the probability that the reactingUnit will hit the trigger unit if it fires.
-- less than 0 means always miss, more than 1 means always hit
--
-- damageSchedule(triggerUnit,reactingUnit)-->thresholdTable
-- If a unit 'hits', roll a number between 0 and 1, and put it into the
-- thresholdTable.  The value returned gives the actual damage for the hit
-- (which could be 0)
--
-- reactionPriority(triggerUnit,reactingUnit,hitProbability,damageSchedule)--> number
-- gives a 'score' to each unit that can react, the unit with the highest score actually attacks
-- if several units have equal priority, the unit with the highest id number makes the attack
--
-- munitionEffect(triggerUnitBeforeDamage,reactingUnit,tableOfMunitionsGenerated,triggerUnitHit,damageToBeDoneToTriggerUnit)-->void
-- allows for stuff to be done to generated munitions
-- triggerUnitHit is true if the firing unit 'hit' the triggerUnit, even if that hit did 0 damage
--
-- afterReaction(triggerUnitAfterDamageBeforeDeletion,reactingUnit,damageDone,triggerUnitHit,triggerUnitKilled,triggerUnitDemoted) --> void
-- does stuff after a reacting unit 'fires' on the trigger unit
-- e.g. expend a reaction for the turn, cost money, etc
-- triggerUnitHit is true if the attack did not miss (even if damageSchedule returned 0), false if missed
-- triggerUnitKilled is true if the attack killed the trigger unit false if the unit survived the 
-- attack from the reacting unit or was demoted (i.e. killed, but replaced with another unit)
-- triggerUnitDemoted is true if the attack killed the trigger unit, but the trigger unit was replaced with
-- another unit, false if the unit was killed outright or not killed at all
--
-- doWhenUnitKilled(loser,winner)-->unit or nil
-- this is the code to run when a unit is killed.  The loser will be the trigger unit, and the winner will be
-- the reacting unit.  If the unit is 'demoted' instead of killed, the function should return the replacement
-- unit.  nil should be returned if the unit is killed outright



local reactionBase = {}

local maximumReactionDistance = 6

function reactionBase.setMaximumReactionDistance(integer)
    if type(integer) ~= "number" or (math.floor(integer) ~= integer) then
        error("reactionBase.setMaximumReactionDistance: argument must be an integer.")
    end
    maximumReactionDistance = integer
end

local function reactionEngine(theTriggerUnit,theTableOfMunitionsGenerated,canReact,hitProbability,damageSchedule,reactionPriority,munitionEffect,afterReaction,doWhenUnitKilled,maximumReactionsAgainstTriggerUnit)

    -- the units with these id numbers have already reacted to the triggerUnit
    -- that is alreadyReactedUnitIDs[unit.id]=true if the unit has reacted
    local triggerTribe = theTriggerUnit.owner
    local alreadyReactedUnitIDs = {}
    local function getReactionUnits(triggeringUnit,alreadyReactedTable)
        local reactingUnitsList = {}
        local index = 1
        for unit in gen.nearbyUnits(triggeringUnit.location,maximumReactionDistance) do
            -- instead of true, canReact returns a string for the 'type' of reaction attack
            -- e.g. 'dive' from high altitude to low, 'climb' from lower altitude to high, etc.
        --
        --  Supplied Function 
        --
            local canReactResult = canReact(triggeringUnit,unit)
        --
        --  
        --
            if not(alreadyReactedTable[unit.id]) and canReactResult then
                reactingUnitsList[index] = {["unit"] = unit,
                                            ["reactionType"] = canReactResult,
        --
        --  Supplied Function 
        --
                                            ["hitProbability"]= hitProbability(triggeringUnit,unit),
        --
        --  Supplied Function 
        --
                                            ["damageSchedule"]= damageSchedule(triggeringUnit,unit),}
        --
        --
        --

                index = index+1
            end
        end
        --print(civlua.serialize(reactingUnitsList))
        return reactingUnitsList
    end

    local reportTable = {}
    -- reportTable[tribeID][unitTypeID][reactionTypeString] = number of times unitType from tribe attacked
    -- with the given 'type' of reaction
    -- e.g. 'dive', 'climb', 'attack',
    local deathsAndDemotions = {}
    -- records when a unit is killed or demoted


    local function doSingleReaction(triggeringUnit,reactingUnitsList)-->nextTriggerUnit,closeConditionString
        local bestReactingUnitSoFar = nil
        local bestScoreSoFar = -math.huge
        local bestIndexSoFar = nil
        local bestIDSoFar = -math.huge
        for listIndex,unitInfo in pairs(reactingUnitsList) do
        --
        --  Supplied Function 
        --
            local reactionScore = reactionPriority(triggeringUnit,unitInfo.unit,unitInfo.hitProbability,
                                                    unitInfo.damageSchedule)
        --
        --
        --
            if reactionScore > bestScoreSoFar or (reactionScore == bestScoreSoFar and
                unitInfo.unit.id > bestIDSoFar) then
                bestReactingUnitSoFar = unitInfo.unit
                bestScoreSoFar = reactionScore
                bestIndexSoFar = listIndex
                bestIDSoFar = bestReactingUnitSoFar.id
            end
        end
        if bestReactingUnitSoFar == nil then
            return triggeringUnit,"noReactingUnits"
        end
        local reactionEntry = reactingUnitsList[bestIndexSoFar]
        local firingUnit = bestReactingUnitSoFar
        local damageDealt = 0
        local targetHit = false
        if math.random() <=reactionEntry.hitProbability then
            damageDealt = reactionEntry.damageSchedule[math.random()]
            damageDealt = math.min(damageDealt,triggeringUnit.hitpoints)
            targetHit = true
        end
        -- make sure the unit can't react again to this unit or any demoted unit
        alreadyReactedUnitIDs[firingUnit.id] = true
        --
        --  Supplied Function 
        --
        munitionEffect(triggeringUnit,firingUnit,theTableOfMunitionsGenerated,targetHit,damageDealt)
        --
        --
        --
        local triggeringUnitKilled = false
        local triggeringUnitDemoted = false
        -- note overkill damage was fixed above, so unit won't go into negative hp
        triggeringUnit.damage = triggeringUnit.damage+damageDealt
        local replacingUnit = nil
        if triggeringUnit.hitpoints <= 0 then
            -- 
            -- Supplied Function
            --
            replacingUnit = doWhenUnitKilled(triggeringUnit,firingUnit)
            --
            --
            --
            if replacingUnit then
                triggeringUnitDemoted = true
                deathsAndDemotions[#deathsAndDemotions+1] = {triggeringUnit.type.name,replacingUnit.type.name}
            else
                triggeringUnitKilled = true
                deathsAndDemotions[#deathsAndDemotions+1] = {triggeringUnit.type.name}
            end
        end
        --
        -- Supplied Function
        --
        afterReaction(triggeringUnit,firingUnit,damageDealt,targetHit,triggeringUnitKilled,triggeringUnitDemoted)
        --
        --
        --
        local tribeID = firingUnit.owner.id
        local unitTypeID = firingUnit.type.id
        local reactType = reactingUnitsList[bestIndexSoFar]["reactionType"]
        reportTable[tribeID] = reportTable[tribeID] or {}
        reportTable[tribeID][unitTypeID] = reportTable[tribeID][unitTypeID] or {}
        reportTable[tribeID][unitTypeID][reactType] = (reportTable[tribeID][unitTypeID][reactType] or 0)+1
        reactingUnitsList[bestIndexSoFar]=nil
        if triggeringUnitDemoted then
            civ.deleteUnit(triggeringUnit)
            return replacingUnit,"unitDemoted"
        elseif triggeringUnitKilled then
            civ.deleteUnit(triggeringUnit)
            return nil,"unitKilled"
        else
            return triggeringUnit,"unitSurvived"
        end
    end



    local triggerUnit = theTriggerUnit
    -- the trigger unit will change if it is 'demoted' instead of killed (think damaged B17s)
    -- trigger unit will be nil when the unit is killed
    local reactionsToTriggerUnit = 0
    local tableOfReactingUnits = getReactionUnits(triggerUnit,alreadyReactedUnitIDs)
    local function tableIsEmpty(table)
        for __,val in pairs(table) do
            return false
        end
        return true
    end


    repeat
        local unitReturned,textReturned = doSingleReaction(triggerUnit,tableOfReactingUnits)
        if textReturned == "noReactingUnits" then
            break
        elseif textReturned == "unitDemoted" then
            triggerUnit = unitReturned
            tableOfReactingUnits = getReactionUnits(triggerUnit,alreadyReactedUnitIDs)
            reactionsToTriggerUnit = reactionsToTriggerUnit + 1
        elseif textReturned == "unitKilled" then
            triggerUnit = unitReturned
            reactionsToTriggerUnit = reactionsToTriggerUnit + 1
            break
        elseif textReturned == "unitSurvived" then
            triggerUnit = unitReturned
            reactionsToTriggerUnit = reactionsToTriggerUnit + 1
        end
    until (tableIsEmpty(tableOfReactingUnits) or not(triggerUnit) or (reactionsToTriggerUnit >= maximumReactionsAgainstTriggerUnit))

    local tabulationData = {}
    tabulationData[0]={[1]="Tribe",[2]="Unit Type",[3]="Reaction Category"}
    local tdIndex = 1
    for i=1,#deathsAndDemotions do
        local entry = deathsAndDemotions[i]
        if entry[2] then
            -- unit was demoted
            tabulationData[tdIndex]={[1]=triggerTribe.adjective,[2]=entry[1],[3]="Demoted to "..entry[2]}
        else
            -- unit was killed
            tabulationData[tdIndex]={[1]=triggerTribe.adjective,[2]=entry[1],[3]="Destroyed"}
        end
        tdIndex = tdIndex+1
    end
    for tribeID = 0,7 do
        if reportTable[tribeID] then
            local tribeAdjective = civ.getTribe(tribeID).adjective
            for unitTypeID = 0,127 do
                if reportTable[tribeID][unitTypeID] then
                    local unitTypeName = civ.getUnitType(unitTypeID).name
                    for reactionTypeString,value in pairs(reportTable[tribeID][unitTypeID]) do
                        tabulationData[tdIndex] = {[1] = tribeAdjective,[2] = unitTypeName,
                        [3] = tostring(value).." "..reactionTypeString,}
                        tdIndex = tdIndex+1
                    end
                end
            end
        end
    end
    if tabulationData[1] then
        text.simpleTabulation(tabulationData,"Enemy Reaction")
    end
end
reactionBase.reactionEngine = reactionEngine


local reactionState = "reactionStateNotLinked"
local unitReactionsCount = {}
local lastReactionCountReset = {}
-- lastReactionCountReset[tribeID]={turn=turn or reset,tribeID = active Tribe's ID when reset}
-- determines when a tribe's units in unitReactionsCount were last reset to 0

-- can't serialize math.huge, so this will have to do
local hugeNumber = 1000000
-- links the state table with this module
local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        reactionState = tableInStateTable
        reactionState.unitReactionsCount = reactionState.unitReactionsCount or {}
        reactionState.lastReactionCountReset = reactionState.lastReactionCountReset or 
        {[0]={turn=-hugeNumber,tribeID=0},[1]={turn=-hugeNumber,tribeID=0},[2]={turn=-hugeNumber,tribeID=0},[3]={turn=-hugeNumber,tribeID=0},[4]={turn=-hugeNumber,tribeID=0},[5]={turn=-hugeNumber,tribeID=0},[6]={turn=-hugeNumber,tribeID=0},[7]={turn=-hugeNumber,tribeID=0},}
        unitReactionsCount = reactionState.unitReactionsCount
        lastReactionCountReset = reactionState.lastReactionCountReset
    else
        error("linkState: linkState takes a table as an argument.")
    end
end
reactionBase.linkState = linkState


-- clears the reaction count for the tribe's units
-- if force == true, then this is done regardless of whether it has
-- been at least a turn since it was last done
local function clearReactionsIfNecessary(tribe,force)
    local currentTurn = civ.getTurn()
    local currentActiveTribe = civ.getCurrentTribe()
    local lastClearedTurn = lastReactionCountReset[tribe.id].turn
    local lastClearedActiveTribeID = lastReactionCountReset[tribe.id].tribeID
    if (not force) and (currentTurn-lastClearedTurn == 0 or 
        (currentTurn-lastClearedTurn == 1 and lastClearedActiveTribeID > currentActiveTribe.id)) then
        -- the tribe's combat was cleared less than 1 turn ago, so don't clear it again
        return
    end
    for unitID,value in pairs(unitReactionsCount) do
        if (not(civ.getUnit(unitID))) or (civ.getUnit(unitID) and civ.getUnit(unitID).owner == tribe) then
            unitReactionsCount[unitID] = nil
        end
    end
    lastReactionCountReset[tribe.id].turn = currentTurn
    lastReactionCountReset[tribe.id].tribeID = currentActiveTribe.id
end
reactionBase.clearReactionsIfNecessary = clearReactionsIfNecessary
    
local function getReactionsMade(unit)
    clearReactionsIfNecessary(unit.owner,false)
    return unitReactionsCount[unit.id] or 0
end

reactionBase.getReactionsMade = getReactionsMade

-- adds one to a unit's reaction count, unless increment is specified, in which 
-- case, add the increment
local function incrementReactions(unit,increment)
    increment = increment or 1
    unitReactionsCount[unit.id] = (unitReactionsCount[unit.id] or 0)+increment
end
reactionBase.incrementReactions = incrementReactions

-- computes the expected remaining hitpoints after an attack with a given probability
-- and damage schedule is applied to the trigger unit
--
local function expectedRemainingHitpoints(triggerUnit,hitProbability,damageSchedule)
    local keyList = {}
    local index = 1
    for key,__ in pairs(damageSchedule) do
        keyList[index] = key
        index = index+1
    end
    table.sort(keyList)
    local currentHP = triggerUnit.hitpoints
    -- begin computing the expectation with the 'miss' result
    local expectedHP = (1-hitProbability)*currentHP
    -- compute each damage probability in the damage schedule
    for i=1,(index-2) do
        -- the mins and maxes ensure the computation ignores parts of the
        -- damage schedule outside the 0-1 range
        local lowerBound = math.min(math.max(keyList[i],0),1)
        local upperBound = math.min(math.max(keyList[i+1],0),1)
        expectedHP = expectedHP+(hitProbability*(upperBound-lowerBound)*damageSchedule[keyList[i]])
    end
    -- do the last boundary separately (in case a value for [1] is not specified
    local lowerBound = math.min(math.max(keyList[index-1],0),1)
    expectedHP = expectedHP+(hitProbability*(1-lowerBound)*damageSchedule[keyList[index-1]])
    return expectedHP
end
reactionBase.expectedRemainingHitpoints = expectedRemainingHitpoints
                
gen.versionFunctions(reactionBase,versionNumber,fileModified,"LuaCore".."\\".."reactionBase.lua")
return reactionBase













