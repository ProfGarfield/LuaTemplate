
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


--[[
            Land and Air Transport Cargo Settings
            =====================================
This file allows you to set up Land and Air units to carry other units.
These abilities only apply to human players.  The AI can't use them.

If a transport unit can carry cargo, it will carry with it any sleeping 
units that are on the same tile (up to the transport's capacity), as long
as the units can be carried by the transport, and can be loaded onto the
transport unit on that tile.

When a player opens a city screen, all units in that city are unloaded from
any transport units that might be carrying them.  This also happens at the 
end of the player's turn.

--]]



local object = require("object")
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
local cargo = require("landAirCargo")


-- You can register the default load and unload parameters for
-- land and air cargo.  These are used if the cargo unit does not
-- have a cargoSpec, or if the cargoSpec has a nil load or unload
-- parameter.
--If you specify a function, it should take two arguments, the unit and the partner unit.
--It should return true if the unit can unload at that location.
--It should return false otherwise.
--That is, function(unit,partnerUnit) -> boolean
--If you specify a string, it should be one of the following:
--[[* "ownCities": only unload in cities owned by the same tribe as the unit
    * "alliedCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities.
    * "peaceCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied).
    * "ownCitiesAirfields": only unload in cities owned by the same tribe as the unit, or on tiles with airfields.
    * "alliedCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities, or on tiles with airfields.
    * "peaceCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied), or on tiles with airfields.
    * "land": only unload on land
    * "everywhere": unload anywhere
--]]
cargo.registerDefaultLoadFunction("everywhere")
cargo.registerDefaultUnloadFunction("everywhere")

--[[
The unitType is a unitTypeObject that the cargoSpec is associated with.
cargoSpec is a table with the following fields:
* hold = integer >= 0 | nil
    - the number of units that can be carried
    - if nil, use unitType.hold 
* unload = nil | "default" | "ownCities" | "alliedCities" | "peaceCities" | "ownCitiesAirfields" | "alliedCitiesAirfields" | "peaceCitiesAirfields" | "everywhere" | "land" | function(unit,partnerUnit) -> boolean
    - Determines where cargo can be unloaded.  Both the cargo unit and the carrying unit must agree that unloading is allowed.  Units can always unload (for free) in a city.  Units will be unloaded from an air unit upon entering a city, will be unloaded from a ground unit if the city window is opened or at the end of the player's turn (if they are still there).
        + "ownCities": only unload in cities owned by the same tribe as the unit
        + "alliedCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities.
        + "peaceCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied).
        + "ownCitiesAirfields": only unload in cities owned by the same tribe as the unit, or on tiles with airfields.
        + "alliedCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities, or on tiles with airfields.
        + "peaceCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied), or on tiles with airfields.
        + "land": only unload on land
        + "everywhere": unload anywhere
        + "default": use the default unloading rule
        + function(unit,partnerUnit) -> boolean: a function that takes the unit corresponding to this cargo spec, and the `partnerUnit` (either the carrier or the cargo, depending on what \`unit\` is) and returns true if the cargo can be unloaded and false if it can't.
        + nil means "default"
* unloadFailureMessage = nil | string | function(unit,partnerUnit) -> string | nil
    - If the cargo can't be unloaded, this message is displayed to the user.  If both the carrying unit and the cargo unit are unable to unload, and both have an unload message, the message from the carrying unit is displayed first, followed by the message from the cargo unit.
        + nil: no message is displayed
        + string: a message to display.  text.substitute(message,{unit.type.name,partnerUnit.type.name,unit,partnerUnit}) is called to generate the message.
        + function(unit,partnerUnit) -> string | nil: a function that takes the unit corresponding to this cargo spec, and the `partnerUnit` (either the carrier or the cargo, depending on what \`unit\` is) and returns a string to display.
* unloadEffects = nil | number | function(unit,partnerUnit) -> number | nil
    - Provides effects when the cargo is unloaded.  There is never an effect if the cargo is unloaded within a city.
        + if nil, there is no unloading effect or cost
        + if positive number, this many movement points is expended for unloading.  (The cargo expends movement based on its unloadEffects value, and the carrying unit expends movement based on its own unloadEffects value.)
        + if negative number, expend "atomic" movement points instead of full movement points.  (The cargo expends movement based on its unloadEffects value, and the carrying unit expends movement based on its own unloadEffects value.)
        + if function, the function is called with the cargo unit and the carrying unit as arguments.  If the function returns a number, that number is used to spend movement points in addition to whatever other effect the function has.  The cargo unit's function will be called first, if applicable, and then the carrying unit's function will be called.
* load = "ownCities" | "alliedCities" | "peaceCities" | "ownCitiesAirfields" | "alliedCitiesAirfields" | "peaceCitiesAirfields" | "everywhere" | "land" | "default" | function(unit,partnerUnit) -> boolean 
    - Determines where cargo can be loaded from.  Both the cargo unit and the carrying unit must agree that loading is allowed.  Units can always be loaded (for free) from within cities.
        + "ownCities": only load from cities owned by the same tribe as the unit
        + "alliedCities": only load from cities owned by the same tribe as the unit, or from squares adjacent to allied cities.
        + "peaceCities": only load from cities owned by the same tribe as the unit, or from squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied).
        + "ownCitiesAirfields": only load from cities owned by the same tribe as the unit, or from tiles with airfields.
        + "alliedCitiesAirfields": only load from cities owned by the same tribe as the unit, or from squares adjacent to allied cities, or from tiles with airfields.
        + "peaceCitiesAirfields": only load from cities owned by the same tribe as the unit, or from squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied), or from tiles with airfields.
        + "land": only load from land
        + "everywhere": load from anywhere
        + function(unit,partnerUnit) -> boolean: a function that takes the unit corresponding to this cargo spec, and the `partnerUnit` (either the carrier or the cargo, depending on what \`unit\` is) and returns true if the cargo can be loaded and false if it can't.
        + "default": use the default loading rule
        + nil means "default"
* loadEffects = nil | number | function(unit,partnerUnit) -> number | nil
    - Provides effects when the cargo is loaded.  The effect happens when the carrying unit leaves the tile with sleeping units.  There is never an effect if the cargo is loaded within a city.
        + if nil, there is no unloading effect or cost
        + if positive number, this many movement points is expended for unloading.  (The cargo expends movement based on its unloadEffects value, and the carrying unit expends movement based on its own unloadEffects value.)
        + if negative number, expend "atomic" movement points instead of full movement points.  (The cargo expends movement based on its unloadEffects value, and the carrying unit expends movement based on its own unloadEffects value.)
        + if function, the function is called with the cargo unit and the carrying unit as arguments.  If the function returns a number, that number is used to spend movement points in addition to whatever other effect the function has.  The cargo unit's function will be called first, if applicable, and then the carrying unit's function will be called.
* cargoDefends = boolean | number>=0 | function(unit,partnerUnit) -> boolean | number
    - If true, a cargo unit can defend the tile, at its normal defense value.  
    - If false, the cargo unit does not defend the tile.  This is true even if the partner unit would allow the cargo unit to defend the tile.
    - If a number, the cargo unit can defend the tile, but its defense value is multiplied by the number.  If both the cargo unit and the carrying unit have a numerical cargoDefends value, both values are multiplied together for the combat penalty (or bonus).
    - If a function, the function is called with the unit and the partnerUnit unit as arguments, and the returned value is applied as above.
    - nil is true for ground units, and false for air and sea units.
* cargoDestroyed = boolean | number>=0 | function(unit,partnerUnit) -> boolean | number>=0
    - If true, the cargo unit is destroyed if the carrying unit is destroyed.
    - If false, the cargo unit is not destroyed if the carrying unit is destroyed.
    - If a number, split the number into the integer part and the fractional part.  That is, integer part is math.floor(number) and fractional part is number - math.floor(number).  
        + The fractional part is the probability the cargo unit is destroyed.  Multiply the probabilities of **survival** for the cargo unit and the carrying unit together to get the probability the cargo unit survives.  
        (e.g. if the carrying unit has a .5 chance of destruction, and the cargo unit has a .25 chance of destruction, multiply the survival chances (.5 and .75) together to get a .375 chance of survival or .625 chance of destruction for the cargo unit).  This is equivalent to applying the cargo unit's destruction chance, then, if the unit is not destroyed, applying the carrying unit's destruction chance.
        + The integer part is the damage dealt to the cargo if it survives (With the cargo destroyed if damage exceeds remaining hitpoints). 
    - If a function, the function is called with the unit and the partnerUnit unit as arguments, and the returned value is applied as above.
    - nil is false for ground units, and true for air and sea units.
    - if stack kills are enabled, all cargo is destroyed anyway.
* validCargo = nil|function(cargo,carryingUnit) --> boolean
    - If nil, 
        + Refer to the following keys to determine if the cargo can be carried:
            * allowedCargoTypes
            * forbiddenCargoTypes
            * allowedTransportTypes
            * forbiddenTransportTypes
        + If all of the above keys are nil, then any ground unit can be carried (but not any air or sea units), unless the carrying unit type has the carryAir flag, in which case only air units can be carried.
    - If a table, the table should contain unitType objects.  Only units of those types can be carried.
    - If a function, the function is called with the prospective cargo and carrying unit as arguments, and the unit can be carried if and only if the function returns true.
    - Note that conditions must be met for both the cargo unit and the carrying unit. 
* allowedCargoTypes = nil|table<any,unitType>
    - The unit can only carry unitTypes in this table.
* forbiddenCargoTypes = nil|table<any,unitTypes>
    - The unit can cary all unitTypes, except those listed in this table.  
    - If allowedCargoTypes is not nil, this table is ignored.
* allowedTransportTypes = nil|table<any,unitType>
    - The unit can only be carried by unitTypes in this table.
* forbiddenTransportTypes = nil|table<any,unitTypes>
    - The unit can be carried by any transport unit, except those listed in this table.
    - If allowedTransportTypes is not nil, this table is ignored.

--]]




--[[ Some examples used during testing ]]
--[[
cargo.registerCargoSpec(gen.original.uMechInf,{
    hold = 1,
    load = "ownCities",
    loadEffects = 1,
    unload = "ownCities",
    unloadFailureMessage = "%STRING1 can't unload %STRING2 here",
})



cargo.registerCargoSpec(gen.original.uBomber,{
    hold = 1,
    load = "ownCitiesAirfields",
    loadEffects = 1,
    unload = function(bomber,cargo)
        if gen.isParadrop(cargo.type) and cargo.location.type ~= gen.c.oceanBaseTerrainType then
            return true
        end
        return false
        end,
    unloadFailureMessage = "%NAME3 can't unload %NAME4 here",
    unloadEffects = 2,
})

cargo.registerCargoSpec(gen.original.uParatroopers,{
    hold = 0,
    load = "ownCitiesAirfields",
    unload = "land",
})

cargo.registerCargoSpec(gen.original.uStlthBmbr,{
    hold = 2,
    load = "ownCitiesAirfields",
    allowedCargoTypes = {gen.original.uFighter},
    unload = "everywhere",
})

cargo.registerCargoSpec(gen.original.uFighter,{
    hold = 0,
    load = "ownCitiesAirfields",
    unload = "everywhere",
    allowedTransportTypes = {gen.original.uStlthBmbr},
})

cargo.registerCargoSpec(gen.original.uFreight,{
    hold = 2,
    load = "everywhere",
    unload = "everywhere",
    --unload = "peaceCitiesAirfields",
    loadEffects = -1,
    unloadEffects = -1,
    cargoDefends = 0.75,
    cargoDestroyed = 2.5,
    forbiddenCargoTypes = {gen.original.uFreight},
})

cargo.registerCargoSpec(gen.original.uMusketeers,{
    hold = 0,
    load = "peaceCities",
    unload = "land",
    cargoDefends = false,
    cargoDestroyed = true,
})

cargo.registerCargoSpec(gen.original.uLegion,{
    hold = 0,
    load = "alliedCities",
    unload = "land",
    cargoDefends = false,
    cargoDestroyed = 2.5,
})  

-- in testing, this unit was given carryAir flag
cargo.registerCargoSpec(gen.original.uExtraLand,{
    hold = 3,
    load = "everywhere",
    unload = "everywhere",
    cargoDefends = false,
    cargoDestroyed = 2.5,
})

cargo.registerCargoSpec(gen.original.uCruiseMsl,{
    hold = 0,
    load = "ownCities",
    unload = "peaceCitiesAirfields",
    cargoDefends = false,
    cargoDestroyed = 2.5,
    forbiddenTransportTypes = {}, -- allows it to be carried by anything, not just units with carryAir flag
})
--]]


local cargoSettings = {}

gen.versionFunctions(cargoSettings, versionNumber, fileModified, "MechanicsFiles\\cargoSettings.lua")
return cargoSettings