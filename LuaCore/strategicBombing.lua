-- A module for implementing strategic bombing (or similar actions)
-- by linking units to terrain types and city improvements
--


-- data about target units
local targetData = "state not linked"

-- data about target groups
local groupData = "state not linked"

local gen = require("generalLibrary")
local text = require("text")
local discreteEvents = require("discreteEventsRegistrar")

local strat = {}

local function linkState(tableInStateTable)
    local stratState = {}
    if type(tableInStateTable) == "table" then
        stratState = tableInStateTable
    else
        error("strategicBombing.linkState: linkState takes a table as an argument.")
    end
    stratState.targetData = stratState.targetData or {}
    targetData = stratState.targetData
    stratState.groupData = stratState.groupData or {}
    groupData = stratState.groupData
end

function discreteEvents.linkStateTableToModules(state,stateTableKeys)
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
--      targetUnitId = integer or nil, -- unitID of the actual unit acting as the target, nil if unit missing
--      targetUnitTypeId = integer, -- unitTypeID of the target unit
--      tileId = integer, -- ID of the tile the target is on, using gen.getTileID, gen.getTileFromID
--      ownerId = integer, -- ID of the tribe that owns the target
--      targetGroupId = integer, or nil -- ID of the targetGroup the target belongs to, if applicable
--      cityTileId = integer, -- ID of the associated city
--      improvementId = integer or nil, -- ID of the associated improvement, if applicable
--      wonderId = integer or nil, -- ID of the associated wonder, if applicable
--      class = string -- a string to differentiate between different "types" of target
--

-- targetObject
--  properties
--  id = integer, -- id of the targetObject
--  unit = unitObject or nil, -- the unit that is acting as the target
--                              -- nil if the unit has been destroyed/disbanded
--                              -- verify against location/owner/etc
--  targetGroup = targetGroupObject or nil, -- the target group the target is part of
--  owner = tribe -- the tribe that owns the target
--  city = cityObject -- the city the target is associated with
--  improvement = improvementObject or wonderObject or nil -- the associated improvement/wonder, if applicable
--  location = tileObject
--  class = string -- a string to differentiate between different "types" of target
--
--

-- groupDatum
-- data about a particular target group
-- groupData[id] = groupDatum
--
--  groupDatum = {
--    id = integer,
--    targetIdList



-- The function to execute when a target is lost
-- 
local targetLostFn = function(target) end

function strat.registerTargetLostFn(tLostFn)
  if type(tLostFn) ~= "function" then
    error("strategicBombing.registerTargetLostfn: argument must be a function.  Received: "..tostring(tLostFn))
  else
    targetLostFn = tLostFn
  end      
end

-- a function to execute whenever a targetGroup is updated
local targetGroupUpdateFn = function(targetGroup) end

function strat.registerTargetGroupUpdateFn(tGUpdateFn)
    if type(tGUpdateFn) ~= "function" then
      error("strategicBombing.registerTargetGroupUpdateFn: argument must be a function.  Received: "..tostring(tGUpdateFn))
    else
      targetGroupUpdateFn = tGUpdateFn
    end
end



local function targetExists(targetDatum)
    if not targetDatum then
        return false
    end
    local targetUnit = targetDatum.targetUnitId and civ.getUnit(targetDatum.targetUnitId)
    return targetUnit.type.id == targetDatum.targetUnitTypeId 
            and gen.getTileID(targetUnit.location) == targetDatum.tileId 
            and targetUnit.owner.id == targetDatum.ownerId
end

local targetObjectMetatable = {
    __index = function(targetObject,key)
        local targetID = rawget(targetObject["targetID"])
        local targetDatum = targetData[targetID] or {id = targetID}
        if not targetExists(targetDatum) then
            return nil
        end
        if key == "id" then
            return targetID
        elseif key == "unit" then
            return civ.getUnit(targetDatum.targetUnitId)
        elseif key == "targetGroup" then
            return strat.getTargetGroup(targetDatum.targetGroupId)
        elseif key == "owner" then
            return civ.getTribe(targetDatum.ownerId)
        elseif key == "city" then
            return gen.getTileFromId(targetDatum.cityTileId).city
        elseif key == "improvement" then
            if targetDatum.improvementId then
                return civ.getImprovement(targetDatum.improvementId)
            elseif targetDatum.wonderId then
                return civ.getWonder(targetDatum.wonderId)
            else
                return nil
            end
        elseif key == "location" then
          return gen.getTileFromId(targetDatum.tileId)
        elseif key == "class" then
          return targetDatum.class
        else
            error("A targetObject does not have a value for the "..tostring(key).." key.")
        end
    end,

    __newindex = function(targetObject,key,newValue)
        error("targetObject keys can not be set.")
    end,
    __tostring = function(targetObject)
        return "<Target Object for city: "..tostring(targetObject.city and targetObject.city.name)..
          " improvement: "..tostring(targetObject.improvement and targetObject.improvement.name)..
          " target unit: "..tostring(targetObject.unit)..
          " at location: "..text.coordinates(targetObject.location)..
          " with class: "..tostring(targetObject.class)..">"
    end
    
}
targetObjectMetatable.__eq = function(thisTable,anotherTable)
    return type(anotherTable) == "table" and 
      getmetatable(anotherTable) == targetObjectMetatable and
      rawget(anotherTable,"targetID") == rawget(thisTable,"targetID")
end


local function isTarget(possibleTarget)
  return type(possibleTarget) == "table" and getmetatable(possibleTarget) ==targetObjectMetatable
end

--local function destroyTarget(


local function createTarget(tile,targetType,city,improvement,targetGroup,class)
    class = class or "default"
    local targetId = #targetData+1
    local targetDatum = {id = targetId}
    targetData[targetId] = targetDatum
    local owner = city.owner
    local targetUnit = civ.createUnit(targetType, owner, tile)
    targetDatum.targetUnitId = targetUnit.id
    targetDatum.targetUnitTypeId = targetType.id
    targetDatum.tileId = gen.getTileId(tile)
    targetDatum.ownerId = owner.id
    targetDatum.targetGroupId = targetGroup and targetGroup.id
    targetDatum.cityTileId = gen.getTileId(city.location)
    targetDatum.class = class
    if civ.isImprovement(improvement) then
      targetDatum.improvementId = improvement.id
    elseif civ.isWonder(improvement) then
      targetDatum.wonderId = improvement.id
    end
    local target = {targetID = targetId}
    setmetatable(target, targetObjectMetatable)
    return target
end

local function getTarget(id)
  if targetData[id] then
    local target = {targetID = id}
    setmetatable(target,targetObjectMetatable)
    return target
  else
    return nil
  end    
end

local function destroyTarget(target)
    local targetID = target.id
    targetLostFn(target)
    if target.unit then
      gen.deleteUnit(target.unit)
    end
    targetData[targetID] = nil
    
end

local function changeTargetOwner(target,newOwner)
    local targetId = target.id
    local targetDatum = targetData[targetId]
    targetDatum.ownerId = newOwner.id
    
    
end
