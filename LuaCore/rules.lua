-- The Rules module is a module that reads supplementary
-- @SECTIONS of rules.txt, and translates them to
-- tables or functions defining Lua events.
local gen = require("generalLibrary")
local readRules = require("readRules")
local text = require("text")
local civilopedia = require("civilopedia")
local discreteEvents = require("discreteEventsRegistrar")
local keyboard = require("keyboard")

local readFromFile = "rules_lst.txt"
local rulesTable = readRules.readRules(gen.getScenarioDirectory().."\\"..readFromFile,true)
local rules = {}

local function paddString(str,characters)
    while string.len(str) < characters do
        str = str.." "
    end
    return str
end



--  Combat Groups
local luaCombatGroupsSection = "@LSTCOMBATGROUPS"
local unitNameCharacterAllotment = 20 -- not including comma

local luaCombatGroupsPreamble = [[
;       Custom Combat Groups and Modifiers
; A) Unit Name: No direct effect, but if the unit name doesn't match
;       the name for the unit with the same ID, a warning is printed
;       in the console
; B) Combat Group Membership mask:     0: not in group;    1: in group
;       0000000000000001    Group 0
;       0000000000000010    Group 1
;       0000000000000100    Group 2
;       0000000000001000    Group 3
;       0000000000010000    Group 4
;       0000000000100000    Group 5
;       0000000001000000    Group 6
;       0000000010000000    Group 7
;       0000000100000000    Group 8  
;       0000001000000000    Group 9
;       0000010000000000    Group 10
;       0000100000000000    Group 11
;       0001000000000000    Group 12
;       0010000000000000    Group 13
;       0100000000000000    Group 14
;       1000000000000000    Group 15
; C) Percentage Increment:      Determines how much the modifier masks change with
;                               each increase.  25 means the increment is 25%
; D) Attack Modifier mask:      0: Can't attack group, 1-9: multiply attack power by percentage increment 
;                               when attacking that group.  That is, if the increment is 25,
;                               1: 25% power, 2: 50% power, 3: 75% power, 4: 100%, 5: 125%
;                               *: attack with normal power against group
; E) Defense Modifier mask:     0-9: multiply defender power by the percentage increment
;                               when defending against attacks from that group.
;                               That is, if the increment is 33.
;                               1: 33% of normal, 2: 66% of normal, 3: 99% normal, 4: 132% normal, etc
;                               *: defend at normal value against group
;        A                     B            C           D                  E]]
--345678901234567890,   1234567890123456,  123,  1234567890123456,  1234567890123456
local function buildLuaCombatGroupsSection()
    local sampleSection = luaCombatGroupsPreamble.."\n"..luaCombatGroupsSection.."\n"
    for i=0,civ.cosmic.numberOfUnitTypes-1 do
        sampleSection = sampleSection..paddString(civ.getUnitType(i).name..",",unitNameCharacterAllotment+4)
            .."0000000000000000,   50,  ****************,  **************** ; id: "..i.."\n"
    end
    return sampleSection
end

if rulesTable[luaCombatGroupsSection] and (rulesTable[luaCombatGroupsSection][civ.cosmic.numberOfUnitTypes-1] == nil
    or rulesTable[luaCombatGroupsSection][civ.cosmic.numberOfUnitTypes-1][0] == nil) then
    local sampleSection = buildLuaCombatGroupsSection()
    error("The section "..luaCombatGroupsSection.." has been declared, but either doesn't exist or is missing entries for some unit types.  A sample section follows:\n\n"..sampleSection)
end

local function checkNames(section)
    for i=0,civ.cosmic.numberOfUnitTypes-1 do
        if rulesTable[luaCombatGroupsSection][i][0] ~= civ.getUnitType(i).name then
            print("WARNING for "..section..": entry for unit type with ID "..i.." is called "..rulesTable[luaCombatGroupsSection][i][0].." but the unit type with that id has a name of "..civ.getUnitType(i).name.."." )
        end
    end
end

local numberOfCombatGroups = 16
-- Combat Group Names
local luaCombatGroupNamesSection = "@LSTCOMBATGROUPNAMES"
local luaCombatGroupNamesPreamble = text.substitute([[
;        Combat Group Names
;  This section defines names for the 16 combat groups
;  in  the %STRING1 section,
;  starting with Group 0 in the first line.
;  These names will be used for some automatically generated
;  documentation.]],{luaCombatGroupsSection,})
local function buildLuaCombatGroupNamesSection()
    local sampleSection = luaCombatGroupNamesPreamble.."\n"..luaCombatGroupNamesSection.."\n"
    for i=0,numberOfCombatGroups-1 do
        sampleSection = sampleSection.."Combat Group "..i..", ; Combat Group "..i.."\n"
    end
    return sampleSection
end

if rulesTable[luaCombatGroupNamesSection] and (rulesTable[luaCombatGroupNamesSection][numberOfCombatGroups-1]==nil
    or rulesTable[luaCombatGroupNamesSection][numberOfCombatGroups-1][0]==nil) then
    error("The section "..luaCombatGroupNamesSection.." has been declared, but either doesn't exist or is missing entries for some combat groups.  A sample section follows:\n\n"..buildLuaCombatGroupNamesSection())
end

local registeredCombatGroupNames = {}
for i=0,numberOfCombatGroups-1 do
    registeredCombatGroupNames[i] = (rulesTable[luaCombatGroupNamesSection] and rulesTable[luaCombatGroupNamesSection][i][0]) or "Combat Group "..i
end



if rulesTable[luaCombatGroupsSection] then
    checkNames(luaCombatGroupsSection)

    -- combatGroupMembership[unitTypeID][groupNumber] = true or nil
    --  if true, unitTypeID is part of the group specified
    --  if nil, it isn't
    --  groupNumbers go from 0 to numberOfCombatGroups-1
    local combatGroupMembership = {}
    -- combatGroupAttackMultipliers[unitTypeID][groupNumber] = number
    -- the unitType will multiply its attack by this value when fighting
    -- a unit in groupNumber
    local combatGroupAttackMultipliers = {}
    -- combatGroupDefenceMultipliers[unitTypeID][groupNumber] = number
    -- the unitType will multiply its defence by this value when fighting
    -- a unit in groupNumber
    local combatGroupDefenceMultipliers = {}
    for i=0,civ.cosmic.numberOfUnitTypes-1 do
        combatGroupMembership[i]={}
        local membershipMask = rulesTable[luaCombatGroupsSection][i][1]
        for groupNumber=0,numberOfCombatGroups-1 do
            if string.sub(membershipMask,-(groupNumber+1),-(groupNumber+1)) == "0" then
                combatGroupMembership[i][groupNumber] = nil
            elseif string.sub(membershipMask,-(groupNumber+1),-(groupNumber+1)) == "1" then
                combatGroupMembership[i][groupNumber] = true
                civilopedia.description(civ.getUnitType(i),registeredCombatGroupNames[groupNumber])
            else
                error("rules: "..luaCombatGroupsSection.." column B should have "..numberOfCombatGroups.." 1s and 0s.  "..rulesTable[luaCombatGroupsSection][i][0].." row doesn't match that specification.  Received: "..membershipMask)
            end
        end
        local increment = tonumber(rulesTable[luaCombatGroupsSection][i][2])
        if type(increment) ~= "number" then
            error("rules: "..luaCombatGroupsSection.." column C should have a number."..rulesTable[luaCombatGroupsSection][i][0].." row doesn't match that specification.  Received: "..rulesTable[luaCombatGroupsSection][i][2])
        end
        local increment = increment/100 -- the received increment is a % value
        local attackMultiplierMask = rulesTable[luaCombatGroupsSection][i][3]
        local defenceMultiplierMask = rulesTable[luaCombatGroupsSection][i][4]
        combatGroupAttackMultipliers[i] = {}
        combatGroupDefenceMultipliers[i] = {}
        for groupNumber=0,numberOfCombatGroups-1 do
            local attackMultiplier = string.sub(attackMultiplierMask,-(groupNumber+1),-(groupNumber+1))
            local defenceMultiplier = string.sub(defenceMultiplierMask,-(groupNumber+1),-(groupNumber+1))
            if attackMultiplier == "*" then
                combatGroupAttackMultipliers[i][groupNumber] = 1
            elseif type(tonumber(attackMultiplier)) == "number" then
                combatGroupAttackMultipliers[i][groupNumber] = increment*tonumber(attackMultiplier)
                civilopedia.description(civ.getUnitType(i),"x"..increment*tonumber(attackMultiplier).." Attack vs. "..registeredCombatGroupNames[groupNumber])
            else
                error("rules: "..luaCombatGroupsSection.." column D should have "..numberOfCombatGroups.." * or digits 0-9.  "..rulesTable[luaCombatGroupsSection][i][0].." row doesn't match that specification.  Received: "..attackMultiplierMask)
            end
            if defenceMultiplier == "*" then
                combatGroupDefenceMultipliers[i][groupNumber] = 1
            elseif type(tonumber(defenceMultiplier)) == "number" then
                combatGroupDefenceMultipliers[i][groupNumber] = increment*tonumber(defenceMultiplier)
                civilopedia.description(civ.getUnitType(i),"x"..increment*tonumber(defenceMultiplier).." Defense vs. "..registeredCombatGroupNames[groupNumber])
            else
                error("rules: "..luaCombatGroupsSection.." column E should have "..numberOfCombatGroups.." * or digits 0-9.  "..rulesTable[luaCombatGroupsSection][i][0].." row doesn't match that specification.  Received: "..defenceMultiplierMask)
            end
        end
    end
    console.combatGroupMembership = combatGroupMembership
    function rules.combatGroupCustomModifiers(attacker,defender) --> attackerCustomMultiplier,defenderCustomMultiplier
        local attackerCustomMultiplier = 1
        local attackerTypeID = attacker.type.id
        local defenderCustomMultiplier = 1
        local defenderTypeID = defender.type.id

        for groupNumber,val in pairs(combatGroupMembership[attackerTypeID]) do
            defenderCustomMultiplier = defenderCustomMultiplier*combatGroupDefenceMultipliers[defenderTypeID][groupNumber]
        end
        for groupNumber,val in pairs(combatGroupMembership[defenderTypeID]) do
            attackerCustomMultiplier = attackerCustomMultiplier*combatGroupAttackMultipliers[attackerTypeID][groupNumber]
        end
        return attackerCustomMultiplier, defenderCustomMultiplier
    end
else
    function rules.combatGroupCustomModifiers(attacker,defender) --> attackerCustomMultiplier,defenderCustomMultiplier
        return 1,1
    end

end

local function makeGenerateSectionWithUnits(preamble,sectionName,BForward)
    return function()
        local sampleSection = preamble.."\n"..sectionName.."\n"
        for i=0,civ.cosmic.numberOfUnitTypes-1 do
            sampleSection = sampleSection..paddString(civ.getUnitType(i).name..",",unitNameCharacterAllotment+4)..BForward.."; id: "..i.."\n"
        end
        return sampleSection
    end
end

local function verifySection(sectionName,expectedRowNumber,builderFunction)
    if rulesTable[sectionName] and (rulesTable[sectionName][expectedRowNumber] == nil
        or rulesTable[sectionName][expectedRowNumber][0] == nil) then
        error("The section "..sectionName.." does not have all the rows expected.  A sample section follows:\n\n"..builderFunction())
    end
end

local function buildGroups(sectionName,maskSize,column,lastLine,conversionFunction)
    local groups = {}
    for i=0,maskSize-1 do
        groups[i] = {}
    end
    for ID = 0,lastLine do
        local mask = rulesTable[sectionName][ID][column]
        for j=1,maskSize do
            if string.sub(mask,-j,-j) == "1" then
                groups[j-1][#groups[j-1]+1] = conversionFunction(ID)
            elseif string.sub(mask,-j,-j) ~= "0" then
                error("Lua Scenario Template Rules: "..sectionName.." column "..(column+1).." must have "..maskSize.."1s or 0s as the data.  In line "..ID.." received: "..mask)
            end
        end
    end
    return groups
end

local function filterByMask(groups,mask,default)
    local output = {}
    for key,value in pairs(groups) do
        if string.sub(mask,-(key+1),-(key+1)) == "1" then
            output[key] = value
        else
            output[key] = default
        end
    end
    return output
end

local function filterAndMerge(groups,mask)
    local filtered = filterByMask(groups,mask,{})
    filtered[#filtered+1] = filtered[0]
    filtered[0] = nil
    -- above is done since table.unpack ignores 0th element
    return gen.mergeTableValues(table.unpack(filtered))
end

-- Demotions

local demotionsSection = "@LSTDEMOTION"
local demotionMaskSize = 16
local demotionsPreamble=[[
;       Demotions
; A) Unit Name: No direct effect, but if the unit name doesn't match
;       the name for the unit with the same ID, a warning is printed
;       in the console
; B) Demotion Group Membership mask:     0: not in group;    1: in group
;       0000000000000001    Group 0
;       0000000000000010    Group 1
;       0000000000000100    Group 2
;       0000000000001000    Group 3
;       0000000000010000    Group 4
;       0000000000100000    Group 5
;       0000000001000000    Group 6
;       0000000010000000    Group 7
;       0000000100000000    Group 8  
;       0000001000000000    Group 9
;       0000010000000000    Group 10
;       0000100000000000    Group 11
;       0001000000000000    Group 12
;       0010000000000000    Group 13
;       0100000000000000    Group 14
;       1000000000000000    Group 15
;       
; C) Demotion Unit: If a unit is defeated, replace it with the unit 
;       corresponding id number (starting at 0).  nil means the unit is
;       not replaced upon destruction
; D) Destroy if Killed By Mask:  0: Ignore this group for demotions
;       1: If killer is in this group, destroy the unit instead of demoting it.
; E) Demotion Settings:
;       00000001    Vet Status Change: 0: Keep current vet status when demoted
;                                      1: Give vet status upon demotion    
;                                      2: Remove vet status upon demotion
;       00000010    Demote only if veteran: 0: Demote regardless of vet status
;                                      1: Demote only if veteran
;       0000ab00    Damage to replacing unit: Replacing unit should be given
;                                      ab damage upon creation, i.e. 00002300
;                                      would create a unit with 23 damage already
;       11110000    Reserved (no effect)
;          A                   B             C            D               E]]
local buildDemotionSection = makeGenerateSectionWithUnits(demotionsPreamble,demotionsSection,
    "0000000000000000,   nil,   0000000000000000,   00000000, ")

verifySection(demotionsSection,civ.cosmic.numberOfUnitTypes-1,buildDemotionSection)
if rulesTable[demotionsSection] then
    local demotionGroups = buildGroups(demotionsSection, demotionMaskSize,1,civ.cosmic.numberOfUnitTypes-1,civ.getUnitType)
    rules.demotionTable = {}
    local rulesSection = rulesTable[demotionsSection]
    for unitID=0,civ.cosmic.numberOfUnitTypes-1 do
        if type(tonumber(rulesSection[unitID][2])) == "number" then
            local datum = {}
            datum.replacementUnitType = civ.getUnitType(tonumber(rulesSection[unitID][2]))
            datum.destroyIfKilledBy = filterAndMerge(demotionGroups,rulesSection[unitID][3])
            datum.demoteOnlyIfVeteran = string.sub(rulesSection[unitID][4],-2,-2) == "1"
            if string.sub(rulesSection[unitID][4],-2,-2) ~= "1" and 
               string.sub(rulesSection[unitID][4],-2,-2) ~= "0" then
               error("Lua Scenario Template Rules "..demotionsSection..": Column E, flag ......X. should only have values 0 or 1")
           end
            if string.sub(rulesSection[unitID][4],-1,-1) == "1" then
                datum.vetStatus = "give"
            elseif string.sub(rulesSection[unitID][4],-1,-1) == "2" then
                datum.vetStatus = "remove"
            elseif string.sub(rulesSection[unitID][4],-1,-1) == "0" then
                datum.vetStatus = "preserve"
            else
                error("Lua Scenario Template Rules "..demotionsSection..": Column E, flag .......X should only have values 0, 1, or 2")
            end
            datum.damage = tonumber(string.sub(rulesSection[unitID][4],-4,-3))
            rules.demotionTable[unitID]=datum
        end
    end
else
    rules.demotionTable = {}
end


-- Promotions
local promotionSection = "@LSTPROMOTION"
local promotionMaskSize = 16
local promotionPreamble = [[
;       Promotions
; A) Unit Name: No direct effect, but if the unit name doesn't match
;       the name for the unit with the same ID, a warning is printed
;       in the console
; B) Veteran Status Chance: Percent chance for a unit to be given veteran status
; C) Promotion Group Membership mask:     0: not in group;    1: in group
;       0000000000000001    Group 0
;       0000000000000010    Group 1
;       0000000000000100    Group 2
;       0000000000001000    Group 3
;       0000000000010000    Group 4
;       0000000000100000    Group 5
;       0000000001000000    Group 6
;       0000000010000000    Group 7
;       0000000100000000    Group 8  
;       0000001000000000    Group 9
;       0000010000000000    Group 10
;       0000100000000000    Group 11
;       0001000000000000    Group 12
;       0010000000000000    Group 13
;       0100000000000000    Group 14
;       1000000000000000    Group 15
; D) Promotion Unit: If a unit is victorious in combat, it may be promoted to the unit with
;       this id number (starting at 0). nil means the unit can't be promoted
; E) Promotion Chance: Percent chance for a unit to be promoted to the new unit.
; F) Do Not Promote For Kill By Mask:  0: ignore this group for promotions
;       1: If defeated unit is in this group, do not promote the unit
; G) Promotion Flags:
;       00000001    Non Vet Upgrade: 1: unit can upgrade if not vet 0: must be vet to upgrade
;       00000010    Change Vet Status: 0:unit retains current vet status 1: unit loses vet status
;                        if it has it 2: unit gains vet status if it doesn't have it
;       00000100    Heal Unit: 0: Unit retains existing damage upon upgrade 1: unit fully healed
;       00001000    Preserve HP: 0: Unit keeps existing damage 1: Unit keeps existing hitpoints
;                   e.g. 20 hp unit with 7 hp (13 damage) left upgraded to 30 hp unit type:
;                   0: new hp is 17 (13 damage), 1: new hp is 7 (23 damage)
;       00010000    Spend Move: 0-9: spend this many movement points upon upgrade *: spend all movement
;       00100000    Not assigned
;       01000000    Not assigned
;       10000000    Not Assigned
; 
;          A             B            C             D      E            F               G]]
local buildPromotionSection = makeGenerateSectionWithUnits(promotionPreamble,promotionSection,
    " 50,   0000000000000000,   nil,   50,   0000000000000000,   00000000 ")

verifySection(promotionSection,civ.cosmic.numberOfUnitTypes-1,buildPromotionSection)
if rulesTable[promotionSection] then
    rules.upgradeInfoTable = {}
    rules.promotionChanceTable = {}
    local rulesSection = rulesTable[promotionSection]
    local promotionGroups = buildGroups(promotionSection,promotionMaskSize,2,civ.cosmic.numberOfUnitTypes-1,civ.getUnitType)
    for unitID=0,civ.cosmic.numberOfUnitTypes-1 do
        if not tonumber(rulesSection[unitID][2]) then
            error("Lua Scenario Template Rules "..promotionSection..": Column B should be a number (that represents a percent).  Received:"..tostring(rulesSection[unitID][2]))
        end
        if not tonumber(rulesSection[unitID][4]) then
            error("Lua Scenario Template Rules "..promotionSection..": Column E should be a number (that represents a percent).  Received:"..tostring(rulesSection[unitID][5]))
        end
        rules.promotionChanceTable[unitID] = tonumber(rulesSection[unitID][1])/100
        if type(tonumber(rulesSection[unitID][3])) == "number" then
            if tonumber(rulesSection[unitID][3]) >= civ.cosmic.numberOfUnitTypes then
                error("Lua Scenario Template Rules "..promotionSection..": Column D should be a number that represents a unit type.  That is, it should be less than "..(civ.cosmic.numberOfUnitTypes-1))
            end
            local datum = {}
            datum.upgradeUnitType = civ.getUnitType(tonumber(rulesSection[unitID][3]))
            datum.upgradeChance = tonumber(rulesSection[unitID][4])//100
            datum.excludedUnitTypes = filterAndMerge(promotionGroups,rulesSection[unitID][5])
            local flags = rulesSection[unitID][6]
            if string.sub(flags,-1,-1) == "1" then
                datum.nonVetUpgrade = true
            elseif string.sub(flags,-1,-1) == "0" then
                datum.nonVetUpgrade = false
            else
                error("Lua Scenario Template Rules "..promotionSection..": Column G, flag .......X should only have values 0 or 1.  For unit with ID "..unitID.." (A column name "..rulesSection[unitID][0]..") received: "..flags)
            end
            if string.sub(flags,-2,-2) == "0" then
                --nothing
            elseif string.sub(flags,-2,-2) == "1" then
                datum.clearVetStatus = true
            elseif string.sub(flags,-2,-2) == "2" then
                datum.giveVetStatus = true
            else
                error("Lua Scenario Template Rules "..promotionSection..": Column G, flag ......X. should only have values 0, 1, or 2.  For unit with ID "..unitID.." (A column name "..rulesSection[unitID][0]..") received: "..flags)
            end
            if string.sub(flags,-3,-3) == "0" then
                datum.healUnit = false
            elseif string.sub(flags,-3,-3) == "1" then
                datum.healUnit = true
            else
                error("Lua Scenario Template Rules "..promotionSection..": Column G, flag .....X.. should only have values 0 or 1.  For unit with ID "..unitID.." (A column name "..rulesSection[unitID][0]..") received: "..flags)
            end
            if string.sub(flags,-4,-4) == "0" then
                datum.preserveHP = false
            elseif string.sub(flags,-4,-4) == "1" then
                datum.preserveHP = true
            else
                error("Lua Scenario Template Rules "..promotionSection..": Column G, flag ....X... should only have values 0 or 1.  For unit with ID "..unitID.." (A column name "..rulesSection[unitID][0]..") received: "..flags)
            end
            if string.sub(flags,-5,-5) == "*" then
                datum.spendMove = true
            elseif type(tonumber(string.sub(flags,-5,-5))) == "number" then
                datum.spendMoveMult = tonumber(string.sub(flags,-5,-5))
            else
                error("Lua Scenario Template Rules "..promotionSection..": Column G, flag ...X.... should only have values 0-9 or * .  For unit with ID "..unitID.." (A column name "..rulesSection[unitID][0]..") received: "..flags)
            end
            datum.upgradeMessage = "For valor in combat, our %STRING1 unit has been promoted to a %STRING2 unit."
            rules.upgradeInfoTable[unitID]=datum
        end
    end
else
    rules.upgradeInfoTable = {}
end

local function generateRulesLST()
    local fileLocation = gen.getScenarioDirectory().."\\"..tostring(os.time())..readFromFile
    local message = "Do you wish to generate a Lua Scenario Template Rules File?  It will be written to "..fileLocation
    local choice = text.menu({"No","Yes"},message)
    if choice == 1 then
        return
    end
    local fileText = [[;
;       Lua Scenario Template Rules
;       This file is organized very similarly to the rules.txt file.
;       It is designed to provide you with some of the functionality
;       offered by Lua Events in a familiar format
;
]]
    fileText = fileText.."\n\n"..buildLuaCombatGroupsSection().."\n"
        ..buildLuaCombatGroupNamesSection().."\n"..buildDemotionSection().."\n"..buildPromotionSection()
    local file =  io.open(fileLocation,"a")
    io.output(file)
    io.write(fileText)
    io.close(file)
    civ.ui.text("A Lua Scenario Template Rules File has been generated at "..fileLocation)
end


function discreteEvents.onKeyPress(keyID)
    if keyID == keyboard.ctrl.shift.F4 then
        generateRulesLST()
    end
end

return rules
