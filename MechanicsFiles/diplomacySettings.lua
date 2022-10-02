
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file




local object = require("object")
local diplomacy = require("diplomacy")

local diplomacySettings = {}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(diplomacySettings,versionNumber,fileModified,"MechanicsFiles".."\\".."diplomacySettings.lua")
-- the units with these id numbers can't be given away
-- if the value is set to true
local forbiddenGiveAway = {}

-- uncomment to disallow diplomacy that is
-- not driven by lua events
--diplomacy.setEventTreatiesOnly("You may have received a message about a change in diplomacy.  This change has been undone.")


function diplomacySettings.forbidTileGiveaway(tile)
    if tile.owner ~= civ.getCurrentTribe() then
        return true
    end
    for unit in tile.units do
        if forbiddenGiveAway[unit.type.id] then
            civ.ui.text("Note that the "..unit.type.name.." on this tile can not be given away.  If you wish to give away the contents of this tile to another player, the "..unit.type.name.." must be moved or disbanded.")
            return true
        end
    end
    return false
end

-- if true, the tech with the ID number can't be transferred
-- forbiddenTechTransfer[techID]
local forbiddenTechTransfer = {}



diplomacySettings.forbiddenTechTransfer=forbiddenTechTransfer

diplomacySettings.giftTechNotTrade = {}
local j=1
for i=0,99 do
    if forbiddenTechTransfer[i] then
        diplomacySettings.giftTechNotTrade[j] = civ.getTech(i).name
        j=j+1
    end
end


function diplomacySettings.diplomacyMenu()
        local options = {forbidTileGiveaway = diplomacySettings.forbidTileGiveaway(civ.getCurrentTile()),giftTechNotTrade=diplomacySettings.giftTechNotTrade}
        diplomacy.diplomacyMenu(options)
end

return diplomacySettings
