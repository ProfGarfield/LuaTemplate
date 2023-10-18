--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--
--
--  This file allows for a scenario designer to organize events
--  in a manner similar to the legacy system, in that you don't have to
--  group all events of the same type in the same place.
--  This may be more convenient in some cases.
--
--  You can create events in multiple files, but event order is only
--  guaranteed to be preserved within files.  That is, for two files
--  and 4 events with the same execution point
--      discreteEventsFile1.lua
--          Event A
--          Event B
--      discreteEventsFile2.lua
--          Event Y
--          Event Z
--  A will be checked before B and Y before Z,
--  but both A, B, Y, Z and Y, Z, A, B
--  are possible orders to check and execute the code
--
--
--
--

-- ===============================================================================
--
--          Require Lines etc.
--
-- ===============================================================================
-- This section is for the 'require' lines for this file, and anything
-- else that must be at the top of the file.

---@module "discreteEventsRegistrar"
local discreteEvents = require("discreteEventsRegistrar"):minVersion(4)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
---@module "param"
local param = require("parameters"):minVersion(1)
local object = require("object")
---@module "text"
local text = require("text"):minVersion(1)
---@module "diplomacy"
local diplomacy = require("diplomacy"):minVersion(1)
---@module "delayedAction"
local delayed = require("delayedAction"):minVersion(1)
local calendar = require("calendar")
local keyboard = require("keyboard")
local civlua = require("civluaModified")


-- ===============================================================================
--
--          Discrete Events
--
-- ===============================================================================
---&autoDoc onActivateUnit
--Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving, `false` otherwise.
--If the function returns true, the unit activation will be cancelled.
--No further activation code will be executed, and the unit's type
--will temporarily be set to have 0 movement points.
--If the function returns function(unit), then the unit activation
--will be cancelled, and the function returned will be executed
--just before another unit is activated.  (You may wish to put
--the unit to sleep, for example.)
--Not returning anything is equivalent to returning nil, which is
--acceptable, and keeps the unit activation going.
discreteEvents.onActivateUnit(function(unit,source,repeatMove)
    if _global.eventTesting then
        civ.ui.text("Unit activation Discrete Event")
    end
end)
---&endAutoDoc

---&autoDoc onCityDestroyed
discreteEvents.onCityDestroyed(function(city) 
    if _global.eventTesting then
        civ.ui.text("City destroyed discrete event test")
    end
end)
---&endAutoDoc
---&autoDoc onBribeUnit
discreteEvents.onBribeUnit(function(unit,previousOwner)
    if _global.eventTesting then
        civ.ui.text("Bribe unit discrete event test")
    end
end)
---&endAutoDoc
---&autoDoc onCityFounded
discreteEvents.onCityFounded(function(city) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onCityFounded for "..city.name)
    end
    -- the cityCancelled() function is executed if the player
    -- decides not to found the city after all
    -- (so you can undo terrain changes, etc.
    local function cityCancelled()
        if _global.eventTesting then
            civ.ui.text("discreteEvents.onCityFounded city cancelled for "..city.name)
        end
    end
    return cityCancelled
end)
---&endAutoDoc
---&autoDoc onCityProcessed
discreteEvents.onCityProcessed(function(city) 
    --civ.ui.text("City processed discrete event test for city "..city.name)

end)
---&endAutoDoc
---&autoDoc onCityProduction
discreteEvents.onCityProduction(function(city,item) 
    --civ.ui.text("City production discrete event test")

end)
---&endAutoDoc
---&autoDoc onCityTaken
discreteEvents.onCityTaken(function(city,defender) 
    --civ.ui.text(city.name.." taken from "..defender.name.." discrete event")


end)
---&endAutoDoc
---&autoDoc onScenarioLoaded
discreteEvents.onScenarioLoaded(function() 
    --civ.ui.text("discrete event on scenario loaded")

end)
---&endAutoDoc
---&autoDoc onTurn
discreteEvents.onTurn(function(turn) 
    --civ.ui.text("discrete on turn event 1")
end)
---&endAutoDoc

discreteEvents.onTurn(function(turn) 
    --civ.ui.text("discrete on turn event 2")

end)

discreteEvents.onTurn(function(turn) 
    --civ.ui.text("discrete on turn event 3")
end)

---&autoDoc onUnitKilled
discreteEvents.onUnitKilled(function(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus) 
    if _global.eventTesting then
        civ.ui.text(loser.type.name.." was killed by "..winner.type.name.." discrete event 1")
    end
end)
---&endAutoDoc

---&autoDoc onUnitDefeated
discreteEvents.onUnitDefeated(function(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus) 
    if _global.eventTesting then
    civ.ui.text(loser.type.name.." was defeated (possibly by event) by "..winner.type.name.." discrete event")
    end
end)
---&endAutoDoc

discreteEvents.onTurn(function(turn)
    --civ.ui.text("discrete on turn event 4")
end)
---&autoDoc onCityProcessingComplete
discreteEvents.onCityProcessingComplete(function(turn,tribe) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onCityProcessingComplete for "..tribe.name.." on turn "..tostring(turn))
    end
end)
---&endAutoDoc

---&autoDoc onTribeTurnBegin
discreteEvents.onTribeTurnBegin(function(turn,tribe) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onTribeTurnBegin for "..tribe.name.." on turn "..tostring(turn))
    end
end)
---&endAutoDoc
---&autoDoc onTribeTurnEnd
discreteEvents.onTribeTurnEnd(function(turn,tribe) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onTribeTurnEnd for "..tribe.name.." on turn "..tostring(turn))
    end
end)
---&endAutoDoc

discreteEvents.onUnitKilled(function(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus) 
    if _global.eventTesting then
        civ.ui.text(loser.type.name.." was killed by "..winner.type.name.." discrete event 2")
    end
end)
---&autoDoc onCentauriArrival
discreteEvents.onCentauriArrival(function(tribe)
    --civ.ui.text(tribe.name.." arrived at centauri discrete event")
end)
---&endAutoDoc
---&autoDoc onGameEnds
-- On Game Ends
-- Return true if the game ends as normal,
-- and false otherwise.
-- This is combined with the consolidated events and the
-- legacy events, as well as a separate onGameEnds.lua file
-- If any of these return false, then game end is prevented
-- Not documented or experimented with much
-- based on legacy event engine code, reason is an integer
discreteEvents.onGameEnds(function(reason)
    -- return false to stop the game from ending
    return true
end)
---&endAutoDoc
---&autoDoc onSchism
-- On Schism 
-- Return true (default) if the tribe can schism,
-- and false otherwise.
-- This is combined with the consolidated events and the
-- legacy events, as well as a separate onSchism.lua file
-- If any of these return false, then schism is prevented
discreteEvents.onSchism(function(tribe)

    return true
end)
---&endAutoDoc

---&autoDoc onNegotiation
-- On Negotiation 
-- Return true if the talker can contact the listener,
-- and false otherwise.
-- This is combined with the consolidated events and the
-- legacy events, as well as a separate onNegotiation.lua file
-- If any of these return false, then negotiation is prevented
discreteEvents.onNegotiation(function(talker,listener)

    return true
end)
---&endAutoDoc

---&autoDoc onCanFoundCity
-- Checking if a unit can found a city
-- Return true if the unit can found a city
-- return false if it can't
-- If any one of the consolidated event, the discrete events, 
-- or the separate file event return false, then the city
-- can't be built
-- Notes: Returning true does NOT override any normal city
-- building condition (like no adjacent cities, or cities at sea)
-- Registers a function that is called to determine if `unit` can found 
-- a city at the unit's location. `advancedTribe` is `true` when picking 
-- up a hut with `unit` triggers an advanced tribe. 
-- Return `true` to allow, `false` to disallow.
discreteEvents.onCanFoundCity(function(unit,advancedTribe)
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onCanFoundCity for "..unit.type.name)
    end
    return true
end)
---&endAutoDoc
---&autoDoc onEnterTile
-- onEnterTile(unit,previousTile)
-- executes when a unit successfully enters a tile (so not when it attacks
-- a unit or fails to enter a tile because it lacks movement points)
discreteEvents.onEnterTile(function(unit,previousTile,previousDomainSpec)
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onEnterTile: "..unit.type.name.." has entered tile ("..text.coordinates(unit.location)..") from tile ("..text.coordinates(previousTile)..").")
    end
end)
---&endAutoDoc
---&autoDoc onFinalOrderGiven
-- onFinalOrderGiven(unit)
-- executes when a unit has been given its final order for the turn.
-- that is, when a new unit is active and the previous unit has spent
-- all its movement points
discreteEvents.onFinalOrderGiven(function(unit)
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onFinalOrderGiven: "..unit.type.name.." has been given its order.")
    end
end)
---&endAutoDoc

-- Key press events are probably best registered in
-- MechanicsFiles\keyPressSettings.lua
-- This is here to facilitate documentation
---&autoDoc onKeyPress
-- The keyCode is an integer that corresponds to a particular key on the keyboard.
-- The keyboard module provides names for these codes.
discreteEvents.onKeyPress(function(keyCode)
    if _global.eventTesting and keyboard.backspace == keyCode then
        civ.ui.text("discreteEvents.onKeyPress: The backspace key has been pressed.")
    end
end)
---&endAutoDoc

---&autoDoc onCityWindowOpened
-- Executes when a city window is opened.
-- Note that the AI doesn't open city windows.
discreteEvents.onCityWindowOpened(function(city)
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onCityWindowOpened: The city window for "..city.name.." has been opened.")
    end
end)
---&endAutoDoc

-- ===============================================================================
--
--          End of File
--
-- ===============================================================================
--      In order to register discrete events, you don't need 
--      to return anything, but the file must be 'required'
--      by another file.  Discrete Events can be registered in any file,
--      provided it has the following require line:
--      
--      local discreteEvents = require("discreteEventsRegistrar")

local versionTable = {}
gen.versionFunctions(versionTable,versionNumber,fileModified,"MechanicsFiles".."\\".."discreteEvents.lua")
return versionTable

