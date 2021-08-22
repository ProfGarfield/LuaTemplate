
local consolidated = require("consolidatedEvents")
local bribeUnitEvents = {}


function bribeUnitEvents.onBribeUnit(unit,previousOwner)
    consolidated.onBribeUnit(unit,previousOwner)

end
return bribeUnitEvents
