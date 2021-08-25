
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local cityFounded = {}
function cityFounded.onCityFounded(city)
    consolidated.onCityFounded(city)
    discreteEvents.performOnCityFounded(city)

end

return cityFounded
