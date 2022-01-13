-- This file can be deleted if it is not being used.
-- Deprecated! Use onCityProcessingComplete.lua instead
local onAfterProduction = {}

function onAfterProduction.onAfterProduction(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("onAfterProduction for turn "..turn.." and tribe "..tribe.name.." separate file")
    end

end

return onAfterProduction
