-- this file can be deleted if it is not being used

local register = {}


---&autoDoc onUseNuclearWeapon
---Add any events to happen with a nuclear strike, or  
---return false to abort the strike.  Events.lua already
---kills (and performs related events) for units in the
---blast radius 
---@param unit unitObject The weapon (or spy) that is making the nuclear attack.
---@param tile tileObject The location of the attack.
---@return boolean If true, attack proceeds, if false, it is aborted.
function register.onUseNuclearWeapon(unit,tile)

    local proceedWithAttack = true
    return proceedWithAttack
end
---&endAutoDoc

return register