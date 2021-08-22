
-- you can cut and paste these template functions into
-- consolidatedEvents.lua in order to access the corresponding
-- functionality.  This file also contains some "behind the scenes"
-- code to make consolidatedEvents work well, and no clutter that
-- file with code that shouldn't be changed
--


-- ===============================================================================
--
--          Execution Points
--
-- ===============================================================================
local events = {}

-- Unit Activation
function events.onActivateUnit(unit,source)

end

-- On Unit Bribery
function events.onBribeUnit(unit,previousOwner)

end

-- On calculate City Yield not included here

-- On Can Build not included here

-- On Centauri Arrival
function events.onCentauriArrival(tribe)

end

-- City destruction
function events.onCityDestroyed(city)

end

-- On City Founded
function events.onCityFounded(city)

end

-- On city production (when a city produces a unit/improvement/wonder)
function events.onCityProduction(city,prod)

end

-- On City Taken
-- (get conqueror by using city.owner)
function events.onCityTaken(city,defender)

end

-- On Game Ends
-- Not included, since not documented/experimented with
--
-- On Initiate Combat not included here 


-- On key press
function events.onKeyPress(keyCode)

end

-- On Scenario Loaded
function events.onScenarioLoaded()

end

-- On Negotiation not included here

-- On Schism not included here
--

-- Between Turns
function events.onTurn(turn)

end


-- On unit killed in combat
-- use the events in onUnitKilled.lua if you need other unit death events
function events.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)

end

-- After Production
function events.afterProduction(turn,tribe)

end

-- Before Production
function events.beforeProduction(turn,tribe)

end




-- ===============================================================================
--
--          House Keeping
--
-- ===============================================================================

-- if an execution point function doesn't exist in eventsTable, the empty function
-- defined in events will be used instead.  In this way, functions can be omitted
-- from consolidatedEvents.lua

local consolidator = {}
function consolidator.maintainEvents(eventsTable)
    for key, func in pairs(events) do
        eventsTable[key] = eventsTable[key] or events[key]
    end
    return eventsTable
end

return consolidator
