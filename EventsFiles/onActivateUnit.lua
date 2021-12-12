-- This file can be deleted if it is not used.
local register = {}
--Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving, `false` otherwise.
function register.onActivateUnit(unit,source,repeatMove)
    --civ.ui.text("unit activation separate file")

end

return register
