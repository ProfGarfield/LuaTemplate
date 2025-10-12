
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
local help = require("help")
local traits = require("traits")
require("setTraits")
---@module "generalLibrary"
local gen = require("generalLibrary")
local text = require("text")
local configuration = require("configuration")
local keyboard = require("keyboard")
local customCosmic = require("customCosmic")
local object       = require("object")


-- Registers custom movement multiplier names
-- for use in the unit help text box.
help.registerCustomMovementMultiplierNames(
    "Road","Rail","River","Alpine")


-- Registers unit type traits to be displayed to the player in unit
-- help text boxes, and the text to display if a unit has that particular trait.
-- These will be displayed in order they are specified in this table
local traitTextTable = {
    --{"mounted","Mounted Unit"},
    --{"siegeEngine","Siege Engine"},
}
local function makeTraitDescription(unitType)
    return help.makeTraitDescription(unitType, traitTextTable,", ")
    -- Change third argument to "\n^" if you want trait descriptions to be separated by newlines
end

-- Registers functions to check unit flags (or similar binary properties)
-- and the corresponding help text to display in unit help if the property
-- is true for the unit.
-- These will be displayed in order they are specified in this table
local flagTextTable = {
    {function(unit) return unit.type.role == gen.c.roleTrade end,"Trade Unit"},
    {function(unit) return unit.type.role == gen.c.roleDiplomacy end,"Diplomacy Unit"},
    {customCosmic.isSeeTwoSpaces, "Two space visibility"},
    {customCosmic.isIgnoreZOC, "Ignore zones of control"},
    {customCosmic.isAmphibious, "Can make amphibious assaults"},
    {function(unit) return gen.isSubmarine(unit.type) end, "Submarine advantages/disadvantages"},
    {function(unit) return gen.isAttackAir(unit.type) end, "Can attack air units"},
    {customCosmic.isCoastal, "Ship must stay near land"},
    {customCosmic.isIgnoreWalls, "Negates city walls"},
    {customCosmic.isCarryAir, "Can carry air units"},
    {customCosmic.isParadrop, "Can make paradrops"},
    {customCosmic.isAlpine, "Treats all squares as road"},
    {function(unit) return gen.isBonusAgainstHorse(unit.type) end, "x2 on defense versus horse"},
    {customCosmic.isFreeSupportUnderFundamentalism, "Free support under fundamentalism"},
    {customCosmic.isDestroyedAfterAttacking, "Destroyed after attacking"},
    {function(unit) return gen.isBonusAgainstAir(unit.type) end, "x2 on defense versus air"},
    {customCosmic.isSpotSubmarines, "Can spot submarines"},
    {function(unit) return gen.isInvisibleUntilAttack(unit.type) end, "Invisible until it attacks"},
    {function(unit) return gen.isNonDisbandable(unit.type) end, "Cannot be disbanded"},
    {function(unit) return gen.isZeroRangeAirUnitDamageOverride(unit.type) end, "Doesn't take damage in the field"},
    --{gen.isCannotBuyOffBarbarian, "Can't be paid off if barbarian"},
    {customCosmic.isCanCrossImpassableTerrain, "Can cross impassable terrain"},
    --{function(unit) return gen.isBarbarianWillNotExpire(unit.type) end, "Doesn't disappear if barbarian"},
    --{function(unit) return gen.isOverrideSPR(unit.type) end, ""},
    {function(unit) return gen.isReducePopulationWhenBuilt(unit.type) end, "Reduces city population when built"},
    {customCosmic.isRequiresFoodSupport, "Requires food support"},
    {customCosmic.isCanFoundCities, "Can found cities"},
    {customCosmic.isCanImproveTiles, "Can improve tiles"},
}

local function makeFlagDescription(unitType)
    return help.makeFlagDescription(unitType, flagTextTable, ", ")
    -- change third argument to "\n^" if you want flag descriptions to be separated by newlines
end


local function nearestCityOnMap(unit)
    local bestCity = nil
    local bestDistance = math.huge
    for city in civ.iterateCities() do
        local distance = gen.distance(unit.location, city.location)
        if distance < bestDistance and city.owner == unit.owner and city.location.z == unit.location.z then
            bestDistance = distance
            bestCity = city
        end
    end
    return bestCity
end

--[=[Registers a hint for a unitType or all the unitTypes with
a given trait, to be displayed for that unitType's help box.
---@param unitType unitTypeObject|string A unit type or trait
---@param hint string The hint to be displayed in the help box
---@param hintPlaceInteger? integer The place of the hint among the hints for the unitType (gaps are ignored).  If not specified, the hint will be shown in an arbitrary order after all hints created with a hintPlaceInteger.  Duplicating the hintPlaceInteger for a unitType will result in an error.
function help.registerHint(unitType,hint,hintPlaceInteger)]=]
--help.registerHint(gen.original.uCatapult,"Unordered testing hint 1")
--help.registerHint(gen.original.uCatapult,"Best used to attack cities",1)
--help.registerHint(gen.original.uCatapult,"Weak on defense",4)
--help.registerHint(gen.original.uCatapult,"Unordered testing hint 2")
--help.registerHint(gen.original.uCrusaders,"Strong and fast attacker, weak defender") 



--[[Registers a function(unit)-->string to place help information before the unit statistics in the unit help box]]
help.registerTopUnitHelpFunction(function(unit)
    local info = ""
    if unit.type.domain == gen.c.domainAir then
        local nearestCity = nearestCityOnMap(unit)
        if nearestCity then
            info = info .. "Nearest city: " .. nearestCity.name .. "\n"
        end
    end
    info = info..help.unitTypeHints(unit.type,", ")
    return info
end)


--[[Registers a function(unit)-->string to place help information between the unit statistics and the combat bonus information]]
help.registerMiddleUnitHelpFunction(function(unit)
    local traitDescriptionString = makeTraitDescription(unit)
    if traitDescriptionString == "" then
        return makeFlagDescription(unit)
    end
    local flagDescriptionString = makeFlagDescription(unit)
    if flagDescriptionString == "" then
        return traitDescriptionString
    end
    return makeTraitDescription(unit)..", "..makeFlagDescription(unit)
end)

--[[Registers a function(unit)-->string to place help information after the bonus information]]
help.registerBottomUnitHelpFunction(function(unit)
    return ""
end)


--[[Registers a function(unit)-->string to place help information at the top of the help box for foreign units]]
help.registerTopForeignUnitHelpFunction(function(unit)
    return help.unitTypeHints(unit.type,", ")
end)

--[[Registers a function(unit)-->string to place help information between the unit statistics and the combat bonus information for foreign units]]
help.registerMiddleForeignUnitHelpFunction(function(unit)
    local traitDescriptionString = makeTraitDescription(unit)
    if traitDescriptionString == "" then
        return makeFlagDescription(unit)
    end
    local flagDescriptionString = makeFlagDescription(unit)
    if flagDescriptionString == "" then
        return traitDescriptionString
    end
    return makeTraitDescription(unit)..", "..makeFlagDescription(unit)
end)

--[[Registers a function(unit)-->string to place help information at the bottom of the help box for foreign units]]
help.registerBottomForeignUnitHelpFunction(function(unit)
    return ""
end)



local function chooseBestAttacker(unitOrTile)
    local selection = help.selectBestAttacker(unitOrTile)
    if selection == unitOrTile then
        return nil, nil
    end
    if selection then
        return "Activate "..selection.type.name..".",{selection}
    end
    return nil, nil
end

--[[Registers a menuAction for the player's unit help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(unitObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(unitObject,table):void This function is called when the action is selected.
]]
help.registerUnitHelpMenuAction({
    [1]={description = chooseBestAttacker,
        effect = function(unit,params)
            params[1]:activate()
        end
    }
})




--[[Registers a menuAction for a foreign unit's help box.  Optionally,
--a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(unitObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(unitObject,table):void This function is called when the action is selected.
]]
help.registerForeignUnitMenuAction({
    [1]={description = chooseBestAttacker,
        effect = function(unit,params)
            params[1]:activate()
        end
    }
})



--[[Registers a menuAction for a tile's help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(tileObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(tileObject,table):void This function is called when the action is selected.
]]
help.registerTileHelpMenuAction({
    [1]={description = chooseBestAttacker,
        effect = function(tile,params)
            params[1]:activate()
        end
    }
})


--[[Register's a menuAction for a foreign city's help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(cityObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(cityObject,table):void This function is called when the action is selected.
]]
help.registerForeignCityHelpMenuAction({
    [1]={description = function(city) 
            local text,params = chooseBestAttacker(city.location)
            return text,params
        end,
        effect = function(city,params)
            params[1]:activate()
        end
    }
})

local helpSettings = {}
gen.versionFunctions(helpSettings,versionNumber, fileModified, "MechanicsFiles\\helpSettings.lua")
return helpSettings
