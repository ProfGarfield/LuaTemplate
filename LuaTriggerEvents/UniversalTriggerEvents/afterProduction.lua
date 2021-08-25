
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local afterProdEvents = {}

function afterProdEvents.afterProduction(turn,tribe)
    consolidated.afterProduction(turn,tribe)
    discreteEvents.performAfterProduction(turn,tribe)
   -- civ.ui.text("After Production for turn "..tostring(turn).." and tribe "..tribe.name)

end
return afterProdEvents
