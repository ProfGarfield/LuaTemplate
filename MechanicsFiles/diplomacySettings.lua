
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


---@module "diplomacy"
local diplomacy = require("diplomacy"):minVersion(2)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
local object = require("object")


local diplomacySettings = {}
gen.versionFunctions(diplomacySettings,versionNumber,fileModified,"MechanicsFiles".."\\".."diplomacySettings.lua")


-- Tribes can be forbidden from changing their treaties through 
-- negotiation by using the function
-- diplomacy.disableEndogenousTreatyChange(tribe1,tribe2)
-- And enabling it again can be done with
-- diplomacy.enableEndogenousTreatyChange(tribe1,tribe2)
-- Ordinarily, the default position is that tribes can change their
-- treaties through negotiation.  However, if you want the default
-- position to be that tribes can't change their treaties through
-- negotiation, you can call the following function
-- diplomacy.disableEndogenousTreatyChangeByDefault(tribe1,tribe2)
-- You will have to call this function for each pair of tribes
-- that you want to have this default position.
-- p.s. The word endogenous means "from within" or "internal"
-- and refers to the fact that the treaty change is coming from
-- within the game, rather than from a lua event.
-- 

-- Uncomment this code if you want all endogenous treaty changes
-- disabled by default
--[[
for tribe1ID=1,gen.c.maxTribeID do
    for tribe2ID = tribe1ID+1,gen.c.maxTribeID do
        diplomacy.disableEndogenousTreatyChangeByDefault(tribe1ID,tribe2ID)
    end
end
--]]

--example of disabling endogenous treaty changes between tribes 1 and 2
--diplomacy.disableEndogenousTreatyChangesByDefault(civ.getTribe(1),civ.getTribe(2))



--[[
stopTechTransferTable[techObject.id] = {
    * noPrereqs = bool
        - If true, then the tech can't be given or traded to another tribe, or conquered, or stolen, if the receiving tribe doesn't have the tech's prerequisites.
        - If false (or nil), a tribe can receive the tech even if it  doesn't have the tech's prerequisites.
    * noTrade = bool
        - If true, then the tech can't be given or traded to another tribe.
        - If false (or nil), a tribe can receive the tech through diplomacy.
    * noConquest = bool
        - If true, then the tech can't be received by conquering a city.
        - If false (or nil), a tribe can receive the tech by conquering a city.
    * noTheft = bool
        - If true, then the tech can't be stolen with a diplomat or spy.
        - If false (or nil), a tribe can steal the tech.
    }
    If there is no value for a particular tech object, then all these
    values are considered false
]]
local stopTechTransfer = {}

-- examples
--[[
stopTechTransfer[gen.original.aAdvancedFlight.id] = {noPrereqs = false, noTrade = false, noConquest = false, noTheft = true}

stopTechTransfer[gen.original.aSpaceFlight.id] = {noPrereqs = true, noTrade = false, noConquest = false, noTheft = false}
--]]

-- Build functions to register from the stopTechTransferTable
-- You can, of course, build different functions to register
-- instead.
local forbidTechTradeFn, forbidTechFromConquestFn, forbidTechFromTheftFn = diplomacy.techTransferTableToFunctions(stopTechTransfer)



--Register a function to determine whether a tribe can receive a technology from another tribe through diplomacy.<br><br>
-- forbidTechTrade(tech,receiverTribe,giverTribe)-->bool
-- If true, the `giverTribe` can't give or trade the tech
-- to the `receiverTribe`. (Either in in-game negotiations, or
-- using the diplomacy module's gift system.)
-- If false (or nil), the `giverTribe` can give or trade the tech
-- to the `receiverTribe`.
diplomacy.registerForbidTechTradeFunction(forbidTechTradeFn)


-- Register a function to determine whether a tribe can receive a technology when conquering another tribe's city.<br><br>
--  forbidTechFromConquest(tech,conqueringTribe,losingTribe)-->bool
--      If true, the `conqueringTribe` can't receive the `tech`
--      from the `losingTribe` as a result of conquering a city
--      owned by the `losingTribe`.
--      If false (or nil), the `conqueringTribe` can receive the `tech`
--      from the `losingTribe` as a result of conquering a city
--      owned by the `losingTribe`.
diplomacy.registerForbidTechFromConquestFunction(forbidTechFromConquestFn)

-- Register a function to determine whether a tribe can
-- steal a technology using a diplomatic (role 6) unit.
-- forbidTechTheft(tech,thievingTribe,thievingUnit)-->boolean
--      If true, the `thievingTribe` can't steal the `tech`
--      from another tribe using the `thievingUnit` (if it has 
--      role 6 for diplomatic units).
--      If false (or nil), the `thievingTribe` can steal the `tech`.
--      (The giving tribe can't be specified, because there isn't a
--      way to control which tribe the spy or diplomat steals from.)
diplomacy.registerForbidTechTheftFunction(forbidTechFromTheftFn)

-- Return true if the `givingTribe` can give the units and/or city on `tile` to the
-- `receivingTribe`, and false if it can't.
-- (This is called when a player uses the gift menu.)
-- If the `givingTribe` doesn't own the tile, then the menu will
-- prevent the transaction, regardless of the result of this function
---@param tile tileObject
---@param givingTribe tribeObject
---@param receivingTribe tribeObject
---@return boolean
local function tribeCanGiveAwayTile(tile,givingTribe,receivingTribe)
    return true
end

-- in this example, the tribe can't give away tiles that
-- have mech infantry units on them
--[[
tribeCanGiveAwayTile = function(tile,givingTribe,receivingTribe)
    if gen.unitTypeOnTile(tile,gen.original.uMechInf) then
        return false
    else
        return true
    end
end
--]]

--Register a function to determine whether a tribe can give away a tile to another tribe.<br><br>
-- tribeCanGiveAwayTile(tile,givingTribe,receivingTribe)-->bool
--      If true, the `givingTribe` can give the units and/or city on `tile` to the
--      `receivingTribe`.
--      If false (or nil), the `givingTribe` can't give the units and/or city on `tile` to the
--      `receivingTribe`.
diplomacy.registerCanGiveAwayTileFn(tribeCanGiveAwayTile)


--[[
Registers a function(giftGiver,giftReceiver) that determines whether the `giftGiver` can give a gift to the `giftReceiver` through the gift giving menu.

If the function returns true, then the giftReceiver will be an option in
the gift giving menu for giftGiver.
]]
-- In this example, the gift giver can't give a gift to the barbarians
--[[
diplomacy.registerCanGiveGiftFunction(function(giftGiver,giftReceiver)
    return giftReceiver.id ~= 0
end)
--]]





function diplomacySettings.diplomacyMenu()
    diplomacy.giveGiftMenu()
end

return diplomacySettings