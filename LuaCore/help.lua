
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- You may wish to consider changing combat stats in initiateCombat instead of this module.

---@module "generalLibrary"
---@diagnostic disable-next-line: undefined-field
local gen = require("generalLibrary"):minVersion(14)
local leaderBonus = require("leaderBonus"):minVersion(3)
local text        = require("text")
local traits      = require("traits")
require("setTraits")
---@module "customCosmic"
---@diagnostic disable-next-line: undefined-field
local customCosmic= require("customCosmic"):minVersion(2)
---@module "combatModifiers"
local combatMod = require("combatModifiers"):minVersion(3)
local discreteEvents    = require("discreteEventsRegistrar")
local keyboard = require("keyboard")
---@module "configuration"
---@diagnostic disable-next-line: undefined-field
local configuration = require("configuration"):minVersion(2)
local combatCalculator = require("combatCalculator")
local changeRules = require("changeRules")
require("configurationSettings"):minVersion(2)
local aStar = require("aStarCiv")

---@class help
local help = {}
gen.versionFunctions(help,versionNumber, fileModified, "LuaCore".."\\".."help.lua")

---@type table<integer,fun(unit:unitObject):string>
local customDateUnitTooltipTable = {}

local function asteriskAdjustment(adjusted,base)
    if adjusted == base then
        return tostring(adjusted)
    else
        return tostring(adjusted).."*"
    end
end

--[[
Computes statistics for a unit help information,
including adjusted combat stats based on bonuses
and terrain, and returns a table with the following
keys:
 -baseAttack,
 -baseDefense,
 -baseFirepowerAttack,
 -baseFirepowerDefense,
 -adjustedAttack,
 -adjustedDefense,
 -adjustedFirepowerAttack,
 -adjustedFirepowerDefense,
 -activeBonusMessages
 -inactiveBonusMessages
 -moveMultipliers
 -moveRemaining
 -maxMoves
 -fortificationGround
 -fortificationAir
 -fortificationSea
 -attackerWallMultiplier # 1 if ignore walls, dCityWalls if attacker modifies the standard wall defense bonus, otherwise, standard wall multiplier
 -attacksRemaining # The number of attacks the unit can still make, or moveRemaing, whichever is smaller
]]
---@param unit unitObject
---@return table
function help.getUnitStats(unit)
    local resultTable = {}
    resultTable.baseAttack = unit.type.attack
    resultTable.baseDefense = unit.type.defense
    resultTable.baseFirepowerAttack = unit.type.firepower
    resultTable.baseFirepowerDefense = unit.type.firepower
    local combatModifierOverrideTableAttack = {}
    local combatModifierOverrideTableDefense = {}
    local helpListAttack = {}
    local helpListDefense = {}
    combatMod.applyRegisteredRules(unit,nil,combatModifierOverrideTableAttack,helpListAttack)


    combatMod.applyRegisteredRules(nil,unit,combatModifierOverrideTableDefense,helpListDefense)
    local modifiedAttack, modifiedFirepowerAttack, _,_ =combatCalculator.getCombatValues(unit,nil,false,combatModifierOverrideTableAttack)
    local _,_, modifiedDefense, modifiedFirepowerDefense = combatCalculator.getCombatValues(nil,unit,false,combatModifierOverrideTableDefense)
    
    resultTable.fortificationGround = modifiedDefense/combatCalculator.getCombatModifier("dConstant")
    resultTable.fortificationAir = modifiedDefense/combatCalculator.getCombatModifier("dConstant")
    resultTable.fortificationSea = modifiedDefense/combatCalculator.getCombatModifier("dConstant")
    if unit.type.domain ~= gen.c.domainLand then
        -- only ground units can take advantage of walls, fortresses,
        -- or being fortified
    elseif unit.location.city and (civ.hasImprovement(unit.location.city,gen.original.iCityWalls) or gen.isWonderActiveForTribe(gen.original.wGreatWall,unit.owner)) then
        local wallModifier = combatModifierOverrideTableDefense.dCityWalls or combatCalculator.getCombatModifier("dCityWalls")
        resultTable.fortificationGround = resultTable.fortificationGround*wallModifier
    elseif gen.hasFortress(unit.location) then
        local fortressModifier = combatModifierOverrideTableDefense.dFortress or combatCalculator.getCombatModifier("dFortress")
        resultTable.fortificationGround = resultTable.fortificationGround*fortressModifier
        resultTable.fortificationSea = resultTable.fortificationSea*fortressModifier
    elseif gen.isFortified(unit) then
        local fortifyModifier = combatModifierOverrideTableDefense.dFortified or combatCalculator.getCombatModifier("dFortified")
        resultTable.fortificationGround = resultTable.fortificationGround*fortifyModifier
        resultTable.fortificationAir = resultTable.fortificationAir*fortifyModifier
        resultTable.fortificationSea = resultTable.fortificationSea*fortifyModifier
    end

    -- SAM fortification bonus check
	if unit.location.city and (not gen.isAttackAir(unit.type)) and civ.hasImprovement(unit.location.city, gen.original.iSAMMissileBattery) then
        local samModifier = combatModifierOverrideTableDefense.dSAM or combatCalculator.getCombatModifier("dSamMissileBattery")
        resultTable.fortificationAir = resultTable.fortificationAir * samModifier
    end

    -- Coastal Fortress Check
    if unit.type.domain ~= gen.c.domainSea and unit.location.city and civ.hasImprovement(unit.location.city, gen.original.iCoastalFortress) then
        local coastalFortressModifier = combatModifierOverrideTableDefense.dCoastalFortress or combatCalculator.getCombatModifier("dCoastalFortress")
        resultTable.fortificationSea = resultTable.fortificationSea * coastalFortressModifier
    end



    resultTable.activeBonusMessages = {}
    resultTable.inactiveBonusMessages = {}
    for i=1,#helpListAttack.attackerHelpActiveList do
        resultTable.activeBonusMessages[i] = helpListAttack.attackerHelpActiveList[i]
    end
    for i=1,#helpListDefense.defenderHelpActiveList do
        resultTable.activeBonusMessages[#resultTable.activeBonusMessages + 1] = helpListDefense.defenderHelpActiveList[i]
    end
    for i=1,#helpListAttack.attackerHelpList do
        resultTable.inactiveBonusMessages[i] = helpListAttack.attackerHelpList[i]
    end
    for i=1,#helpListDefense.defenderHelpList do
        resultTable.inactiveBonusMessages[#resultTable.inactiveBonusMessages + 1] = helpListDefense.defenderHelpList[i]
    end
    resultTable.adjustedAttack = modifiedAttack/combatCalculator.getCombatModifier("aConstant")
    resultTable.adjustedDefense = modifiedDefense/combatCalculator.getCombatModifier("dConstant")
    resultTable.adjustedFirepowerAttack = modifiedFirepowerAttack
    resultTable.adjustedFirepowerDefense = modifiedFirepowerDefense
    local moveMultipliers = customCosmic.getMovementMultipliers(unit)
    resultTable.moveMultipliers = moveMultipliers
    local moveRemaining = gen.moveRemaining(unit)
    moveRemaining = math.max(moveRemaining,0)
    moveRemaining = gen.round(moveRemaining/moveMultipliers.aggregate,2)
    resultTable.moveRemaining = moveRemaining
    resultTable.attacksRemaining = moveRemaining
    if unit.type.attacksPerTurn and unit.type.attacksPerTurn > 0 then
        resultTable.attacksRemaining = unit.type.attacksPerTurn - unit.attackSpent
        resultTable.attacksRemaining = math.min(resultTable.attacksRemaining,math.ceil(resultTable.moveRemaining))
    end
    local maxMoves = gen.maxMoves(unit)
    maxMoves = gen.round(maxMoves/moveMultipliers.aggregate,2)
    resultTable.maxMoves = maxMoves
    resultTable.maxHitpoints = unit.type.hitpoints
    resultTable.currentHitpoints = unit.hitpoints
    -- compute attacker wall multiplier
    resultTable.attackerWallMultiplier = combatModifierOverrideTableAttack.dCityWalls or combatCalculator.getCombatModifier("dCityWalls") 
    if customCosmic.isIgnoreWalls(unit) then
        resultTable.attackerWallMultiplier = 1
    end
    return resultTable
end


---Creates a string to replace the date in the status window
---when a unit is active, in order to provide help to the
---player.
---@param unit unitObject
---@param backupString string A string to return (e.g. the formatted date) if a tooltip is not generated for some reason.
---@return string
function help.dateTooltip(unit,backupString)
    if gen.isDeletedUnitTile(unit.location) then
        return backupString
    end
    if customDateUnitTooltipTable[unit.type.id] then
        return customDateUnitTooltipTable[unit.type.id](unit)
    end
    local tooltipTemplate = "A(%STRING5):%STRING1 D:%STRING2 H:%STRING3 F:%STRING4"
    local tooltip = ""
    local statsTable = help.getUnitStats(unit)
    local attacksRemaining = statsTable.attacksRemaining
    if configuration.getSettingValue("useDateTooltip") == "baseStats" then
        tooltip = text.substitute(tooltipTemplate,{unit.type.attack,unit.type.defense,unit.type.hitpoints,unit.type.firepower,attacksRemaining})
        return tooltip
    end
    local adjustedAttack = statsTable.adjustedAttack
    local adjustedDefense = statsTable.adjustedDefense
    local adjustedFirepowerAttack = statsTable.adjustedFirepowerAttack
    local adjustedFirepowerDefense = statsTable.adjustedFirepowerDefense
    local hitpoints = statsTable.currentHitpoints
    local attack = statsTable.baseAttack
    local defense = statsTable.baseDefense
    local firepower = statsTable.baseFirepowerAttack

    local function firepowerString(adjFPAtk,adjFPDef,fp,mode)
        if mode == "baseStats" then
            return tostring(fp)
        end
        if mode == "adjustedStats" then
            if adjFPAtk == adjFPDef then
                return asteriskAdjustment(adjFPAtk,fp)
            else
                return asteriskAdjustment(adjFPAtk,fp).."/"..asteriskAdjustment(adjFPDef,fp)
            end
        end
        if mode == "bothStats" then
            return adjFPAtk.."("..fp..")/"..adjFPDef.."("..fp..")"
        end
    end
    if configuration.getSettingValue("useDateTooltip") == "adjustedStats" then
        tooltip = text.substitute(tooltipTemplate,{asteriskAdjustment(adjustedAttack,attack),asteriskAdjustment(adjustedDefense,defense),hitpoints,firepowerString(adjustedFirepowerAttack,adjustedFirepowerDefense,firepower,"adjustedStats"),attacksRemaining})
    end
    if configuration.getSettingValue("useDateTooltip") == "bothStats" then
        tooltip = text.substitute(tooltipTemplate,{adjustedAttack.."("..attack..")",adjustedDefense.."("..defense..")",hitpoints,firepowerString(adjustedFirepowerAttack,adjustedFirepowerDefense,firepower,"bothStats"),attacksRemaining})
    end
    local rank = leaderBonus.getRank(unit)
    if rank then
        tooltip = tooltip.." Rank: "..rank
    elseif leaderBonus.getCommanderRank(unit) then
        tooltip = tooltip.." Ldr: "..leaderBonus.getCommanderRank(unit)
    end
    return tooltip
end

---Registers a customised date tooltip function for particular units
---@param unitType unitTypeObject|string # If a trait, registers the tooltip function for all unitTypes with that trait
---@param tooltipFunction fun(unit: unitObject):string
function help.registerCustomDateTooltip(unitType,tooltipFunction)
    if type(tooltipFunction) ~= "function" then
        error("help.registerCustomDateTooltip: second argument must be a function(unit)-->string.  Received: "..tostring(tooltipFunction))
    end
    if civ.isUnitType(unitType) then
        if customDateUnitTooltipTable[unitType.id] then
            print("WARNING: Overwriting custom unit tooltip for unit type "..unitType.name)
        end
        customDateUnitTooltipTable[unitType.id] = tooltipFunction
        return
    end
    if type(unitType) == "string" then
        for unitID = 0,civ.cosmic.numberOfUnitTypes-1 do
            if traits.hasTrait(civ.getUnitType(unitID)--[[@as unitTypeObject]],unitType) then
                if customDateUnitTooltipTable[unitID] then
                    print("WARNING: Overwriting custom unit tooltip for unit type "..civ.getUnitType(unitID).name.." due to the trait "..unitType)
                end
                customDateUnitTooltipTable[unitID] = tooltipFunction
            end
        end
        return
    end
    error("help.registerCustomDateTooltip: first argument must be either unitTypeObject or valid trait.  Received: "..tostring(unitType))
end

---Registers a customised date tooltip function for particular units
local customListUnitTooltipTable = {}

---This function creates a one line tooltip for a unit, to be displayed
---when help is asked for on a tile owned by the player.
---@param unit unitObject # The unit for which the tooltip is being generated
---@return string tooltipString
function help.unitListTooltip(unit)
    if customListUnitTooltipTable[unit.type.id] then
        return customListUnitTooltipTable[unit.type.id](unit)
    end
    local tooltip = "%STRING[unitName] "..
        "MP:%STRING[moveRemaining]/%STRING[maxMoves] "..
        "A(%STRING[atkRemaining]):%STRING[adjAttack](%STRING[baseAttack]) D:%STRING[adjDefense](%STRING[baseDefense]) "..
        "FPA:%STRING[adjFPA](%STRING[baseFP]) FPD:%STRING[adjFPD](%STRING[baseFP]) HP:%STRING[hitpoints]/%STRING[maxHitpoints] "
    local statTable = help.getUnitStats(unit)
    local unitName = unit.type.name
    if unit.veteran then
        unitName = unitName.."("..text.getShortVeteranTitle()..")"
    end
    tooltip = text.substitute(tooltip,{unitName = unitName,
        adjAttack=statTable.adjustedAttack,
        baseAttack = statTable.baseAttack,
        adjDefense = statTable.adjustedDefense,
        baseDefense = statTable.baseDefense,
        adjFPA = statTable.adjustedFirepowerAttack,
        adjFPD = statTable.adjustedFirepowerDefense,
        baseFP = statTable.baseFirepowerAttack,
        hitpoints = statTable.currentHitpoints,
        maxHitpoints = statTable.maxHitpoints,
        moveRemaining = statTable.moveRemaining,
        maxMoves = statTable.maxMoves,
        atkRemaining = statTable.attacksRemaining,
    })
    return tooltip
end


---Registers a customised list tooltip function for particular unit types
---@param unitType unitTypeObject|string # If a trait, registers the tooltip function for all unitTypes with that trait
---@param tooltipFunction fun(unit: unitObject):string
function help.registerCustomListTooltip(unitType,tooltipFunction)
    if type(tooltipFunction) ~= "function" then
        error("help.registerCustomListTooltip: second argument must be a function(unit)-->string.  Received: "..tostring(tooltipFunction))
    end
    if civ.isUnitType(unitType) then
        if customListUnitTooltipTable[unitType.id] then
            print("WARNING: Overwriting custom unit tooltip for unit type "..unitType.name)
        end
        customListUnitTooltipTable[unitType.id] = tooltipFunction
        return
    end
    if type(unitType) == "string" then
        for unitID = 0,civ.cosmic.numberOfUnitTypes-1 do
            if traits.hasTrait(civ.getUnitType(unitID)--[[@as unitTypeObject]],unitType) then
                if customListUnitTooltipTable[unitID] then
                    print("WARNING: Overwriting custom unit tooltip for unit type "..civ.getUnitType(unitID).name.." due to the trait "..unitType)
                end
                customListUnitTooltipTable[unitID] = tooltipFunction
            end
        end
        return
    end
    error("help.registerCustomListTooltip: first argument must be either unitTypeObject or valid trait.  Received: "..tostring(unitType))
end

local movementMultiplierNames = {
    ["Road"] = "Road",
    ["Rail"] = "Rail",
    ["River"] = "River",
    ["Alpine"] = "Alpine",
}

---Registers custom movement multiplier names for `help.unitHelp`
---@param road string
---@param rail string
---@param river string
---@param alpine string
function help.registerCustomMovementMultiplierNames(road,rail,river,alpine)
    if type(road) ~= "string" and road ~= nil then
        error("help.registerCustomMovementMultiplierNames: first argument must be a string or nil.  Received: "..tostring(road))
    end
    if type(rail) ~= "string" and rail ~= nil then
        error("help.registerCustomMovementMultiplierNames: second argument must be a string or nil.  Received: "..tostring(rail))
    end
    if type(river) ~= "string" and river ~= nil then
        error("help.registerCustomMovementMultiplierNames: third argument must be a string or nil.  Received: "..tostring(river))
    end
    if type(alpine) ~= "string" and alpine ~= nil then
        error("help.registerCustomMovementMultiplierNames: fourth argument must be a string or nil.  Received: "..tostring(alpine))
    end
    if road then
        movementMultiplierNames["Road"] = road
    end
    if rail then
        movementMultiplierNames["Rail"] = rail
    end
    if river then
        movementMultiplierNames["River"] = river
    end
    if alpine then
        movementMultiplierNames["Alpine"] = alpine
    end
end


---Creates Text describing the flags (or other attributes
---specified by function(unit)-->boolean) of a unit type.
---@param unit unitObject
---@param descriptionTable table<integer,[fun(unitObject):boolean,string]> # A table where the values are a function to check if the unitType has the attribute and a string description, with keys specifying the order the descriptions should be written.
---@param separator? string # Separator between each hint.  Defaults to ", "
---@return string
function help.makeFlagDescription(unit, descriptionTable, separator)
    separator = separator or ", "
    local minKey,maxKey = gen.extremeKeys(descriptionTable)
    local descriptions = {}
    if not minKey then
        return ""
    end
    for i = minKey,maxKey do
        local entry = descriptionTable[i]
        if entry then
            local hasAttribute = entry[1](unit)
            if hasAttribute then
                table.insert(descriptions, entry[2])
            end
        end
    end
    return table.concat(descriptions, separator)
end

--[[Checks if the unit has the traits specified in the list, and, produces a list of the traits that it has]]
---@param unit unitObject
---@param traitDescriptionTable table<integer,[string,string]>
---@param separator? string # Separator between each hint.  Defaults to ", "
function help.makeTraitDescription(unit, traitDescriptionTable, separator)
    local hasTraits = {}
    local minKey,maxKey = gen.extremeKeys(traitDescriptionTable)
    if not minKey then
        return ""
    end
    for i = minKey,maxKey do
        local trait = traitDescriptionTable[i]
        if traits.hasTrait(unit.type, trait[1]) then
            table.insert(hasTraits, trait[2])
        end
    end
    return table.concat(hasTraits, separator)
end

-- Display above unit stats
local topUnitHelpFunction = function(unit) return "" end
-- Display between unit stats and bonus information
local middleUnitHelpFunction = function(unit) return "" end
-- Display after bonus information
local bottomUnitHelpFunction = function(unit) return "" end

--[[Registers a function(unit)-->string to place help information before the unit statistics in the unit help box]]
---@param func fun(unit: unitObject):string
function help.registerTopUnitHelpFunction(func)
    topUnitHelpFunction = func
end

--[[Registers a function(unit)-->string to place help information between the unit statistics and the combat bonus information]]
---@param func fun(unit: unitObject):string
function help.registerMiddleUnitHelpFunction(func)
    middleUnitHelpFunction = func
end

--[[Registers a function(unit)-->string to place help information after the bonus information]]
---@param func fun(unit: unitObject):string
function help.registerBottomUnitHelpFunction(func)
    bottomUnitHelpFunction = func
end


local topForeignUnitHelpFunction = function(unit) return "" end
local middleForeignUnitHelpFunction = function(unit) return "" end
local bottomForeignUnitHelpFunction = function(unit) return "" end
--[[Registers a function(unit)-->string to place help information before the unit statistics in the foreign unit help box]]
---@param func fun(unit: unitObject):string
function help.registerTopForeignUnitHelpFunction(func)
    topForeignUnitHelpFunction = func
end
--[[Registers a function(unit)-->string to place help information between the unit statistics and the combat bonus information]]
---@param func fun(unit: unitObject):string
function help.registerMiddleForeignUnitHelpFunction(func)
    middleForeignUnitHelpFunction = func
end
--[[Registers a function(unit)-->string to place help information after the bonus information]]
---@param func fun(unit: unitObject):string
function help.registerBottomForeignUnitHelpFunction(func)
    bottomForeignUnitHelpFunction = func
end

---A helpObject is an object for which a help box/menu has been created
---@generic helpObject

-- A menuAction defines an action that is presented as an
-- option within a help box menu for the helpObject.  
---@class menuAction<helpObject>
---@field public description string|fun(helpObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
---@field public effect fun(helpObject,table):void This function is called when the action is selected.

---@enum (key) menuActionTypes
local menuActionRegistry = {
    unitHelp = {},
    foreignUnitHelp = {},
    tileHelp = {},
    cityHelp = {},
    foreignCityHelp = {}
}

---Registers a menuAction for a particular help function
---@param actionType menuActionTypes
---@param action menuAction
local function registerMenuAction(actionType, action)
    if menuActionRegistry[actionType] then
        table.insert(menuActionRegistry[actionType], gen.copyTable(action))
    end
end

--[[Registers a menuAction for the player's unit help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(unitObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(unitObject,table):void This function is called when the action is selected.
]]
---@param action menuAction<unitObject>|table<integer,menuAction<unitObject>>
function help.registerUnitHelpMenuAction(action)
    if type(action) ~= "table" then
        error("help.registerUnitHelpMenuAction: first argument must be a menuAction table, or a table of menuAction tables.  Received: "..tostring(action))
    end
---@diagnostic disable-next-line: undefined-field
    if action.description == nil and action.effect == nil then
        -- assume a table of menuActions
        for i = 1,#action do
            help.registerUnitHelpMenuAction(action[i])
        end
        return
    end
    registerMenuAction("unitHelp", action)
end


--[[Registers a menuAction for a foreign unit's help box.  Optionally,
--a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(unitObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(unitObject,table):void This function is called when the action is selected.
]]
---@param action menuAction<unitObject>|table<integer,menuAction<unitObject>>
function help.registerForeignUnitMenuAction(action)
    if type(action) ~= "table" then
        error("help.registerForeignUnitMenuAction: first argument must be a menuAction table, or a table of menuAction tables.  Received: "..tostring(action))
    end
---@diagnostic disable-next-line: undefined-field
    if action.description == nil and action.effect == nil then
        -- assume a table of menuActions
        for i = 1,#action do
            help.registerForeignUnitMenuAction(action[i])
        end
        return
    end
    registerMenuAction("foreignUnitHelp", action)
end

--[[Registers a menuAction for a tile's help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(tileObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(tileObject,table):void This function is called when the action is selected.
]]
---@param action menuAction<tileObject>|table<integer,menuAction<tileObject>>
function help.registerTileHelpMenuAction(action)
    if type(action) ~= "table" then
        error("help.registerTileHelpMenuAction: first argument must be a menuAction table, or a table of menuAction tables.  Received: "..tostring(action))
    end
---@diagnostic disable-next-line: undefined-field
    if action.description == nil and action.effect == nil then
        -- assume a table of menuActions
        for i = 1,#action do
            help.registerTileHelpMenuAction(action[i])
        end
        return
    end
    registerMenuAction("tileHelp", action)
end

--[[Registers a menuAction for a player's city's help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(cityObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(cityObject,table):void This function is called when the action is selected.
]]
---@param menuAction menuAction<cityObject>|table<integer,menuAction<cityObject>>
function help.registerCityHelpMenuAction(menuAction)
    if type(menuAction) ~= "table" then
        error("help.registerCityHelpMenuAction: first argument must be a menuAction table, or a table of menuAction tables.  Received: "..tostring(menuAction))
    end
---@diagnostic disable-next-line: undefined-field
    if menuAction.description == nil and menuAction.effect == nil then
        -- assume a table of menuActions
        for i = 1,#menuAction do
            help.registerCityHelpMenuAction(menuAction[i])
        end
        return
    end
    registerMenuAction("cityHelp", menuAction)
end

--[[Register's a menuAction for a foreign city's help box.  Optionally,
a table (with integer indices) of menuActions can be registered at once.
A menuAction is a table with two fields:
- description: string|fun(cityObject):string|nil,table Provides text for the option in the help box menu.  If nil is returned, the menu option isn't shown.  The function must also return a table to pass to the effect function.  If a string is provided, an empty table is passed to the effect function, and the action is always shown in the menu.
- effect: fun(cityObject,table):void This function is called when the action is selected.
]]
---@param menuAction menuAction<cityObject>|table<integer,menuAction<cityObject>>
function help.registerForeignCityHelpMenuAction(menuAction)
    if type(menuAction) ~= "table" then
        error("help.registerForeignCityHelpMenuAction: first argument must be a menuAction table, or a table of menuAction tables.  Received: "..tostring(menuAction))
    end
---@diagnostic disable-next-line: undefined-field
    if menuAction.description == nil and menuAction.effect == nil then
        -- assume a table of menuActions
        for i = 1,#menuAction do
            help.registerForeignCityHelpMenuAction(menuAction[i])
        end
        return
    end
    registerMenuAction("foreignCityHelp", menuAction)
end

--[[Adds menuActions to the menuTable, and returns a function to
execute the chosen action, if applicable.]]
---@param menuTable table
---@param startIndex integer
---@param registrySection menuActionTypes
---@param helpObject any The object for which help is being called
---@return fun(choice:integer)
local function prepareMenuActions(menuTable,startIndex,registrySection,helpObject)
    local actionFunctions = {}
    local registry = menuActionRegistry[registrySection]
    if not registry then
        error("help.prepareMenuActions: third argument must be a valid menuActionTypes key.  Received: "..tostring(registrySection))
    end
    local actionIndex = startIndex
    for i = 1,#registry do
        local entry = registry[i]
        if type(entry.description) == "string" then
            menuTable[actionIndex] = entry.description
            actionFunctions[actionIndex] = function() entry.effect(helpObject,{}) end
            actionIndex = actionIndex + 1
        elseif type(entry.description) == "function" then
            local description, passTable = entry.description(helpObject)
            if type(description) == "string" then
                menuTable[actionIndex] = description
                actionFunctions[actionIndex] = function() entry.effect(helpObject,passTable) end
                actionIndex = actionIndex + 1
            end
        end
    end
    return function(choice)
        if actionFunctions[choice] then
            return actionFunctions[choice]()
        end

    end
end

---Creates and a detailed help message for a unit
---If applicable, the player will be given a choice to look
---at tile help, or to look at the menu for other units
---stacked on the tile.
---@param unit unitObject
function help.unitHelp(unit)
    local unitStats = help.getUnitStats(unit)
    local adjustedAttack = unitStats.adjustedAttack
    local adjustedDefense = unitStats.adjustedDefense
    local adjustedFirepowerAttack = unitStats.adjustedFirepowerAttack
    local adjustedFirepowerDefense = unitStats.adjustedFirepowerDefense
    local hitpoints = unitStats.maxHitpoints
    local firepower = unitStats.baseFirepowerAttack
    local moveMultipliers = unitStats.moveMultipliers
    local moveRemaining = unitStats.moveRemaining
    local maxMoves = unitStats.maxMoves
    local attack = unitStats.baseAttack
    local defense = unitStats.baseDefense
    local fortVsGround = unitStats.fortificationGround
    local fortVsAir = unitStats.fortificationAir
    local fortVsSea = unitStats.fortificationSea

    local statTable = {[1]={},[2]={},[3]={},[4]={},[5]={}}
    statTable[1][1] = "Hit Points:"
    statTable[1][2] = tostring(unit.hitpoints).."/"..tostring(hitpoints)
    statTable[1][3] = "Move Points:"
    statTable[1][4] = tostring(moveRemaining).."/"..tostring(maxMoves)
    statTable[2][1] = "Attacks:"
    statTable[2][2] = tostring(unitStats.attacksRemaining).."/"..tostring(unit.type.attacksPerTurn or "N/A")
    statTable[2][3] = ""
    statTable[2][4] = ""
    statTable[3][1] = "Attack:"
    statTable[3][2] = tostring(adjustedAttack).."("..tostring(attack)..")"
    statTable[3][3] = "Defense:"
    statTable[3][4] = tostring(adjustedDefense).."("..tostring(defense)..")"
    statTable[4][1] = "Fortification:"
    statTable[4][2] = "Land: "..tostring(fortVsGround)
    statTable[4][3] = "Air: "..tostring(fortVsAir)
    statTable[4][4] = "Sea: "..tostring(fortVsSea)
    statTable[5][1] = "Atk FP:"
    statTable[5][2] = tostring(adjustedFirepowerAttack).."("..tostring(firepower)..")"
    statTable[5][3] = "Def FP:"
    statTable[5][4] = tostring(adjustedFirepowerDefense).."("..tostring(firepower)..")"
    local function moveMultTranslate(number,mode)
        if number == -1 then
            return movementMultiplierNames[mode]..": Unlimited"
        end
        if number == 0 then
            return movementMultiplierNames[mode]..": Normal"
        end
        return movementMultiplierNames[mode]..": "..tostring(number)
    end
    if unit.type.domain == gen.c.domainLand then
        statTable[6] = {}
        statTable[6][1] = "Bonuses:"
        statTable[6][2] = moveMultTranslate(moveMultipliers.railroad, "Rail")
        if customCosmic.isAlpine(unit) then
            statTable[6][3] = moveMultTranslate(moveMultipliers.alpine, "Alpine")
        else
            statTable[6][3] = moveMultTranslate(moveMultipliers.road, "Road")
        end
        statTable[6][4] = moveMultTranslate(moveMultipliers.river, "River")
    end
    local rank = leaderBonus.getRank(unit)
    local commanderRank = leaderBonus.getCommanderRank(unit)
    local helpString = topUnitHelpFunction(unit).."\n"
    helpString = helpString..text.simpleTabTableToText(statTable,4)
    helpString = helpString.."\n"
    if rank then
        helpString = helpString.."^Leader Class: "..rank.."\n"
    elseif commanderRank then
        helpString = helpString.."^Commander: "..commanderRank.."\n"
    end
    helpString = helpString..middleUnitHelpFunction(unit).."\n"
    for i = 1,#unitStats.activeBonusMessages do
        helpString = helpString.."^"..unitStats.activeBonusMessages[i].."\n"
    end
    for i = 1,#unitStats.inactiveBonusMessages do
        helpString = helpString.."^"..unitStats.inactiveBonusMessages[i].."\n"
    end
    helpString = "^"..helpString..bottomUnitHelpFunction(unit)
    local choices = {
        [1] = "Close",
        [2] = "Stack Help Menu",
        [4] = "Terrain Help",
    }
    if moveRemaining > 0 then
        choices[3] = "Activate this "..unit.type.name
    end
    -- Second argument for prepareMenuActions is the index to start adding actions at.  Must be at least one more than the highest index in choices
    local actionFunction = prepareMenuActions(choices, 5, "unitHelp", unit)
    local choice = text.menu(choices,helpString,"Help for "..unit.type.name,text.unitTypeImage(unit.type))
    if choice == 2 then
        return help.tileStackHelpMenu(unit.location)
    end
    if choice == 4 then
        return help.terrainHelp(unit.location)
    end
    if choice == 3 then
        return unit:activate()
    end
    if choice == 1 then
        return
    end
    return actionFunction(choice)
end



--[[
Produces a help box for the top foreign unit on the tile,
if the stack is visible to the player.
]]
---@param tile tileObject
function help.foreignUnitHelp(tile)
    local player = civ.getPlayerTribe()
    if not gen.isTileRevealed(tile,player) then
        return help.terrainHelp(tile)
    end
    if not gen.isUnitStackVisible(tile,player) then
        return help.terrainHelp(tile)
    end
    local unit = tile.units()
    local unitStats = help.getUnitStats(unit)
    local adjustedAttack = unitStats.adjustedAttack
    local adjustedDefense = unitStats.adjustedDefense
    local adjustedFirepowerAttack = unitStats.adjustedFirepowerAttack
    local adjustedFirepowerDefense = unitStats.adjustedFirepowerDefense
    local hitpoints = unitStats.maxHitpoints
    local firepower = unitStats.baseFirepowerAttack
    local moveMultipliers = unitStats.moveMultipliers
    local moveRemaining = unitStats.moveRemaining
    local maxMoves = unitStats.maxMoves
    local attack = unitStats.baseAttack
    local defense = unitStats.baseDefense
    local statTable = {[1]={},[2]={},[3]={}}
    statTable[1][1] = "Hit Points:"
    statTable[1][2] = tostring(unit.hitpoints).."/"..tostring(unit.type.hitpoints)
    statTable[1][3] = "Move Points:"
    statTable[1][4] = tostring(maxMoves)
    statTable[2][1] = "Attack:"
    statTable[2][2] = tostring(adjustedAttack).."("..tostring(attack)..")"
    statTable[2][3] = "Defense:"
    statTable[2][4] = tostring(adjustedDefense).."("..tostring(defense)..")"
    statTable[3][1] = "Atk FP:"
    statTable[3][2] = tostring(adjustedFirepowerAttack).."("..tostring(firepower)..")"
    statTable[3][3] = "Def FP:"
    statTable[3][4] = tostring(adjustedFirepowerDefense).."("..tostring(firepower)..")"
    local helpString = topForeignUnitHelpFunction(unit).."\n"
    helpString = helpString..text.simpleTabTableToText(statTable,4)
    helpString = helpString.."\n"
    helpString = helpString..middleForeignUnitHelpFunction(unit).."\n"
    for i = 1,#unitStats.activeBonusMessages do
        helpString = helpString.."^"..unitStats.activeBonusMessages[i].."\n"
    end
    for i = 1,#unitStats.inactiveBonusMessages do
        helpString = helpString.."^"..unitStats.inactiveBonusMessages[i].."\n"
    end
    helpString = helpString..bottomForeignUnitHelpFunction(unit).."\n"
    local choices = {
        [1] = "Close",
        [2] = "Terrain Help",
    }
    -- Second argument for prepareMenuActions is the index to start adding actions at.  Must be at least one more than the highest index in choices
    local actionFunction = prepareMenuActions(choices, 4, "foreignUnitHelp", unit)
    local choice = text.menu(choices,helpString,"Help for "..unit.type.name,text.unitTypeImage(unit.type))
    if choice == 2 then
        return help.terrainHelp(unit.location)
    end
    if choice == 1 then
        return
    end
    return actionFunction(choice)
end

---Provides a help text box for a city owned by the active player
---@param city cityObject
function help.cityHelp(city)

    local helpString = ""
    local cityCosmic = customCosmic.getCityCustomisation(city)
    local statTable = {[1]={},[2]={},[3]={}}
    statTable[1][1] = "Population:"
    text.simpleTabTableToText(statTable,4)
    local choices = {
        [1] = "Close",
        [2] = "Tile Help Menu",
    }
    -- Second argument for prepareMenuActions is the index to start adding actions at.  Must be at least one more than the highest index in choices
    local actionFunction = prepareMenuActions(choices, 3, "cityHelp", city)
    local choice = text.menu(choices,helpString,"Help for "..city.name)
    if choice == 1 then
        return
    end
    if choice == 2 then
        return help.tileStackHelpMenu(city.location)
    end
end

---Provides a help text box for a foreign city
---@param city any
function help.foreignCityHelp(city)

    local helpString = ""
    local statTable = {[1]={},[2]={},[3]={}}
    statTable[1][1] = "Population:"
    statTable[1][2] = tostring(city.size)
    text.simpleTabTableToText(statTable,4)
    local choices = {
        [2] = "Close",
    }
    local actionFunction = prepareMenuActions(choices, 3, "foreignCityHelp", city)
    local choice = text.menu(choices,helpString,"Help for "..city.name)
    if choice == 1 then
        return help.tileStackHelpMenu(city.location)
    end
    if choice == 2 then
        return
    end
    actionFunction(choice)
end

---Produces a help menu for a tile, giving each unit on the
---tile as a choice, as well as the terrain help.
---The list tooltip is used to provide a one line description
---of the unit's status
---@param tile tileObject
function help.tileStackHelpMenu(tile)
    local player = civ.getPlayerTribe()
    if not gen.isTileRevealed(tile,player) then
        return help.terrainHelp(tile)
    end
    if tile.city and tile.city.owner ~= player then
        return help.foreignCityHelp(tile.city)
    end
    if tile.defender == nil then
        return help.terrainHelp(tile)
    end
    if tile.defender ~= player then
        help.foreignUnitHelp(tile)
        return
    end
    local menuTable = {}
    menuTable[1] = "Close"
    menuTable[2] = "Help for "..tile.terrain.name.."."
    if tile.city and tile.city.owner == player then
        menuTable[3] = "Help for "..tile.city.name.."."
    end
    local actionFunction = prepareMenuActions(menuTable, 4, "tileHelp", tile)
    local minMenu,maxMenu = gen.extremeKeys(menuTable)
    local unitList = {}
    local unitCount = 0
    local offset = maxMenu+1
    for unit in tile.units do
        unitCount = unitCount + 1 
        unitList[unitCount] = unit
        menuTable[unitCount+offset] = help.unitListTooltip(unit)
    end
    local choice = text.menu(menuTable,"Help for "..tile.terrain.name)
    if choice == 1 then
        return
    end
    if choice == 2 then
        return help.terrainHelp(tile)
    end
    if choice == 3 then
        return help.cityHelp(tile.city)
    end
    if choice > 3 and choice < offset then
        return actionFunction(choice)
    end
    local unit = unitList[choice - offset]
    if unit then
        help.unitHelp(unit)
    end
end

---Produces a help box for a game tile
---@param tile tileObject
function help.terrainHelp(tile)
    local player = civ.getPlayerTribe()
    local helpString = ""
    local city = tile.city
    local cityWorkingTile = gen.getCityWorkingTile(tile)
    if city then
        helpString = helpString.."^City: "..city.name.."\n"
    elseif cityWorkingTile and cityWorkingTile.owner == player then
        helpString = helpString.."^Worked By: "..cityWorkingTile.name.."\n"
    elseif cityWorkingTile and cityWorkingTile.owner ~= player then
        cityWorkingTile = nil
    end
    local statTable = {}
    local defaultBaseTerrain = changeRules.authoritativeDefaultRules[tile.baseTerrain]
    local defaultTerrain = changeRules.authoritativeDefaultRules[tile.terrain]

    statTable[1] = {"","Food","Shields","Trade"}
    local baseIndex = 2
    if cityWorkingTile then
        baseIndex = 3
        local food,shields,trade = gen.getTileProduction(tile,cityWorkingTile)
        statTable[2] = {cityWorkingTile.name.." Production:",food,shields,trade}
    end
    local tradeBonus = 0
    if defaultTerrain.trade > 0 or gen.isBit1(changeRules.authoritativeDefaultRules["totpp.roadTrade"][tile.z], tile.baseTerrain.type+1) then
        tradeBonus = 1
    end
    if tile.baseTerrain.type == gen.c.oceanBaseTerrainType then
        tradeBonus = 0
    end
    statTable[baseIndex] = {"Base Production:",defaultTerrain.food,defaultTerrain.shields,defaultTerrain.trade}
    statTable[baseIndex+1] = {"Improvement Bonus:",defaultBaseTerrain.irrigateBonus,defaultBaseTerrain.mineBonus,tradeBonus}
    statTable[baseIndex+2] = {"","","",""}
    statTable[baseIndex+3] = {"Move Cost:",defaultBaseTerrain.moveCost,"",""}
    statTable[baseIndex+4] = {"Defense Bonus:","x"..tostring(gen.round(defaultBaseTerrain.defense*0.5,1)),"",""}
    helpString = helpString..text.simpleTabTableToText(statTable,4)

    local menuTable = {}
    if tile.defender then
        menuTable[2] = "Stack Help Menu"
    end
    menuTable[1] = "Close"
    if not gen.isTileRevealed(tile,player) then
        helpString = "^No help available for unrevealed tiles.\n"
    end
    local helpTitle = "Help for "..tile.terrain.name
    if not gen.isTileRevealed(tile,player) then
        helpTitle = "Help for Unknown Tile"
        menuTable[2] = nil
    end
    local choice = text.menu(menuTable,helpString,helpTitle)
    if choice == 2 then
        return help.tileStackHelpMenu(tile)
    end
    if choice == 1 then
        return
    end
end


--[[A hintTable for a unitType has two keys,
    -orderedHints = {[hintPlaceInteger]=string}
    -unorderedHints = {[integer]=string}
If help.registerHint(unitType|trait,hint,hintPlaceInteger?)
is called with non-nil hintPlaceInteger, the hint will be added to the
orderedHints table at the specified place. If hintPlaceInteger is nil,
the hint will be added to the unorderedHints table.  If the hintPlaceInteger
already exists in the orderedHints table, an error will be generated.
When help.unitTypeHints(unitType) is called, a string will be produced,
with all the hints for that unitType, with the ordered hints appearing in
the locations specified by their hintPlaceInteger (ignoring any gaps),
and the unordered hints appearing at the end.]]

-- Stores the hintTable for each unit type, indexed by unitType.id
local hintsPerUnitType = {}

--[[Registers a hint for a unitType or all the unitTypes with
a given trait, to be displayed for that unitType's help box.]]
---@param unitType unitTypeObject|string A unit type or trait
---@param hint string The hint to be displayed in the help box
---@param hintPlaceInteger? integer The place of the hint among the hints for the unitType (gaps are ignored).  If not specified, the hint will be shown in an arbitrary order after all hints created with a hintPlaceInteger.  Duplicating the hintPlaceInteger for a unitType will result in an error.
function help.registerHint(unitType,hint,hintPlaceInteger)
    if type(unitType) == "string" then
        for possibleUnitType in gen.iterateUnitTypes() do
            if traits.hasTrait(possibleUnitType,unitType) then
                help.registerHint(possibleUnitType,hint,hintPlaceInteger)
            end
        end
        return
    end
    local hintTable = hintsPerUnitType[unitType.id] or {orderedHints = {}, unorderedHints = {}}
    if hintPlaceInteger then
        if hintTable.orderedHints[hintPlaceInteger] then
            error("Hint "..hintPlaceInteger.." already exists in orderedHints table for unitType "..unitType.name..".")
        end
        if type(hintPlaceInteger) ~= "number" or hintPlaceInteger ~= math.floor(hintPlaceInteger) then
            error("hintPlaceInteger must be an integer.  Received "..tostring(hintPlaceInteger).." for unitType "..unitType.name.." and hint '"..hint.."'.")
        end
        hintTable.orderedHints[hintPlaceInteger] = hint
    else
        hintTable.unorderedHints[#hintTable.unorderedHints+1] = hint
    end
    hintsPerUnitType[unitType.id] = hintTable
end

--[[Generates a string for all the registered hints of a unitType.]]
---@param unitType unitTypeObject
---@param separator? string A separator between each hint.  Defaults to ", "
---@return string
function help.unitTypeHints(unitType,separator)
    local hintTable = hintsPerUnitType[unitType.id]
    if not hintTable then
        return ""
    end
    separator = separator or ", "
    local hints = {}
    local minHint,maxHint = gen.extremeKeys(hintTable.orderedHints)
    if not minHint then
        minHint = 0
        maxHint = -1
    end
    for i = minHint,maxHint do
        hints[#hints+1] = hintTable.orderedHints[i]
    end
    for i = 1,#hintTable.unorderedHints do
        hints[#hints+1] = hintTable.unorderedHints[i]
    end
    return table.concat(hints,separator)
end

---Activates help for the active unit or highlighted tile
function help.onHelpKeyPress()
    if civ.getActiveUnit() then
        help.unitHelp(civ.getActiveUnit())
    else
        help.tileStackHelpMenu(civ.getCurrentTile())
    end
end

---@type fun(attacker:unitObject,defender:unitObject|nil,isSneakAttack:boolean):number,number,number,number
local computeCombatStatisticsFunction = nil

--[[Registers a function (attacker,defender,isSneakAttack)-->attackerStrength, attackerFirepower, defenderStrength, defenderFirepower
For use in help.rateAttacker and help.selectBestAttacker
]]
---@param func fun(attacker:unitObject,defender:unitObject|nil,isSneakAttack:boolean):number,number,number,number
function help.registerComputeCombatStatisticsFunction(func)
    if type(func) ~= "function" then
        error("help.registerComputeCombatStatisticsFunction: first argument must be a function.  Received: "..tostring(func))
    end
    computeCombatStatisticsFunction = func
end

--Provides a numerical rating of a unit's ability to attack.
--If a proposedDefender is provided, the rating will reflect
--the relative attack and defense power of the two units.
---@param unit unitObject
---@param proposedDefender? unitObject
---@param cityWalls? boolean Adjusts for ability against city walls if true, ignored if proposedDefender is a unit 
---@return number
function help.rateAttacker(unit,proposedDefender,cityWalls)
    if proposedDefender and not civ.isUnit(proposedDefender) then
        error("help.rateAttacker: second argument must be a unit or nil.  Received: "..tostring(proposedDefender))
    end
    if proposedDefender then
        local attackerStrength, attackerFirepower, defenderStrength, defenderFirepower = computeCombatStatisticsFunction(unit,proposedDefender,false)
        if defenderStrength <= 0 then 
            return 1e8
        end
        return (attackerStrength/defenderStrength)*(unit.hitpoints/unit.type.hitpoints)
    end
    local statTable = help.getUnitStats(unit)
    if cityWalls then
        return (statTable.adjustedAttack/statTable.attackerWallMultiplier)*(unit.hitpoints/unit.type.hitpoints)
    end
    return statTable.adjustedAttack*(unit.hitpoints/unit.type.hitpoints)
end

--[[Selects the best unit for attacking, given context.  If the
first argument is a unit or tile owned/defended by the active player,
the unit with the highest adjusted attack on that tile will be chosen.<br>
If the first argument is a unit owned by another player, a unit adjacent
owned by the active player with the highest adjusted divided by that unit's adjusted defense will be chosen.  If the argument is a tile defended by
another player, the top unit (determined by tile.units()) will be chosen,
unless the tile has a city, in which case adjusted attack won't be compared
to a defender, but city wall related bonuses will be considered.<br>
If the second argument is a trait, only units with that trait will be considered.<br>
In all cases, the unit must not have used up all its attacks for the turn.
If no valid unit is found, nil is returned.<br>
Note that if a defender isn't specified, attackerHelpActive must be set for a combatModification to be applied.
]]
---@param unitOrTile unitObject|tileObject
---@param trait? string
---@return unitObject|nil
function help.selectBestAttacker(unitOrTile,trait)
    local center = nil
    local radius = 0
    local proposedDefender = nil
    local cityWalls = false
    if civ.isTile(unitOrTile) then
        center = unitOrTile
        if unitOrTile.defender and unitOrTile.defender == civ.getPlayerTribe() then
            -- Defended by the player, so look for the best attacker on the tile
            radius = 0
            center = unitOrTile
        else
            -- Defended by another player, so look for the best attacker adjacent to the tile
            center = unitOrTile
            radius = 1
            if unitOrTile.city and civ.hasImprovement(unitOrTile.city,gen.original.iCityWalls) then
                cityWalls = true
            end
        end
    elseif civ.isUnit(unitOrTile) then
        if unitOrTile.owner == civ.getPlayerTribe() then
            -- Owned by the player, so look for the best attacker on the tile
            radius = 0
            center = unitOrTile.location
        else
            -- Owned by another player, so look for the best attacker adjacent to the tile
            radius = 1
            center = unitOrTile.location
            proposedDefender = unitOrTile --[[@as unitObject]]
        end
    else
        error("help.selectBestAttacker: first argument must be a unit or tile.  Received: "..tostring(unitOrTile))
    end
    if trait and type(trait) ~= "string" then
        error("help.selectBestAttacker: second argument must be a string or nil.  Received: "..tostring(trait))
    end
    local bestUnit = nil
    local bestValue = -1
    local function evaluateUnit(unit)
        if unit.owner ~= civ.getPlayerTribe() then
            return
        end
        if trait and not traits.hasTrait(unit.type,trait) then
            return
        end
        local statTable = help.getUnitStats(unit)
        if statTable.adjustedAttack <= 0 then
            return
        end
        if statTable.attacksRemaining <= 0 then
            return
        end
        local value = help.rateAttacker(unit,proposedDefender,cityWalls)
        if value > bestValue then
            bestValue = value
            bestUnit = unit
        end
    end
    for nearbyUnit in gen.nearbyUnits(center,radius,center.z) do
        evaluateUnit(nearbyUnit)
    end
    return bestUnit
end








return help