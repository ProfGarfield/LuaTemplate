-- A module for implementing strategic bombing (or similar actions)
-- by linking units to terrain types and city improvements
--


-- data about target units
local targetData = "state not linked"

-- data about target groups
local groupData = "state not linked"

local gen = require("generalLibrary")
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
--

-- targetObject
--  properties
--  id = integer, -- id of the targetObject
--  unit = unitObject or nil, -- the unit that is acting as the target
--                              -- nil if the unit has been destroyed/disbanded
--                              -- verify against location/owner/etc
--  targetGroup = targetGroupObject or nil, -- the target group the target is part of



