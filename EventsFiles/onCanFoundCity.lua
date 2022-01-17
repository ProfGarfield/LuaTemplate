-- this file can be deleted if it is unnecessary

local register = {}


-- Checking if a unit can found a city
-- Return true if the unit can found a city
-- return false if it can't
-- If any one of the consolidated event, the discrete events, 
-- or the separate file event return false, then the city
-- can't be built
-- Notes: Returning true does NOT override any normal city
-- building condition (like no adjacent cities, or cities at sea)
-- This event is not called for advanced tribes (as of TOTPPv18.1),
-- so it can't prevent them.  Setting that tile's fertility to 0
-- will prevent it (and stop the AI from settling that tile also)

function register.onCanFoundCity(unit)
    if _global.eventTesting then
        civ.ui.text("separate file onCanFoundCity for "..unit.type.name)
    end
    return true
end

return register
