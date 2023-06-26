-- This file can be deleted if it is not necessary.
--

-- This function is only run when a unit is killed in standard civ ii combat.  If you need an effect to happen even if a unit is 'defeated' by another unit in an event, use onUnitDefeated.lua

local onUnitKilled = {}

---&autoDoc onUnitKilled
-- This will only run when a unit is killed in combat (i.e. not when an event
-- 'kills' a unit)
-- note that if the aggressor loses, aggressor.location will not work
-- note: use loserLocation instead of loser.location, since loser.location doesn't work if the attacker loses
-- (the game returns a 'tile' off the map)
function onUnitKilled.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    if _global.eventTesting then
        civ.ui.text(loser.type.name.." killed by "..winner.type.name.." separate file test killed in combat.")
    end

end
---&endAutoDoc

return onUnitKilled
