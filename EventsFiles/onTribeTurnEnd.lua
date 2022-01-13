
-- this file can be deleted if it is not being used
local register = {}

function register.onTribeTurnEnd(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("onTribeTurnEnd for turn "..turn.." and tribe "..tribe.name.." separate file")
    end
end

return register
