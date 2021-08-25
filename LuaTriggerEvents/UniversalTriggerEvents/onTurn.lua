
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local onTurn = {}
function onTurn.onTurn(turn)
    consolidated.onTurn(turn)
    discreteEvents.performOnTurn(turn)

end

return onTurn
