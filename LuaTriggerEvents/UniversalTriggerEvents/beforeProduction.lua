local gen = require("generalLibrary")
local object = require("object")
local flag = require("flag")
local counter = require("counter")
local consolidated = require("consolidatedEvents")

local beforeProduction = {}


-- If you want different tribes to gather different amounts of
-- resources from the terrain, you can use this event to make
-- the change.  However, you may wish to make the changes in the
-- calculateCityYield event instead, since having the event
-- here will result in foreign civs appearing to have incorrect
-- production values if you investigate the city with a diplomat
-- (or look at the city in cheat mode)
function beforeProduction.beforeProduction(turn,tribe)
    consolidated.beforeProduction(turn,tribe)

end

return beforeProduction
