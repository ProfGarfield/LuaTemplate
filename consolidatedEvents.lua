--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--



-- This file allows for a scenario designer to work with several
-- "event triggers" or "execution points" in the same file, instead
-- of spreading the events over several files.
--
-- This is for three purposes:
--  1.  For scenarios with relatively few events, this file may be more convenient.  
--  2.  For those starting their journey into Lua events, working with a single
--      file may be less intimidating.
--  3.  If an event requires the interaction of several triggers, it is more
--      convenient to work in one file.
--
-- However, beware the fact that as you write more events, having them in a
-- single file is likely to make them disorganized and hard to follow.  This
-- was the one of the reasons the template was separated into so many files
-- in the first place.
--

-- ===============================================================================
--
--          Require Lines etc.
--
-- ===============================================================================
-- This section is for the 'require' lines for this file, and anything
-- else that must be at the top of the file.
local consolidator = require("consolidator"):minVersion(1)
local gen = require("generalLibrary"):minVersion(1)
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


local events = {}


-- ===============================================================================
--
--          Helper Functions
--
-- ===============================================================================
--      If you write a helper function that is used for multiple events,
--      It is recommended that you store them in the 'helper' table here.
--      This will make it easier to move them to their own file later, if
--      you decide to migrate the events to individual files
local helper = {}
function helper.sampleHelperFunction()
    print("I am a sample helper function")
end


-- ===============================================================================
--
--          Execution Points
--
-- ===============================================================================
--      You can delete any unneeded function here.  It won't cause an error.
--      If you want to add a function back in, you can copy the relevant code
--      from consolidator.lua in the LuaCore directory



-- Unit Activation
--Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving, `false` otherwise.
function events.onActivateUnit(unit,source,repeatMove)
    --civ.ui.text("Unit activation consolidated test")

end


-- On Unit Bribery
function events.onBribeUnit(unit,previousOwner)
    --civ.ui.text("Bribe unit consolidated test")

end

-- On calculate City Yield not included here

-- On Can Build not included here

-- On Centauri Arrival
-- This is available with games started as an extended original game,
-- but not with games started as a standard game (I think, this hasn't been looked at too closely)
function events.onCentauriArrival(tribe)
    --civ.ui.text(tribe.name.." has reached Alpha Centauri.")

end

-- City destruction
function events.onCityDestroyed(city)
    --civ.ui.text("City destroyed consolidated test")

end

-- On City Founded
function events.onCityFounded(city)
    if _global.eventTesting then
        civ.ui.text("consolidated.onCityFounded for "..city.name)
    end
    -- the cityCancelled() function is executed if the player
    -- decides not to found the city after all
    -- (so you can undo terrain changes, etc.
    local function cityCancelled()
        if _global.eventTesting then
            civ.ui.text("consolidated.onCityFounded city cancelled for "..city.name)
        end
    end
    return cityCancelled
end

-- On City Processed
function events.onCityProcessed(city)
    --civ.ui.text(city.name.." processed")

end

-- On city production (when a city produces a unit/improvement/wonder)
function events.onCityProduction(city,prod)
    --civ.ui.text(city.name.." has procuded something.")

end

-- On City Taken
-- (get conqueror by using city.owner)
function events.onCityTaken(city,defender)
    --civ.ui.text(city.name.." captured from the "..defender.name.." by the "..city.owner.name..". Consolidated Events.")

end


-- On Initiate Combat not included here 

-- On key press
function events.onKeyPress(keyCode)
    --if keyCode == keyboard.backspace then
    --    civ.ui.text("backspace pressed")
    --end

end

-- On Scenario Loaded
function events.onScenarioLoaded()
    --civ.ui.text("Scenario Loaded consolidated event")

end

-- On Negotiation 
-- Return true if the talker can contact the listener,
-- and false otherwise.
-- This is combined with the discrete events and the
-- legacy events, as well as a separate onNegotiation.lua file
-- If any of these return false, then negotiation is prevented
function events.onNegotiation(talker,listener)

    return true
end


-- On Schism 
-- Return true (default) if the tribe can schism,
-- and false otherwise.
-- This is combined with the discrete events and the
-- legacy events, as well as a separate onSchism.lua file
-- If any of these return false, then schism is prevented
function events.onSchism(tribe)

    return true
end

-- Between Turns
function events.onTurn(turn)
    --civ.ui.text("The turn is "..tostring(turn)..".")

end

-- On unit killed in combat
function events.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    --civ.ui.text("A "..loser.type.name.." has been defeated by a "..winner.type.name..".")

end
-- On unit defeated in combat or by some other event
function events.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    --civ.ui.text("unit defeated consolidated test")

end



-- After Production
function events.onCityProcessingComplete(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("consolidated.onCityProcessingComplete for turn "..tostring(turn).." and tribe "..tribe.name)
    end

end
-- Before Production
function events.onTribeTurnBegin(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("consolidated.onTribeTurnBegin for turn "..tostring(turn).." and tribe "..tribe.name)
    end

end

function events.onTribeTurnEnd(turn,tribe)
    if _global.eventTesting then
        civ.ui.text("consolidated.onTribeTurnEnd for turn "..tostring(turn).." and tribe "..tribe.name)
    end

end

-- On Game Ends
-- Return true if the game ends as normal,
-- and false otherwise.
-- This is combined with the discrete events and the
-- legacy events, as well as a separate onGameEnds.lua file
-- If any of these return false, then game end is prevented
-- Lua Function Reference Info:
--onGameEnds
--civ.scen.onGameEnds(function (reason) -> boolean) -> void
--
--Registers a function that is called when the game ends. `reason` is an integer between 1 and 6:
--1 and 2 - Space race victory. This does not trigger if `onCentauriArrival` has a callback registered.
--3 - Conquest victory
--4 - Defeat
--5 - Retirement
--6 - Macro ENDGAME action
--Return `true` to end the game, `false` to keep playing.
--
function events.onGameEnds(reason)

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
function events.onCanFoundCity(unit,advancedTribe)
    if _global.eventTesting then
        civ.ui.text("consolidated.onCanFoundCity for "..unit.type.name)
    end
    return true
end


-- onEnterTile(unit,previousTile)
-- executes when a unit successfully enters a tile (so not when it attacks
-- a unit or fails to enter a tile because it lacks movement points)
function events.onEnterTile(unit,previousTile)
    if _global.eventTesting then
        civ.ui.text("consolidated.onEnterTile: "..unit.type.name.." has entered tile ("..text.coordinates(unit.location)..") from tile ("..text.coordinates(previousTile)..").")
    end
end


-- onFinalOrderGiven(unit)
-- executes when a unit has been given its final order for the turn.
-- that is, when a new unit is active and the previous unit has spent
-- all its movement points
function events.onFinalOrderGiven(unit)
    if _global.eventTesting then
        civ.ui.text("consolidated.onFinalOrderGiven: "..unit.type.name.." has been given its order.")
    end
end




-- ===============================================================================
--
--          End of File
--
-- ===============================================================================

gen.versionFunctions(events,versionNumber,fileModified,"consolidatedEvents.lua")
return consolidator.maintainEvents(events)

