local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

local customCosmic = require("customCosmic")
local object = require("object")
require("setTraits")
local traits = require("traits")
local gen = require("generalLibrary")

--          Enabling Custom Cosmic Settings
--[[
By default, the customCosmic events are disabled.  This is because the 
mechanics that make customCosmic work have a couple side effects.  First,
all unit types that are not the activeUnit have their movement allowance
set to 255, so that they will always activate if they can.  (A unit,
especially a damaged unit, might look to the game like it has used all
its movement allowance, but it would still have some left after applying
its customisations.  Setting the movement allowance to 255 circumvents this.)
As a consequence, the Civilopedia will show incorrect movement allowances.

Additionally, all units which have expended their true movement allocation
for the turn have their moveSpent field set to 255, to compensate for
having all non-active unitTypes with 255 movement.
Uncomment the following line to enable customCosmic events.
--]]

-- customCosmic.enableCustomCosmic()

--          Enabling Ephemeral Map Transport Settings
--[[
Unlike other unit type rules, the build transport, use transport and
native transport settings are not read from the rules.txt whenever
a game is loaded, but instead stored as part of the saved game.
This way, events can enable (or disable) transportation abilities
during the game.  As a consequence, the `nativeTransport`, 
`useTransport`, and `buildTransport` unitType fields are not 
ephemeral in Lua.

Uncommenting the line of code following this paragraph
makes the customCosmic module treat these fields as ephemeral,
reading their value from the current state of the rules.txt, 
and then altering them based on customisations that may be
defined below.  This will render events that change
transportation abilities ineffective (unless, of course, you
account for that in the customisation).
--]]

--customCosmic.enableEphemeralMapTransportSettings()



--          Default Movement Multipliers
--[[
Here, you can set the default movement multipliers for
Land, Air, and Sea units (along with domain 3).
These will be used as the movement multipliers for units
of the corresponding domain, unless the unit has something else
specified below.

If a value is set to nil, the Lua Template then looks to
    changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]["propertyKey"]

]]

--  Default land multipliers are set to nil, since you probably
--  want to use the values in the rules.txt
customCosmic.defaultMovementMultipliers.land.alpine = nil
customCosmic.defaultMovementMultipliers.land.river = nil
customCosmic.defaultMovementMultipliers.land.road = nil
customCosmic.defaultMovementMultipliers.land.railroad = nil

--  You probably want to set all of these default movement
--  multipliers to 0, since these units can't take advantage
--  of road/rail/river/alpine bonuses anyway
--  These are commented out only so that the default version
--  of the template doesn't change the game mechanics
--[[
customCosmic.defaultMovementMultipliers.air.alpine = 0
customCosmic.defaultMovementMultipliers.air.river = 0
customCosmic.defaultMovementMultipliers.air.road = 0
customCosmic.defaultMovementMultipliers.air.railroad = 0

customCosmic.defaultMovementMultipliers.sea.alpine = 0
customCosmic.defaultMovementMultipliers.sea.river = 0
customCosmic.defaultMovementMultipliers.sea.road = 0
customCosmic.defaultMovementMultipliers.sea.railroad = 0

customCosmic.defaultMovementMultipliers[3].alpine = 0
customCosmic.defaultMovementMultipliers[3].river = 0
customCosmic.defaultMovementMultipliers[3].road = 0
customCosmic.defaultMovementMultipliers[3].railroad = 0
--]]

--      Unit Type Customisations
--[[
Unit Type customisations are registered with the function
customCosmic.registerUnitTypeCustomisation(type,customisation)
The type can be a unitType, a trait (string), or a table of
traits and strings.  In order for a customisation to apply,
both the unit type it is registered to and the customisation
`condition` must be met.  If multiple conditions are met, the
one with the largest `priority` is chosen.
The customisation is a table which has this structure:
]]
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

--[[
    These are some sample registrations that were used during testing:

customCosmic.registerUnitTypeCustomisation({gen.original.uCruiser, gen.original.uAEGISCruiser}, {
    condition = civ.getTribe(1),
    flags = {
        spotSubmarines = false,
        paradrop = true,
    },
    cosmic = {
        paradropRange = 3,
    },
    movementBonus = 2,
    priority = 1,
    minMove = 4,
    customisationName = "TestRomanCruiser",
})

customCosmic.registerUnitTypeCustomisation(gen.original.uExplorer,{
    alpineMultiplier = 4,
    riverMultiplier = 8,
    roadMultiplier = 4,
    railroadMultiplier = 1,
    customMovement = 1,
    priority = 1,
    customisationName = "Explorer Test",
})

customCosmic.registerUnitTypeCustomisation(gen.original.uPhalanx,{
    alpineMultiplier = 2,
    riverMultiplier = 8,
    roadMultiplier = 6,
    railroadMultiplier = 1,
    customMovement = 1,
    priority = 1,
    customisationName = "Phalanx Test",
})
--]]
--[[
traits.allowedTraits("fighter","bomber","warship")
traits.assign({gen.original.uFighter, gen.original.uStlthFtr},"fighter")
--]]
--[==[
customCosmic.registerUnitTypeCustomisation("fighter",{
    movementBonus = function(unit)
        local bonus = 0
        local tribe = unit.owner
        if tribe:hasTech(gen.original.aSuperconductor) then
            bonus = bonus +2
        end
        if gen.isWonderActiveForTribe(gen.original.wSETIProgram, tribe) then
            bonus = bonus + 1
        end
        return bonus
    end,
    transport01 = {nativeTransport=function(unit) return unit.location.z == 1 end, useTransport=true},
    customisationName = "Fighter movement bonus",
})
customCosmic.registerUnitTypeCustomisation(gen.original.uNuclearMsl,{
  customMovement = 255,
})

-- note the two freight conditions can be true at the same time,
-- so the priorities are set and are different
customCosmic.registerUnitTypeCustomisation(gen.original.uFreight,{
    roadMultiplier = 2,
    railroadMultiplier = 10,
    customMovement = 2,
    priority = 1,
    customisationName = "Pre-Automobile Freight",
})
customCosmic.registerUnitTypeCustomisation(gen.original.uFreight,{
    roadMultiplier = 6,
    railroadMultiplier = 6,
    customMovement = 4,
    priority = 2,
    condition = function(unit)
        return unit.owner:hasTech(gen.original.aAutomobile)
    end,
    customisationName = "Automobile Freight",
})

customCosmic.registerUnitTypeCustomisation({
    gen.original.uArmor, gen.original.uMechInf, gen.original.uHowitzer,
},{
    isImpassable = {[gen.original.bSwamp] = true},
    moveCost = {[gen.original.bHills] = 1},
    customisationName = "Impassable Swamp for Mech, hills easy",
})

customCosmic.registerUnitTypeCustomisation(gen.original.uPartisans,{
    atomicCustomMovement = 11,
    customMovement = 8, -- this should be overridden, since atomic take priority
    atomicMinMove = 7, -- in game, this will be reduced to 6, so that it is equivalent to a full movement point; damaged units can't have a fractional movement allowance
})

customCosmic.registerUnitTypeCustomisation(gen.original.uRiflemen,{
    isImpassable = {[gen.original.bSwamp] = false, },
    customisationName = "Riflemen cross swamp",
})
--]==]

--      City Customisations
--[[
City customisations are registered with the function
customCosmic.registerCityCustomisation(customisation)
City customisations can apply to all cities, as long as
the `condition` is met.  If the `condition`s for multiple
customisations are met, the one with the largest `priority`
is chosen.
the customisation is a table which has this structure:
]]
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

--  These city customisations were used during testing:
--[==[

customCosmic.registerCityCustomisation({
    priority = 1,
    condition = {civ.getTribe(1),civ.getTribe(7)},
    [gen.original.wPyramids] = {costModifier = -5},
    [gen.original.uWarriors] = {cost=0},
    [gen.original.uMechInf] = {cost=function(city) return (city:hasImprovement(gen.original.iFactory) and 5) or 10 end, },
    [gen.original.iGranary] = {cost=function(city) return (city:hasImprovement(gen.original.iFactory) and 5) or 10 end,upkeep = function(city) return (city:hasImprovement(gen.original.iFactory) and 100) or 0 end, cantSell = function(city) return city:hasImprovement(gen.original.iPoliceStation) end,},
    [gen.original.wColossus] = {cost=function(city) return (city:hasImprovement(gen.original.iFactory) and 5) or 10 end, },
    [gen.original.bPlains] = {irrigateBonusModifier=1,
        mineBonusModifier=function(city)
            if city:hasImprovement(gen.original.iFactory) then
                return 4
            else
                return -2
            end
        end,
        roadTrade = function(city) return city:hasImprovement(gen.original.iFactory) end,
    },
    [gen.original.bMountains] = {irrigateBonusModifier=1,
        mineBonusModifier=function(city)
            if city:hasImprovement(gen.original.iFactory) then
                return 4
            else
                return -2
            end
        end,},
    [gen.original.tOcean] = {trade=0,
        tradeModifier = function(city)
            if city:hasImprovement(gen.original.iPortFacility) then
                return 3
            else
                return 0
            end
        end,},
    [gen.original.tWhales] = {},
    foodEaten = 0,
    communismPalaceDistance = 25,
    prodChangePenalty = function(city) return city.shields end,
    riotFactor = function(city) if city:hasImprovement(gen.original.iPalace) then return 100 else return 0 end end,
    scienceLostFundamentalism = function(city) return (city:hasImprovement(gen.original.iCathedral) and 100) or 0 end,
    scienceRateFundamentalism = function(city) return (city:hasImprovement(gen.original.iLibrary) and 8) or 0 end,
    sizeUnhappiness = function(city) return (city:hasImprovement(gen.original.iFactory) and 6) or 10 end,

})

customCosmic.registerCityCustomisation({
    priority = 2,
    condition = function(city --[[@as cityObject]]) return city:hasImprovement(gen.original.iPalace) end,
    [{"warship","fighter",gen.original.uMechInf,}] = {
        costModifier = -3},
})
--]==]

--      Tribe Customisations
--[[
Tribe customisations are registered with the function
customCosmic.registerTribeCustomisation(customisation)
Tribe customisations can apply to any tribe, as long as
the `condition` is met.  If the `condition`s for multiple
customisations are met, the one with the largest `priority`
is chosen.
The customisation is a table which has this structure:
--]]
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

--[==[
--  These tribe customisations were used during testing:

customCosmic.registerTribeCustomisation({
    priority = 1,
    condition = {civ.getTribe(1),civ.getTribe(7)},
    [gen.original.uMechInf] = {requiresFoodSupport = function(tribe) return tribe:hasTech(gen.original.aDemocracy) end, freeSupportUnderFundamentalism = function(tribe) return not gen.isWonderActiveForTribe(gen.original.wMichelangelosChapel, tribe) end},
    supportMonarchy=0,
    supportMonarchyModifier=function(tribe) return tribe.id end,
    supportFundamentalism = function(tribe) return (tribe:hasTech(gen.original.aFundamentalism ) and 4) or 0 end,
    sizeAquaduct = function(tribe) return (tribe:hasTech(gen.original.aSanitation) and 6) or 10 end,
    sizeSewer = function(tribe) return (tribe:hasTech(gen.original.aEnvironmentalism) and 7) or 11 end,
    settlersEatHigh = function(tribe) return (tribe:hasTech(gen.original.aRefrigeration) and 3) or 2 end,
    settlersEatLow = function(tribe) return (tribe:hasTech(gen.original.aRefrigeration) and 3) or 1 end,
    shieldRows = function(tribe) return tribe.id+4 end,
    supportCommunism = function(tribe) return (gen.isWonderActiveForTribe(gen.original.wColossus, tribe) and 4) or 0 end,
})

customCosmic.registerTribeCustomisation({
    priority = 2,
    condition = function(tribe) return gen.isWonderActiveForTribe(gen.original.wHangingGardens,tribe) end,
    supportMonarchy = 10,
    settlersEatLow = 0,
})
--]==]



local register = {}
gen.versionFunctions(register,versionNumber,fileModified,"MechanicsFiles".."\\".."customCosmicSettings.lua")
return register
