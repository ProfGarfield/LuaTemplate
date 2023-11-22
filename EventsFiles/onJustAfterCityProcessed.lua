
-- this file can be deleted if it is not being used
local register = {}

---&autoDoc onJustAfterCityProcessed
function register.onJustAfterCityProcessed(city)
    if _global.eventTesting then
        civ.ui.text("just after city processed separate file")
    end
end
---&endAutoDoc

return register