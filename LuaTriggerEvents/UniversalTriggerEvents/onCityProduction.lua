
local consolidated = require("consolidatedEvents")
local cityProduction = {}
function cityProduction.onCityProduction(city,prod)
    consolidated.onCityProduction(city,prod)
end

return cityProduction
