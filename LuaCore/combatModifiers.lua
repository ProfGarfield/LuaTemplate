
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--

    -- Register a rule to modify combat
    -- combatMod.registerCombatModificationRule(combatModifier)
    --  registers a rule to modify combat
    --  see below for the specifications for a combatModifier table

--      combatSpec = table{
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

-- combatModifier = {
--  attacker = nil or traitString or unitType or table of traitString/unitType
--      if nil, modifier applies to all attackers
--      if traitString, the modifier applies if the attacker has the trait
--      if unitType, the modifier applies if the attacker is of that unitType
--      if table, any trait or unitType is allowed
--  attackerDetail = nil or traitString or baseTerrain, or terrain, or cityImprovement, or tribe, or wonder, or table of these
--      if nil, modifier applies to all attackers
--      if terrain/baseTerrain, modifier applies if the attacker is on that kind of tile
--      if cityImprovement, modifier applies if the attacker is on a city tile, and the city has that improvement
--          (or, has a non-expired wonder providing that improvement)
--      if tribe, modifier applies if the attacker is of that tribe
--      if tech, modifier applies if the attacker has that tech
--      if wonder, modifier applies if the wonder is owned by the tribe as long as it is not expired
--      if unitType, modifier applies if the tile is shared with a unit of this type
--      if traitString, the modifer applies if the terrain, baseTerrain, tribe, owned Tech, owned wonder, any city improvement, or any unit on tile has that trait
--          NOTE: if the trait is for a wonder, it applies even if the wonder is expired
--          (You can use a conditional trait to get around that.)
--      if table, any entry is valid
--  defender = nil or traitString or unitType or table of traitString/unitType
--      if nil, modifier applies to all defenders
--      if traitString, the modifier applies if the defender has the trait
--      if unitType, the modifier applies if the defender is of that unitType
--      if table, any trait or unitType is allowed
--  defenderDetail = nil or traitString or baseTerrain, or terrain, tribe, or cityImprovement or table of these
--      if nil, modifier applies to all defenders
--      if terrain/baseTerrain, modifier applies if the defender is on that kind of tile
--      if cityImprovement, modifier applies if the defender is on a city tile, and the city has that improvement
--          (or, has a non-expired wonder providing that improvement)
--      if tribe, modifier applies if the defender is of that particular tribe
--      if tech, modifier applies if the defender has that tech
--      if wonder, modifier applies if the tribe owns that wonder as long as it is not expired
--      if unitType, modifier applies if the tile is shared with a unit of this type
--      if traitString, the modifer applies if the terrain, baseTerrain, tribe, owned Tech, owned wonder, any city improvement, or any unit on tile has that trait
--          NOTE: if the trait is for a wonder, it applies even if the wonder is expired
--          (You can use a conditional trait to get around that.)
--      if table, any entry is valid
--  customCheck = nil or function(attacker,defender) --> boolean
--      if nil, modifier applies if above specifications are valid
--      if function, modifier applies if the function returns true, and false if it does not
--
--  combatSpec = combatSpec or nil
--      the combatSpec to apply to combat if all the checks are true
--      if nil, it counts as an empty table
--      
--  combatSpecKey = combatSpecValue
--      adds combatSpeck key and value specified to the combatSpec provided, overriding
--      the value for the key if applicable


--  this is the behind the scenes combatModifier
-- internalCombatModifier = {
--  attackerUnitTypeID = nil or {[unitTypeID] = true}
--  attackerTraits = nil or table of traits
--      if both are nil, any attacker can get this bonus
--      if the attacker's unitTypeID is in the attackerUnitTypeID table, it can get the bonus
--      if the attacker has a trait in attackerTraits, it can get the bonus
--  attackerDetailItems = nil or {[item]=function(unit,item)-->boolean}
--      item can be terrain,baseTerrain,cityImprovement,tribe,tech
--      function checks if the detail is satisfied
--  attackerDetailTraits = nil or table of traits
--  defenderUnitTypeID = nil or {[unitTypeID] = true}
--  defenderTraits = nil or table of traits
--      if both are nil, any defender can get this bonus
--      if the defender's unitTypeID is in the defenderUnitTypeID table, it can get the bonus
--      if the defender has a trait in defenderTraits, it can get the bonus
--  defenderDetailItems = nil or {[item]=function(unit,item)-->boolean}
--      item can be terrain,baseTerrain,cityImprovement,tribe,tech
--      function checks if the detail is satisfied
--  defenderDetailTraits = nil or table of traits
--  customCheck = nil or function(attacker,defender) --> boolean
--      if nil, modifier applies if other specifications are met
--      if function, modifier only applies if function returns true (and other modifications are met)
--
--  combatSpec = combatSpec
--      the combatSpec that applies if the conditions are true
--
--


--
local traits = require("traits"):minVersion(2)
require("setTraits")
local combatMod = {}
local gen = require("generalLibrary"):minVersion(2)
gen.versionFunctions(combatMod,versionNumber,fileModified,"LuaCore".."\\".."combatModifiers.lua")
local combatCalculator = require("combatCalculator"):minVersion(2)


local posNumNil = {["nil"]=true,["number"]={minVal = 0}}
local posNumNilFunc = {["nil"]=true,["number"]={minVal = 0},["function"]="function(attacker,defender) --> number>=0|nil"}
local numNil = {["nil"]=true,["number"]=true}
local numNilFunc = {["nil"]=true,["number"]=true,["function"]="function(attacker,defender) --> number|nil"}
local falseNil = {["nil"]=true,["boolean"]="false"}
local falseNilFunc = {["nil"]=true,["boolean"]="false",["function"]="function(attacker,defender) --> false|nil"}
local traitUnitNil = {["nil"]=true,["userdata"] = {["unitType"]=civ.isUnitType},["string"]=traits.allTraits(),}


local combatSpecSpecificKeys = {

    aCustomAdd = numNilFunc,
    dCustomAdd = numNilFunc,
    aCustomMult = posNumNilFunc,
    dCustomMult = posNumNilFunc,
    aAddFirepower = numNilFunc,
    dAddFirepower = numNilFunc,

    aVeteran = posNumNilFunc,
    aPartisans = posNumNilFunc,
    aParadrop = posNumNilFunc,
    aSneakAttack = posNumNilFunc,
    aEasiestLevelHumanAttacker = posNumNilFunc,
    aEasyLevelsHumanDefender = posNumNilFunc,
    aBarbarianAttackerVsHumanDefender = posNumNilFunc,
    aBarbarianAttackerVsAiDefender = posNumNilFunc,
    aBarbarianAttackerVsDefendersOnlyCity = posNumNilFunc,
    aBarbarianAttackerVsDefendersCapitalCity = posNumNilFunc,
    aBarbarianAttackerVsDefenderWithGreatWall = posNumNilFunc,
    aGreatWallVsBarbarianDefender = posNumNilFunc,
    aFirepowerCaughtInPort = posNumNilFunc,
    dVeteran = posNumNilFunc,
    dScramblingFighterVsBomber = posNumNilFunc,
    dScramblingFighterVsFighter = posNumNilFunc,
    dHelicopter = posNumNilFunc,
    dCityWalls = posNumNilFunc,
    dFortress = posNumNilFunc,
    dFortified = posNumNilFunc,
    dPikemenFlag = posNumNilFunc,
    dAegisFlagVsMissile = posNumNilFunc,
    dAegisFlagVsOtherAir = posNumNilFunc,
    dSdiDefenseVsMissile = posNumNilFunc,
    dSamMissileBattery = posNumNilFunc,
    dCoastalFortress = posNumNilFunc,
    dBarbarianDefenderArchers = posNumNilFunc,
    dBarbarianDefenderLegion = posNumNilFunc,

    aMovesRemainingCheck = falseNilFunc,
    aFirepowerShoreBombardmentCheck = falseNilFunc,
    dBaseTerrainCheck = falseNilFunc,
    dFirepowerHelicopterCheck = falseNilFunc,
    dFirepowerShoreBombardmentCheck = falseNilFunc,
    dFirepowerCaughtInPortCheck = falseNilFunc,
    dFirepowerSubmarineFlagCheck = falseNilFunc,

    dRiverAddition = numNilFunc,
}

local function isTerrainOrBaseTerrain(item)
    return civ.isTerrain(item) or civ.isBaseTerrain(item)
end

local function isTerrainIndex(number)
    return type(number) == "number" and number == math.floor(number) and number >= 0 and number <=191
end
local function getTerrainIndex(terrainObject)
    return 3*16*terrainObject.map+3*terrainObject.type+terrainObject.resource
end
        

local function isAddKey(key)
    if type(key) ~= "string" then
        return false
    end
    local prefix = string.sub(key,1,5)
    return prefix == "aAdd_" or prefix == "dAdd_"
end

local function isMultKey(key)
    if type(key) ~= "string" then
        return false
    end
    local prefix = string.sub(key,1,6)
    return prefix == "aMult_" or prefix == "dMult_"
end

local function isModifierKey(key)
    if type(key) ~= "string" then
        return false
    end
    local prefix = string.sub(key,1,10)
    return prefix == "aModifier_" or prefix == "dModifier_" or prefix == "aOverride_" or prefix == "dOverride_"
end


local combatSpecGeneralKeys = {
    [isTerrainIndex] = posNumNilFunc,
    [isAddKey] = numNilFunc,
    [isMultKey] = posNumNilFunc,
    [isModifierKey] = posNumNilFunc,
}

local baseNewCombatSpec, isCombatSpec, combatSpecMetatable = gen.createDataType("combatSpec",combatSpecSpecificKeys,combatSpecGeneralKeys,{},{})

local function newCombatSpec(table)
    table = gen.copyTable(table)
    local intermediateTable = {}
    for key,value in pairs(table) do
        if civ.isBaseTerrain(key) then
            intermediateTable[getTerrainIndex(key:getTerrain(0))] = value
            if key.type ~= 2 then
                intermediateTable[getTerrainIndex(key:getTerrain(1))] = value
                intermediateTable[getTerrainIndex(key:getTerrain(2))] = value
            end
            table[key] = nil
        end
    end
    for key,value in pairs(table) do
        if civ.isTerrain(key) then
            intermediateTable[getTerrainIndex(key)] = value
            table[key] = nil
        end
    end
    for key,value in pairs(intermediateTable) do
        table[key] = value
    end
    return baseNewCombatSpec(table)
end

local originalCombatSpec__index = combatSpecMetatable.__index
local originalCombatSpec__newindex = combatSpecMetatable.__newindex
combatSpecMetatable.__index = function(t,key)
    if civ.isTerrain(key) then
        return originalCombatSpec__index(t,getTerrainIndex(key))
    else
        return originalCombatSpec__index(t,key)
    end
end
combatSpecMetatable.__newindex = function(t,key,value)
    if civ.isTerrain(key) then
        originalCombatSpec__newindex(t,getTerrainIndex(key),value)
    elseif civ.isBaseTerrain(key) then
        originalCombatSpec__newindex(t,getTerrainIndex(key:getTerrain(0)),value)
        if key.type ~= 2 then
            originalCombatSpec__newindex(t,getTerrainIndex(key:getTerrain(1)),value)
            originalCombatSpec__newindex(t,getTerrainIndex(key:getTerrain(2)),value)
        end
    else
        originalCombatSpec__newindex(t,key,value)
    end
end


combatMod.newCombatSpec = newCombatSpec
combatMod.isCombatSpec = isCombatSpec

local tileVDI = {["nil"]=true,["string"]=traits.allTraits(),["userdata"]={["baseTerrain"]=civ.isBaseTerrain, ["terrain"] = civ.isTerrain,["cityImprovement"]=civ.isImprovement,["tribe"]=civ.isTribe, ["wonder"]=civ.isWonder, ["tech"] = civ.isTech,["unitType"]=civ.isUnitType,}}

local combatModifierSpecificKeys = {
    attacker = gen.vDIOrTableOfVDI(traitUnitNil),
    defender = gen.vDIOrTableOfVDI(traitUnitNil),
    attackerDetail = gen.vDIOrTableOfVDI(tileVDI),
    defenderDetail = gen.vDIOrTableOfVDI(tileVDI),
    customCheck = {["nil"]=true,["function"]="function(attacker,defender) --> boolean"},
    combatSpec = {["nil"]=true,["table"] = {function(table) return isCombatSpec(table) or "table is not a combatSpec" end,"combatSpec"}}
}
local nilOrTable = {["nil"] = true, ["table"]=true}

local internalCombatModiferSpecificKeys = {
    attackerUnitTypeID = nilOrTable,
    attackerTraits = nilOrTable,
    attackerDetailItems = nilOrTable,
    attackerDetailTraits = nilOrTable,
    defenderUnitTypeID = nilOrTable,
    defenderTraits = nilOrTable,
    defenderDetailItems = nilOrTable,
    defenderDetailTraits = nilOrTable,
    customCheck = {["nil"]=true,["function"]="function(attacker,defender) --> boolean"},
    combatSpec = {["table"] = {function(table) return isCombatSpec(table) or "table is not a combatSpec" end,"combatSpec"}},
}


for key,value in pairs(combatSpecSpecificKeys) do
    combatModifierSpecificKeys[key] = value
end


local baseNewCombatModifier, isCombatModifier = gen.createDataType("combatModifier",combatModifierSpecificKeys,combatSpecGeneralKeys,{},{})

local function newCombatModifier(table)
    table = gen.copyTable(table)
    if table.combatSpec and type(table.combatSpec) == "table" and not isCombatSpec(table.combatSpec) then
        table.combatSpec = newCombatSpec(table.combatSpec)
    end
    local intermediateTable = {}
    for key,value in pairs(table) do
        if civ.isBaseTerrain(key) then
            intermediateTable[getTerrainIndex(key:getTerrain(0))] = value
            if key.type ~= 2 then
                intermediateTable[getTerrainIndex(key:getTerrain(1))] = value
                intermediateTable[getTerrainIndex(key:getTerrain(2))] = value
            end
            table[key] = nil
        end
    end
    for key,value in pairs(table) do
        if civ.isTerrain(key) then
            intermediateTable[getTerrainIndex(key)] = value
            table[key] = nil
        end
    end
    for key,value in pairs(intermediateTable) do
        table[key] = value
    end
    return baseNewCombatModifier(table)
end

combatMod.newCombatModifier = newCombatModifier
combatMod.isCombatModifier = isCombatModifier

local newInternalCombatModifier, isInternalCombatModifier = gen.createDataType("internalCombatModifer",internalCombatModiferSpecificKeys, {},{},{})

local reservedCombatModKeys = {["attacker"]=true,["attackerDetail"]=true,["defender"]=true,["defenderDetail"]=true,["customCheck"]=true,["combatSpec"]=true,}

function combatMod.processCombatModifier(combatMod)
    local internalTable = {}
    local function splitCombatModValue(value,itemKey,traitKey)
        if type(value) == "nil" then
            return
        elseif type(value) == "table" then
            for _,v in pairs(value) do
                splitCombatModValue(v,itemKey,traitKey)
            end
            return
        elseif type(value) == "string" then
            internalTable[traitKey] = internalTable[traitKey] or {}
            internalTable[traitKey][#(internalTable[traitKey])+1] = value
            return
        elseif civ.isUnitType(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value.id] = true
            return
        end
    end
    splitCombatModValue(combatMod.attacker,"attackerUnitTypeID","attackerTraits")
    splitCombatModValue(combatMod.defender,"defenderUnitTypeID","defenderTraits")
    local function evaluateTerrain(unit,item)
        return unit.location.terrain == item
    end
    local function evaluateBaseTerrain(unit,item)
        return unit.location.baseTerrain == item
    end
    local wonderImprovements = {
        [gen.original.iGranary.id] = gen.original.wPyramids,
        [gen.original.iCityWalls.id] = gen.original.wGreatWall,
        [gen.original.iCathedral.id] = gen.original.wMichelangelosChapel,
        [gen.original.iResearchLab.id] = gen.original.wSETIProgram,
        [gen.original.iPoliceStation.id] = gen.original.wWomensSuffrage,
        [gen.original.iHydroPlant.id] = gen.original.wHooverDam,
    }
    local function evaluateImprovement(unit,item)
        local wonderEquivalent = wonderImprovements[item.id]
        return unit.location.city and (unit.location.city:hasImprovement(item) or 
            (wonderEquivalent and gen.isWonderActiveForTribe(wonderEquivalent,unit.location.city.owner)))
    end
    local function evaluateTribe(unit,item)
        return unit.owner == item
    end
    local function evaluateTech(unit,item)
        return unit.owner:hasTech(item)
    end
    local function evaluateWonder(unit,item)
        return gen.isWonderActiveForTribe(item,unit.owner)
    end
    local function evaluateUnitType(unit,item)
        for otherUnit in unit.location.units do
            if otherUnit ~= unit and otherUnit.type == item then
                return true
            end
        end
        return false
    end

    local function splitCombatModDetails(value,itemKey,traitKey)
        if type(value) == "nil" then
            return
        elseif type(value) == "table" then
            for _,v in pairs(value) do
                splitCombatModDetails(v,itemKey,traitKey)
            end
            return
        elseif type(value) == "string" then
            internalTable[traitKey] = internalTable[traitKey] or {}
            internalTable[traitKey][#(internalTable[traitKey])+1] = value
            return
        elseif civ.isTerrain(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateTerrain
            return
        elseif civ.isBaseTerrain(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateBaseTerrain
            return
        elseif civ.isImprovement(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateImprovement
            return
        elseif civ.isTribe(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateTribe
            return
        elseif civ.isTech(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateTech
            return
        elseif civ.isWonder(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateWonder
            return
        elseif civ.isUnitType(value) then
            internalTable[itemKey] = internalTable[itemKey] or {}
            internalTable[itemKey][value] = evaluateUnitType
            return
        else
            error("combatModifiers: the item "..tostring(value).." is an invalid detail.")
        end
    end
    splitCombatModDetails(combatMod.attackerDetail,"attackerDetailItems","attackerDetailTraits")
    splitCombatModDetails(combatMod.defenderDetail,"defenderDetailItems","defenderDetailTraits")
    internalTable.customCheck = combatMod.customCheck
    if combatMod.combatSpec then
        internalTable.combatSpec = newCombatSpec(gen.copyTable(combatMod.combatSpec))
    else
        internalTable.combatSpec = newCombatSpec({})
    end
    for key,value in pairs(combatMod) do
        if type(key) == "number" then
            internalTable.combatSpec[key] = value
        end
    end
    for key,value in pairs(combatMod) do
        if civ.isBaseTerrain(key) then
            internalTable.combatSpec[key] = value
        end
    end
    for key,value in pairs(combatMod) do
        if civ.isTerrain(key) then
            internalTable.combatSpec[key] = value
        end
    end
    for key,value in pairs(combatMod) do
        if not reservedCombatModKeys[key] and not civ.isBaseTerrain(key) and not civ.isTerrain(key) and type(key) ~= "number" then
            internalTable.combatSpec[key] = value
        end
    end
    return newInternalCombatModifier(internalTable)
end

local combatModifierTable = {}
-- Registers a combat modifier 


function combatMod.registerCombatModificationRule(combatModifier)
    if not isCombatModifier(combatModifier) then
        combatModifier = newCombatModifier(combatModifier)
    end
    local internalCombatModifier = combatMod.processCombatModifier(combatModifier)
    combatModifierTable[1+#combatModifierTable] = internalCombatModifier
end

-- these keys should be immediately added/multiplied, rather than put into
-- an intermediate table to find the biggest buff/debuff
local directAddKeys = {
    ["aCustomAdd"] = true,
    ["dCustomAdd"] = true,
    ["aAddFirepower"] = true,
    ["dAddFirepower"] = true,
}
local directMultKeys = {
    ["aCustomMult"] = true,
    ["dCustomMult"] = true,
}
-- these modifiers are disabled by setting them to false,
-- they can be applied immediately
local falseModifiers = {
    ["aMovesRemainingCheck"]=true,
    ["aFirepowerShoreBombardmentCheck"] = true,
    ["dBaseTerrainCheck"]=true,
    ["dFirepowerHelicopterCheck"]=true,
    ["dFirepowerShoreBombardmentCheck"]=true,
    ["dFirepowerCaughtInPortCheck"]=true,
    ["dFirepowerSubmarineFlagCheck"]=true,
}

local doNotApplyRegisteredCombatRules = false
-- this is here in the event that combat rules are suspected of causing lag, especially
-- during the AI turn.
function combatMod.disable()
    doNotApplyRegisteredCombatRules = true
    civ.ui.text("All combat modifications are disabled.  They will still be registered, but they will not apply to combat.")
end

--  the attacker and defender are the units that will (possibly) engage in combat
--  the combatModifierOverrideTable is modified in place, to make the changes to combat
function combatMod.applyRegisteredRules(attacker,defender,combatModifierOverrideTable)
    if doNotApplyRegisteredCombatRules then
        return
    end
    local function anyDetailMatches(unit,detailItems,detailTraits)
        if detailItems == nil and detailTraits == nil then
            return true
        end
        detailItems = detailItems or {}
        detailTraits = detailTraits or {}
        for item, fn in pairs(detailItems) do
            if fn(unit,item) then
                return true
            end
        end
        if traits.anyAssociatedWithTribe(unit.owner,detailTraits) then
            return true
        end
        if traits.anyAssociatedWithTile(unit.location,detailTraits) then
            return true
        end
        for otherUnit in unit.location.units do
            if otherUnit ~= unit and traits.hasAnyTrait(otherUnit.type,detailTraits) then
                return true
            end
        end
        return false
    end

    local function attackerValid(modTable)
        if modTable.attackerUnitTypeID and modTable.attackerTraits then
            return modTable.attackerUnitTypeID[attacker.type.id] or traits.hasAnyTrait(attacker.type,modTable.attackerTraits) 
        elseif modTable.attackerUnitTypeID then
            return modTable.attackerUnitTypeID[attacker.type.id]
        elseif modTable.attackerTraits then
            return traits.hasAnyTrait(attacker.type,modTable.attackerTraits)
        else
            return true
        end
    end
    local function defenderValid(modTable)
        if modTable.defenderUnitTypeID and modTable.defenderTraits then
            return modTable.defenderUnitTypeID[defender.type.id] or traits.hasAnyTrait(defender.type,modTable.defenderTraits) 
        elseif modTable.defenderUnitTypeID then
            return modTable.defenderUnitTypeID[defender.type.id]
        elseif modTable.defenderTraits then
            return traits.hasAnyTrait(defender.type,modTable.defenderTraits)
        else
            return true
        end
    end

    local function attackerAndDefenderValid(modTable)
        return attackerValid(modTable) and defenderValid(modTable)
    end
    local function customCheckTrue(modTable)
        if modTable.customCheck and (not modTable.customCheck(attacker,defender)) then
            return false
        end
        return true
    end
    -- these tables keep track of the buffs and debuffs over multiple rules, if applicable
    local largestValue = {} 
    local smallestValue = {}
    local function trackExtremeValues(key,val)
        -- no reason to track terrain values, if the defender isn't on that kind of terrain
        if type(key) == 'number' and getTerrainIndex(defender.location.terrain) ~= key then
            return
        end
        if largestValue[key] == nil then
            largestValue[key] = val
            smallestValue[key] = val
            return
        end
        if largestValue[key] < val then
            largestValue[key] = val
        end
        if smallestValue[key] > val then
            smallestValue[key] = val
        end
    end
    for _,modTable in pairs(combatModifierTable) do
        if attackerAndDefenderValid(modTable) and 
        anyDetailMatches(attacker, modTable.attackerDetailItems,modTable.attackerDetailTraits) and
        anyDetailMatches(defender,modTable.defenderDetailItems,modTable.defenderDetailTraits) and
        customCheckTrue(modTable) then
            local cSpec = modTable.combatSpec
            for key,recordedValue in pairs(cSpec) do
                local value = recordedValue
                if type(value) == "function" then
                    value = value(attacker,defender)
                end
                if value == nil then
                    -- just do nothing if the value ends up being nil
                elseif directAddKeys[key] then
                    combatModifierOverrideTable[key] = (combatModifierOverrideTable[key] or 0) + value
                elseif directMultKeys[key] then
                    combatModifierOverrideTable[key] = (combatModifierOverrideTable[key] or 1)*value
                elseif falseModifiers[key] then
                    combatModifierOverrideTable[key] = false
                else
                    trackExtremeValues(key,value)
                end
            end
        end
    end
    -- This function will be run in a loop over largestValue
    -- it is its own function in part to allow for efficient use of return
    -- initialize the following keys, so they are guaranteed to be available:
    combatModifierOverrideTable.aCustomAdd = combatModifierOverrideTable.aCustomAdd or 0
    combatModifierOverrideTable.dCustomAdd = combatModifierOverrideTable.dCustomAdd or 0
    combatModifierOverrideTable.aCustomMult = combatModifierOverrideTable.aCustomMult or 1
    combatModifierOverrideTable.dCustomMult = combatModifierOverrideTable.dCustomMult or 1
    local function applyBuffsAndDebuffs(key)
        if type(key) == 'number' then
            -- The integer key is only saved in largestValue if the defender is on the corresponding terrain type
            -- so, we can apply it immediately
            local defValue = defender.location.baseTerrain.defense / 2
            if largestValue[key] > defValue and smallestValue[key] < defValue then
                combatModifierOverrideTable.dTerrainDefenseValue = largestValue[key] + smallestValue[key] - defValue
            elseif largestValue[key] > defValue then
                combatModifierOverrideTable.dTerrainDefenseValue = largestValue[key]
            elseif smallestValue[key] < defValue then
                combatModifierOverrideTable.dTerrainDefenseValue = smallestValue[key]
            end
            return
        end
        if isAddKey(key) then
            local addKey = "aCustomAdd"
            if string.sub(key,1,5) == "dAdd_" then
                local addKey = "dCustomAdd"
            end
            if largestValue[key] > 0 and smallestValue[key] < 0 then
                combatModifierOverrideTable[addKey] = combatModifierOverrideTable[addKey] +largestValue[key] + smallestValue[key]
            elseif largestValue[key] > 0 then
                combatModifierOverrideTable[addKey] = combatModifierOverrideTable[addKey] +largestValue[key]
            elseif smallestValue[key] < 0 then
                combatModifierOverrideTable[addKey] = combatModifierOverrideTable[addKey] + smallestValue[key]
            end
            return
        end
        if isMultKey(key) then
            local multKey = "aCustomMult"
            if string.sub(key,1,6) == "dMult_" then
                local multKey = "dCustomMult"
            end
            if largestValue[key] > 1 and smallestValue[key] < 1 then
                combatModifierOverrideTable[multKey] = combatModifierOverrideTable[multKey]*largestValue[key]*smallestValue[key]
            elseif largestValue[key] > 1 then
                combatModifierOverrideTable[multKey] = combatModifierOverrideTable[multKey]*largestValue[key]
            elseif smallestValue[key] < 1 then
                combatModifierOverrideTable[multKey] = combatModifierOverrideTable[multKey]*smallestValue[key]
            end
            return
        end
        if isModifierKey(key) then
            local prefix = string.sub(key,1,10)
            if prefix == "aOverride_" or prefix == "dOverride_" then
                -- overrides will be handled with the modifier keys, if they appear
                return
            end
            local overridePrefix = "aOverride_"
            local cMOTKey = "aCustomMult"
            if prefix == "dModifier_" then
                overridePrefix = "dOverride_"
                cMOTKey = "dCustomMult"
            end
            local overrideKey = overridePrefix..string.sub(key,11,-1)
            local defaultValue = largestValue[key]
            local lVal = largestValue[overrideKey] or defaultValue
            local sVal = smallestValue[overrideKey] or defaultValue
            local finalVal = defaultValue
            if lVal > defaultValue and sVal < defaultValue then
                finalVal = lVal+sVal-defaultValue
            elseif lVal > defaultValue then
                finalVal = lVal
            elseif sVal < defaultValue then
                finalVal = sVal
            end
            combatModifierOverrideTable[cMOTKey] = combatModifierOverrideTable[cMOTKey]*finalVal
            return
        end
        -- if we get here, we're overriding numerical bonuses
        local defaultValue = combatCalculator.getCombatModifier(key)
        local lVal = largestValue[key]
        local sVal = smallestValue[key]
        local finalVal = defaultValue
        if lVal > defaultValue and sVal < defaultValue then
            finalVal = lVal+sVal-defaultValue
        elseif lVal > defaultValue then
            finalVal = lVal
        elseif sVal < defaultValue then
            finalVal = sVal
        end
        combatModifierOverrideTable[key] = finalVal
        return
    end
    for key,value in pairs(largestValue) do
        applyBuffsAndDebuffs(key)
    end
end

return combatMod
