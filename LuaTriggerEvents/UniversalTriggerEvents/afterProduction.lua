
local consolidated = require("consolidatedEvents")
local afterProdEvents = {}

function afterProdEvents.afterProduction(turn,tribe)
    consolidated.afterProduction(turn,tribe)
   -- civ.ui.text("After Production for turn "..tostring(turn).." and tribe "..tribe.name)

end
return afterProdEvents
