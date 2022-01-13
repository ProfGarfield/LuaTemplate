
-- this file can be deleted if it is not being used
local register = {}

function register.onTribeTurnBegin(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("onTribeTurnBegin for turn "..turn.." and tribe "..tribe.name.." separate file")
    end
end

return register
