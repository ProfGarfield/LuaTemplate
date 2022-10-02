
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local helpKey = require("helpkey")
local gen = require("generalLibrary"):minVersion(1)




-- Text for each flag a unit type might have
local flagText = {
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

-- unitTypeText[unitType.id] = text string
-- gives text to display for each unit type
-- nil means display no text for that unit type
local unitTypeText = {

}



-- displays text based on each individual unit
local function unitTextFunction(unit)
    local unitHPofMax = tostring(unit.hitpoints).." of "..tostring(unit.type.hitpoints).." Hit Points remaining."
    local nearestCity = nil
    local distanceToCity = 1000
    for city in civ.iterateCities() do
        if city.owner == unit.owner and city.location.z == unit.location.z then
            if gen.distance(city,unit) <distanceToCity then
                nearestCity = city
                distanceToCity = gen.distance(city,unit)
            end
        end
    end
    local nearestCityText = "No friendly city found on this map."
    if nearestCity then
        nearestCityText = "Nearest city is "..nearestCity.name.." at a distance of "..tostring(distanceToCity).."."
    end
    return unitHPofMax.."  "..nearestCityText

end



local function doHelpKey()
    -- original help key concept checked the keyID with a specified
    -- key id number; here, we set the values equal, and rely on the check
    -- to happen elsewhere.  Hence, 212, 212 as the first two entries.
    helpKey.helpKey(212,212,flagText,unitTypeText,unitTextFunction)
end

local helpKeySettings = {doHelpKey = doHelpKey}
gen.versionFunctions(helpKeySettings,versionNumber,fileModified,"MechanicsFiles".."\\".."helpKeySettings.lua")

return helpKeySettings
