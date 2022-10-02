--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- You may wish to consider changing combat stats in initiateCombat instead of this module.

local attackBonus = require("attackBonus")

local object = require("object")


-- defaultAttackTable[unitType.id]=integer
-- gives the attack value of the unit type without a bonus. Only necessary for
-- units that might receive a bonus, but no problem if all use it

local defaultAttackTable = {}

-- comment out the next line if you wish to use the categoryAttackBonus instead
local simpleAttackBonusTable = {}
-- uncomment this line if you wish to use the categoryAttackBonus instead
-- local categoryAttackBonusTable = {}



local function atkBonus(activeUnit)
    attackBonus.simpleAttackBonus(activeUnit,simpleAttackBonusTable,defaultAttackTable)
    -- if you wish to use the category attack bonus, comment out the above line, and
    -- uncomment the following one
    --attackBonus.categoryAttackBonus(activeUnit,categoryAttackBonusTable,defaultAttackTable)
end

local ab = {attackBonus = atkBonus}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(ab,versionNumber,fileModified,"MechanicsFiles".."\\".."attackBonusSettings.lua")
return ab
