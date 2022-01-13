
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
-- This is available with games started as an extended original game,
-- but not with games started as a standard game (I think, this hasn't been looked at too closely)
function events.onCentauriArrival(tribe)

end

-- City destruction
function events.onCityDestroyed(city)

end

-- On City Founded
function events.onCityFounded(city)

end

-- On City Processed
function events.onCityProcessed(city)

end

-- On city production (when a city produces a unit/improvement/wonder)
function events.onCityProduction(city,prod)

end

-- On City Taken
-- (get conqueror by using city.owner)
function events.onCityTaken(city,defender)

end

-- On Game Ends
-- Return true if the game ends as normal,
-- and false otherwise.
-- This is combined with the discrete events and the
-- legacy events, as well as a separate onGameEnds.lua file
-- If any of these return false, then game end is prevented
-- Not documented or experimented with much
-- based on legacy event engine code, reason is an integer
function events.onGameEnds(reason)

    return true
end

-- On Initiate Combat not included here 


-- On key press
function events.onKeyPress(keyCode)

end

-- On Scenario Loaded
function events.onScenarioLoaded()

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

end


-- On unit killed in combat
function events.onUnitKilled(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)

end

-- On unit defeated in combat or by some other event
function events.onUnitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)

end

-- After Production
function events.onCityProcessingComplete(turn,tribe)

end
-- After Production -- Deprecated, use onCityProcessingComplete
function events.afterProduction(turn,tribe)

end


-- Before Production 
function events.onTribeTurnBegin(turn,tribe)

end

-- Before Production -- Deprecated, use onTribeTurnBegin
function events.beforeProduction(turn,tribe)

end

-- Tribe turn end 
function events.onTribeTurnEnd(turn,tribe)

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
