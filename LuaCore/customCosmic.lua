
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


--[[
This module provides code to allow parameters which are typically global
to be set for individual units, cities, or tribes as seamlessly as possible.
]]


--[[
            Unit Type Customisations
    Relevant when unit is not active
        unit movement points, movement multipliers
    Only relevant when unit is active
        terrain movement costs, impassable terrain, triremeLost, paradropRange,
        unitType attributes



]]

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(6)
local changeRules = require("changeRules")
local traits = require("traits"):minVersion(3)
local discreteEvents = require("discreteEventsRegistrar")

local nilInt = {["nil"]=true,["number"]={integer=true}}
local nilIntFn = {["nil"]=true,["number"]={integer=true}, ["function"]="function(unit)-->nil|int"}
local nilPosInt = {["nil"]=true,["number"]={minVal = 0, integer=true}}
local nilPosIntFn = {["nil"]=true,["number"]={minVal = 0, integer=true}, ["function"]="function(unit)-->nil|int>=0"}
local posNum = {["number"]={minVal = 0}}
local nilPosNumFn = {["nil"]=true,["number"]={minVal = 0}, ["function"]="function(unit)-->nil|num>=0"}
local nilNumFn = {["nil"]=true,["number"]=true, ["function"]="function(unit)-->nil|num>=0"}
local mMultFn = {["nil"]=true,["number"]={minVal = -1, maxVal=255, integer=true}, ["function"]="function(unit)-->nil|int>=-1"}
local nilBool = {["nil"]=true,["boolean"]=true}
local nilBoolFn = {["nil"]=true,["boolean"]=true,["function"]="function(unit)-->nil|boolean"}
local nilStringFn = {["nil"]=true,["string"]=true,["function"]="function(unit)-->nil|string"}

local unitSpecCondition = gen.valueSpecOrTable({["userdata"]={tribeObject=civ.isTribe},["string"] = traits.allTraits()})
unitSpecCondition["nil"] = true
unitSpecCondition["function"] = "function(unit)-->boolean"
local citySpecCondition = gen.valueSpecOrTable({["userdata"]={tribeObject=civ.isTribe},["string"] = traits.allTraits()})
citySpecCondition["nil"] = true
citySpecCondition["function"] = "function(city)-->boolean"
---@class customCosmic
local customCosmic = {}
gen.versionFunctions(customCosmic, versionNumber, fileModified, "LuaCore\\CustomCosmic.lua")
gen.minEventsLuaVersion(5, 1,"LuaCore\\CustomCosmic.lua")

local customCosmicDisabled = true
function customCosmic.enableCustomCosmic()
    customCosmicDisabled = false
    gen.registerCustomCosmic(customCosmic)
end

---Returns true if the customCosmic module has been enabled 
---using `cusomCosmic.enableCustomCosmic()`, and false otherwise.
---@return boolean
function customCosmic.isEnabled()
    return (not customCosmicDisabled)
end

-- customCosmic.defaultMovementMultipliers[domain][category]
-- domain is one of the following:
--      "land","air","sea",0,1,2,3
-- category is one of the following:
--      "aggregate","alpine","railroad","river","road"
local function gcd(a,b)
    while b > 0 do
        a,b = b,a%b
    end
    return a
end
local function lcm(a,b)
    return a*b//gcd(a,b)
end

local function computeLCM(road,river,rail,alpine)
    road,river,rail,alpine = math.max(road,1),math.max(river,1),math.max(rail,1),math.max(alpine,1)
    return lcm(lcm(road,river),lcm(rail,alpine))
end
local mMultSpec = mMultFn
local newMMult, isMMult, mMultMT = gen.createDataType("customCosmic movementMultiplier", {alpine=mMultSpec,railroad=mMultSpec,river=mMultSpec,road=mMultSpec} , {}, {}, {}, {})


local cCosDomainSpec = {["table"] = {[2] = "customCosmic movementMultiplier",
    [1] = function(item) 
        return isMMult(item) or "the item is not a customCosmic movementMultiplier" 
    end}}


local newCCosDefault,isCCosDefault,cCosDefaultMT = 
    gen.createDataType("customCosmic.defaultMovementMultipliers",
    {[1] = cCosDomainSpec, [2] = cCosDomainSpec, 
    [3] = cCosDomainSpec, [0] = cCosDomainSpec,}, {},{},{},
    {land=0,air=1,sea=2})


customCosmic.defaultMovementMultipliers = newCCosDefault({
    [0] = newMMult({}),
    [1] = newMMult({}),
    [2] = newMMult({}),
    [3] = newMMult({}),
})

local function isBaseTerrainInt(item)
    if not gen.isInteger(item) then
        return false
    end
    if not gen.getBaseTerrainFromID(item) then
        return false
    end
    return true
end
local function baseTerrainToIntAlias(item)
    if not civ.isBaseTerrain(item) then
        return false
    end
    return gen.getBaseTerrainID(item)
end

local makeBaseTerrainKeyTableImpassable, isBaseTerrainKeyTableImpassable, baseTerrainKeyTableImpassableMT =
    gen.createDataType("baseTerrainImpassableDataTable", {}, 
        {[isBaseTerrainInt] = {["nil"]=true,["boolean"]=true},},
        {}, {}, baseTerrainToIntAlias)


local baseTerrainKeyTableImpassableSpec = gen.valueSpecForCustomData(isBaseTerrainKeyTableImpassable, "this is not a baseTerrainImpassableDataTable","customCosmic baseTerrainImpassableDataTable")


local makeBaseTerrainKeyTableMoveCost, isBaseTerrainKeyTableMoveCost, baseTerrainKeyTableMoveCostMT =
    gen.createDataType("customCosmic baseTerrainMoveCostDataTable", {}, 
        {[isBaseTerrainInt] = {["nil"]=true,["number"]={minVal = 0, integer=true}},},
        {}, {}, baseTerrainToIntAlias)

local baseTerrainKeyTableMoveCostSpec = gen.valueSpecForCustomData(isBaseTerrainKeyTableMoveCost, "this is not a baseTerrainMoveCostDataTable", "customCosmic baseTerrainMoveCostDataTable")


local unitTypeCosmicListKeys = {
    paradropRange = nilPosInt,
    triremeLost = {["number"]={minVal=1,integer=true},["nil"]=true},
    transformBase = {["number"]={minVal=1,integer=true},["nil"]=true},
}

local makeUnitCosmicList, isUnitCosmicList, unitCosmicListMT =
    gen.createDataType("customCosmic unitTypeCosmicSettings",
    unitTypeCosmicListKeys,{},{},{},{})

local customCosmicUnitTypeCosmicSettingsSpec = gen.valueSpecForCustomData(isUnitCosmicList,"item is not a customCosmic unitTypeCosmicSettings","customCosmic unitTypeCustomSettings")

local unitTypeFlagListKeys = {
    CanCrossImpassableTerrain = nilBool,
    CanFoundCities = nilBool,
    CanImproveTiles = nilBool,
    SeeTwoSpaces = nilBool,
    IgnoreZOC = nilBool,
    Amphibious = nilBool,
    AttackAir = nilBool,
    Coastal = nilBool,
    IgnoreWalls = nilBool,
    CarryAir = nilBool,
    Paradrop = nilBool,
    Alpine = nilBool,
    DestroyedAfterAttacking = nilBool,
    SpotSubmarines = nilBool,
}

local unitTypeFlagListAliases = {
    canCrossImpassableTerrain ="CanCrossImpassableTerrain",
    canFoundCities ="CanFoundCities",
    canImproveTiles ="CanImproveTiles",
    seeTwoSpaces ="SeeTwoSpaces",
    ignoreZOC ="IgnoreZOC",
    amphibious ="Amphibious",
    coastal ="Coastal",
    ignoreWalls ="IgnoreWalls",
    carryAir ="CarryAir",
    paradrop ="Paradrop",
    alpine ="Alpine",
    destroyedAfterAttacking ="DestroyedAfterAttacking",
    spotSubmarines ="SpotSubmarines",
}

local makeUnitFlagList, isUnitFlagList, unitFlagListMT =
    gen.createDataType("customCosmic unitTypeFlagList",
    unitTypeFlagListKeys,{},{},{},unitTypeFlagListAliases)

local customCosmicUnitTypeFlagSettingsSpec = gen.valueSpecForCustomData(isUnitFlagList, "item is not a customCosmic unitTypeFlagList", "customCosmic unitTypeFlagList")



local function quickCustomDataTable(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable,aliasKeyTable)
    local makeData,isData,dataMT = gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable,aliasKeyTable)
    local customDataValueSpec = gen.valueSpecForCustomData(isData,
    "item is not a "..dataName, dataName)
    customDataValueSpec["nil"] = true
    local tableOfCustomDataSpec = gen.tableOfValueSpecification(customDataValueSpec)
    return makeData,isData, customDataValueSpec, tableOfCustomDataSpec
end

local transportKeys = {
    nativeTransport = nilBoolFn,
    buildTransport = nilBoolFn,
    useTransport = nilBoolFn,
}

local makeTransportKeys,_,transportKeysSpec,_ = 
    quickCustomDataTable("customCosmic unitType transportKeys", transportKeys, {},{}, {}, {})


local ephemeralTransportSettings = false

---Enables the nativeTransport, buildTransport, useTransport fields
-- to be altered by the customCosmic module.  Usually, these
-- fields are saved as part of the game, so game events can enable
-- or disable transport.  Those kinds of events will no longer work,
-- (unless you program them into customCosmic customisations instead).
function customCosmic.enableEphemeralMapTransportSettings()
    ephemeralTransportSettings = true
end

local unitTypeCustomisationsFixedKeys = {
-- if both of these are used, both modify movement
    atomicMovementBonus = nilIntFn,
    -- atomicMovementBonus = nil|int or function(unit)-->nil|Int
    -- Bonus movement points (compared to authoritativeDefaultRules)
    -- Positive means add, negative means subtract
    -- nil means no change
    -- if function, the returned value of function(unit) is used.
    movementBonus = nilNumFn,
    -- movementBonus = nil|num or function(unit)-->nil|num
    -- Bonus movement points (compared to authoritativeDefaultRules)
    -- whole movement points, positive means add, negative means subtract
    -- nil means no change
    -- if function, the returned value of function(unit) is used.

-- only one of these two items is permissible.  If both exist,
-- atomicCustomMovement is used
    -- if this and the movementBonus both exist, the movementBonus is
    -- added to this instead of the authoritativeDefaultRules
    -- if both are nil, refer to the authoritativeDefaultRules
    atomicCustomMovement = nilPosIntFn,
    -- atomicCustomMovement nil|int>=0 or function(unit)-->nil|int>=0
    -- Unit type will have this amount of atomic movement points,
    -- regardless of the authoritativeDefaultRules
    -- if function, the returned value of function(unit) is used.
    customMovement = nilPosNumFn,
    -- customMovement = nil|num>=0 or function(unit)--> nil|num>=0
    -- Unit type will have this amount of movement points, regardless
    -- of the authoritativeDefaultRules
    -- if function, the returned value of function(unit) is used.

-- if both of these are used, the larger one is used
    atomicMinMove = nilPosIntFn,
    -- atomicMinMove = nil|int or function(unit)-->nil|int
    -- Ensures a damaged land or sea unit will still be able
    -- to move this many atomic movement points
    -- (unless that would require setting it's unit type's atomic movement
    -- beyond 255, which can't be overcome.  If this is a problem,
    -- consider changing movement multipliers for the unit to have
    -- a lower aggregate value)
    -- nil means no minimum movement
    -- does not increase movement beyond the unit's movement allowance
    -- since a damaged unit can't have a fractional movement allowance,
    -- the effective atomicMinMove is reduced to the next lowest full
    -- movement point.
    minMove = nilPosNumFn,
    -- minMove = nil|num or function(unit)-->nil|num
    -- Ensures a damaged land or sea unit will still be able
    -- to move this many movement points
    -- (unless that would require setting it's unit type's atomic movement
    -- beyond 255, which can't be overcome.  If this is a problem,
    -- consider changing movement multipliers for the unit to have
    -- a lower aggregate value)
    -- nil means no minimum movement
    -- does not increase movement beyond the unit's movement allowance

    roadMultiplier = mMultFn,
    -- roadMultiplier = nil or int>=-1 or function(unit)-->nil int>=-1
    -- The road multiplier for the unit type
    -- nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
    -- if function, the returned value of function(unit) is used.

    railroadMultiplier = mMultFn,
    -- railroadMultiplier = nil or int>=-1 or function(unit)-->nil int>=-1
    -- The railroad multiplier for this unit type
    -- nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
    -- if function, the returned value of function(unit) is used.

    alpineMultiplier = mMultFn,
    -- alpineMultiplier = nil or int>=-1 or function(unit)-->nil int>=-1
    -- The alpine multiplier for this unit type
    -- nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
    -- if function, the returned value of function(unit) is used.

    riverMultiplier = mMultFn,
    -- riverMultiplier = nil or int>=-1 or function(unit)-->nil int>=-1
    -- The river multiplier for this unit type
    -- nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
    -- if function, the returned value of function(unit) is used.

    isImpassable = baseTerrainKeyTableImpassableSpec,
    -- isImpassable[baseTerrainObject/ID] = nil or boolean or function(unit)-->nil or boolean
    -- if true, the baseTerrain is impassable for the unit type
    -- if false, the baseTerrain is not impassable for the unit type
    -- if nil, refer to the authoritativeDefaultRules
    -- note, ID is the id generated by gen.getBaseTerrainID,
    -- but you can just use the baseTerrain object. 
    -- if function, the returned value of function(unit) is used.


    moveCost = baseTerrainKeyTableMoveCostSpec,
    -- moveCost[baseTerrainObject/ID] = nil or positiveInteger or function(unit)-->nil or positiveInteger
    -- if integer, this is the (full movement point) movement cost of the base terrain 
    -- if nil, refer to the authoritativeDefaultRules
    -- note, ID is the id generated by gen.getBaseTerrainID 
    -- if function, the returned value of function(unit) is used.

    cosmic = customCosmicUnitTypeCosmicSettingsSpec,
    -- cosmic[cosmicKey] = positiveInteger or nil or function(unit)-->posInt or nil
    -- if nil, use the value in the authoritativeDefaultRules instead
    -- possible values for cosmicKey:
    -- "paradropRange"
    -- "triremeLost"
    -- "transformBase" 
    -- if function, the returned value of function(unit) is used.

    flags = customCosmicUnitTypeFlagSettingsSpec,
    -- flags[flagKey] = nil or boolean or function(unit)-->nil or boolean
    -- if true, the unit has the flag corresponding to the flagKey
    -- if false, the unit does not have the flag corresponding to flagKey
    -- if nil, flags from the authoritativeDefaultRules are used
    -- possible values for flagKey:
    -- "canCrossImpassableTerrain"
    -- "canFoundCities"
    -- "canImproveTiles" (no effect if not settler)
    -- "seeTwoSpaces"
    -- "ignoreZOC"
    -- "amphibious"
    -- "coastal"
    -- "ignoreWalls"
    -- "carryAir"
    -- "paradrop"
    -- "alpine"
    -- "destroyedAfterAttacking"
    -- "spotSubmarines"
    -- if function, the returned value of function(unit) is used.

    condition = unitSpecCondition,
    -- condition = nil|tribeObject|traitString|function(unit)-->boolean or
    --          table of tribeObject|traitString
    -- if nil, this unit type customisation applies to all units
    -- of the relevant type(s).
    -- if tribeObject, this customisation can only apply to units
    -- owned by that tribe (as long as the unit is also of
    -- the relevant type)
    -- if traitString, this customisation applies to tribes which
    -- have the trait
    -- if table of tribeObject|traitString, this applies to any
    -- tribe or traitString in the table
    -- if function(unit) --> boolean, then this customisation
    -- applies to units of the relevant type(s) which also make this function
    -- return true
    -- Only one customisation can apply to any unit.  The priority
    -- key is used to tie break.

    priority = posNum,
    -- priority = nil or number>=0
    -- If multiple customisations can apply to a unit, this value chooses
    -- among them, with higher priority taking precedence.
    -- If the unit is eligible for two customisations of the same priority,
    -- an error may be generated, and will certainly be generated if they
    -- are of the highest priority

    customisationName = {["string"]=true},
    -- A name to be used during certain kinds of error and debugging messages
    -- nil will give "Unnamed UnitType Customisation"

-- Transport settings have no effect unless
-- customCosmic.ephemeralMapTransportSettings() has been called
-- The final transport settings are computed as follows:
-- 1. restore the unitType to the authoritativeDefaultRules transportation settings
-- 2. Apply the <something>Transport strings to the result of step 1
-- 3. apply transportXY data to the result of step 2
-- 
    
    nativeTransport = nilStringFn,
    -- nativeTransport = string
    -- governs the unitType nativeTransport field
    -- String should be 16 characters, 0,1, or x 
    -- Each of the 16 characters reference one of the possible
    -- map transport relationships.  If it is 0, the corresponding
    -- relationship is disabled, if it is 1, the corresponding
    -- relationship is enabled, and if it is x, reference the
    -- authoritativeDefaultRules
    -- if nil, use authoritativeDefaultRules, if function, 
    -- evaluate function(unit) and use the result

    buildTransport = nilStringFn,
    -- buildTransport = string
    -- governs the unitType buildTransport field
    -- String should be 16 characters, 0,1, or x 
    -- Each of the 16 characters reference one of the possible
    -- map transport relationships.  If it is 0, the corresponding
    -- relationship is disabled, if it is 1, the corresponding
    -- relationship is enabled, and if it is x, reference the
    -- authoritativeDefaultRules
    -- if nil, use authoritativeDefaultRules, if function, 
    -- evaluate function(unit) and use the result

    useTransport = nilStringFn,
    -- useTransport = string
    -- governs the unitType useTransport field
    -- String should be 16 characters, 0,1, or x 
    -- Each of the 16 characters reference one of the possible
    -- map transport relationships.  If it is 0, the corresponding
    -- relationship is disabled, if it is 1, the corresponding
    -- relationship is enabled, and if it is x, reference the
    -- authoritativeDefaultRules
    -- if nil, use authoritativeDefaultRules, if function, 
    -- evaluate function(unit) and use the result

    transport01 = transportKeysSpec,
    transport02 = transportKeysSpec,
    transport03 = transportKeysSpec,
    transport12 = transportKeysSpec,
    transport13 = transportKeysSpec,
    transport23 = transportKeysSpec,
    -- transportXY = {
    --  nativeTransport = nil|boolean or function(unit) --> nil|boolean
    --  buildTransport = nil|boolean or function(unit) --> nil|boolean
    --  useTransport = nil|boolean or function(unit) --> nil|boolean
    -- }
    -- transportXY governs the transport relationship between maps X and Y
    -- <something>Transport key is true, then the relationship between
    -- the two maps is enabled for maps X and Y in unitType.<something>Transport
    -- if it is false, the relationship is disabled
    -- if nil, use the authoritativeDefaultRules, or the relationship
    -- set out by the <something>Transport key defined above
    -- if function, evaluate function(unit) and use the result





}
-- just in case in some future, tot gets extra maps.
for x=0,gen.c.maxMapID-1 do
    for y=x+1,gen.c.maxMapID do
        local key = "transport"..tostring(x)..tostring(y)
        unitTypeCustomisationsFixedKeys[key] = transportKeysSpec
    end
end

local unitTypeCustomisationsDefaultKeys = {
    isImpassable = makeBaseTerrainKeyTableImpassable({}),
    moveCost = makeBaseTerrainKeyTableMoveCost({}),
    cosmic = makeUnitCosmicList({}),
    flags = makeUnitFlagList({}),
    customisationName = "Unnamed UnitType Customisation",
    priority = 0,
}


local makeUnitTypeCustomisationBase, isUnitTypeCustomisation, unitTypeCustomisationMT = 
gen.createDataType("customCosmic unitTypeCustomisation",unitTypeCustomisationsFixedKeys,{},unitTypeCustomisationsDefaultKeys,{},{})

local function returnTrue(object) return true end


function customCosmic.makeUnitTypeCustomisation(table)
    table = gen.copyTable(table)
    table.isImpassable = makeBaseTerrainKeyTableImpassable(table.isImpassable or {})
    table.moveCost = makeBaseTerrainKeyTableMoveCost(table.moveCost or {})
    table.cosmic = makeUnitCosmicList(table.cosmic or {})
    table.flags = makeUnitFlagList(table.flags or {})
    for x=0,gen.c.maxMapID-1 do
        for y=x+1,gen.c.maxMapID do
            local key = "transport"..tostring(x)..tostring(y)
            if table[key] then
                table[key] = makeTransportKeys(table[key])
            end
        end
    end

    local customisation = makeUnitTypeCustomisationBase(table)

    if customisation.condition == nil then
        customisation.condition = returnTrue
    elseif civ.isTribe(customisation.condition) then
        local conditionTribe = customisation.condition
        customisation.condition = function(unit) return unit.owner == conditionTribe end
    elseif type(customisation.condition) == "string" then
        local conditionTrait = customisation.condition
        customisation.condition = function(unit) return traits.hasTrait(unit.owner) end
    elseif type(customisation.condition) == "function" then
        -- do nothing here, since the condition is already a function
    elseif type(customisation.condition) == "table" then
        local conditionTable = gen.copyTable(customisation.condition)
        customisation.condition = function(unit)
            for _,tribeString in pairs(conditionTable) do
                if type(tribeString) == "string" then
                    if traits.hasTrait(unit.owner,tribeString) then
                        return true
                    end
                else
                    if unit.owner == tribeString then
                        return true
                    end
                end
            end
            return false
        end
    else
        error("customCosmic.makeUnitTypeCustomisation: the 'condition' key does not satisfy the value specification.  Ask for help.  This error should have been caught earlier in the code.  Received: "..tostring(customisation.condition))
    end
    return customisation
end
customCosmic.isUnitTypeCustomisation = isUnitTypeCustomisation

local unitTypeCustomisationList, addUnitTypeCustomisation = 
    traits.makeItemTraitListAssociation(civ.isUnitType,
        function(unitType) return unitType.id end,
        "unitTypeObject", gen.iterateUnitTypes)


---Registers a customisation for a unitType, a trait for unitTypes, or a table of unitTypes and traits for unitTypes.<br>
--[[
Keys and descriptions for unitType customisation tables:
<br>
- If both `atomicMovementBonus` and `movementBonus` are used, both modify movement.
    * `atomicMovementBonus` = nil|int or function(unit)-->nil|Int
        +  Bonus movement points (compared to authoritativeDefaultRules)
        +  Positive means add, negative means subtract
        +  nil means no change
        +  if function, the returned value of function(unit) is used.
    * `movementBonus` = nil|num or function(unit)-->nil|num
        + Bonus movement points (compared to authoritativeDefaultRules)
        + whole movement points, positive means add, negative means subtract
        + nil means no change
        + if function, the returned value of function(unit) is used.
- Only one of `atomicCustomMovement` and `customMovement` is permissible.  If both exist, `atomicCustomMovement` is used.  If this and the `movementBonus` both exist, the `movementBonus` is added to this instead of the authoritativeDefaultRules.  If both are nil, refer to the authoritativeDefaultRules.
    * `atomicCustomMovement` = nil|int>=0 or function(unit)-->nil|int>=0
        + Unit type will have this amount of atomic movement points, regardless of the authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.
    * `customMovement` = nil|num>=0 or function(unit)--> nil|num>=0
        + Unit type will have this amount of movement points, regardless of the authoritativeDefaultRules.
        + if function, the returned value of function(unit) is used.
- If both of `atomicMinMove` and `minMove` are specified, the one yielding a larger bonus is used.
    * `atomicMinMove` = nil|int or function(unit)-->nil|int
        + Ensures a damaged land or sea unit will still be able to move this many atomic movement points (unless that would require setting it's unit type's atomic movement beyond 255, which can't be overcome.  If this is a problem,
        consider changing movement multipliers for the unit to have
        a lower aggregate value)
        + nil means no minimum movement
        + does not increase movement beyond the unit's movement allowance
        + since a damaged unit can't have a fractional movement allowance,
        the effective atomicMinMove is reduced to the next lowest full
        movement point.
    * `minMove` = nil|num or function(unit)-->nil|num
        + Ensures a damaged land or sea unit will still be able to move this many movement points (unless that would require setting it's unit type's atomic movement beyond 255, which can't be overcome.  If this is a problem,
        consider changing movement multipliers for the unit to have
        a lower aggregate value)
        + nil means no minimum movement
        + does not increase movement beyond the unit's movement allowance
- Movement Multipliers have no special interactions.
    * `roadMultiplier` = nil or int>=-1 or function(unit)-->nil int>=-1
        + The road multiplier for the unit type
        + nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.
    * `railroadMultiplier` = nil or int>=-1 or function(unit)-->nil int>=-1
        + The railroad multiplier for this unit type
        + nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.
    * `alpineMultiplier` = nil or int>=-1 or function(unit)-->nil int>=-1
        + The alpine multiplier for this unit type
        + nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.
    * `riverMultiplier` = nil or int>=-1 or function(unit)-->nil int>=-1
        + The river multiplier for this unit type
        + nil means refer first to the defaultMovementMultipliers, then to authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.

- The `isImpassable` and `moveCost` keys have tables as values (or nil, if you wish to make no changes).  These tables accept either `baseTerrainObject`s as keys, or integers, as determined by `gen.getBaseTerrainID`. Using the baseTerrainObject is recommended for clarity.
    * `isImpassable[baseTerrainObject/ID]` = nil or boolean or function(unit)-->nil or boolean
        + if true, the baseTerrain is impassable for the unit type
        + if false, the baseTerrain is not impassable for the unit type
        + if nil, refer to the authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.
    * `moveCost[baseTerrainObject/ID]` = nil|int>=0 or function(unit)-->nil|int>=0
        + if integer, this is the (full movement point) movement cost of the base terrain 
        + if nil, refer to the authoritativeDefaultRules
        + if function, the returned value of function(unit) is used.

- The `cosmic` and `flag` keys have tables as values.  The `cosmic` table keys change the `civ.cosmic` fields with the same key.  The `flags` table keys are derived from General Library function names.
    * `cosmic[cosmicKey]` = int>=0|nil or function(unit)-->int>=0|nil
        + if nil, use the value in the authoritativeDefaultRules instead
        + possible values for cosmicKey:
            - "paradropRange"
            - "triremeLost"
            - "transformBase" 
        + if function, the returned value of function(unit) is used.
    * `flags[flagKey]` = nil or boolean or function(unit)-->nil or boolean
        + if true, the unit has the flag corresponding to the flagKey
        + if false, the unit does not have the flag corresponding to flagKey
        + if nil, flags from the authoritativeDefaultRules are used
        + possible values for flagKey:
            - "canCrossImpassableTerrain"
            - "canFoundCities"
            - "canImproveTiles" (no effect if not settler)
            - "seeTwoSpaces"
            - "ignoreZOC"
            - "amphibious"
            - "coastal"
            - "ignoreWalls"
            - "carryAir"
            - "paradrop"
            - "alpine"
            - "destroyedAfterAttacking"
            - "spotSubmarines"
        + if function, the returned value of function(unit) is used.
- The `condition` and `priority` keys determine which customisation table is chosen for a particular unit.  The `customisationName` key is used to give the customisation a name which is used in some error messages.
    * `condition` = nil|tribeObject|traitString|function(unit)-->boolean or table of tribeObject|traitString
        + if nil, this unit type customisation applies to all units of the relevant type(s).
        + if tribeObject, this customisation can only apply to units owned by that tribe (as long as the unit is also of the relevant type)
        + if traitString, this customisation applies to tribes which have the trait
        + if table of tribeObject|traitString, this applies to any tribe or traitString in the table
        + if function(unit) --> boolean, then this customisation applies to units of the relevant type(s) which also make this function return true
        + Only one customisation can apply to any unit.  The `priority` key is used to tie break.
    * `priority` = nil or number>=0
        + If multiple customisations can apply to a unit, this value chooses among them, with higher priority taking precedence.
        + If the unit is eligible for two customisations of the same priority, an error may be generated, and will certainly be generated if they are of the highest priority.
    * `customisationName` = nil|string,
        + A name to be used during certain kinds of error and debugging messages
        + nil will give "Unnamed UnitType Customisation"
- Transport settings have no effect unless `customCosmic.ephemeralMapTransportSettings()` has been called.  The final transport settings are computed as follows:
<br>1. restore the unitType to the authoritativeDefaultRules transportation settings
<br>2. Apply the <something>Transport strings to the result of step 1
<br>3. Apply transportXY data to the result of step 2
    * `nativeTransport` = string|nil or function(unit) --> string|nil
        + Governs the unitType nativeTransport field
        + String should be 16 characters, 0,1, or x 
        + Each of the 16 characters reference one of the possible map transport relationships.  If it is 0, the corresponding relationship is disabled, if it is 1, the corresponding relationship is enabled, and if it is x, reference the authoritativeDefaultRules
        + if nil, use authoritativeDefaultRules, if function, 
        + evaluate function(unit) and use the result

    * `buildTransport` = string|nil or function(unit) --> string|nil
        + Governs the unitType buildTransport field
        + String should be 16 characters, 0,1, or x 
        + Each of the 16 characters reference one of the possible map transport relationships.  If it is 0, the corresponding relationship is disabled, if it is 1, the corresponding relationship is enabled, and if it is x, reference the authoritativeDefaultRules
        + if nil, use authoritativeDefaultRules, if function, 
        + evaluate function(unit) and use the result
    * `useTransport` = string|nil or function(unit) --> string|nil
        + Governs the unitType useTransport field
        + String should be 16 characters, 0,1, or x 
        + Each of the 16 characters reference one of the possible map transport relationships.  If it is 0, the corresponding relationship is disabled, if it is 1, the corresponding relationship is enabled, and if it is x, reference the authoritativeDefaultRules
        + if nil, use authoritativeDefaultRules, if function, 
        + evaluate function(unit) and use the result

    * `transportXY` = {
    <br> nativeTransport = nil|boolean or function(unit) --> nil|boolean
    <br> buildTransport = nil|boolean or function(unit) --> nil|boolean
    <br> useTransport = nil|boolean or function(unit) --> nil|boolean
    <br>}
        + transportXY governs the transport relationship between maps X and Y
        + if `somethingTransport` key is true, then the relationship between the two maps is enabled for maps X and Y in unitType.somethingTransport
        + if it is false, the relationship is disabled
        + if nil, use the authoritativeDefaultRules, or the relationship set out by the somethingTransport key defined above
        + if function, evaluate function(unit) and use the result
        + `transportXY` represents the following available keys:
            - `transport01`
            - `transport02`
            - `transport03`
            - `transport12`
            - `transport13`
            - `transport23`
--]]
---@param unitTypeOrTrait unitTypeObject|string|table<any,unitTypeObject|string>
---@param unitTypeCustomisation table
function customCosmic.registerUnitTypeCustomisation(unitTypeOrTrait,unitTypeCustomisation)
    if not isUnitTypeCustomisation(unitTypeCustomisation) then
        unitTypeCustomisation = customCosmic.makeUnitTypeCustomisation(unitTypeCustomisation)
    end
    local unitTypeTable = gen.tableWrap(unitTypeOrTrait)
    for _,unitTypeOrTrait in pairs(unitTypeTable) do
        addUnitTypeCustomisation(unitTypeOrTrait,unitTypeCustomisation)
    end
end

local emptyUnitCustomisation = customCosmic.makeUnitTypeCustomisation({priority = 0, customisationName = "Empty Unit Customisation"})
rawset(emptyUnitCustomisation,"priority",-1)

---Returns an 'empty' unitTypeCustomisation, with priority set to -1
---@return table
function customCosmic.getEmptyUnitTypeCustomisation()
    return emptyUnitCustomisation
end

local function getUnitTypeCustomisation(unit)
    local customList = unitTypeCustomisationList(unit.type)
    local priorityCustomisation = emptyUnitCustomisation
    for customisation,_ in pairs(customList) do
        -- during the creation of the customisation, non-function
        -- values for 'condition' are replaced with functions
        if customisation.condition(unit) then
            if customisation.priority > priorityCustomisation.priority then
                priorityCustomisation = customisation
            elseif customisation.priority == priorityCustomisation.priority then
                error("customCosmic: unitType customisation conflict ("..unit.type.name.."): the unit: "..tostring(unit).." satisfies customisation "..customisation.customisationName.." as well as "..priorityCustomisation.customisationName..", which both have priority "..tostring(customisation.priority)..".")
            end
        end
    end
    return priorityCustomisation
end

---Returns the unitTypeCustomisation for `unit`.
---@param unit unitObject
---@return table
function customCosmic.getUnitTypeCustomisation(unit)
    return getUnitTypeCustomisation(unit)
end

---Allows a scenario designer to register a function(unit)-->unitTypeCustomisation
--to be used instead of the `customCosmic.registerUnitTypeCustomisation` system.
--The function must return a unitTypeCustomisation for every unit
--under all circumstances
---@param fun fun(unit: unitObject):table
function customCosmic.registerGetUnitTypeCustomisation(fun)
    getUnitTypeCustomisation = fun
end

local function makeUnitEval(unit)
    return function(val)
        if type(val) == "function" then
            return val(unit)
        else
            return val
        end
    end
end

---Returns the movementMultipliers for `unit` in a table.
---@param unit unitObject
---@param customisation? table
---@return {alpine:integer,road:integer,railroad:integer,river:integer,aggregate:integer}
function customCosmic.getMovementMultipliers(unit,customisation)
    if customCosmicDisabled then
        return {
            alpine = totpp.movementMultipliers.alpine,
            aggregate = totpp.movementMultipliers.aggregate,
            road = totpp.movementMultipliers.road,
            railroad = totpp.movementMultipliers.railroad,
            river = totpp.movementMultipliers.river,
        }
    end
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    ---@cast customisation table
    local s = makeUnitEval(unit)
    local customCosmicDefaults = customCosmic.defaultMovementMultipliers[unit.type.domain]
    local rulesDefaults = changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]
    local customMultipliers = {
        alpine = s(customisation.alpineMultiplier) or s(customCosmicDefaults.alpine) or rulesDefaults.alpine,
        road = s(customisation.roadMultiplier) or s(customCosmicDefaults.road) or rulesDefaults.road,
        railroad = s(customisation.railroadMultiplier) or s(customCosmicDefaults.railroad) or rulesDefaults.railroad,
        river = s(customisation.riverMultiplier) or s(customCosmicDefaults.river) or rulesDefaults.river,
    }
    local aggregate = computeLCM(customMultipliers.road,customMultipliers.river,
        customMultipliers.railroad,customMultipliers.alpine)
    customMultipliers.aggregate = aggregate
    return customMultipliers
end

-- if a and b are not nil, multiply them and return the floor
---@param a nil|number
---@param b nil|number
---@return integer|nil
local function nilMultFloor(a,b)
    return a and b and math.floor(a*b)
end


local function makeIsFlag(capitalisedFlagName)
    local genIsFn = gen["is"..capitalisedFlagName]
    local function isThisFlag(unit,customisation)
        if not isUnitTypeCustomisation(customisation) then
            customisation = customCosmic.getUnitTypeCustomisation(unit) 
        end
        local s = makeUnitEval(unit)
        local customFlag = s(customisation.flags[capitalisedFlagName])
        if customFlag == nil then
            customFlag = genIsFn(changeRules.authoritativeDefaultRules[unit.type])
        end
        return customFlag
    end
    return isThisFlag
end

local unitFlagCheckList = {}
local unitFlagGiveList = {}
local unitFlagRemoveList = {}
for _,capitalisedFlagName in pairs(unitTypeFlagListAliases) do
    customCosmic["is"..capitalisedFlagName] = makeIsFlag(capitalisedFlagName)
    unitFlagCheckList[capitalisedFlagName] = customCosmic["is"..capitalisedFlagName] 
    unitFlagGiveList[capitalisedFlagName] = gen["give"..capitalisedFlagName]
    unitFlagRemoveList[capitalisedFlagName] = gen["remove"..capitalisedFlagName]
end

---comment
---@param unit unitObject
---@param aggMult integer
---@param proposedMaxMove integer
---@return integer
local function expectedMoveAllowance(unit,aggMult,proposedMaxMove)
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(gen.original.aNuclearPower) then
            proposedMaxMove = proposedMaxMove+aggMult
        end
        -- apply magellan's and lighthouse
        if gen.isWonderActiveForTribe(gen.original.wMagellansExpedition,unit.owner) then
            proposedMaxMove = proposedMaxMove+2*aggMult
        end
        if gen.isWonderActiveForTribe(gen.original.wLighthouse,unit.owner) and not customCosmic.isCoastal(unit) then
            proposedMaxMove = proposedMaxMove + aggMult
        end
    end
    local moveAllowance = (unit.hitpoints*proposedMaxMove)//unit.type.hitpoints
    if moveAllowance % aggMult > 0 then
        moveAllowance = moveAllowance - (moveAllowance % aggMult) + aggMult
    end
    if unit.type.domain == 0 then
        return math.min(math.max( moveAllowance,aggMult),moveAllowance)
    elseif unit.type.domain == 1 then
        return moveAllowance
    elseif unit.type.domain == 2 then
        return math.min(math.max( moveAllowance,2*aggMult),moveAllowance)
    else
        -- domain 3 or more act as domain 0
        return math.min(math.max( moveAllowance,aggMult),moveAllowance)
    end
end

local function getNecessaryMoveValue(unit,aggMult,minAllowance,fullHPMove)
    if expectedMoveAllowance(unit,aggMult,fullHPMove) >= minAllowance then
        return fullHPMove
    end
    local highMax = 255 -- this is known to be higher than the correct MaxMove
    local lowMax = minAllowance -- this is known to be lower than correct maxMove
    local proposedMaxMove = math.floor(0.5*(highMax+lowMax))
    local expectedAllowance = expectedMoveAllowance(unit,aggMult,proposedMaxMove)
    for loopCount = 0,255 do
        if expectedAllowance == minAllowance or proposedMaxMove == 255 then
            return proposedMaxMove
        elseif expectedAllowance < minAllowance then
            lowMax = proposedMaxMove
            proposedMaxMove = math.ceil(0.5*(lowMax+highMax))
            expectedAllowance = expectedMoveAllowance(unit,aggMult,proposedMaxMove)
        else
            highMax = proposedMaxMove
            proposedMaxMove = math.floor(0.5*(lowMax+highMax))
            expectedAllowance = expectedMoveAllowance(unit,aggMult,proposedMaxMove)
        end
    end
    error("customCosmic.computeMovementAllowance (helper function: getNecessaryMoveValue): failed to find a solution for unit "..tostring(unit))
end

---Computes the movement allowance for the unit if it is at full health. 
---@param unit unitObject
---@param customisation? table # If not defined, customCosmic.getUnitTypeCustomisation is called to retrieve it.
---@return integer
function customCosmic.fullHealthMovementAllowance(unit,customisation)
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    ---@cast customisation table
    local movementMultipliers = customCosmic.getMovementMultipliers(unit, customisation)
    local s = makeUnitEval(unit)
    local aggMult = movementMultipliers.aggregate
    local fullHPMove = s(customisation.atomicCustomMovement) or 
        nilMultFloor(s(customisation.customMovement),aggMult) or 
        (changeRules.authoritativeDefaultRules[unit.type].move*aggMult)
    
    fullHPMove = fullHPMove + (s(customisation.atomicMovementBonus) or 0)
    fullHPMove = fullHPMove + (nilMultFloor(s(customisation.movementBonus),aggMult) or 0)

    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(gen.original.aNuclearPower) then
            fullHPMove = fullHPMove+aggMult
        end
        -- apply magellan's and lighthouse
        if gen.isWonderActiveForTribe(gen.original.wMagellansExpedition,unit.owner) then
            fullHPMove = fullHPMove+2*aggMult
        end
        if gen.isWonderActiveForTribe(gen.original.wLighthouse,unit.owner) and not customCosmic.isCoastal(unit) then
            fullHPMove = fullHPMove + aggMult
        end
    end
    return fullHPMove
end

---Computes the value that `unit.type.move` should have so that `unit` satisfies
---all its customisations.
---@param unit unitObject
---@param customisation? table # If not defined, customCosmic.getUnitTypeCustomisation is called to retrieve it.
---@return integer
function customCosmic.computeMovementAllowance(unit,customisation)
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    ---@cast customisation table
    local movementMultipliers = customCosmic.getMovementMultipliers(unit, customisation)
    local s = makeUnitEval(unit)
    local aggMult = movementMultipliers.aggregate
    local fullHPMove = customCosmic.fullHealthMovementAllowance(unit,customisation)
    local atomicMinMove = s(customisation.atomicMinMove) or 0
    atomicMinMove = atomicMinMove - (atomicMinMove % aggMult) -- minMove can't be a fractional movement point
    local fullMinMove = nilMultFloor(s(customisation.minMove),aggMult) or 0
    -- don't give the unit more than its maximum movement allotment anyway
    local minMove = math.min(fullHPMove,math.max(atomicMinMove,fullMinMove))
    return getNecessaryMoveValue(unit, aggMult, minMove, fullHPMove)
end

local function setUnitTypeFlagsForUnit(unit,customisation)
    local unitType = unit.type
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    for capitalisedFlagName,customCosmicCheckFn in pairs(unitFlagCheckList) do
        if customCosmicCheckFn(unit,customisation) then
            -- true arg necessary to suppress canImproveTiles error
            unitFlagGiveList[capitalisedFlagName](unitType,true)
        else
            -- true arg necessary to suppress canImproveTiles error
            unitFlagRemoveList[capitalisedFlagName](unitType,true)
        end
    end
end



local function setCosmicForUnit(unit,customisation)
    local s = makeUnitEval(unit)
    local rulesDefaults = changeRules.authoritativeDefaultRules["civ.cosmic"]
    for key,_ in pairs(unitTypeCosmicListKeys) do
        civ.cosmic[key] = s(customisation.cosmic[key]) or rulesDefaults[key]
    end
    local multipliers = customCosmic.getMovementMultipliers(unit, customisation)
    totpp.movementMultipliers.road = multipliers.road
    totpp.movementMultipliers.railroad = multipliers.railroad
    totpp.movementMultipliers.river = multipliers.river
    totpp.movementMultipliers.alpine = multipliers.alpine
end

---Determines if a terrain type is impassable for the specified unit.
---@param baseTerrain baseTerrainObject
---@param unit unitObject
---@param customisation nil|table
---@param s? nil|fun(value: any):any 
---@param defaultRules? nil|table
---@return boolean
local function isImpassableFor(baseTerrain,unit,customisation,s,defaultRules)
    s = s or makeUnitEval(unit)
    defaultRules = defaultRules or changeRules.authoritativeDefaultRules
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    ---@cast customisation table
    local impassable = s(customisation.isImpassable[baseTerrain])
    if impassable == nil then
        impassable = defaultRules[baseTerrain].impassable
    end
    return impassable
end

---Determines if a base terrain type is impassable for the specified unit.
---@param baseTerrain baseTerrainObject
---@param unit unitObject
---@param customisation nil|table # if nil, the customisation is retrieved by calling `customCosmic.getUnitTypeCustomisation`
---@return boolean
function customCosmic.isImpassableFor(baseTerrain,unit,customisation)
    return isImpassableFor(baseTerrain,unit,customisation)
end

local baseTerrainList = {}
for i=0,63 do
    baseTerrainList[1+#baseTerrainList] = gen.getBaseTerrainFromID(i)
end


local function setBaseTerrainForUnit(unit,customisation)
    local s = makeUnitEval(unit)
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    local defaultRules = changeRules.authoritativeDefaultRules
    for _,baseTerrain in pairs(baseTerrainList) do
        ---@cast baseTerrain baseTerrainObject
        baseTerrain.impassable = isImpassableFor(baseTerrain,unit,customisation,s,defaultRules)
        baseTerrain.moveCost = s(customisation.moveCost[baseTerrain]) or defaultRules[baseTerrain].moveCost
    end
end

local function computeTransportXY(unitType,key,map1,map2,transportVal,s)
    if not transportVal then
        return
    end
    local innerVal = s(transportVal[key])
    if innerVal == nil then
        return
    elseif innerVal == true then
        unitType[key] = gen.giveTransportBetweenMaps(map1,map2,unitType[key],false)
    elseif innerVal == false then
        unitType[key] = gen.removeTransportBetweenMaps(map1,map2,unitType[key],false)
    else
        error("customCosmic: computeTransportXY, "..tostring(unitType).. "has invalid "..key.." settings for map "..tostring(map1).." and "..tostring(map2)..": "..tostring(innerVal))
    end

end

local function setTransportFlagsForUnit(unit,customisation)
    if not ephemeralTransportSettings then
        return
    end
    if not isUnitTypeCustomisation(customisation) then
        customisation = customCosmic.getUnitTypeCustomisation(unit) 
    end
    local s = makeUnitEval(unit)
    local unitType = unit.type
    local default = changeRules.authoritativeDefaultRules[unitType]
    for key,_ in pairs(transportKeys) do
        unitType[key] = default[key]
        local bitString = s(customisation[key])
        if bitString then
            unitType[key] = gen.setBits(unitType[key],bitString)
        end
        computeTransportXY(unitType,key,0,1,customisation.transport01,s)
        computeTransportXY(unitType,key,0,2,customisation.transport02,s)
        computeTransportXY(unitType,key,0,3,customisation.transport03,s)
        computeTransportXY(unitType,key,1,2,customisation.transport12,s)
        computeTransportXY(unitType,key,1,3,customisation.transport13,s)
        computeTransportXY(unitType,key,2,3,customisation.transport23,s)
    end
end


discreteEvents.onScenarioLoaded(function()
    if customCosmicDisabled then
        return
    end
    for unitType in gen.iterateUnitTypes() do
        unitType.move = 255
    end
end)


local previousUnitForChangeEphemeralForUnit = nil
---Changes the ephemeral rules so that the unit customisations
---will work
---@param unit unitObject
function customCosmic.changeEphemeralForUnit(unit)
    if customCosmicDisabled then
        return
    end
    local previousUnit = previousUnitForChangeEphemeralForUnit
    previousUnitForChangeEphemeralForUnit = unit
    if previousUnit and previousUnit ~= unit then
        if previousUnit.moveSpent < 255 and (gen.moveRemaining(unit) <= 0) then
            previousUnit.moveSpent = 255
        end
        previousUnit.type.move = 255
    end
    local customisation = customCosmic.getUnitTypeCustomisation(unit) 
    setCosmicForUnit(unit, customisation)
    setBaseTerrainForUnit(unit, customisation)
    setUnitTypeFlagsForUnit(unit,customisation)
    setTransportFlagsForUnit(unit, customisation)
    unit.type.move = customCosmic.computeMovementAllowance(unit, customisation)
end








local cityImprovementKeys = {
    cantSell = nilBoolFn,
    cost = nilPosIntFn,
    costModifier = nilIntFn,
    upkeep = nilPosIntFn,
    upkeepModifier = nilIntFn,
    onCapture = {["nil"]=true,["number"]={minVal=0,maxVal=3,integer=true}, ["function"]="function(city)-->0,1,2,3"},
}

local makeCityImprovementKey, _,cityImprovementKeysSpec,_ =
    quickCustomDataTable("customCosmic improvementKeys for City", cityImprovementKeys, {},{},{},{})


local cityWonderKeys = {
    cost = nilPosIntFn,
    costModifier = nilIntFn,
}
local makeWonderKey, _,cityWonderKeysSpec,_ =
    quickCustomDataTable("customCosmic wonderKeys for City", cityWonderKeys, {},{},{},{})

local cityUnitTypeKeys = {
    cost = nilPosIntFn,
    costModifier = nilIntFn,
}
local makeCityUnitTypeKey, _,cityUnitTypeKeysSpec,_ =
    quickCustomDataTable("customCosmic UnitTypeKeys for City", cityUnitTypeKeys, {},{},{},{})

local cityBaseTerrainKeys = {
    irrigateBonus = nilPosIntFn,
    irrigateBonusModifier = nilIntFn,
    mineBonus = nilPosIntFn,
    mineBonusModifier = nilIntFn,
    roadTrade = nilBoolFn,
}
local makeBaseTerrainKey, _,cityBaseTerrainKeysSpec,_ =
    quickCustomDataTable("customCosmic BaseTerrainKeys for City", cityBaseTerrainKeys, {},{},{},{})

local cityTerrainKeys = {
    food = nilPosIntFn,
    foodModifier = nilIntFn,
    shields = nilPosIntFn,
    shieldsModifier = nilIntFn,
    trade = nilPosIntFn,
    tradeModifier = nilIntFn,
}
local makeTerrainKey, _,cityTerrainKeysSpec,_ =
    quickCustomDataTable("customCosmic TerrainKeys for City", cityTerrainKeys, {},{},{},{})


local cityChangeableCosmicKeys = {
    communismPalaceDistance = true,
    foodEaten = true,
    prodChangePenalty= true,
    riotFactor= true,
    scienceLostFundamentalism= true,
    scienceRateFundamentalism= true,
    sizeUnhappiness= true,
}

local cityCustomCosmicListKeys = {
    communismPalaceDistance = nilPosIntFn,
    -- communismPalaceDistance = nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.communismPalaceDistance 
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    communismPalaceDistanceModifier = nilIntFn,
    -- communismPalaceDistanceModifier = nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.communismPalaceDistance 
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    foodEaten = nilPosIntFn,
    -- foodEaten = nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.foodEaten 
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    foodEatenModifier = nilIntFn,
    -- foodEatenModifier = nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.foodEaten 
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    prodChangePenalty= nilPosIntFn,
    -- prodChangePenalty= nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.prodChangePenalty
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    prodChangePenaltyModifier= nilIntFn,
    -- prodChangePenaltyModifier= nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.prodChangePenalty
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    riotFactor= nilPosIntFn,
    -- riotFactor= nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.riotFactor
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    riotFactorModifier = nilIntFn,
    -- riotFactorModifier = nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.riotFactor
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    scienceLostFundamentalism= nilPosIntFn,
    -- scienceLostFundamentalism= nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.scienceLostFundamentalism
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    scienceLostFundamentalismModifier= nilIntFn,
    -- scienceLostFundamentalismModifier= nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.scienceLostFundamentalism
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    scienceRateFundamentalism= nilPosIntFn,
    -- scienceRateFundamentalism= nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.scienceRateFundamentalism
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    scienceRateFundamentalismModifier= nilIntFn,
    -- scienceRateFundamentalismModifier= nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.scienceRateFundamentalism
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    sizeUnhappiness= nilPosIntFn,
    -- sizeUnhappiness= nil|int>=0 or function(city) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.sizeUnhappiness
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the city as the argument.
    sizeUnhappinessModifier= nilIntFn,
    -- sizeUnhappinessModifier= nil|int or function(city) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.sizeUnhappiness
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the city as the argument.
    customisationName = {["string"]=true},
    -- A name to be used during certain kinds of error and debugging messages
    -- nil will give "Unnamed City Customisation"
    condition = citySpecCondition,
    -- condition = nil|tribeObject|traitString|function(city)-->boolean or
    --          table of tribeObject|traitString
    -- if nil, this customisation applies to all cities (unless a higher 
    -- priority customisation also applies)
    -- if tribeObject, this customisation applies to cities owned by
    -- the tribe
    -- if traitString, this customisation applies to tribes which have the
    -- trait
    -- if table of tribeObject|traitString, this applies to any tribe or
    -- traitString in the table
    -- if function(city) --> boolean, then this customisation applies to
    -- cities which make this function return true
    -- only one customisation can apply to any city.  The priority key
    -- is used to tie break.
    priority = posNum,
    -- priority = nil or number >= 0
    -- If multiple customisations can apply to a city, this value chooses
    -- among them, with higher priority taking precedence.
    -- If the city is eligible for two customisations of the same priority,
    -- an error may be generated, and will certainly be generated if they
    -- are of the highest priority.


    -- [unitTypeObject] = {
    --          cost = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base cost (in shield rows) for the city
    --              If nil, refer to authoritativeDefaultRules
    --              If function, use result after evaluating function(city)
    --          costModifier = nil|int or function(city)-->nil|int
    --              Add this to the base cost, but cost won't be less than 0
    --              If nil, use 0
    --              If function, use result after evaluating function(city)
    --          }

    -- [improvementObject] = {
    --          cost = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base cost (in shield rows) for the city
    --              If nil, refer to authoritativeDefaultRules
    --              If function, use result after evaluating function(city)
    --          costModifier = nil|int or function(city)-->nil|int
    --              Add this to the base cost, but cost won't be less than 0
    --              If nil, use 0
    --              If function, use result after evaluating function(city)
    --          cantSell = nil|boolean or function(city)-->nil|boolean
    --              If true, the city can't sell the improvement, if false,
    --              it can.
    --              If nil, refer to the authoritativeDefaultRules
    --          upkeep = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base upkeep (gold per turn) this improvement 
    --              in this city.
    --              If nil, refer to authoritativeDefaultRules
    --              If function, use result after evaluating function(city)
    --              Note: Upkeep costs will be calculated correctly during city
    --              processing, but the Tax Rate and Trade Adviser windows will
    --              not be correct if the upkeep isn't the same for all cities
    --              (Costs for the most recently looked at city will be used.)
    --          upkeepModifier = nil|int or function(city)-->nil|int
    --              Add this to the base upkeep, but upkeep won't be less than 0
    --              If nil, use 0
    --              If function, use result after evaluating function(city)
    --          
    -- [wonderObject] = {
    --          cost = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base cost (in shield rows) for the city
    --              If nil, refer to authoritativeDefaultRules
    --              If function, use result after evaluating function(city)
    --          costModifier = nil|int or function(city)-->nil|int
    --              Add this to the base cost, but cost won't be less than 0
    --              If nil, use 0
    --              If function, use result after evaluating function(city)
    --          }
    --              
    -- [baseTerrainObject] = {
    --          irrigateBonus = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base value of the irrigation bonus for the
    --              city and baseTerrain.
    --              If nil, refer to the authoritativeDefaultRules,
    --              If function, use the result of function(city), 
    --          irrigateBonusModifier = nil|int or function(city)-->nil|int
    --              Add this to the base irrigation bonus, but results less
    --              than 0 will be set to 0.
    --              If nil, use 0.
    --              If function, use result after evaluating function(city)
    --          mineBonus = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base value of the mining bonus for the
    --              city and baseTerrain.
    --              If nil, refer to the authoritativeDefaultRules,
    --              If function, use the result of function(city), 
    --          mineBonusModifier = nil|int or function(city)-->nil|int
    --              Add this to the base mining bonus, but results less
    --              than 0 will be set to 0.
    --              If nil, use 0.
    --              If function, use result after evaluating function(city)
    --          roadTrade = nil|boolean or function(city)-->nil|boolean
    --              If true, for this city and baseTerrain, the road trade
    --              bonus is applied.  If false, it is not.
    --              If nil, refer to the authoritativeDefaultRules

    -- [terrainObject] = {
    --          food = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base value for the food produced for this
    --              city by this terrain type.
    --              If nil, refer to the authoritativeDefaultRules
    --              If function, use the result of function(city)
    --          foodModifier = nil|int or function(city)-->nil|int
    --              Add this to the base food production value, but
    --              if the result is less than 0, it will be raised to 0.
    --              If nil, use 0.
    --              If function, use the result of function(city) 
    --          shields = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base value for the shields produced for this
    --              city by this terrain type.
    --              If nil, refer to the authoritativeDefaultRules
    --              If function, use the result of function(city)
    --          shieldsModifier = nil|int or function(city)-->nil|int
    --              Add this to the base shield production value, but
    --              if the result is less than 0, it will be raised to 0.
    --              If nil, use 0.
    --              If function, use the result of function(city) 
    --          trade = nil|int>=0 or function(city)-->nil|int>=0
    --              Sets the base value for the trade produced for this
    --              city by this terrain type.
    --              If nil, refer to the authoritativeDefaultRules
    --              If function, use the result of function(city)
    --          tradeModifier = nil|int or function(city)-->nil|int
    --              Add this to the base trade production value, but
    --              if the result is less than 0, it will be raised to 0.
    --              If nil, use 0.
    --              If function, use the result of function(city) 

    -- bulk assignment
    -- [keyTable] = data
    --  For each value in the keyTable, if value is not a trait,
    --  assign customisation[value] = gen.copyTable(data)
    --  if the value is a trait, for each ITEM such that
    --  traits.hasTrait(ITEM,value) is true, assign
    --  customisation[ITEM] = gen.copyTable(data)
}
local cityCustomCosmicDefaultKeys = {
    priority = 0,
    customisationName = "Unnamed City Customisation",
}

local improvementOffset = gen.c.maxUnitTypes
local wonderOffset = improvementOffset + gen.c.maxImprovements
local baseTerrainOffset = wonderOffset + gen.c.maxWonders
local terrainOffset = baseTerrainOffset + gen.c.maxBaseTerrains
local endOffset = terrainOffset + gen.c.maxTerrains
for i=0,endOffset-1 do
    if i < improvementOffset then
        cityCustomCosmicListKeys[i] = cityUnitTypeKeysSpec
    elseif i < wonderOffset then
        cityCustomCosmicListKeys[i] = cityImprovementKeysSpec
    elseif i < baseTerrainOffset then
        cityCustomCosmicListKeys[i] = cityWonderKeysSpec
    elseif i < terrainOffset then
        cityCustomCosmicListKeys[i] = cityBaseTerrainKeysSpec
    elseif i < endOffset then
        cityCustomCosmicListKeys[i] = cityTerrainKeysSpec
    end
end

local cityCustomCosmicAliasKeys = function(item)
    if type(item) ~= "userdata" then
        if item == "sizeAqueduct" then
            return "sizeAquaduct"
        elseif item == "sizeAqueductModifier" then
            return "sizeAquaductModifier"
        end
        return item
    elseif civ.isUnitType(item) then
        return item.id
    elseif civ.isImprovement(item) then
        return improvementOffset + item.id
    elseif civ.isWonder(item) then
        return wonderOffset + item.id
    elseif civ.isBaseTerrain(item) then
        return baseTerrainOffset + gen.getBaseTerrainID(item)
    elseif civ.isTerrain(item) then
        return terrainOffset + gen.getTerrainID(item)
    else
        return item
    end
end

local makeCityCustomisationBase, isCityCustomisation, cityCustomisationMT =
    gen.createDataType("customCosmic cityCustomisation",cityCustomCosmicListKeys,{},cityCustomCosmicDefaultKeys,{},cityCustomCosmicAliasKeys)

local function iterateEverything()
    return coroutine.wrap(function()
        for unitType in gen.iterateUnitTypes() do
            coroutine.yield(unitType)
        end
        for improvement in gen.iterateImprovements() do
            coroutine.yield(improvement)
        end
        for wonder in gen.iterateImprovements() do
            coroutine.yield(wonder)
        end
        for baseTerrain in gen.iterateBaseTerrain() do
            coroutine.yield(baseTerrain)
        end
        for terrain in gen.iterateTerrain() do
            coroutine.yield(terrain)
        end
    end)
end

local function bulkKeyAssignment(customisation)
    local traitList = traits.allTraits()
    for keyTable,value in pairs(customisation) do
        if type(keyTable) == "table" then
            for _,key in pairs(keyTable) do
                if type(key) == "string" and traitList[key] then
                    for item in iterateEverything() do
                        if traits.hasTrait(item,key) then
                            customisation[item] = gen.copyTable(value)
                        end
                    end
                else
                    customisation[key] = gen.copyTable(value)
                end
            end
            customisation[keyTable] = nil
        end
    end
end
function customCosmic.makeCityCustomisation(table)
    table = gen.copyTable(table)
    bulkKeyAssignment(table)
    for key,val in pairs(table) do
        if civ.isUnitType(key) then
            table[key] = makeCityUnitTypeKey(table[key])
        elseif civ.isImprovement(key) then
            table[key] = makeCityImprovementKey(table[key])
        elseif civ.isWonder(key) then
            table[key] = makeWonderKey(table[key])
        elseif civ.isBaseTerrain(key) then
            table[key] = makeBaseTerrainKey(table[key])
        elseif civ.isTerrain(key) then
            table[key] = makeTerrainKey(table[key])
        end

    end

    local customisation = makeCityCustomisationBase(table)

    if customisation.condition == nil then
        customisation.condition = returnTrue
    elseif civ.isTribe(customisation.condition) then
        local conditionTribe = customisation.condition
        customisation.condition = function(city) return city.owner == conditionTribe end
    elseif type(customisation.condition) == "string" then
        local conditionTrait = customisation.condition
        customisation.condition = function(city) return traits.hasTrait(city.owner,conditionTrait) end
    elseif type(customisation.condition) == "function" then
        -- do nothing here, since the condition is already a function
    elseif type(customisation.condition) == "table" then
        local conditionTable = gen.copyTable(customisation.condition)
        customisation.condition = function(city)
            for _,tribeString in pairs(conditionTable) do
                if type(tribeString) == "string" then
                    if traits.hasTrait(city.owner,tribeString) then
                        return true
                    end
                else
                    if city.owner == tribeString then
                        return true
                    end
                end
            end
            return false
        end
    else
        error("customCosmic.makecityTypeCustomisation: the 'condition' key does not satisfy the value specification.  Ask for help.  This error should have been caught earlier in the code.  Received: "..tostring(customisation.condition))
    end
    return customisation
end


-- cityCustomisationTable = {[index]=cityCustomisation}
local cityCustomisationTable = {}

--Registers a customisation for cities.<br>
--Keys and descriptions for city customisation tables:
--[[

- These keys are used to change cosmic parameters that relate to city 
production.  Some cosmic parameters relating to city production are in the tribe
customisations, because they are used before code in onCalculateCityYield can
change them.
    * `communismPalaceDistance` = nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.communismPalaceDistance 
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `communismPalaceDistanceModifier` = nil|int or function(city) --> nil|int
        + Add this to the base value to be used for civ.cosmic.communismPalaceDistance 
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
    * `foodEaten` = nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.foodEaten 
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `foodEatenModifier` = nil|int or function(city) --> nil|int
        + Add this to the base value to be used for civ.cosmic.foodEaten 
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
    * `prodChangePenalty`= nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.prodChangePenalty
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `prodChangePenaltyModifier`= nil|int or function(city) --> nil|int
        + Add this to the base value to be used for civ.cosmic.prodChangePenalty
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
    * `riotFactor`= nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.riotFactor
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `riotFactorModifier` = nil|int or function(city) --> nil|int
        + Add this to the base value to be used for civ.cosmic.riotFactor
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
    * `scienceLostFundamentalism`= nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.scienceLostFundamentalism
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `scienceLostFundamentalismModifier`= nil|int or function(city) --> nil|int
        + Add this to the base value to be used for civ.cosmic.scienceLostFundamentalism
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
    * `scienceRateFundamentalism`= nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.scienceRateFundamentalism
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `scienceRateFundamentalismModifier`= nil|int or function(city) --> nil|int
        + Add this to the base value to be used for civ.cosmic.scienceRateFundamentalism
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
    * `sizeUnhappiness`= nil|int>=0 or function(city) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.sizeUnhappiness
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the city as the argument.
    * `sizeUnhappinessModifier`= nil|int or function(city) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.sizeUnhappiness
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the city as the argument.
- The `condition` and `priority` keys determine which customisation table is chosen for a particular city.  The `customisationName` key is used to give the customisation a name which is used in some error messages.
    * `customisationName` = nil|string
        + A name to be used during certain kinds of error and debugging messages
        + nil will give "Unnamed City Customisation"
    * `condition` = nil|tribeObject|traitString|function(city)-->boolean or table of tribeObject|traitString
        + if nil, this customisation applies to all cities (unless a higher  priority customisation also applies)
        + if tribeObject, this customisation applies to cities owned by the tribe
        + if traitString, this customisation applies to tribes which have the trait
        + if table of tribeObject|traitString, this applies to any tribe or traitString in the table
        + if function(city) --> boolean, then this customisation applies to cities which make this function return true
        + only one customisation can apply to any city.  The `priority` key is used to tie break.
    * `priority` = nil or number >= 0
        + If multiple customisations can apply to a city, this value chooses among them, with higher priority taking precedence.
        + If the city is eligible for two customisations of the same priority, an error may be generated, and will certainly be generated if they are of the highest priority.
- The following types of objects can also be keys in a city customisation table: `unitTypeObject`, `improvementObject`, `wonderObject`, `baseTerrainObject`, and `terrainObject`.  (These are associated with integer values behind the scenes, but don't worry about that.  Just use the object (NOT the ID) as the key.)  Each key takes a table value (or nil), to govern some aspects of the item.
    * `[unitTypeObject]` = nil|table 
        + `cost` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base cost (in shield rows) for the city
            - If nil, refer to authoritativeDefaultRules
            - If function, use result after evaluating function(city)
        + `costModifier` = nil|int or function(city)-->nil|int
            - Add this to the base cost, but cost won't be less than 0
            - If nil, use 0
            - If function, use result after evaluating function(city)

    * `[improvementObject]` = nil|table 
        + `cost` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base cost (in shield rows) for the city
            - If nil, refer to authoritativeDefaultRules
            - If function, use result after evaluating function(city)
        + `costModifier` = nil|int or function(city)-->nil|int
            - Add this to the base cost, but cost won't be less than 0
            - If nil, use 0
            - If function, use result after evaluating function(city)
        + `cantSell` = nil|boolean or function(city)-->nil|boolean
            - If true, the city can't sell the improvement, if false, it can.
            - If nil, refer to the authoritativeDefaultRules
        + `upkeep` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base upkeep (gold per turn) this improvement in this city
            - If nil, refer to authoritativeDefaultRules
            - If function, use result after evaluating function(city)
            - Note: Upkeep costs will be calculated correctly during city processing, but the Tax Rate and Trade Adviser windows will not be correct if the upkeep isn't the same for all cities (Costs for the most recently looked at city will be used.)
            - `customCosmic.getTribeUpkeep` will calculate the actual upkeep per turn for the tribe.
        + `upkeepModifier` = nil|int or function(city)-->nil|int
            - Add this to the base upkeep, but upkeep won't be less than 0
            - If nil, use 0 
            - If function, use result after evaluating function(city)
    * `[wonderObject]` = nil|table
        + `cost` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base cost (in shield rows) for the city
            - If nil, refer to authoritativeDefaultRules
            - If function, use result after evaluating function(city)
        + `costModifier` = nil|int or function(city)-->nil|int
            - Add this to the base cost, but cost won't be less than 0
            - If nil, use 0
            - If function, use result after evaluating function(city)
    * `[baseTerrainObject]` = nil|table
        + `irrigateBonus` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base value of the irrigation bonus for the city and baseTerrain.
            - If nil, refer to the authoritativeDefaultRules,
            - If function, use the result of function(city), 
        + `irrigateBonusModifier` = nil|int or function(city)-->nil|int
            - Add this to the base irrigation bonus, but results less than 0 will be set to 0.
            - If nil, use 0.
            - If function, use result after evaluating function(city)
        + `mineBonus` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base value of the mining bonus for the city and baseTerrain.
            - If nil, refer to the authoritativeDefaultRules,
            - If function, use the result of function(city), 
        + `mineBonusModifier` = nil|int or function(city)-->nil|int
            - Add this to the base mining bonus, but results less than 0 will be set to 0.
            - If nil, use 0.
            - If function, use result after evaluating function(city)
        + `roadTrade` = nil|boolean or function(city)-->nil|boolean
            - If true, for this city and baseTerrain, the road trade bonus is applied.  If false, it is not.
            - If nil, refer to the authoritativeDefaultRules
            - If function, use result after evaluating function(city)
    * `[terrainObject]` = {
        + `food` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base value for the food produced for this city by this terrain type.
            - If nil, refer to the authoritativeDefaultRules
            - If function, use the result of function(city)
        + `foodModifier` = nil|int or function(city)-->nil|int
            - Add this to the base food production value, but if the result is less than 0, it will be raised to 0.
            - If nil, use 0.
            - If function, use the result of function(city) 
        + `shields` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base value for the shields produced for this city by this terrain type.
            - If nil, refer to the authoritativeDefaultRules
            - If function, use the result of function(city)
        + `shieldsModifier` = nil|int or function(city)-->nil|int
            - Add this to the base shield production value, but if the result is less than 0, it will be raised to 0.
            - If nil, use 0.
            - If function, use the result of function(city) 
        + `trade` = nil|int>=0 or function(city)-->nil|int>=0
            - Sets the base value for the trade produced for this city by this terrain type.
            - If nil, refer to the authoritativeDefaultRules
            - If function, use the result of function(city)
        + `tradeModifier` = nil|int or function(city)-->nil|int
            - Add this to the base trade production value, but if the result is less than 0, it will be raised to 0.
            - If nil, use 0.
            - If function, use the result of function(city) 
- You can assign the same data table to multiple items by providing a table as the key, instead of a string or luaObject.  Consider:
<br> [keyTable] = data
<br>For each value in the `keyTable`, if value is not a trait, assign
<br>customisation[value] = gen.copyTable(data)
<br>if the value is a trait, for each ITEM such that 
<br>traits.hasTrait(ITEM,value)` 
<br>is true, assign
<br>customisation[ITEM] = gen.copyTable(data)
]]
---@param customisation table # A city customisation table, described above.
function customCosmic.registerCityCustomisation(customisation)
    if not isCityCustomisation(customisation) then
        customisation = customCosmic.makeCityCustomisation(customisation)
    end
    cityCustomisationTable[1+#cityCustomisationTable] = customisation
end

local emptyCityCustomisation = customCosmic.makeCityCustomisation
    ({priority=0, customisationName = "Empty City Customisation"}) --[[@as table]]
rawset(emptyCityCustomisation,"priority",-1)

local function getCityCustomisation(city)
    local priorityCustomisation = emptyCityCustomisation
    for _,customisation in pairs(cityCustomisationTable) do
        -- during the creation of the customisation, non-function
        -- values for 'condition' are replaced with functions
        if customisation.condition(city) then
            if customisation.priority > priorityCustomisation.priority then
                priorityCustomisation = customisation
            elseif customisation.priority == priorityCustomisation.priority then
                error("customCosmic: city customisation conflict ("..city.name.."): the city: "..tostring(city).." satisfies customisation "..customisation.customisationName.." as well as "..priorityCustomisation.customisationName..", which both have priority "..tostring(customisation.priority)..".")
            end
        end
    end
    return priorityCustomisation
end

---Returns the cityCustomisation for `city`
---@param city cityObject
---@return table
function customCosmic.getCityCustomisation(city)
    return getCityCustomisation(city)
end

---Allows the scenario designer to register a function(city)-->cityCustomisation
--to be used instead of the `customCosmic.registerCityCustomisation` system.
--The function must return a cityCustomisation for every 
--city under all circumstances
---@param fun fun(city: cityObject):table
function customCosmic.registerGetCityCustomisation(fun)
    getCityCustomisation = fun
end


local function makeCityEval(city)
    return function(val)
        if type(val) == "function" then
            return val(city)
        else
            return val
        end
    end
end

local function setCityCosmicValues(city,customisation)
    if not isCityCustomisation(customisation) then
        customisation = customCosmic.getCityCustomisation(city)
    end
    local default = changeRules.authoritativeDefaultRules["civ.cosmic"]
    local s = makeCityEval(city)
    for key,_ in pairs(cityChangeableCosmicKeys) do
        local keyVal = customisation[key]
        local modVal = customisation[key.."Modifier"]
        local defaultVal = default[key]      
        local val = math.max(0,(s(keyVal) or defaultVal) + (s(modVal) or 0))
        civ.cosmic[key] = val
    end
end

local function setCityUnitTypeValues(city,customisation,s)
    if not isCityCustomisation(customisation) then
        customisation = customCosmic.getCityCustomisation(city)
    end
    local s = s or makeCityEval(city)
    for unitType in gen.iterateUnitTypes() do
        local c = customisation[unitType] or {}
        local default = changeRules.authoritativeDefaultRules[unitType]
        unitType.cost = math.max(0,(s(c.cost) or default.cost) + (s(c.costModifier) or 0))
    end
end

-- cityUpkeepTable[cityID] = total upkeep for city improvements
local cityUpkeepTable = {}

local function setCityImprovementWonderValues(city,customisation,s)
    if not isCityCustomisation(customisation) then
        customisation = customCosmic.getCityCustomisation(city)
    end
    local s = s or makeCityEval(city)
    local totalUpkeep = 0
    for improvement in gen.iterateImprovements() do
        ---@cast improvement improvementObject
        local c = customisation[improvement] or {}
        local default = changeRules.authoritativeDefaultRules[improvement]
        improvement.cost = math.max(0,(s(c.cost) or default.cost) +(s(c.costModifier) or 0))
        improvement.upkeep = math.max(0,(s(c.upkeep) or default.upkeep) +(s(c.upkeepModifier) or 0))
        local cantVal = s(c.cantSell)
        if type(cantVal) == "boolean" then
            improvement.cantSell = cantVal
        else
            improvement.cantSell = default.cantSell
        end
        if city:hasImprovement(improvement) then
            totalUpkeep = totalUpkeep + improvement.upkeep
        end
    end
    cityUpkeepTable[city.id] = totalUpkeep
    for wonder in gen.iterateWonders() do
        ---@cast wonder improvementObject
        local c = customisation[wonder] or {}
        local default = changeRules.authoritativeDefaultRules[wonder]
        wonder.cost = math.max(0,(s(c.cost) or default.cost) +(s(c.costModifier) or 0))
    end
end

---Returns the total improvement maintenance cost a tribe must pay each turn.
--If `recalculate` is false or absent, the value is from the most recent
--update of each city.  If `recalculate` is true, city improvement customisations
--are calculated to get the current version of upkeep.
---@param tribe tribeObject
---@param recalculate? boolean
---@return integer
function customCosmic.getTribeUpkeep(tribe,recalculate)
    local tribeUpkeep = 0
    for city in civ.iterateCities() do
        if city.owner == tribe then
            if recalculate then
                setCityImprovementWonderValues(city)
            end
            tribeUpkeep = tribeUpkeep + (cityUpkeepTable[city.id] or 0)
        end
    end
    return tribeUpkeep
end

local function setCityTerrainValues(city,customisation,s)
    if not isCityCustomisation(customisation) then
        customisation = customCosmic.getCityCustomisation(city)
    end
    local s = s or makeCityEval(city)
    for baseTerrain in gen.iterateBaseTerrain() do
        local c = customisation[baseTerrain] or {}
        local default = changeRules.authoritativeDefaultRules[baseTerrain]
        local defaultRoadTrade = changeRules.authoritativeDefaultRules["totpp.roadTrade"][baseTerrain.map]
        baseTerrain.irrigateBonus = math.max(0,(s(c.irrigateBonus) or default.irrigateBonus)
            + (s(c.irrigateBonusModifier) or 0))
        baseTerrain.mineBonus = math.max(0,(s(c.mineBonus) or default.mineBonus)
            + (s(c.mineBonusModifier) or 0))
        local roadVal = s(c.roadTrade)
        if type(roadVal) == "boolean" then
            if roadVal then
                gen.giveRoadTradeBonus(baseTerrain)
            else
                gen.removeRoadTradeBonus(baseTerrain)
            end
        else
            if gen.isBit1(defaultRoadTrade,baseTerrain.type+1) then
                gen.giveRoadTradeBonus(baseTerrain)
            else
                gen.removeRoadTradeBonus(baseTerrain)
            end
        end
    end
    for terrain in gen.iterateTerrain() do
        local c = customisation[terrain] or {}
        local default = changeRules.authoritativeDefaultRules[terrain]
        terrain.food = math.max(0,(s(c.food) or default.food)+(s(c.foodModifier) or 0))
        terrain.shields = math.max(0,(s(c.shields) or default.shields)+(s(c.shieldsModifier) or 0))
        terrain.trade = math.max(0,(s(c.trade) or default.trade)+(s(c.tradeModifier) or 0))
    end
end

function customCosmic.changeEphemeralForCity(city)
    if customCosmicDisabled then
        return
    end
    local customisation = customCosmic.getCityCustomisation(city)
    local cityEval = makeCityEval(city)
    setCityCosmicValues(city, customisation)
    setCityUnitTypeValues(city, customisation, cityEval)
    setCityImprovementWonderValues(city,customisation,cityEval)
    setCityTerrainValues(city, customisation, cityEval)
end

local tribeUnitTypeKeys = {
    freeSupportUnderFundamentalism = nilBoolFn,
    requiresFoodSupport = nilBoolFn,
}
local makeTribeUnitTypeKey, _,tribeUnitTypeKeysSpec,_ =
    quickCustomDataTable("customCosmic UnitTypeKeys for Tribe", tribeUnitTypeKeys, {},{},{},{})

local tribeChangeableCosmicKeys = {
    foodRows= true,
    settlersEatHigh= true,
    settlersEatLow= true,
    shieldRows= true,
    sizeAquaduct= true,
    sizeSewer= true,
    supportCommunism= true,
    supportFundamentalism= true,
    supportMonarchy= true,
}

local tribeCustomCosmicListKeys = {
    foodRows= nilPosIntFn,
    -- foodRows= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.foodRows
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    foodRowsModifier = nilIntFn,
    -- foodRowsModifier = nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.foodRows
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    settlersEatHigh= nilPosIntFn,
    -- settlersEatHigh= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.settlersEatHigh
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    settlersEatHighModifier= nilIntFn,
    -- settlersEatHighModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.settlersEatHigh
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    settlersEatLow= nilPosIntFn,
    -- settlersEatLow= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.settlersEatLow
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    settlersEatLowModifier= nilIntFn,
    -- settlersEatLowModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.settlersEatLow
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    shieldRows= nilPosIntFn,
    -- shieldRows= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.shieldRows
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    shieldRowsModifier= nilIntFn,
    -- shieldRowsModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.shieldRows
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    sizeAquaduct= nilPosIntFn,
    -- sizeAquaduct= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.sizeAquaduct
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    sizeAquaductModifier= nilIntFn,
    -- sizeAquaductModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.sizeAquaduct
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    sizeSewer= nilPosIntFn,
    -- sizeSewer= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.sizeSewer
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    sizeSewerModifier= nilIntFn,
    -- sizeSewerModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.sizeSewer
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    supportCommunism= nilPosIntFn,
    -- supportCommunism= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.supportCommunism
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    supportCommunismModifier= nilIntFn,
    -- supportCommunismModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.supportCommunism
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    supportFundamentalism= nilPosIntFn,
    -- supportFundamentalism= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.supportFundamentalism
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    supportFundamentalismModifier= nilIntFn,
    -- supportFundamentalismModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.supportFundamentalism
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    supportMonarchy= nilPosIntFn,
    -- supportMonarchy= nil|int>=0 or function(tribe) --> nil|int>=0
    -- Specifies the base value to be used for civ.cosmic.supportMonarchy
    -- If nil, the value from the authoritativeDefaultRules is used.
    -- If function, use the returned value when given the tribe as the argument.
    supportMonarchyModifier= nilIntFn,
    -- supportMonarchyModifier= nil|int or function(tribe) --> nil|int
    -- Add this to the base value to be used for 
    -- civ.cosmic.supportMonarchy
    -- If nil, add 0.  Note, a negative number here will not reduce the
    -- base value below 0.
    -- If function, use the returned value when given the tribe as the argument.
    customisationName = {["string"]=true},
    -- A name to be used during certain kinds of error and debugging messages
    -- nil will give "Unnamed Tribe Customisation"
    condition = citySpecCondition,
    -- condition = nil|tribeObject|traitString|function(tribe)-->boolean or
    --          table of tribeObject|traitString
    -- if nil, this customisation applies to all tribes (unless a higher 
    -- priority customisation also applies)
    -- if tribeObject, this customisation applies to that tribe
    -- if traitString, this customisation applies to tribes which have the
    -- trait
    -- if table of tribeObject|traitString, this applies to any tribe or
    -- traitString in the table
    -- if function(tribe) --> boolean, then this customisation applies to
    -- tribes which make this function return true
    -- only one customisation can apply to any tribe.  The priority key
    -- is used to tie break.
    priority = posNum,
    -- priority - nil or number >= 0
    -- If multiple customisations can apply to a tribe, this value chooses
    -- among them, with higher priority taking precedence.
    -- If the tribe is eligible for two customisations of the same priority,
    -- an error may be generated, and will certainly be generated if they
    -- are of the highest priority.

    -- [unitTypeObject] = {
    --          freeSupportUnderFundamentalism = nil|boolean or function(tribe)-->nil|boolean
    --              If true, unitType has the freeSupportUnderFundamentalism 
    --              for this tribe.  If false, it does not.
    --              If nil, refer to the authoritativeDefaultRules
    --          requiresFoodSupport = nil|boolean or function(tribe)-->nil|boolean
    --              If true, the tribe must pay food support for this unitType.
    --              If false, it does not. (Setting this to true makes both
    --              settler and non-settler unit types require food.)
    --              If nil, refer to the authoritativeDefaultRules
    --          }
    -- bulk assignment
    -- [keyTable] = data
    --  For each value in the keyTable, if value is not a trait,
    --  assign customisation[value] = gen.copyTable(data)
    --  if the value is a trait, for each ITEM such that
    --  traits.hasTrait(ITEM,value) is true, assign
    --  customisation[ITEM] = gen.copyTable(data)

}
for i=0,improvementOffset-1 do
    tribeCustomCosmicListKeys[i] = tribeUnitTypeKeysSpec
end
local tribeCustomCosmicDefaultKeys = {
    priority = 0,
    customisationName = "Unnamed Tribe Customisation",
}

local tribeCustomCosmicAliasKeys = function(item)
    if civ.isUnitType(item) then
        return item.id
    end
    if item == "sizeAqueduct" then
        return "sizeAquaduct"
    elseif item == "sizeAqueductModifier" then
        return "sizeAquaductModifier"
    end
    return item
end

local makeTribeCustomisationBase, isTribeCustomisation, tCustMT = 
    gen.createDataType("customCosmic tribeCustomisation", tribeCustomCosmicListKeys,
    {},tribeCustomCosmicDefaultKeys,{},tribeCustomCosmicAliasKeys)

function customCosmic.makeTribeCustomisation(table)
    table = gen.copyTable(table)
    bulkKeyAssignment(table)
    for key,val in pairs(table) do
        if type(key) == "table" then
           for _,v in pairs(val) do
            table[v] = gen.copyTable(val)
           end 
           table[key] = nil
        end
    end
    for key,val in pairs(table) do
        if civ.isUnitType(key) then
            table[key] = makeTribeUnitTypeKey(val)
        end
    end
    local customisation = makeTribeCustomisationBase(table)
    if customisation.condition == nil then
        customisation.condition = returnTrue
    elseif civ.isTribe(customisation.condition) then
        local conditionTribe = customisation.condition
        customisation.condition = function(tribe) return tribe == conditionTribe end
    elseif type(customisation.condition) == "string" then
        local conditionTrait = customisation.condition
        customisation.condition = function(tribe) return traits.hasTrait(tribe,conditionTrait) end
    elseif type(customisation.condition) == "function" then
        -- do nothing here, since the condition is already a function
    elseif type(customisation.condition) == "table" then
        local conditionTable = gen.copyTable(customisation.condition)
        customisation.condition = function(tribe)
            for _,tribeString in pairs(conditionTable) do
                if type(tribeString) == "string" then
                    if traits.hasTrait(tribe,tribeString) then
                        return true
                    end
                else
                    if tribe == tribeString then
                        return true
                    end
                end
            end
            return false
        end
    else
        error("customCosmic.makeTribeTypeCustomisation: the 'condition' key does not satisfy the value specification.  Ask for help.  This error should have been caught earlier in the code.  Received: "..tostring(customisation.condition))
    end
    return customisation
end

local tribeCustomisationTable = {}

--Registers a customisation for tribes.<br>
--Keys and descriptions for tribe customisation tables:
--[[

- These keys are used to change cosmic parameters that relate to city
production.  These are customised by tribe because the game uses them
before onCalculateCityYield can change them. Other customisations can be made on a per city basis.
    * `foodRows`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.foodRows
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `foodRowsModifier` = nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.foodRows
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `settlersEatHigh`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.settlersEatHigh
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `settlersEatHighModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.settlersEatHigh
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `settlersEatLow`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.settlersEatLow
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `settlersEatLowModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.settlersEatLow
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `shieldRows`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.shieldRows
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `shieldRowsModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.shieldRows
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `sizeAquaduct`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.sizeAquaduct
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
        + NOTE: sizeAqueduct can be used instead to refer to this value.
    * `sizeAquaductModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.sizeAquaduct
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
        + NOTE: sizeAqueductModifier can be used instead to refer to this value.
    * `sizeSewer`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.sizeSewer
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `sizeSewerModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.sizeSewer
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `supportCommunism`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.supportCommunism
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `supportCommunismModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.supportCommunism
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `supportFundamentalism`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.supportFundamentalism
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `supportFundamentalismModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.supportFundamentalism
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
    * `supportMonarchy`= nil|int>=0 or function(tribe) --> nil|int>=0
        + Specifies the base value to be used for civ.cosmic.supportMonarchy
        + If nil, the value from the authoritativeDefaultRules is used.
        + If function, use the returned value when given the tribe as the argument.
    * `supportMonarchyModifier`= nil|int or function(tribe) --> nil|int
        + Add this to the base value to be used for  civ.cosmic.supportMonarchy
        + If nil, add 0.  Note, a negative number here will not reduce the base value below 0.
        + If function, use the returned value when given the tribe as the argument.
- The `condition` and `priority` keys determine which customisation table is chosen for a particular tribe.  The `customisationName` key is used to give the customisation a name which is used in some error messages.
    * `customisationName` = nil|string
        + A name to be used during certain kinds of error and debugging messages
        + nil will give "Unnamed Tribe Customisation"
    * `condition` = nil|tribeObject|traitString|function(tribe)-->boolean or table of tribeObject|traitString
        + if nil, this customisation applies to all tribes (unless a higher  priority customisation also applies)
        + if tribeObject, this customisation applies to that tribe
        + if traitString, this customisation applies to tribes which have the trait
        + if table of tribeObject|traitString, this applies to any tribe or traitString in the table
        + if function(tribe) --> boolean, then this customisation applies to tribes which make this function return true
        + only one customisation can apply to any tribe.  The `priority` key is used to tie break.
    * `priority` = nil|number>=0
        + If multiple customisations can apply to a tribe, this value chooses among them, with higher priority taking precedence.
        + If the tribe is eligible for two customisations of the same priority, an error may be generated, and will certainly be generated if they are of the highest priority.
- `unitTypeObject`s can also be keys in a tribe customisation table.
(These are associated with integer values behind the scenes,
 but don't worry about that.  Just use the object (NOT the ID) as the key.)
Each key takes a table (or nil) as a value, to govern the support
characteristics of the item.
    * `[unitTypeObject]` = nil|table
        + `freeSupportUnderFundamentalism` = nil|boolean or function(tribe)-->nil|boolean
            - If true, unitType has the freeSupportUnderFundamentalism flag for this tribe.  If false, it does not.
            - If nil, refer to the authoritativeDefaultRules
        + `requiresFoodSupport` = nil|boolean or function(tribe)-->nil|boolean
            - If true, the tribe must pay food support for this unitType.
            - If false, it does not. (Setting this to true makes both settler and non-settler unit types require food.)
            - If nil, refer to the authoritativeDefaultRules
    --          }
- You can assign the same data table to multiple items by providing a table as the key, instead of a string or luaObject.  Consider:
<br> [keyTable] = data
<br>For each value in the `keyTable`, if value is not a trait, assign
<br>customisation[value] = gen.copyTable(data)
<br>if the value is a trait, for each ITEM such that 
<br>traits.hasTrait(ITEM,value)` 
<br>is true, assign
<br>customisation[ITEM] = gen.copyTable(data)
]]
---@param customisation table
function customCosmic.registerTribeCustomisation(customisation)
    if not isTribeCustomisation(customisation) then
        customisation = customCosmic.makeTribeCustomisation(customisation)
    end
    tribeCustomisationTable[1+#tribeCustomisationTable] = customisation
end

local emptyTribeCustomisation = customCosmic.makeTribeCustomisation
    ({priority=0, customisationName = "Empty Tribe Customisation"}) --[[@as table]]
rawset(emptyTribeCustomisation,"priority",-1)

local function getTribeCustomisation(tribe)
    local priorityCustomisation = emptyTribeCustomisation
    for _,customisation in pairs(tribeCustomisationTable) do
        -- during the creation of the customisation, non-function
        -- values for 'condition' are replaced with functions
        if customisation.condition(tribe) then
            if customisation.priority > priorityCustomisation.priority then
                priorityCustomisation = customisation
            elseif customisation.priority == priorityCustomisation.priority then
                error("customCosmic: tribe customisation conflict ("..tribe.name.."): the tribe: "..tostring(tribe).." satisfies customisation "..customisation.customisationName.." as well as "..priorityCustomisation.customisationName..", which both have priority "..tostring(customisation.priority)..".")
            end
        end
    end
    return priorityCustomisation
end

---Returns the tribeCustomisation for `tribe`
---@param tribe tribeObject
---@return table
function customCosmic.getTribeCustomisation(tribe)
    return getTribeCustomisation(tribe)
end


---Allows the scenario designer to register a function(tribe)-->tribeCustomisation
--to be used instead of the `customCosmic.registerTribeCustomisation` system.
--The function must return a tribeCustomisation for every 
--tribe under all circumstances
---@param fun fun(tribe: tribeObject):table
function customCosmic.registerGetTribeCustomisation(fun)
    getTribeCustomisation = fun
end

local function makeTribeEval(tribe)
    return function(val)
        if type(val) == "function" then
            return val(tribe)
        else
            return val
        end
    end
end

local function setTribeCosmicValues(tribe,customisation)
    if not isTribeCustomisation(customisation) then
        customisation = customCosmic.getTribeCustomisation(tribe)
    end
    local s = makeTribeEval(tribe)
    local default = changeRules.authoritativeDefaultRules["civ.cosmic"]
    for key,_ in pairs(tribeChangeableCosmicKeys) do
        local keyVal = customisation[key]
        local modVal = customisation[key.."Modifier"]
        local defaultVal = default[key]      
        local val = math.max(0,(s(keyVal) or defaultVal) + (s(modVal) or 0))
        civ.cosmic[key] = val
    end
end

local function setTribeUnitTypeValues(tribe,customisation)
    if not isTribeCustomisation(customisation) then
        customisation = customCosmic.getTribeCustomisation(tribe)
    end
    local s = makeTribeEval(tribe)
    for unitType in gen.iterateUnitTypes() do
        local default = changeRules.authoritativeDefaultRules[unitType]
        local c = customisation[unitType] or {}
        local supVal = s(c.freeSupportUnderFundamentalism)
        if type(supVal) == "boolean" then
            if supVal then
                gen.giveFreeSupportUnderFundamentalism(unitType)
            else
                gen.removeFreeSupportUnderFundamentalism(unitType)
            end
        else
            if gen.isFreeSupportUnderFundamentalism(default) then
                gen.giveFreeSupportUnderFundamentalism(unitType)
            else
                gen.removeFreeSupportUnderFundamentalism(unitType)
            end
        end
        local foodVal = s(c.requiresFoodSupport)
        if type(foodVal) == "boolean" then
            if foodVal then
                gen.giveRequiresFoodSupport(unitType)
            else
                gen.removeRequiresFoodSupport(unitType)
            end
        else
            if gen.isRequiresFoodSupport(default) then
                gen.giveRequiresFoodSupport(unitType)
            else
                gen.removeRequiresFoodSupport(unitType)
            end
        end
    end
end


function customCosmic.changeEphemeralForTribe(tribe)
    if customCosmicDisabled then
        return
    end
    local customisation = customCosmic.getTribeCustomisation(tribe)
    setTribeCosmicValues(tribe,customisation)
    setTribeUnitTypeValues(tribe,customisation)

end

function customCosmic.getFreeSupport(tribe)
    if civ.getCurrentTribe() == tribe or customCosmicDisabled then
        return {supportMonarchy = civ.cosmic.supportMonarchy,
            supportCommunism = civ.cosmic.supportCommunism,
            supportFundamentalism = civ.cosmic.supportFundamentalism,}
    end
    local customisation = getTribeCustomisation(tribe)
    ---@cast customisation table
    local s = makeTribeEval(tribe)
    local default = changeRules.authoritativeDefaultRules["civ.cosmic"]
    local output = {}
    for key,_ in pairs({supportMonarchy=true,supportCommunism=true,supportFundamentalism=true,}) do
        local keyVal = customisation[key]
        local modVal = customisation[key.."Modifier"]
        local defaultVal = default[key]      
        local val = math.max(0,(s(keyVal) or defaultVal) + (s(modVal) or 0))
        output[key] = val
    end
    return output
end

function customCosmic.getCustomisedTerrainInfo(tile,city)
    if customCosmicDisabled then
        return tile.baseTerrain, tile.terrain, totpp.roadTrade
    end
    local customisation = customCosmic.getCityCustomisation(city)
    local baseTerrain = tile.baseTerrain
    local c = customisation[baseTerrain] or {}
    local default = changeRules.authoritativeDefaultRules[baseTerrain]
    local baseTerrainEquiv = {type = baseTerrain.type}
    local totppRoadTradeEquiv = gen.copyTable(changeRules.authoritativeDefaultRules["totpp.roadTrade"])
    local s = makeCityEval(city)
    baseTerrainEquiv.irrigateBonus = math.max(0,(s(c.irrigateBonus) or default.irrigateBonus)
        + (s(c.irrigateBonusModifier) or 0))
    baseTerrainEquiv.mineBonus = math.max(0,(s(c.mineBonus) or default.mineBonus)
        + (s(c.mineBonusModifier) or 0))
    local roadVal = s(c.roadTrade)
    -- since totppRoadTradeEquiv is the result of the authoritativeDefaultRules,
    -- we don't do anything if roadVal is nil (unlike the actual terrain prep)
    if type(roadVal) == "boolean" then
        if roadVal then
            totppRoadTradeEquiv[tile.z] = gen.setBit1(totppRoadTradeEquiv[tile.z],baseTerrain.type+1)
        else
            totppRoadTradeEquiv[tile.z] = gen.setBit0(totppRoadTradeEquiv[tile.z],baseTerrain.type+1)
        end
    end
    local terrain = tile.terrain
    local terrainEquiv = {}
    c = customisation[terrain] or {}
    default = changeRules.authoritativeDefaultRules[terrain]
    terrainEquiv.food = math.max(0,(s(c.food) or default.food)+(s(c.foodModifier) or 0))
    terrainEquiv.shields = math.max(0,(s(c.shields) or default.shields)+(s(c.shieldsModifier) or 0))
    terrainEquiv.trade = math.max(0,(s(c.trade) or default.trade)+(s(c.tradeModifier) or 0))
    return baseTerrainEquiv, terrainEquiv, totppRoadTradeEquiv
end

--rawset(_G,"cc",customCosmic)
--]]

-- Notes on why fields are not included

-- cityImprovement onCapture field not included, because the city is updated
-- with the new owner before civ.scen.onCityTaken is applied, and you'd want
-- to use the defender's customisation, and that would require different code
-- than everything else.

-- submarine, attackAir, bonusAgainstHorse, bonusAgainstAir, 
-- invisibleUntilAttack not included, since these have effects when the
-- unit is not active.

-- nonDisbandable not included, since that can be done both with a unit
-- order and from the city menu.

return customCosmic