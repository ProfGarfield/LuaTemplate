local object = require("object")
local base = require("scripts\\baseCivAPI")
local gen = require("generalLibrary")
local civlua = require("civlua")

local api = gen.copyTable(base)

-- get word list from regular api
-- (excluding the object list, which
-- will be done as a separate list
local functionList = {}
local propertyMethodList = {}

local function parseClass(childs)
    for key,value in pairs(childs) do
        propertyMethodList[key] = true
    end
end

local function mergeKeys(previousKeys,currentKey)
    if previousKeys == "" then
        return currentKey
    else
        return previousKeys.."."..currentKey
    end
end

local function parseLib(previousKeys, currentKey,entry)
    if entry.type == "class" then
        parseClass(entry.childs)
    elseif entry.type == "lib" then
        for key,val in pairs(entry.childs) do
            parseLib(mergeKeys(previousKeys,currentKey),key,val)
        end
    else
        if entry.type == "function" then
            functionList[mergeKeys(previousKeys,currentKey)] =true
        else
            propertyMethodList[mergeKeys(previousKeys,currentKey)] =true
        end
    end
end

for key,value in pairs(api) do
    parseLib("",key,value)
end

local functionListOutput = ""
for key,val in pairs(functionList) do
    functionListOutput = functionListOutput..key.."\n"
end

local propertyMethodListOutput = ""
for key,val in pairs(propertyMethodList) do
    propertyMethodListOutput = propertyMethodListOutput..key.."\n"
end



-- add object, and make a list for highlighting as well
local objectListOutput = ""

api.object = {type = "lib", childs = {}, description = "The object table is where we name most of the 'objects' in our scenario, such as unit type objects and improvement objects."}

for key,value in pairs(object) do
    local entry = {}
    local function standardEntry(value,valuetype)
        entry.type = "value"
        entry.description = tostring(value)
        entry.valuetype = valuetype
    end
    if civ.isTech(value) then
        standardEntry(value,"techObject")
    elseif civ.isTile(value) then
        entry.type = "value"
        entry.valueType = "tileObject"
        if value.city then
            entry.description = tostring(value).." city: "..value.city.name
        else
            entry.description = tostring(value).." city: none"
        end
    elseif civ.isCity(value) then
        entry.type = "value"
        entry.valueType = "cityObject"
        entry.description = tostring(value).." owner: "..value.owner.name
    elseif civ.isUnitType(value) then
        standardEntry(value,"unitTypeObject")
    elseif civ.isImprovement(value) then
        standardEntry(value,"improvementObject")
    elseif civ.isTribe(value) then
        standardEntry(value,"tribeObject")
    elseif civ.isWonder(value) then
        entry.type = "value"
        entry.valueType = "wonderObject"
        if value.city then
            entry.description = tostring(value).." city: "..value.city.name
        else
            entry.description = tostring(value)
        end
    elseif civ.isBaseTerrain(value) then
        standardEntry(value,"baseTerrainObject")
    elseif civ.isTerrain(value) then
        standardEntry(value,"terrainObject")
    elseif civ.isImage(value) then
        entry.type = "value"
        entry.valueType = "imageObject"
        entry.description = "An image object"
    elseif type(value) == "string" then
        entry.type = "value"
        entry.valueType = "string"
        entry.description = value
    else
        entry.type = "value"
        entry.description = "A "..type(value)
    end
    objectListOutput = objectListOutput.." object."..key
    api.object.childs[key] = entry
end


local fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."totpp-api.lua"



local super = {api=api, keyWordList = {functionListOutput, propertyMethodListOutput, objectListOutput}}

local file = io.open(fileLocation,"a")
io.output(file)
io.write(civlua.serialize(super))
io.close(file)
print("ZeroBrane API written to "..fileLocation)

    
