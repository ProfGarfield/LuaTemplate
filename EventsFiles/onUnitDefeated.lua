-- This file can be deleted if it is not used.
local onUnitDefeated = {}

-- This will run any time a unit is killed, either in combat or by events
function onUnitDefeated.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    --civ.ui.text(loser.type.name.." defeated (possibly in an event rather than combat) by "..winner.type.name.." separate file test")

end

return onUnitDefeated
