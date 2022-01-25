local object = require("object")
local base = require("scripts\\baseCivAPI")
local gen = require("generalLibrary")
local civlua = require("civlua")

local api = gen.copyTable(base)

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
        entry.description = tostring(value).." owner: "..city.owner.name
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
    api.object.childs[key] = entry
end


local fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."totpp-api.lua"

local file = io.open(fileLocation,"a")
io.output(file)
io.write(civlua.serialize(api))
io.close(file)
print("ZeroBrane API written to "..fileLocation)

    
