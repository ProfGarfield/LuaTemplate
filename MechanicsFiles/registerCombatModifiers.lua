
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


--      You can register combat modification rules in any file.
--      This file simply provides some examples and the documentation.
--

local combatMod = require("combatModifiers")
local object = require("object")
local traits = require("traits")
local gen = require("generalLibrary"):minVersion(1)

-- You can register a combatModifier in order to make automatic changes to combat
-- using the following function call:
--
--      combatMod.registerCombatModificationRule(combatModifier)
--
--          a combatModifier is a data type defined below
--          if this function receives a regular table, it will be converted
--          to a combatModifier
--
-- A combatModifier can be created from a table using
--
--      local myCombatModifier = combatMod.newCombatModifier(specTable)
--
--  and a table can be tested to check if it is a combatModifer with the function
--  
--      combatMod.isCombatModifier(possibleCombatModifier)
--
--  A combatModifer can be modified like a regular table, but Lua will (probably) throw
--  an error if the modification doesn't meet the requirements of a combatModifier


--  A combat modifier has the following keys and values:
--
-- combatModifier = {
--  attacker = nil or traitString or unitType or table of traitString/unitType
--      if nil, modifier applies to all attackers
--      if traitString, the modifier applies if the attacker has the trait
--      if unitType, the modifier applies if the attacker is of that unitType
--      if table, any trait or unitType is allowed
--  attackerDetail = nil or traitString or baseTerrain, or terrain, or cityImprovement, or tribe, or wonder, or unitType or table of these
--      if nil, modifier applies to all attackers
--      if terrain/baseTerrain, modifier applies if the attacker is on that kind of tile
--      if cityImprovement, modifier applies if the attacker is on a city tile, and the city has that improvement
--          (or, has a non-expired wonder providing that improvement)
--      if tribe, modifier applies if the attacker is of that tribe
--      if tech, modifier applies if the attacker has that tech
--      if wonder, modifier applies if the wonder is owned by the tribe as long as it is not expired
--      if unitType, modifier applies if the tile is shared with a unit of this type
--      if traitString, the modifer applies if the terrain, baseTerrain, tribe, owned Tech, owned wonder, any city improvement, or any unit (other than the defender) on tile has that trait
--          NOTE: if the trait is for a wonder, it applies even if the wonder is expired
--          (You can use a conditional trait to get around that.)
--      if table, any entry is valid
--  defender = nil or traitString or unitType or table of traitString/unitType
--      if nil, modifier applies to all defenders
--      if traitString, the modifier applies if the defender has the trait
--      if unitType, the modifier applies if the defender is of that unitType
--      if table, any trait or unitType is allowed
--  defenderDetail = nil or traitString or baseTerrain, or terrain, tribe, or cityImprovement, or unitType or table of these
--      if nil, modifier applies to all defenders
--      if terrain/baseTerrain, modifier applies if the defender is on that kind of tile
--      if cityImprovement, modifier applies if the defender is on a city tile, and the city has that improvement
--          (or, has a non-expired wonder providing that improvement)
--      if tribe, modifier applies if the defender is of that particular tribe
--      if tech, modifier applies if the defender has that tech
--      if unitType, modifier applies if the tile is shared with a unit of this type
--      if wonder, modifier applies if the wonder is owned by the tribe and is not expired
--      if traitString, the modifer applies if the terrain, baseTerrain, tribe, owned Tech, owned wonder, any city improvement, or any unit (other than the defender) on tile has that trait
--          NOTE: if the trait is for a wonder, it applies even if the wonder is expired
--          (You can use a conditional trait to get around that.)
--      if table, any entry is valid
--  customCheck = nil or function(attacker,defender) --> boolean
--      if nil, modifier applies if above specifications are valid
--      if function, modifier applies if the function returns true, and false if it does not
--
--  combatSpec = combatSpec or nil (defined below)
--      the combatSpec to apply to combat if all the checks are true
--      if nil, it counts as an empty table
--      Note: if a regular table is provided here, the function combatMod.newCombatModifier will 
--      automatically convert it to a combatSpec (assuming it meets the requirements)
--      
--  combatSpecKey = combatSpecValue or nil (combatSpec valid keys defined below)
--      adds combatSpeck key and value specified to the combatSpec provided, overriding
--      the value for the key if applicable





-- A combatSpec is a data type used to specify how combat should be changed
-- It can be created from a table with the following function call
--      
--      local myCombatSpecification = combatMod.newCombatSpec(specTable)
--
--  A table can be checked to see if it is a combatSpec with the function call
--
--      combatMod.isCombatSpec(possibleCombatSpec)

-- combatSpec = table{
--      Note: all keys can be nil, in which case there is no modification
--
--          aCustomAdd = number -- add this to attack before multipliers are applied (negative number to subtract)
--          dCustomAdd = number-- add this to defense before multipliers are applied (negative number to subract)
--          aCustomMult = number-- multiply the attacker's strength by this much (to supply a custom bonus or penalty)
--          dCustomMult = number-- multiply the defender's strength by this much (to supply a custom bonus or penalty)
--          aAddFirepower = number -- add this to the attacker's firepower before any other calculations (negative number to subtract)
--          dAddFirepower = number -- add this to the defender's firepower before any other calculations (negative number to subtract)
--              If multiple combatSpec are applied, all aCustomAdd and dCustomAdd are summed together.
--              These are applied before multiplicative bonuses/penalties
--              If aCustomAdd reduces an attack value below 1, the attack will be set to 1
--              If dCustomAdd reduces a defense value below 0, the value will be set to 0
--
--              If multiple combatSpec are applied, all aAddFirepower and dAddFirepower are summed together.
--              These are applied before shore bombardment/caught in port etc. bonuses/penalties
--              If firepower modifications would reduce a unit's firepower below 1, it is set to 1
--
--          aAdd_~~~~
--          dAdd_~~~~
--          aMult_~~~~
--          dMult_~~~~
--              This group of keys can be any string, as long as they start with aAdd_, dAdd_, aMult_, dMult_
--              (i.e. ~~~~ is replaced by at least one character)
--              In each category, the largest buff (aAdd_, dAdd_ > 0; aMult_,dMult_ > 1) and 
--              debuff (aAdd_, dAdd_ < 0; aMult_,dMult_ < 1) among all applied combatSpecs in that
--              category are applied, with all others ignored.  E.g. with these combatSpecs:
--              aAdd_Many = -1,-2,-0.5,1,2,3
--              aAdd_Few = -2.5,1, 0.5
--              aAdd_Many -> 3 (max buff), -2 (max debuff)
--              aAdd_Few -> -2.5 (only debuff), 1 (max buff)
--              --> 3 - 2 - 2.5 + 1 = -0.5
--              -0.5 is added to aCustomAdd total
--              aMult_Some = 2.5, 1.25,0.75,0.33
--              aMult_Some -> 2.5 (max buff), 0.33 (max debuff)
--              --> 2.5*.33 = 0.825
--              -->0.825 is multiplied with aCustomMult
--              
--
--          [terrainIndex (integer)] = number
--              terrainIndex is 3*16*terrain.map+3*terrain.type+terrain.resource
--              if the number is specified, that terrain's defense multiplier is substituted for this one
--              (e.g. 1.5 is equivlalent to a defense value set to 3 in the rules, since 3/2=1.5)
--              Note: if any applied combatSpec uses dBaseTerrainCheck = false, no defense bonus is applied
--              regardless of the keys in this section
--              (except possibly river)
--              if multiple combatSpec are applied, 
--                  take the largest buff and largest debuff (additive), and applies both.
--                  e.g. hills, default value 4 -> x2 defense
--                  attempted overrides: 1,1.5, 2, 2.5, 3.5 
--                  buffs are 2.5, 3.5 (since larger than 2) -> +0.5, +1.5 -> largest buff: +1.5
--                  debuffs are 1, 1.5 (since smaller than 2) -> -1, -0.5 --> largest debuff: -1
--                  resulting override: -1+1.5 = 0.5 -> 2+0.5 = 2.5 
--
--          [terrainOrBaseTerrain] = number
--              assigning with terrain can be used in place of the terrainIndex integer
--              if key is baseTerrain, it counts as all 3 terrain types with that baseTerrain
--              (baseTerrain can only be used to assign values, not to get them)
--              when initially creating the combatSpec, baseTerrain are assigned first, then
--              the terrain is assigned.  After creation, baseTerrain will overwrite all 3
--              corresponding terrain indices
--
--              Note: during creation, terrain and baseTerrain keys in the supplied table overwrite
--              values supplied as terrain indices
--
--          aModifierName = number/bool (depending on modifier)
--          dModifierName = number/bool (depending on modifier)
--              if not nil, overrides the regular value for the combat modifer
--              if multiple combatSpec are applied, and the modifier is a boolean,
--                  the modifiers will all have to be false, so there is no conflict
--              if multiple combatSpec are applied, and the modifier is a number
--                  take the largest buff and largest debuff (additive), and applies both.
--                  e.g. dCityWalls, default value 3
--                  attempted overrides: 1, 2, 2.5, 3.5, 4
--                  buffs are 3.5,4 (since larger than 3) -> +0.5, +1 -> largest buff: +1
--                  debuffs are 1, 2, 2.5 (since smaller than 3) -> -2, -1, -0.5 --> largest debuff: -2
--                  resulting override: -2+1 = -1 -> 3-1 = 2 -> dCityWalls = 2
--
--              This is the list:
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
--          aModifier_~~~~
--          dModifier_~~~~
--          aOverride_~~~~
--          dOverride_~~~~
--              Keys that begin with aModifier_ or dModifier_ exist to represent combat modifiers
--              like the ones built into the game (dCityWalls,dPikemenFlag, etc.)
--              This program assumes that all such modifiers with the same name have the same value
--              So you can, for example, have 2 instances of aModifier_CavalryCharge to represent
--              different situations when the CavalryCharge bonus applies, but they should both give
--              the same bonus
--              Keys that begin with aOverride_ or dOverride_ will change the effects of the corresponding
--              aModifier_ and dModifier_ keys in the same way that aModifierName and dModifierName work above

--  This function disables combat modifiers if it is uncommented
--  This is provided to enable a designer to test if there is lag due to
--  the combat modifiers code.  This might be an issue on AI turns, since the
--  AI will check which unit is going to defend a tile as part of its planning,
--  so the combat modification code might be run a lot.
--  If this happens, contact Prof. Garfield, since I can probably optimize
--  the combatModifiers code to improve performance.
-- combatMod.disable()
--
--  In combatSettings.lua, you can search for
--  %Report Combat Strength%
--  to find a line of code, which, when uncommented, 
--  will report the results of the combat calculation
--
--      Examples
--
--
--
--[[
--  example traits assignment (in setTraits.lua)
traits.allowedTraits("religiousBuilding","mounted","siege engine","science wonder")

traits.assign(gen.original.iCathedral,"religiousBuilding")
traits.assign(gen.original.iTemple,"religiousBuilding")

traits.assign({gen.original.uHorsemen, gen.original.uKnights, gen.original.uCrusaders,
        gen.original.uDragoons, gen.original.uCavalry}, "mounted")

traits.assign({gen.original.uCatapult, gen.original.uCannon, gen.original.uArtillery},"siege engine")

traits.assign({gen.original.wCopernicusObservatory, gen.original.wIsaacNewtonsCollege, gen.original.wSETIProgram},"science wonder")
--]]
--
--
--[[
--
-- air units get an attack bonus against ancient units
combatMod.registerCombatModificationRule({
    attacker = {gen.original.uFighter, gen.original.uStlthBmbr, gen.original.uStlthFtr, gen.original.uBomber, gen.original.uHelicopter},
    defender = {gen.original.uWarriors, gen.original.uPhalanx, gen.original.uArchers, gen.original.uLegion},
    aCustomAdd = 3,
})

-- special bonus for defending on Furs or Game (x4 instead of regular)
combatMod.registerCombatModificationRule({
    -- attacker can be anyone
    -- defender can be anyone
    defenderDetail = {gen.original.tFurs, gen.original.tGame},
    dModifier_tundraSpecial = 4,
})

-- Alpine Troops negate tundra special defense bonus,
combatMod.registerCombatModificationRule({
    attacker = gen.original.uAlpineTroops,
    dOverride_tundraSpecial = 1,
})
-- Alpine troops get a defensive bonus of x6 on tundra specials instead of x4
combatMod.registerCombatModificationRule({
    defender = gen.original.uAlpineTroops,
    dOverride_tundraSpecial = 6,
})
-- Crusaders get +4 defense when defending a city with a "religiousBuilding" (temple/cathedral)
-- (or city has cathedral via mike's chapel)
combatMod.registerCombatModificationRule({
    defender = gen.original.uCrusaders,
    defenderDetail = "religiousBuilding",
    --combatSpec = {dCustomAdd = 4 },
    dCustomAdd = 4,
})


-- units with the mounted trait get defense bonuses on
-- flat terrain, and different bonuses on rough terrain
combatMod.registerCombatModificationRule({
    defender = "mounted",
    [gen.original.bDesert] = 2,
    [gen.original.bPlains] = 2.5,
    [gen.original.bGrassland] = 2.5,
    [gen.original.bHills] = 1.5,
    [gen.original.bMountains] = 0.5,
    [gen.original.bTundra] = 1.5,
    [gen.original.bForest] = 1.5,
    [gen.original.bJungle] = 1,
    [gen.original.bSwamp] = 0.75,
    [gen.original.bGlacier] = 0.5,
})

-- 'siege engines' (catapult, cannon, artillery) reduce
-- the effectiveness of fortifications when attacking
combatMod.registerCombatModificationRule({
    attacker = "siege engine",
    dCityWalls = 2,
    dFortress = 1.5,
    dFortified = 1.25,
})
-- fanatics and siege engines are particularly good at defending fortified positions
combatMod.registerCombatModificationRule({
    defender = {"siege engine", gen.original.uFanatics},
    combatSpec = {
        dCityWalls = 4.5,
        dFortress = 3,
        dFortified = 2,
    },
})
-- A granary increases the defensive value of city walls to 5
combatMod.registerCombatModificationRule({
    defenderDetail = gen.original.iGranary,
    dCityWalls = 5,
})
-- Note, if siege engine attacks fanatics in a city with walls,
-- the granary bonus is largest bonus, so the fanatic bonus is ignored
-- So, granary bonus: +2, siege engine debuff = -1 --> 3+2-1 = 4
-- city walls impart x4 defence.



-- mech inf gives a bonus when either another mech inf
-- or an armor attacks from the same tile
-- a single mech inf doesn't get the bonus
combatMod.registerCombatModificationRule({
    attacker = {gen.original.uArmor, gen.original.uMechInf},
    attackerDetail = gen.original.uMechInf,
    aCustomAdd = 2,
})

-- with computers, battleships don't lose firepower during shore bombardment
combatMod.registerCombatModificationRule({
    attacker = gen.original.uBattleship,
    attackerDetail = gen.original.aComputers,
    aFirepowerShoreBombardmentCheck = false,
})

-- tanks get a bonus when the defender is not veteran
combatMod.registerCombatModificationRule({
    attacker = gen.original.uArmor,
    customCheck = function(attacker,defender)
        return not defender.veteran
    end,
    aCustomMult = 1.25,
})

-- tribes with a 'science wonder' get a 10% boost to combat power
-- (Note: this will apply regardless of whether the wonder is expired,
-- unless the trait is conditional on the wonder not being expired)
combatMod.registerCombatModificationRule({
    attackerDetail = "science wonder",
    aCustomMult = 1.1,
})
combatMod.registerCombatModificationRule({
    defenderDetail = "science wonder",
    dCustomMult = 1.1,
})
-- tribes with an unexpired happiness wonder get 20% combat bonus
-- due to high morale
combatMod.registerCombatModificationRule({
    attackerDetail = {gen.original.wHangingGardens, gen.original.wCureforCancer},
    aCustomMult = 1.2,
})
combatMod.registerCombatModificationRule({
    defenderDetail = {gen.original.wHangingGardens, gen.original.wCureforCancer},
    dCustomMult = 1.2,
})


--]]






local register = {}
gen.versionFunctions(register,versionNumber,fileModified,"MechanicsFiles".."\\".."registerCombatModifiers.lua")
return register
