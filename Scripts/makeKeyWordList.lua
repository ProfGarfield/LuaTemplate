local base = require("scripts\\baseCivAPI")
local gen = require("generalLibrary")

local api = gen.copyTable(base)

local functionList = {}
local propertyMethodList = {}
local zeroBraneBaseList = {} -- zeroBraneStudio counts "." as always part
-- of the same word, so there is no point in trying to highlight 
-- property calls

local function parseClass(childs)
    for key,value in pairs(childs) do
        propertyMethodList[key] = true
        -- only need methods for the zeroBrane list
        if value.type == "method" then
            zeroBraneBaseList[key] = true
        end
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
            zeroBraneBaseList[mergeKeys(previousKeys,currentKey)] = true
        else
            propertyMethodList[mergeKeys(previousKeys,currentKey)] =true
            zeroBraneBaseList[mergeKeys(previousKeys,currentKey)] = true
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

local zeroBraneBaseListOutput = ""
for key,val in pairs(zeroBraneBaseList) do
    zeroBraneBaseListOutput = zeroBraneBaseListOutput..key.."\n"
end

local fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."functionList.txt"
local file = io.open(fileLocation,"a")
io.output(file)
io.write(functionListOutput)
io.close(file)
print("function list written to "..fileLocation)
fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."propertyMethodList.txt"
file = io.open(fileLocation,"a")
io.output(file)
io.write(propertyMethodListOutput)
io.close(file)
print("property method list written to "..fileLocation)
fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."zeroBraneList.txt"
file = io.open(fileLocation,"a")
io.output(file)
io.write(zeroBraneBaseListOutput)
io.close(file)
print("Zero Brane Base list written to "..fileLocation)
