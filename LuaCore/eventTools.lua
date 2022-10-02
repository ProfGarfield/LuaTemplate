--  At the moment, this is believed to be unnecessary
--
-- This is a module that contains stuff to make other events work,
-- so as not to clutter the general library
local eventTools = {}

local eventToolsState = "state not linked"


local function linkState(stateTable)
    if type(stateTable) == "table" then
        eventToolsState = stateTable
    else
        error("eventTools.linkState: linkState takes a table as an argument.")
    end
    -- eventToolsState.activationUnitIDs[unitID] = true if the unit is an activation guarantor
    eventToolsState.activationUnitIDs = eventToolsState.activationUnitIDs or {}
    -- eventToolsState.tribeActivationUnit[tribeID] = unitID or nil
    -- gives the unit (if it exists) that is guaranteeing that the tribe will have an active unit
    eventToolsState.tribeActivationUnit = eventToolsState.tribeActivationUnit or {}
end
eventTools.linkState = linkState


-- requireIfAvailable(fileName) --> fileFound (bool), prefix (whatever is returned by a successful require, or nil)
local function requireIfAvailable(fileName)
    if package.loaded[fileName] then
        return true, require(fileName)
    else
        for _,searcher in ipairs(package.searchers) do
            local loader = searcher(fileName)
            if type(loader) == 'function' then
                return true, require(fileName)
            end
        end
        return false, nil
    end
end

local fileFound, discreteEvents = requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "eventToolsState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkState(state[keyName])
    end
end


local activationUnitType = nil

local noUnitWarningShown = false
-- set the unit type to be created for the unit that will
-- ensure a unit activation event will occur
local function setGuaranteeUnitActivationType(unitType)
    if unitType == nil then
        print("WARNING: setGuaranteeUnitActivationType was set to nil.  The functionality to guarantee that a tribe will have an active unit is disabled.  Some events may not work properly until a unit type is specified.")
        noUnitWarningShown = true
    elseif not civ.isUnitType(unitType) then
        error("setGuaranteeUnitActivationType: argument must be a unit type")
    end
    if civ.isUnit(unitType) and unitType.move == 0 then
        error("setGuaranteeUnitActivationType: unit must have movement allowance greater than 0.")
    end
    activationUnitType = unitType

end
eventTools.setGuaranteeUnitActivationType = setGuaranteeUnitActivationType

local activationGuaranteeUnitPlacementLocationFunction = function(tribe) error("eventTools: the function setGuaranteeActivationUnitLocationFunction has not been run.") end

local function setGuaranteeActivationUnitLocationFunction(func)
    activationGuaranteeUnitPlacementLocationFunction = func
end
eventTools.setGuaranteeActivationUnitLocationFunction = setGuaranteeActivationUnitLocationFunction


local function guaranteeUnitActivation(tribe)
    if activationUnitType == nil then
        if not noUnitWarningShown then
            print("WARNING: No unit type has been set for guaranteeing unit activation.  The functions to guarantee that a tribe will have an active unit has been disabled.  Use eventTools.setGuaranteeUnitActivationType(unitType) to set a unit.")
        end
        return
    end
    -- there is already an activation unit
    if eventToolsState.tribeActivationUnit and eventToolsState.tribeActivationUnit[tribe.id] and civ.getUnit(eventToolsState.tribeActivationUnit[tribe.id]) and civ.getUnit(eventToolsState.tribeActivationUnit[tribe.id]).owner == tribe and civ.getUnit(eventToolsState.tribeActivationUnit[tribe.id]).moveSpent==0 then
        return
    end
    if eventToolsState.tribeActivationUnit and eventToolsState.tribeActivationUnit[tribe.id] then
        local tribeID = tribe.id
        eventToolsState.activationUnitIDs[eventToolsState.tribeActivationUnit[tribeID]] = nil
        civ.deleteUnit(civ.getUnit(eventToolsState.tribeActivationUnit[tribeID]))
        eventToolsState.tribeActivationUnit[tribeID] = nil
    end
    local actUnit = civ.createUnit(activationUnitType,tribe,activationGuaranteeUnitPlacementLocationFunction(tribe))
    eventToolsState.tribeActivationUnit = eventToolsState.tribeActivationUnit or {}
    eventToolsState.activationUnitIDs = eventToolsState.activationUnitIDs or {}
    eventToolsState.tribeActivationUnit[tribe.id]=actUnit.id
    eventToolsState.activationUnitIDs[actUnit.id]=true
    ----print("units in tribe activation unit")
    --for tribeID,unitID in pairs(eventToolsState.tribeActivationUnit) do
    --    print(civ.getTribe(tribeID).name,civ.getUnit(unitID))
    --end
    ----print("units in activation unit IDs")
    --for unitID,__ in pairs(eventToolsState.activationUnitIDs) do
    --    print(civ.getUnit(unitID))
    --end
end
eventTools.guaranteeUnitActivation = guaranteeUnitActivation

local function guaranteeUnitActivationForNextActiveTribe(currentTribe)
    local currentTribeID = currentTribe.id
    for i=1,8 do
        if civ.getTribe((currentTribeID+i)%8).active then
            guaranteeUnitActivation(civ.getTribe((currentTribeID+i)%8))
            return
        end
    end
end
eventTools.guaranteeUnitActivationForNextActiveTribe = guaranteeUnitActivationForNextActiveTribe


local function unitActivation(unit,source)
    local tribeID = unit.owner.id
    if eventToolsState.tribeActivationUnit[tribeID] then
        eventToolsState.activationUnitIDs[eventToolsState.tribeActivationUnit[tribeID]] = nil
        civ.deleteUnit(civ.getUnit(eventToolsState.tribeActivationUnit[tribeID]))
        eventToolsState.tribeActivationUnit[tribeID] = nil
    end
end
eventTools.unitActivation = unitActivation


-- makes sure the unit activation table contains only references 
-- to the activationUnitType
-- all other unit references are deleted, and new
-- guarantee activation function calls are made
local function maintainUnitActivationTable()
    local activateTribe = {}
    for key,val in pairs(eventToolsState.activationUnitIDs) do
        if civ.getUnit(key) then
            activateTribe[civ.getUnit(key).owner.id] = true
        end
        if not (civ.getUnit(key) and civ.getUnit(key).type == activationUnitType) then
            -- not referencing an activation guarantee unit
            eventToolsState.activationUnitIDs[key] = nil
        end
        eventToolsState.activationUnitIDs[key] = nil
    end
    for key,val in pairs(eventToolsState.tribeActivationUnit) do
        if civ.getUnit(val) then
            activateTribe[key] = true
        end
        if not (civ.getUnit(val) and civ.getUnit(val).type == activationUnitType) then
            -- not referencing an activation guarantee unit
            eventToolsState.tribeActivationUnit[key] = nil
        end
    end
    for tribeID,__ in pairs(activateTribe) do
        guaranteeUnitActivation(civ.getTribe(tribeID))
    end
end
eventTools.maintainUnitActivationTable= maintainUnitActivationTable

local function unitDeletion(dyingUnit)
    if eventToolsState.activationUnitIDs[dyingUnit.id] then
        eventToolsState.activationUnitIDs[dyingUnit.id] = nil
        eventToolsState.tribeActivationUnit[dyingUnit.owner.id] = nil
    end
    guaranteeUnitActivation(dyingUnit.owner)
end
eventTools.unitDeletion = unitDeletion

return eventTools
