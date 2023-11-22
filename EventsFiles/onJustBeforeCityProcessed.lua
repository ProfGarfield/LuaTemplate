
-- this file can be deleted if it is not being used
local register = {}

---&autoDoc onJustBeforeCityProcessed
function register.onJustBeforeCityProcessed(city)
    if _global.eventTesting then
        civ.ui.text("just before city processed separate file")
    end
end
---&endAutoDoc

return register