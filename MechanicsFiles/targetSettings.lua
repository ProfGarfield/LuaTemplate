-- Note: See strategicTargetsDocumentation.txt in the LuaDocumentation folder

local gen = require("generalLibrary")
local strat = require("strategicTargets")
local discreteEvents = require("discreteEventsRegistrar")
local object = require("object")



-- This function should return true if the
-- item is a strategicItem (has a target associated with
-- it), and false otherwise

local function isStrategicItem(item)
  
  return false
end



-- tileEffectsFnunction(city,item) --> false or table of
--    {
--      tile = tileObject
--        a tile where something will happen
--      constructionBaseTerrain = baseTerrainObject or nil
--        change the base terrain to this upon construction
--        nil means no change to terrain
--      constructionResource = 0,1,2 or nil
--        change the terrain resource to this upon construction
--        nil means no change to the resource
--        (ignored if grassland is the baseTerrain of the tile,
--         after the constructionBaseTerrain change is made)
--      destructionBaseTerrain = baseTerrainObject or nil
--        change the base terrain of the tile to this
--        when the target is destroyed
--        nil means no change to the terrain
--      destructionResource = 0,1,2, or nil
--        change the terrain resource to this upon target destruction
--        nil means no change to the resource
--        (ignored if grassland is the baseTerrain of the tile,
--         after the destructionBaseTerrain change is made)
--      targetUnitType = unitTypeObject or true or nil
--        if unitTypeObject, create a target with that unit type
--        on this tile.  nil means no target on this tile.
--        true means create a 'target' without a unit, for example
--        if you want to tie a terrain change to whether or not
--        the item is still in the city
--      captureWithCity = bool or nil
--        if true, the target on this tile is caputured with the city
--        provided the item is still intact.  False or nil means it
--        is destroyed instead.  For basicStrategicFunctions,
--        if any target is destroyed, the item is removed, so all
--        other targets will be destroyed.  If you want a target
--        to be capured, all the targets for the item should be true
--    }
--  return false if the item can't be constructed in the city
--  (this will only be called on items where isStrategicItemFn(item) returns true)

local function tileEffectsFunction(city,item)
  --[[
  return {
    {
      tile = civ.getTile(0,0,0),
      constructionBaseTerrain = civ.getBaseTerrain(0,0),
      constructionResource = nil,
      destructionBaseTerrain = civ.getBaseTerrain(0,1),
      destructionResource = nil,
      targetUnitType = civ.getUnitType(0),
      captureWithCity = false,
    },
    {
      tile = civ.getTile(0,0,0),
      constructionBaseTerrain = nil,
      constructionResource = 1,
      destructionBaseTerrain = nil,
      destructionResource = 0,
      targetUnitType = nil,
      captureWithCity = false,
    },
  }
  --]]
  return false
end



-- use the basic constructor
local constructedTargetLostFunction,
  constructedTargetVerificationFunction,
  constructedRegisterSupplementalConditionsFunction,
  constructedCityProductionEventFunction =
  strat.basicStrategicFunctions(isStrategicItem,tileEffectsFunction)



-- We need to create the target when an item is
-- produced (perhaps at other times as well)
function discreteEvents.onCityProduction(city,item)
  constructedCityProductionEventFunction(city,item)
end



-- The registered is run (once) when a target
-- is destroyed
--[[
local function targetLostFunction(target)
  
end
]]

strat.registerTargetLostFn(constructedTargetLostFunction)



-- strat.verifyTarget(target) reviews a target, and determines if it is
-- still "valid". Returns true if it is, and false if it is not.
-- If false is returned, the target is destroyed.
-- The target is automatically destroyed if the target unit is missing,
-- a city is registered for the target, but the city doesn't exist,
-- if there is an improvement (or wonder) registered, but the registered
-- city no longer has that improvement or if the registered city has
-- a different owner than the target, and the target is not captured
-- with the city (if it is captured with the city, but ownerhsip hasn't
-- changed yet, it is done at this time).

-- Add additional target verification steps in the function below
-- return true if the target should remain in place, and
-- return false if it should be destroyed
--[[
local function targetVerificationFunction(target)
  return true
end
--]]
strat.registerTargetVerificationFn(constructedTargetVerificationFunction)

-- register the supplemental building conditions
constructedRegisterSupplementalConditionsFunction()

-- This function governs what happens when a target is
-- created or captured
-- while there are other units on the tile
-- The targets have changed owners when this function is executed
local function moveUnitsAfterTargetCreatedOrCapturedFunction(tile,target)
  local owner = target.owner
  for unit in tile.units do
    if unit.owner ~= owner then
      gen.moveUnitAdjacent(unit)
    end
  end
end

strat.registerMoveUnitsAfterTargetCreatedOrCapturedFn(moveUnitsAfterTargetCreatedOrCapturedFunction)


