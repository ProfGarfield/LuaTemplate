
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local cityDestroyed = {}
function cityDestroyed.onCityDestroyed(city)
    consolidated.onCityDestroyed(city)
    discreteEvents.performOnCityDestroyed(city)

end

return cityDestroyed
