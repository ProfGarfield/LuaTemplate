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
local consolidator = require("consolidator")
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
--      from consolidator.lua



-- Unit Activation
function events.onActivateUnit(unit,source)
    --civ.ui.text("Unit activation consolidated test")

end


-- On Unit Bribery
function events.onBribeUnit(unit,previousOwner)
    --civ.ui.text("Bribe unit test")

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
    --civ.ui.text("City destroyed")

end

-- On City Founded
function events.onCityFounded(city)
    --civ.ui.text("City founded")

end

-- On city production (when a city produces a unit/improvement/wonder)
function events.onCityProduction(city,prod)
    --civ.ui.text(city.name.." has procuded something.")

end

-- On City Taken
-- (get conqueror by using city.owner)
function events.onCityTaken(city,defender)
    --civ.ui.text(city.name.." captured from the "..defender.name.." by the "..city.owner.name..".")

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
    --civ.ui.text("Scenario Loaded")

end

-- On Negotiation not included here


-- On Schism not included here

-- Between Turns
function events.onTurn(turn)
    --civ.ui.text("The turn is "..tostring(turn)..".")

end

-- On unit killed in combat
-- use the events in onUnitKilled.lua if you need other unit death events
function events.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    --civ.ui.text("A "..loser.type.name.." has been defeated by a "..winner.type.name..".")

end


-- After Production
-- Not yet linked
function events.afterProduction(turn,tribe)
    --civ.ui.text("After production for turn "..tostring(turn).." and tribe "..tribe.name)
    

end

-- Before Production
-- Not yet linked
function events.beforeProduction(turn,tribe)
    --civ.ui.text("Before production for turn "..tostring(turn).." and tribe "..tribe.name)

end




-- ===============================================================================
--
--          End of File
--
-- ===============================================================================

return consolidator.maintainEvents(events)

