local object = require("object")
local gen = require("generalLibrary")
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
require("discreteEvents")

local unitActivation = {}
function unitActivation.activateFunction(unit,source)
    consolidated.onActivateUnit(unit,source)
    discreteEvents.performOnActivateUnit(unit,source)


end

return unitActivation
