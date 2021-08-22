
local consolidated = require("consolidatedEvents")
local cityTaken = {}
function cityTaken.onCityTaken(city,defender)
    consolidated.onCityTaken(city,defender)

end

return cityTaken
