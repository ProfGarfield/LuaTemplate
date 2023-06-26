-- This file can be deleted from the template if it is not needed
local onTurn = {}
---&autoDoc onTurn
function onTurn.onTurn(turn)
    if _global.eventTesting then
        civ.ui.text("on turn test separate file")
    end
end
---&endAutoDoc

return onTurn
