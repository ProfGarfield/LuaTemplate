
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



-- This file contains settings that can be defined relatively easily,
-- perhaps with a couple parameters or a single table
--

local param = require("parameters")
local object = require("object")
local gen = require("generalLibrary"):minVersion(1)

local simpleSettings = {}
gen.versionFunctions(simpleSettings,versionNumber,fileModified,"MechanicsFiles".."\\".."simpleSettings.lua")
gen.minEventsLuaVersion(1,1,"MechanicsFiles".."\\".."simpleSettings.lua")

-- False or nil settings mean use the behaviour for 'standard' Civ II

-- rehomeUnitsOnCityCapture     
--      If true, when a city is captured or destroyed,
--      the units which are homed to that city are rehomed
--      to the nearest city that has the extra capacity to support them,
--      rather than disbanded
--
simpleSettings.rehomeUnitsOnCityCapture = false

-- cancelWeLoveTheKing[i]
--      if true, cities with the government number i
--      will have the "We Love the King Day" flag
--      cleared during the onTurn event.
--      This could be useful for stopping republics and
--      democracies growing too fast, for example
--      Happens after triggerEvents.onTurn in case
--      you want to reward the tribe some other way
simpleSettings.cancelWeLoveTheKing = {}
simpleSettings.cancelWeLoveTheKing[0] = false
simpleSettings.cancelWeLoveTheKing[1] = false
simpleSettings.cancelWeLoveTheKing[2] = false
simpleSettings.cancelWeLoveTheKing[3] = false
simpleSettings.cancelWeLoveTheKing[4] = false
simpleSettings.cancelWeLoveTheKing[5] = false
simpleSettings.cancelWeLoveTheKing[6] = false


--  clearAdjacentAirProtectionAI
--  clearAdjacentAirProtectionHuman
--      Clear air protection for adjacent tiles when a unit
--      is activated (except for tiles/units owned by that player)
--      alternate settings for ai and humans, in case a distinction
--      is to be made
--
simpleSettings.clearAdjacentAirProtectionAI = false
simpleSettings.clearAdjacentAirProtectionHuman = false

-- uses events to select the next unit to activate
-- see gen.selectNextActiveUnit 
simpleSettings.enableCustomUnitSelection = false

-- provide an alternate weight function for selecting the next
-- active unit
-- see gen.selectNextActiveUnit
simpleSettings.customWeightFunction = nil

-- prevents AI Text archives from being deleted.
-- Not sure why you'd want this, but here it is
simpleSettings.doNotDeleteAITextArchives = nil

-- makes aircraft defend first when units with the
-- fighter ability attack air protected stacks
simpleSettings.fightersAttackAirFirst =  true


-- gen.activateRangeForLandAndSea(restoreRangeFn=nil,applyToAI=false)
-- restoreRangeFn(unit) --> bool governs when a unit's range is restored
-- and is checked when entering the tile and also after the unit has been
-- given its last order for the turn (i.e. when the unit has all movement
-- expended and the next unit is activated, or at the end of the turn if it
-- still has movement points e.g. if sleeping).  
-- If true, range is restored, if false it is not
-- By default, range is restored in city squares and on airbases
-- If you want to clear movement points (like for air units) do it in this function
-- Land and Sea units must now abide by range limitations set in rules.txt (if they are not 0)
-- if applyToAI is true, the AI will lose units when it violates these limits

simpleSettings.rangeForLandAndSea = false
if simpleSettings.rangeForLandAndSea then
    gen.activateRangeForLandAndSea(nil,false)
end



return simpleSettings
