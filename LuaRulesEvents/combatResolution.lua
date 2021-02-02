
local object = require("object")
local combatResolution = {}


-- This will be computed on the first round of combat.  
--
-- If false is returned,
-- combat will not take place, and a unit will be killed (set a unit's hp to 0 to ensure
-- that unit is the one that is killed).
--
-- If true is returned, the result of combatResolution.everyRound will determine
-- whether combat takes place
--
-- If you want a unit to automatically win combat against another unit, for example,
-- set the desired loser's hitpoints to 0 and return false.
function combatResolution.firstRound(defaultResolutionFunction,defender,attacker)
    return true
end 

-- These actions will be taken every round of combat.
--
-- If false is returned,
-- combat will not take place, and a unit will be killed (set a unit's hp to 0 to ensure
-- that unit is the one that is killed).

function combatResolution.everyRound(defaultResolutionFunction,defender,attacker)

    return defaultResolutionFunction(defender,attacker)
end

return combatResolution
