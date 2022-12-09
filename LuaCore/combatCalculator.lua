

local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


-- The vast majority of the work for this module was done by Knighttime, and
-- supplied in this Civfanatics Post:
-- https://forums.civfanatics.com/threads/civilization-ii-combat-guide-v2-0-updates.673992/#post-16192594
--
-- 


local gen = require("generalLibrary"):minVersion(1)
local scenarioDirectoryFound, scenarioDirectoryOrError = pcall(gen.getScenarioDirectory)
-- gen.getScenarioDirectory() returns an error if the directory has not been set
-- pcall will therefore set scenarioDirectoryFound to false, will print a warning
-- to the console, and use default values instead
local cosmic2FromFile = {}
if scenarioDirectoryFound then
    local readRulesFound, readRules = gen.requireIfAvailable("readRules")
    -- if the readRules module is not found, print a warning to the console,
    -- and use default values for cosmic 2
    if readRulesFound then
        local loadedRules = readRules.loadedRules
        cosmic2FromFile = loadedRules["@COSMIC2"] or {} -- if there is no @COSMIC2 Section, need an empty table
    else
        print("WARNING: combatCalculator.lua did not find the readRules.lua module, so default values for @COSMIC2 are being used instead.")
    end

else
    print("WARNING: combatCalculator.lua: the generalLibrary does not have a scenario directory set.  Therefore, no attempt to use the readRules.lua module has been made, and default values for @COSMIC2 are being used instead.  gen.setScenarioDirectory(directoryString) can be used to set the scenario directory, if that is desired.")

end


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


-- ==================================================================
--  LOCAL VARIABLES AND INITIALIZATION 
-- ==================================================================



-- this provides a list of @COSMIC2 keys related to defense, and converts
--  them form all lower case to 'regular' case to facilitate
--  reading from rules.txt

local cosmic2DefenseKeysToRegularCase = {}
cosmic2DefenseKeysToRegularCase["fortifydefense"]="FortifyDefense"
cosmic2DefenseKeysToRegularCase["fortressdefense"]="FortressDefense"
cosmic2DefenseKeysToRegularCase["citywallsdefense"]="CityWallsDefense"
cosmic2DefenseKeysToRegularCase["coastalfortressdefense"]="CoastalFortressDefense"
cosmic2DefenseKeysToRegularCase["aegisvsairdefense"]="AegisVSAirDefense"
cosmic2DefenseKeysToRegularCase["aegisvsmissiledefense"]="AegisVSMissileDefense"
cosmic2DefenseKeysToRegularCase["samdefense"]="SAMDefense"
cosmic2DefenseKeysToRegularCase["sdidefense"]="SDIDefense"
cosmic2DefenseKeysToRegularCase["terraindefenseforair"] ="TerrainDefenseForAir"
cosmic2DefenseKeysToRegularCase["terraindefenseforsea"] ="TerrainDefenseForSea"




-- This table needs to be populated with the corresponding values exactly as entered in the @COSMIC2 section of Rules.txt,
--		or automatically read from that file.
-- If the cosmic2 table is created and populated *after* this file is read, then the initializeCombatModifiers() function
--		should be called again, immediately afterwards, in order for the values there to take effect in the combat calculations.

local cosmic2 = {
	AegisVSAirDefense = nil,
	AegisVSMissileDefense = nil,
	CityWallsDefense = nil,
	CoastalFortressDefense = nil,
	FortifyDefense = nil,
	FortressDefense = nil,
	SAMDefense = nil,
	SDIDefense = nil, --
	TerrainDefenseForAir = nil,
	TerrainDefenseForSea = nil
}

-- read the @COSMIC2 section from the rules, and copy relevant portions
-- to the cosmic2 table.  If rules were not read, cosmic2FromFile will
-- be an empty table, so nothing will happen
-- console.c2 = cosmic2FromFile

for lineNumber,columnTable in pairs(cosmic2FromFile) do
    if type(columnTable[0]) == "string" and cosmic2DefenseKeysToRegularCase[string.lower(columnTable[0])] then
        cosmic2[cosmic2DefenseKeysToRegularCase[string.lower(columnTable[0])]] = tonumber(columnTable[1])
    end
end

-- Copied from civlua.lua (not needed if that file is already being imported):
local domain = {ground = 0, air = 1, sea = 2}

local combatModifier = { }
-- All of these initial values in the combatModifier table can be overridden dynamically by calling setCombatModifier().
-- 		See notes prior to that function below.
local function initializeCombatModifiers () --> void

-- ATTACKING UNIT STRENGTH MODIFIERS:
	combatModifier.aConstant = 8
	combatModifier.aMovesRemainingCheck = true
	combatModifier.aVeteran = 1.5
	combatModifier.aPartisans = 8
	combatModifier.aParadrop = 1.5
	combatModifier.aSneakAttack = 2
	combatModifier.aEasiestLevelHumanAttacker = 2
	combatModifier.aEasyLevelsHumanDefender = 0.5
	combatModifier.aBarbarianAttackerVsHumanDefender = 0.25 * (civ.game.difficulty + 1)
	combatModifier.aBarbarianAttackerVsAiDefender = 0.5
	combatModifier.aBarbarianAttackerVsDefendersOnlyCity = 0
	combatModifier.aBarbarianAttackerVsDefendersCapitalCity = 0.5
	combatModifier.aBarbarianAttackerVsDefenderWithGreatWall = 0.5
	combatModifier.aGreatWallVsBarbarianDefender = 2
	
-- ATTACKING UNIT FIREPOWER MODIFIERS:
	combatModifier.aFirepowerShoreBombardmentCheck = true
	combatModifier.aFirepowerCaughtInPort = 2
	
-- DEFENDING UNIT STRENGTH MODIFIERS:
	combatModifier.dConstant = 8
	combatModifier.dVeteran = 1.5
	combatModifier.dScramblingFighterVsBomber = 4
	combatModifier.dScramblingFighterVsFighter = 2
	combatModifier.dHelicopter = 0.5
	combatModifier.dCityWalls = 3
		if cosmic2 ~= nil and cosmic2.CityWallsDefense ~= nil then
			combatModifier.dCityWalls = cosmic2.CityWallsDefense / 2
		end
	combatModifier.dFortress = 2
		if cosmic2 ~= nil and cosmic2.FortressDefense ~= nil then
			combatModifier.dFortress = cosmic2.FortressDefense / 2
		end
	combatModifier.dFortified = 1.5
		if cosmic2 ~= nil and cosmic2.FortifyDefense ~= nil then
			combatModifier.dFortified = cosmic2.FortifyDefense / 2
		end
	combatModifier.dPikemenFlag = 1.5
	combatModifier.dAegisFlagVsMissile = 5
		if cosmic2 ~= nil and cosmic2.AegisVSMissileDefense ~= nil then
			combatModifier.dAegisFlagVsMissile = cosmic2.AegisVSMissileDefense / 2
		end
	combatModifier.dAegisFlagVsOtherAir = 3
		if cosmic2 ~= nil and cosmic2.AegisVSAirDefense ~= nil then
			combatModifier.dAegisFlagVsOtherAir = cosmic2.AegisVSAirDefense / 2
		end
	combatModifier.dSdiDefenseVsMissile = 2
		if cosmic2 ~= nil and cosmic2.SDIDefense ~= nil then
			combatModifier.dSdiDefenseVsMissile = cosmic2.SDIDefense / 2
		end
	combatModifier.dSamMissileBattery = 2
		if cosmic2 ~= nil and cosmic2.SAMDefense ~= nil then
			combatModifier.dSamMissileBattery = cosmic2.SAMDefense / 2
		end
	combatModifier.dCoastalFortress = 2
		if cosmic2 ~= nil and cosmic2.CoastalFortressDefense ~= nil then
			combatModifier.dCoastalFortress = cosmic2.CoastalFortressDefense / 2
		end
	combatModifier.dBaseTerrainCheck = true
	combatModifier.dRiverAddition = 0.5
	combatModifier.dBarbarianDefenderArchers = 0.5
	combatModifier.dBarbarianDefenderLegion = 0.5
	
-- DEFENDING UNIT FIREPOWER MODIFIERS:
	combatModifier.dFirepowerHelicopterCheck = true
	combatModifier.dFirepowerShoreBombardmentCheck = true
	combatModifier.dFirepowerCaughtInPortCheck = true
	combatModifier.dFirepowerSubmarineFlagCheck = true
end
-- The above function must run immediately upon file initialization, but it can also be called later at any point.
-- For example, if the cosmic2 table is created and populated *after* this file is read, initializeCombatModifiers() should be called again.
-- Another example: if your code has made multiple calls to setCombatModifier() that you want to "undo", rather than
--		resetting each modifier individually, you can call initializeCombatModifiers() to reset all modifiers to their default values.
initializeCombatModifiers()

local defaultCombatModifier = combatModifier -- this line allows me to use combatModifier as a local
                        -- variable in getCombatValues, so I don't have to rename stuff (Prof. Garfield)


-- ========================================================
--  INTERNAL HELPER FUNCTION 
-- ========================================================
local function knownByAnyHuman (tech) --> boolean
	local result = false
	for i = 1, 7 do
		local tribe = civ.getTribe(i)
		if tribe ~= nil and tribe.active and tribe.isHuman then
			if civ.hasTech(tribe, tech) then
				result = true
			end
		end
	end
	return result
end



-- ==============================================================
--  EXTERNALLY AVAILABLE FUNCTIONS 
-- ==============================================================
local function getCombatModifier (modifierName) --> decimal or boolean
	return combatModifier[modifierName]
end

-- All of the initial values in the combatModifier table can be overridden dynamically by calling setCombatModifier().
-- Note that any values you provide should be the *exact* modifier which will be applied (unlike values provided via the @COSMIC2 section
--		of Rules.txt, which are multiplied by 50% before being applied).  Decimal values are permitted.
-- As listed in the comment at the top of this file, values are *multiplicative* so an event can disable an individual modifier entirely
--		by setting its value to 1. Modifiers which are initialized to boolean "true" can be disabled by setting them to "false". There is
--		no ability to adjust the *effect* of these modifiers if they are set to "true". 'dRiverAddition' is an *additive* bonus, so its
--		value must be set to 0 (not 1) in order to disable it.
-- Example: utilCombat.setCombatModifier("dCityWalls", 2)
--		The above example line will reduce the City Walls defensive bonus from its default value of x3 to a value of x2 (the same as a Fortress).
local function setCombatModifier (modifierName, value) --> void
	combatModifier[modifierName] = value
end

-- Credit to http://www.civfanatics.com/civ2/strategy/combatguide and especially to TheNamelessOne
-- combatModifierOverride is an optional argument can have the same keys as the combatModifier table
--  any supplied keys will override the combatModifier values for the current calculation only
--      the following seven modifiers are also available
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
--      dTerrainDefenseValue -- overrides the terrain defense bonus (normally calculated by baseTerrain.defense/2) 
--
local function getCombatValues (attacker, defender, isSneakAttack,combatModifierOverride) --> 4 integers, followed by 4 (informational-only) strings:
		-- attackerStrength, attackerFirepower, defenderStrength, defenderFirepower,
		-- attackerStrengthModifiersApplied, attackerFirepowerModifiersApplied, defenderStrengthModifiersApplied, defenderFirepowerModifiersApplied

    combatModifierOverride = combatModifierOverride or {}
    -- since combatModifier might be modified, the defaultCombatModifier table
    -- must be duplicated using gen.copyTable
    local combatModifier = gen.copyTable(defaultCombatModifier)
    for key,value in pairs(combatModifier) do
        if combatModifierOverride[key] ~= nil then
            combatModifier[key] = combatModifierOverride[key]
        end
    end
    -- I don't remember if there was a reason for the above loop to pair over combatModifier
    -- instead of combatModifierOverride, so I add this check here
    -- Standard behaviour happens when dTerrainDefenseValue is nil
    if combatModifierOverride.dTerrainDefenseValue then
        combatModifier.dTerrainDefenseValue = combatModifierOverride.dTerrainDefenseValue
    end
    
	local attackerStrengthModifiersApplied = ""
	local attackerFirepowerModifiersApplied = ""
	local defenderStrengthModifiersApplied = ""
	local defenderFirepowerModifiersApplied = ""

	local attackerStrength = attacker.type.attack
    -- custom addition to attack strength
    if combatModifierOverride.aCustomAdd then
        attackerStrength = attackerStrength + combatModifierOverride.aCustomAdd
        attackerStrengthModifiersApplied = attackerStrengthModifiersApplied.."attackerCustomAdd "..tostring(combatModifierOverride.aCustomAdd).." to get "..tostring(attackerStrength)..", "
        if attackerStrength < 1 then
            attackerStrength = 1
            attackerStrengthModifiersApplied = attackerStrengthModifiersApplied.."applyMinAttackStrength = 1, "
        end
    end
    attackerStrength = attackerStrength * combatModifier.aConstant
	local attackerFirepower = attacker.type.firepower

    -- custom addition to attacker's firepower
    if combatModifierOverride.aAddFirepower then
        attackerFirepower = math.floor(attackerFirepower + combatModifierOverride.aAddFirepower)
        attackerFirepowerModifiersApplied = attackerFirepowerModifiersApplied.."attackerAddFirepower "..tostring(combatModifierOverride.aAddFirepower).." to get "..tostring(attackerFirepower)..", "
        if attackerFirepower < 1 then
            attackerFirepower = 1
            attackerFirepowerModifiersApplied = attackerFirepowerModifiersApplied.."applyMinFirepower = 1, "
        end
    end

	local defenderStrength = defender.type.defense 

    -- custom addition to defense strength
    if combatModifierOverride.dCustomAdd then
        defenderStrength = defenderStrength + combatModifierOverride.dCustomAdd
        defenderStrengthModifiersApplied = defenderStrengthModifiersApplied.."defenderCustomAdd "..tostring(combatModifierOverride.dCustomAdd).." to get "..tostring(defenderStrength)..", "
        if defenderStrength < 0 then
            defenderStrength = 0
            defenderStrengthModifiersApplied = defenderStrengthModifiersApplied.."applyMinDefenseStrength = 0, "
        end
    end
	defenderStrength = defenderStrength * combatModifier.dConstant
	local defenderFirepower = defender.type.firepower

    -- custom addition to defender firepower
    if combatModifierOverride.dAddFirepower then
        defenderFirepower = math.floor(defenderFirepower + combatModifierOverride.dAddFirepower)
        defenderFirepowerModifiersApplied = defenderFirepowerModifiersApplied.."defenderAddFirepower "..tostring(combatModifierOverride.dAddFirepower).." to get "..tostring(defenderFirepower)..", "
        if defenderFirepower < 1 then
            defenderFirepower = 1
            defenderFirepowerModifiersApplied = defenderFirepowerModifiersApplied.."applyMinFirepower = 1, "
        end
    end
	

-- ATTACKING UNIT STRENGTH MODIFIERS:

	-- 1. Insufficient moves remaining:
	if combatModifier.aMovesRemainingCheck then
		local attackerMovesRemainingPriorToAttack = (gen.moveRemaining(attacker) + totpp.movementMultipliers.aggregate) / totpp.movementMultipliers.aggregate
		if attackerMovesRemainingPriorToAttack < 1 then
			-- Tiny fraction in the next formula is to prevent rounding errors, since movement may use a denominator which does not divide evenly:
			attackerStrength = (attackerStrength * attackerMovesRemainingPriorToAttack) + 0.00000001
			attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "insufficientMovesRemaining x" .. tostring(attackerMovesRemainingPriorToAttack) .. ", "
		end
	end
	-- 2. Veteran:
	if attacker.veteran then
		attackerStrength = attackerStrength * combatModifier.aVeteran
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "veteran x" .. combatModifier.aVeteran .. ", "
	end
	-- 3. Partisans:
	if attacker.type == gen.original.uPartisans and defender.type.attack == 0 then
		attackerStrength = attackerStrength * combatModifier.aPartisans
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "partisans x" .. combatModifier.aPartisans .. ", "
	end
	-- 4. Paradrop:
	if gen.isParadropped(attacker) then
		attackerStrength = attackerStrength * combatModifier.aParadrop
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "paradrop x" .. combatModifier.aParadrop .. ", "
	end
	-- 5. Sneak attack:
	-- Note: This must be passed in as a parameter because it's too late to analyze the treaty statuses once onInitiateCombat() begins;
	--		 a cease fire or peace treaty that did exist will already show as canceled at that point.
	if defender.owner.isHuman and isSneakAttack then
		attackerStrength = attackerStrength * combatModifier.aSneakAttack
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "sneakAttack x" .. combatModifier.aSneakAttack .. ", "
	end
	-- 6. Easiest level, human attacker:
	if attacker.owner.isHuman and civ.game.difficulty == 0 then
		attackerStrength = attackerStrength * combatModifier.aEasiestLevelHumanAttacker
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "easiestLevelHumanAttacker x" .. combatModifier.aEasiestLevelHumanAttacker .. ", "
	end
	-- 7. Easy levels, human defender:
	if defender.owner.isHuman and civ.game.difficulty <= 1 then
		attackerStrength = attackerStrength * combatModifier.aEasyLevelsHumanDefender
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "easyLevelsHumanDefender x" .. combatModifier.aEasyLevelsHumanDefender .. ", "
	end
	-- 8. Barbarian attacker vs.:
	if attacker.owner.id == 0 then
		-- 8a. Human defender:
		if defender.owner.isHuman then
			attackerStrength = attackerStrength * combatModifier.aBarbarianAttackerVsHumanDefender
			attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "barbarianAttackerVsHumanDefender x" .. combatModifier.aBarbarianAttackerVsHumanDefender .. ", "
		end
		-- 8b. AI defender:
		if defender.owner.isHuman == false then
			attackerStrength = attackerStrength * combatModifier.aBarbarianAttackerVsAiDefender
			attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "barbarianAttackerVsAiDefender x" .. combatModifier.aBarbarianAttackerVsAiDefender .. ", "
		end
		-- 8c. Defender's only city:
		if defender.location.city ~= nil and defender.owner.numCities == 1 then
			attackerStrength = attackerStrength * combatModifier.aBarbarianAttackerVsDefendersOnlyCity
			attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "barbarianAttackerVsDefendersOnlyCity x" .. combatModifier.aBarbarianAttackerVsDefendersOnlyCity .. ", "
		end
		-- 8d. Defender's capital city:
		if defender.location.city ~= nil and defender.owner.numCities > 1 and civ.hasImprovement(defender.location.city, gen.original.iPalace) then
			attackerStrength = attackerStrength * combatModifier.aBarbarianAttackerVsDefendersCapitalCity
			attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "barbarianAttackerVsDefendersCapitalCity x" .. combatModifier.aBarbarianAttackerVsDefendersCapitalCity .. ", "
		end
		-- 8e. Defender with Great Wall:
		if gen.isWonderActiveForTribe(gen.original.wGreatWall, defender.owner) then
			attackerStrength = attackerStrength * combatModifier.aBarbarianAttackerVsDefenderWithGreatWall
			attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "barbarianAttackerVsDefenderWithGreatWall x" .. combatModifier.aBarbarianAttackerVsDefenderWithGreatWall .. ", "
		end
	end
	-- 9. Great Wall vs. barbarian defender:
	if gen.isWonderActiveForTribe(gen.original.wGreatWall, attacker.owner) and defender.owner.id == 0 then
		attackerStrength = attackerStrength * combatModifier.aGreatWallVsBarbarianDefender
		attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "greatWallVsBarbarianDefender x" .. combatModifier.aGreatWallVsBarbarianDefender .. ", "
	end

    -- attacker custom multiplier
    if combatModifierOverride.aCustomMult then
        attackerStrength = attackerStrength * combatModifierOverride.aCustomMult
        attackerStrengthModifiersApplied = attackerStrengthModifiersApplied .. "attackerCustomMultiplier x" ..tostring(combatModifierOverride.aCustomMult) .. ", "
    end
	attackerStrength = math.floor(attackerStrength)
	
-- ATTACKING UNIT FIREPOWER MODIFIERS:
	
	-- 1. Shore bombardment:
	if combatModifier.aFirepowerShoreBombardmentCheck then
		if attacker.type.domain == domain.sea and defender.type.domain == domain.ground then
			attackerFirepower = 1
			attackerFirepowerModifiersApplied = attackerFirepowerModifiersApplied .. "shoreBombardment =1, "
		end
	end
	-- 2. Caught in port:
	if (attacker.type.domain == domain.ground or attacker.type.domain == domain.air) and defender.type.domain == domain.sea and defender.location.baseTerrain.type ~= 10 then
		attackerFirepower = attackerFirepower * combatModifier.aFirepowerCaughtInPort
		attackerFirepowerModifiersApplied = attackerFirepowerModifiersApplied .. "shipCaughtInPort x" .. combatModifier.aFirepowerCaughtInPort .. ", "
	end
	attackerFirepower = math.floor(attackerFirepower)

-- DEFENDING UNIT STRENGTH MODIFIERS:

	-- 1. Veteran:
	if defender.veteran then
		defenderStrength = defenderStrength * combatModifier.dVeteran
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "veteran x" .. combatModifier.dVeteran .. ", "
	end
	-- 2. Scrambling fighter vs bomber:
	if attacker.type.domain == domain.air and attacker.type.range ~= 1 and defender.type.domain == domain.air and defender.location.city ~= nil and gen.isAttackAir(defender.type) then
		defenderStrength = defenderStrength * combatModifier.dScramblingFighterVsBomber
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "scramblingFighterVsBomber x" .. combatModifier.dScramblingFighterVsBomber .. ", "
	end
	-- 3. Scrambling fighter vs fighter:
	if gen.isAttackAir(attacker.type) and defender.type.domain == domain.air and defender.location.city ~= nil and gen.isAttackAir(defender.type) then
		defenderStrength = defenderStrength * combatModifier.dScramblingFighterVsFighter
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "scramblingFighterVsFighter x" .. combatModifier.dScramblingFighterVsFighter .. ", "
	end
	-- 4. Helicopter:
	if attacker.type.role == 3 and defender.type.domain == domain.air and defender.type.range == 0 then
		defenderStrength = defenderStrength * combatModifier.dHelicopter
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "helicopter x" .. combatModifier.dHelicopter .. ", "
	end
	-- 5. These next 3 bonuses do not stack; only the first match applies:
	-- 5a. City Walls:
	if attacker.type.domain == domain.ground and gen.isIgnoreWalls(attacker.type) == false and defender.type.domain == domain.ground and defender.location.city ~= nil and (civ.hasImprovement(defender.location.city, gen.original.iCityWalls) or gen.isWonderActiveForTribe(gen.original.wGreatWall, defender.owner)) then
		defenderStrength = defenderStrength * combatModifier.dCityWalls
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "cityWalls x" .. combatModifier.dCityWalls .. ", "
	-- 5b. Fortress:
	elseif attacker.type.domain ~= domain.air and gen.isIgnoreWalls(attacker.type) == false and defender.type.domain == domain.ground and defender.location.improvements & 0x42 == 0x40 then
		defenderStrength = defenderStrength * combatModifier.dFortress
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "fortress x" .. combatModifier.dFortress .. ", "
	-- 5c. Fortified:
	elseif defender.type.domain == domain.ground and defender.order & 0xFF == 0x02 then
		defenderStrength = defenderStrength * combatModifier.dFortified
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "fortified x" .. combatModifier.dFortified .. ", "
	end
	-- 6. Pikemen flag: (assumes user is running TOTPP v0.17 or higher and has the "Pikemen flag" patch enabled)
	if attacker.type.domain == domain.ground and attacker.type.move / totpp.movementMultipliers.aggregate == 2 and attacker.type.hitpoints == 10 and gen.isBonusAgainstHorse(defender.type) then
		defenderStrength = defenderStrength * combatModifier.dPikemenFlag
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "pikemenFlag x" .. combatModifier.dPikemenFlag .. ", "
	end
	-- 7. AEGIS flag vs. missile:
	if attacker.type.domain == domain.air and gen.isDestroyedAfterAttacking(attacker.type) and gen.isBonusAgainstAir(defender.type) then
		defenderStrength = defenderStrength * combatModifier.dAegisFlagVsMissile
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "aegisFlagVsMissile x" .. combatModifier.dAegisFlagVsMissile .. ", "
	end
	-- 8. AEGIS flag vs. other air:
	if attacker.type.domain == domain.air and gen.isDestroyedAfterAttacking(attacker.type) == false and gen.isBonusAgainstAir(defender.type) then
		defenderStrength = defenderStrength * combatModifier.dAegisFlagVsOtherAir
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "aegisFlagVsOtherAir x" .. combatModifier.dAegisFlagVsOtherAir .. ", "
	end
	-- 9. SDI Defense vs. missile:
	if attacker.type.domain == domain.air and gen.isDestroyedAfterAttacking(attacker.type) and defender.location.city ~= nil and civ.hasImprovement(defender.location.city, gen.original.iSDIDefense) then
		defenderStrength = defenderStrength * combatModifier.dSdiDefenseVsMissile
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "sdiDefenseVsMissile x" .. combatModifier.dSdiDefenseVsMissile .. ", "
	end
	-- 10. SAM Missile Battery:
	if attacker.type.domain == domain.air and defender.location.city ~= nil and (gen.isDestroyedAfterAttacking(attacker.type) or gen.isAttackAir(defender.type) == false) and civ.hasImprovement(defender.location.city, gen.original.iSAMMissileBattery) then
		defenderStrength = defenderStrength * combatModifier.dSamMissileBattery
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "samBattery x" .. combatModifier.dSamMissileBattery .. ", "
	end
	-- 11. Coastal Fortress:
	if attacker.type.domain == domain.sea and defender.type.domain ~= domain.sea and defender.location.city ~= nil and civ.hasImprovement(defender.location.city, gen.original.iCoastalFortress) then
		defenderStrength = defenderStrength * combatModifier.dCoastalFortress
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "coastalFortress x" .. combatModifier.dCoastalFortress .. ", "
	end
	-- 12. Terrain:
	if defender.type.domain == domain.ground or
	   (defender.type.domain == domain.air and cosmic2.TerrainDefenseForAir ~= 0) or
	   (defender.type.domain == domain.sea and cosmic2.TerrainDefenseForSea ~= 0) then
		local terrainFactor = 1
		-- 12a. Base Terrain Type:
		if combatModifier.dBaseTerrainCheck then
            if combatModifier.dTerrainDefenseValue then
                terrainFactor = combatModifier.dTerrainDefenseValue
                -- added this to make it easy to override regular terrain defense values (prof. garfield)
            else
			    terrainFactor = defender.location.baseTerrain.defense / 2
            end
		end
		-- 12b. River:
		if defender.location.river then
			terrainFactor = terrainFactor + combatModifier.dRiverAddition
		end
		defenderStrength = defenderStrength * terrainFactor
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "baseTerrainType"
		if defender.location.river then
			defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "+river"
		end
		defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. " x" .. terrainFactor .. ", "
	end
	-- 13. Barbarian defender:
	if defender.owner.id == 0 then
		-- These modifiers are not allowed to reduce the strength of the defender below 1, but due to the order in which they're actually applied
		--		that's almost impossible to happen unless the unit type already has 0 defense.
		-- 13a. Archers:
		if defender.type == gen.original.uArchers then
			defenderStrength = defenderStrength * combatModifier.dBarbarianDefenderArchers
			defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "barbarianDefenderArchers x" .. combatModifier.dBarbarianDefenderArchers .. ", "
		end
		-- 13b. Legion:
		if defender.type == gen.original.uLegion and knownByAnyHuman(gen.original.aIronWorking) == false then
			defenderStrength = defenderStrength * combatModifier.dBarbarianDefenderLegion
			defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "barbarianDefenderLegion x" .. combatModifier.dBarbarianDefenderLegion .. ", "
		end
	end
    -- defender custom multiplier
    if combatModifierOverride.dCustomMult then
        defenderStrength = defenderStrength * combatModifierOverride.dCustomMult
        defenderStrengthModifiersApplied = defenderStrengthModifiersApplied .. "defenderCustomMultiplier x" ..tostring(combatModifierOverride.dCustomMult) .. ", "
    end
	defenderStrength = math.floor(defenderStrength)
	
-- DEFENDING UNIT FIREPOWER MODIFIERS:
	
	-- 1. Helicopter:
	if combatModifier.dFirepowerHelicopterCheck then
		if attacker.type.role == 3 and defender.type.domain == domain.air and defender.type.range == 0 then
			defenderFirepower = 1
			defenderFirepowerModifiersApplied = defenderFirepowerModifiersApplied .. "helicopter =1, "
		end
	end
	-- 2. Shore bombardment:
	if combatModifier.dFirepowerShoreBombardmentCheck then
		if attacker.type.domain == domain.sea and defender.type.domain == domain.ground then
			defenderFirepower = 1
			defenderFirepowerModifiersApplied = defenderFirepowerModifiersApplied .. "shoreBombardment =1, "
		end
	end
	-- 3. Caught in port:
	if combatModifier.dFirepowerCaughtInPortCheck then
		if (attacker.type.domain == domain.ground or attacker.type.domain == domain.air) and defender.type.domain == domain.sea and defender.location.baseTerrain.type ~= 10 then
			defenderFirepower = 1
			defenderFirepowerModifiersApplied = defenderFirepowerModifiersApplied .. "caughtInPort =1, "
		end
	end
	-- 4. Submarine flag:
	if combatModifier.dFirepowerSubmarineFlagCheck then
		if gen.isSubmarine(defender.type) then
			defenderFirepower = 1
			defenderFirepowerModifiersApplied = defenderFirepowerModifiersApplied .. "submarineFlag =1, "
		end
	end
	defenderFirepower = math.floor(defenderFirepower)
	
	return attackerStrength, attackerFirepower, defenderStrength, defenderFirepower,
		   attackerStrengthModifiersApplied, attackerFirepowerModifiersApplied, defenderStrengthModifiersApplied, defenderFirepowerModifiersApplied
end

local combatCalculator = {
	initializeCombatModifiers = initializeCombatModifiers,
	getCombatModifier = getCombatModifier,
	setCombatModifier = setCombatModifier,
	getCombatValues = getCombatValues,
}

gen.versionFunctions(combatCalculator,versionNumber,fileModified,"LuaCore".."\\".."combatCalculator.lua")
return combatCalculator
