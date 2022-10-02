-- this file can be removed without breaking the events (though a warning will be printed to the console)
--
--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--

local register = {}



--Registers a function that is called when calculating 
--the cost to rush-buy a city's current production.
--It takes the city and the cost as calculated by the
--game as parameters. Returns an integer representing the new costs.
function register.onGetRushBuyCost(city,cost)
    return cost
end

local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(register,versionNumber,fileModified,"MechanicsFiles".."\\".."rushBuySettings.lua")


return register
