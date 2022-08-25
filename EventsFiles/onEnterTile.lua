-- This file can be deleted if it is not used.
local register = {}
local text = require("text")
local gen = require("generalLibrary")
-- onEnterTile(unit,previousTile)
-- executes when a unit successfully enters a tile (so not when it attacks
-- a unit or fails to enter a tile because it lacks movement points)
function register.onEnterTile(unit,previousTile)
    if _global.eventTesting then
        civ.ui.text("onEnterTile.onEnterTile: "..unit.type.name.." has entered tile ("..text.coordinates(unit.location)..") from tile ("..text.coordinates(previousTile)..").")
    end
    --if gen.isParadrop(unit.type) and not unit.location.city then
    --    unit:teleport(previousTile)
    --    gen.clearParadropped(unit)
    --end
    --gen.original.uParatroopers.hold = 1
    --gen.original.uParatroopers.domain = 2

end

return register
