-- This file can be deleted if it is not being used.

local register = {}

---&autoDoc onCityProcessingComplete
function register.onCityProcessingComplete(turn,tribe)
    --civ.ui.text('after production separate file')
    if _global.eventTesting then
        civ.ui.text("onCityProcessingComplete for turn "..turn.." and tribe "..tribe.name.." separate file")
    end

end
---&endAutoDoc

return register
