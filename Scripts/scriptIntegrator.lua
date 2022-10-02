-- This file provides access to scripts (usually from the Scripts directory)
-- through the use of Ctrl+Shift+F4
-- These are robust to not having the script available

--local rules = require("rules")
local gen = require("generalLibrary")
local keyboard = require("keyboard")
local discreteEvents = require("discreteEventsRegistrar")
local text = require("text")


local function dofileIfAvailable(fileName)
    for _,searcher in ipairs(package.searchers) do
        local loader = searcher(fileName)
        if type(loader) == 'function' then
            loader()
            return true 
        end
    end
    return false, nil
end

function discreteEvents.onKeyPress(keyID)
    if keyID ~= keyboard.ctrl.shift.F4 then
        return
    end
    local menuTable = {}
    menuTable[1] = "Generate rules_lst.txt"
    menuTable[2] = "Generate object.lua"
    menuTable[3] = "Generate object.js"
    menuTable[4] = "Generate setTraits.lua"
    menuTable[5] = "Start the Polygon Script"
    menuTable[6] = "Build describe.txt"
    menuTable[7] = "Build the sample dscribe.txt from samplePedia.lua"
    menuTable[8] = "Run update helper."
    local menuText = "Choose a script to run."
    local menuTitle = "Scripts"
    local choice = text.menu(menuTable,menuText,menuTitle,true)
    if choice == 0 then
        return
    elseif choice == 1 then
        local found,rules = gen.requireIfAvailable("rules")
        if found then
            rules.generateRulesLST()
        else
            text.simple("rules.lua not found.  File not generated")
        end
        return
    elseif choice == 2 then
        local found,rules = dofileIfAvailable("Scripts\\makeObject")
        if found then
            -- nothing needs to be done, since this runs the script
        else
            text.simple("Scripts\\makeObject.lua not found.  File not generated")
        end
        return
    elseif choice == 3 then
        local found,rules = dofileIfAvailable("Scripts\\makeObjectJS")
        if found then
            -- nothing needs to be done, since this runs the script
        else
            text.simple("Scripts\\makeObjectJS.lua not found.  File not generated")
        end
        return
    elseif choice == 4 then
        local found,rules = dofileIfAvailable("Scripts\\makeSetTraits")
        if found then
            -- nothing needs to be done, since this runs the script
        else
            text.simple("Scripts\\makeSetTraits.lua not found.  File not generated")
        end
        return
    elseif choice == 5 then
        local found,rules = dofileIfAvailable("Scripts\\PolygonScript")
        if found then
            -- nothing needs to be done, since this runs the script
        else
            text.simple("Scripts\\PolygonScript.lua not found.")
        end
        return
    elseif choice == 6 then
        local found,pedia = gen.requireIfAvailable("civilopedia")
        if found then
            pedia.makeDescribeTxt()
        else
            text.simple("civilopedia.lua not found.  File not generated")
        end
        return
    elseif choice == 7 then
        local found,rules = dofileIfAvailable("samplePedia")
        if found then
            -- nothing needs to be done, since this runs the script
        else
            text.simple("samplePedia.lua not found.  File not generated")
        end
        return
    elseif choice == 8 then
        local found, _ = dofileIfAvailable("Scripts\\updateInfo")
        if found then

        else
            text.simple("updateInfo.lua not found.  No update help.")
        end
        return
    else
        text.simple("Invalid choice.  This shouldn't be possible, so please report this to Prof. Garfield in the Civfanatics Forums.")
        return
    end



end

return {}
