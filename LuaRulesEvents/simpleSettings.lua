-- This file contains settings that can be defined relatively easily,
-- perhaps with a couple parameters or a single table
--

local param = require("parameters")
local object = require("object")

local simpleSettings = {}

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





return simpleSettings
