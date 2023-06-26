-- this file can be deleted if it is unnecessary

local register = {}


---&autoDoc onCanFoundCity
-- Checking if a unit can found a city
-- Return true if the unit can found a city
-- return false if it can't
-- If any one of the consolidated event, the discrete events, 
-- or the separate file event return false, then the city
-- can't be built
-- Notes: Returning true does NOT override any normal city
-- building condition (like no adjacent cities, or cities at sea)
-- Registers a function that is called to determine if `unit` can found 
-- a city at the unit's location. `advancedTribe` is `true` when picking 
-- up a hut with `unit` triggers an advanced tribe. 
-- Return `true` to allow, `false` to disallow.

function register.onCanFoundCity(unit,advancedTribe)
    if _global.eventTesting then
        civ.ui.text("separate file onCanFoundCity for "..unit.type.name)
    end
    return true
end
---&endAutoDoc

return register
