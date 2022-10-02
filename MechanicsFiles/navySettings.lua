--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- Settings for the navy module
local object = require("object")
local gen = require("generalLibrary"):minVersion(1)
local navy = require("navy"):minVersion(1)
local readRules = require("readRules"):minVersion(1)


-- This module implements features related to ships:
--  When can ships unload onto beaches
--  What planes can use which carriers
--

-- shipCapacityList[unitType.id] = nil or integer
-- supplies the default carrying capacity of each ship
-- if nil, the unit always has a capacity of 0
local shipCapacityList = navy.buildShipCapacityListFrom(readRules.loadedRules)
navy.registerShipCapacityList(shipCapacityList)



-- Unloading Units onto beaches
-- Both the ship doing the unloading and the unit
-- being unloaded must satisfy these conditions
-- in order to be activated
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
-- Loading Units onto ships:
-- The unit and the ship type must both satisfy the
-- conditions, which are determined based on the location
-- of the unit attempting to board the ship
-- (if the unit can't board a ship type, the type's carrying capacity
-- will be set to 0)
--These restrictions may not hold for the AI
-- beachShipSettings[unitType.id] = {
--  .restrictBeachUnload = boolean or number or nil
--      if false or nil, unit can unload onto any beach
--      if true, unit can never unload onto a "beach"
--      (but might be able to unload beside a foreign port, see below)
--      if 0 or positive number, the unit can not have expended
--      more than that many "full" movement points.  That is, can only unload if
--      unit.moveSpent <= beachShipSettings[unit.type.id].restricBeachUnload*totpp.movementMultipliers.aggregate
--      if negative number, the unit can not have expended more than
--      that many 'atomic' movement points, that is
--      unit.moveSpent <= -beachShipSettings[unit.type.id].restricBeachUnload
--
--  .restrictPeacePortUnload = boolean or number or nil
--      if false or nil, the unit can unload from a square adjacent to a city
--      owned by a civ with which the player is at peace (or allied) without penalty,
--      even if restrictBeachUnload is true
--      if true, the unit can only unload if it can unload onto a "beach"
--      if 0 or positive number, the unit can not have expended
--      more than that many "full" movement points.  That is, can only unload if
--      unit.moveSpent <= beachShipSettings[unit.type.id].restricPeacePortUnload*totpp.movementMultipliers.aggregate
--      if negative number, the unit can not have expended more than
--      that many 'atomic' movement points, that is
--      unit.moveSpent <= -beachShipSettings[unit.type.id].restricPeacePortUnload
--
--  .restrictAlliedPortUnload = boolean or number or nil
--      if false or nil, the unit can unload from a square adjacent to a city
--      owned by a civ with which the player is allied without penalty,
--      even if restrictBeachUnload and restrictPortUnload are true
--      if true, the unit can only unload if it can unload onto a "beach" or peace port
--      if 0 or positive number, the unit can not have expended
--      more than that many "full" movement points.  That is, can only unload if
--      unit.moveSpent <= beachShipSettings[unit.type.id].restricAlliedPortUnload*totpp.movementMultipliers.aggregate
--      if negative number, the unit can not have expended more than
--      that many 'atomic' movement points, that is
--      unit.moveSpent <= -beachShipSettings[unit.type.id].restricAlliedPortUnload
--
--  .beachUnloadPenalty = function(unit)-->void or number or nil
--      if nil, nothing is done when unloading the unit
--      if number is 0 or positive, set the moveSpent of that unit so that
--      that many full movement points are expended, unless more have already been expended
--      i.e.
--      unit.moveSpent = math.max(unit.moveSpent, beachShipSettings[unit.type.id].beachUnloadPenalty*totpp.movementMultipliers.aggregate)
--      if number is negative, set the move spent so that many atomic movement units have been spent
--      if function, that function will be run for the unit unloaded, then for the ship carrying it
--      If different behaviour is desired for unloading beside a port, check for that and change the
--      penalty applied within the function
--
--  .unloadCheckFunction = nil or function(unit) --> boolean
--      if function, the unit can only unload if the function returns true
--      (and all other conditions are met)
--      nil means no extra condition
--  
--  .unloadFailureMessage = nil or string or function(unit) --> string
--      Message to show if the unit can't unload.
--      The message for the ship is shown at the top of the message
--      box, and the message for the cargo is shown below that
--      if nil, a generic message is shown.
--      If string, the string is shown, with %STRING1 replaced by the unit
--      type name.
--      If function, the returned string is used for the message, with
--      %STRING1 replaced by the unit type name
--
--  .forbidBeachBoarding = nil or boolean
--      If true, a unit can't get onto a ship from the "beach",
--      unless that unit is adjacent to a city at peace or allied
--      with the unit's owner
--      false or nil means it can

--  .forbidPeacePortBoarding = nil or boolean
--      If true, a unit can't get onto a ship from a tile
--      adjacent to a city with which it is at peace with
--      (unless forbidBeachBoarding isn't active)
--      false or nil means the unit can load from a tile
--      adjacent to a city with which the owner is at peace
--
--  .forbidAlliedPortBoarding = nil or boolean
--      if true, a unit can't get onto a ship from a tile
--      adjacent to an ally's city (unless it is allowed to
--      board a ship from a beach or peace port)
--
--  .boardingCheckFunction = nil or function(boardingUnit,shipType) --> boolean
--      if nil, ignore this condition
--      if a function and it returns true, the unit can board (if other conditions
--      allow it).  If the function returns false, the unit can't board
--      The boardingUnit is the unit checking if it can board a ship, and
--      the ship type is the unit type that may be boarded
--
--  forbidBoarding = nil or table of unit types
--      units in this table (if it is supplied) can't board this transport
--      type, or this type of unit can't board the transport types listed
--      (depending on whether this setting is for a land unit or 
--      sea transport)
--      This is achieved by clearing the sleep status of any invalid cargo
--      when a ship is activated within a city (as well as forbidding the
--      other types of boarding)
--

local beachShipSettings = {}
--[[
-- Here are some testing examples
beachShipSettings[gen.original.uTrireme.id] = {
    restrictBeachUnload = true,
    restrictPeacePortUnload = true,
    restrictAlliedPortUnload = true,
    forbidBeachBoarding = true,
    forbidPeacePortBoarding = true,
    forbidAlliedPortBoarding = true,
    unloadFailureMessage = "%STRING1 units can only disembark units within a city."
}

beachShipSettings[gen.original.uMechInf.id] = {
    restrictBeachUnload = true,
    restrictPeacePortUnload = true,
    forbidBeachBoarding = true,
    unloadFailureMessage = "%STRING1 units can only disembark within a city, or beside an allied city.",
}

beachShipSettings[gen.original.uGalleon.id] = {
    restrictBeachUnload = 0,
    restrictPeacePortUnload = 2,
    restrictAlliedPortUnload = 3,
    beachUnloadPenalty = 2,
    unloadFailureMessage = "%STRING1 units can only disembark units onto a beach if they haven't moved, can only disembark units beside a city with whom they are at peace if they have not moved more than 2 spaces, and can't disembark units beside allied cities unless they haven't moved more than 3 spaces."
}

--beachShipSettings[gen.original.uArmor.id] = {
--    restrictBeachUnload = -3,
--    restrictPeacePortUnload = -6,
--    beachUnloadPenalty = -4,
--}

beachShipSettings[gen.original.uArchers.id] = {
    boardingCheckFunction = function(boardingUnit,shipType)
        return shipType == gen.original.uCaravel 
    end
    -- archers can only board a caravel outside of port
}

beachShipSettings[gen.original.uArmor.id] = {
    restrictBeachUnload = -3,
    restrictPeacePortUnload = -6,
    beachUnloadPenalty = function(unit) unit.damage = unit.damage+5 end,
    -- note, repeatedly activating the unit will cause more damage each time
    -- with this setup unit.damage = math.max(unit.damage,5) would be an alternative,
    -- as would keeping track of units already activated this turn
}

beachShipSettings[gen.original.uLegion.id] = {
    forbidBoarding = {gen.original.uFrigate},
}
beachShipSettings[gen.original.uFrigate.id] = {
    forbidBoarding = {gen.original.uMusketeers}
}
--]]



-- Carrier Units
-- If a unit is not within the carrierSettings table, it will either always
-- be a carrier, or never be a carrier
-- carrierSettings[unitType.id] = table with keys:
--  canNotUse = nil or table of unit types
--      units in this table can not land on the specified carrier
--      (if the unit is land/sea, this means the carrier does not have
--      carrier status when that unit is activated)
--  setPropertyFor = nil or table of tribes
--      the carrier property is always enabled for these tribes
--      (You can avoid air protected stacks for carriers by using
--      this and assigning a different carrier unit type to each tribe/alliance)
--      (note that range 0 or 1 units don't provide air stack anyway)
--  clearPropertyFor = nil or table of tribes
--      the carrier property is always disabled for these tribes
--      (not sure why you'd want this)
--  hold = integer or nil
--      The carrier can hold this many aircraft
--      nil means unlimited capacity


local carrierSettings = {}
--[[
carrierSettings[gen.original.uCarrier.id] = {
    canNotUse = {gen.original.uBomber, gen.original.uStlthBmbr, gen.original.uNuclearMsl},
    setPropertyFor = {civ.getTribe(2),civ.getTribe(3)},
    clearPropertyFor = {civ.getTribe(4)},
    hold = 1,
}
carrierSettings[gen.original.uTrireme.id] = {
    canNotUse = {gen.original.uBomber, gen.original.uStlthBmbr, gen.original.uStlthFtr},
}
--]]



navy.registerBeachShipSettings(beachShipSettings)
navy.registerCarrierSettings(carrierSettings)
-- uncomment this line if you want these settings to apply to the AI
-- This is not tested, some parts might not apply to the AI anyway
-- (I think the AI will still be able to land on beaches as normal),
-- and the AI might not understand how it is supposed to do things
-- (it might have difficulty with not being able to load from a beach)
-- navy.applySettingsToAI()

local navySettings = {}
gen.versionFunctions(navySettings,versionNumber,fileModified,"MechanicsFiles".."\\".."navySettings.lua")
return navySettings


