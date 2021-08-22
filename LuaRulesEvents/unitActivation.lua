local object = require("object")
local gen = require("generalLibrary")
local consolidated = require("consolidatedEvents")

local unitActivation = {}
function unitActivation.activateFunction(unit,source)
    consolidated.onActivateUnit(unit,source)


end

return unitActivation
