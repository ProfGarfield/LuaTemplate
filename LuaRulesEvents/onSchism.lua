local legacy = require("legacyEventEngine")
local onSchism = {}

function onSchism.onSchism(tribe)
    return legacy.doNoSchismEvents(tribe)
end

return onSchism
