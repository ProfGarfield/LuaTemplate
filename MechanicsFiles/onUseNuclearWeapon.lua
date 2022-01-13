-- this file can be deleted if it is not necessary
-- nuclear weapons will behave normally then
-- Note that the events.lua file runs the unit killed
-- events for all units in the nuke's blast radius
-- after this function returns
-- You will have to change that file if you don't want
-- that to happen
--
local register = {}



-- onUseNuclearWeapon does not trigger if the attack
-- is thwarted by SDI or if the spy is captured before
-- completing the mission
function register.onUseNuclearWeapon(unit,tile)
    if _global.eventTesting then
        civ.ui.text("onUseNuclearWeapon.onUseNuclearWeapon for "..unit.type.name.." on tile "..tostring(tile))
    end

    -- return true if the nuke should proceed as normal
    -- return false if you want to stop the attempt
    -- the nuke/spy will disappear
    -- if spy, spy neither escapes nor is caught red handed
    return true
end

return register
