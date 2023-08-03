-- This file can be deleted if it is not used.
local register = {}

---&autoDoc onActivateUnit
--Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving, `false` otherwise.
--If the function returns true, the unit activation will be cancelled.
--No further activation code will be executed, and the unit's type
--will temporarily be set to have 0 movement points.
--If the function returns function(unit), then the unit activation
--will be cancelled, and the function returned will be executed
--just before another unit is activated.  (You may wish to put
--the unit to sleep, for example.)
--Not returning anything is equivalent to returning nil, which is
--acceptable, and keeps the unit activation going.
function register.onActivateUnit(unit,source,repeatMove)
    --civ.ui.text("unit activation separate file")

end
---&endAutoDoc

return register
