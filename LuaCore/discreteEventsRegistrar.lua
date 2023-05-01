local versionNumber = 4
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
local suppressEventsLuaWarning = false -- if set to true, this suppresses the warning that
-- the file couldn't find the events.lua version.  This is probably only useful if
-- you're using discreteEventsRegistrar outside of the LuaScenarioTemplate
-- (I wouldn't recommend setting fileModified to true just for this, since you might think
-- you made important changes)


--[[The Discrete Events Registration Module allows the scenario designer to 
register code for events in discrete chunks, instead of having to program out
all the logic for events of a certain type in the same place.  Note, however, that 
the order of execution of different discrete events is not guaranteed.  If you need
events to happen in a specific order, you should either progrgram them all in the same
discrete event, or use either `consolidatedEvents.lua` or the appropriate file in the
`EventFiles` directory.  To import this module, use the following code:
```lua
local discreteEvents = require("discreteEventsRegistrar")
```
    ]]
---@class discreteEvents
local discreteEvents = {}

local eventsTable = {}

local minVersion = function(self,minVersion)
    if versionNumber < minVersion then
        local message = "The LuaCore\\discreteEventsRegistrar.lua file is out of date.  It is version "..tostring(versionNumber)..
        ", but one of your other files needs version "..tostring(minVersion).." or later.  "
        .."You should download the most recent version of the Lua Scenario Template, and replace "
        .."LuaCore\\discreteEventsRegistrar with the updated version."
        if fileModified then
            message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
            .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."

        end
        error(message)
    end
    return self
end
local recommendedVersion = function(self,recVersion)
    local moduleFileName = "LuaCore\\discreteEventsRegistrar.lua"
    local vNum = versionNumber
    if vNum < recVersion then
        local message = "WARNING: The "..moduleFileName.." is out of date.  It is version "..tostring(vNum)..
        ", but one of your files recommends version "..tostring(recVersion).." or later.  "
        if fileModified then
            message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
            .."  Replacing this file will remove those changes.  This is not a mandatory update, so you (probably) don't have to make any changes.  However, you may still wish to bring code in from the new file for extra features."
        else
            message = message.." The fileModified variable at the top of the file does not indicate that you have made any changes to this file.  If this is actually the case, you can replace it with the most recent version from the Lua Scenario Template without any problem."
        end
        print(message.."\n")
    end
    return self
end
discreteEvents.minVersion = minVersion
discreteEvents.recommendedVersion = recommendedVersion
discreteEvents.getVersion = versionNumber

local eventsVersion = {}
eventsVersion.versionNumber = _G._discreteEventsRegistrar_events_lua_versionNumber
eventsVersion.fileModified = _G._discreteEventsRegistrar_events_lua_fileModified
eventsVersion.regressionNumber = _G._discreteEventsRegistrar_events_lua_regressionNumber

local function minEventsLuaVersion(minVersion,regNum)
    local fileName = "LuaCore\\discreteEventsRegistrar.lua"
    if eventsVersion.versionNumber == nil then
            if not suppressEventsLuaWarning then
            print("WARNING: "..fileName.." expects to use version "..tostring(minVersion).." of the Lua Scenario Template, but no version of events.lua has been registered.  If you are using the Lua Scenario Template, this means your events.lua file is old.  If you are not, you can suppress this warning by changing the 'suppressEventsLuaWarning' variable at the top of discreteEventsRegistrar.lua.")
            end
        return
    end
    if minVersion > eventsVersion.versionNumber then
        local message = "The events.lua file is out of date.  It is version "..tostring(eventsVersion.versionNumber)
        ..", but one of your other files needs version "..tostring(minVersion).." or later.  "
        .."You should download the most recent version of the Lua Scenario Template, and replace "
        .."events.lua with the updated version."
        if eventsVersion.fileModified then
            message = message.."\nIMPORTANT WARNING: it appears you've changed events.lua for your scenario."
            .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."
        end
        if regNum > eventsVersion.regressionNumber then
            message = message.."\nIMPORTANT WARNING: it appears that events.lua has had some sort of functionality removed or changed.  Seek advice before updating."
        end
        error(message)
    end
end
minEventsLuaVersion(4,1)


eventsTable.onActivateUnit = {}
eventsTable.onActivateUnitIndex = 1

function discreteEvents.performOnActivateUnit(unit,source,rep)
    for i = 1,eventsTable.onActivateUnitIndex-1 do
        eventsTable.onActivateUnit[i](unit,source,rep)
    end
end


eventsTable.onBribeUnit = {}
eventsTable.onBribeUnitIndex = 1

function discreteEvents.performOnBribeUnit(unit,previousOwner)
    for i = 1,eventsTable.onBribeUnitIndex-1 do
        eventsTable.onBribeUnit[i](unit,previousOwner)
    end
end


eventsTable.onCityDestroyed = {}
eventsTable.onCityDestroyedIndex = 1

function discreteEvents.performOnCityDestroyed(city)
    for i = 1,eventsTable.onCityDestroyedIndex-1 do
        eventsTable.onCityDestroyed[i](city)
    end
end

eventsTable.onCityFounded = {}
eventsTable.onCityFoundedIndex = 1

function discreteEvents.performOnCityFounded(city)
    local cityCancelledTable = {}
    local cityCancelledIndex = 1
    for i = 1,eventsTable.onCityFoundedIndex-1 do
        local cancellationFn = eventsTable.onCityFounded[i](city)
        if cancellationFn and type(cancellationFn) == "function" then
            cityCancelledTable[cityCancelledIndex] = cancellationFn
            cityCancelledIndex = cityCancelledIndex+1
        elseif cancellationFn then
            error("discreteEventsRegistrar: one of your onCityFounded discrete events returns a value that is not a function.  That value is "..tostring(cancellationFn)..".  Your onCityFounded event does not need to return a value, but if it does, it should be a function (or nil).")
        end
    end
    local function cancellationFunction()
        for j=1,cityCancelledIndex-1 do
            cityCancelledTable[j]()
        end
    end
    return cancellationFunction
end

eventsTable.onCityProcessed = {}
eventsTable.onCityProcessedIndex = 1
function discreteEvents.performOnCityProcessed(city)
    for i = 1,eventsTable.onCityProcessedIndex-1 do
        eventsTable.onCityProcessed[i](city)
    end
end

eventsTable.onCityProduction = {}
eventsTable.onCityProductionIndex = 1

function discreteEvents.performOnCityProduction(city,item)
    for i = 1,eventsTable.onCityProductionIndex-1 do
        eventsTable.onCityProduction[i](city,item)
    end
end


eventsTable.onCityTaken = {}
eventsTable.onCityTakenIndex = 1

function discreteEvents.performOnCityTaken(city,defender)
    for i = 1,eventsTable.onCityTakenIndex-1 do
        eventsTable.onCityTaken[i](city,defender)
    end
end

eventsTable.onScenarioLoaded = {}
eventsTable.onScenarioLoadedIndex = 1

function discreteEvents.performOnScenarioLoaded()
    for i = 1,eventsTable.onScenarioLoadedIndex-1 do
        eventsTable.onScenarioLoaded[i]()
    end
end

eventsTable.onTurn = {}
eventsTable.onTurnIndex = 1

function discreteEvents.performOnTurn(turn)
    for i = 1,eventsTable.onTurnIndex-1 do
        eventsTable.onTurn[i](turn)
    end
end

eventsTable.onUnitKilled = {}
eventsTable.onUnitKilledIndex = 1

function discreteEvents.performOnUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    for i = 1,eventsTable.onUnitKilledIndex-1 do
        eventsTable.onUnitKilled[i](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    end
end

eventsTable.onUnitDefeated = {}
eventsTable.onUnitDefeatedIndex = 1

function discreteEvents.performOnUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    for i = 1,eventsTable.onUnitDefeatedIndex-1 do
        eventsTable.onUnitDefeated[i](loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    end
end


eventsTable.onUnitDeleted = {}
eventsTable.onUnitDeletedIndex = 1

function discreteEvents.performOnUnitDeleted(deletedUnit,replacingUnit)
    for i = 1,eventsTable.onUnitDeletedIndex-1 do
        eventsTable.onUnitDeleted[i](deletedUnit,replacingUnit)
    end
end

eventsTable.onAfterProduction = {}
eventsTable.onAfterProductionIndex = 1

function discreteEvents.performOnAfterProduction(turn,tribe)
    for i = 1,eventsTable.onAfterProductionIndex-1 do
        eventsTable.onAfterProduction[i](turn,tribe)
    end
end

eventsTable.onCityProcessingComplete = {}
eventsTable.onCityProcessingCompleteIndex = 1

function discreteEvents.performOnCityProcessingComplete(turn,tribe)
    for i = 1,eventsTable.onCityProcessingCompleteIndex-1 do
        eventsTable.onCityProcessingComplete[i](turn,tribe)
    end
end
eventsTable.onBeforeProduction = {}
eventsTable.onBeforeProductionIndex = 1

function discreteEvents.performOnBeforeProduction(turn,tribe)
    for i = 1,eventsTable.onBeforeProductionIndex-1 do
        eventsTable.onBeforeProduction[i](turn,tribe)
    end
end

eventsTable.onTribeTurnBegin = {}
eventsTable.onTribeTurnBeginIndex = 1

function discreteEvents.performOnTribeTurnBegin(turn,tribe)
    for i = 1,eventsTable.onTribeTurnBeginIndex-1 do
        eventsTable.onTribeTurnBegin[i](turn,tribe)
    end
end

eventsTable.onTribeTurnEnd = {}
eventsTable.onTribeTurnEndIndex = 1

function discreteEvents.performOnTribeTurnEnd(turn,tribe)
    for i = 1,eventsTable.onTribeTurnEndIndex-1 do
        eventsTable.onTribeTurnEnd[i](turn,tribe)
    end
end


eventsTable.linkStateToModules = {}
eventsTable.linkStateToModulesIndex = 1
-- state is the state table (after the buffer has been extracted)
-- stateTableKeys are keys for the state table that have
-- already been used, (this enables errors upon collision of keys) 
--
function discreteEvents.performLinkStateToModules(state,stateTableKeys)
    for i = 1,eventsTable.linkStateToModulesIndex-1 do
        eventsTable.linkStateToModules[i](state,stateTableKeys)
    end
end


eventsTable.onCentauriArrival = {}
eventsTable.onCentauriArrivalIndex = 1

function discreteEvents.performOnCentauriArrival(tribe)
    for i = 1,eventsTable.onCentauriArrivalIndex-1 do
        eventsTable.onCentauriArrival[i](tribe)
    end
end


eventsTable.onNegotiation = {}
eventsTable.onNegotiationIndex = 1

function discreteEvents.performOnNegotiation(talker,listener)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    -- in this case, false prevents negotiation
    local resultSoFar = true
    for i =1, eventsTable.onNegotiationIndex-1 do
        local currentResult = eventsTable.onNegotiation[i](talker,listener)
        if currentResult == nil then
            error('discreteEvents.performOnNegotiation: all discrete events registered by discreteEvents.onNegotiation must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


eventsTable.onGameEnds = {}
eventsTable.onGameEndsIndex = 1

function discreteEvents.performOnGameEnds(reason)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    local resultSoFar = true
    for i =1, eventsTable.onGameEndsIndex-1 do
        local currentResult = eventsTable.onGameEnds[i](reason)
        if currentResult == nil then
            error('discreteEvents.performOnGameEnds: all discrete events registered by discreteEvents.onGameEnds must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


eventsTable.onSchism = {}
eventsTable.onSchismIndex = 1

function discreteEvents.performOnSchism(tribe)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    -- in this case, false prevent schism
    local resultSoFar = true
    for i =1, eventsTable.onSchismIndex-1 do
        local currentResult = eventsTable.onSchism[i](tribe)
        if currentResult == nil then
            error('discreteEvents.performOnSchism: all discrete events registered by discreteEvents.onSchism must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end


eventsTable.onChooseSeason = {}
eventsTable.onChooseSeasonIndex = 1

function discreteEvents.performOnChooseSeason()
    for i=1, eventsTable.onChooseSeasonIndex-1 do
        eventsTable.onChooseSeason[i]()
    end
end


eventsTable.onKeyPress = {}
eventsTable.onKeyPressIndex = 1

function discreteEvents.performOnKeyPress(keyId)
    for i=1, eventsTable.onKeyPressIndex-1 do
        eventsTable.onKeyPress[i](keyId)
    end
end


eventsTable.onCanFoundCity = {}
eventsTable.onCanFoundCityIndex = 1

function discreteEvents.performOnCanFoundCity(unit)
    -- the default value is true, so return false if
    -- any of the discrete events return false
    local resultSoFar = true
    for i =1, eventsTable.onCanFoundCityIndex-1 do
        local currentResult = eventsTable.onCanFoundCity[i](unit)
        if currentResult == nil then
            error('discreteEvents.performOnCanFoundCity: all discrete events registered by discreteEvents.onCanFoundCity must return a boolean value, that is either true or false.')
        end
        resultSoFar = resultSoFar and currentResult
    end
    return resultSoFar
end

eventsTable.onSave = {}
eventsTable.onSaveIndex = 1
function discreteEvents.performOnSave()
    for i=1, eventsTable.onSaveIndex-1 do
        eventsTable.onSave[i]()
    end
end


eventsTable.onEnterTile = {}
eventsTable.onEnterTileIndex = 1

function discreteEvents.performOnEnterTile(unit,previousTile,previousDomainSpec)
    for i = 1,eventsTable.onEnterTileIndex-1 do
        eventsTable.onEnterTile[i](unit,previousTile,previousDomainSpec)
    end
end

-- onEnterTile priority allows transport movement to 
-- be resolved before other onEnterTile events
eventsTable.onEnterTilePriority = {}
eventsTable.onEnterTilePriorityIndex = 1

function discreteEvents.performOnEnterTilePriority(unit,previousTile,previousDomainSpec)
    for i = 1,eventsTable.onEnterTilePriorityIndex-1 do
        eventsTable.onEnterTilePriority[i](unit,previousTile,previousDomainSpec)
    end
end


eventsTable.onFinalOrderGiven = {}
eventsTable.onFinalOrderGivenIndex = 1

function discreteEvents.performOnFinalOrderGiven(unit)
    for i = 1,eventsTable.onFinalOrderGivenIndex-1 do
        eventsTable.onFinalOrderGiven[i](unit)
    end
end

local registeredEventTypes =
[[
discreteEvents.onActivateUnit 
discreteEvents.onBribeUnit 
discreteEvents.onCityDestroyed 
discreteEvents.onCityFounded 
discreteEvents.onCityProduction 
discreteEvents.onCityTaken 
discreteEvents.onScenarioLoaded 
discreteEvents.onTurn 
discreteEvents.onUnitKilled 
discreteEvents.onUnitDefeated 
discreteEvents.onUnitDeleted 
discreteEvents.onAfterProduction 
discreteEvents.onBeforeProduction 
discreteEvents.onCityProcessed
discreteEvents.linkStateToModules
discreteEvents.onCentauriArrival
discreteEvents.onNegotiation
discreteEvents.onGameEnds
discreteEvents.onChooseSeason
discreteEvents.onKeyPress
discreteEvents.onCityProcessingComplete
discreteEvents.onTribeTurnBegin
discreteEvents.onTribeTurnEnd
discreteEvents.onCanFoundCity
discreteEvents.onSchism
discreteEvents.onSave
discreteEvents.onEnterTile
discreteEvents.onEnterTilePriority
discreteEvents.onFinalOrderGiven
]]

local function newIndexFn(myTable,key,value)
    if eventsTable[key] then
        eventsTable[key][eventsTable[key.."Index"]]=value
        eventsTable[key.."Index"]=eventsTable[key.."Index"]+1
    else
        error("\ndiscreteEvents."..key.." is not a registered event type in discrete events.  These are the events that can be registered using discreteEvents:\n"..registeredEventTypes.."\nIf you desired event execution point isn't in this list, you can't register it as a discrete event.")
    end
end

local registeredEventCalls =
[[
discreteEvents.performOnActivateUnit 
discreteEvents.performOnBribeUnit 
discreteEvents.performOnCityDestroyed 
discreteEvents.performOnCityFounded 
discreteEvents.performOnCityProduction 
discreteEvents.performOnCityTaken 
discreteEvents.performOnScenarioLoaded 
discreteEvents.performOnTurn 
discreteEvents.performOnUnitKilled 
discreteEvents.performOnUnitDefeated 
discreteEvents.performOnUnitDeleted 
discreteEvents.performOnAfterProduction 
discreteEvents.performOnBeforeProduction 
discreteEvents.performOnCityProcessed 
discreteEvents.performLinkStateToModules
discreteEvents.performOnCentauriArrival
discreteEvents.performOnNegotiation
discreteEvents.performOnGameEnds
discreteEvents.performOnChooseSeason
discreteEvents.performOnKeyPress
discreteEvents.performOnCityProcessingComplete
discreteEvents.performOnTribeTurnBegin
discreteEvents.performOnTribeTurnEnd
discreteEvents.performOnCanFoundCity
discreteEvents.performOnSchism
discreteEvents.performOnSave
discreteEvents.performOnEnterTile
discreteEvents.performOnEnterTilePriority
discreteEvents.performOnFinalOrderGiven
]]
local function indexFn(myTable,key)
    if discreteEvents[key] then
        return discreteEvents[key]
    else
        error("discreteEvents: discreteEvents."..key.." does not exist.  Perhaps you meant one of the following:\n"..registeredEventCalls)
    end
end


local superMetatable = {__index = indexFn,__newindex=newIndexFn}

local superTable = {version=versionNumber, eventsTable=eventsTable}


---Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving (see civ.scen.compatibility), `false` otherwise.
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(unit: unitObject, source: boolean, repeatMove: boolean)
discreteEvents.onActivateUnit = function(code)
    newIndexFn(nil,"onActivateUnit",code)
end


---Registers a function that is called when a unit is bribed successfully. unit.owner is the new owner at this point, `previousOwner` the old owner.
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(unit: unitObject, previousOwner: tribeObject)
function discreteEvents.onBribeUnit(code)
    newIndexFn(nil,"onBribeUnit",code)
end


--[[
Registers a function that is called to determine if `unit` can found a city at the unit's location. `advancedTribe` is `true` when picking up a hut with `unit` triggers an advanced tribe. Return `true` to allow, `false` to disallow.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---This is combined with the consolidated events, the legacy events, and the separate onCanFoundCity.lua file.  If any of these functions return false, the city can't be built.
---@param code fun(unit: unitObject, advancedTribe: boolean):boolean
function discreteEvents.onCanFoundCity(code)
    newIndexFn(nil,"onCanFoundCity",code)
end

--[[
    Registers a function that is called when a tribe's spaceship reaches its target. Just registering this function causes the game to not end at this point ("endgame override").
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(tribe:tribeObject)
function discreteEvents.onCentauriArrival(code)
    newIndexFn(nil,"onCentauriArrival",code)
end



--[[
Registers a function that is called when a city is destroyed.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(city:cityObject) 
function discreteEvents.onCityDestroyed(code)
    newIndexFn(nil,"onCityDestroyed",code)
end


--[[
Registers a function to be called every time a city is founded. The callback takes the city as a parameter, and can optionally return a function (since 0.18) that is called to perform cleanup when the user cancels founding the city.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.  This includes any code returned to cleanup after the user cancels founding the city.
---@param code fun(city:cityObject)|fun(city:cityObject):fun()
function discreteEvents.onCityFounded(code)
    newIndexFn(nil,"onCityFounded",code)
end


--[[
Registers a function that is called when a tribe's cities have been processed for that turn. See `onTurn` for interaction with other "turn" triggers.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(turn: integer, tribe:tribeObject)
function discreteEvents.onCityProcessingComplete(code)
    newIndexFn(nil,"onCityProcessingComplete",code)
end





--[[
Registers a function that is called when a city completes its production order. The produced item `prod` is either a unit, improvement or wonder (this can be checked with the civ.is* functions).
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(city:cityObject, prod:producedItem)
function discreteEvents.onCityProduction(code)
    newIndexFn(nil,"onCityProduction",code)
end


--[[
Registers a function that is called when a city is captured. `city` is the city changing hands, at this point city.owner is the new owner already. `defender` is the old owner.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(city: cityObject, defender: tribeObject)
function discreteEvents.onCityTaken(code)
    newIndexFn(nil,"onCityTaken",code)
end


--[[
<br>Registers a function that is called when the game ends. `reason` is an integer between 1 and 6:
<br>1 and 2 - Space race victory. This does not trigger if `onCentauriArrival` has a callback registered. 1 means victory by active player.
<br>3 - Conquest victory
<br>4 - Defeat
<br>5 - Retirement
<br>6 - Macro ENDGAME action
<br>Return `true` to end the game, `false` to keep playing.
--]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---This is combined with the consolidated events, the legacy events, and the separate onGameEnds.lua file. If any of these return false, the game end is prevented.
---@param code fun(reason:gameEndReasons):(gameIsOver:boolean)
function discreteEvents.onGameEnds(code)
    newIndexFn(nil,"onGameEnds",code)
end


--[[
Registers a function to be called every time a key is pressed.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code function (keyCode:integer)
function discreteEvents.onKeyPress(code)
    newIndexFn(nil,"onKeyPress",code)
end




--[[
Registers a function that is called when two tribes attempt negotiations. `talker` is the tribe initiating the contact, `listener` the receiver. Return `true` to allow the negotiations to commence, `false` to deny.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---This is combined with the consolidated events, the legacy events, and the separate onNegotiation.lua file.  If any of these return false, then negotiation is prevented.
---@param code fun(talker:tribeObject, listener:tribeObject):(canTalk:boolean)
function discreteEvents.onNegotiation(code)
    newIndexFn(nil,"onNegotiation",code)
end




--[[
Registers a function that is called when the game is saved.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.  However, you can't add extra data to be saved on the end of the file with this function.
---@param code fun()
function discreteEvents.onSave(code)
    newIndexFn(nil,"onSave",code)
end


--[[
Registers a function that is called when the scenario is loaded.  (This is whenever a game is loaded, not just when the scenario is started.)
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun()
function discreteEvents.onScenarioLoaded(code)
    newIndexFn(nil,"onScenarioLoaded",code)
end


--[[
Registers a function that is called when a schism is triggered. This happens when the capital of a AI-controlled tribe with more than four cities is captured, and, if the attacker is human-controlled, it is ranked lower in power than the defender. If the attacker is AI-controlled the best human tribe must be ranked lower than the defender for the schism to trigger.
If the schism is allowed, a new tribe will be created that takes over about half the cities of the old tribe. If no new tribe can be created, the schism does not occur.
Return `true` to allow the schism to happen, `false` to deny.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---This is combined with the consolidated events, the legacy events, and the separate onSchism.lua file.  If any of these return false, then schism is prevented.
---@param code fun(tribe:tribeObject):allowSchism:boolean
function discreteEvents.onSchism(code)
    newIndexFn(nil,"onSchism",code)
end



--[[
Registers a function that is called at the start of a tribe's turn. See `onTurn` for interaction with other "turn" triggers.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(turn:integer, tribe:tribeObject)
function discreteEvents.onTribeTurnBegin(code)
    newIndexFn(nil,"onTribeTurnBegin",code)
end


--[[
Registers a function that is called at the end of a tribe's turn. See `onTurn` for interaction with other "turn" triggers.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(turn:integer, tribe:tribeObject)
function discreteEvents.onTribeTurnEnd(code)
    newIndexFn(nil,"onTribeTurnEnd",code)
end


--[[
Registers a function that is called at the start of a turn. The basic sequence of this and other "turn" triggers is as follows:
<br>`onTurn` fires
<br>Non-tribe-specific updates take place
<br>`onTribeTurnBegin` fires for tribe 0.
<br>Tribe 0 cities are processed.
<br>`onCityProcessingComplete` fires for tribe 0 (this fires even when a tribe has no cities).
<br>Tribe 0 units move
<br>`onTribeTurnEnd` fires for tribe 0.
<br>All active tribes are processed in order according to the sequence for tribe 0
<br>`onTribeTurnEnd` fires for tribe 7.
<br>`onTurn` fires for the next turn
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(turn:integer)
function discreteEvents.onTurn(code)
    newIndexFn(nil,"onTurn",code)
end


--[[
Registers a function that is called whenever a unit is killed in standard Civ II combat. `loser` is the unit that is killed, `winner` is the unit responsible for it.  `aggressor` is the unit that initiated the attack, and `victim` is the unit that was attacked.  `loserLocation` is the tile where the unit that lost combat stood (if the loser is the aggressor, loser.location and aggressor.location return a tile off the map).  `winnerVetStatus` and `loserVetStatus` are true if the corresponding unit was a veteran before combat took place.  (winner.veteran is checked after the unit is promoted) 
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(loser:unitObject, winner:unitObject, aggressor: unitObject, victim: unitObject, loserLocation: tileObject, winnerVetStatus: boolean, loserVetStatus:boolean)
function discreteEvents.onUnitKilled(code)
    newIndexFn(nil,"onUnitKilled",code)
end

--[[
Registers a function that is called whenever a unit is killed, either in standard Civ II combat or by events. `loser` is the unit that is killed, `winner` is the unit responsible for it.  `aggressor` is the unit that initiated the attack, and `victim` is the unit that was attacked.  `loserLocation` is the tile where the unit that lost combat stood (if the loser is the aggressor, loser.location and aggressor.location return a tile off the map).  `winnerVetStatus` and `loserVetStatus` are true if the corresponding unit was a veteran before combat took place.  (winner.veteran is checked after the unit is promoted) 
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(loser:unitObject, winner:unitObject, aggressor: unitObject, victim: unitObject, loserLocation: tileObject, winnerVetStatus: boolean, loserVetStatus:boolean)
function discreteEvents.onUnitDefeated(code)
    newIndexFn(nil,"onUnitDefeated",code)
end

--[[
Registers a function that is called when a unit is deleted (either through combat death, or by some other even, but not if the unit is disbanded).  `deletedUnit` is the unit being deleted, while `replacing unit` is the unit replacing it (e.g. from promotion/demotion), or _nil_ if there is no such unit.
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(deletedUnit: unitObject, replacingUnit:unitObject|nil)
function discreteEvents.onUnitDeleted(code)
    newIndexFn(nil,"onUnitDeleted",code)
end

--[[
Registers a function that is called immediately before each city is processed (which happens at the start of a tribe's turn).  (This is achieved through use of civ.scen.onCalculateCityYield.)
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(city: cityObject)
function discreteEvents.onCityProcessed(code)
    newIndexFn(nil,"onCityProcessed",code)
end

--[[Registers a function that will be called during civ.scen.onLoad, with which you can link state tables from inside individual modules.  `stateTable` is the table which is added to the saved game, `stateTableKeys` is a record of keys already used in the stateTable, and by adding keys, you can avoid accidental collision. Example:
```lua
local delayedActionState = "state not linked"
local savedActions = "state not linked"
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
discreteEvents.linkStateToModules(function(state,stateTableKeys)
    local keyName = "delayedAction"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    -- link the state table to the module
    state[keyName] = state[keyName] or {}
    linkState(state[keyName])
end)
```
]]
---@param code fun(stateTable: table, stateTableKeys: table<string,true>)
function discreteEvents.linkStateToModules(code)
    newIndexFn(nil,"linkStateToModules",code)
end

--[[
Registers code to be executed during civ.scen.onTurn and civ.scen.onScenarioLoaded.  This way, the correct "season" can be chosen when the scenario is loaded, and can be updated for each new turn.
    ]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun()
function discreteEvents.onChooseSeason(code)
    newIndexFn(nil,"onChooseSeason",code)
end

--[[
Registers code to be executed when a unit enters a tile.  (Implemented using several civ.scen functions.)  `unit` is the unit which entered the tile, `previousTile` is where the unit was before it moved, and `previousDomainSpec` is the value of unit.domainSpec before it moved into the square (useful for units with range).
]]
---As a Discrete Event, this function can be called multiple times, and all code will be registered to the event.
---@param code fun(unit: unitObject, previousTile: tileObject, previousDomainSpec: integer)
function discreteEvents.onEnterTile(code)
    newIndexFn(nil,"onEnterTile",code)
end

--- Registers an onEnterTile event before all other onEnterTile events.  It is used for "transport" events, so that units can "drag" other units into the tile before the regular onEnterTile event.
---@param code fun(unit: unitObject, previousTile: tileObject, previousDomainSpec: integer)
function discreteEvents.onEnterTilePriority(code)
    newIndexFn(nil,"onEnterTilePriority", code)
end

--[[
Registers code to be executed when a unit has been given its last order for the turn.  That is, when a new unit is active, and the previous unit has spent all its movement points (or, at the end of the turn)
]]
---@param code fun(unit: unitObject)
function discreteEvents.onFinalOrderGiven(code)
    newIndexFn(nil,"onFinalOrderGiven",code)
end



-- to make these functions appear in the documentation, 
-- it is necessary to add them to superTable.  However, I want the
-- metatable to handle them (so that backwards compatibility can
-- be maintained where discreteEvents.onActivateUnit = someFunction
-- will also register someFunction as a discrete event).
-- Therefore, I need to remove these functions from the superTable,
-- which is done via nillify below (also for LuaLS documentation reasons)
superTable.onActivateUnit = discreteEvents.onActivateUnit 
superTable.onBribeUnit = discreteEvents.onBribeUnit 
superTable.onCityFounded = discreteEvents.onCityFounded 
superTable.onCityProduction = discreteEvents.onCityProduction 
superTable.onCityTaken = discreteEvents.onCityTaken 
superTable.onScenarioLoaded = discreteEvents.onScenarioLoaded 
superTable.onTurn = discreteEvents.onTurn 
superTable.onUnitKilled = discreteEvents.onUnitKilled 
superTable.onUnitDefeated = discreteEvents.onUnitDefeated 
superTable.onUnitDeleted = discreteEvents.onUnitDeleted 
-- deprecated functions

---Use discreteEvents.onCityProcessingComplete instead
---@param code fun(turn: integer, tribe:tribeObject)
---@deprecated
function superTable.onAfterProduction(code)
    discreteEvents.onCityProcessingComplete(code)
end

--- Use discreteEvents.onTribeTurnBegin instead
---@param code fun(turn:integer, tribe:tribeObject)
---@deprecated
function discreteEvents.onBeforeProduction(code)
    newIndexFn(nil,"onTribeTurnBegin",code)
end

superTable.onCityProcessed = discreteEvents.onCityProcessed
superTable.linkStateToModules = discreteEvents.linkStateToModules
superTable.onCentauriArrival = discreteEvents.onCentauriArrival
superTable.onNegotiation = discreteEvents.onNegotiation
superTable.onGameEnds = discreteEvents.onGameEnds
superTable.onChooseSeason = discreteEvents.onChooseSeason
superTable.onKeyPress = discreteEvents.onKeyPress
superTable.onCityProcessingComplete = discreteEvents.onCityProcessingComplete
superTable.onTribeTurnBegin = discreteEvents.onTribeTurnBegin
superTable.onTribeTurnEnd = discreteEvents.onTribeTurnEnd
superTable.onCanFoundCity = discreteEvents.onCanFoundCity
superTable.onSchism = discreteEvents.onSchism
superTable.onSave = discreteEvents.onSave
superTable.onEnterTile = discreteEvents.onEnterTile
superTable.onEnterTilePriority = discreteEvents.onEnterTilePriority
superTable.onFinalOrderGiven = discreteEvents.onFinalOrderGiven
local function nillify(table)
    table.onActivateUnit = nil
    table.onBribeUnit = nil
    table.onCityFounded = nil
    table.onCityProduction = nil
    table.onCityTaken = nil
    table.onScenarioLoaded = nil
    table.onTurn = nil
    table.onUnitKilled = nil
    table.onUnitDefeated = nil
    table.onUnitDeleted = nil
    table.onAfterProduction = nil
    table.onBeforeProduction = nil
    table.onCityProcessed = nil
    table.linkStateToModules = nil
    table.onCentauriArrival = nil
    table.onNegotiation = nil
    table.onGameEnds = nil
    table.onChooseSeason = nil
    table.onKeyPress = nil
    table.onCityProcessingComplete = nil
    table.onTribeTurnBegin = nil
    table.onTribeTurnEnd = nil
    table.onCanFoundCity = nil
    table.onSchism = nil
    table.onSave = nil
    table.onEnterTile = nil
    table.onEnterTilePriority = nil
end
nillify(superTable)

setmetatable(superTable,superMetatable)

return superTable
