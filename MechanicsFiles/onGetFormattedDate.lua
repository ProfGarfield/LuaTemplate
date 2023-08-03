-- this file can be deleted if it is not necessary
--
--
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--


local register = {}

--[[
local leaderBonus = require("leaderBonus")
function register.onGetFormattedDate(turn,defaultDateString)
    if civ.getCurrentTribe().isHuman and civ.getActiveUnit() and not civ.getOpenCity() then
        local activeUnit = civ.getActiveUnit()
        local rank = leaderBonus.getRank(activeUnit)
        if rank then
            return "Rank: "..rank
        elseif leaderBonus.getCommanderRank(activeUnit) then
            return "Ldr: "..leaderBonus.getCommanderRank(activeUnit)
        else
            return "No Leader"
        end
    else
        return defaultDateString
    end
    return defaultDateString
end
--]]

--Registers a function that is called when the game needs to get the date string for a given turn (e.g. "4000 B.C." for turn 1). `turn` is the turn for which the date is requested (not always the current turn), and `defaultDateString` is the string as formatted by the game
---&autoDoc onGetFormattedDate
function register.onGetFormattedDate(turn,defaultDateString)
    if _global.eventTesting then
        --print(turn,civ.getTurn())
        return "Testing Turn "..turn
    end
    return defaultDateString
end
---&endAutoDoc
--]]

local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(register,versionNumber,fileModified,"MechanicsFiles".."\\".."onGetFormattedDate.lua")
return register
