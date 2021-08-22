
local consolidated = require("consolidatedEvents")
local cityFounded = {}
function cityFounded.onCityFounded(city)
    consolidated.onCityFounded(city)

end

return cityFounded
