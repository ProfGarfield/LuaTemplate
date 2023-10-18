
--
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(9)

---@module "text"
local text = require("text"):minVersion(5)

local civlua = require("civlua")

---@module "data"
local data = require("data")

---@module "discreteEventsRegistrar"
local discreteEvents = require("discreteEventsRegistrar")


local changeRules = require("changeRules")

---@class diplomacy
local diplomacy = {}

gen.versionFunctions(diplomacy,versionNumber,fileModified,"LuaCore".."\\".."diplomacy.lua")
gen.minEventsLuaVersion(9, 1, "LuaCore\\diplomacy.lua")


local diplomacyState = "notLinked"

local function initializeExpectedTreaties(expectedTreatiesTable)
    if expectedTreatiesTable then
        return expectedTreatiesTable
    end
    expectedTreatiesTable = {}
    for senderTribeID=0,7 do
        expectedTreatiesTable[senderTribeID]={}
        for receiverTribeID = 0,7 do
            expectedTreatiesTable[senderTribeID][receiverTribeID]=0
        end
    end
    return expectedTreatiesTable
end

local function linkState(tableInState)
    if type(tableInState)~="table" then
        error("diplomacy.linkState takes a table as an argument.")
    else
        diplomacyState = tableInState
    end
    diplomacyState.diplomaticOffers = diplomacyState.diplomaticOffers or {}
    diplomacyState.expectedTreaties = initializeExpectedTreaties(diplomacyState.expectedTreaties)
end
diplomacy.linkState = linkState

discreteEvents.linkStateToModules(function (stateTable, stateTableKeys)
    local keyName = "diplomacyState"
    if stateTableKeys[keyName] then
        error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
    else
        stateTableKeys[keyName] = true
    end
    -- link the state table to the module
    stateTable[keyName] = stateTable[keyName] or {}
    linkState(stateTable[keyName])
end)


-- checkSymmetricBit1(int1,int2,bitNumber,errorMessage)-->bool
-- if the bitNumber'th bit in int1 and int2 are both 1,
-- then return true
-- if they are both 0, then return false,
-- if they are different, then return an error
local function checkSymmetricBit1(int1,int2,bitNumber,errorMessage)
    local int1Bit = gen.isBit1(int1,bitNumber)
    local int2Bit = gen.isBit1(int2,bitNumber)
    if int1Bit == int2Bit then
        return int1Bit
    else
        -- bits are not symmetric
        error(errorMessage)
    end
end

local function dataSuffix(tribe1,tribe2)
    if civ.isTribe(tribe1) then
        tribe1=tribe1.id
    end
    if civ.isTribe(tribe2) then
        tribe2 = tribe2.id
    end
    if type(tribe1) ~= "number" then
        error("diplomacy.dataSuffix: tribe1 must be a tribe object or a tribe ID")
    end
    if type(tribe2) ~= "number" then
        error("diplomacy.dataSuffix: tribe2 must be a tribe object or a tribe ID")
    end
    if tribe1< tribe2 then
        return tribe1.."_"..tribe2
    else
        return tribe2.."_"..tribe1
    end
end

local endogenousFlagsDefined = false

local endogenousFlagDefaults = {}
for i=0,gen.c.maxTribeID do
    for j = i+1,gen.c.maxTribeID do
        endogenousFlagDefaults[i.."_"..j] = true
    end
end

--[[
Calling this function prevents `tribe1` and `tribe2` from changing their treaty status with each other through diplomacy.  If they change
their treaty status, events will undo the change at the earliest opportunity.  All treaty changes will have to be made using the diplomacy module.
The function `diplomacy.enableEndogenousTreatyChanges` can be used to re-enable treaty changes through diplomacy.
Vendetta and Embassy status can still be changed.
    ]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.disableEndogenousTreatyChanges(tribe1,tribe2)
    if not endogenousFlagsDefined then
        error("diplomacy.disableEndogenousTreatyChanges: This function can only be called during a scenario execution point, and not during initialization.  You might want to use the function diplomacy.disableEndogenousTreatyChangesByDefault instead.")
    end
    if not civ.isTribe(tribe1) or not civ.isTribe(tribe2) then
        error("diplomacy.disableEndogenousTreatyChanges: tribe1 and tribe2 must be tribe objects")
    end
    data.flagSetFalse("endogenousTreatyChangesEnabled_"..dataSuffix(tribe1,tribe2),"diplomacy")
end

--[[
Calling this function enables `tribe1` and `tribe2` to change their treaty status with each other through diplomacy.  This ability
may have been disabled by a call to `diplomacy.disableEndogenousTreatyChanges`, or it may have been disabled by default (see `diplomacy.disableEndogenousTreatyChangesByDefault`).
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.enableEndogenousTreatyChanges(tribe1,tribe2)
    if not endogenousFlagsDefined then
        error("diplomacy.enableEndogenousTreatyChanges: This function can only be called during a scenario execution point, and not during initialization.  The function diplomacy.disableEndogenousTreatyChangesByDefault is available, though since you are calling this function, you probably want to refrain from calling it somewhere.")
    end
    if not civ.isTribe(tribe1) or not civ.isTribe(tribe2) then
        error("diplomacy.enableEndogenousTreatyChanges: tribe1 and tribe2 must be tribe objects")
    end
    data.flagSetTrue("endogenousTreatyChangesEnabled_"..dataSuffix(tribe1,tribe2),"diplomacy")
end

--[[
Calling this function changes whether `tribe1` and `tribe2` can change their treaty status with each other through diplomacy.  Ordinarily, the
ability to change treaty status is enabled by default (in which case this function restores the default behaviour after a call to `diplomacy.disableEndogenousTreatyChanges`).  However, if `diplomacy.disableEndogenousTreatyChangesByDefault` was called during initialization, then the ability to change treaty status is disabled by default (in which case this function restores the default behaviour after a call to `diplomacy.enableEndogenousTreatyChanges`).
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.resetEndogenousTreatyChanges(tribe1,tribe2)
    if not endogenousFlagsDefined then
        error("diplomacy.resetEndogenousTreatyChanges: This function can only be called during a scenario execution point, and not during initialization.")
    end
    if not civ.isTribe(tribe1) or not civ.isTribe(tribe2) then
        error("diplomacy.resetEndogenousTreatyChanges: tribe1 and tribe2 must be tribe objects")
    end
    data.flagReset("endogenousTreatyChangesEnabled_"..dataSuffix(tribe1,tribe2),"diplomacy")
end

--[[
Call this function in diplomacySettings.lua to disable the ability of `tribe1` and `tribe2` to change their treaty status with each other through diplomacy by default.  This is useful if you want to use the diplomacy module to control all treaty changes, and you don't want the AI to change treaties on its own.  You can use `diplomacy.enableEndogenousTreatyChanges` if you want two tribes to be able to change their treaty status with each other through diplomacy during
part of your scenario.
Vendetta and Embassy status can still be changed.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.disableEndogenousTreatyChangesByDefault(tribe1,tribe2)
    if endogenousFlagsDefined then
        error("diplomacy.disableEndogenousTreatyChangesByDefault: The flags governing endogenous treaty changes have already been defined.  You must call this function before calling diplomacy.defineEndogenousFlags.  You should be able to call this function in the file MechanicsFiles\\diplomacySettings.lua.  This function can never be called as part of an actual event.")
    end
    endogenousFlagDefaults[dataSuffix(tribe1,tribe2)] = false
end

--[[Returns true if `tribe1` and `tribe2` are allowed to change their treaty status with each other through diplomacy.  This is the default behaviour, but it can be changed by calling `diplomacy.disableEndogenousTreatyChangesByDefault` in diplomacySettings.lua.  It can also be changed by calling `diplomacy.disableEndogenousTreatyChanges` or `diplomacy.enableEndogenousTreatyChanges` as part of normal events.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
---@return boolean
function diplomacy.canTribesChangeTreatiesEndogenously(tribe1,tribe2)
    return data.flagGetValue("endogenousTreatyChangesEnabled_"..dataSuffix(tribe1,tribe2),"diplomacy")
end



--[[
It is not expected that the scenario designer will need to use this function.

This function is called in events.lua to define the flags that allow
the diplomacy module to keep track of whether two tribes can change
their treaty status with each other through diplomacy.

It is called in events.lua (instead of in diplomacy.lua) so that
`diplomacy.disableEndogenousTreatyChangesByDefault` can be called
in diplomacySettings.lua before the flags are defined, which
allows the default value to be set to false for some tribes.
    ]]
function diplomacy.defineEndogenousFlags()
    for i=0,gen.c.maxTribeID do
        for j = i,gen.c.maxTribeID do
            data.defineModuleFlag("diplomacy","endogenousTreatyChangesEnabled_"..i.."_"..j,
            endogenousFlagDefaults[i.."_"..j])
        end
    end
    endogenousFlagsDefined = true
end

---@type string|nil|false
local eventTreatiesMessage = "You may have received a message that the %STRING1 and %STRING2 have changed their treaty status.  This has been undone."

--[[
Sets the message that is displayed when a treaty change is undone.
%STRING1 and %STRING2 are replaced with the names of the tribes that
changed their treaty status.
Calling this function with a value of nil or false will prevent a message
from being displayed.
The default value is "You may have received a message that the %STRING1 and %STRING2 have changed their treaty status.  This has been undone."
]]
---@param message string|nil|false
function diplomacy.setDiplomacyReversalMessage(message)
    eventTreatiesMessage = message
end

--[[
The scenario designer should not need to call this function.
Checks the treaties between tribes and compares them to expectations.
If tribes are not allowed to change their treaty status with each other
through diplomacy, then the treaty status is reset to the expected value.
If they can change treaties, the expected value is updated to match the
actual value.
]]
function diplomacy.checkTreaties()
    local expectedTreatiesTable = diplomacyState.expectedTreaties
    for tribe1ID=0,gen.c.maxTribeID do
        for tribe2ID=tribe1ID+1,gen.c.maxTribeID do
            if data.flagGetValue("endogenousTreatyChangesEnabled_"..tribe1ID.."_"..tribe2ID,"diplomacy") then
                expectedTreatiesTable[tribe1ID][tribe2ID] = civ.getTribe(tribe1ID).treaties[civ.getTribe(tribe2ID)]
                expectedTreatiesTable[tribe2ID][tribe1ID] = civ.getTribe(tribe2ID).treaties[civ.getTribe(tribe1ID)]
                
            else
                local tribe1Treaties = civ.getTribe(tribe1ID).treaties[civ.getTribe(tribe2ID)]
                local tribe2Treaties = civ.getTribe(tribe2ID).treaties[civ.getTribe(tribe1ID)]
                local expectedTreatiesTribe1 = expectedTreatiesTable[tribe1ID][tribe2ID]
                local expectedTreatiesTribe2 = expectedTreatiesTable[tribe2ID][tribe1ID]
                -- set bits 5 and 8 (vendetta and embassy) to 0
                -- so they don't interfere with the comparison
                -- and can change even if endogenous treaty changes are forbidden
                tribe1Treaties = tribe1Treaties & ~0x90
                tribe2Treaties = tribe2Treaties & ~0x90
                expectedTreatiesTribe1 = expectedTreatiesTribe1 & ~0x90
                expectedTreatiesTribe2 = expectedTreatiesTribe2 & ~0x90
                if tribe1Treaties ~= expectedTreatiesTribe1 or 
                    tribe2Treaties ~= expectedTreatiesTribe2 then
                    civ.getTribe(tribe1ID).treaties[civ.getTribe(tribe2ID)] = expectedTreatiesTable[tribe1ID][tribe2ID]
                    civ.getTribe(tribe2ID).treaties[civ.getTribe(tribe1ID)] = expectedTreatiesTable[tribe2ID][tribe1ID]
                    if eventTreatiesMessage then
                        text.simple(text.substitute(eventTreatiesMessage,{civ.getTribe(tribe1ID).name,civ.getTribe(tribe2ID).name}))
                    end
                end
            end
        end
    end
end

--[[
Generates an error, so the scenario designer knows to update
to the new diplomacy functions.
]]
---@deprecated
---@param eventTreatiesMsg string
function diplomacy.setEventTreatiesOnly(eventTreatiesMsg)
    local message = [[diplomacy.setEventTreatiesOnly:
This is a function from an earlier version of the diplomacy module.
In order to disable two tribes from changing their treaty status,use 
diplomacy.disableEndogenousTreatyChangesByDefault(tribe1,tribe2)
in this file, or call 
diplomacy.disableEndogenousTreatyChanges(tribe1,tribe2) within
an execution point during the scenario.  To re-enable the tribes
to change their treaty status, use
diplomacy.enableEndogenousTreatyChanges(tribe1,tribe2) within
an execution point during the scenario.]]

    message = message.."\nTo set the message for reversing a treaty change, add the following call to this file:\ndiplomacy.setDiplomacyReversalMessage("..eventTreatiesMsg..")"
    error(message)
end


--[[
Generates an error, so the scenario designer knows to update
to the new diplomacy functions.
]]
---@deprecated
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.alwaysEnableTreatyChanges(tribe1,tribe2)
    local message = [[diplomacy.alwaysEnableTreatyChanges:
This is a function from an earlier version of the diplomacy module.
You no longer need to call this function to make sure some tribes
can always change their treaties when other tribes can't.
Now, for the relevant tribes, you simply need to refrain from calling
diplomacy.disableEndogenousTreatyChangesByDefault(tribe1,tribe2)
in this file or
diplomacy.disableEndogenousTreatyChanges(tribe1,tribe2)
in the scenario events.

Note that diplomacy.enableTreatyChanges and diplomacy.disableTreatyChanges should still work as before, as long as
you've called diplomacy.disableEndogenousTreatyChangesByDefault
for tribes that should not be able to negotiate at the start
of the scenario.]]
    error(message)
end

--[[
Calls diplomacy.enableEndogenousTreatyChanges for `tribe1` and `tribe2`.
This is the name of a function from an earlier version of the diplomacy module.
]]
---@deprecated
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.enableTreatyChanges(tribe1,tribe2)
    diplomacy.enableEndogenousTreatyChanges(tribe1,tribe2)
end

--[[
Calls diplomacy.disableEndogenousTreatyChanges for `tribe1` and `tribe2`.
This is the name of a function from an earlier version of the diplomacy module.
]]
---@deprecated
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.disableTreatyChanges(tribe1,tribe2)
    diplomacy.disableEndogenousTreatyChanges(tribe1,tribe2)
end

-- setTreatiesBit1(tribe1,tribe2,bitNumber,tribe1Only=nil)-->void
-- changes the treaties for tribe1 and tribe2, setting the corresponding
-- bit to 1, unless tribe1Only is true, in which case, only tribe1's treaties
-- are changed
local function setTreatiesBit1(tribe1,tribe2,bitNumber,tribe1Only)
    local expectedTreatiesTable = diplomacyState.expectedTreaties
    tribe1.treaties[tribe2] = gen.setBit1(tribe1.treaties[tribe2],bitNumber)
    expectedTreatiesTable[tribe1.id][tribe2.id] = gen.setBit1(expectedTreatiesTable[tribe1.id][tribe2.id],bitNumber)
    if tribe1Only then
        return
    else
        tribe2.treaties[tribe1]=gen.setBit1(tribe2.treaties[tribe1],bitNumber)
        expectedTreatiesTable[tribe2.id][tribe1.id] = gen.setBit1(expectedTreatiesTable[tribe2.id][tribe1.id],bitNumber)
    end
end

-- setTreatiesBit0(tribe1,tribe2,bitNumber,tribe1Only=nil)-->void
-- changes the treaties for tribe1 and tribe2, setting the corresponding
-- bit to 0, unless tribe1Only is true, in which case, only tribe1's treaties
-- are changed
local function setTreatiesBit0(tribe1,tribe2,bitNumber,tribe1Only)
    local expectedTreatiesTable = diplomacyState.expectedTreaties
    tribe1.treaties[tribe2] = gen.setBit0(tribe1.treaties[tribe2],bitNumber)
    expectedTreatiesTable[tribe1.id][tribe2.id] = gen.setBit0(expectedTreatiesTable[tribe1.id][tribe2.id],bitNumber)
    if tribe1Only then
        return
    else
        tribe2.treaties[tribe1]=gen.setBit0(tribe2.treaties[tribe1],bitNumber)
        expectedTreatiesTable[tribe2.id][tribe1.id] = gen.setBit0(expectedTreatiesTable[tribe2.id][tribe1.id],bitNumber)
    end

end

--[[Returns true if `tribe1` and `tribe2` are at war with each other, and false otherwise.  (Note that if tribes have no contact with each other, they can attack each other's units but will not be at war.)]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
---@return boolean
function diplomacy.warExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],14,
    "warExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric war status.")
end

--[[
Sets treaties so that `tribe1` and `tribe2` are at war with each other.
(Note, you may also have to use `civ.makeAggression` to make the tribes actually fight each other.) 
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.setWar(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,14)
end

--[[
Clears the "war" "treaty" between `tribe1` and `tribe2`.  Does not establish
any other treaty between the tribes. 
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.clearWar(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,14)
end

--[[
Returns true if "contact" "treaties" exists between `tribe1` and `tribe2`, and false otherwise.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
---@return boolean
function diplomacy.contactExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],1,
    "contactExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric contact status.")
end

--[[
Sets treaties so that "contact" exists between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.setContact(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,1)
end

--[[
Clears treaties so that "contact" does not exist between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.clearContact(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,1)
end

--[[
Returns true if a cease fire treaty exists between `tribe1` and `tribe2`, and false otherwise.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
---@return boolean
function diplomacy.ceaseFireExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],2,
    "ceaseFireExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Cease Fire status.")
end

--[[
Sets treaties so that a cease fire exists between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.setCeaseFire(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,2)
end

--[[
Clears treaties so that a cease fire does not exist between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.clearCeaseFire(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,2)
end

--[[
Returns true if a peace treaty exists between `tribe1` and `tribe2`, and false otherwise.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
---@return boolean
function diplomacy.peaceTreatyExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],3,
    "peaceTreatyExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Peace Treaty status.")
end

--[[
Sets treaties so that a peace treaty exists between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.setPeaceTreaty(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,3)
end

--[[
Clears treaties so that a peace treaty does not exist between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.clearPeaceTreaty(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,3)
end

--[[
Returns true if an alliance exists between `tribe1` and `tribe2`, and false otherwise.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
---@return boolean
function diplomacy.allianceExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],4,
    "allianceExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Alliance status.")
end

--[[
Sets treaties so that an alliance exists between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.setAlliance(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,4)
end

--[[
Clears treaties so that an alliance does not exist between `tribe1` and `tribe2`.
]]
---@param tribe1 tribeObject
---@param tribe2 tribeObject
function diplomacy.clearAlliance(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,4)
end

--[[
Returns true if the `ownerTribe` has an embassy with the `hostTribe`, and false otherwise.  That is, the `ownerTribe` receives an intelligence report about `hostTribe`.
]]
---@param ownerTribe tribeObject
---@param hostTribe tribeObject
---@return boolean
function diplomacy.hasEmbassyWith(ownerTribe,hostTribe)
    return gen.isBit1(ownerTribe.treaties[hostTribe],8)
end

--[[
Sets treaties so that the `ownerTribe` has an embassy with the `hostTribe`.  That is, the `ownerTribe` will receive an intelligence reports about `hostTribe`.
]]
---@param ownerTribe tribeObject
---@param hostTribe tribeObject
function diplomacy.setEmbassyWith(ownerTribe,hostTribe)
    setTreatiesBit1(ownerTribe,hostTribe,8,true)
end

--[[
Clears treaties so that the `ownerTribe` does not have an embassy with the `hostTribe`.  That is, the `ownerTribe` will not receive an intelligence reports about `hostTribe`.
]]
---@param ownerTribe tribeObject
---@param hostTribe tribeObject
function diplomacy.clearEmbassyWith(ownerTribe,hostTribe)
    setTreatiesBit0(ownerTribe,hostTribe,8,true)
end

--[[
Returns true if the `angryTribe` has a vendetta with the `offendingTribe`, and false otherwise.
]]
---@param angryTribe tribeObject
---@param offendingTribe tribeObject
---@return boolean
function diplomacy.hasVendettaWith(angryTribe,offendingTribe)
    return gen.isBit1(angryTribe.treaties[offendingTribe],5)
end

--[[
Sets treaties so that the `angryTribe` has a vendetta with the `offendingTribe`.
]]
---@param angryTribe tribeObject
---@param offendingTribe tribeObject
function diplomacy.setVendettaWith(angryTribe,offendingTribe)
    setTreatiesBit1(angryTribe,offendingTribe,5,true)
end

--[[
Clears treaties so that the `angryTribe` does not have a vendetta with the `offendingTribe`.
]]
---@param angryTribe tribeObject
---@param offendingTribe tribeObject
function diplomacy.clearVendettaWith(angryTribe,offendingTribe)
    setTreatiesBit0(angryTribe,offendingTribe,5,true)
end

-- Forbid Technology Transfer
-- The diplomacy module provides ways to forbid technology transfer
-- between tribes, even if the receiving tribe can research the
-- technology on its own.

-- The following functions can be registered to determine
-- whether a tribe can receive a technology from another tribe.
-- If the function returns true, then the technology transfer
-- is prevented, if false (or nil), it is allowed.

-- forbidTechTrade(tech,receiverTribe,giverTribe)-->bool
-- If true, the `giverTribe` can't give or trade the tech
-- to the `receiverTribe`. (Either in in-game negotiations, or
-- using the diplomacy module's gift system.)
-- If false (or nil), the `giverTribe` can give or trade the tech
-- to the `receiverTribe`.
local forbidTechTradeRegisteredFn = function(tech,receiverTribe,giverTribe)
    return false
end

--Register a function to determine whether a tribe can receive a technology from another tribe through diplomacy.<br><br>
-- forbidTechTrade(tech,receiverTribe,giverTribe)-->bool
-- If true, the `giverTribe` can't give or trade the tech
-- to the `receiverTribe`. (Either in in-game negotiations, or
-- using the diplomacy module's gift system.)
-- If false (or nil), the `giverTribe` can give or trade the tech
-- to the `receiverTribe`.
---@param forbidTechTrade fun(tech:techObject,receiverTribe:tribeObject,giverTribe:tribeObject):boolean
function diplomacy.registerForbidTechTradeFunction(forbidTechTrade)
    if type(forbidTechTrade)~="function" then
        error("diplomacy.registerForbidTechTradeFunction: argument must be a function.")
    end
    forbidTechTradeRegisteredFn = forbidTechTrade
end

-- forbidTechFromConquest(tech,conqueringTribe,losingTribe)-->bool
-- If true, the `conqueringTribe` can't receive the `tech`
-- from the `losingTribe` as a result of conquering a city 
-- owned by the `losingTribe`.
-- If false (or nil), the `conqueringTribe` can receive the `tech`
-- from the `losingTribe` as a result of conquering a city
-- owned by the `losingTribe`.
local forbidTechFromConquestRegisteredFn = function(tech,conqueringTribe,losingTribe)
    return false
end

--Register a function to determine whether a tribe can receive a technology when conquering another tribe's city.<br><br>
--forbidTechFromConquest(tech,conqueringTribe,losingTribe)-->bool
-- If true, the `conqueringTribe` can't receive the `tech`
-- from the `losingTribe` as a result of conquering a city
-- owned by the `losingTribe`.
-- If false (or nil), the `conqueringTribe` can receive the `tech`
-- from the `losingTribe` as a result of conquering a city
-- owned by the `losingTribe`.
---@param forbidTechFromConquest fun(tech:techObject,conqueringTribe:tribeObject,losingTribe:tribeObject):boolean
function diplomacy.registerForbidTechFromConquestFunction(forbidTechFromConquest)
    if type(forbidTechFromConquest)~="function" then
        error("diplomacy.registerForbidTechFromConquestFunction: argument must be a function.")
    end
    forbidTechFromConquestRegisteredFn = forbidTechFromConquest
end

-- forbidTechTheft(tech,thievingTribe,thievingUnit)-->boolean
-- If true, the `thievingTribe` can't steal the `tech`
-- from another tribe using the `thievingUnit` (if it has 
-- role 6 for diplomatic units).
-- If false (or nil), the `thievingTribe` can steal the `tech`.
-- (The giving tribe can't be specified, because there isn't a
-- way to control which tribe the spy or diplomat steals from.)
local forbidTechTheftRegisteredFn = function(tech,thievingTribe,thievingUnit)
    return false
end


-- Register a function to determine whether a tribe can
-- steal a technology using a diplomatic (role 6) unit.<br><br>
-- forbidTechTheft(tech,thievingTribe,thievingUnit)-->boolean
-- If true, the `thievingTribe` can't steal the `tech`
-- from another tribe using the `thievingUnit` (if it has 
-- role 6 for diplomatic units).
-- If false (or nil), the `thievingTribe` can steal the `tech`.
-- (The giving tribe can't be specified, because there isn't a
-- way to control which tribe the spy or diplomat steals from.)
---@param forbidTechTheft fun(tech:techObject,thievingTribe:tribeObject,thievingUnit:unitObject):boolean
function diplomacy.registerForbidTechTheftFunction(forbidTechTheft)
    if type(forbidTechTheft)~="function" then
        error("diplomacy.registerForbidTechTheftFunction: argument must be a function.")
    end
    forbidTechTheftRegisteredFn = forbidTechTheft
end

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
---@param stopTechTransferTable table stopTechTransferTable[techObject.id] = {noPrereqs=bool,noTrade=bool,noConquest=bool,noTheft=bool}
---@return fun(tech:techObject,receiverTribe:tribeObject,giverTribe:tribeObject):boolean forbidTechTrade
---@return fun(tech:techObject,conqueringTribe:tribeObject,losingTribe:tribeObject):boolean forbidTechFromConquest
---@return fun(tech:techObject,thievingTribe:tribeObject,thievingUnit:unitObject):boolean forbidTechTheft
function diplomacy.techTransferTableToFunctions(stopTechTransferTable)
    stopTechTransferTable = gen.copyTable(stopTechTransferTable)
    ---@param tech techObject
    ---@param receiverTribe tribeObject
    ---@param giverTribe tribeObject
    ---@return boolean
    local function forbidTechTrade(tech,receiverTribe,giverTribe)
        if not stopTechTransferTable[tech.id] then
            return false
        end
        if stopTechTransferTable[tech.id].noTrade then
            return true
        end
        if stopTechTransferTable[tech.id].noPrereqs then
            if tech.prereq1 and not receiverTribe:hasTech(tech.prereq1) then
                return true
            end
            if tech.prereq2 and not receiverTribe:hasTech(tech.prereq2) then
                return true
            end
        end
        return false
    end

    local function forbidTechFromConquest(tech,conqueringTribe,losingTribe)
        if not stopTechTransferTable[tech.id] then
            return false
        end
        if stopTechTransferTable[tech.id].noConquest then
            return true
        end
        if stopTechTransferTable[tech.id].noPrereqs then
            if tech.prereq1 and not conqueringTribe:hasTech(tech.prereq1) then
                return true
            end
            if tech.prereq2 and not conqueringTribe:hasTech(tech.prereq2) then
                return true
            end
        end
        return false
    end

    local function forbidTechTheft(tech,thievingTribe,thievingUnit)
        if not stopTechTransferTable[tech.id] then
            return false
        end
        if stopTechTransferTable[tech.id].noTheft then
            return true
        end
        if stopTechTransferTable[tech.id].noPrereqs then
            if tech.prereq1 and not thievingTribe:hasTech(tech.prereq1) then
                return true
            end
            if tech.prereq2 and not thievingTribe:hasTech(tech.prereq2) then
                return true
            end
        end
        return false
    end
    return forbidTechTrade,forbidTechFromConquest,forbidTechTheft
end



local noTransferTechGroup = 7
diplomacy.reservedTechGroup = noTransferTechGroup
local techGroupsAreModified = false

local function restoreTechGroupDefaults()
    if not techGroupsAreModified then
        -- don't need to do anything if the tech groups haven't been modified
        return
    end
    local authoritativeDefaultRules = changeRules.authoritativeDefaultRules
    for tech in gen.iterateTechs() do
        tech.group = authoritativeDefaultRules[tech].group
    end
    techGroupsAreModified = false
end


local negotiationConquestRecent = false
local function prepareTechGroupsForNegotiation(talker,listener)
    civ.enableTechGroup(talker,noTransferTechGroup,2)
    civ.enableTechGroup(listener,noTransferTechGroup,2)
    for tech in gen.iterateTechs() do
        if talker:hasTech(tech) and forbidTechTradeRegisteredFn(tech,listener,talker) then
            -- if the talker has the tech, and the listener can't receive it
            -- then the tech is moved to the noTransferTechGroup
            tech.group = noTransferTechGroup
        elseif listener:hasTech(tech) and forbidTechTradeRegisteredFn(tech,talker,listener) then
            -- if the listener has the tech, and the talker can't receive it
            -- then the tech is moved to the noTransferTechGroup
            tech.group = noTransferTechGroup
        end
    end
    techGroupsAreModified = true
    negotiationConquestRecent = true
end


function diplomacy.onNegotiation(talker,listener,canNegotiate)
    if canNegotiate then
        prepareTechGroupsForNegotiation(talker,listener)
    end
end


local function prepareTechGroupsForConquest(conqueringTribe,losingTribe)
    civ.enableTechGroup(conqueringTribe,noTransferTechGroup,2)
    civ.enableTechGroup(losingTribe,noTransferTechGroup,2)
    for tech in gen.iterateTechs() do
        if losingTribe:hasTech(tech) and forbidTechFromConquestRegisteredFn(tech,conqueringTribe,losingTribe) then
            -- if the losing tribe has the tech, and the conquering tribe can't receive it
            -- then the tech is moved to the noTransferTechGroup
            tech.group = noTransferTechGroup
        end
    end
    techGroupsAreModified = true
    negotiationConquestRecent = true
end

function diplomacy.onCityTaken(city,defender)
    local conqueringTribe = city.owner
    local losingTribe = defender
    prepareTechGroupsForConquest(conqueringTribe,losingTribe)
end

local function prepareTechGroupsForTheft(thievingTribe,thievingUnit)
    civ.enableTechGroup(thievingTribe,noTransferTechGroup,2)
    for tech in gen.iterateTechs() do
        if forbidTechTheftRegisteredFn(tech,thievingTribe,thievingUnit) then
            -- if the thieving tribe can't receive the tech
            -- then the tech is moved to the noTransferTechGroup
            tech.group = noTransferTechGroup
        end
    end
    techGroupsAreModified = true
end

function diplomacy.onActivateUnit(unit,source,repeatedActivation)
    if unit.type.role ~= gen.c.roleDiplomacy then
        restoreTechGroupDefaults()
        return
    end
    prepareTechGroupsForTheft(unit.owner,unit)
end

function diplomacy.onDateCheck()
    if negotiationConquestRecent then
        restoreTechGroupDefaults()
        negotiationConquestRecent = false
    end
end

-- If true, the givingTribe can transfer ownership of everything
-- on the tile to the receiving tribe.
-- Note that this will not be called if the giving tribe
-- doesn't own the tile
local canGiveTileFn = function(tile,givingTribe,receivingTribe) return true end


--[[Registers a function(tile,givingTribe,receivingTribe)  
to determine whether the givingTribe can transfer ownership
of everything (units and city) on the tile to the receivingTribe.

There is no need to check that the giving tribe owns the units/city
on the tile.  That is taken care of within the diplomacy module.
]]
---@param canGiveAwayTileFn fun(tile:tileObject,givingTribe:tribeObject,receivingTribe:tribeObject):boolean
function diplomacy.registerCanGiveAwayTileFn(canGiveAwayTileFn)
    if type(canGiveAwayTileFn) ~= "function" then
        error("diplomacy.registerCanGiveAwayTileFn: argument must be a function.")
    end
    canGiveTileFn = canGiveAwayTileFn
end


-- Diplomacy menu choice history spec
--[[
    table with the following keys (all of which can be nil at some point):
    giftReceiver = tribeObject
        The tribe that will receive the gift
    giftGiver = tribeObject
        The tribe giving the gift (that opened the menu)
    moneyGift = number
        The amount of money to be given
    techGift = techObject
        The tech to be given
    tileGift = tileObject
        The tile where everything on it will be given
]]

local confirmMoneyGiftMenu = text.newMenuRecord({menuName="Diplomacy confirm money gift menu"})
confirmMoneyGiftMenu.menuText = function(callingArgument,history)
    local lastHist = history[1]
    return "Shall we send "..text.money(lastHist.moneyGift).." (out of "..text.money(lastHist.giftGiver.money)..") to the "..lastHist.giftReceiver.name.."?"
end
confirmMoneyGiftMenu.menuTitle = "Prepare a Gift"

confirmMoneyGiftMenu.menuGenerator = function(callingArgument,history)
    local lastHist = history[1]
    local giftGiver = lastHist.giftGiver
    local menuOptionTable = {}
    if giftGiver.money < lastHist.moneyGift then
        menuOptionTable[1] = {
            choice = nil,
            optionName = "We don't have enough money, so let us prepare a smaller gift.",
            nextMenu = 1,
        }
    else
        menuOptionTable[1] = {
            choice = nil,
            optionName = "No, the amount is incorrect, so let us change it.",
            nextMenu = 1,
        }
        menuOptionTable[2] = {
            choice = lastHist,
            optionName = "Yes, send "..text.money(lastHist.moneyGift)..".",
            nextMenu = nil,
        }
    end
    menuOptionTable[3] = {
        choice = nil,
        optionName = "No, let us cancel the gift.",
        nextMenu = nil,
    }
    menuOptionTable[4] = {
        choice = nil,
        optionName = "No, let us prepare a different kind of gift.",
        nextMenu = 2,
    }
    return menuOptionTable
end
    
local goBackOptions = {
    [1] = {goBack = 1, optionName = "Let's give them something other than money."},}

local chooseMoneyGiftMenu = text.makeChooseNumberMenu({1,10,50,100,500,1000,5000,10000,-1,-10,-100,-1000},{min=0,max=100000},"moneyGift",confirmMoneyGiftMenu,goBackOptions,"Choose Money Amount Menu","Add %MONEY1","Subtract %MONEY1","Select %MONEY1")

chooseMoneyGiftMenu.menuTitle = "Prepare a Gift"

chooseMoneyGiftMenu.menuText = function(callingArgument,history)
    local lastHist = history[1]
    return "We're preparing a gift of money to the "..lastHist.giftReceiver.name..".  Is "..text.money(lastHist.moneyGift).." the correct amount?"
end

local confirmTileGiftMenu = text.newMenuRecord({menuName="Diplomacy confirm tile gift menu"})

confirmTileGiftMenu.menuText = function(callingArgument,history)
    local lastHist = history[1]
    local city = lastHist.tileGift.city
    local unitList = {}
    local unitCount = 0
    for unit in lastHist.tileGift.units do
        unitList[unit.type.name] = (unitList[unit.type.name] or 0) + 1
        unitCount = unitCount+1
    end
    local keyList = gen.sortTableKeysInDescendingValueOrder(unitList)
    local textList = {}
    local explicitCount = 0
    for i=1,5 do
        if keyList[i] and unitList[keyList[i]] > 0 then
            textList[i] = unitList[keyList[i]].." "..keyList[i].." unit"
            if unitList[keyList[i]] > 1 then
                textList[i] = textList[i].."s"
            end
            explicitCount = explicitCount + unitList[keyList[i]]
        else
            break
        end
    end
    if explicitCount < unitCount then
        textList[#textList+1] = (unitCount-explicitCount).." other unit"
        if unitCount-explicitCount > 1 then
            textList[#textList] = textList[#textList].."s"
        end
    end
    local message = ""
    if #keyList > 0 and city then
        message = "We are preparing to give the "..lastHist.giftReceiver.name.." the city of "..city.name..", "..text.niceList(textList).."."
    elseif #keyList > 0 then
        message = "We are preparing to give the "..lastHist.giftReceiver.name.." "..text.niceList(textList)..", which are located on tile ("..text.coordinates(lastHist.tileGift)..")."
    elseif city then
        message = "We are preparing to give the "..lastHist.giftReceiver.name.." the city of "..city.name..".  There are no units in that city."
    end
    return message
end
confirmTileGiftMenu.menuTitle = "Prepare a Gift"
confirmTileGiftMenu.menuGenerator = function(callingArgument,history)
    local lastHist = history[1]
    local menuOptionTable = {}
    menuOptionTable[1] = {
        choice = nil,
        optionName = "No, let us cancel the gift.",
        nextMenu = nil,
    }
    menuOptionTable[2] = {
        choice = nil,
        optionName = "No, let us prepare a different kind of gift.",
        nextMenu = 1,
    }
    menuOptionTable[3] = {
        choice = lastHist,
        optionName = "Yes, send the gift.",
        nextMenu = nil,
    }
    return menuOptionTable
end

local confirmTechGiftMenu = text.newMenuRecord({menuName="Diplomacy confirm tech gift menu"})
confirmTechGiftMenu.menuText = function(callingArgument,history)
    local lastHist = history[1]
    return "Shall we send the "..lastHist.techGift.name.." to the "..lastHist.giftReceiver.name.."?"
end
confirmTechGiftMenu.menuGenerator = function(callingArgument,history)
    local lastHist = history[1]
    local menuOptionTable = {}
    menuOptionTable[1] = {
        choice = 1,
        optionName = "No, let us give a different technology.",
        nextMenu = nil,
    }
    menuOptionTable[2] = {
        choice = lastHist,
        optionName = "Yes, send the secret of "..lastHist.techGift.name..".",
        nextMenu = nil,
    }
    menuOptionTable[3] = {
        choice = nil,
        optionName = "No, let us cancel the gift.",
        nextMenu = nil,
    }
    menuOptionTable[4] = {
        choice = nil,
        optionName = "No, let us prepare a different kind of gift.",
        nextMenu = 2,
    }
    return menuOptionTable
end

local chooseTechGiftMenu = text.newMenuRecord({menuName="Diplomacy Choose Tech Gift Menu"})
chooseTechGiftMenu.menuText = "What secret shall we teach the %NAME[giftReceiver]?"




-- Returns true if the `tribe` can own the `tech`, and false otherwise.
-- At the moment always returns true, since there is no way to determine
-- the current status of a tech group.
---@param tribe tribeObject
---@param tech techObject
---@return boolean
local function tribeCanOwnTech(tribe,tech)
    return true
end

chooseTechGiftMenu.menuGenerator = function(callingArgument,history)
    local lastHist = history[1]
    local giver = lastHist.giftGiver
    local receiver = lastHist.giftReceiver
    local menuOptionTable = {}
    menuOptionTable[-2] = {
        choice = nil,
        optionName = "No, let us prepare a different kind of gift.",
        nextMenu = 1,
    }
    menuOptionTable[-1] = {
        choice = nil,
        optionName = "Let us cancel the gift.",
        nextMenu = nil,
    }
    for i=0,gen.c.maxTechID do
        local tech = civ.getTech(i)
        if tech and giver:hasTech(tech) and 
            (not receiver:hasTech(tech)) and
            (not forbidTechTradeRegisteredFn(tech,receiver,giver)) and
            tribeCanOwnTech(receiver,tech) then
            menuOptionTable[i] = {
                choice = {giftGiver = lastHist.giftGiver,giftReceiver = lastHist.giftReceiver,techGift = tech},
                optionName = tech.name,
                nextMenu = confirmTechGiftMenu,
            }
        end
    end
    return menuOptionTable
end

---Returns true if the `tribe` owns the units and/or city on the tile.
---Returns false if it does not, or if the tile has no units or city.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
local function tileOwnedByTribe(tile,tribe)
    if tile.city then
        return tile.city.owner == tribe
    end
    return tile.defender == tribe
end

local chooseGiftTypeMenu = text.newMenuRecord({menuName="Diplomacy Choose Gift Type Menu"})
chooseGiftTypeMenu.menuText = "What kind of gift shall we give the %NAME[giftReceiver]?"
chooseGiftTypeMenu.menuTitle = "Prepare a Gift"
chooseGiftTypeMenu.menuGenerator = function(callingArgument,history)
    local lastHist = history[1]
    local giver = lastHist.giftGiver
    local receiver = lastHist.giftReceiver
    local menuOptionTable = {}
    menuOptionTable[1] = {
        choice = nil,
        optionName = "Let us cancel the gift.",
        nextMenu = nil,
    }
    menuOptionTable[2] = {
        choice = nil,
        optionName = "Choose a different recipient.",
        nextMenu = 1,
    }
    if receiver.id ~= 0 then
        menuOptionTable[3] = {
            choice = {giftGiver = lastHist.giftGiver,giftReceiver = lastHist.giftReceiver,moneyGift = 0},
            optionName = "Money",
            nextMenu = chooseMoneyGiftMenu,
        }
    end
    local currentTile = civ.getCurrentTile()
    if currentTile and canGiveTileFn(currentTile,giver,receiver) and tileOwnedByTribe(currentTile,giver) then
        local optionText = ""
        local tile = currentTile
        if tile.city then
            optionText = "The city of "..tile.city.name
        else
            optionText = "Tile ("..text.coordinates(tile)..")"
        end
        local numUnits = 0
        for unit in tile.units do
            numUnits = numUnits + 1
        end
        if numUnits > 0 then
            optionText = optionText.." and "..numUnits.." unit"
            if numUnits > 1 then
                optionText = optionText.."s"
            end
        end
        menuOptionTable[4] = {
            choice = {giftGiver = lastHist.giftGiver,giftReceiver = lastHist.giftReceiver,tileGift = tile},
            optionName = optionText,
            nextMenu = confirmTileGiftMenu,
        }
    end
    if receiver.id ~= 0 then
        menuOptionTable[5] = {
            choice = {giftGiver = lastHist.giftGiver,giftReceiver = lastHist.giftReceiver,techGift = nil},
            optionName = "A technology",
            nextMenu = chooseTechGiftMenu,
        }
    end
    return menuOptionTable
end

-- Return true if giftGiver can give giftReceiver a gift through the gift giving menu.
local canGiveGiftFn = function(giftGiver,giftReceiver)
    return true
end

--[[
Registers a function(giftGiver,giftReceiver) that determines whether the `giftGiver` can give a gift to the `giftReceiver` through the gift giving menu.

If the function returns true, then the giftReceiver will be an option in
the gift giving menu for giftGiver.
]]
---@param canGiveGiftFunction fun(giftGiver:tribeObject,giftReceiver:tribeObject):boolean
function diplomacy.registerCanGiveGiftFunction(canGiveGiftFunction)
    if type(canGiveGiftFunction) ~= "function" then
        error("diplomacy.registerCanGiveGiftFunction: argument must be a function.")
    end
    canGiveGiftFn = canGiveGiftFunction
end

local chooseGiftRecipientMenu = text.newMenuRecord({menuName="Diplomacy Choose Gift Recipient Menu"})
chooseGiftRecipientMenu.menuText = "To whom shall we give a gift?"
chooseGiftRecipientMenu.menuTitle = "Prepare a Gift"
chooseGiftRecipientMenu.menuGenerator = function(callingArgument,history)
    local lastHist = {giftGiver = civ.getCurrentTribe()}
    local giver = lastHist.giftGiver
    local menuOptionTable = {}
    menuOptionTable[-1] = {
        choice = nil,
        optionName = "Let us cancel the gift.",
        nextMenu = nil,
    }
    for i=0,7 do
        local receiver = civ.getTribe(i)
        if receiver and receiver.active and receiver ~= giver and canGiveGiftFn(giver,receiver) then
            menuOptionTable[i] = {
                choice = {giftGiver = lastHist.giftGiver,giftReceiver = receiver},
                optionName = receiver.name,
                nextMenu = chooseGiftTypeMenu,
            }
        end
    end
    return menuOptionTable
end
local broadcast = true
function diplomacy.giveGiftMenu()
    local gift = chooseGiftRecipientMenu()
    if gift == nil then
        return
    end
    if gift.moneyGift then
        gift.giftGiver.money = gift.giftGiver.money - gift.moneyGift
        gift.giftReceiver.money = gift.giftReceiver.money + gift.moneyGift
        text.displayNextOpportunity(gift.giftReceiver,"We have received "..text.money(gift.moneyGift).." from the "..gift.giftGiver.name..".","Foreign Minister","Gift From the "..gift.giftGiver.name)
        return
    end
    if gift.techGift then
        gift.giftReceiver:giveTech(gift.techGift)
        text.displayNextOpportunity(gift.giftReceiver,"We have received the secret of "..gift.techGift.name.." from the "..gift.giftGiver..".","Foreign Minister","Gift From the "..gift.giftGiver.name)
        return
    end
    if gift.tileGift then
        gen.transferTileContents(gift.tileGift,gift.giftReceiver)
        local tileName = "the tile ("..text.coordinates(gift.tileGift)..")"
        if gift.tileGift.city then
            tileName = "the city of "..gift.tileGift.city.name
        end
        local unitList = {}
        local unitCount = 0
        for unit in gift.tileGift.units do
            unitList[unit.type.name] = (unitList[unit.type.name] or 0) + 1
            unitCount = unitCount+1
        end
        local keyList = gen.sortTableKeysInDescendingValueOrder(unitList)
        local textList = {}
        local explicitCount = 0
        for i=1,5 do
            if keyList[i] and unitList[keyList[i]] > 0 then
                textList[i] = unitList[keyList[i]].." "..keyList[i].." unit"
                if unitList[keyList[i]] > 1 then
                    textList[i] = textList[i].."s"
                end
                explicitCount = explicitCount + unitList[keyList[i]]
            else
                break
            end
        end
        if explicitCount < unitCount then
            textList[#textList+1] = (unitCount-explicitCount).." other unit"
            if unitCount-explicitCount > 1 then
                textList[#textList] = textList[#textList].."s"
            end
        end
        local message = "We have received "..tileName
        if #textList > 0 then
            message = message..", with "..text.niceList(textList)..","
        end
        message = message.." from the "..gift.giftGiver.name.."."
        text.displayNextOpportunity(gift.giftReceiver,message,"Foreign Minister","Gift From the "..gift.giftGiver.name)
        return
    end

end

if _G.console then
    console.diplomacy = diplomacy
end


return diplomacy
