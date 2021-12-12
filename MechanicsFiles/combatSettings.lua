--      combatSettings.lua
--
--  This file consists of three related parts.
--
--  The first part is the "combat calculation," which determines
--  The final attack and defense values of the units involved in combat
--  By default, this section calls upon the combatCalculator module, which 
--  was developed by Knighttime (with some changes made by me, Prof. Garfield)
--
--  The second part is the "on choose defender" event, which determines, given
--  an attacking unit, what unit will defend the tile in combat.  By default, it is set up
--  to choose the unit with defensiveStat*currentHP/maxHP (round down)
--  This seems to be the default function for choosing a defender
--      https://forums.civfanatics.com/threads/defending-unit-choice.667673/
--  The actual default choice function is not used here, to take into account a modified combat calculator
--
--  The last part of this file is the "on initiate combat" event, which actually governs
--  how combat works.  If you want to stop combat early, for example, you would do it in this section.
--  It is also the place where you can change the way combat behaves.

local register = {}
local gen = require("generalLibrary")
--
local combatCalculator = require("combatCalculator")




--      combat calculation
--  Here, you can modify the combat statistics of units
--  By default, an implementation of the standard combat calculator is used
--  The combatModifier table has the following keys:
--[[
Modifiers that can be disabled by setting their value to "1" (the numeric value, without quotes):
	aVeteran
	aPartisans
	aParadrop
	aSneakAttack
	aEasiestLevelHumanAttacker
	aEasyLevelsHumanDefender
	aBarbarianAttackerVsHumanDefender
	aBarbarianAttackerVsAiDefender
	aBarbarianAttackerVsDefendersOnlyCity
	aBarbarianAttackerVsDefendersCapitalCity
	aBarbarianAttackerVsDefenderWithGreatWall
	aGreatWallVsBarbarianDefender
	aFirepowerCaughtInPort
	dVeteran
	dScramblingFighterVsBomber
	dScramblingFighterVsFighter
	dHelicopter
	dCityWalls
	dFortress
	dFortified
	dPikemenFlag
	dAegisFlagVsMissile
	dAegisFlagVsOtherAir
	dSdiDefenseVsMissile
	dSamMissileBattery
	dCoastalFortress
	dBarbarianDefenderArchers
	dBarbarianDefenderLegion

Modifiers that can be disabled by setting their value to "false" (the boolean value, without quotes):
	aMovesRemainingCheck
	aFirepowerShoreBombardmentCheck
	dBaseTerrainCheck
	dFirepowerHelicopterCheck
	dFirepowerShoreBombardmentCheck
	dFirepowerCaughtInPortCheck
	dFirepowerSubmarineFlagCheck

Modifiers that can be disabled by setting their value to "0" (the numeric value, without quotes):
	dRiverAddition
]]

-- These modifiers can be overridden by setting assigning a value to the same key in
-- the table combatModifierOverride.
--
-- By default, the modifiers use the standard Civ II value, or read the value from the active
-- rules.txt file in the scenario's folder.  If you wish to change these values on a more permanent
-- basis (until the scenario is loaded again -- treat as an 'ephemeral' TOTPP setting),
-- use the function
-- combatCalculator.setCombatModifier(modifierKey,value), e.g.
-- combatCalculator.setCombatModifier("dCityWalls",2)
--
-- You can also check the modifier's value by using
-- combatCalculator.getCombatModifier(modifierKey)
--
-- You can reset all the values by using
-- combatCalculator.initializeCombatModifiers()

-- In addition to the combat modifier keys, six additional keys can
-- be added to combatModifierOverride to change values
-- These can be used to add extra bonuses or penalties based on your own logic
--      aCustomAdd -- add this to attack before multipliers are applied (negative number to subtract,
--                              attack will be set to 1 if this would set it lower)
--      dCustomAdd -- add this to defense before multipliers are applied (negative number to subract,
--                              defense will be set to 0 if this would set it lower)
--      aCustomMult -- multiply the attacker's strength by this much (to supply a custom bonus or penalty)
--      dCustomMult -- multiply the defender's strength by this much (to supply a custom bonus or penalty)
--      aAddFirepower -- add this to the attacker's firepower before any other calculations (negative number to
--                          subtract, but min firepower will be 1)
--      dAddFirepower -- add this to the defender's firepower before any other calculations (negative number to
--                          subtract, but min firepower will be 1)

local function computeCombatStatistics(attacker, defender, isSneakAttack)
    
    local combatModifierOverride = {}


	local attackerStrength, attackerFirepower, defenderStrength, defenderFirepower,
		   attackerStrengthModifiersApplied, attackerFirepowerModifiersApplied, 
           defenderStrengthModifiersApplied, defenderFirepowerModifiersApplied
                = combatCalculator.getCombatValues(attacker,defender, isSneakAttack,combatModifierOverride)
	
    -- if you want to do something after the standard computations, you can do it here

    -- if you need to log modifiers for debugging, set this to true
    if false then
        print(attackerStrengthModifiersApplied)
        print(attackerFirepowerModifiersApplied)
        print(defenderStrengthModifiersApplied)
        print(defenderFirepowerModifiersApplied)
    end

    return attackerStrength, attackerFirepower, defenderStrength, defenderFirepower
end




-- register.onChooseDefender
--Registers a function that is called every time a unit is chosen to defend a tile.
--The first parameter is the default function as implemented by the game.
--It takes `tile` and `attacker` as parameters. You can call this to produce a 
--result for cases you don't need to handle yourself. The second parameter 
--is the tile that's being considered, the third is the attacking unit, and the 
--fourth, `isCombat`, is a boolean that indicates if this invocation will be 
--followed by combat. This function is also called by the AI to determine its 
--goals, in which case `isCombat` is false.

function register.onChooseDefender(defaultFunction,tile,attacker,isCombat)
    local bestDefenderValue = -math.huge
    local bestDefender = nil
    for possibleDefender in tile.units do
        local attackerStrength, attackerFirepower, defenderStrength, defenderFirepower
            = computeCombatStatistics(attacker,possibleDefender,false)
        local defenderValue = defenderStrength*possibleDefender.hitpoints//possibleDefender.type.hitpoints
        if defenderValue > bestDefenderValue or 
            (defenderValue == bestDefenderValue and possibleDefender.id < bestDefender.id) then
            bestDefenderValue = defenderValue
            bestDefender = possibleDefender
        end
    end
    return bestDefender
    --return defaultFunction(tile,attacker)
end


function register.onInitiateCombatMakeCoroutine(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower,isSneakAttack)

    local maxCombatRounds = math.huge -- If you want to limit combat to a specific number of
                                        -- turns, set this variable

    local calculatedAttackerStrength, 
            calculatedAttackerFirepower,
            calculatedDefenderStrength, 
            calculatedDefenderFirepower = computeCombatStatistics(attacker,defender,isSneakAttack)
    --if calculatedAttackerStrength ~= attackerDie then
    --    civ.ui.text("Attacker: calculated: "..calculatedAttackerStrength.." actual: "..attackerDie)
    --end
    --if calculatedDefenderStrength ~= defenderDie then
    --    civ.ui.text("Defender: calculated: "..calculatedDefenderStrength.." actual: "..defenderDie)
    --end
    --if calculatedAttackerFirepower ~= attackerPower then
    --    civ.ui.text("AttackerFP: calculated: "..calculatedAttackerFirepower.." actual: "..attackerPower)
    --end
    --if calculatedDefenderFirepower ~= defenderPower then
    --    civ.ui.text("DefenderFP: calculated: "..calculatedDefenderFirepower.." actual: "..defenderPower)
    --end
    return coroutine.create(function()
        local round = 0
        while(round < maxCombatRounds and attacker.hitpoints >0 and defender.hitpoints > 0) do

            if false then
                -- If the coroutine yields true as its first value, 
                -- the game's default combat resolution is skipped for that round 
                -- and the designer is responsible for updating damage. 
                -- The second value yielded is either the attacker or the defender, 
                -- this is used to render animations etc. 
                -- In this case the coroutine resumes without any values.

                coroutine.yield(true,defender)
            else

                --If the coroutine yields false as its first value, 
                --the game runs its default combat algorithm. The designer 
                --can additionally yield modified values for attackerDie, 
                --attackerPower, defenderDie and defenderPower (in this order) 
                --which will be used by the game for that round.

                local newAttackerDie = calculatedAttackerStrength
                local newAttackerFirepower = calculatedAttackerFirepower
                local newDefenderDie = calculatedDefenderStrength
                local newDefenderFirepower = calculatedDefenderFirepower
                local result = coroutine.yield(false,newAttackerDie,newAttackerFirepower,defenderDie,newDefenderFirepower)

                --In this case the coroutine resumes with the result of the round, 
                --a table containing four values:
                    -- winner, this is either attacker or defender.
                    -- attackerRoll, the result of the attacker's die roll
                    -- defenderRoll, the result of the defender's die roll
                    -- reroll, true if a reroll happened. This can happen only 
                         -- if the attacker is tribe 0, the defender is a unit 
                         -- guarding a city, and the city is the capital or 
                         -- the tribe has less than 8 cities in total and 
                         -- the attacker's die roll is higher than the 
                         -- defender's. A reroll can happen at most once.


            end
            round = round+1
        end
        -- once we get here, combat stops
    end)
end


return register
