-- this file can be deleted if it is not being used

local register = {}

---&autoDoc onCityWindowOpened
---Add any events to happen when a city window is opened.
---(Note that the AI doesn't open city windows.)
---@param city cityObject The city that is being examined.
function register.onCityWindowOpened(city)
    if _global.eventTesting then
        civ.ui.text("eventsFiles\\onCityWindowOpened.lua: onCityWindowOpened called with city: "..city.name)
    end
end
---&endAutoDoc

return register