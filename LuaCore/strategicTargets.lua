--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- A module for implementing strategic bombing (or similar actions)
-- by linking units to terrain types and city improvements
--

local moduleName = "strategicTargets"

-- data about target units
local targetData = "state not linked"


-- if a unit is acting as a target, retrieves the id of the target
local unitIdToTargetId = "state not linked"


local gen = require("generalLibrary"):minVersion(1)
local text = require("text")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local canBuild = require("canBuild"):minVersion(2)

local strat = {}
gen.versionFunctions(strat,versionNumber,fileModified,"LuaCore".."\\".."strategicTargets.lua")

local function linkState(tableInStateTable)
    local stratState = nil
    if type(tableInStateTable) == "table" then
        stratState = tableInStateTable
    else
        error(moduleName..".linkState: linkState takes a table as an argument.")
    end
    stratState.targetData = stratState.targetData or {}
    targetData = stratState.targetData
    stratState.unitIdToTargetId = stratState.unitIdToTargetId or {}
    unitIdToTargetId = stratState.unitIdToTargetId
end

function discreteEvents.linkStateToModules(state,stateTableKeys)
    local keyName = "strategicBombing"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    state[keyName] = state[keyName] or {}
    linkState(state[keyName])
end

-- targetDatum
--  data about a particular target
--  targetData[id] = targetDatum
--
--  targetDatum = {
--      id = integer,
--      targetUnitId = integer or nil, -- unitId of the actual unit acting as the target, nil if target doesn't have an associated unit
--          (e.g. tying terrain to improvement without target to kill
--      targetUnitTypeId = integer or nil, -- unitTypeId of the target unit, nil if no associated unit
--      tileId = integer or nil, -- Id of the tile the target is on, using gen.getTileId, gen.getTileFromId
--          nil if no associated unit
--      ownerId = integer, -- Id of the tribe that owns the target
--      customData = stateSavable item (item is string, number or table of strings and numbers)
--      cityTileId = integer or nil, -- Id of the associated city, nil if none registered
--      improvementId = integer or nil, -- Id of the associated improvement, if applicable
--      wonderId = integer or nil, -- Id of the associated wonder, if applicable
--      class = string -- a string to differentiate between different "types" of target
--      captureWithCity = bool -- if true, target is captured if the registered
--                              -- city is captured, if false, it is destroyed
--

-- targetObject
-- table/metatable, table = {targetId = id}
--  properties
--  active = boolean -- true if targetLostFn hasn't been run yet, false if it has
--  id = integer, -- id of the targetObject
--  unit = unitObject or nil, -- the unit that is acting as the target
--                              -- nil if the unit has been destroyed/disbanded, or if no associated unit
--                              -- verify against location/owner/etc
--  hasRegisteredUnit = boolean -- returns true if there is a unit
--                      registered with this target, false if not
--  owner = tribeObject -- the tribe that owns the target
--  city = cityObject or nil -- the city associated with the target
--                    -- nil means no city on the registered tile
--                    -- (or no registered tile)
--  cityLocation = tileObject or nil -- the tile for the city associated
--                    -- with the target, or nil if none registered
--  improvement = improvementObject or wonderObject or nil
--                    -- returns the improvement/wonder registered with
--                    -- the targetObject, or nil if none was registered
--  customData = string, number, nil or (nested) table of strings, numbers, nil
--  targetLocation = tileOjbect or nil -- the tile where the target is located
--                  -- nil if there is no unit registered for the tile
--  captureWithCity = bool -- true if the target is captured with the city
--  class = string or nil  -- a string to differentiate between different
--                      -- "types" of target



-- The function to execute when a target is lost
-- 
local targetLostFn = function(target) end

function strat.registerTargetLostFn(tLostFn)
  if type(tLostFn) ~= "function" then
    error(moduleName..".registerTargetLostfn: argument must be a function.  Received: "..tostring(tLostFn))
  else
    targetLostFn = tLostFn
  end      
end

-- function to check if a target should remain standing
local targetVerificationFn = function(target) return true end

function strat.registerTargetVerificationFn(tVerifyFn)
  if type(tVerifyFn) ~= "function" then
    error(moduleName..".registerTargetVerificationFn: argument must be a function.  Received: "..tostring(tVerifyFn))
  else
    targetVerificationFn = tVerifyFn
  end
end

-- this moves unit on a tile after a target is captured by another player
-- updated elsewhere to a target being created as well
local moveUnitsAfterTargetCapturedFn = function(tile,target)
  local newOwner = target.owner
  for unit in tile.units do
    if unit.owner ~= newOwner then
      gen.moveUnitAdjacent(unit)
    end
  end
end

-- registers the function for moving units after a target
-- is captured
function strat.registerMoveUnitsAfterTargetCreatedOrCapturedFn(mUnitsFn)
  if type(mUnitsFn) ~= "function" then
    error(moduleName..".registerMoveUnitsAfterTargetCreatedOrCapturedFn: argument must be a function.  Received: "..tostring(mUnitsFn))
  else
    moveUnitsAfterTargetCapturedFn = mUnitsFn
  end
end


-- strat.destroyTarget(target)
-- This function destroys the target object.  
function strat.destroyTarget(target)
  if not target.active then
    -- target has already been destroyed
    return
  end
  -- apply effects of target being lost
  targetLostFn(target)
  local targetId = target.id
  local targetUnit = target.unit
  -- delete the target unit if it exists
  if target.unit then
    gen.deleteUnit(target.unit)
  end
  -- set the target id to -1, just in case there
  -- is another attempt to use the target
  rawset(target,"targetId",-1)
  -- delete the target data (this will also deactivate
  -- the target object)
  targetData[targetId] = nil 
  for otherTarget in strat.iterateTargets() do
    if otherTarget.active then
      strat.verifyTarget(otherTarget)
    end
  end
end



-- strat.verifyTarget(target)
-- If a target should be destroyed
--    e.g. unit missing, city missing, improvement missing
--    then the target is destroyed and false is returned
-- otherwise, true is returned
-- if the target should be captured, but hasn't been, change
-- the owner to city's owner
-- if the target should be destroyed upon capture, but hasn't been,
-- it is destroyed
function strat.verifyTarget(target)
  if target.hasRegisteredUnit and not target.unit then
    -- the target unit is missing, so destroy the target
    strat.destroyTarget(target)
    return false
  elseif target.cityLocation and not target.cityLocation.city then
    -- the target has a registered city location, but there
    -- is no city.  Assume city destroyed, and destroy target
    strat.destroyTarget(target)
    return false
  elseif target.city and target.improvement then
    -- the target has an associated city and an associated improvement
    if civ.isImprovement(target.improvement) and not target.city:hasImprovement(target.improvement) then
      -- city doesn't have the specified improvement
      strat.destroyTarget(target)
      return false
    elseif civ.isWonder(target.improvement) and target.improvement.city ~= target.city then
      -- city doesn't have the specified wonder
      strat.destroyTarget(target)
      return false
    end
  elseif not targetVerificationFn(target) then
    -- target doesn't meet custom verification standards
    strat.destroyTarget(target)
    return false
  end
  if target.cityLocation and target.city.owner ~= target.owner then
    -- city has been captured, but target has not
    if target.captureWithCity then
      target.owner = target.city.owner
    else
      strat.destroyTarget(target)
      return false
    end
  end
  return true
end


local targetObjectMetatable = {
    __index = function(targetObject,key)
        local targetId = rawget(targetObject,"targetId")
        local targetDatum = targetData[targetId] or {id = targetId}
        if key == "id" then
            return targetId
        elseif key == "unit" then
          local targetUnit = targetDatum.targetUnitId and civ.getUnit(targetDatum.targetUnitId)
          if targetUnit then
            if targetUnit.type.id == targetDatum.targetUnitTypeId
            and gen.getTileId(targetUnit.location) == targetDatum.tileId
            and targetUnit.owner.id == targetDatum.ownerId then
              return targetUnit
            else
              return nil
            end            
          else
            return nil
          end
        elseif key == "owner" then
            return civ.getTribe(targetDatum.ownerId)
        elseif key == "hasRegisteredUnit" then
          if targetDatum.targetUnitId then
            return true
          else
            return false
          end          
        elseif key == "city" then
            if targetDatum.cityTileId then
              return gen.getTileFromId(targetDatum.cityTileId).city
            else
              return nil
            end
        elseif key == "improvement" then
            if targetDatum.improvementId then
                return civ.getImprovement(targetDatum.improvementId)
            elseif targetDatum.wonderId then
                return civ.getWonder(targetDatum.wonderId)
            else
                return nil
            end
        elseif key == "cityLocation" then
            if targetDatum.cityTileId then
              return gen.getTileFromId(targetDatum.cityTileId)
            else
              return nil
            end
        elseif key == "class" then
          return targetDatum.class
        elseif key == "active" then
          if targetData[rawget(targetObject,"targetId")] then
            -- targetId is set to -1 when the target is destroyed
            -- and also, the targetData is cleared at that time
            -- since there is never a negative key in the targetData,
            -- this determines if the targetObject is still active
            return true
          else
            return false
          end
        elseif key == "captureWithCity" then
          return targetDatum.captureWithCity
        elseif key == "customData" then
          return targetDatum.customData
        elseif key == "targetLocation" then
          return targetDatum.tileId and gen.getTileFromId(targetDatum.tileId)
        else
            error("A targetObject does not have a value for the "..tostring(key).." key.")
        end
    end,

    __newindex = function(targetObject,key,newValue)
        local targetId = rawget(targetObject,"targetId")
        local targetDatum = targetData[rawget(targetObject,"targetId")]
        if not targetDatum then
          error("Attempt to set target object key \""..key.."\", but the target object is not active.")
        end
        if key == "owner" then
          if not civ.isTribe(newValue) then
            error("target object \"owner\" must be set to a tribeObject.  Received: "..tostring(newValue))
          end
          local targetUnit = targetObject.unit
          if targetUnit then
            targetUnit.owner = newValue
          end
          targetDatum.ownerId = newValue.id
        elseif key == "captureWithCity" then
          if type(newValue) ~= "boolean" then
            error("target object key \"captureWithCity\" must be set to a boolean.  Received: "..tostring(newValue))
          end
          targetDatum.captureWithCity = newValue
        else
          error("targetObject key \""..key.."\" can not be set.")
        end
    end,
    __tostring = function(targetObject)
        return "<Target Object for city: "..tostring(targetObject.city and targetObject.city.name)..
          " improvement: "..tostring(targetObject.improvement and targetObject.improvement.name)..
          " target unit: "..tostring(targetObject.unit)..
          " at location: "..tostring(targetObject.targetLocation and text.coordinates(targetObject.targetLocation))..
          " with class: "..tostring(targetObject.class)..">"
    end
    
}
targetObjectMetatable.__eq = function(thisTable,anotherTable)
    return type(anotherTable) == "table" and 
      getmetatable(anotherTable) == targetObjectMetatable and
      rawget(anotherTable,"targetId") == rawget(thisTable,"targetId")
end



local function isTarget(possibleTarget)
  return type(possibleTarget) == "table" and getmetatable(possibleTarget) ==targetObjectMetatable
end
strat.isTarget = isTarget

-- strat.createTarget(tile,targetType,cityOrOwner,class="default",improvement=nil,customData=nil,captureWithCity=false)
-- creates a target on the supplied tile, with unit type given by targetType,
-- associated with the provided city (or no city, but just an owner if a tribe is supplied instead)
-- an improvement or wonder that the target is associated with
-- (if a city is specified, the target will be destroyed if the
-- city no longer has that improvement)
-- if nil is supplied, the target is not associated with any particular
-- improvement
-- class is a string to facilitate giving targets different 'types'
-- customData is a string, number, nil or (nested) table of string, number, nil.
-- captureWithCity is a boolean, true if the target is captured when
-- a city is captured, and false if it is destroyed when the city
-- is captured

local function createTarget(tile,targetType,city,class,improvement,customData,captureWithCity)
    if not civ.isTile(tile) then
      error(moduleName..".createTarget: first argument must be a tileObject.  Received: "..tostring(tile))
    elseif targetType and not civ.isUnitType(targetType) then
      error(moduleName..".createTarget: second argument must be a unitTypeObject or nil.  Received: "..tostring(targetType))
    elseif not civ.isCity(city) and not civ.isTribe(city) then
      error(moduleName..".createTarget: third argument must be a cityObject or a tribeObject.  Received: "..tostring(city))
    elseif type(class) ~= "string" and type(class) ~= nil then
      error(moduleName..".createTarget: fourth argument must be a string or nil.  Received: "..tostring(class))
    elseif type(improvement) ~= "nil" and not civ.isImprovement(improvement) and not civ.isWonder(improvement) then
      error(moduleName..".createTarget: fifth argument must be an improvementObject, wonderObject, or nil.  Received: "..tostring(improvement))
    elseif not gen.isStateSavable(customData) then
      error(moduleName..".createTarget: sixth argument must be a string, a number, nil, or a (possibly nested) table of strings, numbers, and nils.  Received: "..tostring(customData))
    elseif type(captureWithCity) ~= "boolean" then
      error(moduleName..".createTarget: seventh argument must be a boolean or nil.  Received: "..tostring(captureWithCity))
    end
    captureWithCity = captureWithCity or false
    class = class or "default"
    local targetId = #targetData+1
    local targetDatum = {id = targetId}
    targetData[targetId] = targetDatum
    local owner = nil
    if civ.isCity(city) then
      owner = city.owner
      targetDatum.cityTileId = gen.getTileId(city.location)
    else
      owner = city
    end
    if targetType then
      local targetUnit = civ.createUnit(targetType, owner, tile)
      targetUnit.homeCity = nil
      targetUnit.veteran = true
      targetDatum.targetUnitId = targetUnit.id
      targetDatum.targetUnitTypeId = targetType.id
      targetDatum.tileId = gen.getTileId(tile)
    end
    targetDatum.ownerId = owner.id
    targetDatum.class = class
    targetDatum.customData = customData
    targetDatum.captureWithCity = captureWithCity
    if civ.isImprovement(improvement) then
      targetDatum.improvementId = improvement.id
    elseif civ.isWonder(improvement) then
      targetDatum.wonderId = improvement.id
    end
    local target = {targetId = targetId}
    setmetatable(target, targetObjectMetatable)
    if target.targetLocation then
      moveUnitsAfterTargetCapturedFn(target.targetLocation,target)
    end
    return target
end
strat.createTarget = createTarget

local function getTarget(id)
  if targetData[id] then
    local target = {targetId = id}
    setmetatable(target,targetObjectMetatable)
    return target
  else
    return nil
  end    
end
strat.getTarget = getTarget

-- strat.iterateTargets(filterItem)
-- if filterItem is nil, iterate through all targets
-- if filterItem is a city, return only targets associated with that city
-- if filterItem is a tribe, return only targets owned by that tribe
-- if filterItem is a string, return only targets with that class
-- if filterItem is a unitType, return only targets of that unit type (including active targets where the unit has been destroyed
-- if filterItem is a tile, return targets on that tile
-- if filterItem is an improvement or wonder, return targets associated with that improvement/wonder

function strat.iterateTargets(filterItem)
  local filterKey = nil
  local filterValue = nil
  if type(filterItem) == "nil" then
    
  elseif civ.isCity(filterItem) then
    filterKey = "cityTileId"
    filterValue = gen.getTileId(filterItem.location)
  elseif civ.isTribe(filterItem) then
    filterKey = "ownerId"
    filterValue = filterItem.id
  elseif type(filterItem) == "string" then
    filterKey = "class"
    filterValue = filterItem
  elseif civ.isUnitType(filterItem) then
    filterKey = "targetUnitTypeId"
    filterValue = filterItem.id
  elseif civ.isTile(filterItem) then
    filterKey = "tileId"
    filterValue = gen.getTileId(filterItem)
  elseif civ.isImprovement(filterItem) then
    filterKey = "improvementId"
    filterValue = filterItem.id
  elseif civ.isWonder(filterItem) then
    filterKey = "wonderId"
    filterValue = filterItem.id
  else
    error(moduleName..".iterateTargets: "..tostring(filterItem).." is an invalid filter.  A filter can be nil, a cityObject, tribeObject, string, unitTypeObject, tileObject, improvementObject, wonderObject.")
  end
  if filterItem == nil or filterKey == nil or filterValue == nil then
    -- return everything
    return coroutine.wrap(function()
        for key,datum in pairs(targetData) do
          coroutine.yield(getTarget(key))
        end
      end)
  end  
  return coroutine.wrap(function()
      for key,datum in pairs(targetData) do
        if datum[filterKey] == filterValue then
          coroutine.yield(getTarget(key))
        end        
      end
    end)
end

  

function discreteEvents.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
  for id,datum in pairs(targetData) do
    if loser.id == datum.targetUnitId and gen.getTileId(loser.location) == datum.tileId and loser.owner.id == datum.ownerId then
      strat.destroyTarget(getTarget(id))
    end
  end
end

function discreteEvents.onCityTaken(city,defender)
  local targetsCaptured = {}
  local tCTdx = 1
  for target in strat.iterateTargets(city) do
    -- on city taken event happens after city improvements are
    -- destroyed for city conquest, so verifying the target 
    -- will destroy it if the improvement is missing, or
    -- if it is destroyed on capture, and change the owner
    -- if it is captured with the city
      local targetCaptured = strat.verifyTarget(target)
      if targetCaptured then
        targetsCaptured[tCTdx] = target
        tCTdx = tCTdx+1
      end       
  end
  for _,target in pairs(targetsCaptured) do
    if target.targetLocation then
      moveUnitsAfterTargetCapturedFn(target.targetLocation,target)
    end
  end  
end

function discreteEvents.onCityDestroyed(city)
    for target in strat.iterateTargets(city) do
      strat.destroyTarget(target)
    end
end

function discreteEvents.onTribeTurnBegin(turn,tribe)
  for target in strat.iterateTargets(tribe) do
    strat.verifyTarget(target)
  end
end

-- strat.basicStrategicFunctions(isStrategicItemFn,tileEffectsFn)
--  --> targetLostFunction(target) --> void,
--      targetVerificationFunction(target) --> void,
--      registerSupplementalConditionsFunction() --> void,
--      cityProductionEventFunction(city,item) --> void
--
-- isStrategicItemFn
--    function(item) --> boolean
--      item: improvement or wonder
--      return true if the item is strategic
--      (creates targets/changes terrain upon construction/destruction)
--      false otherwise
--
-- tileEffectsFn(city,item) --> false or table of
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


-- target customData
--  Custom data is a list of tiles to change
--  when the target is destroyed, and the
--  information for what to change it to
--    {[tileID of the tile to change] = 
--                  {baseId = destroyed base terrain.type,
--                  resource = 0,1,2, the resource the terrain should have}

function strat.basicStrategicFunctions(isStrategicItemFn,
    tileEffectsFn)
  local function targetLostFunction(target)
    local customData = target.customData
    if target.city and civ.isImprovement(target.improvement) then
      target.city:removeImprovement(target.improvement)
    elseif target.city and civ.isWonder(target.improvement) then
      target.improvement.city = nil
    end
    for tileId, info in pairs(customData) do
      local tile = gen.getTileFromId(tileId)
      if info.baseId then
        tile.baseTerrain = civ.getBaseTerrain(tile.z,info.baseId)
      end
      if info.resource and tile.baseTerrain.type ~= 2 then
        tile.terrain = civ.getTerrain(tile.z,tile.baseTerrain.type,info.resource)
      end
    end
  end
  local function targetVerificationFn(target)
    return true
  end
  local function registerSupplementalConditionsFunction()
    for i=0,39 do
      local item = civ.getImprovement(i)
      if isStrategicItemFn(item) then
        canBuild.registerSupplementalCondition(item,
          function(dBf,city,item)
            return (not isStrategicItemFn(item) or (not not tileEffectsFn(city,item)))
          end
        )
      end
    end
    for i=0,27 do
      local item = civ.getWonder(i)
      if isStrategicItemFn(item) then
        canBuild.registerSupplementalCondition(item,
          function(dBf,city,item)
            return (not isStrategicItemFn(item) or (not not tileEffectsFn(city,item)))
          end
        )
      end
    end
  end
  local function cityProductionEventFunction(city,item)
    if not isStrategicItemFn(item) then
      return
    end
    local tileList = tileEffectsFn(city,item)
    if tileList == false then
      text.simple("There is no place to build our "..item.name..".  The shields have been returned to the production box.")
      if civ.isImprovement(item) then
        city:removeImprovement(item)
        city.shields = city.shields + 10*item.cost
      else
        item.city = nil
        city.shields = city.shields + 10*item.cost
      end
      return
    end
    local customData = {}
    local targetsToCreateList = {} -- entries: {unitType,tile,captureWithCity}
    for index,info in pairs(tileList) do
      local tile = info.tile
      local tileId = gen.getTileId(tile)
      customData[tileId] = {}
      if info.constructionBaseTerrain 
      and civ.isBaseTerrain(info.constructionBaseTerrain) then
        tile.baseTerrain = info.constructionBaseTerrain
      elseif info.constructionBaseTerrain then
        error("basicStrategicFunctions: the tileEffectsFn for city: "..tostring(city).." and item: "..tostring(item).." returned an invalid value for index "..tostring(index)..".  The key 'constructionBaseTerrain' should be either nil or a baseTerrainObject.  Received: "..tostring(info.constructionBaseTerrain))
      end
      if info.constructionResource ~= nil and info.constructionResource ~= 0
      and info.constructionResource ~= 1 and info.constructionResource ~= 2 then
        error("basicStrategicFunctions: the tileEffectsFn for city: "..tostring(city).." and item: "..tostring(item).." returned an invalid value for index "..tostring(index)..".  The key 'constructionResource' should be nil, 0, 1, or 2.  Received: "..tostring(info.constructionResource))
      end
      if info.constructionResource and tile.baseTerrain.type ~= 2 then
        tile.terrain = tile.baseTerrain:getTerrain(info.constructionResource)
      end
      if info.destructionBaseTerrain 
      and civ.isBaseTerrain(info.destructionBaseTerrain) then
        customData[tileId].baseId = info.destructionBaseTerrain.type
      elseif info.destructionBaseTerrain then
        error("basicStrategicFunctions: the tileEffectsFn for city: "..tostring(city).." and item: "..tostring(item).." returned an invalid value for index "..tostring(index)..".  The key 'destructionBaseTerrain' should be either nil or a baseTerrainObject.  Received: "..tostring(info.destructionBaseTerrain))
      end
      if info.destructionResource ~= nil and info.destructionResource ~= 0
      and info.destructionResource ~= 1 and info.destructionResource ~= 2 then
        error("basicStrategicFunctions: the tileEffectsFn for city: "..tostring(city).." and item: "..tostring(item).." returned an invalid value for index "..tostring(index)..".  The key 'destructionResource' should be nil, 0, 1, or 2.  Received: "..tostring(info.destructionResource))
      end
      if info.destructionResource and tile.baseTerrain.type ~= 2 then
        customData[tileId].resource = info.destructionResource
      end
      if info.targetUnitType then
        targetsToCreateList[#targetsToCreateList+1] = {info.targetUnitType, tile,info.captureWithCity}
      end
    end
    if #targetsToCreateList == 0 then
      error("basicStrategicFunctions: the tileEffectsFn for city: "..tostring(city).." and item: "..tostring(item).."  did not produce any targets.  At least one target is required, but you can set the key 'targetUnitType' to true if you do not want a unit on the map that can be attacked.")
    end
    for _,info in pairs(targetsToCreateList) do
      local unitType = info[1]
      if unitType == true then
        unitType = nil
      end
      createTarget(info[2],unitType,city,item.name,item,customData,info[3])
    end
  end
  return targetLostFunction, targetVerificationFn,
    registerSupplementalConditionsFunction, cityProductionEventFunction
end










return strat

