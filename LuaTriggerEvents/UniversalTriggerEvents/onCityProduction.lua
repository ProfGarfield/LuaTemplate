
local discreteEvents = require("discreteEventsRegistrar")
local consolidated = require("consolidatedEvents")
local cityProduction = {}
function cityProduction.onCityProduction(city,prod)
    consolidated.onCityProduction(city,prod)
    discreteEvents.performOnCityProduction(city,prod)

end

return cityProduction
