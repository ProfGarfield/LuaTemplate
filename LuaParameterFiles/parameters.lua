
-- This file is meant to group scenario parameters, so that there is a single
-- place where important values are recorded.  It is recommended that you define
-- a parameter value in one place and always refer to that place, so that if
-- you decide to make a change, only one value has to be changed instead of
-- searching for every possible place that value is relevant.

local gen = require("generalLibrary")
local text = require("text")
local eventTools = require("eventTools")
local discreteEvents = require("discreteEventsRegistrar")

text.setMoney("%STRING1 gold")
-- text.setMoney("$%STRING1,000")
-- used to determine how text.money(amount)--> string
-- will work

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


function discreteEvents.onScenarioLoaded()
    civ.scen.compatibility.activateUnitEveryMove = true
end


-- use this function to set a unit out of range message for
-- units that run out of range due to events.
-- gen.setOutOfRangeMessage(textOrFunction,title=nil) --> void
-- if textOrFunction is a string, the text is shown when a unit is 
-- lost due to being out of range, and title is the box title
-- (if this is governed by events and not standard movement)
-- %STRING1 substitutes for the unit type's name
--
-- if textOrFunction is a function(unit) --> void
-- the function is trusted to generate the loss of fuel message
-- The default message is the standard out of range message



local param = {}



return param
