
local consolidated = require("consolidatedEvents")
local cityDestroyed = {}
function cityDestroyed.onCityDestroyed(city)
    consolidated.onCityDestroyed(city)

end

return cityDestroyed
