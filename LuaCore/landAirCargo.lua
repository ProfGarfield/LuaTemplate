--
local versionNumber = 0
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--  This module allows land and air units to carry cargo
--  and controls the details

local gen = require("generalLibrary"):minVersion(1)
local civlua = require("civlua")
local diplomacy = require("diplomacy")
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local text = require("text")

local cargo = {}
gen.versionFunctions(cargo,versionNumber,fileModified,"LuaCore".."\\".."landAirCargo.lua")


