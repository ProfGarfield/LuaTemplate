---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(13)
local leaderBonus = require("leaderBonus"):minVersion(3)
local text        = require("text")
local traits      = require("traits")
require("setTraits")
local customCosmic= require("customCosmic")
local combatMod = require("combatModifiers")
local discreteEvents    = require("discreteEventsRegistrar")
local keyboard = require("keyboard")
local configuration = require("configuration")
local combatCalculator = require("combatCalculator")

---@class help
local help = {}

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
    resultTable.adjustedAttack = modifiedAttack//combatCalculator.getCombatModifier("aConstant")
    resultTable.adjustedDefense = modifiedDefense//combatCalculator.getCombatModifier("dConstant")
    resultTable.adjustedFirepowerAttack = modifiedFirepowerAttack
    resultTable.adjustedFirepowerDefense = modifiedFirepowerDefense
    local moveMultipliers = customCosmic.getMovementMultipliers(unit)
    resultTable.moveMultipliers = moveMultipliers
    local moveRemaining = gen.moveRemaining(unit)
    moveRemaining = math.max(moveRemaining,0)
    moveRemaining = gen.round(moveRemaining/moveMultipliers.aggregate,2)
    resultTable.moveRemaining = moveRemaining
    local maxMoves = gen.maxMoves(unit)
    maxMoves = gen.round(maxMoves/moveMultipliers.aggregate,2)
    resultTable.maxMoves = maxMoves
    resultTable.maxHitpoints = unit.type.hitpoints
    resultTable.currentHitpoints = unit.hitpoints
    return resultTable
end

--[==[
---Computes statistics for a unit help information,
---including adjusted combat stats based on bonuses
---and terrain, and returns a table with the following
---keys:
--- -baseAttack,
--- -baseDefense,
--- -baseFirepowerAttack,
--- -baseFirepowerDefense,
--- -adjustedAttack,
--- -adjustedDefense,
--- -adjustedFirepowerAttack,
--- -adjustedFirepowerDefense,
--- -activeBonusMessages
--- -inactiveBonusMessages
--- -moveMultipliers
--- -moveRemaining
--- -maxMoves
---@param unit unitObject
---@return table
function help.getUnitStats(unit)
    local helpInfoTable = combatMod.bonusHelp(unit)
    local attack = unit.type.attack
    local defense = unit.type.defense
    local hitpoints = unit.type.hitpoints
    local firepower = unit.type.firepower
    local adjustedAttack = attack + helpInfoTable.aCustomAddSum
    adjustedAttack = math.max(1,adjustedAttack)
    adjustedAttack = adjustedAttack * helpInfoTable.aCustomMultProduct
    if attack == 0 then
        adjustedAttack = 0
    end
    local adjustedDefense = defense + helpInfoTable.dCustomAddSum
    adjustedDefense = math.max(0,adjustedDefense)
    adjustedDefense = adjustedDefense * helpInfoTable.dCustomMultProduct
    local terrainDefenseMult = unit.location.baseTerrain.defense/2
    if helpInfoTable.highTerrainMult and helpInfoTable.lowTerrainMult then
        if helpInfoTable.highTerrainMult == helpInfoTable.lowTerrainMult then
            terrainDefenseMult = helpInfoTable.highTerrainMult    
        else
            local defBuff = helpInfoTable.highTerrainMult - terrainDefenseMult
            local defDebuff = helpInfoTable.lowTerrainMult - terrainDefenseMult
            terrainDefenseMult = terrainDefenseMult + defBuff + defDebuff
        end
    end
    if unit.location.river then
        terrainDefenseMult = terrainDefenseMult + combatCalculator.getCombatModifier("dRiverAddition")
    end
    if unit.type.domain == gen.c.domainAir and not combatCalculator.getCombatModifier("dTerrainDefenseForAir") then
        terrainDefenseMult = 1
    end
    if unit.type.domain == gen.c.domainSea and not combatCalculator.getCombatModifier("dTerrainDefenseForSea") then
        terrainDefenseMult = 1
    end
    adjustedDefense = adjustedDefense * terrainDefenseMult
    if unit.type.domain == gen.c.domainLand and 
        gen.isFortified(unit) then
            adjustedDefense = adjustedDefense*
            combatCalculator.getCombatModifier("dFortified")
        
    end



    local adjustedFirepowerAttack = firepower + helpInfoTable.aAddFirepowerSum
    adjustedFirepowerAttack = math.max(1,adjustedFirepowerAttack)
    local adjustedFirepowerDefense = firepower + helpInfoTable.dAddFirepowerSum
    adjustedFirepowerDefense = math.max(1,adjustedFirepowerDefense)
    local moveMultipliers = customCosmic.getMovementMultipliers(unit)
    local moveRemaining = math.max(gen.moveRemaining(unit),0)
    moveRemaining = gen.round(moveRemaining/moveMultipliers.aggregate,2)
    local maxMoves = gen.maxMoves(unit)
    maxMoves = gen.round(maxMoves/moveMultipliers.aggregate,2)
    local statsTable = {
        baseAttack = attack,
        baseDefense = defense,
        baseFirepowerAttack = firepower,
        baseFirepowerDefense = firepower,
        adjustedAttack = adjustedAttack,
        adjustedDefense = adjustedDefense,
        adjustedFirepowerAttack = adjustedFirepowerAttack,
        adjustedFirepowerDefense = adjustedFirepowerDefense,
        activeBonusMessages = helpInfoTable.activeBonusMessages,
        inactiveBonusMessages = helpInfoTable.inactiveBonusMessages,
        moveMultipliers = moveMultipliers,
        moveRemaining = moveRemaining,
        maxMoves = maxMoves,
        maxHitpoints = hitpoints,
        currentHitpoints = unit.hitpoints,
    }
    return statsTable
end
--]==]

---Creates a string to replace the date in the status window
---when a unit is active, in order to provide help to the
---player.
---@param unit unitObject
---@return string
function help.dateTooltip(unit)
    if customDateUnitTooltipTable[unit.type.id] then
        return customDateUnitTooltipTable[unit.type.id](unit)
    end
    local tooltipTemplate = "A:%STRING1 D:%STRING2 H:%STRING3 F:%STRING4"
    local tooltip = ""
    if configuration.getSettingValue("useDateTooltip") == "baseStats" then
        tooltip = text.substitute(tooltipTemplate,{unit.type.attack,unit.type.defense,unit.type.hitpoints,unit.type.firepower})
        return tooltip
    end
    local statsTable = help.getUnitStats(unit)
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
        tooltip = text.substitute(tooltipTemplate,{asteriskAdjustment(adjustedAttack,attack),asteriskAdjustment(adjustedDefense,defense),hitpoints,firepowerString(adjustedFirepowerAttack,adjustedFirepowerDefense,firepower,"adjustedStats")})
    end
    if configuration.getSettingValue("useDateTooltip") == "bothStats" then
        tooltip = text.substitute(tooltipTemplate,{adjustedAttack.."("..attack..")",adjustedDefense.."("..defense..")",hitpoints,firepowerString(adjustedFirepowerAttack,adjustedFirepowerDefense,firepower,"bothStats")})
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
        "A:%STRING[adjAttack](%STRING[baseAttack]) D:%STRING[adjDefense](%STRING[baseDefense]) "..
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

---Creates and a detailed help message for a unit
---If applicable, the player will be given a choice to look
---at terrain help, or to look at the menu for other units
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


    local statTable = {[1]={},[2]={},[3]={}}
    statTable[1][1] = "Hit Points:"
    statTable[1][2] = tostring(unit.hitpoints).."/"..tostring(hitpoints)
    statTable[1][3] = "Move Points:"
    statTable[1][4] = tostring(moveRemaining).."/"..tostring(maxMoves)
    statTable[2][1] = "Attack:"
    statTable[2][2] = tostring(adjustedAttack).."("..tostring(attack)..")"
    statTable[2][3] = "Defense:"
    statTable[2][4] = tostring(adjustedDefense).."("..tostring(defense)..")"
    statTable[3][1] = "Atk FP:"
    statTable[3][2] = tostring(adjustedFirepowerAttack).."("..tostring(firepower)..")"
    statTable[3][3] = "Def FP:"
    statTable[3][4] = tostring(adjustedFirepowerDefense).."("..tostring(firepower)..")"
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
        statTable[4] = {}
        statTable[4][1] = "Bonuses:"
        statTable[4][2] = moveMultTranslate(moveMultipliers.railroad, "Rail")
        if gen.isAlpine(unit.type) then
            statTable[4][3] = moveMultTranslate(moveMultipliers.alpine, "Alpine")
        else
            statTable[4][3] = moveMultTranslate(moveMultipliers.road, "Road")
        end
        statTable[4][4] = moveMultTranslate(moveMultipliers.river, "River")
    end
    local rank = leaderBonus.getRank(unit)
    local commanderRank = leaderBonus.getCommanderRank(unit)
    local helpString = ""
    helpString = helpString..text.simpleTabTableToText(statTable,4)
    helpString = helpString.."\n"
    if rank then
        helpString = helpString.."^Leader Class: "..rank.."\n"
    elseif commanderRank then
        helpString = helpString.."^Commander: "..commanderRank.."\n"
    end
    for i = 1,#unitStats.activeBonusMessages do
        helpString = helpString.."^"..unitStats.activeBonusMessages[i].."\n"
    end
    for i = 1,#unitStats.inactiveBonusMessages do
        helpString = helpString.."^"..unitStats.inactiveBonusMessages[i].."\n"
    end
    local choices = {
        [1] = "Stack Help Menu",
        [2] = "Terrain Help",
        [4] = "Close",
    }
    if moveRemaining > 0 then
        choices[3] = "Activate this "..unit.type.name
    end
    local choice = text.menu(choices,helpString,"Help for "..unit.type.name)
    if choice == 1 then
        return help.tileHelpMenu(unit.location)
    end
    if choice == 2 then
        return help.terrainHelp(unit.location)
    end
    if choice == 3 then
        return unit:activate()
    end
    if choice == 4 then
        return
    end
end

---Produces a help menu for a tile, giving each unit on the
---tile as a choice, as well as the terrain help.
---The list tooltip is used to provide a one line description
---of the unit's status
---@param tile tileObject
function help.tileHelpMenu(tile)
    local player = civ.getPlayerTribe()
    if not gen.isTileRevealed(tile,player) then
        return help.terrainHelp(tile)
    end
    if tile.defender == nil then
        return help.terrainHelp(tile)
    end
    if tile.defender ~= player then
        -- do something tbd
        return
    end
    local unitList = {}
    local offset = 3
    local unitCount = 0
    local menuTable = {}
    menuTable[1] = "Close"
    menuTable[2] = "Help for "..tile.terrain.name.."."
    for unit in tile.units do
        unitCount = unitCount + 1 + offset
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
    end



    local menuTable = {}
    if tile.defender then
        menuTable[1] = "Stack Help Menu"
    end
    menuTable[2] = "Close"
    if not gen.isTileRevealed(tile,player) then
        helpString = "^No help available for unrevealed tiles.\n"
    end
    local helpTitle = "Help for "..tile.terrain.name
    if not gen.isTileRevealed(tile,player) then
        helpTitle = "Help for Unknown Tile"
        menuTable[1] = nil
    end
    local choice = text.menu(menuTable,helpString,helpTitle)
    if choice == 1 then
        return help.tileHelpMenu(tile)
    end
    if choice == 2 then
        return
    end
end










discreteEvents.onKeyPress(function (key)
    if key == keyboard.backspace then
        if civ.getActiveUnit() then
            help.unitHelp(civ.getActiveUnit())
        else
            help.tileHelpMenu(civ.getCurrentTile())
        end
        --if not civ.getActiveUnit() then
        --    return
        --end
        --local unit = civ.getActiveUnit()
        --help.unitHelp(unit)
    end
end)


return help