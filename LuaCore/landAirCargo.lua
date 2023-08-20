--
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--  This module allows land and air units to carry cargo
--  and controls the details

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(8)
local civlua = require("civlua")
local diplomacy = require("diplomacy")
---@module "discreteEventsRegistrar"
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local text = require("text")
---@module "unitData"
local unitData = require("unitData")
local navy = require("navy"):minVersion(2) -- to make sure that the navy module doesn't interfere with this module
local changeRules = require("changeRules")


local applyToAI = false -- set to true if you want this stuff to apply to the AI

local cargo = {}
gen.versionFunctions(cargo,versionNumber,fileModified,"LuaCore".."\\".."landAirCargo.lua")
gen.minEventsLuaVersion(7, 1, "LuaCore\\landAirCargo.lua")



local function isTableOfUnitTypes(table)
    for key,val in pairs(table) do
        if not civ.isUnitType(val) then
            return "The value for key "..key.." is not a unit type.  Received "..tostring(val)
        end
    end
end

-- Define external cargoSpec:
local cargoSpecSpecificKeys = {
    hold = {["nil"]=true, ["number"]={minVal=0,integer=true}},
    unload = {["nil"]=true, ["string"]={default=true,ownCities=true,alliedCities=true,peaceCities=true,ownCitiesAirfields=true,alliedCitiesAirfields=true,peaceCitiesAirfields=true,everywhere=true,land=true}, ["function"]="function(unit,partnerUnit) -> boolean"},
    unloadFailureMessage = {["nil"]=true, ["string"]=true, ["function"] = "function(unit,partnerUnit) -> string"},
    unloadEffects = {["nil"]=true, ["number"]=true, ["function"]="function(unit,partnerUnit) -> number|nil"},
    load = {["nil"]=true, ["string"]={default=true, ownCities=true,alliedCities=true,peaceCities=true,ownCitiesAirfields=true,alliedCitiesAirfields=true,peaceCitiesAirfields=true,everywhere=true,land=true}, ["function"]="function(unit,partnerUnit) -> boolean"},
    loadEffects = {["nil"]=true, ["number"]=true, ["function"]="function(unit,partnerUnit) -> number"},
    cargoDefends = {["nil"]=true, ["boolean"]=true, ["number"]={minVal=0}, ["function"]="function(unit,partnerUnit) -> boolean|number"},
    cargoDestroyed = {["nil"]=true, ["boolean"]=true, ["number"]={minVal=0}, ["function"]="function(unit,partnerUnit) -> boolean"},
    validCargo = {["nil"]=true, ["function"]="function(cargo,carryingUnit) -> boolean"},
    allowedCargoTypes = {["table"]={isTableOfUnitTypes,"Table with unit type values."},["nil"]=true},
    forbiddenCargoTypes = {["table"]={isTableOfUnitTypes,"Table with unit type values."},["nil"]=true},
    allowedTransportTypes = {["table"]={isTableOfUnitTypes,"Table with unit type values."},["nil"]=true},
    forbiddenTransportTypes = {["table"]={isTableOfUnitTypes,"Table with unit type values."},["nil"]=true},
}

local cargoSpecDefaultValues = {
}

local newCargoSpec, isCargoSpec, cargoSpecMT = gen.createDataType("cargoSpecification", cargoSpecSpecificKeys, {}, cargoSpecDefaultValues, {}, {})



local internalSpecKeys = {
    hold = {["function"]="function(unit) -> number"},
    unload = { ["function"]="function(unit,partnerUnit) -> boolean"},
    unloadFailureMessage = {["function"] = "function(unit,partnerUnit) -> string"},
    unloadEffects = {["function"]="function(unit,partnerUnit) -> number"},
    load = {["function"]="function(unit,partnerUnit) -> boolean"},
    loadEffects = {["function"]="function(unit,partnerUnit) -> number"},
    cargoDefends = {["function"]="function(unit,partnerUnit) -> boolean|number"},
    cargoDestroyed = { ["function"]="function(unit,partnerUnit) -> boolean"},
    validCargo = {["function"]="function(cargo,carryingUnit) -> boolean"},
}

local baseNewInternalSpec, isInternalSpec, internalSpecMT = gen.createDataType("internalCargoSpecification", internalSpecKeys, {}, {}, {}, {})

local loadUnloadKeyWords = {
    ownCities = true,
    alliedCities = true,
    peaceCities = true,
    ownCitiesAirfields = true,
    alliedCitiesAirfields = true,
    peaceCitiesAirfields = true,
    everywhere = true,
    land = true,
}


local unloadFunctions = {}
function unloadFunctions.ownCities(unit,partnerUnit)
    return not not unit.location.city
end
function unloadFunctions.alliedCities(unit,partnerUnit)
    if unit.location.city then
        return true
    end
    for _, tile in pairs(gen.getAdjacentTiles(unit.location)) do
        if tile.city and tile.city.owner ~= unit.owner and 
        diplomacy.allianceExists(unit.owner,tile.city.owner) then
            return true
        end
    end
    return false
end
function unloadFunctions.peaceCities(unit,partnerUnit)
    if unit.location.city then
        return true
    end
    for _, tile in pairs(gen.getAdjacentTiles(unit.location)) do
        if tile.city and tile.city.owner ~= unit.owner and 
        diplomacy.peaceTreatyExists(unit.owner,tile.city.owner) then
            return true
        end
    end
    return false
end
function unloadFunctions.ownCitiesAirfields(unit,partnerUnit)
    return (not not unit.location.city) or gen.hasAirbase(unit.location)
end

function unloadFunctions.alliedCitiesAirfields(unit,partnerUnit)
    if unit.location.city or gen.hasAirbase(unit.location) then
        return true
    end
    for _, tile in pairs(gen.getAdjacentTiles(unit.location)) do
        if tile.city and tile.city.owner ~= unit.owner and 
        diplomacy.allianceExists(unit.owner,tile.city.owner) then
            return true
        end
    end
    return false
end

function unloadFunctions.peaceCitiesAirfields(unit,partnerUnit)
    if unit.location.city or gen.hasAirbase(unit.location) then
        return true
    end
    for _, tile in pairs(gen.getAdjacentTiles(unit.location)) do
        if tile.city and tile.city.owner ~= unit.owner and 
        diplomacy.peaceTreatyExists(unit.owner,tile.city.owner) then
            return true
        end
    end
    return false
end

function unloadFunctions.everywhere(unit,partnerUnit)
    return true
end

function unloadFunctions.land(unit,partnerUnit)
    return not (unit.location.baseTerrain.type == gen.c.oceanBaseTerrainType)
end

local defaultUnloadFunction = unloadFunctions.ownCities
unloadFunctions.default = function(unit,partnerUnit)
    return defaultUnloadFunction(unit,partnerUnit)
end

--Registers a function as the new default unload function.
--The function should take two arguments, the unit and the partner unit.
--It should return true if the unit can unload at that location.
--It should return false otherwise.
--[[The `code` parameter can also be one of the following strings:
    * "ownCities": only unload in cities owned by the same tribe as the unit
    * "alliedCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities.
    * "peaceCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied).
    * "ownCitiesAirfields": only unload in cities owned by the same tribe as the unit, or on tiles with airfields.
    * "alliedCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities, or on tiles with airfields.
    * "peaceCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied), or on tiles with airfields.
    * "land": only unload on land
    * "everywhere": unload anywhere

--]]
---@param code string|fun(unit: unitObject, partnerUnit: unitObject): boolean
function cargo.registerDefaultUnloadFunction(code)
    local origCode = code
    if loadUnloadKeyWords[code] then
        code = unloadFunctions[code]
    end
    if type(code) ~= "function" then
        error("The argument to cargo.registerDefaultUnloadFunction should be a function or one of the following strings: 'ownCities', 'alliedCities', 'peaceCities', 'ownCitiesAirfields', 'alliedCitiesAirfields', 'peaceCitiesAirfields', 'everywhere', 'land'.  Received "..tostring(origCode))
    end
    defaultUnloadFunction = code
end

local loadFunctions = {}
loadFunctions.ownCities = unloadFunctions.ownCities
loadFunctions.alliedCities = unloadFunctions.alliedCities
loadFunctions.peaceCities = unloadFunctions.peaceCities
loadFunctions.ownCitiesAirfields = unloadFunctions.ownCitiesAirfields
loadFunctions.alliedCitiesAirfields = unloadFunctions.alliedCitiesAirfields
loadFunctions.peaceCitiesAirfields = unloadFunctions.peaceCitiesAirfields
loadFunctions.everywhere = unloadFunctions.everywhere
loadFunctions.land = unloadFunctions.land

local defaultLoadFunction = loadFunctions.ownCities
loadFunctions.default = function(unit,partnerUnit)
    return defaultLoadFunction(unit,partnerUnit)
end

--Registers a function as the new default unload function.
--The function should take two arguments, the unit and the partner unit.
--It should return true if the unit can unload at that location.
--It should return false otherwise.
--[[The `code` parameter can also be one of the following strings:
    * "ownCities": only unload in cities owned by the same tribe as the unit
    * "alliedCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities.
    * "peaceCities": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied).
    * "ownCitiesAirfields": only unload in cities owned by the same tribe as the unit, or on tiles with airfields.
    * "alliedCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to allied cities, or on tiles with airfields.
    * "peaceCitiesAirfields": only unload in cities owned by the same tribe as the unit, or in squares adjacent to cities of tribes with which the unit's tribe is at peace (or allied), or on tiles with airfields.
    * "land": only unload on land
    * "everywhere": unload anywhere

--]]
---@param code string|fun(unit: unitObject, partnerUnit: unitObject): boolean
function cargo.registerDefaultLoadFunction(code)
    local origCode = code
    if loadUnloadKeyWords[code] then
        code = loadFunctions[code]
    end
    if type(code) ~= "function" then
        error("The argument to cargo.registerDefaultLoadFunction should be a function, or one of these strings: 'ownCities', 'alliedCities', 'peaceCities', 'ownCitiesAirfields', 'alliedCitiesAirfields', 'peaceCitiesAirfields', 'everywhere', 'land'.  Received "..tostring(origCode))
    end
    defaultLoadFunction = code
end


local function newInternalSpec(spec)
    local inSpec = {}
    if spec.hold then
        local holdValue = spec.hold
        inSpec.hold = function(unit) return holdValue end
    else
        inSpec.hold = function(unit) return unit.type.hold end
    end
    if type(spec.unload) == "function" then
        inSpec.unload = spec.unload
    else
        local unloadString = spec.unload or "default"
        inSpec.unload = unloadFunctions[unloadString]
    end
    if type(spec.unloadFailureMessage) == "function" then
        inSpec.unloadFailureMessage = spec.unloadFailureMessage
    else
        local messageString = spec.unloadFailureMessage
        inSpec.unloadFailureMessage = function(unit,partnerUnit) return messageString end
    end
    if type(spec.unloadEffects) == "function" then
        inSpec.unloadEffects = spec.unloadEffects
    else
        local unloadEffectsValue = spec.unloadEffects
        inSpec.unloadEffects = function(unit,partnerUnit) return unloadEffectsValue end
    end
    if type(spec.load) == "function" then
        inSpec.load = spec.load
    else
        local loadString = spec.load or "default"
        inSpec.load = loadFunctions[loadString]
    end
    if type(spec.loadEffects) == "function" then
        inSpec.loadEffects = spec.loadEffects
    else
        local loadEffectsValue = spec.loadEffects
        inSpec.loadEffects = function(unit,partnerUnit) return loadEffectsValue end
    end
    if type(spec.cargoDefends) == "function" then
        inSpec.cargoDefends = spec.cargoDefends
    elseif type(spec.cargoDefends) == "nil" then
        inSpec.cargoDefends = function(unit,partnerUnit) return unit.type.domain == gen.c.domainLand end
    else
        local cargoDefendsValue = spec.cargoDefends
        inSpec.cargoDefends = function(unit,partnerUnit) return cargoDefendsValue end
    end
    if type(spec.cargoDestroyed) == "function" then
        inSpec.cargoDestroyed = spec.cargoDestroyed
    elseif type(spec.cargoDestroyed) == "nil" then
        inSpec.cargoDestroyed = function(unit,partnerUnit) return unit.type.domain ~= gen.c.domainLand end
    else
        local cargoDestroyedValue = spec.cargoDestroyed
        inSpec.cargoDestroyed = function(unit,partnerUnit) return cargoDestroyedValue end
    end
    if type(spec.validCargo) == "function" then
        inSpec.validCargo = spec.validCargo
    else
        local cargoIsOK = function(cargo) return true end
        local transportIsOK = function(carryingUnit) return true end
        if spec.allowedCargoTypes then
            local allowedCargoTypes = {}
            for _,unitType in pairs(spec.allowedCargoTypes) do
                allowedCargoTypes[unitType.id] = true
            end
            cargoIsOK = function(cargo) return not not allowedCargoTypes[cargo.type.id] end
        elseif spec.forbiddenCargoTypes then
            local forbiddenCargoTypes = {}
            for _,unitType in pairs(spec.forbiddenCargoTypes) do
                forbiddenCargoTypes[unitType.id] = true
            end
            cargoIsOK = function(cargo) return not forbiddenCargoTypes[cargo.type.id] end
        end
        if spec.allowedTransportTypes then
            local allowedTransportTypes = {}
            for _,unitType in pairs(spec.allowedTransportTypes) do
                allowedTransportTypes[unitType.id] = true
            end
            transportIsOK = function(carryingUnit) return not not allowedTransportTypes[carryingUnit.type.id] end
        elseif spec.forbiddenTransportTypes then
            local forbiddenTransportTypes = {}
            for _,unitType in pairs(spec.forbiddenTransportTypes) do
                forbiddenTransportTypes[unitType.id] = true
            end
            transportIsOK = function(carryingUnit) return not forbiddenTransportTypes[carryingUnit.type.id] end
        end
        if spec.allowedCargoTypes or spec.allowedTransportTypes
        or spec.forbiddenCargoTypes or spec.forbiddenTransportTypes then
        inSpec.validCargo = function(cargo,carryingUnit) 
            return cargoIsOK(cargo) and transportIsOK(carryingUnit) end
        else
            inSpec.validCargo = function(cargo,carryingUnit) 
                if gen.isCarryAir(carryingUnit.type) then
                    return cargo.type.domain == gen.c.domainAir
                else
                    return cargo.type.domain == gen.c.domainLand
                end
            end
        end
    end
    return baseNewInternalSpec(inSpec)
end

local cargoInfoTable = {}

local emptyCargoInfo = newInternalSpec(newCargoSpec({}))

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
---@param unitType unitTypeObject
---@param cargoSpec table
function cargo.registerCargoSpec(unitType,cargoSpec)
    local internalSpec = newInternalSpec(newCargoSpec(cargoSpec))
    if cargoInfoTable[unitType.id] then
        error("Cargo spec already registered for unit type "..unitType.id)
    end
    cargoInfoTable[unitType.id] = internalSpec
end

local moduleName = "landAirCargo"

unitData.defineModuleFlag(moduleName, "isBeingCarried", false)


-- This function exists so that a different way of recording
-- cargo being carried can be used if necessary
local function setCarriedBy(cargoUnit,carryingUnit)
    unitData.flagSetTrue(cargoUnit,"isBeingCarried",moduleName)
    cargoUnit.carriedBy = carryingUnit
end

-- This function exists so that a different way of recording
-- cargo being carried can be used if necessary
local function clearCarriedBy(cargoUnit)
    unitData.flagReset(cargoUnit,"isBeingCarried",moduleName)
    cargoUnit.carriedBy = nil
end

-- This function exists so that a different way of recording
-- cargo being carried can be used if necessary
local function isCarriedBy(cargoUnit,possibleCarrier)
    if unitData.flagGetValue(cargoUnit, "isBeingCarried", moduleName) then
        return cargoUnit.carriedBy == possibleCarrier
    else
        return false
    end
    --return cargoUnit.carriedBy == possibleCarrier
end

---Returns true if the `cargoUnit` is being carried by the `possibleCarrier`.
---@param cargoUnit unitObject
---@param possibleCarrier unitObject
---@return boolean
function cargo.isCarriedBy(cargoUnit,possibleCarrier)
    return isCarriedBy(cargoUnit,possibleCarrier)
end


-- This function exists so that a different way of recording
-- cargo being carried can be used if necessary
local function isBeingCarried(cargoUnit)
    return unitData.flagGetValue(cargoUnit, "isBeingCarried", moduleName)
    --return cargoUnit.carriedBy ~= nil
end

---Returns true if the `cargoUnit` is being carried by any unit.
---@param cargoUnit unitObject
---@return boolean
function cargo.isBeingCarried(cargoUnit)
    return isBeingCarried(cargoUnit)
end

local function getCarryingUnit(cargoUnit)
    if not isBeingCarried(cargoUnit) then
        return nil
    end
    return cargoUnit.carriedBy
end

---Returns the unit carrying the `cargoUnit`, or nil if the `cargoUnit` is not being carried.
---@param cargoUnit unitObject
---@return unitObject|nil
function cargo.getCarryingUnit(cargoUnit)
    return getCarryingUnit(cargoUnit)
end

-- if using the carriedBy field, moving a unit one
-- square undoes the carriedBy field, so we need to
-- renew it.  This function exists so that a different
-- way of recording cargo being carried can be used if necessary
local function renewCarriedBy(cargo,carryingUnit)
    cargo.carriedBy = carryingUnit
    gen.setToSleeping(cargo)
end

--Makes the cargoUnit carried by the carrying unit.
--If the cargoUnit is not in a city, the load effects are applied.
--Does not check if the cargoUnit can be loaded.
---@param cargoUnit unitObject
---@param carryingUnit unitObject
function cargo.loadCargo(cargoUnit,carryingUnit)
    local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    if not cargoUnit.location.city then
        local cargoLoadEffect = cargoInfo.loadEffects(cargoUnit,carryingUnit)
        local carryingLoadEffect = carryingInfo.loadEffects(carryingUnit,cargoUnit)
        if type(cargoLoadEffect) == "number" then
            if cargoLoadEffect >= 0 then
                gen.spendMovementPoints(cargoUnit, cargoLoadEffect)
            else
                gen.spendMovementPoints(cargoUnit, -cargoLoadEffect,1)
            end
        end
        if type(carryingLoadEffect) == "number" then
            if carryingLoadEffect >= 0 then
                gen.spendMovementPoints(carryingUnit, carryingLoadEffect)
            else
                gen.spendMovementPoints(carryingUnit, -carryingLoadEffect,1)
            end
        end
    end
    setCarriedBy(cargoUnit, carryingUnit)
end

--Makes the cargoUnit not carried by the carrying unit.
--If the cargoUnit is not in a city, the unload effects are applied.
--Does not check if the cargoUnit can be unloaded.
---@param cargoUnit unitObject
---@param carryingUnit unitObject
function cargo.unloadCargo(cargoUnit,carryingUnit)
    local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    if not cargoUnit.location.city then
        local cargoUnloadEffect = cargoInfo.unloadEffects(cargoUnit,carryingUnit)
        local carryingUnloadEffect = carryingInfo.unloadEffects(carryingUnit,cargoUnit)
        if type(cargoUnloadEffect) == "number" then
            if cargoUnloadEffect >= 0 then
                gen.spendMovementPoints(cargoUnit, cargoUnloadEffect)
            else
                gen.spendMovementPoints(cargoUnit, -cargoUnloadEffect,1)
            end
        end
        if type(carryingUnloadEffect) == "number" then
            if carryingUnloadEffect >= 0 then
                gen.spendMovementPoints(carryingUnit, carryingUnloadEffect)
            else
                gen.spendMovementPoints(carryingUnit, -carryingUnloadEffect,1)
            end
        end
    end
    clearCarriedBy(cargoUnit)
end

--Returns true if the cargoUnit can be loaded onto the carryingUnit, 
--and false otherwise.  Returns false if the unit is already carried.
---@param cargoUnit unitObject
---@param carryingUnit unitObject
---@return boolean
function cargo.canLoadOnto(cargoUnit,carryingUnit)
    if isBeingCarried(cargoUnit) then
        return false
    end
    local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    if not cargoInfo.validCargo(cargoUnit,carryingUnit) then
        return false
    end
    if not carryingInfo.validCargo(cargoUnit,carryingUnit) then
        return false
    end
    if not cargoInfo.load(cargoUnit,carryingUnit) then
        return false
    end
    if not carryingInfo.load(carryingUnit,cargoUnit) then
        return false
    end
    return true
end

--Returns the number of holds the cargo takes up on a carryingUnit.
--Always 1 for now, but may be changed in the future.
---@param cargoUnit unitObject
---@return number
function cargo.numberOfHoldsUsed(cargoUnit)
    return 1
end


--Returns true if the cargoUnit can be unloaded from the carryingUnit.
--Return false if the cargoUnit is not carried by the carryingUnit.
---@param cargoUnit unitObject
---@param carryingUnit unitObject
---@return boolean
function cargo.canUnloadFrom(cargoUnit,carryingUnit)
    if not isCarriedBy(cargoUnit,carryingUnit) then
        return false
    end
    local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    if not cargoInfo.unload(cargoUnit,carryingUnit) then
        return false
    end
    if not carryingInfo.unload(carryingUnit,cargoUnit) then
        return false
    end
    return true
end

--Returns the remaining cargo capacity of the carryingUnit.
--By default, checks adjacent tiles for cargo in case the cargo
--hasn't been teleported to the carryingUnit's tile yet.
--If checkTile is a tileObject, only that tile and the carryingUnit's
--tile are checked for cargo.
---@param carryingUnit unitObject
---@param checkTile? tileObject
---@return number
function cargo.remainingCapacity(carryingUnit,checkTile)
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    local remainingHolds = carryingInfo.hold(carryingUnit)
    if not checkTile then
        for possibleCargo in gen.nearbyUnits(carryingUnit.location,1) do
            if isCarriedBy(possibleCargo,carryingUnit) then
                remainingHolds = remainingHolds - cargo.numberOfHoldsUsed(possibleCargo)
            end
        end
    else
        for possibleCargo in checkTile.units do
            if isCarriedBy(possibleCargo,carryingUnit) then
                remainingHolds = remainingHolds - cargo.numberOfHoldsUsed(possibleCargo)
            end
        end
        if carryingUnit.location ~= checkTile then
            for possibleCargo in carryingUnit.location.units do
                if isCarriedBy(possibleCargo,carryingUnit) then
                    remainingHolds = remainingHolds - cargo.numberOfHoldsUsed(possibleCargo)
                end
            end
        end
    end
    return remainingHolds
end

-- A "phantomUnit" is a table that passes through most
-- calls to unit fields, but changes some fields to
-- be different from the actual unit
-- (An example is that this allows a unit to 'pretend' to
-- be on a different tile than it actually is)
---@param unit unitObject
---@param phantomParameters table<string,any> # these parameters are stored in the table, instead of referring to the unit's fields
---@return table
local function makePhantomUnit(unit,phantomParameters)
    local phantomUnit = gen.copyTable(phantomParameters)
    local mt = { __index = function(t,key) return unit[key] end,
        __newindex = function(t,key,value) unit[key] = value end,
    }
    setmetatable(phantomUnit,mt)
    return phantomUnit
end

function cargo.onEnterTile(carryingUnit,previousTile,prevDomainSpec)
    -- don't apply to AI unless specified
    if carryingUnit.type.domain == gen.c.domainSea or not (applyToAI or carryingUnit.owner.isHuman) then
        return false
    end
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    if carryingInfo.hold(carryingUnit) <= 0 then
        return
    end
    local remainingCapacity = cargo.remainingCapacity(carryingUnit,previousTile)
    --local currentTile = carryingUnit.location
    --carryingUnit:teleport(previousTile)
    local trueCarryingUnit = carryingUnit
    local phantomCarryingUnit = makePhantomUnit(carryingUnit,{location = previousTile})
    for possibleCargo --[[@as unitObject]] in previousTile.units do
        if isCarriedBy(possibleCargo,trueCarryingUnit) then
            possibleCargo:teleport(trueCarryingUnit.location)
            renewCarriedBy(possibleCargo, trueCarryingUnit)
        end
        if gen.isSleeping(possibleCargo) and remainingCapacity >= cargo.numberOfHoldsUsed(possibleCargo) and cargo.canLoadOnto(possibleCargo,phantomCarryingUnit) then
            cargo.loadCargo(possibleCargo,trueCarryingUnit)
            remainingCapacity = remainingCapacity - cargo.numberOfHoldsUsed(possibleCargo)
            possibleCargo:teleport(trueCarryingUnit.location)
            renewCarriedBy(possibleCargo, trueCarryingUnit)
        end
    end
end
discreteEvents.onEnterTile(cargo.onEnterTile)

--Automatically unloads cargo in a city.  To be called when a city window
--is opened or at the end of a turn.
function cargo.unloadCargoInCity(city)
    for cargoUnit in city.location.units do
        if isBeingCarried(cargoUnit) then
            local carryingUnit = getCarryingUnit(cargoUnit)
            if carryingUnit.location == city.location then
                cargo.unloadCargo(cargoUnit,carryingUnit)
                gen.setToNoOrders(cargoUnit)
            end
        end
    end
end

local function cargoOnCityScreenOpened(city)
    cargo.unloadCargoInCity(city)
end
discreteEvents.onCityWindowOpened(cargoOnCityScreenOpened)

local function cargoOnTribeTurnEnd(turn,tribe)
    for city in civ.iterateCities() do
        if city.owner == tribe then
            cargo.unloadCargoInCity(city)
        end
    end
end
discreteEvents.onTribeTurnEnd(cargoOnTribeTurnEnd)


---Performs onActivateUnit effects for this event.  Return true if the activation should be cancelled, and false otherwise.
---@param cargoUnit unitObject
---@return boolean|fun(u:unitObject) Return true if activation should be cancelled, and false otherwise.
function cargo.onActivateCargoUnit(cargoUnit,manualActivation)
    -- don't apply to AI unless specified
    if not (applyToAI or cargoUnit.owner.isHuman) then
        return false
    end
    local carryingUnit = getCarryingUnit(cargoUnit)
    if (not carryingUnit) or carryingUnit.type.domain == gen.c.domainSea then
        return false
    end
    if carryingUnit.location.x > 60000 then
        gen.killUnit(cargoUnit)
        return true
    end
    if carryingUnit.location ~= cargoUnit.location then
        clearCarriedBy(cargoUnit)
        return false
    end
    if not manualActivation then
        return function(notActivatedUnit) gen.setToSleeping(notActivatedUnit) end
    end
    local cargoSpec = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingSpec = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    local cargoUnitCanBeUnloaded = cargoSpec.unload(cargoUnit,carryingUnit)
    local carryingUnitCanBeUnloaded = carryingSpec.unload(carryingUnit,cargoUnit)
    if cargoUnitCanBeUnloaded and carryingUnitCanBeUnloaded then
        cargo.unloadCargo(cargoUnit,carryingUnit)
        return false
    end
    local carryingUnloadFailureMessage = carryingSpec.unloadFailureMessage(carryingUnit,cargoUnit)
    local cargoUnloadFailureMessage = cargoSpec.unloadFailureMessage(cargoUnit,carryingUnit)
    if carryingUnloadFailureMessage or cargoUnloadFailureMessage then
        local joiner = (carryingUnloadFailureMessage and cargoUnloadFailureMessage) and "\n^\n^" or ""
        carryingUnloadFailureMessage = carryingUnloadFailureMessage or ""
        carryingUnloadFailureMessage = text.substitute(carryingUnloadFailureMessage,{
            carryingUnit.type.name,cargoUnit.type.name,carryingUnit,cargoUnit,
        })
        cargoUnloadFailureMessage = cargoUnloadFailureMessage or ""
        cargoUnloadFailureMessage = text.substitute(cargoUnloadFailureMessage,{
            cargoUnit.type.name,carryingUnit.type.name,cargoUnit,carryingUnit,
        })
        local message = carryingUnloadFailureMessage ..joiner.. cargoUnloadFailureMessage
        text.simple(message,"Transportation Minister")
    end
    return function(notActivatedUnit) gen.setToSleeping(notActivatedUnit) end
end


--Computes the defense modifier for cargo units
--carried by land or air transports.
--If the unit is not being carried, return 1,
--so defense is unmodified.
--If the unit can't defend, return 0.
function cargo.getDefenseModifier(cargoUnit)
    local carryingUnit = getCarryingUnit(cargoUnit)
    if not carryingUnit or carryingUnit.type.domain == gen.c.domainSea then
        return 1
    end
    local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    local cargoDefenseModifier = cargoInfo.cargoDefends(cargoUnit,carryingUnit)
    local carryingDefenseModifier = carryingInfo.cargoDefends(carryingUnit,cargoUnit)
    if type(cargoDefenseModifier) == "number" and type(carryingDefenseModifier) == "number" then
        return cargoDefenseModifier * carryingDefenseModifier
    elseif (not cargoDefenseModifier) or (not carryingDefenseModifier) then
        return 0
    elseif type(cargoDefenseModifier) == "number" then
        return cargoDefenseModifier
    elseif type(carryingDefenseModifier) == "number" then
        return carryingDefenseModifier
    else
        return 1
    end
end

--Returns true if the cargo unit can defend the tile.
--Returns false otherwise.
--Returns true if the unit isn't the cargo of a land/air unit.
---@param cargoUnit unitObject
---@return boolean
function cargo.canDefend(cargoUnit)
    local carryingUnit = getCarryingUnit(cargoUnit)
    if not carryingUnit or carryingUnit.type.domain == gen.c.domainSea then
        return true
    end
    local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
    local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
    if not cargoInfo.cargoDefends(cargoUnit,carryingUnit) then
        return false
    end
    if not carryingInfo.cargoDefends(carryingUnit,cargoUnit) then
        return false
    end
    return true
end


function cargo.onCarryingUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    if loser.type.domain == gen.c.domainSea then
        return
    end
    if loser == victim and changeRules.authoritativeDefaultRules["cosmic2"]["nostackkills"] == false then
        return
    end
    local unitsKilledWithTransport = 0
    for cargoUnit in loserLocation.units do
        if isCarriedBy(cargoUnit,loser) then
            local subAggressor = aggressor
            if aggressor == loser then
                subAggressor = cargoUnit
            end
            local subVictim = cargoUnit
            if victim == winner then
                subVictim = winner
            end
            local subLoserVetStatus = cargoUnit.veteran
            local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
            local carryingInfo = cargoInfoTable[loser.type.id] or emptyCargoInfo
            local cargoDestroyed = cargoInfo.cargoDestroyed(cargoUnit,loser)
            local carryingDestroyed = carryingInfo.cargoDestroyed(loser,cargoUnit)
            if type(cargoDestroyed) == "number" and type(carryingDestroyed) == "number" then
                local cargoSurvivalChance = 1 - math.min(1,math.max(0,cargoDestroyed - math.floor(cargoDestroyed)))
                local carryingSurvivalChance = 1 - math.min(1,math.max(0,carryingDestroyed - math.floor(carryingDestroyed)))
                local survivalChance = cargoSurvivalChance * carryingSurvivalChance
                local cargoDamage = math.floor(cargoDestroyed)+math.floor(carryingDestroyed)
                if math.random() < survivalChance and cargoUnit.hitpoints > cargoDamage then
                    cargoUnit.damage = cargoUnit.damage + cargoDamage
                else
                    gen.defeatUnit(cargoUnit,winner,subAggressor,subVictim,loserLocation,winnerVetStatus,subLoserVetStatus)
                    unitsKilledWithTransport = unitsKilledWithTransport + 1
                end
            elseif cargoDestroyed == true or carryingDestroyed == true then
                gen.defeatUnit(cargoUnit,winner,subAggressor,subVictim,loserLocation,winnerVetStatus,subLoserVetStatus)
                unitsKilledWithTransport = unitsKilledWithTransport + 1
            elseif type(cargoDestroyed) == "number" then
                local cargoDestructionChance = cargoDestroyed - math.floor(cargoDestroyed)
                local cargoDamage = math.floor(cargoDestroyed)
                if math.random() < cargoDestructionChance or 
                cargoUnit.hitpoints <= cargoDamage then
                    gen.defeatUnit(cargoUnit,winner,subAggressor,subVictim,loserLocation,winnerVetStatus,subLoserVetStatus)
                    unitsKilledWithTransport = unitsKilledWithTransport + 1
                else
                    cargoUnit.damage = cargoUnit.damage + cargoDamage
                end
            elseif type(carryingDestroyed) == "number" then
                local carryingDestructionChance = carryingDestroyed - math.floor(carryingDestroyed)
                local cargoDamage = math.floor(carryingDestroyed)
                if math.random() < carryingDestructionChance or
                cargoUnit.hitpoints <= cargoDamage then
                    gen.defeatUnit(cargoUnit,winner,subAggressor,subVictim,loserLocation,winnerVetStatus,subLoserVetStatus)
                    unitsKilledWithTransport = unitsKilledWithTransport + 1
                else
                    cargoUnit.damage = cargoUnit.damage + cargoDamage
                end
            end
        end
    end
    if unitsKilledWithTransport > 0 then
        local message = tostring(unitsKilledWithTransport+1).." units destroyed."
        text.simple(message,"Defense Minister")
    end
end
    

function cargo.onCarryingUnitDeathOutsideCombat(carryingUnit)
    if carryingUnit.type.domain == gen.c.domainSea then
        return
    end
    for cargoUnit in carryingUnit.location.units do
        if isCarriedBy(cargoUnit,carryingUnit) then
            local cargoInfo = cargoInfoTable[cargoUnit.type.id] or emptyCargoInfo
            local carryingInfo = cargoInfoTable[carryingUnit.type.id] or emptyCargoInfo
            local cargoDestroyed = cargoInfo.cargoDestroyed(cargoUnit,carryingUnit)
            local carryingDestroyed = carryingInfo.cargoDestroyed(carryingUnit,cargoUnit)
            if type(cargoDestroyed) == "number" and type(carryingDestroyed) == "number" then
                local cargoSurvivalChance = 1 - math.min(1,math.max(0,cargoDestroyed - math.floor(cargoDestroyed)))
                local carryingSurvivalChance = 1 - math.min(1,math.max(0,carryingDestroyed - math.floor(carryingDestroyed)))
                local survivalChance = cargoSurvivalChance * carryingSurvivalChance
                if math.random() < survivalChance then
                    gen.setToSleeping(cargoUnit)
                else
                    gen.killUnit(cargoUnit)
                end
            elseif cargoDestroyed == true or carryingDestroyed == true then
                gen.killUnit(cargoUnit)
            elseif type(cargoDestroyed) == "number" then
                if math.random() < cargoDestroyed then
                    gen.killUnit(cargoUnit)
                end
            elseif type(carryingDestroyed) == "number" then
                if math.random() < carryingDestroyed then
                    gen.killUnit(cargoUnit)
                end
            end
        end
    end
end

local startOfTurnCargoUnits = {}
local function cargoOnTurnStart(turn,tribe)
    startOfTurnCargoUnits = {}
    for cargoUnit in civ.iterateUnits() do
        local carryingUnit = getCarryingUnit(cargoUnit)
        if carryingUnit and carryingUnit.type.domain ~= gen.c.domainSea then
            startOfTurnCargoUnits[cargoUnit.id] = true
        end
    end
end
discreteEvents.onTribeTurnBegin(cargoOnTurnStart)
local function cargoOnCityProcessingComplete(turn,tribe)
    for cargoUnitID,_ in pairs(startOfTurnCargoUnits) do
        local cargoUnit = civ.getUnit(cargoUnitID)
        if cargoUnit and (cargoUnit.carriedBy.location.x > 60000 or cargoUnit.carriedBy == nil) then
            gen.killUnit(cargoUnit)
        end
        startOfTurnCargoUnits[cargoUnitID] = nil
    end
end
discreteEvents.onCityProcessingComplete(cargoOnCityProcessingComplete)

return cargo
