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

local discreteEvents = require("discreteEventsRegistrar")
local gen = require("generalLibrary")
local param = require("parameters")
local object = require("object")
local text = require("text")
local diplomacy = require("diplomacy")
local delayed = require("delayedAction")
local calendar = require("calendar")
local keyboard = require("keyboard")
local flag = require("flag")
local counter = require("counter")
local civlua = require("civluaModified")


-- ===============================================================================
--
--          Discrete Events
--
-- ===============================================================================

--Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving, `false` otherwise.
function discreteEvents.onActivateUnit(unit,source,repeatMove)
    --civ.ui.text("Unit activation Discrete Event")
end

function discreteEvents.onCityDestroyed(city) 
    --civ.ui.text("City destroyed discrete event test")

end

function discreteEvents.onBribeUnit(unit,previousOwner)
    --civ.ui.text("Bribe unit discrete event test")
end

function discreteEvents.onCityFounded(city) 
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

end

function discreteEvents.onCityProcessed(city) 
    --civ.ui.text("City processed discrete event test for city "..city.name)

end

function discreteEvents.onCityProduction(city,item) 
    --civ.ui.text("City production discrete event test")

end

function discreteEvents.onCityTaken(city,defender) 
    --civ.ui.text(city.name.." taken from "..defender.name.." discrete event")


end

function discreteEvents.onScenarioLoaded() 
    --civ.ui.text("discrete event on scenario loaded")

end

function discreteEvents.onTurn(turn) 
    --civ.ui.text("discrete on turn event 1")
end

function discreteEvents.onTurn(turn) 
    --civ.ui.text("discrete on turn event 2")

end

function discreteEvents.onTurn(turn) 
    --civ.ui.text("discrete on turn event 3")
end


function discreteEvents.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus) 
    --civ.ui.text(loser.type.name.." was killed by "..winner.type.name.." discrete event 1")
end

function discreteEvents.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus) 
    --civ.ui.text(loser.type.name.." was defeated (possibly by event) by "..winner.type.name.." discrete event")
end

function discreteEvents.onTurn(turn) 
    --civ.ui.text("discrete on turn event 4")
end

function discreteEvents.onCityProcessingComplete(turn,tribe) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onCityProcessingComplete for "..tribe.name.." on turn "..tostring(turn))
    end
end


function discreteEvents.onTribeTurnBegin(turn,tribe) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onTribeTurnBegin for "..tribe.name.." on turn "..tostring(turn))
    end
end

function discreteEvents.onTribeTurnEnd(turn,tribe) 
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onTribeTurnEnd for "..tribe.name.." on turn "..tostring(turn))
    end
end

function discreteEvents.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus) 
    --civ.ui.text(loser.type.name.." was killed by "..winner.type.name.." discrete event 2")
end

function discreteEvents.onCentauriArrival(tribe)
    --civ.ui.text(tribe.name.." arrived at centauri discrete event")
end

-- On Game Ends
-- Return true if the game ends as normal,
-- and false otherwise.
-- This is combined with the consolidated events and the
-- legacy events, as well as a separate onGameEnds.lua file
-- If any of these return false, then game end is prevented
-- Not documented or experimented with much
-- based on legacy event engine code, reason is an integer
function discreteEvents.onGameEnds(reason)
    -- return false to stop the game from ending
    return true
end

-- On Schism 
-- Return true (default) if the tribe can schism,
-- and false otherwise.
-- This is combined with the consolidated events and the
-- legacy events, as well as a separate onSchism.lua file
-- If any of these return false, then schism is prevented
function discreteEvents.onSchism(tribe)

    return true
end


-- On Negotiation 
-- Return true if the talker can contact the listener,
-- and false otherwise.
-- This is combined with the consolidated events and the
-- legacy events, as well as a separate onNegotiation.lua file
-- If any of these return false, then negotiation is prevented
function discreteEvents.onNegotiation(talker,listener)

    return true
end


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
function discreteEvents.onCanFoundCity(unit,advancedTribe)
    if _global.eventTesting then
        civ.ui.text("discreteEvents.onCanFoundCity for "..unit.type.name)
    end
    return true
end


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
