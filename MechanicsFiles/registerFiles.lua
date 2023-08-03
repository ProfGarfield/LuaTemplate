
local versionNumber = 6
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


--      You can register combat modification rules in any file.
--      This file simply provides some examples and the documentation.
--

--      This file serves as a place to require other files, to make sure they are run
--      This is necessary if files have effects without actually returning useful stuff
--

--          Lua Scenario Template Files


-- All necessary file require calls were moved to events.lua
-- during the last update of that file.





--          Files For This Scenario






--      Footer

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(2)

local register = {}
gen.versionFunctions(register,versionNumber,fileModified,"MechanicsFiles".."\\".."registerFiles.lua")
gen.minEventsLuaVersion(7,1,"registerFiles.lua")
return register
