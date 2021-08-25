
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local cityTaken = {}
function cityTaken.onCityTaken(city,defender)
    consolidated.onCityTaken(city,defender)
    discreteEvents.performOnCityTaken(city,defender)

end

return cityTaken
