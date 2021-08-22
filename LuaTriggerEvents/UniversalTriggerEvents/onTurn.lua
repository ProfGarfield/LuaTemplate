
local consolidated = require("consolidatedEvents")
local onTurn = {}
function onTurn.onTurn(turn)
    consolidated.onTurn(turn)

end

return onTurn
