-- this file can be deleted if it is not being used
-- Deprecated! use onTribeTurnBegin.lua instead
local register = {}

---&autoDoc onBeforeProduction
function register.onBeforeProduction(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("onBeforeProduction for turn "..turn.." and tribe "..tribe.name.." separate file")
    end

end
---&endAutoDoc

return register
