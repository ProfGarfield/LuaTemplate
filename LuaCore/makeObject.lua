local equalsColumn = 32 -- the = will be in this column, unless the table and key push it further out

local terrainTypesPerMap={[0]=11,[1]=11,[2]=11,[3]=11}
local width,height,n_maps = civ.getAtlasDimensions()
for i=0,n_maps-1 do
    local question = civ.ui.createDialog()
    question:addText("How many terrain types does map "..tostring(i).." have?")
    for j=16,11,-1 do
        question:addOption(tostring(j),j)
    end
    terrainTypesPerMap[i]=question:show()
end




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
    key = prefix..string.gsub(key,"[^%a%d]","")
    while usedKeys[key] do
        key = key.."_"
    end
    usedKeys[key]=true
    return key
end
local fileLocation = civ.getToTDir().."\\"..tostring(os.time()).."object.lua"

local file = io.open(fileLocation,"a")
io.output(file)

local fileOutput = 
[[local flag = require("flag")

local object = {}

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
for i=0,99 do
    local adv = civ.getTech(i)
    row = "object."..scrubKey(adv.name,"a")
    row = paddRow(row)
    row = row.."= civ.getTech("..tostring(i)..")"
    if type(advancesNotes[i])=="string" then
        row = row.."   --"..advancesNotes[i]
    end
    currentOutput = currentOutput..row.."\n"
end


fileOutput = fileOutput..currentOutput
io.write(fileOutput)
fileOutput =
[[

-- Map Locations (tiles/squares)
-- recommended key prefix 'l'



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
    for terrainIndex = 0,terrainTypesPerMap[map]-1  do
        local bTer = civ.getBaseTerrain(map,terrainIndex)
        if bTer then
            row = "object."..scrubKey(bTer.name,"b")
            row = paddRow(row)
            row = row.."=civ.getBaseTerrain("..tostring(map)..","..tostring(terrainIndex)..")  --"..bTer.abbrev
            currentOutput = currentOutput..row.."\n"
        end
    end
end
fileOutput = fileOutput..currentOutput
print(type(fileOutput))
io.write(fileOutput)


fileOutput=
[[

-- Terrain
-- recommended prefix 't'

]]

currentOutput = ""


for map = 0,n_maps-1 do
    for terrainIndex = 0,terrainTypesPerMap[map]-1 do
        for resource = 0,2 do
            if not (terrainIndex == 2 and resource > 0) then
                local ter = civ.getTerrain(map,terrainIndex,resource)
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



-- Flag and Counter Definitions
-- Flags and counters have to be defined somewhere, and this
-- is as good a place as any






-- this will give you an if you try to access a key not entered into
-- the object table, which could be helpful for debugging, but it
-- means that no nil value can ever be returned for table object
-- If you need that ability, comment out this section
setmetatable(object,{__index = function(myTable,key)
    error("The object table doesn't have a value associated with "..tostring(key)..".") end})

return object
]]

io.write(fileOutput)
io.close(file)


print("Basic object file written to "..fileLocation)



