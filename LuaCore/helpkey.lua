
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local func = require "functions"
local text = require "text"

-- insert help = require "helpkey"


-- If a unit is active and keyID matches helpKeyNumber, then a dialog box displaying
-- help information is created.  This only works for active units, since otherwise it
-- could be used to check any tile for an enemy unit (additional TOTPP Lua functionality
-- could allow for visible enemy units to be checked)

-- flagTextTable is a table of strings to be displayed if the unittype has that particular flag
-- unitTypeTextTable is a table of strings to be displayed that give extra information about the
--   unit if the creator specifies it.
-- unitTextFunction function(unit)--> string
--   takes the specific unit and returns a string giving extra information/help.  E.g. a flying
--   unit could return the distance to the nearest city, the unit's remaining hp, etc.

local defaultFlagTextTable = {
[1] = "Two space visibility",
[2] = "Ignore zones of control",
[3] = "Can make amphibious assaults",
[4] = "Submarine advantages/disadvantages",
[5]= "Can attack air units (fighter)",
[6]= "Ship must stay near land (trireme)",
[7]= "Negates city walls (howitzer)",
[8]= "Can carry air units (carrier)",
[9]= "Can make paradrops",
[10]= "Alpine (treats all squares as road)",
[11]= "x2 on defense versus horse (pikemen)",
[12]= "Free support for fundamentalism (fanatics)",
[13]= "Destroyed after attacking (missiles)",
[14]= "x2 on defense versus air (AEGIS)",
[15]= "Unit can spot submarines",}

local function helpKey(keyID, helpKeyNumber,flagTextTable, unitTypeTextTable,unitTextFunction)
    if keyID == helpKeyNumber and civ.getActiveUnit() then
        local helpUnit = civ.getActiveUnit()
        local helpUnitType = helpUnit.type
        local helpWindow = civ.ui.createDialog()
        local roleText = ""
        if helpUnitType.domain == 1 then
            roleText = " Range: "..tostring(helpUnitType.range)
        elseif helpUnitType.domain == 2 then
            roleText = " Carry: "..tostring(helpUnitType.hold)
        end
        local windowText = ""
        helpWindow.title = "Help for "..helpUnitType.name
        helpWindow:addText(func.splitlines("Attack Value: "..tostring(helpUnitType.attack).."      Firepower: "..tostring(helpUnitType.firepower)))
        helpWindow:addText(func.splitlines("\n^".."Defense Value: "..tostring(helpUnitType.defense).."    Hit Points: "..tostring(helpUnitType.hitpoints)))
        helpWindow:addText(func.splitlines("\n^".."Movement Rate: "..tostring(math.floor(helpUnitType.move/totpp.movementMultipliers.aggregate))..roleText))
        for i=1,15 do
            if helpUnitType.flags & 2^(i-1) == 2^(i-1) then
                if flagTextTable[i] then
                    helpWindow:addText(func.splitlines("\n^"..flagTextTable[i]))
                else
                    helpWindow:addText(func.splitlines("\n^"..defaultFlagTextTable[i]))
                end
            end
        end -- end for i=1:15
        if unitTypeTextTable[helpUnitType.id] then
            helpWindow:addText(func.splitlines("\n^"..unitTypeTextTable[helpUnitType.id]))
        end
        if unitTextFunction and unitTextFunction(helpUnit) then
            text.addMultiLineTextToDialog("\n^"..unitTextFunction(helpUnit),helpWindow)
        end 
        helpWindow:show()
    end -- if keyID == helpKeyNumber
    
end -- helpKey(keyID, helpKeyNumber,...

-- Distance for flat map, ignore elevation distance between maps.
local function flatDistance(tile1,tile2)
    return math.ceil((math.abs(tile1.x-tile2.x)+math.abs(tile1.y-tile2.y))/2)
end -- flatDistance


local function defaultUnitTextFunction(unit)
    local unitHPofMax = tostring(unit.hitpoints).." of "..tostring(unit.type.hitpoints).." Hit Points remaining."
    local nearestCity = nil
    local distanceToCity = 1000
    for city in civ.iterateCities() do
        if city.owner == unit.owner and city.location.z == unit.location.z then
            if flatDistance(unit.location,city.location) <distanceToCity then
                nearestCity = city
                distanceToCity = flatDistance(unit.location,city.location)
            end
        end
    end
    local nearestCityText = "No friendly city found on this map."
    if nearestCity then
        nearestCityText = "Nearest city is "..nearestCity.name.." at a distance of "..tostring(distanceToCity).."."
    end
    return unitHPofMax.."  "..nearestCityText
end -- defaultUnitTextFunction


local gen = require("generalLibrary"):minVersion(1)

local helpRegister = {helpKey = helpKey,
        defaultUnitTextFunction = defaultUnitTextFunction,
}
gen.versionFunctions(helpRegister,versionNumber,fileModified,"LuaCore".."\\".."helpkey.lua")
return helpRegister
