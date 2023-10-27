local versionNumber = 4
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

-- The traits module associates strings with different
-- civilization objects, for more convenient coding.
--
-- For example, you can assign the "tank" trait to certain
-- units, and then check for the "tank" trait whenever it
-- is relevant, instead of maintaining different tables for
-- each time you want to check if something is a tank.

local gen = require("generalLibrary"):minVersion(1)
local discreteEvents = require("discreteEventsRegistrar"):minVersion(3)
local traits = {version=versionNumber}
gen.versionFunctions(traits,versionNumber,fileModified,"LuaCore".."\\".."traits.lua")

--      traitTables
--  a traitTable is a table of tables, with the outer
--  index being the id of the object, and the inner
--  index being the trait string.  The value is either a
--  boolean, nil, or a function()-->bool
--  If the value is true (or the function returns true), 
--  then the corresponding object has the attribute.
--      traitTable[object.id][traitString] = nil or bool or function()-->bool


local unitTypeTraits = {}
for i=0,(civ.cosmic.numberOfUnitTypes-1) do
    unitTypeTraits[i] = {}
end

local improvementTraits = {}
for i=0,39 do
    improvementTraits[i]={}
end

local wonderTraits = {}
for i=0,27 do
    wonderTraits[i]={}
end

local techTraits = {}
for i=0,255 do
       -- 253 techs max, so 0-252 is probably enough
    if civ.getTech(i) then
        techTraits[i] = {}
    end
end

-- baseTerrain
--      a baseTerrainObject is converted to an integer by
--          16*baseTerrain.map+baseTerrain.type
--          for results ranging from 0 to 63

local baseTerrainTraits = {}
for i=0,63 do
    baseTerrainTraits[i]={}
end

-- terrain
--      a terrainObject is converted to an integer by
--          3*16*terrain.map+3*terrain.type+terrain.resource
--          for results ranging from 0 to 191
local terrainTraits = {}
for i=0,191 do
    terrainTraits[i] = {}
end

local tribeTraits = {}
for i=0,7 do
    tribeTraits[i]={}
end



local allowedTraits = {}
local allowedTraitsSpecified = false

local function allowedTraitsRun(functionName)
    if not allowedTraitsSpecified then
        error(functionName..": the function traits.allowedTraits must be executed before you can use this function.  If traits.allowedTraits isn't in this file, add a require line to this file for the file that traits.allowedTraits is executed in.  In the standard template, this should be\nrequire(\"setTraits\")")
    end
end

-- specify all the allowed traits,
-- arguments can be either strings or 
-- tables of strings
function traits.allowedTraits(...)
    if allowedTraitsSpecified then
        error("traits.allowedTraits: you can only run this function once during script initialization.")
    end
    local argList = {...}
    for __,arg in pairs(argList) do
        local argTable = arg
        if type(argTable) ~= "table" then
            argTable = {argTable}
        end
        for ___,traitString in pairs(argTable) do
            if type(traitString) ~="string" then
                error("traits.allowedTraits: only strings can be traits, but you've instead"..
                "provided a "..type(traitString)..",\n"..tostring(traitString))
            end
            allowedTraits[traitString]=true
        end
    end
    allowedTraitsSpecified = true
end

-- returns a copy of all allowed traits in the form {["trait"]=true}
function traits.allTraits()
    if not allowedTraitsSpecified then
        error("traits.allTraits: traits.allowedTraits must be called before traits.allTraits can be used.")
    end
    return gen.copyTable(allowedTraits)
end

---Returns true if the string is an allowed trait
---And False otherwise.
---Throws an error if traits.allwedTraits has not been called
---@param traitString string
---@return boolean
function traits.isTrait(traitString)
    if not allowedTraitsSpecified then
        error("traits.isTrait: traits.allowedTraits must be called before traits.isTrait can be used.")
    end
    return not not allowedTraits[traitString]
end


-- returns the appropriate traitTable for a given object
local function selectTraitTable(object)
    if civ.isUnitType(object) then
        return unitTypeTraits
    elseif civ.isImprovement(object) then
        return improvementTraits
    elseif civ.isWonder(object) then
        return wonderTraits
    elseif civ.isTech(object) then
        return techTraits
    elseif civ.isBaseTerrain(object) then
        return baseTerrainTraits
    elseif civ.isTerrain(object) then
        return terrainTraits
    elseif civ.isTribe(object) then
        return tribeTraits
    else
        error("traits.lua: The current version of traits.lua can't assign a trait to this object:\n"
            ..tostring(object).."\n")
    end
end

local function getTraitID(object)
    if civ.isUnitType(object) then
        return object.id
    elseif civ.isImprovement(object) then
        return object.id
    elseif civ.isWonder(object) then
        return object.id
    elseif civ.isTech(object) then
        return object.id
    elseif civ.isBaseTerrain(object) then
        return 16*object.map+object.type
    elseif civ.isTerrain(object) then
        return 48*object.map+3*object.type+object.resource
    elseif civ.isTribe(object) then
        return object.id
    else
        error("traits.lua: The current version of traits.lua can't assign a trait to this object:\n"
            ..tostring(object).."\n")
    end
end

local showWarnings = true
-- disables warning messages for the traits module
function traits.noWarnings()
    showWarnings = false
end
-- Set to false once a warning has been displayed
local firstWarning = true
local function warning(warning)
    if not showWarnings then
        return
    end
    if firstWarning then
        print("You can disable warnings from traits.lua by adding a line\ntraits.noWarnings()\nbefore you assign traits.")
    end
    print(warning)
end

local function iterateTraitStrings(table,functionName)
    functionName = functionName or "traits.lua"
    return coroutine.wrap(
    function()
        for __,val in pairs(table) do
            if type(val) == "string" and allowedTraits[val] then
                coroutine.yield(val)
            elseif type(val) == "table" then
                for ___,traitString in pairs(val) do
                    if type(traitString) == "string" and allowedTraits[traitString] then
                        coroutine.yield(traitString)
                    elseif type(traitString) == "string" then
                        error(functionName..": \""..traitString.."\" is not a valid trait.  If it is not a typo, add"
                        .." it to the list of valid traits using\ntraits.allowedTraits(\""..traitString.."\")")
                    else
                        error(functionName..": strings are the only acceptable 'traits', but you can provide them as tables of strings.\n\""
                        ..tostring(val).."\" is a "..type(val).." within a table.")
                    end
                end
            elseif type(val)=="string" then
                error(functionName..": \""..val.."\" is not a valid trait.  If it is not a typo, add"
                .." it to the list of valid traits using\ntraits.allowedTraits(\""..val.."\")")
            else
                error(functionName..": strings acceptable 'traits', but you can provide them as tables of strings, if you prefer.\n\""
                ..tostring(val).."\" is a "..type(val)..".")
            end
        end
    end)
end

-- returns an error if any of the supplied traits have
-- not been registered
function traits.validateTraits(...)
    allowedTraitsRun("traits.validTraits")
    local list = {...}
    for trait in iterateTraitStrings(list,"traits.validateTraits") do

    end
end


-- an arbitrary number of traits can be assigned
-- at once, i.e.
-- traits(object,trait1)
-- traits(object,trait1,trait2,trait3)
--      each trait can be either a string
--      or a table of strings
function traits.assign(object,...)
    allowedTraitsRun("traits.assign")
    if type(object) == "table" then
        for _,val in pairs(object) do
            traits.assign(val,...)
        end
        return
    end
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local arglist = {...}
    for traitString in iterateTraitStrings(arglist,"traits.assign") do
        if traitTable[objectID][traitString] ~= nil then
            warning("Warning: "..tostring(object).." has already been assigned the trait \""..traitString.."\".")
        end
        traitTable[objectID][traitString]=true
    end
end

-- unassigns an arbitrary number of traits
-- at once.  This might be useful if a bunch
-- of items all need the same traits, except one
-- or two don't need them all
function traits.unassign(object,...)
    allowedTraitsRun("traits.unassign")
    if type(object) == "table" then
        for _,val in pairs(object) do
            traits.unassign(val,...)
        end
        return
    end
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local arglist = {...}
    for traitString in iterateTraitStrings(arglist,"traits.unassign") do
        traitTable[objectID][traitString]=nil
    end
end

-- It is conceivable that you don't want an object to always
-- have a trait.  This function stores a function()-->boolean
-- in the traitTable, and the function will be used to determine
-- if the object currently has the trait

function traits.conditionalTrait(object,traitString,func)
    allowedTraitsRun("traits.conditionalTrait")
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    if type(traitString)~="string" then
        error("traits.conditionalTrait: Only strings can be assigned as traits.\n"
        ..tostring(traitString).." is a "..type(traitString)..".")
    end
    if type(func) ~="function" then
        error("traits.conditionalTrait: the third argument should be a function()-->bool.\n"
            .."However, "..tostring(func).." is a "..type(func)..".")
    end
    traitTable[objectID][traitString] = func
end


-- checks if the object has the trait associated
-- with traitString (at the current time)
function traits.hasTrait(object,traitString)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    if not allowedTraits[traitString] then
        error("traits.hasTrait: \""..tostring(traitString).."\" is not a valid trait.  If it is a string"
        .." you can use traits.allowedTraits(\""..tostring(traitString).."\") to add it to the allowed traits.")
    end
    local traitVal = traitTable[objectID][traitString]
    -- if traitVal is nil or false, immediately return false
    -- if truthy, it must either be true or a function.
    -- if true, return traitVal == true, otherwise return 
    -- traitVal()
    -- Only reason to do this is to avoid if statements
    return (traitVal and (traitVal == true or traitVal())) or false
end



-- returns a table of all the traits the object has
-- (in no particular order), as a table indexed by integers
-- for conditional traits, returns the current value of them
function traits.traitList(object)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local tList = {}
    local tListIndex=1
    for traitString,traitVal in pairs(objectTraits) do
        -- see trait.hasTrait for why the below if statement checks for truth
        if traitVal and (traitVal == true or traitVal()) then
            tList[tListIndex] = traitString
            tListIndex=tListIndex+1
        end
    end
    return tList
end

-- returns a table of the object's current traits,
-- (i.e. after resolving conditional traits) in
-- the form table[traitString]= true
-- for traits that exist
function traits.traitTable(object)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local tTable = {}
    for traitString,traitVal in pairs(objectTraits) do
        -- see trait.hasTrait for why the below if statement checks for truth
        if traitVal and (traitVal == true or traitVal()) then
            tTable[traitString]=true
        end
    end
    return tTable
end



-- returns true if the object has all the listed traits
-- and false otherwise

function traits.hasAllTraits(object,...)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local arglist = {...}
    for traitString in iterateTraitStrings(arglist,"traits.hasAllTraits") do
        local tVal = objectTraits[traitString]
        if not (tVal and (tVal == true or tVal())) then
            return false
        end
    end
    return true
end

-- returns true if the object has any of the listed traits
-- (at the current time) and false otherwise

function traits.hasAnyTrait(object,...)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local arglist = {...}
    for traitString in iterateTraitStrings(arglist,"traits.hasAnyTrait") do
        local tVal = objectTraits[traitString]
        if tVal and (tVal == true or tVal()) then
            return true
        end
    end
    return false
end

        
-- returns a list of traits (table indexed by integers)
-- that is posessed by the object and is also in the
-- argument list
-- Second return value gives the number of traits
-- in common

function traits.listPossessedTraits(object,...)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local arglist = {...}
    local outputTable = {}
    local outputCount = 0
    for traitString in iterateTraitStrings(arglist,"traits.listAllTraits") do
        local tVal = objectTraits[traitString]
        if (tVal and (tVal == true or tVal())) then
            outputCount=outputCount+1
            outputTable[outputCount]=traitString
        end
    end
    return outputTable,outputCount
end
traits.listPosessedTraits = traits.listPossessedTraits

-- returns a table


-- returns a table of the combined traits of all
-- technologies owned by the tribe
-- (after resolving conditional traits) in
-- the form table[traitString]= true
-- for the traits that exist
function traits.ownedTechTraitsTable(tribe)
    if not civ.isTribe(tribe) then
        error("traits.ownedTechTraitsTable: argument must be a tribeObject")
    end
    local outputTable = {}
    for techID,traitTable in pairs(techTraits) do
        if tribe:hasTech(civ.getTech(techID)) then
            for trait,boolOrFn in pairs(traitTable) do
                if (type(boolOrFn) == "function" and boolOrFn()) or boolOrFn == true then
                    outputTable[trait] = true
                end
            end
        end
    end
    return outputTable
end

-- returns a table of the combined traits of all
-- wonders owned by the tribe
-- (after resolving conditional traits) in the
-- form table[traitString]=true
-- for the traits that are possessed.

function traits.ownedWonderTraitsTable(tribe)
    if not civ.isTribe(tribe) then
        error("traits.ownedWonderTraitsTable: argument must be a tribeObject")
    end
    local outputTable = {}
    for wonderID, traitTable in pairs(wonderTraits) do
        local wdr = civ.getWonder(wonderID)
        if wdr.city and wdr.city.owner == tribe then
            for trait,boolOrFn in pairs(traitTable) do
                if (type(boolOrFn) == "function" and boolOrFn()) or boolOrFn == true then
                    outputTable[trait] = true
                end
            end
        end
    end
    return outputTable
end

-- returns a table of the combined traits of all
-- improvements constructed within the city
-- (after resolving conditional traits) in
-- the form of table[traitString]=true
-- for the traits that are found
-- if ignoreWonderEquivalent is true, city improvements from owned
-- wonders are excluded

local improvementEquivalentWonders = {
    [gen.original.wPyramids]= gen.original.iGranary               ,
    [gen.original.wGreatWall]= gen.original.iCityWalls              ,
    [gen.original.wMichelangelosChapel]=gen.original.iCathedral     ,
    [gen.original.wWomensSuffrage]= gen.original.iPoliceStation         ,
    [gen.original.wHooverDam]= gen.original.iHydroPlant              ,
    [gen.original.wSETIProgram]= gen.original.iResearchLab            ,
}
    

function traits.cityImprovementTraitsTable(city,ignoreWonderEquivalent)
    if not civ.isCity(city) then
        error("traits.cityImprovementTraitsTable: argument must be a cityObject")
    end
    local outputTable = {}
    for improvementId, traitTable in pairs(improvementTraits) do
        if city:hasImprovement(civ.getImprovement(improvementId)) then
            for trait,boolOrFn in pairs(traitTable) do
                if (type(boolOrFn) == "function" and boolOrFn()) or boolOrFn == true then
                    outputTable[trait] = true
                end
            end
        end
    end
    if not ignoreWonderEquivalent then
        for wonder,improvement in pairs(improvementEquivalentWonders) do
            if gen.isWonderActiveForTribe(wonder,city.owner) then
                for trait, boolOrFn in pairs(improvementTraits[improvement.id]) do
                    if (type(boolOrFn) == "function" and boolOrFn()) or boolOrFn == true then
                        outputTable[trait] = true
                    end
                end
            end
        end
    end
    return outputTable
end

-- returns a table of the combined traits of all
-- wonders within the city
-- (after resolving conditional traits) in
-- the form of table[traitString]=true
-- for the traits that are found
function traits.cityWonderTraitsTable(city)
    if not civ.isCity(city) then
        error("traits.cityImprovementTraitsTable: argument must be a cityObject")
    end
    local outputTable = {}
    for wonderId, traitTable in pairs(wonderTraits) do
        local wdr = civ.getWonder(wonderId)
        if wdr.city == city  then
            for trait,boolOrFn in pairs(traitTable) do
                if (type(boolOrFn) == "function" and boolOrFn()) or boolOrFn == true then
                    outputTable[trait] = true
                end
            end
        end
    end
    return outputTable
end





-- Considers the list of traits
--  if the tribe has any trait, or
--  any technology the tribe owns has a trait,
--  or any wonder the tribe owns has a trait,
--  return true
--  return false if none are associated

function traits.anyAssociatedWithTribe(tribeObject,...)
    if not civ.isTribe(tribeObject) then
        error("traits.anyAssociatedWithTribe: first argument must be a tribe object.  Received: "..tostring(tribeObject))
    end
    local arglist = {...}
    local techTraits = traits.ownedTechTraitsTable(tribeObject)
    local wonderTraits = traits.ownedWonderTraitsTable(tribeObject)
    for submittedTrait in iterateTraitStrings(arglist,"traits.anyAssociatedWithTribe") do
        if traits.hasTrait(tribeObject,submittedTrait) or techTraits[submittedTrait] or wonderTraits[submittedTrait] then
            return true
        end
    end
    return false
end

-- considers the list of traits,
-- if the tile's terrain or baseTerrain has any trait in the list,
-- or any improvement or wonder in the city on that tile has any trait in the list
-- (if there is a city)
-- return true
-- return false if none of the traits are associated

function traits.anyAssociatedWithTile(tile,...)
    if not civ.isTile(tile) then
        error("traits.anyAssociatedWithTile: first argument must be a tile object.  Received: "..tostring(tile))
    end
    local arglist = {...}
    local cityImprovementTraits = (tile.city and traits.cityImprovementTraitsTable(tile.city)) or {}
    local tileTerrain = tile.terrain
    local tileBaseTerrain = tile.baseTerrain
    for submittedTrait in iterateTraitStrings(arglist,"traits.anyAssociatedWithTile") do
        if traits.hasTrait(tileTerrain,submittedTrait) or traits.hasTrait(tileBaseTerrain,submittedTrait) or cityImprovementTraits[submittedTrait] then
            return true
        end
    end
    return false
end

--  returns a table of the object's traits
--  which are permanent (i.e. they are always
--  true, not just true sometimes) in the form
--  table[traitString] = true
function traits.permanentTraitTable(object)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local tTable = {}
    for traitString,traitVal in pairs(objectTraits) do
        -- see trait.hasTrait for why the below if statement checks for truth
        if traitVal and traitVal == true  then
            tTable[traitString]=true
        end
    end
    return tTable
end

-- returns a table of the object's traits
-- which are conditional (i.e. they are only true
-- sometimes, set by traits.conditionalTrait)
-- in the form
-- table[traitString] = conditionFn
function traits.conditionalTraitTable(object)
    local traitTable = selectTraitTable(object)
    local objectID = getTraitID(object)
    local objectTraits = traitTable[objectID]
    local tTable = {}
    for traitString,traitVal in pairs(objectTraits) do
        if traitVal and type(traitVal) == "function"  then
            tTable[traitString]=traitVal
        end
    end
    return tTable

end



-- builds functions to associate strings with item types,
--  checkAssociation(item,string) --> bool
--      returns true if the string is associated with the item, or any of the item's traits
--      false otherwise
--
--  addAssociation(itemOrTrait,string)
--      associates the string with either an item, or a trait
--      if itemOrTrait is true, associate with all items
function traits.makeItemTraitQuickStringAssociation(isItemTypeFn,getItemID,itemTypeName,getItemIterator)
    local storageTable = {}
    local conditionalMemoTable = {}
    local scenarioLoadedNotRun = true
    local function checkAssociation(item,str) --> table
        if not isItemTypeFn(item) then
            error("checkAssociation: arg#1 expected "..itemTypeName.." received: "..tostring(item))
        end
        if type(str) ~= "string" then
            error("checkAssociation: arg#2 must be a string.  Received: "..tostring(str))
        end
        local itemID = getItemID(item)
        if storageTable[itemID] and storageTable[itemID][str] then
            return true
        end
        if scenarioLoadedNotRun or not conditionalMemoTable[itemID] then
            conditionalMemoTable[itemID] = traits.conditionalTraitTable(item)
        end
        for trait,traitFn in pairs(conditionalMemoTable[itemID]) do
            if storageTable[trait] and traitFn() and storageTable[trait][str] then
                return true
            end
        end
        -- at scenarioLoaded, permanent traits info is copied into the itemID section
        if scenarioLoadedNotRun then
            if storageTable[true] and storageTable[true][str] then
                return true
            end
            for trait,_ in pairs(traits.permanentTraitTable(item)) do
                if storageTable[trait] and storageTable[trait][str] then
                    return true
                end
            end
        end
        return false
    end

    local function addAssociation(itemOrTrait,str)
        if not isItemTypeFn(itemOrTrait) and type(itemOrTrait) ~= "string" and itemOrTrait ~= true then
            error("addAssociation: arg#1 must be a string, true, or "..itemTypeName..".  Received: "..tostring(itemOrTrait))
        end
        if type(str) ~= "string" then
            error("addAssociation: arg#2 must be a string.  Received: "..tostring(itemOrTrait))
        end
        if isItemTypeFn(itemOrTrait) then
            itemOrTrait = getItemID(itemOrTrait)
        end
        if itemOrTrait == nil then
            itemOrTrait = true
        end
        storageTable[itemOrTrait] = storageTable[itemOrTrait] or {}
        storageTable[itemOrTrait][str] = true
    end
    if getItemIterator then
        function discreteEvents.onScenarioLoaded()
            for item in getItemIterator() do
                local itemID = getItemID(item)
                storageTable[itemID] = storageTable[itemID] or {}
                local permTraits = traits.permanentTraitTable(item)
                for str,__ in pairs(storageTable[true] or {}) do
                    storageTable[itemID][str] = true
                end
                for trait,_ in pairs(permTraits) do
                    for str,__ in pairs(storageTable[trait] or {}) do
                        storageTable[itemID][str] = true
                    end
                end
            end
            scenarioLoadedNotRun = false
        end
    end
    return checkAssociation, addAssociation
end


-- builds functions to associate values with item types
--  getAssociatedList(item) -> {[value]=true}
--      returns a table of values as keys that have been associated with the item
--          or any of its traits
--
--  addAssociation(itemOrTrait,value)
--      associates a value with an item or trait

function traits.makeItemTraitListAssociation(isItemTypeFn, getItemID, itemTypeName, getItemIterator)
    local storageTable = {}
    local conditionalMemoTable = {}
    local scenarioLoadedNotRun = true
    local function getAssociatedList(item)
        if not isItemTypeFn(item) then
            error("getAssociatedList: arg#1 expected "..itemTypeName.." received: "..tostring(item))
        end
        local itemID = getItemID(item)
        local list = {}
        for value,_ in pairs(storageTable[itemID] or {}) do
            list[value] = true
        end
        if scenarioLoadedNotRun or not conditionalMemoTable[itemID] then
            conditionalMemoTable[itemID] = traits.conditionalTraitTable(item)
        end
        for trait,traitFn in pairs(conditionalMemoTable[itemID]) do
            if storageTable[trait] and traitFn() then
                for value,_ in pairs(storageTable[trait]) do
                    list[value] = true
                end
            end
        end
        if scenarioLoadedNotRun then
            for trait,_ in pairs(traits.permanentTraitTable(item)) do
                if storageTable[trait]  then
                    for value,__ in pairs(storageTable[trait]) do
                        list[value] = true
                    end
                end
            end
        end
        return list
    end
    local function addAssociation(itemOrTrait,value)
        if not isItemTypeFn(itemOrTrait) and type(itemOrTrait) ~= "string" then
            error("addAssociation: arg#1 must be a string or "..itemTypeName..".  Received: "..tostring(itemOrTrait))
        end
        if isItemTypeFn(itemOrTrait) then
            itemOrTrait = getItemID(itemOrTrait)
        end
        storageTable[itemOrTrait] = storageTable[itemOrTrait] or {}
        storageTable[itemOrTrait][value] = true
    end
    if getItemIterator then
        function discreteEvents.onScenarioLoaded()
            for item in getItemIterator() do
                local itemID = getItemID(item)
                local permTraits = traits.permanentTraitTable(item)
                storageTable[itemID] = storageTable[itemID] or {}
                for trait,_ in pairs(permTraits) do
                    for val,__ in pairs(storageTable[trait] or {}) do
                        storageTable[itemID][val] = true
                    end
                end
            end
            scenarioLoadedNotRun = false
        end
    end
    return getAssociatedList,addAssociation
end


-- builds functions to associate values with item types
--  getComputation(item) -> result
--      
--      take a table of values as would be generated by makeItemTraitListAssociation
--      valTable = {[value]=true}
--      returns the final result of valueSoFar for the computation
--      valueSoFar = nil
--      for value,_ in pairs(valTable) do
--          valueSoFar = computeFunction(value,valueSoFar)
--      end
--      (the computeFunction should be a computation that returns the same value regardless
--      of the order of computation)
--      computeFunction(nil,nil) should return the initial valueSoFar, which is also the value
--      to return if no association is provided
--
--
--  addComputationValue(itemOrTrait,value)
--      associates a value with an item or trait
--

function traits.makeItemTraitComputation(isItemTypeFn, getItemID, itemTypeName, getItemIterator,computeFunction)
    local storageTable = {}
    local conditionalMemoTable = {}
    local fixedComputedTable = {}
    local scenarioLoadedNotRun = true
    local function getComputation(item)
        if not isItemTypeFn(item) then
            error("getComputation: arg#1 expected "..itemTypeName.." received: "..tostring(item))
        end
        local itemID = getItemID(item)
        local fixedComponentComputation = fixedComputedTable[itemID]
        if fixedComponentComputation == nil then
            local list = {}
            for value,_ in pairs(storageTable[itemID] or {}) do
                list[value] = true
            end
            if scenarioLoadedNotRun then
                for trait,_ in pairs(traits.permanentTraitTable(item)) do
                    if storageTable[trait]  then
                        for value,_ in pairs(storageTable[trait]) do
                            list[value] = true
                        end
                    end
                end
            end
            fixedComponentComputation = computeFunction(nil,nil)
            for v,_ in pairs(list) do
                fixedComponentComputation = computeFunction(v,fixedComponentComputation)
            end
        end
        if scenarioLoadedNotRun or not conditionalMemoTable[itemID] then
            conditionalMemoTable[itemID] = traits.conditionalTraitTable(item)
        end
        local conditionalValues = {}
        for trait,traitFn in pairs(conditionalMemoTable[itemID]) do
            if storageTable[trait] and traitFn() then
                for _,value in pairs(storageTable[trait]) do
                    conditionalValues[value] = true
                end
            end
        end
        local computedValue = fixedComponentComputation
        for v,_ in pairs(conditionalValues) do
            computedValue = computeFunction(v,computedValue)
        end
        return computedValue
    end
    local function addAssociation(itemOrTrait,value)
        if not isItemTypeFn(itemOrTrait) and type(itemOrTrait) ~= "string" then
            error("addAssociation: arg#1 must be a string or "..itemTypeName..".  Received: "..tostring(itemOrTrait))
        end
        if isItemTypeFn(itemOrTrait) then
            itemOrTrait = getItemID(itemOrTrait)
        end
        storageTable[itemOrTrait] = storageTable[itemOrTrait] or {}
        storageTable[itemOrTrait][value] = true
    end
    if getItemIterator then
        function discreteEvents.onScenarioLoaded()
            for item in getItemIterator() do
                local itemID = getItemID(item)
                local permTraits = traits.permanentTraitTable(item)
                storageTable[itemID] = storageTable[itemID] or {}
                for trait,_ in pairs(permTraits) do
                    for val,__ in pairs(storageTable[trait] or {}) do
                        storageTable[itemID][val] = true
                    end
                end
                local fixedComponent = nil
                fixedComponent = computeFunction(nil,nil)
                for val,_ in pairs(storageTable[itemID]) do
                    fixedComponent = computeFunction(val,fixedComponent)
                end
            end
            scenarioLoadedNotRun = false
        end
    end
    return getComputation, addAssociation
end



--[[
-- traits.canHaveTrait(object,traitString)-->boolean
-- traits.canHaveTrait(isObjectTypeFnKey,traitString) --> boolean
--  object is any kind of object that can have a trait
--  isObjectTypeFnKey is one of the following strings
--      "isTerrain" "isBaseTerrain", "isImprovement", "isTribe",
--      "isTech", "isWonder", "isUnitType",
--  returns true if the object/class of objects can have a trait
--  (even if only sometimes)
--  returns false if it can never have the trait
function traits.canHaveTrait(objectOrIsKindFnKey,traitString)
    if type(objectOrIsKindFnKey) == "string" then
        local traitsTable = nil
        if "isUnitType" == objectOrIsKindFnKey then
            traitsTable =  unitTypeTraits
        elseif "isImprovement" == objectOrIsKindFnKey then
            traitsTable =  improvementTraits
        elseif "isWonder" == objectOrIsKindFnKey then
            traitsTable =  wonderTraits
        elseif "isTech" == objectOrIsKindFnKey then
            traitsTable =  techTraits
        elseif "isBaseTerrain" == objectOrIsKindFnKey then
            traitsTable =  baseTerrainTraits
        elseif "isTerrain" == objectOrIsKindFnKey then
            traitsTable =  terrainTraits
        elseif "isTribe" == objectOrIsKindFnKey then
            traitsTable =  tribeTraits
        end


    else

    end
end
--]]

return traits
