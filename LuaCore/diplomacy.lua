--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- Provides Functionality related to diplomacy
--  diplomacy.warExists(tribe1,tribe2)-->bool
--  diplomacy.setWar(tribe1,tribe2)
--  diplomacy.clearWar(tribe1,tribe2)
--  diplomacy.contactExists(tribe1,tribe2)-->bool
--  diplomacy.setContact(tribe1,tribe2)
--  diplomacy.clearContact(tribe1,tribe2)
--  diplomacy.ceaseFireExists(tribe1,tribe2)-->bool
--  diplomacy.setCeaseFire(tribe1,tribe2)
--  diplomacy.clearCeaseFire(tribe1,tribe2)
--  diplomacy.peaceTreatyExists(tribe1,tribe2)-->bool
--  diplomacy.setPeaceTreaty(tribe1,tribe2)
--  diplomacy.clearPeaceTreaty(tribe1,tribe2)
--  diplomacy.allianceExists(tribe1,tribe2)-->bool
--  diplomacy.setAlliance(tribe1,tribe2)
--  diplomacy.clearAlliance(tribe1,tribe2)
--  diplomacy.hasEmbassyWith(ownerTribe,hostTribe) -->bool
--  diplomacy.setEmbassyWith(ownerTribe,hostTribe)
--  diplomacy.clearEmbassyWith(ownerTribe,hostTribe)
--  diplomacy.hasVendettaWith(angryTribe,offendingTribe)-->bool
--  diplomacy.setVendettaWith(angryTribe,offendingTribe)
--  diplomacy.clearVendettaWith(angryTribe,offendingTribe)

local gen = require("generalLibrary"):minVersion(1)
local text = require("text")
local civlua = require("civluaModified")

local diplomacy = {version=versionNumber}
gen.versionFunctions(diplomacy,versionNumber,fileModified,"LuaCore".."\\".."diplomacy.lua")

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
    diplomacyState.allowedTreatyChanges = diplomacyState.allowedTreatyChanges or {[0]={},{},{},{},{},{},{},{}}
end
diplomacy.linkState = linkState

local fileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "diplomacyState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkState(state[keyName])
    end
end




local alwaysAllowedTreatyChanges = {[0]={},{},{},{},{},{},{},{}}

local function negotiationTreaty(tribe1ID,tribe2ID)
    return diplomacyState.allowedTreatyChanges[tribe1ID][tribe2ID] or alwaysAllowedTreatyChanges[tribe1ID][tribe2ID]
end

local function enableTreatyChanges(tribe1,tribe2)
    if type(diplomacyState)=="string" then
        error("diplomacy.enableTreatyChanges: enableTreatyChanges should only be used within an event, and not as part of the setup scripts.  Either use 'diplomacy.alwaysEnableTreatyChanges', or place diplomacy.enableTreatyChanges within an event, such as onScenarioLoaded or onTurn.")
    end
    diplomacyState.allowedTreatyChanges[tribe1.id][tribe2.id]=true
    diplomacyState.allowedTreatyChanges[tribe2.id][tribe1.id]=true
end
diplomacy.enableTreatyChanges = enableTreatyChanges


local function disableTreatyChanges(tribe1,tribe2)
    if type(diplomacyState)=="string" then
        error("diplomacy.disableTreatyChanges: disableTreatyChanges should only be used within an event, and not as part of the setup scripts.  Place it within an event function such as onTurn.")
    end
    diplomacyState.allowedTreatyChanges[tribe1.id][tribe2.id]=nil
    diplomacyState.allowedTreatyChanges[tribe2.id][tribe1.id]=nil
end
diplomacy.disableTreatyChanges = disableTreatyChanges

local function alwaysEnableTreatyChanges(tribe1,tribe2)
    alwaysAllowedTreatyChanges[tribe1.id][tribe2.id]=true
    alwaysAllowedTreatyChanges[tribe2.id][tribe1.id]=true
end
diplomacy.alwaysEnableTreatyChanges = alwaysEnableTreatyChanges


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

-- if eventTreatiesOnly is true, treaties can only
-- be changed by events in the diplomacy module
local eventTreatiesOnly = false
local eventTreatiesMessage = nil

-- After this function is set, treaties can only be
-- changed by event
-- if eventTreatiesMessage is supplied,
-- the message will be shown to the player when a treaty
-- is reset to the event specification
local function setEventTreatiesOnly(eventTreatiesMsg)
    eventTreatiesOnly = true
    eventTreatiesMessage = eventTreatiesMsg
end
diplomacy.setEventTreatiesOnly = setEventTreatiesOnly



-- checkTreaties()
--  
local function checkTreaties()
    if eventTreatiesOnly then
        local expectedTreatiesTable = diplomacyState.expectedTreaties
        local treatyRestored = false
        for senderTribeID=0,7 do
            for receiverTribeID = 0,7 do
                -- if tribes have been allowed to change their treaties
                if negotiationTreaty(senderTribeID,receiverTribeID) then
                    expectedTreatiesTable[senderTribeID][receiverTribeID]=civ.getTribe(senderTribeID).treaties[civ.getTribe(receiverTribeID)]
                else
                    -- tribes haven't been allowed to change their treaties
                    if expectedTreatiesTable[senderTribeID][receiverTribeID]~=civ.getTribe(senderTribeID).treaties[civ.getTribe(receiverTribeID)]
                    then
                        civ.getTribe(senderTribeID).treaties[civ.getTribe(receiverTribeID)]=expectedTreatiesTable[senderTribeID][receiverTribeID]
                        treatyRestored=true
                    end
                end
            end
        end
        if treatyRestored and eventTreatiesMessage then
            text.simple(eventTreatiesMessage,"Diplomacy")
        end
        return
    else
    local expectedTreatiesTable = diplomacyState.expectedTreaties
        for senderTribeID=0,7 do
            for receiverTribeID = 0,7 do
                expectedTreatiesTable[senderTribeID][receiverTribeID]=civ.getTribe(senderTribeID).treaties[civ.getTribe(receiverTribeID)]
            end
        end
        return
    end
end
diplomacy.checkTreaties = checkTreaties
-- 
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


local function warExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],14,
    "warExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric war status.")
end
diplomacy.warExists = warExists

local function setWar(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,14)
end
diplomacy.setWar = setWar

local function clearWar(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,14)
end
diplomacy.clearWar = clearWar

local function contactExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],1,
    "contactExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric contact status.")
end
diplomacy.contactExists = contactExists

local function setContact(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,1)
end
diplomacy.setContact = setContact

local function clearContact(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,1)
end
diplomacy.clearContact = clearContact

local function ceaseFireExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],2,
    "ceaseFireExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Cease Fire status.")
end
diplomacy.ceaseFireExists = ceaseFireExists

local function setCeaseFire(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,2)
end
diplomacy.setCeaseFire = setCeaseFire

local function clearCeaseFire(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,2)
end
diplomacy.clearCeaseFire = clearCeaseFire

local function peaceTreatyExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],3,
    "peaceTreatyExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Peace Treaty status.")
end
diplomacy.peaceTreatyExists = peaceTreatyExists

local function setPeaceTreaty(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,3)
end
diplomacy.setPeaceTreaty = setPeaceTreaty

local function clearPeaceTreaty(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,3)
end
diplomacy.clearPeaceTreaty = clearPeaceTreaty

local function allianceExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],4,
    "allianceExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Alliance status.")
end
diplomacy.allianceExists = allianceExists

local function setAlliance(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,4)
end
diplomacy.setAlliance = setAlliance

local function clearAlliance(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,4)
end
diplomacy.clearAlliance = clearAlliance

local function hasEmbassyWith(ownerTribe,hostTribe)
    return gen.isBit1(ownerTribe.treaties[hostTribe],8)
end
diplomacy.hasEmbassyWith = hasEmbassyWith

local function setEmbassyWith(ownerTribe,hostTribe)
    setTreatiesBit1(ownerTribe,hostTribe,8,true)
end
diplomacy.setEmbassyWith = setEmbassyWith

local function clearEmbassyWith(ownerTribe,hostTribe)
    setTreatiesBit0(ownerTribe,hostTribe,8,true)
end
diplomacy.clearEmbassyWith = clearEmbassyWith

local function hasVendettaWith(angryTribe,offendingTribe)
    return gen.isBit1(angryTribe.treaties[offendingTribe],5)
end
diplomacy.hasVendettaWith = hasVendettaWith

local function setVendettaWith(angryTribe,offendingTribe)
    setTreatiesBit1(angryTribe,offendingTribe,5,true)
end
diplomacy.setVendettaWith = setVendettaWith

local function clearVendettaWith(angryTribe,offendingTribe)
    setTreatiesBit0(angryTribe,offendingTribe,5,true)
end
diplomacy.clearVendettaWith = clearVendettaWith


-- a diplomaticOffer is a table with the following keys
--  .offerMaker = tribeID
--      the ID number of the tribe making the offer of a change in the
--      diplomatic state
--  .offerReceiver = tribeID
--      the ID number of the tribe receiving the offer of a change in
--      the diplomatic state
--  .offerType = string
--      "peace" offer is to establish a peace treaty
--      "ceaseFire" offer is to establish a cease fire state
--      "alliance" offer is to establish an alliance
--  .offerMoney = integer
--      The tribe making the offer will give this amount of money
--      to the receiver if the offer is accepted (or all money, 
--      if treasury is smaller)
--  .demandMoney = integer
--      The tribe making the offer will take this amount of money
--      from the receiver if the offer is accepted.  Offer can't be
--      accepted if receiver doesn't have the money
--

-- manageDiplomaticOffers(tribeID,functionState,offer)
--      
local function manageDiplomaticOffers(tribeID,functionState,offer)
   local functionState = functionState or "choose"
end

local function textTransform(s, translationTable)
   for i,v in pairs(translationTable) do
      s = s:gsub(v.code, v.value)
   end
   return s
end
      


-- Default amounts of money for gift-money screen
local defaultGiftMoneyAmounts = {}
defaultGiftMoneyAmounts[1] = "Add 1"
defaultGiftMoneyAmounts[5] = "Add 5"
defaultGiftMoneyAmounts[10] = "Add 10"
defaultGiftMoneyAmounts[50] = "Add 50"
defaultGiftMoneyAmounts[100] = "Add 100"
defaultGiftMoneyAmounts[500] = "Add 500"
defaultGiftMoneyAmounts[1000] = "Add 1000"
defaultGiftMoneyAmounts[5000] = "Add 5000"
defaultGiftMoneyAmounts[10000] = "Add 5000"

-- Offers a menu to gift a given amount of money 
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftMoneyText -> Text to display in main dialog text
--                 * giftMoneyConfirmation -> Text to display when money is gifted
--                 * giftMoneyAmounts -> A table with the available amounts and the text associated with them
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %RECEIVERADJECTIVE -> Tribe adjective of who is receiving the gift
--                 * %MONEY -> The amount of money given out
--
--    Tribe: The tribe to pass money to
local function giftMoneyMenu(tribe, options)
   local translationTable = { { code = "%%RECEIVER", value = tribe.name }, { code = "%%RECEIVERADJECTIVE", value = tribe.adjective } };
   options = options or {}
   local giftMoneyText = options.giftMoneyText or "Which amount should we gift to our %RECEIVER friends?"
   giftMoneyText = textTransform(giftMoneyText, translationTable)
   local giftMoneyAmounts = options.giftMoneyAmounts or defaultGiftMoneyAmounts
   local player = civ.getCurrentTribe()
   local totalMoney  = 0
   local prevMoney = -1
   local ended = false
   repeat
      local menuTable = {}
      local lastOne = 1
      for i,v in pairs(giftMoneyAmounts) do
	 if(i<=(player.money-totalMoney)) then
	    menuTable[i] = v
	 end
	 if(i+1) > lastOne then
	    lastOne = i+1
	 end
      end
      if(prevMoney~=-1) then
         menuTable[lastOne] = "Substract "..tostring(prevMoney).."!"
      end
      if(totalMoney>0) then
	 menuTable[lastOne+1] = "Yes, give "..tostring(totalMoney).."!"
      end

      local tmp = giftMoneyText .. "(".. tostring(totalMoney).. " cumulated)"
      local money = text.menu(menuTable, tmp, tmp, true)
      if giftMoneyAmounts[money]~=nil then
	 totalMoney = totalMoney + money
         prevMoney = money
      elseif money == lastOne then
         totalMoney = totalMoney - prevMoney
         prevMoney =  -1
      end
   until giftMoneyAmounts[money]==nil and money~=lastOne
   if totalMoney~=0 then
      tribe.money = tribe.money + totalMoney
      player.money = player.money - totalMoney
      translationTable[#translationTable + 1 ] = { code = "%%MONEY", value = totalMoney }
      local message = options.giftMoneyConfirmation or "%MONEY sent to our %RECEIVER friends!"
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end

--- Destroy (and retun all units in tile)
---
---   param is tile
---
---   returns array of units that have been destroyed
local function destroyUnitsIn(tile)
   local units = {}
   for unit in tile.units do
      units[#units+1] = { unittype = unit.type, veteran = unit.veteran, damage = unit.damage, needsHome = (not not unit.homeCity) }
   end
   for unit in tile.units do
      civ.deleteUnit(unit)
   end
   return units
end

-- Recreate array of units in tile (or set of tiles) for tribe
--
--   params are
--             units = array of units to be recreated
--             tile = Position, or a table of positions (see civlua.createUnit)
--             tribe = Owner of the unit
--
--   returns true if all are created, false otherwise
local function recreateUnitsIn(units, position, tribe)
   local allGood = true
   for i,unit in pairs(units) do
      local x = civlua.createUnit(unit.unittype, tribe, position)[1]
      if x~=nil then
	 x.veteran = unit.veteran
	 x.damage = unit.damage
     x.homeCity = nil
     if unit.needsHome then
         gen.homeToNearestCity(x)
     end


      else
	 allGood = false
      end
   end
   return allGood
end



-- Gift units to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftUnitsMaxCharUnitList -> Limit of characters for the list of units description (default: 300)
--                 * giftUnitsText -> Text to be shown to ask for confirmation
--                 * giftUnitsConfirmation -> Dialog to show after confirmation
--                 * giftUnitsLocations -> A list of locations per tribe name to put the gift. It will start with the first one,
--                                           and use all of them until one is valid
--                 * giftUnitsError -> A error message to be displayed in case no suitable location is found
--                   (only happens when giftUnitsLocations is provided)
--
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %RECEIVERADJECTIVE -> Tribe adjective of who is receiving the gift
--                 * %TILE     -> Tile where it happens
--                 * %UNITS     -> Friendly text about the units given
--
local function giftUnits(tribe, options)
   local function buildUnitsText(tile, maxChar)
      local text = ""
      local byType = {}
      local unitCount = 0
      for unit in tile.units do
          unitCount = unitCount+1
	 if byType[unit.type.id] == nil then
	    byType[unit.type.id] = 1
	 else
	    byType[unit.type.id] = byType[unit.type.id] + 1
	 end
      end
      local unitsInText = 0
      for i,v in pairs(byType) do
	 if text:len() < maxChar then
	    local thisPart = tostring(v).." "..civ.getUnitType(i).name
	    if text == "" then
	       text = thisPart
	    else
	       text = text..", "..thisPart
	    end
            unitsInText = unitsInText + v
	 end
      end
      
      if unitsInText < unitCount then
         text = text.." and "..tostring(unitCount-unitsInText).." other units"
      end
      return text
   end
	 
   local tile = civ.getCurrentTile()
   local maxChar = options.giftUnitsMaxCharUnitList or 300
   local translationTable = { { code = "%%RECEIVER", value = tribe.name },
      { code = "%%RECEIVERADJECTIVE", value = tribe.adjective },
      { code = "%%TILE", value = tostring(tile.x)..","..tostring(tile.y).." in map "..tostring(tile.z) },
      { code = "%%UNITS", value = buildUnitsText(tile,maxChar) }}
   local giftUnitsQuestion = options.giftUnitsText or "Do you confirm gifting %UNITS to %RECEIVER in %TILE?"
   giftUnitsQuestion = textTransform(giftUnitsQuestion, translationTable)
   local menuTable = {}
   menuTable[1] = "Ok!"
   local goAhead = text.menu(menuTable, giftUnitsQuestion, giftUnitsQuestion, true)
   if goAhead == 1 then
      local units = destroyUnitsIn(tile)
      local position = nil
      if options.giftUnitsLocations ~= nil and options.giftUnitsLocations[tribe.name] ~= nil then
	 position = options.giftUnitsLocations[tribe.name]
      else
	 position = {{ tile.x, tile.y, tile.z }}
      end
      local message = nil
      if recreateUnitsIn(units, position, tribe) then
	 message = options.giftUnitsConfirmation or "Units in %TILE transferred to %RECEIVER"
      else
	 message = options.giftUnitsError or "Some units were lost as no suitable destination square was found!"
      end
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end

-- Gift a city (non-captial) to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftCityText -> Text to be shown to ask for confirmation
--                 * giftCityConfirmation -> Dialog to show after confirmation
--                 * giftCityDestroyUnits -> Whether all units needs to be destroyed after the city is given out
--
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %RECEIVERADJECTIVE -> Tribe adjective of who is receiving the gift
--                 * %CITY     -> Name of the city
--
local function giftCity(tribe, options)
   local tile = civ.getCurrentTile()
   local city = tile.city
   local translationTable = { { code = "%%RECEIVER", value = tribe.name },
      { code = "%%RECEIVERADJECTIVE", value = tribe.adjective },
      { code = "%%CITY", value = city.name } }
   local giftCityQuestion = options.giftCityText or "Do you confirm gifting %CITY to %RECEIVER?"
   giftCityQuestion = textTransform(giftCityQuestion, translationTable)
   local menuTable = {}
   menuTable[1] = "Ok!"
   local goAhead = text.menu(menuTable, giftCityQuestion, giftCityQuestion, true)
   if goAhead == 1 then
      local units = destroyUnitsIn(tile)
      local destroyUnits = options.giftCityDestroyUnits or false
      city.owner = tribe
      local position = {{ tile.x, tile.y, tile.z }}
      local message = nil
      if destroyUnits or recreateUnitsIn(units, position, tribe) then
	 message = options.giftCityConfirmation or "%CITY transferred to %RECEIVER"
      else
	 message = "Unexpected error - Some units were lost!"
      end
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end


-- Gift a technology to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftTechText -> Tech to be shown in the Tech window
--                 * giftTechConfirmation -> Text to show when map is passed
--                 * giftTechNoTechs -> Text to show when no tech to offer
--                 * giftTechNotTrade -> Table with names of techs that can't be traded
--
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %RECEIVERADJECTIVE -> Tribe adjective of who is receiving the gift
--                 * $tech     -> Name of the tech
--
local function giftTechnology(tribe, options) -- 
   local function techInTable(tech, techTable)
      for i, v in pairs(techTable) do
	 if v == tech.name then
	    return true
	 end
      end
      return false
   end

   local translationTable = { { code = "%%RECEIVER", value = tribe.name },  { code = "%%RECEIVERADJECTIVE", value = tribe.adjective },};
   local player = civ.getCurrentTribe()
   local listTechs = {}
   local techTechs = {}
   local techTable = options.giftTechNotTrade or {}
   for techId = 0,255 do
       -- 253 techs max, so 0-252 is probably enough
       if civ.getTech(techId) then
        local tech = civ.getTech(techId)
        if not tribe:hasTech(tech) and player:hasTech(tech) and not techInTable(tech, techTable)
        then
	      listTechs[#listTechs+1] = tech.name
	      techTechs[#techTechs+1] = tech
        end
    end
   end
   if #listTechs == 0 then
      local message = options.giftTechNoTechs or  "There are no tech we can give to %RECEIVER"
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   else
      local giftTechText = options.giftTechText or "Which tech to give our friends %RECEIVER?"
      giftTechText = textTransform(giftTechText, translationTable)
      local techId = text.menu(listTechs, giftTechText, giftTechText, true)
      if techId ~= 0 then
	 local tech = techTechs[techId]
	 translationTable[#translationTable + 1] = { code = "$tech", value = tech.name } ;
	 tribe:giveTech(tech)
	 local message = options.giftTechConfirmation or "$tech given to %RECEIVER"
	 message = textTransform(message, translationTable)
	 civ.ui.text(message)
      end
   end
end
   



-- Offers a menu to present what can be given as a present to other civ
--
--    options is an optional table, and may contain different configuration
--    parameters for what and how to offer
--                 * mainDialogText -> Text to display in main dialog text
--                 * civSelectionText -> Text to display when selecting destination civ
--                 * giftMoneyText -> Text to display in main dialog text
--                 * giftMoneyConfirmation -> Text to display when money is gifted
--                 * giftMoneyAmounts -> A table with the available amounts and the text associated to them
--                 * sameCivPlayer -> Text when a player attemps to gift something to his/herself.
--                 * giftUnitsMaxCharUnitList -> Limit of characters for the list of units description (default: 300)
--                 * giftUnitsText -> Text to be shown to ask for confirmation
--                 * giftUnitsConfirmation -> Dialog to show after confirmation
--                 * giftUnitsLocations -> A list of locations per tribe name to put the gift. It will start with the first one,
--                                           and use all of them until one is valid
--                 * giftUnitsError -> A error message to be displayed in case no suitable location is found
--                   (only happens when giftUnitsLocations is provided)
--                 * giftCityText -> Text to be shown to ask for confirmation
--                 * giftCityConfirmation -> Dialog to show after confirmation
--                 * giftCityDestroyUnits -> Whether all units needs to be destroyed after the city is given out
--                 * forbidTileGiveaway -> if true, the option to give away units/city on the tile is not available
--
--    
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %RECEIVERADJECTIVE -> Tribe adjective of who is receiving the gift
--                 * %MONEY -> The amount of money given out
--                 * %TILE     -> Tile where it happens
--                 * %CITY0     -> Name of the city
--                 * %UNITS     -> Friendly text about the units given
--
--    Offers present regardless of the cursor position
--                    * Money
--                    * Technology
--                    * Map
--
--    Offers that depend on city/units present on the cursor
--                    * Unit
--                    * City
--
--      
local function diplomacyMenu(options)
   -- Returns if the city is capital
      local function isCapital(city)
	 return city and city:hasImprovement(civ.getImprovement(1))
      end
      local function buildOptions()
	 local tile = civ.getCurrentTile()
	 local menuTable = {}
	 menuTable[1] = "Gift money"
	 menuTable[2] = "Gift technology"
	 if (not options.forbidTileGiveaway) and tile.owner == civ.getCurrentTribe() then
	    if tile.city == nil then
	       local count = 0
	       for i in tile.units do
		  count = count + 1
	       end
	       if count > 0 then
		  menuTable[3] = "Gift units"
	       end
	    else
	       if not isCapital(tile.city) then
		  menuTable[4] = "Gift city"
	       end
	    end
	 end
	 return menuTable
      end

      options = options or {}
      local mainDialogText = options.mainDialogText or "Choose your option"
      local menuTable = buildOptions()
      local gift = text.menu(menuTable, mainDialogText, mainDialogText, true)
      local tribeId = nil
      if gift ~= 0 then
	 local civSelectionText = options.civSelectionText or "Choose the civ to gift to"
	 for i = 0, 7 do
	    menuTable[i+1] = civ.getTribe(i).name
	 end
	 tribeId = text.menu(menuTable, civSelectionText, civSelectionText, true)
      end
      if tribeId~=0 and gift ~=0 then
	 -- How I miss switch/case
	 tribeId = tribeId -1
	 local tribe  = civ.getTribe(tribeId)
	 local player = civ.getCurrentTribe()
	 if tribe.name ~= player.name
	 then
	    if gift == 1 then
	       giftMoneyMenu(tribe, options)
	    elseif gift == 2 then
	       giftTechnology(tribe, options)
	    elseif gift == 3 then
	       giftUnits(tribe, options)
	    elseif gift == 4 then
	       giftCity(tribe, options)
	    end
	 else
	    local errorMessage = options.sameCivPlayer or "You can't gift yourself!"
	    civ.ui.text(errorMessage)
	 end
      end
end
diplomacy.diplomacyMenu = diplomacyMenu

--  an alternate diplomacy model menu used in a cold war scenario
--      canGiveUnitFn(unit)-->bool
--          determines if a unit can be given away as a single unit
--      tribeCanReceiveUnitFn(unitBeforeGift,tribe)-->bool
--          determines if a tribe can receive a unit as a gift (so that a tribe
--          can be selected to receive a gift)
--      cityCanReceiveUnitFn(unitBeforeGift,destinationCity)--> bool or number
--          if false, city can't receive unit
--          if number, city can receive unit, but giver must pay that cost
--          if true, city can receive unit for free
--      afterUnitTransferFn(sourceCity,destinationCity,unitAfterTransfer)-->void
--          performs actions after a unit is transferred
--      canGiveTileFn(tile,giver)
--          if true, the tile and all its contents can be transferred to a new owner
--          if false, it can't
--      canReceiveTileFn(tile,giver,receiver)
--          if true, the tribe can receive the tile
--          if false, it can't
--

local function giftSingleUnit(canGiveUnitFn,tribeCanReceiveUnitFn,cityCanReceiveUnitFn,afterUnitTransferFn)
    -- choose unit to give
    local unitToGive = nil
    local menuTable = {}
    local choiceOffset = 2
    for unit in civ.getCurrentTile().units do
        if canGiveUnitFn(unit) then
            menuTable[unit.id+choiceOffset] = unit.type.name.." ("..((unit.homeCity and unit.homeCity.name) or "NONE")..((unit.veteran and ", Veteran)") or ")")
        end
    end
    local choice = text.menu(menuTable,"Choose a unit to give away.","",true)
    if choice == 0 then
        return
    else
        unitToGive = civ.getUnit(choice - choiceOffset)
    end
    
    local menuTable = {}
    local choiceOffset = 2
    local receiverTribe = nil
    for i=0,7 do
        if tribeCanReceiveUnitFn(unitToGive,civ.getTribe(i)) then
            menuTable[i+choiceOffset] = civ.getTribe(i).name
        end
    end
    local choice = text.menu(menuTable,"To whom shall we send our "..unitToGive.type.name.."?","",true)
    if choice == 0 then
        return
    else
        receiverTribe = civ.getTribe(choice-choiceOffset)
    end
    menuTable = {}
    local destination = nil
    for city in civ.iterateCities() do
        if city.owner == receiverTribe then
            local transportCost = cityCanReceiveUnitFn(unitToGive,city)
            if transportCost == true then
                transportCost = 0
            end
            if transportCost then
                menuTable[city.id+choiceOffset] = city.name.." ("..tostring(transportCost)..")"
            end
        end
    end
    choice = text.menu(menuTable,"Where shall we send our "..unitToGive.type.name.."?","",true)
    if choice == 0 then
        return
    else
        destination = civ.getCity(choice-choiceOffset)
    end
    local transportCost = cityCanReceiveUnitFn(unitToGive,destination)
    if transportCost == true then
        transportCost = 0
    end
    menuTable = {[1]="Yes.",[2]="No."}
    local menuText = "Shall we send our "..unitToGive.type.name.." unit to "..destination.name
    if transportCost > 0 then
        menuText = menuText.." and pay "..tostring(transportCost).." in transportation costs?"
    else
        menuText = menuText.."?"
    end
    choice = text.menu(menuTable,menuText,"")
    if choice == 2 then
        return
    end
    if transportCost > unitToGive.owner.money then
        text.simple("We can't afford to transport this unit.")
        return
    end
    local sourceCity = unitToGive.homeCity
    unitToGive.owner.money = unitToGive.owner.money - transportCost
    unitToGive.owner = destination.owner
    unitToGive:teleport(destination.location)
    unitToGive.homeCity = destination
    afterUnitTransferFn(sourceCity,destination,unitToGive)

    return
end


local function coldWarDiplomacyMenu(options,canGiveUnitFn,tribeCanReceiveUnitFn,cityCanReceiveUnitFn,afterUnitTransferFn,canGiveTileFn,canReceiveTileFn)
   -- Returns if the city is capital
      local function isCapital(city)
	 return city and city:hasImprovement(civ.getImprovement(1))
      end
      local function buildOptions()
	 tile = civ.getCurrentTile()
	 menuTable = {}
	 menuTable[1] = "Gift money"
	 menuTable[2] = "Gift technology"
	 if canGiveTileFn(civ.getCurrentTile(),civ.getCurrentTribe()) and tile.owner == civ.getCurrentTribe() then
	    if tile.city == nil then
	       count = 0
	       for i in tile.units do
		  count = count + 1
	       end
	       if count > 0 then
		  menuTable[3] = "Gift all units on tile"
	       end
	    else
	       if not isCapital(tile.city) then
		  menuTable[4] = "Gift city"
	       end
	    end
	 end
     menuTable[5] = "Give a unit on this tile"
	 return menuTable
      end

      options = options or {}
      local mainDialogText = options.mainDialogText or "Choose your option"
      menuTable = buildOptions()
      gift = text.menu(menuTable, mainDialogText, mainDialogText, true)
      if gift ~= 0 and gift ~= 5 then
          menuTable = {}
    	civSelectionText = options.civSelectionText or "Choose the civ to gift to"
	    for i = 0, 7 do
            if (gift == 3 or gift == 4) and not canReceiveTileFn(civ.getCurrentTile(),civ.getCurrentTribe(),civ.getTribe(i)) then
            else
	            menuTable[i+1] = civ.getTribe(i).name
            end
	    end
	    tribeId = text.menu(menuTable, civSelectionText, civSelectionText, true)
    elseif gift == 5 then
           giftSingleUnit(canGiveUnitFn,tribeCanReceiveUnitFn,cityCanReceiveUnitFn,afterUnitTransferFn)
           return
    elseif gift == 0 then
        return
    end
      if tribeId~=0 and gift ~=0 then
	 -- How I miss switch/case
	 tribeId = tribeId -1
	 tribe  = civ.getTribe(tribeId)
	 player = civ.getCurrentTribe()
	 if tribe.name ~= player.name
	 then
	    if gift == 1 then
	       giftMoneyMenu(tribe, options)
	    elseif gift == 2 then
	       giftTechnology(tribe, options)
	    elseif gift == 3 then
	       giftUnits(tribe, options)
	    elseif gift == 4 then
	       giftCity(tribe, options)
       elseif gift == 5 then
	    end
	 else
	    errorMessage = options.sameCivPlayer or "You can't gift yourself!"
	    civ.ui.text(errorMessage)
	 end
      end
end
diplomacy.coldWarDiplomacyMenu = coldWarDiplomacyMenu

-- Some currently cancelled stuff, that might be used later
--      unitForPurchaseFn(buyerTribe,unit)-->false or number
--          determines if a unit can be bought, and if so, what the price is
--          false means unit not for sale, number means it is for sale at that price
--      cityCanReceivePurchaseFn(city,buyerTribe,unitBeforePurchase)-->bool or number
--          determines if a city can receive a purchased unit (unit is still owned by seller tribe at this point)
--          if true, unit can be received at that city, if number, add that number to purchase cost
--          if false, the city can't receive the unit
--          
--          not complete
local function purchaseUnit(unitForPurchaseFn,cityCanReceivePurchaseFn)
    local buyer = civ.getCurrentTribe()
    local deliveryCity = nil
    local purchaseUnit = nil
    local choice = nil
    local function selectUnit(destCity)
        local choiceOffset = 2
        for unit in civ.iterateUnits() do
            local price = unitForPurchaseFn(buyer,unit)
            local transport = true
            if destCity then
                transport = cityCanReceivePurchaseFn(destCity,buyer,unit)
            end
            if transport then
                local costText = nil
                if transport == true then
                    costText = "Price: "..tostring(price)
                else
                    costText = "Total: "..tostring(price+transport).." Price: "..tostring(price).." Shipping: "..tostring(transport)
                end
                
                local description = unit.type.name.." ("..unit.owner.adjective

            end
        end



    end
    local function selectCity(boughtUnit)

    end
    while choice ~= 3 do
        menuTable = {}

        if purchaseUnit then
            menuTable[1] = "Purchase a different unit."
            menuTable[4] = "Clear unit purchase choice."
        else
            menuTable[1] = "Choose a unit to purchase."
        end
        if deliveryCity then
            menuTable[2] = "Choose a different city to receive the purchase."
            menuTable[5] = "Clear delivery city choice."
        else
            menuTable[2] = "Choose a city to receive your purchase."
        end
        if purchaseUnit and deliveryCity then
            local unitCost = unitForPurchaseFn(buyer,purchaseUnit)
            local deliveryCost = cityCanReceivePurchaseFn(city,buyer,purchaseUnit)
            if deliveryCost == true then
                deliveryCost = 0
            end
            if deliveryCost > 0 then
                menuTable[3] = "Spend "..tostring(unitCost+deliveryCost).." ("..tostring(unitCost).."+"..tostring(deliveryCost)..") to have a "..purchaseUnit.type.name.." delivered to "..deliveryCity.name.."."
            else
                menuTable[3] = "Spend "..tostring(unitCost+deliveryCost).." to have a "..purchaseUnit.type.name.." delivered to "..deliveryCity.name.."."
            end

        end

        choice = text.menu(menuTable,menuText,"",true)
        if choice == 0 then
            return
        elseif choice == 1 then
            purchaseUnit = selectUnit(deliveryCity)
        elseif choice == 2 then
            deliveryCity = selectCity(purchaseUnit)
        elseif choice == 4 then
            purchaseUnit = nil
        elseif choice == 5 then
            deliveryCity = nil
        end
    end

end
if rawget(_G,"console") then
    _G["console"].diplomacy = diplomacy
end

return diplomacy
