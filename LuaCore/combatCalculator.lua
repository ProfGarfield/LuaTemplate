local readRules = require("readRules")
local loadedRules = readRules.loadedRules
local cosmic2 = loadedRules["@COSMIC2"]
local gen = require("generalLibrary")

--Configurable defense bonuses in @COSMIC2. Values should be multiplied by 50% to get the percentage of the normal defense value a unit defends with. E.g. 3 * 50% = 150% of normal defense.
--
--
--Currently, the following keys are defined (default value in parentheses):
--- FortifyDefense (3): Bonus for fortifying.
--- FortressDefense (4): Bonus for fortress tiles (doesn't stack with fortifying)
---CityWallsDefense (6): Bonus for city walls (doesn't stack with fortifying).
--- CoastalFortressDefense (4): Bonus for coastal fortress.
--- AegisVSAirDefense (6): Bonus for AEGIS units against air units.
--- AegisVSMissileDefense (10): Bonus for AEGIS units against missiles.
--- SAMDefense (4): Bonus for SAM Missile Battery versus missiles (stacks with SDI).
--- SDIDefense (4): Bonus for SDI Defense versus missiles (stacks with SAM).
--
--Also, there are two keys, 'TerrainDefenseForAir' &, 'TerrainDefenseForSea' which, when set to 0, disable the defensive bonus from terrain for air/sea units respectively. Default to 1.

local defenseSettings = {}
defenseSettings["FortifyDefense"]=3
defenseSettings["FortressDefense"]=4
defenseSettings["CityWallsDefense"]=6
defenseSettings["CoastalFortressDefense"]=4
defenseSettings["AegisVSAirDefense"]=6
defenseSettings["AegisVSMissileDefense"]=10
defenseSettings["SAMDefense"]=4
defenseSettings["SDIDefense"]=4
defenseSettings['TerrainDefenseForAir'] = 1
defenseSettings['TerrainDefenseForSea'] = 1

local pikemanBonusKey = 'PikemanVSHorse'
defenseSettings[pikemanBonusKey] = 3

if cosmic2 then
    for lineNumber, columnTable in pairs(cosmic2) do
        if defenseSettings[columnTable[0]] then
            defenseSettings[columnTable[0]] = tonumber(columnTable[1])
        end
    end
end

local combatCalculator = {}

function combatCalculator.standardCalculation(attacker,defender)
    local multiplier = 8 -- multiply combat values by this, to allow for integer calculations
    local attackerDie = attacker.type.attack * multiplier
    local defenderDie = defender.type.defense * multiplier
    local attackerFP = attacker.type.firepower
    local defenderFP = defender.type.firepower
    -- pikeman defense condition
    if gen.isBonusAgainstHorse(defender.type) and attacker.type.move == 2 * totpp.movementMultipliers.aggregate
        and attacker.type.hitpoints == 10 and attacker.domain == 0 then
        -- apply pikeman bonus
        defenderDie = defenderDie*defenseSettings[pikemanBonusKey] // 2
    end
    if gen.isBonusAgainstAir(defender.type) and attacker.type.domain == 1 then
        if gen.isDestroyedAfterAttacking(attacker.type) then
            -- apply air/missile bonus
            defenderDie = defenderDie*defenseSettings['AegisVSMissileDefense'] // 2
        else
            -- apply air bonus
            defenderDie = defenderDie*defenseSettings['AegisVSAirDefense'] // 2
        end
    end

    -- Calculate fortification bonus:
    -- if city walls, no separate fortified bonus of 50%
    if defender.location.city and defender.location.city:hasImprovement(gen.original.iCityWalls) and 
        not gen.isIgnoreWalls(attacker.type) and attacker.type.domain == 0 then

    elseif gen.hasFortress(defender.location) and not gen.isIgnoreWalls(attacker.type) and attacker.type.domain ~= 1 then

--    elseif defender.location.city and defender.location.city:hasImprovement(gen.original.iCoastalFortress) and attacker.type.domain == 2 then
--    elseif gen.isFortified(defender) then
-- coastal fortress stacks with fortification for 3x total
-- same for SAM and air
-- SAM + SDI + Fortify = x6 vs missile
-- SAM + SDI = x4 vs missile (air)
    end


    return attackerDie, attackerFP, defenderDie, defenderFP
end

return combatCalculator
