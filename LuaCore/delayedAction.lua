
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
local gen =  require("generalLibrary"):minVersion(1)
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."delayedAction.lua")

-- A module for specifying an action which might have to wait until
-- a different player's turn, (or, a turn at some point in the future)
-- 
-- Functions that can be delayed will be provided to this module in
-- a table indexed by strings
-- These functions will take a table as their argument.
-- The keys to the argument table must be strings or numbers,
-- and the values must be strings, numbers, or tables
-- (and each table must only have strings, numbers, and tables)
--
-- usage:
-- delay = require("delayedAction")
--
--  To enable a function to be delayed
-- delay.makeFunctionDelayable(functionNameString,function)
--
-- To delay a function use one of these two functions
--  delay.doInFuture(functionNameString,argumentTable,turn,tribeID=-1)
--      performs an action specified by the functionNameString
--      and the argumentTable, on the turn specified
--      happens after production of the tribe associated with tribeID,
--      or onTurn, if submitted tribeID is -1
--
-- delay.doNextOpportunity(functionNameString,argumentTable={},tribeOrTribeID=-1)
--      performs a delayed action the next time a tribe is active, or immediately
--      if the tribe is the currently active tribe.  If no tribe is specified,
--      or the tribeID specified is -1,
--      the action will be performed with the onTurn actions for the next turn
--      if no argumentTable is specified, an empty table is generated

local delayedAction = {}
gen.versionFunctions(delayedAction,versionNumber,fileModified,"LuaCore".."\\".."delayedAction.lua")

local delayedActionState = "state not linked"
local savedActions = "state not linked"

-- a savedAction is a table with keys
--      .func = string
--          key of delayableFunctionsTable for the function we want
--      .arguments = table of strings, numbers, tables
--          argument to be fed to the function
--      .turn = integer
--          the turn the action will take place
--      .tribeID = integer in -1 to 7
--          the id of the tribe where this action will take place,
--          or onTurn if the id is -1

local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        delayedActionState = tableInStateTable
    else
        error("linkState: linkState takes a table as an argument.")
    end
    delayedActionState.savedActions = delayedActionState.savedActions or {}
    savedActions = delayedActionState.savedActions
end
delayedAction.linkState = linkState

local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "delayedAction"
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




local delayableFunctionsTable = {}

local function makeFunctionDelayable(key,func)
    if type(key) ~="string" then
        error("makeFunctionDelayable: first argument must be a string")
    elseif type(func) ~= "function" then
        error("makeFunctionDelayable: second argument must be a function")
    end
    if delayableFunctionsTable[key] then
        error("makeFunctionDelayable: the key "..key.." has been used for more than one delayable function.")
    end
    delayableFunctionsTable[key] = func
end
delayedAction.makeFunctionDelayable = makeFunctionDelayable

local function makeTableOfFunctionsDelayable(tableOfDelayableFunctions)
    local function mFD(key,func)
        if type(key) ~="string" then
            error("makeTableOfFunctionsDelayable: the key "..tostring(key).." is not a string.")
        elseif type(func) ~= "function" then
            error("makeFunctionDelayable: the value for key "..key.." is a "..type(func).." when it should be a function.")
        end
        if delayableFunctionsTable[key] then
            error("makeFunctionDelayable: the key "..key.." has been used for more than one delayable function.")
        end
        delayableFunctionsTable[key] = func
    end
    for index,value in pairs(tableOfDelayableFunctions) do
        mFD(index,value)
    end
end
delayedAction.makeTableOfFunctionsDelayable = makeTableOfFunctionsDelayable

--local function getDelayableFunctions(functionsTable)
--    if type(functionsTable) ~="table" then
--        error("getDelayableFunctions: argument must be a table.")
--    end
--    for key,value in pairs(functionsTable) do
--        if type(key) ~= "string" then
--            error("getDelayableFunctions: table must only have string keys.")
--        end
--        if type(value) ~="function" then
--            error("getDelayableFunctions: table must only have function values.")
--        end
--    end
--    delayableFunctionsTable = functionsTable
--end
--delayedAction.getDelayableFunctions = getDelayableFunctions

-- returns an error if any table or sub table consists of stuff other
-- than numbers and strings
local function validateArgumentTable(table)
    for key,value in pairs(table) do
        if type(key) ~= "string" and type(key) ~="number" then
            error("delayedAction: a delayed action argument table can only have numbers and strings as keys.")
        end
        if type(value) ~="string" and type(value) ~="number" and type(value) ~="table" then
            error("delayedAction: a delayed action argument table can only have numbers, strings, and tables as values.")
        end
        if type(value) == "table" then
            validateArgumentTable(value)
        end
    end
end

-- doInFuture(keyInDelayableFunctionsTable,argumentTable,turn,tribeID = -1)
--      performs an action specified by the keyInDelayableFunctionsTable
--      and the argumentTable, on the turn specified
--      happens after production of the tribe associated with tribeID,
--      or onTurn, if submitted tribeID is -1
--      
local function doInFuture(functionKey,argTable,turn,tribeID)
    if type(functionKey) ~= "string" then
        error("doInFuture: The function key argument must be a string")
    end
    if type(turn) ~= "number" or type(tribeID) ~= "number" then
        error("doInFuture: the turn and tribeID arguments must be numbers.")
    end
    tribeID = tribeID or -1
    if not delayableFunctionsTable[functionKey] then
        error("doInFuture: "..functionKey.." is not a registered key in the delayable functions table.")
    end
    if turn < civ.getTurn() or turn == civ.getTurn() and tribeID <= civ.getCurrentTribe().id then
        error("doInFuture: attempt to set the delayed function in the past. specified turn: "..turn..", specified tribeID: "..tribeID..", current turn: "..civ.getTurn()..", current tribeID:"..civ.getCurrentTribe().id)
    end
    validateArgumentTable(argTable)
    local actionInfo = {func = functionKey,arguments = argTable, turn = turn, tribeID = tribeID }
    savedActions[#savedActions+1] = actionInfo
end
delayedAction.doInFuture = doInFuture
    

-- doNextOpportunity(keyInDelayableFunctionsTable,argumentTable={},tribeOrTribeID=-1)
-- performs a delayed action the next time a tribe is active, or immediately
-- if the tribe is the currently active tribe.  If no tribe is specified,
-- or the tribeID specified is -1,
-- the action will be performed with the onTurn actions for the next turn
local function doNextOpportunity(functionKey,argTable,tribeOrID)
    if not delayableFunctionsTable[functionKey] then
        error("doInFuture: "..functionKey.." is not a registered key in the delayable functions table.")
    end
    local tribeID = tribeOrID or -1
    if civ.isTribe(tribeID) then
        tribeID = tribeID.id
    end
    argTable = argTable or {}
    validateArgumentTable(argTable)
    if civ.getCurrentTribe().id == tribeOrID then
        delayableFunctionsTable[functionKey](argTable)
    else
        local turn = civ.getTurn()
        -- tribe earlier in order, so event must happen next turn
        if tribeID < civ.getCurrentTribe().id then
            turn = turn+1
        end
        doInFuture(functionKey,argTable,turn,tribeID)
    end
end
delayedAction.doNextOpportunity = doNextOpportunity

local civlua = require("civluaModified")
local function performDelayedActions(turn,tribeID)
    for i=1,(#savedActions) do
        local action = savedActions[i]
        if tribeID == action.tribeID and turn == action.turn then
            delayableFunctionsTable[action.func](action.arguments)
            savedActions[i] = nil
        end
    end
    gen.clearGapsInArray(savedActions)        
end

local function doAfterProduction(turn,tribe)
    performDelayedActions(turn,tribe.id)
end
delayedAction.doAfterProduction = doAfterProduction

local function doOnTurn(turn)
    performDelayedActions(turn,-1)
end
delayedAction.doOnTurn = doOnTurn


local function doBeforeProduction(turn,tribe)

    -- at the moment, this is just here for future availability,
    -- so that there is something to reference in the template
end
delayedAction.doBeforeProduction = doBeforeProduction

return delayedAction




