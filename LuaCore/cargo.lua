--  This module governs units transporting cargo,
--  including the following features
--  Land and Air units carrying cargo
--  Restricting aircraft carrier capacity and planes
--  Restricting cargo types 

local gen = require("generalLibrary")
local civlua = require("civlua")
local diplomacy = require("diplomacy")
local discreteEvents = require("discreteEventsRegistrar")
local text = require("text")

-- Change the @LANDFALL message so there is no option
-- to unload a ship by sailing into a land tile
--[[
@LANDFALL
@title=Disembark
Shall we disembark, Sire,
and leave the ships behind?

Stay With Ships
Make Landfall
--]]


-- cargoSettings[unitType.id] = {
--  .
--  .forbiddenCargo = nil or table of unitType
--      
