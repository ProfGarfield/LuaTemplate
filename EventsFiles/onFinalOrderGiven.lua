-- This file can be deleted if it is not used.
local register = {}

---&autoDoc onFinalOrderGiven
function register.onFinalOrderGiven(unit)
    if _global.eventTesting then
        civ.ui.text("onFinalOrderGiven.onFinalOrderGiven: "..unit.type.name.." has been given its order.")
    end
    civ.ui.text(unit.type.name.." ("..tostring(unit.id)..") has received its last order")
end
---&endAutoDoc

return register
