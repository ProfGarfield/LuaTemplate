
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local readRules = require("readRules"):minVersion(1)
--      This module allows for setting cosmic and cosmic like parameters
--      (e.g. impassable terrain, road multiplier) for 
--      individual unit types

local unitCosmic = {}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(unitCosmic,versionNumber,fileModified,"LuaCore".."\\".."unitCosmic.lua")



--
-- unitCosmic[unitType.id] = {
--  .impassable = nil or {[baseTerrainObject]=bool or nil or function(unit) --> bool or nil}
--      if true, terrain is impassable to unitType, if false, it is not
--      nil means use "default", either for terrain type, or impassable in general
--  .moveCost = nil or {[baseTerrainObject]=integer or nil or function(unit) --> integer or nil}
--      terrain costs this much for this unit type to cross
--      nil means use "default"
--  .paradropRange = nil or integer or function(unit) --> integer or nil
--      specifies the paradrop range for this unit
--      nil means use "default"
--  .triremeLost = nil or integer or function(unit) --> integer or nil
--      specifies the base 1/x chance of a trireme being lost at sea
--  .roadMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the road multiplier for this unit
--      nil means use default
--  .alpineMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the alpine multiplier for this unit
--      nil means use default
--  .railroadMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the railroad multiplier for this unit
--      nil means use default
--  .riverMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the river multiplier for this unit
--      nil means use default
-- }
--
--  provides default values for the different
--  universal parameters in the game
--  nil means use the rules.txt to get the value
-- unitCosmic["default"] = {
--  .impassable = nil or {[baseTerrainObject]=bool or nil or function(unit) --> bool or nil}
--      if true, terrain is impassable to unitType, if false, it is not
--  .moveCost = nil or {[baseTerrainObject]=integer or nil or function(unit) --> integer or nil}
--      terrain costs this much for this unit type to cross
--  .paradropRange = nil or integer or function(unit) --> integer or nil
--      specifies the paradrop range for this unit
--  .triremeLost = nil or integer or function(unit) --> integer or nil
--      specifies the base 1/x chance of a trireme being lost at sea
--  .roadMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the road multiplier for this unit
--  .alpineMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the alpine multiplier for this unit
--  .railroadMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the railroad multiplier for this unit
--  .riverMultiplier = nil or integer or function(unit) --> integer or nil 
--      specifies the river multiplier for this unit
--
-- }
--

local suppliedUnitCosmic = {}

function unitCosmic.registerUnitCosmic(uCosmicTable)
    if type(uCosmicTable) ~= "table" then
        error("unitCosmic.registerUnitCosmic: argument must be a table.  Received: "..tostring(uCosmicTable))
    end
    suppliedUnitCosmic = uCosmicTable
end

local rulesDefault = {}
local baseRules = readRules.loadedRules
local numberOfTerrainTypesLine = {[0] = "NumberOfTerrainTypes","11","11","11","11"}
if baseRules["@COSMIC2"] then
    for _, tableLine in pairs(baseRules["@COSMIC2"]) do
        if string.lower(tableLine[0]) == "numberofterraintypes" then
            numberOfTerrainTypesLine = tableLine
            break
        end
    end
end
local _,_,maps = civ.getAtlasDimensions()




local internalUnitCosmic = {}

