
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

local gen = require("generalLibrary")
-- attackBonus = require("attackBonus")
--
-- ============================================================================
-- 
-- simpleAttackBonus(activeUnit,simpleAttackBonusTable,defaultAttackTable)-->nil
-- 
-- only one bonus applies
--
-- =============================================================================
--
--
--
-- defaultAttackTable[unitType.id]=integer
-- gives the attack value of the unit type without a bonus. Only necessary for
-- units that might receive a bonus, but no problem if all use it
--
--simpleAttackBonusTable[activeUnit.type.id] ={[bonusUnitType.id]=bonusNumber}
--simpleAttackBonusTable.type = string
--if simpleAttackBonusTable.type == "addbonus" then
-- add the bonusNumber to the base attack
--if simpleAttackBonusTable.type == "addpercent"
-- add bonusNumber percent to the unit's attack
-- i.e. attack 6, bonusNumber 50, new attack 9
--if simpleAttackBonusTable.type == "addfraction"
-- add the fraction of the attack value to the attack,
-- i.e. attack 6, bonusNumber 0.5, new attack 9
-- if simpleAttackBonusTable.type == "multiplypercent" then
-- multiply the unit's attack by the bonusNumber precent
-- i.e. attack 6, bonusNumber 150, new attack 9
-- if simpleAttackBonusTable.type == "multiply" then
-- multiply the unit's attack by bonusNumber
-- i.e. attack 6, bonusNumber 1.5, new attack 9
--simpleAttackBonusTable.round = "up" or "down" or "standard" or nil
-- nil means "standard"
-- "up" means a fractional attack value after a bonus is rounded up
-- "down" means a fractional attack value after a bonus is rounded down
-- "standard" means a fractional attack value is rounded down
-- if fraction part is less than 0.5, and rounded up otherwise

-- usage:
-- local function doOnActivateUnit(unit,source)
--      attackBonus.simpleAttackBonus(unit,simpleAttackBonusTable,defaultAttackTable)
--  end

local function simpleAttackBonus(activeUnit,simpleAttackBonusTable,defaultAttackTable)
    -- reset all unit attack values
    for unitTypeID,attackValue in pairs(defaultAttackTable) do
        civ.getUnitType(unitTypeID).attack = attackValue
    end
    local unitBonusTable = simpleAttackBonusTable[activeUnit.type.id]
    if not unitBonusTable then
        -- unitBonusTable is nil (or false), so the active unit can't
        -- get a bonus
        return
    end
    -- find the best bonus. For all bonus types, the bonus will be greater than 0, 
    -- and for all bonus types, a larger number means a better bonus
    local bestBonusSoFar = 0
    for unit in activeUnit.location.units do
        if unit ~= activeUnit and unitBonusTable[unit.type.id] and 
			unitBonusTable[unit.type.id] > bestBonusSoFar then
            bestBonusSoFar = unitBonusTable[unit.type.id]
        end
    end
    if bestBonusSoFar == 0 then
        -- If no bonus unit is found, this will be true, so do nothing else
        return
    end
    -- set the new attack and return
    if string.lower(simpleAttackBonusTable.type) == "addbonus" then
        activeUnit.type.attack = activeUnit.type.attack+bestBonusSoFar
        return
    end
    local attackMultiplier = 1
    if type(simpleAttackBonusTable.type) ~= "string" then
        error([[simpleAttackBonus: simpleAttackBonusTable.type should be a string with
                one of the following values: "addbonus", "addpercent", "addfraction", "multiplypercent"
                or "multiply".  Actual value is ]]..tostring(simpleAttackBonusTable.type))
    elseif string.lower(simpleAttackBonusTable.type) == "addpercent" then
        attackMultiplier = (100+bestBonusSoFar)/100
    elseif string.lower(simpleAttackBonusTable.type) == "addfraction" then
        attackMultiplier = 1+bestBonusSoFar
    elseif string.lower(simpleAttackBonusTable.type) == "multiplypercent" then
        attackMultiplier = bestBonusSoFar/100
    elseif string.lower(simpleAttackBonusTable.type) == "multiply" then
        attackMultiplier = bestBonusSoFar
    else
        error([[simpleAttackBonus: simpleAttackBonusTable.type should be a string with
                one of the following values: "addbonus", "addpercent", "addfraction", "multiplypercent"
                or "multiply".  Actual value is ]]..tostring(simpleAttackBonusTable.type))
    end
    -- apply the bonus and round as appropriate
    if type(simpleAttackBonusTable.round) ~= "string" then
        activeUnit.type.attack = math.floor(activeUnit.type.attack*attackMultiplier+0.5)
        return
    elseif string.lower(simpleAttackBonusTable.round) == "up" then
        activeUnit.type.attack = math.ceil(activeUnit.type.attack*attackMultiplier)
        return
    elseif string.lower(simpleAttackBonusTable.round) == "down" then
        activeUnit.type.attack = math.floor(activeUnit.type.attack*attackMultiplier)
        return
    else
        activeUnit.type.attack = math.floor(activeUnit.type.attack*attackMultiplier+0.5)
        return
    end
end


-- ============================================================================
-- 
-- categoryAttackBonus(activeUnit,categoryAttackBonusTable,defaultAttackTable)-->nil
-- 
--
-- =============================================================================
--
--
--
-- defaultAttackTable[unitType.id]=integer
-- gives the attack value of the unit type without a bonus. Only necessary for
-- units that might receive a bonus, but no problem if all use it
--
-- A "bonusCategory" is a table
-- bonusCategory = {[bonusUnitType.id]=bonusNumber, maxBonusUnits=integer or nil, nextBonusValue = fraction or nil}
-- In a bonusCategory, the value for bonusUnitType.id tells what the base bonus for that unit type is,
-- maxBonusUnits is the maximum number of units that can provide a bonus in this category,
-- nextBonusValue tells how much to reduce the bonus for each subsequent unit,
-- e.g. nextBonusValue = 0.7, and 5 units, which each have a bonusNumber=1
-- The total bonus is 1(0.7)^0+.7+(.7)(.7)+(.7)^3+(.7)^4 = 1+.7+.49+.343+.2401=2.7731
-- (which would be rounded as specified)
-- nil means nextBonusValue=1
--
-- If a unit type is in two bonus categories for the same unit, there is no guarantee that the
-- best bonus will be achieved
--
--categoryAttackBonusTable[activeUnit.type.id] =table of bonusCategory
--categoryAttackBonusTable.type = string
--if categoryAttackBonusTable.type == "addbonus" then
-- add the bonusNumber to the base attack
--if categoryAttackBonusTable.type == "addpercent"
-- add bonusNumber percent to the unit's attack
-- i.e. attack 6, bonusNumber 50, new attack 9
-- for multiple unit bonuses, add up all the percents, then compute the bonus
-- i.e. 50% bonus and 50% bonus is 100% bonus, not 125%
-- attack 6 --> attack 12
-- nextBonusValue applied directly to bonusNumber, i.e. nextBonusValue=.5 and 2 50% bonus units become 50% + 25% 
-- so attack 6 --> 10.5
--if categoryAttackBonusTable.type == "addfraction"
-- add the fraction of the attack value to the attack,
-- i.e. attack 6, bonusNumber 0.5, new attack 9
-- for multiple unit bonuses, add up the fractions, then compute the bonus
-- i.e. .5 bonus and .5 bonus is 1+.5+.5= 2x bonus, not 2.25x
-- attack 6 --> attack 12
-- nextBonusValue applied directly to bonusNumber, i.e. nextBonusValue=.5 and 2 .5 bonus units become .5+.25 
-- so attack 6 --> 10.5
-- if categoryAttackBonusTable.type == "multiplypercent" then
-- multiply the unit's attack by the bonusNumber precent
-- i.e. attack 6, bonusNumber 150, new attack 9
-- bonuses are multiplied together, i.e. 150% and 150% yields 225% of original value
-- attack 6 --> attack 13.5
-- nextBonusValue applied to bonusNumber in excess of 100, i.e. nextBonusValue=.5 2 150% bonuses become 150% and 125%
-- so attack 6 --> 11.25
-- if categoryAttackBonusTable.type == "multiply" then
-- multiply the unit's attack by bonusNumber
-- i.e. attack 6, bonusNumber 1.5, new attack 9
-- bonuses are multiplied together, i.e. 1.5 and 1.5 yields 2.25x
-- attack 6 --> attack 13.5
-- nextBonusValue applied to bonusNumber in excess of 1, i.e. nextBonusValue=.5 and two 1.5 bonuses become 1.5 and 1.25
-- so attack 6 --> 11.25
--categoryAttackBonusTable.round = "up" or "down" or "standard" or nil
-- nil means "standard"
-- "up" means a fractional attack value after a bonus is rounded up
-- "down" means a fractional attack value after a bonus is rounded down
-- "standard" means a fractional attack value is rounded down
-- if fraction part is less than 0.5, and rounded up otherwise

-- If the active unit can get a bonus, go through each category and compute the bonus for that category.
-- Then, combine the bonuses for all categories to get the overall bonus, and round the result

-- HELPER FUNCTION
-- findBestBonusInUnitStack(tile,bonusCategory,usedUnitTable) --> number or false
-- usedUnitTable is indexed by the i.d. number of units, and if the value for a unit is true,
-- then it has already been used for a bonus (and, so, is not eligible)
-- The function returns the bonus (before nextBonusValue is applied) if there is one, 
-- and marks the unit as used in the usedUnitTable
-- returns false if no unit qualifies
local function findBestBonusInUnitStack(tile,bonusCategory,usedUnitTable)
    local bestBonusSoFar = 0
    local bestUnitSoFar = nil
    -- find the best bonus. For all bonus types, the bonus will be greater than 0, 
    -- and for all bonus types, a larger number means a better bonus
    for unit in tile.units do
        if not usedUnitTable[unit.id] and bonusCategory[unit.type.id] 
            and bonusCategory[unit.type.id] > bestBonusSoFar then
            bestUnitSoFar = unit
            bestBonusSoFar = bonusCategory[unit.type.id]
        end
    end
    if bestUnitSoFar then
        usedUnitTable[bestUnitSoFar.id] = true
        return bestBonusSoFar
    else
        return false
    end
end

-- HELPER FUNCTION
-- computeCategoryBonus(activeUnit,categoryAttackBonusTable,bonusCategory,usedUnitTable)
-- Computes the bonus that the active unit will receive from this category, taking into 
-- account the type of bonus for the table
local function computeCategoryBonus(activeUnit,categoryAttackBonusTable,
										bonusCategory,usedUnitTable)
    local bonusType = string.lower(categoryAttackBonusTable.type)
    local bonusThusFar = nil
    if bonusType == "multiply" then 
        bonusThusFar = 1
    elseif bonusType == "multiplypercent" then
        bonusThusFar = 100
    else
        bonusThusFar = 0
    end
    local bonusDiscount = 1
    for i=1,(bonusCategory.maxBonusUnits or 10000) do
        local currentBonus =findBestBonusInUnitStack(activeUnit.location,
								bonusCategory,usedUnitTable) 
        if not currentBonus then
            -- no more valid bonuses for this category
            break
        end
        if bonusType == "multiply" then
            bonusThusFar = bonusThusFar*((currentBonus-1)*bonusDiscount+1)
        elseif bonusType =="multiplypercent" then
            bonusThusFar = bonusThusFar*((currentBonus-100)*bonusDiscount+100)/100
        else
            bonusThusFar = bonusThusFar+currentBonus*bonusDiscount
        end
        bonusDiscount = bonusDiscount*(bonusCategory.nextBonusValue or 1)
    end
    return bonusThusFar
end

local function categoryAttackBonus(activeUnit,categoryAttackBonusTable,defaultAttackTable)
    -- reset all unit attack values
    for unitTypeID,attackValue in pairs(defaultAttackTable) do
        civ.getUnitType(unitTypeID).attack = attackValue
    end
    local bonusInfoTable = categoryAttackBonusTable[activeUnit.type.id]
    if not bonusInfoTable then
        -- unit doesn't get a bonus
        return
    end
    -- keep track of bonuses already computed
    local bonusResultsTable = {}
    -- keep track of units that have already been "used" for a bonus
    local usedUnitTable = {[activeUnit.id]=true}
    for index,bonusCategory in pairs(bonusInfoTable) do
        bonusResultsTable[index]=computeCategoryBonus(activeUnit,
						categoryAttackBonusTable,bonusCategory,usedUnitTable)
    end
    -- compute the bonus
    local bonusType = string.lower(categoryAttackBonusTable.type)
    local resultAttackBeforeRounding = nil
    if bonusType == "multiply" then
        local bonus = 1
        for __,bonusResult in pairs(bonusResultsTable) do
            bonus = bonus*bonusResult
        end
        resultAttackBeforeRounding = activeUnit.type.attack*bonus
    elseif bonusType == "multiplypercent" then
        local bonus = 1
        for __,bonusResult in pairs(bonusResultsTable) do
            bonus = bonus*bonusResult/100
        end
        resultAttackBeforeRounding = activeUnit.type.attack*bonus
    elseif bonusType == "addbonus" then
        local bonus = 0
        for __,bonusResult in pairs(bonusResultsTable) do
            bonus = bonus+bonusResult
        end
        resultAttackBeforeRounding =activeUnit.type.attack+bonus
    elseif bonusType == "addfraction" then
        local bonus = 0
        for __,bonusResult in pairs(bonusResultsTable) do
            bonus = bonus+bonusResult
        end
        resultAttackBeforeRounding =activeUnit.type.attack*(1+bonus)
    elseif bonusType == "addpercent" then
        local bonus = 0
        for __,bonusResult in pairs(bonusResultsTable) do
            bonus = bonus+(bonusResult/100)
        end
        resultAttackBeforeRounding =activeUnit.type.attack*(1+bonus)
    else
        error("categoryAttackBonus: categoryAttackBonusTable.type is not a valid value.")
    end
    -- apply the bonus and round as appropriate
    local roundType = categoryAttackBonusTable.round
    if type(roundType) ~= "string" then
        activeUnit.type.attack = math.min(math.floor(resultAttackBeforeRounding+0.5),98)
        return
    elseif roundType == "up" then
        activeUnit.type.attack = math.min(math.ceil(resultAttackBeforeRounding),98)
        return
    elseif roundType == "down" then
        activeUnit.type.attack = math.min(math.floor(resultAttackBeforeRounding),98)
        return
    else
        activeUnit.type.attack = math.min(math.floor(resultAttackBeforeRounding+0.5),98)
        return
    end
end


-- duplicateTable(table or value) --> table or value
-- duplicates a table and all the other tables referenced in that table
-- this way, a change can be made to any element of the table,
-- and it won't impact data referenced anywhere else (unless this newly
-- created table is subsequently referenced)
-- if a non-table value is input, that value is returned
--
local function duplicateTable(input)
    if type(input) == "table" then
        -- the input value is a table, so create a new table
       local duplicatedTable={} 
        -- and copy all the indexes and values into the new table, 
        -- making sure to duplicate any tables that appear as values
        for index,value in pairs(input) do
            duplicatedTable[index]=duplicateTable(value)
        end
		return duplicatedTable
    else
        -- the input value was not a table, so we return that value
        return input
    end
end


-- plusFixed({[unitType1.id]=fixedBonus,[unitType2.id]=fixedBonus},categoryAttackBonusTable) --> void
-- changes the bonus given by unitTypeI.id to a unit to be equivalent to
-- to adding number to that unit's attack power.  If the unit doesn't receive a bonus
-- from the unitType, then it won't after applying plusFixed.
-- The value of the existing bonus is ignored.

local function plusFixed(fixedUnitBonusTable,categoryAttackBonusTable)
    local bonusType = string.lower(categoryAttackBonusTable.type)
    for bonusReceivingUnitTypeID,bonusTable in pairs(categoryAttackBonusTable) do
		if type(bonusReceivingUnitTypeID) == "number" then
			-- replace bonusTable with an equivalent table that is not referened
			-- anywhere else, so that changes to it can be made without impacting
			-- data elsewhere
			categoryAttackBonusTable[bonusReceivingUnitTypeID] = duplicateTable(bonusTable)
			-- make bonusTable refer to the "current" bonus table for the unit type
			bonusTable =categoryAttackBonusTable[bonusReceivingUnitTypeID] 
			-- For each unit type in the fixedUnitBonusTable, check if any bonus category
			-- in the bonusTable corresponds to it.  If so, make the change
			for bonusGivingUnitTypeID,fixedBonusValue in pairs(fixedUnitBonusTable) do
				-- get the attack of the unit type 
				local baseAttack = civ.getUnitType(bonusReceivingUnitTypeID).attack
				-- in each bonus category, check if the giver's unit type id is there,
				-- if so, change to the correct attack
				for bonusCategoryIndex,bonusCategory in pairs(bonusTable) do
					if bonusCategory[bonusGivingUnitTypeID] then
					-- change the bonus appropriately
						if bonusType == "addbonus" then
							bonusCategory[bonusGivingUnitTypeID]=fixedBonusValue
						elseif bonusType == "addpercent" then
							bonusCategory[bonusGivingUnitTypeID]=100*fixedBonusValue/baseAttack
						elseif bonusType == "addfraction" then
							bonusCategory[bonusGivingUnitTypeID]=fixedBonusValue/baseAttack
						elseif bonusType == "multiplypercent" then
							bonusCategory[bonusGivingUnitTypeID]=100*(fixedBonusValue+baseAttack)/baseAttack
						elseif bonusType == "multiply" then
							bonusCategory[bonusGivingUnitTypeID]=(fixedBonusValue+baseAttack)/baseAttach
						else
							error("pluxFixed: categoryAttackBonusTable.type does not have an acceptable value.")
						end
					end
				end
			end
        end
    end
end

local attackBonus = {
    simpleAttackBonus = simpleAttackBonus,
    categoryAttackBonus=categoryAttackBonus,
	plusFixed = plusFixed,
}

gen.versionFunctions(attackBonus,versionNumber,fileModified,"LuaCore".."\\".."attackBonus.lua")
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."attackBonus.lua")
return attackBonus
