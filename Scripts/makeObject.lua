local equalsColumn = 32 -- the = will be in this column, unless the table and key push it further out

local width,height,n_maps = civ.getAtlasDimensions()

local text = require("text"):minVersion(2)



local row = nil -- I forgot to define row in each loop, and it was easier to add it here
local function paddRow(row)
    while string.len(row)< equalsColumn do
        row = row.." "
    end
    return row
end

-- keeps track of all the keys added to
-- the table, so duplicate names don't
-- cause problems
local usedKeys = {}

local function scrubKey(key,prefix)
    key = text.anglicise(key)
    key = prefix..string.gsub(key,"[^%a%d]","")
    while usedKeys[key] do
        key = key.."_"
    end
    usedKeys[key]=true
    return key
end

--local fileLocation = civ.getToTDir().."\\"..tostring(os.time()).."object.lua"
local gen = require("generalLibrary")
local fileLocation = gen.getScenarioDirectory().."\\LuaParameterFiles".."\\"..tostring(os.time()).."object.lua"

local file = io.open(fileLocation,"a")
io.output(file)


local fileOutput = 
[[local flag = require("flag")
local counter = require("counter")
local text = require("text")
local gen = require("generalLibrary")

local object = gen.makeDataTable({},"object")
-- This line forbids reassignment of keys of the object table
-- This should prevent errors
gen.forbidReplacement(object)

-- Civilization Advances
-- recommended key prefix 'a'

]]

-- For a comment beside a line for advances,
-- add an entry to this table for that id number
-- comment lines are inserted automatically
-- must be a string to appear 
local advancesNotes = {}
advancesNotes[5] = "Automobile"
advancesNotes[7] = "Bridge Building"

local currentOutput = ""
for i=0,255 do
    -- max techs is 253, so 255 is a bit more than necessary
    -- but no harm
    if civ.getTech(i) then
    local adv = civ.getTech(i)
        row = "object."..scrubKey(adv.name,"a")
        row = paddRow(row)
        row = row.."= civ.getTech("..tostring(i)..")"
        if type(advancesNotes[i])=="string" then
            row = row.."   --"..advancesNotes[i]
        end
        currentOutput = currentOutput..row.."\n"
    end
end


fileOutput = fileOutput..currentOutput
io.write(fileOutput)
fileOutput =
[[

-- Map Locations (tiles/squares)
-- recommended key prefix 'l'

]]

currentOutput = ""
local locationOutput = ""
local cityOutput = ""
local cityRow = nil
for player = 0,7 do
    locationOutput = locationOutput.."\n-- Locations of cities starting the scenario owned by the "..civ.getTribe(player).name..":\n\n"
    cityOutput = cityOutput.."\n--Cities starting the scenario owned by the "..civ.getTribe(player).name..":\n\n"
    for city in civ.iterateCities() do
        if city.owner.id == player then
            local cL = city.location
            row = "object."..scrubKey(city.name,"l")
            row = paddRow(row)
            row = row.."=civ.getTile("..tostring(cL.x)..","..tostring(cL.y)..","..tostring(cL.z)..")"
            locationOutput=locationOutput..row.."\n"
            cityRow = "object."..scrubKey(city.name,"c")
            cityRow = paddRow(cityRow)
            cityRow = cityRow.."=civ.getTile("..tostring(cL.x)..","..tostring(cL.y)..","..tostring(cL.z)..").city"
            cityOutput = cityOutput..cityRow.."\n"
        end
    end
end

fileOutput = fileOutput..locationOutput
io.write(fileOutput)
fileOutput =
[[

-- Cities
-- recommended key prefix 'c'
-- It is not recommended to put cities into this list if the city
-- can be destroyed. This list returns an error if 'nil' is the value
-- associated with the key (see bottom of file), so that could cause
-- a problem if a city in this list is destroyed.  Also, if another
-- city is founded, the ID number of the city might get reused, causing
-- more confusion.  An alternate way to reference a city is by using
-- object.lRome.city when you actually need the city (and suitably guarding
-- against nil values)

--Find these by entering "for city in civ.iterateCities() do print(city.id, city.name) end" in the console

-- All the cities existing when you made generated this template are listed here.
-- If you wish to use these objects, change the line if false then below to if true then
-- It is your job to eliminate any cities that could be destroyed from this list if you use it
-- If you are not sure, it is recommended to reference cities from their locations instead
--

if false then
]]

fileOutput = fileOutput..cityOutput.."\nend\n"
io.write(fileOutput)
fileOutput =


[[

-- Unit Types
-- recommended key prefix 'u'

]]
currentOutput = ""

local unitTypesNotes = {}
unitTypesNotes[1] = "Engineers"
unitTypesNotes[45] = "Nuclear Msl"
unitTypesNotes[47] = "Spy"
unitTypesNotes[49] = "Freight"
for i=0,civ.cosmic.numberOfUnitTypes-1 do
    local unitType = civ.getUnitType(i)
    row = "object."..scrubKey(unitType.name,"u")
    row = paddRow(row)
    row = row.."= civ.getUnitType("..tostring(i)..")"
    if type(unitTypesNotes[i]) =="string" then
        row = row.."   --"..unitTypesNotes[i]
    end
    currentOutput = currentOutput..row.."\n"
end


fileOutput = fileOutput..currentOutput
io.write(fileOutput)
fileOutput = 
[[

-- City Improvements
-- recommended key prefix 'i'
--          

]]
currentOutput = ""

local improvementNotes = {}

for i=0,35 do
    local imp = civ.getImprovement(i)
    row = "object."..scrubKey(imp.name,"i")
    row = paddRow(row)
    row = row.."= civ.getImprovement("..tostring(i)..")"
    if type(improvementNotes[i]) == "string" then
        row = row.."   --"..improvementNotes[i]
    end
    currentOutput = currentOutput..row.."\n"
end

fileOutput = fileOutput..currentOutput
io.write(fileOutput)
fileOutput = 
[[

-- Players (Tribes)
-- recommended key prefix 'p'

]]

currentOutput = ""

local tribeNotes = {}
for i=0,7 do
    local trb = civ.getTribe(i)
    row = "object."..scrubKey(trb.name,"p")
    row = paddRow(row)
    row = row.."= civ.getTribe("..tostring(i)..")"
    if type(tribeNotes[i]) == "string" then
        row = row.."   --"..tribeNotes[i]
    end
    currentOutput = currentOutput..row.."\n"
end

fileOutput = fileOutput..currentOutput
io.write(fileOutput)
fileOutput=
[[

-- Wonders
-- recommended key prefix 'w'

]]

currentOutput = ""
local wonderNotes = {}

for i=0,27 do
    local wdr = civ.getWonder(i)
    row = "object."..scrubKey(wdr.name,"w")
    row = paddRow(row)
    row = row.."= civ.getWonder("..tostring(i)..")"
    if type(wonderNotes[i]) == "string" then
        row = row.."   --"..wonderNotes[i]
    end
    currentOutput = currentOutput..row.."\n"
end
fileOutput = fileOutput..currentOutput
io.write(fileOutput)


fileOutput=
[[

-- Base Terrain
-- recommended prefix 'b'

]]

currentOutput = ""


for map = 0,n_maps-1 do
    for terrainIndex = 0,15  do
        local exists, bTer = pcall(civ.getBaseTerrain,map,terrainIndex)
        if exists and bTer then
            row = "object."..scrubKey(bTer.name,"b")
            row = paddRow(row)
            row = row.."=civ.getBaseTerrain("..tostring(map)..","..tostring(terrainIndex)..")  --"..bTer.abbrev
            currentOutput = currentOutput..row.."\n"
        end
    end
end
fileOutput = fileOutput..currentOutput
io.write(fileOutput)

fileOutput=
[[

-- Terrain
-- recommended prefix 't'

]]

currentOutput = ""


for map = 0,n_maps-1 do
    for terrainIndex = 0,15 do
        for resource = 0,2 do
            local exists, ter = pcall(civ.getTerrain,map,terrainIndex,resource)
            if exists and ter then
                row = "object."..scrubKey(ter.name,"t")
                row = paddRow(row)
                row = row.."=civ.getTerrain("..tostring(map)..","..tostring(terrainIndex)..","..tostring(resource)..")"
                if resource == 1 then
                    row = row.." -- Fish Resource"
                elseif resource == 2 then
                    row = row.." -- Whale Resource"
                end
                currentOutput = currentOutput..row.."\n"
            end
        end
    end
end
fileOutput = fileOutput..currentOutput
io.write(fileOutput)



fileOutput =
[[

-- Text
-- You might find it easier to keep much of your events text here
-- Remember, you can place %STRING1, %STRING2, etc. in your text and
-- use text.substitute to insert the actual values in the event, instead
-- of splitting the text into multiple parts
-- recommended prefix 'x'


-- Images
-- For optimal integration with the image functionality of the
-- text module, it is recommended that you load all your
-- images here.
-- recommended prefix `m`
--
text.setImageTable(object,"object")-- The string "object" provides a name of the table for error messages.


-- Flag and Counter Definitions
-- Flags and counters have to be defined somewhere, and this
-- is as good a place as any






-- this will give you an if you try to access a key not entered into
-- the object table, which could be helpful for debugging, but it
-- means that no nil value can ever be returned for table object
-- If you need that ability, comment out this line
gen.forbidNilValueAccess(object)

return object
]]

io.write(fileOutput)
io.close(file)


print("Basic object file written to "..fileLocation)
civ.ui.text("Basic object file written to "..fileLocation)



