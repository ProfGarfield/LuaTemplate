
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--
local traits = require("traits")
local combatMod = {}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(combatModifiers,versionNumber,fileModified,"LuaCore".."\\".."combatModifiers.lua")
--
-- modification string has the following structure:
-- first char: +,*,-,=,~
-- remainder: number, number with percent, modificationName
-- Meaning and computation order
--      ~modificationName
--          ignore the modification associated with modificationName
--      ^
--



-- consider the attacking unit's type, tribe, tribe's techs, tribe's wonders
-- the improvements of the city the attacker is in, the terrain the attacker is on
--
-- consider the defending unit's type, tribe, tribe's techs, tribe's wonders,
-- the improvements of the city the defender is in, the terrain the defender is on
--
-- If the 

function combatMod.attacker(attackerTraits,defenceTraits,modificationString,modificationName)




return combatMod
