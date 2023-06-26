-- this file can be deleted if it is not necessary
local register = {}

---&autoDoc onCityFounded
function register.onCityFounded(city)
    if _global.eventTesting then
        civ.ui.text("separate file onCityFounded for "..city.name)
    end
    -- the cityCancelled() function is executed if the player
    -- decides not to found the city after all
    -- (so you can undo terrain changes, etc.
    local function cityCancelled()
        if _global.eventTesting then
            civ.ui.text("separate file onCityFounded city cancelled for "..city.name)
        end
    end
    return cityCancelled
end
---&endAutoDoc

return register
