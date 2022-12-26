local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

--      Leader Bonuses and Tracking
--
--      This module keeps track of "leader" units and the units that are under the
--      command of a leader (receiving a leadership bonus).
--      This module also provides automatic combat bonuses using combatModifiers
--
--







local gen = require("generalLibrary"):minVersion(1)
local traits = require("traits"):minVersion(1)
local combatMod = require("combatModifiers"):minVersion(1)
local unitData = require("unitData"):minVersion(1)

local leaderBonus = {}
gen.versionFunctions(leaderBonus,versionNumber,fileModified,"LuaCore".."\\".."leaderBonus.lua")


return leaderBonus
