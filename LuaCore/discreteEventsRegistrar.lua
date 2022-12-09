local versionNumber = 2
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
        ", but one of your files recommends version "..tostring(minVersion).." or later.  "
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
minEventsLuaVersion(1,1)


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
setmetatable(superTable,superMetatable)

return superTable
