local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

--      Leader Bonuses and Tracking
--
--      This module keeps track of "leader" units and the units that are under the
--      command of a leader (receiving a leadership bonus).
--      This module also provides automatic combat bonuses using combatModifiers
--
--
--
--
--  leaderClass = {
--
--      rank = string (not "")
--          The tile/name of the leader class
--          e.g. "Napoleon", "General"
--      seniority = number
--          If a unit could be under the leadership of multiple
--          leaders, the leader with lower seniority is chosen.
--          If two potential leaders have the same seniority,
--          the unit with smaller id number is chosen
--      subordinates = unitType or trait or table of unitTypes and traits
--          Units of these types/traits can be commanded by this
--          class of leader
--      alwaysLeaderType = nil or unitType or trait or table of unitTypes and traits
--          Units of these types/traits ALWAYS have this leader class
--          if nil, no unit types are this leader class by default
--          If a trait is used here, it must not be assigned as a conditional trait
--          to any unit type
--      unitInitialization = nil or integer or table of integers
--          bestows this leader class on the units corresponding to these
--          id numbers when either of these functions are called
--              leaderBonus.initializeLeaders()
--              console.initializeLeaders()
--          Any unit with an id not in an initialization table
--          (and not a unitType that is always a leader class)
--          will have its leader class removed
--      attackModifier = nil or number or combatModifier
--          if nil, this leader provides no bonus when its
--          subordinates attack (unless you program that elsewhere)
--          if number, multiply the unit's attack by this value
--          if combatModifier, an attacking unit subordinate to this leader
--          gains benefit of the combat modifier (provided all other
--          conditions are also met)
--
--      defenseModifier = nil or number or combatModifier
--          if nil, this leader provides no bonus when its subordinates
--          defend (unless you program that elsewhere)
--          if number, multiply the unit's defense by this value
--          if combatModifier, a defending unit subordinate to this
--          leader class gains benefit of the combat modifier
--          (provided all other conditions are also met)
--
--      responsibilityRadius = number
--          units become subordinate to this leader within this
--          many tiles (provided there is not a more senior
--          leader) 0 means only units sharing the leader's
--          tile become subordinate
--          nil means 0
--
--      subordinationRadius = nil or number
--          units remain subordinate to this leader within this
--          many tiles, even if they leave the responsibility
--          radius of the leader (unless they come under the
--          responsibilityRadius of a more senior leader).
--          if nil, subordinationRadius is the same as the
--          responsibilityRadius
--
--      allMapCommand = boolean
--          if true, this leader can command units on all
--          maps (within appropriate radii)
--          if false or nil, the leader can only command
--          units on its own map
--
--
--
--      
--          






local gen = require("generalLibrary"):minVersion(4)
local traits = require("traits"):minVersion(3)
local combatMod = require("combatModifiers"):minVersion(1)
local unitData = require("unitData"):minVersion(1)
require("setTraits")
local discreteEvents =require("discreteEventsRegistrar")

local leaderBonus = {}
-- leaderClassTable[rank] = leaderClass
local leaderClassTable  = {}


--print(gen.tableToString(traits.allTraits()))
local traitUnit = {["userdata"] = {["unitType"]=civ.isUnitType},["string"]=traits.allTraits(),}
local traitUnitNil = {["nil"] = true, ["userdata"] = {["unitType"]=civ.isUnitType},["string"]=traits.allTraits(),}
local nilNumCombatMod = {["nil"] = true, ["number"] = true, ["table"] = {combatMod.isCombatModifier, "a combatModifier (which can be created from a table with combatMod.newCombatModifier)"},}
local leaderClassKeys = {
    rank = {["string"] = true},
    seniority = {["number"]=true},
    subordinates = gen.vDIOrTableOfVDI(traitUnit),
    alwaysLeaderType = gen.vDIOrTableOfVDI(traitUnitNil),
    unitInitialization = {["nil"]=true,["number"]={minVal = 0, integer=true}},
    attackModifier = nilNumCombatMod,
    defenseModifier = nilNumCombatMod,
    responsibilityRadius = {["number"]={minVal = 0, integer=true}, }, --["nil"]=true,
    subordinationRadius = {["number"]={minVal = 0, integer=true}, }, --["nil"]=true,
    allMapCommand = {["nil"]=true,["boolean"]=true},
}
local leaderClassDefaultValues = {
    responsibilityRadius = 0,
    subordinationRadius = 0,
}

local newLeaderClass,isLeaderClass,mt = gen.createDataType("leaderClass",leaderClassKeys,{},leaderClassDefaultValues,{})
leaderBonus.newLeaderClass = newLeaderClass
leaderBonus.isLeaderClass = isLeaderClass

unitData.defineModulePhrase("leaderBonus","rank","","never")
unitData.defineModulePhrase("leaderBonus","commanderRank","","never")
unitData.defineModuleCounter("leaderBonus","commanderID",-1,nil,nil,"none","never",nil,nil)

-- leaderBonus.getCommanderRank(unit) -> string or false
-- if unit is subordinate to a leader class, return the leader's rank
-- otherwise, return false
--
function leaderBonus.getCommanderRank(unit)
    local commanderRank = unitData.phraseGetValue(unit,"commanderRank","leaderBonus")
    if commanderRank == "" then
        return false
    else
        return commanderRank
    end
end

function leaderBonus.removeSubordination(unit)
    unitData.counterReset(unit,"commanderID","leaderBonus")
    unitData.phraseReset(unit,"commanderRank","leaderBonus")
end


function leaderBonus.getCommander(unit)
    local commanderID = unitData.counterGetValue(unit,"commanderID","leaderBonus")
    if commanderID >= 0 then
        if civ.getUnit(commanderID) then
            return civ.getUnit(commanderID) 
        else
            leaderBonus.removeSubordination(unit)
            return false
        end
    else
        return false
    end
end


-- leaderBonus.getRank(unit) --> string or false
--  if the unit has a leadership rank, return the name
--  of that rank.  Return false otherwise
function leaderBonus.getRank(unit)
    local rank = unitData.phraseGetValue(unit,"rank","leaderBonus")
    if rank == "" then
        return false
    else
        return rank
    end
end

local function iterateUnitTypes()
    return coroutine.wrap(function()
        for id = 1,civ.cosmic.numberOfUnitTypes-1 do
            coroutine.yield(civ.getUnitType(id))
        end
    end)
end

-- validSubordinate(unitType,rankTitle) --> boolean
--  returns true if the unitType can be subordinate to the
--  supplied rank

-- addValidSubordination(unitTypeOrTrait,rankTitle)
--      allows unitType to be subordinate to that rankTitle
--      if trait, allows all unitType with that trait to be subordinate to the rankTitle
--      if true, all unitTypes can be subordinate to the rankTitle
local validSubordinate, addValidSubordination = 
    traits.makeItemTraitQuickStringAssociation(civ.isUnitType, function(unitType) return unitType.id end, 
        "unitType", iterateUnitTypes)

-- hasQuality(unitType,qualityString)
--      returns true if the unitType has the quality given by QualityString, false otherwise
--
--  addQuality(unitTypeOrTrait, qualityString)
--      associates a qualityString with a unitType or trait
--      if unitTypeOrTrait is true, associate with all items
local hasQualityBase, addQualityBase =
    traits.makeItemTraitQuickStringAssociation(civ.isUnitType, function(unitType) return unitType.id end, 
        "unitType", iterateUnitTypes)

local eligibleQualities = {["allMapCommand"]=true}
local function hasQuality(unitType,qualityString)
    if eligibleQualities[qualityString] then
        return hasQualityBase(unitType,qualityString)
    end
    error("leaderBonus.hasQuality: "..qualityString.." is an invalid quality.")
end
local function addQuality(unitType,qualityString)
    if eligibleQualities[qualityString] then
        return addQualityBase(unitType,qualityString)
    end
    error("leaderBonus.addQuality: "..qualityString.." is an invalid quality.")
end

local function bestRadius(radius,bestSoFar)
    radius = radius or 0
    bestSoFar = bestSoFar or 0
    return math.max(radius,bestSoFar)
end

-- getLeaderSearchRadius(unitType) --> number
--      determines how far away a unit should
--      search for a radius
--  addLeaderCommandRadius(itemOrTrait,radius)
--      registers that a leader for this item or trait
--      can take command of a unit within the given radius
local getLeaderSearchRadius, addLeaderCommandRadius = traits.makeItemTraitComputation(civ.isUnitType, 
    function(unitType) return unitType.id end,"unitType", iterateUnitTypes,bestRadius)

-- alwaysLeaderUnits[unitType.id] = leaderRank
local alwaysLeaderUnits = {}

local function addAlwaysLeaderUnits(value,rankTitle)
    local function addUnit(unitType)
        if alwaysLeaderUnits[unitType.id] then
            error("leaderBonus.registerLeaderClass: "..rankTitle..": alwaysLeaderType: the unit type "..unitType.name.." is already registered as being always a leader for the rank "..alwaysLeaderUnits[unitType.id]..".")
        end
        alwaysLeaderUnits[unitType.id] = rankTitle
    end
    if value == nil then
        return
    elseif type(value) == "table" then
        for _,v in pairs(value) do
            addAlwaysLeaderUnits(v,rankTitle)
        end
    elseif type(value) == "string" then
        for i=0,civ.cosmic.numberOfUnitTypes-1 do
            local unitType = civ.getUnitType(i)
            if traits.hasTrait(civ.getUnitType(i),value) then
                addUnit(unitType)
            end
            if traits.conditionalTraitTable(civ.getUnitType(i))[value] then
                error("leaderBonus: units with the trait '"..value.."' are always supposed to have rank '"
                ..rankTitle.."', but the "..unitType.name.." has been assigned the trait '"..value..
                "' as a conditional trait.  It is not allowed to use conditional traits to define alwaysLeaderTypes.")
            end
        end
    elseif civ.isUnitType(value) then
        addUnit(value)
    end
end


-- initializationTable[unitID] = rankTitle
local initializationTable = {}
-- leaderBonus.registerLeaderClass(leaderClass)
--  registers the leader class
function leaderBonus.registerLeaderClass(leaderClass)
    if not isLeaderClass(leaderClass) then
        leaderClass = newLeaderClass(leaderClass)
    end
    if leaderClass.rank == "" then
        error("leaderBonus.registerLeaderClass: leader class can't have an empty string as the leader's rank.")
    end
    if leaderClassTable[leaderClass.rank] then
        error("leaderBonus.registerLeaderClass: the rank "..leaderClass.rank.." is used more than once.  All leader classes must have distinct rank names.")
    end
    leaderClassTable[leaderClass.rank] = leaderClass
    addAlwaysLeaderUnits(leaderClass.alwaysLeaderType,leaderClass.rank)
    local attackCombatModifier = leaderClass.attackModifier
    local defenseCombatModifier = leaderClass.defenseModifier
    if type(attackCombatModifier) == "number" then
        attackCombatModifier = combatMod.newCombatModifier({aCustomMult = attackCombatModifier})
        leaderClass.attackModifier = attackCombatModifier
    end
    if type(defenseCombatModifier) == "number" then
        defenseCombatModifier = combatMod.newCombatModifier({dCustomMult = defenseCombatModifier})
        leaderClass.defenseModifier = defenseCombatModifier
    end
    if attackCombatModifier then
        if attackCombatModifier.customCheck then
            local checkFn = attackCombatModifier.customCheck
            leaderClass.attackModifier.customCheck = function(attacker,defender)
                return leaderBonus.getCommanderRank(attacker) == leaderClass.rank and checkFn(attacker,defender)
            end
        else
            leaderClass.attackModifier.customCheck = function(attacker,defender)
                return leaderBonus.getCommanderRank(attacker) == leaderClass.rank
            end
        end
        combatMod.registerCombatModificationRule(leaderClass.attackModifier)
    end
    if defenseCombatModifier then
        if defenseCombatModifier.customCheck then
            local checkFn = defenseCombatModifier.customCheck
            leaderClass.defenseModifier.customCheck = function(attacker,defender)
                return leaderBonus.getCommanderRank(defender) == leaderClass.rank and checkFn(attacker,defender)
            end
        else
            leaderClass.defenseModifier.customCheck = function(attacker,defender)
                return leaderBonus.getCommanderRank(defender) == leaderClass.rank 
            end
        end
        combatMod.registerCombatModificationRule(leaderClass.defenseModifier)
    end
    for _, v in pairs(gen.tableWrap(leaderClass.subordinates)) do
        addValidSubordination(v,leaderClass.rank)
        if leaderClass.allMapCommand then
            addQuality(v,"allMapCommand")
        end
        addLeaderCommandRadius(v,leaderClass.responsibilityRadius)
    end
    for _,unitID in pairs(gen.tableWrap(leaderClass.unitInitialization)) do
        if initializationTable[unitID] then
            error("leaderBonus.registerLeaderClass: the leaderClass '"..leaderClass.rank..
            "' has registered the unit with id "..unitID.." to be initialized as a leader.  "
            .."However, the id "..unitID.." has already been registered for initialization by "
            .."the leaderClass '"..initializationTable[unitID].."'.")
        end
        initializationTable[unitID] = leaderClass.rank
    end
end

local function iterateUnitsInLeadershipRadius(tile,leader)
    local leaderClass = nil
    if type(leader) == "table" then
        leaderClass = leader
    elseif type(leader) == "string" then
        leaderClass = leaderClassTable[leader]
        if not leaderClass then
            error("leaderBonus.iterateUnitsInResponsibilityRadius: #2 argument is not a rank.  Received: "..tostring(leader))
        end
    elseif civ.isUnit(leader) then
        local rank = leaderBonus.getRank(leader)
        if not rank then
            error("leaderBonus.iterateUnitsInResponsibilityRadius: #2 argument unit is not a leader")
        end
        leaderClass = leaderClassTable[rank]
    else
        error("leaderBonus.iterateUnitsInResponsibilityRadius: #2 argument must be a leaderClass, rank, or leader unit.  Received:"..tostring(leader))
    end
    local radius = math.max(leaderClass.responsibilityRadius, leaderClass.subordinationRadius)
    local map = tile.z
    if leaderClass.allMapCommand then
        map = nil
    end
    return gen.nearbyUnits(tile,radius,map)
end



-- leaderBonus.makeSubordinate(unit,leaderUnit)
-- makes the unit subordinate to the leaderUnit, if the leaderUnit
-- if the leader unit has a rank and the unit can be subordinate
-- to that rank
function leaderBonus.makeSubordinate(unit,leaderUnit)
    if leaderBonus.getRank(leaderUnit) then
        unitData.counterSetValue(unit,"commanderID",leaderUnit.id,"leaderBonus")
        unitData.phraseSetValue(unit,"commanderRank",leaderBonus.getRank(leaderUnit),"leaderBonus")
    end
end






-- leaderBonus.commissionLeader(unit,rank,noErrorIfFailure=false)
--      bestows the unit with the leader class corresponding to rank
--      if the unitType can't be made this leader (because it is an alwaysLeaderType),
--      an error is thrown, unless noErrorIfFailure is set to true, in which
--      case, nothing is done
function leaderBonus.commissionLeader(unit,rank,noErrorIfFailure)
    if not leaderClassTable[rank] then
        error("leaderBonus.commissionLeader: the rank "..tostring(rank).." is not a registered leaderClass.")
    end
    if alwaysLeaderUnits[unit.type.id] then
        if alwaysLeaderUnits[unit.type.id] == rank then
            unitData.phraseSetValue(unit,"rank",rank,"leaderBonus")
        elseif not noErrorIfFailure then
            error("leaderBonus.commissionLeader: attempted to give rank of "..rank.." to unit: "..tostring(unit)
            .." but the unit type "..unit.type.name.." must always have rank "..alwaysLeaderUnits[unit.type.id]..".")
        end
    else
        unitData.phraseSetValue(unit,"rank",rank,"leaderBonus")
        for possibleFollower in iterateUnitsInLeadershipRadius(unit.location,rank) do
            leaderBonus.updateCommander(possibleFollower)
        end
    end
end

-- leaderBonus.dismissLeader(unit,noErrorIfFailure=false)
-- removes the leaderClass (if any exists) from the unit
-- if the unit's type can't have leadership removed,
-- (because it is an alwaysLeaderType), an error will be
-- thrown, unless noErrorIfFailure is set to true
function leaderBonus.dismissLeader(unit,noErrorIfFailure)
    local rank = leaderBonus.getRank(unit)
    if not rank then
        return
    end
    if alwaysLeaderUnits[unit.type.id] then
        if not noErrorIfFailure then
            error("leaderBonus.dismissLeader: attempted to remove rank of "..alwaysLeaderUnits[unit.type.id].." from unit: "..tostring(unit)
            .." but the unit type "..unit.type.name.." must always have rank "..alwaysLeaderUnits[unit.type.id]..".")
        end
    else
        unitData.phraseReset(unit,"rank","leaderBonus")
        for possibleFollower in iterateUnitsInLeadershipRadius(unit.location,rank) do
            leaderBonus.updateCommander(possibleFollower)
        end
    end
end


-- leaderBonus.changeRank(unit,newRank)
--  changes the rank of the leader, updates all subordinates to be commanded
--  by the new rank, then updates all nearby units in case leadership changes
function leaderBonus.changeRank(unit,newRank)
    local newLeaderClass = leaderClassTable[newRank]
    if not newLeaderClass then
        error("leaderBonus.changeRank: the newRank "..tostring(newRank).." is not a registered leaderClass.")
    end
    -- do nothing if the rank doesn't change
    local currentLeaderClass = leaderClassTable[leaderBonus.getRank(unit)]
    if newRank == currentLeaderClass.rank then
        return 
    end
    if alwaysLeaderUnits[unit.type.id] then
        error("leaderBonus.changeRank: the unit type "..unit.type.name.." can't have its rank changed, since "
        .."it must always have the rank "..alwaysLeaderUnits[unit.type.id]..".")
    end
    unitData.phraseSetValue(unit,"rank",newRank,"leaderBonus")
    local updateLeaderClass = currentLeaderClass
    if math.max(newLeaderClass.responsibilityRadius,newLeaderClass.subordinationRadius) >
        math.max(currentLeaderClass.responsibilityRadius,currentLeaderClass.subordinationRadius) then
        updateLeaderClass = newLeaderClass
    end
    for possibleFollower in iterateUnitsInLeadershipRadius(unit.location,updateLeaderClass) do
        if leaderBonus.getCommander(possibleFollower) == unit then
            unitData.phraseSetValue(possibleFollower,"commanderRank",newRank,"leaderBonus")
        end
        if possibleFollower.owner == unit.owner then
            leaderBonus.updateCommander(possibleFollower)
        end
    end
end




-- verifyCommander(unit)
--      checks if the unit's commander exists, has the correct rank,
--      and is within the subordinationRadius
--      If it is not, clear the unit's data
local function verifyCommander(unit)
    if unitData.phraseIsNil(unit,"commanderRank","leaderBonus") then
        unitData.phraseReset(unit,"commanderRank","leaderBonus")
        return
    end
    local cmdrRank = unitData.phraseGetValue(unit,"commanderRank","leaderBonus")
    local leaderUnit = civ.getUnit(unitData.counterGetValue(unit,"commanderID","leaderBonus"))
    if not leaderUnit or unitData.phraseGetValue(leaderUnit,"rank","leaderBonus") ~= cmdrRank then
        unitData.phraseReset(unit,"commanderRank","leaderBonus")
        unitData.counterReset(unit,"commanderID","leaderBonus")
        return
    end
    local leaderClass = leaderClassTable[cmdrRank]
    if gen.distance(unit,leaderUnit) > leaderClass.subordinationRadius then
        unitData.phraseReset(unit,"commanderRank","leaderBonus")
        unitData.counterReset(unit,"commanderID","leaderBonus")
        return
    end
    if (not leaderClass.allMapCommand) and unit.location.z ~= leaderUnit.location.z then
        unitData.phraseReset(unit,"commanderRank","leaderBonus")
        unitData.counterReset(unit,"commanderID","leaderBonus")
        return
    end
end
    

-- leaderBonus.firstOutranksSecond(firstLeader,secondLeader) --> boolean
--      returns true if the firstLeader (unit) outranks the secondLeader (unit)
--      outrank means leaderClass.seniority is lower (or if they are equal, unitID is lower)
--      firstLeader must always be a unit, return false if firstLeader has no rank
--      secondLeader can be false/nil, if so, return true (provided firstLeader has a rank)
--      if secondLeader is a unit, it must have a rank
function leaderBonus.firstOutranksSecond(firstLeader,secondLeader)
    local firstLeaderRank = leaderBonus.getRank(firstLeader)
    if not firstLeaderRank then
        return false
    end
    if not secondLeader then
        return true
    end
    local secondLeaderRank = leaderBonus.getRank(secondLeader)
    local firstLeaderSeniority = leaderClassTable[firstLeaderRank].seniority
    local secondLeaderSeniority = leaderClassTable[secondLeaderRank].seniority
    if firstLeaderSeniority < secondLeaderSeniority then
        return true
    elseif secondLeaderSeniority > firstLeaderSeniority then
        return false
    else
        return firstLeader.id < secondLeader.id
    end
end



-- leaderBonus.updateCommander(unit)
-- checks if the unit's current commander can remain in command
-- and searches nearby for a higher ranking commander

function leaderBonus.updateCommander(unit)
    -- some code might kill/delete the unit before this applies
    -- if so, the unit.location will not be a valid tile
    local l = unit.location
    if not civ.isTile(civ.getTile(l.x,l.y,l.z)) then
        leaderBonus.removeSubordination(unit)
        return
    end
    verifyCommander(unit)
    local searchRadius = getLeaderSearchRadius(unit.type)
    local searchMap = nil -- nil means gen.nearbyUnits will search all maps
    if not hasQuality(unit.type,"allMapCommand") then
        searchMap = unit.location.z
    end
    local function updateProvisionalLeader(candidate,pL)
        if candidate.owner ~= unit.owner or not leaderBonus.firstOutranksSecond(candidate,pL) then
            return pL
        end
        local newRank = leaderBonus.getRank(candidate)
        if not validSubordinate(unit.type,newRank) then
            return pL
        end
        local candidateLeaderClass = leaderClassTable[newRank]
        if gen.tileDist(unit.location,candidate.location) > candidateLeaderClass.responsibilityRadius
            or ((not candidateLeaderClass.allMapCommand) and unit.location.z ~= candidate.location.z) then
            return pL
        end
        return candidate
    end
    local provisionalLeader = leaderBonus.getCommander(unit)
    for nearbyUnit in gen.nearbyUnits(unit.location,searchRadius,searchMap) do
        if alwaysLeaderUnits[nearbyUnit.type.id] and not leaderBonus.getRank(nearbyUnit) then
            leaderBonus.commissionLeader(nearbyUnit,alwaysLeaderUnits[nearbyUnit.type.id])
        end
        provisionalLeader = updateProvisionalLeader(nearbyUnit,provisionalLeader)
    end
    if provisionalLeader then
        leaderBonus.makeSubordinate(unit,provisionalLeader)
    end
end


-- leaderBonus.transferSubordination(unit,originalLeader,newLeader)
--      if the unit is subordinate to the original leader, make
--      it subordinate to the newLeader
--      if the unit is not subordinate to the original leader, do nothing
function leaderBonus.transferSubordination(unit,originalLeader,newLeader)
    if leaderBonus.getCommander(unit) == originalLeader then
        leaderBonus.makeSubordinate(unit,newLeader)
    end
end

function discreteEvents.onUnitDeleted(originalUnit,replacingUnit)
    local rank = leaderBonus.getRank(originalUnit)
    if rank and replacingUnit then
        leaderBonus.commissionLeader(replacingUnit,rank)
        local leaderClass = leaderClassTable[rank]
        for nearbyUnit in iterateUnitsInLeadershipRadius(originalUnit.location,leaderClass) do
            leaderBonus.transferSubordination(nearbyUnit,originalUnit,replacingUnit)
        end
    elseif rank then
        unitData.phraseReset(originalUnit,"rank","leaderBonus")
        for possibleFollower in iterateUnitsInLeadershipRadius(originalUnit.location,rank) do
            leaderBonus.updateCommander(possibleFollower)
        end
    end
end

function discreteEvents.onCityProduction(city,item)
    if civ.isUnit(item) and alwaysLeaderUnits[item.type.id] then
        leaderBonus.commissionLeader(item,alwaysLeaderUnits[item.type.id])
    end
end

function discreteEvents.onActivateUnit(unit,source,rep)
    if alwaysLeaderUnits[unit.type.id] and not leaderBonus.getRank(unit) then
        leaderBonus.commissionLeader(unit,alwaysLeaderUnits[unit.type.id])
    end
    leaderBonus.updateCommander(unit)
end






gen.versionFunctions(leaderBonus,versionNumber,fileModified,"LuaCore".."\\".."leaderBonus.lua")

--  leaderBonus.initializeLeaders()
--  console.initializeLeaders()
--      uses the information in leaderClass.alwaysLeaderType and leaderClass.unitInitialization
--      to commission units as leaders
function leaderBonus.initializeLeaders()
    for unit in civ.iterateUnits() do
        if initializationTable[unit.id] then
            if alwaysLeaderUnits[unit.type.id] and alwaysLeaderUnits[unit.type.id] ~= initializationTable[unit.id] then
                error("leaderBonus.initializeLeaders: The unit with id number .."..unit.id.." was registered to "
                .."be initialized with rank '"..initializationTable[unit.id].."', but its unit type "..
                "("..unit.type.name..") must always have the rank '"..alwaysLeaderUnits[unit.type.id].."'.")
            end
            leaderBonus.commissionLeader(unit,initializationTable[unit.id])
        elseif alwaysLeaderUnits[unit.type.id] then
            leaderBonus.commissionLeader(unit,alwaysLeaderUnits[unit.type.id])
        end
    end
end
if _G.console then
    _G.console.initializeLeaders = leaderBonus.initializeLeaders
end

return leaderBonus
