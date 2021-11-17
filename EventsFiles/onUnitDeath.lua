-- this file can be deleted if it is not being used.
local onUnitDeath = {}

-- this happens whenever a unit 'dies', regardless of combat, as long as it is not replaced
function onUnitDeath.onUnitDeath(dyingUnit)
    --civ.ui.text(dyingUnit.type.name.." died separate file test")

end

-- this happens whenever a unit 'dies', but not through combat (or 'defeat')
function onUnitDeath.onUnitDeathOutsideCombat(dyingUnit)
    --civ.ui.text(dyingUnit.type.name.." died outside combat separate file test")

end
-- this happens if a unit is deleted (either through combat death, or by some other event,
-- but not if the unit is disbanded)
-- If the unit isn't being replaced, replacingUnit is nil
function onUnitDeath.onUnitDeleted(deletedUnit,replacingUnit)
    --civ.ui.text(deletedUnit.type.name.." deleted and replaced by "..tostring(replacingUnit).." separate file")

end

return onUnitDeath
