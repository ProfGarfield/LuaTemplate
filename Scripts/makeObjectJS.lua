local object = require("object")
---@module "data"
local data = require("data"):minVersion(2)
local gen = require("generalLibrary")

-- Check if we're working with the default object.lua file
-- this function allows for the use of pcall to check
-- if "%SAMPLEFILE%" is a key in object, 
-- since that normally creates an error if it is missing
local function checkObject(key)
    return object[key]
end
if pcall(checkObject,"%SAMPLEFILE%") then
    local dialog = civ.ui.createDialog()
    dialog.title = "makeObjectJS.lua"
    dialog:addText("The object table currently registered appears to be the default object.lua file that ships with the Lua Scenario Template.  This is probably not what you want.  If you have already generated an XXXXXXXXXXobject.lua file using the makeObject.lua script, double check that that file has been renamed as object.lua, and re-load the game before running this script again.")
    dialog:addOption("Thanks for catching that, I'll make the change and reload the game.",1)
    dialog:addOption("I'm doing this on purpose, generate object.js now.",2)
    local choice = dialog:show()
    if choice == 1 then
        return
    end
end

local function findKeyOf(item,table,typeCheckFn)
    for key,value in pairs(table) do
        if typeCheckFn(value) and value == item then
            return key
        end
    end
    return false
end

local function makeLine(id,getTypeFn,typeCheckFn,table)
    local item = getTypeFn(id)
    if not item then
        return ""
    end
    local key = findKeyOf(item,object,typeCheckFn)
    if not key then
        return ""
    end
    local line = "\t{name:\""..item.name.."\", id:"..tostring(id)..",code:\"object."..key.."\"},\n"
    return line
end

local function buildCityLocationLine(city,table)
    local locationKey = findKeyOf(city.location,object,civ.isTile)
    if not locationKey then
        return ""
    end
    local line = "\t{name:\""..city.name.."\", id:"..tostring(city.id)..", tribeId:"..tostring(city.owner.id)
        ..", code:\"object."..locationKey.."\", xyz:["..tostring(city.location.x)..","..tostring(city.location.y)
        ..","..tostring(city.location.z).."]},\n"
    return line
end
    

--local fileLocation = civ.getToTDir().."\\"..tostring(os.time()).."object.js"
local fileLocation = gen.getScenarioDirectory().."\\Scripts".."\\"..tostring(os.time()).."object.js"

local file = io.open(fileLocation,"a")
io.output(file)

local fileOutput = 
[=[ 
// This file is to support autoCanBuild.html, and possibly others.
// It provides a means of accessing relevant scenario information in order
// to build code.

// Unit Types
const unitList = [
]=]
for i = 0,civ.cosmic.numberOfUnitTypes-1 do
    fileOutput = fileOutput..makeLine(i,civ.getUnitType,civ.isUnitType,object)
end
fileOutput = fileOutput..
[=[]

// Tribes/Players
const tribeList = [
]=]
for i=0,7 do
    fileOutput = fileOutput..makeLine(i,civ.getTribe,civ.isTribe,object)
end

fileOutput = fileOutput..
[=[]

// Improvements
const improvementList = [
]=]
for i=0,39 do
    fileOutput = fileOutput..makeLine(i,civ.getImprovement,civ.isImprovement,object)
end
fileOutput = fileOutput..
[=[]

// Wonders
const wonderList = [
]=]
for i=0,27 do
    fileOutput = fileOutput..makeLine(i,civ.getWonder,civ.isWonder,object)
end

fileOutput = fileOutput..
[=[]

// Advances
const advancesList = [
]=]
for i=0,255 do
    -- max techs is 253, so this is a bit more than necessary
    if civ.getTech(i) then
        fileOutput = fileOutput..makeLine(i,civ.getTech,civ.isTech,object)
    end
end
fileOutput = fileOutput..
[=[]

// Cities
const cityLocationList = [
]=]
for city in civ.iterateCities() do
    fileOutput = fileOutput..buildCityLocationLine(city,object)
end
fileOutput = fileOutput..
[=[]
]=]

fileOutput = fileOutput..
[=[
// Flags
// (flags with the moduleName field specified won't appear here, but those don't work with
// canBuildSettings.lua anyway)
const flagsList = [
]=]
    for index,flag in pairs(data.listOfFlagKeys()) do
        fileOutput = fileOutput.."\t{name:'Flag: \""..flag.."\"', id:"..tostring(index)..", code:\""..flag.."\"},\n"
    end
    fileOutput = fileOutput..
[=[]
]=]

fileOutput = fileOutput..
[=[
// Counter Keys
const countersList = [
]=]
for index,counter in pairs(data.listOfCounterKeys()) do
    fileOutput = fileOutput.."\t{name:'Counter: \""..counter.."\"', id:"..tostring(index)..", code:\""..counter.."\"},\n"
end
fileOutput = fileOutput..
[=[]
]=]


fileOutput = fileOutput..
[=[


const fullList = {}
const fullArray = [...unitList,...tribeList,...improvementList,...wonderList,...cityLocationList,...advancesList,...flagsList,...countersList]

fullArray.map( value => {
            fullList[value.code] = value;
    });


const testObject = false;

]=]
io.write(fileOutput)
io.close(file)
print("object.js file written to "..fileLocation)
civ.ui.text("object.js file written to "..fileLocation)








    
