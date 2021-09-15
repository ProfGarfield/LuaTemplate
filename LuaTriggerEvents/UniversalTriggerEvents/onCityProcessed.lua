
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local cityProcessed = {}
function cityProcessed.onCityProcessed(city)
    consolidated.onCityProcessed(city)
    discreteEvents.performOnCityProcessed(city)

end

return cityProcessed
