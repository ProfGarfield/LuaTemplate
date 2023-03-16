
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



-- This file is meant to group scenario parameters, so that there is a single
-- place where important values are recorded.  It is recommended that you define
-- a parameter value in one place and always refer to that place, so that if
-- you decide to make a change, only one value has to be changed instead of
-- searching for every possible place that value is relevant.

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
local text = require("text")
--local eventTools = require("eventTools")
---@module "discreteEvents"
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)

text.setMoney("%STRING1 gold")
-- text.setMoney("$%STRING1,000")
-- text.setMoneu("%STRING1 Pounds", "%STRING1 Pound")
-- used to determine how text.money(amount)--> string
-- will work
-- if second argument is supplied, that is used when the amount is 1

text.setDigitGroupSeparator(",")
-- text.setDigitGroupSeparator("")
-- text.setDigitGroupSeparator(".")
-- used to determine how text.groupDigits(integer)-->string
-- will work

text.setVeteranTitle("Veteran")
-- sets the string that is returned by text.getVeteranTitle()
--

text.setShortVeteranTitle("Vet")
-- sets the string that is returned by text.getShortVeteranTitle()

--[[ This eventTools functionality has been replaced by the activateUnitBackstop
--      in events.lua that was made available by onGetFormatted date
--      and by the civ.scen.onCityProcessingComplete
--      This code hasn't been removed yet, just in case something breaks and 
--      eventTools still needed

-- The event tools have functionality to guarantee that a tribe
-- will have an active unit.  This ensures that after production
-- events and promotions to new unit types work properly
-- (and, maybe, other stuff too).
-- The unit that is guaranteeing unit activation will be deleted
-- as soon as it is activated.
-- Make sure to choose a unit type that has more than 0 movement points
-- Also, change activationLocations below
--
eventTools.setGuaranteeUnitActivationType(nil)
-- these locations are used for creating units that will
-- guarantee unit activation
-- If possible, choose an out of the way area of the map
-- if none is available, you'll have to write a function
-- to find a place
local activationLocations = {
[0] = civ.getTile(0,0,0) ,
[1] = civ.getTile(0,0,0),
[2] = civ.getTile(0,0,0),
[3] = civ.getTile(0,0,0),
[4] = civ.getTile(0,0,0),
[5] = civ.getTile(0,0,0),
[6] = civ.getTile(0,0,0),
[7] = civ.getTile(0,0,0),
}
local function activationLocationFunction(tribe)
    return activationLocations[tribe.id]
end
eventTools.setGuaranteeActivationUnitLocationFunction(activationLocationFunction)

-- This is the end of the eventTools code for this file
--]]


function discreteEvents.onScenarioLoaded()
    civ.scen.compatibility.activateUnitEveryMove = true
end


-- This function registers what happens when Lua code causes a
-- unit to be destroyed because it is 'out of range/fuel'.  This could be
-- because events expended the last movement points of an aircraft,
-- or because land/sea units have been given a range using Lua.  
-- (No code is run when the standard game detects an aircraft to be
-- out of range)<br><br>
-- If `textOrFunction` is a string, the text is shown when a unit is 
-- lost due to being out of range, with %STRING1 substitutes for the unit type's name.  `title` provides the title for the box.
--
-- If `textOrFunction` is a `function(unit) -> void`, the
-- function is exectued, and is trusted to generate the 
-- the function is trusted to generate a suitable message.
--gen.setOutOfRangeMessage(textOrFunction,title)
local message = 
[[Your aircraft has run out of fuel.
Fighter and Missile units must return to
a city or Carrier at the end of each
turn.  Bomber units must return at the end
of their second turn.]]
gen.setOutOfRangeMessage(message,"Civ Rules: Fuel")


local param = {}

gen.versionFunctions(param,versionNumber,fileModified,"LuaParameterFiles".."\\".."parameters.lua")


return param
