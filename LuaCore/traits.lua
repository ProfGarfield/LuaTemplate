local versionNumber = 1
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

-- specify all the allowed traits,
-- arguments can be either strings or 
-- tables of strings
function traits.allowedTraits(...)
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
-- an arbitrary number of traits can be assigned
-- at once, i.e.
-- traits(object,trait1)
-- traits(object,trait1,trait2,trait3)
--      each trait can be either a string
--      or a table of strings
function traits.assign(object,...)
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

function traits.listPosessedTraits(object,...)
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
            if gen.applyWonderBonus(wonder,city.owner) then
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
        local wdr = civ.getWonder(wonderID)
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

--function traits.anyAssociatedWithTribe(tribeObject,...)
--    if not civ.isTribe(tribeObject) then
--        error("traits.anyAssociatedWithTribe: first argument must be a tribe object.")
--    end
--    local arglist = {...}
--    local newArgs = {}
--    local index = 1
--    for submittedTrait in iterateTraitStrings(arglist,"traits.anyAssociatedWithTribe") do
--        newArgs[index] = submittedTrait
--        index = index+1
--    end
--    
--
--end


return traits
