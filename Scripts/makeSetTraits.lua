
local object = require("object")


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

local function findObjectKey(compareStr,arg1,arg2,arg3)
    local sameTypeFn = civ["is"..compareStr]
    local compareFn = civ["get"..compareStr]
    for key,value in pairs(object) do
        if sameTypeFn(value) and value == compareFn(arg1,arg2,arg3) then
            return key
        end
    end
    return false
end
        
local fileLocation = civ.getToTDir().."\\"..tostring(os.time()).."setTraits.lua"
local file = io.open(fileLocation,"a")
io.output(file)





local fileOutput = 
[[
local traits = require("traits")
local object = require("object")

traits.allowedTraits("sample trait 1","sample trait 2",{"sampleThree","sample4"})

-- object 'traits' are strings that you can "assign" to
-- objects, and check elsewhere in your code if a particular
-- object has a particular trait.  If you have a trait "tank",
-- assigning the "tank" trait to a unit type is like
-- adding that unit type to the list of "tank"s,
-- and you can access that list with the traits module.
--
-- To prevent typos, you can only use trait strings that have
-- been registered by traits.allowedTraits.  The functions
-- traits.allowedTraits and traits.assign can take any number
-- of arguments, and you can also supply traits within tables
-- if that makes sense.

-- Unit Type Traits

]]

for i=0,(civ.cosmic.numberOfUnitTypes-1) do
    local key = findObjectKey("UnitType",i)
    if key then
        fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
    else
        print("Warning: could not find entry in object table for unit type "..tostring(i))
    end
end

io.write(fileOutput)
fileOutput = 
[[

-- Tribe Traits

]]
for i=0,7 do
    local key = findObjectKey("Tribe",i)
    if key then
        fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
    else
        print("Warning: could not find entry in object table for tribe "..tostring(i))
    end
end

io.write(fileOutput)
fileOutput = 
[[

-- Tech Traits

]]

for i=0,99 do
    local key = findObjectKey("Tech",i)
    if key then
        fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
    else
        print("Warning: could not find entry in object table for tech "..tostring(i))
    end
end

io.write(fileOutput)
fileOutput = 
[[

-- Improvement Traits

]]
for i=0,39 do
    local key = findObjectKey("Improvement",i)
    if key then
        fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
    else
        print("Warning: could not find entry in object table for improvement "..tostring(i))
    end
end

io.write(fileOutput)
fileOutput = 
[[

-- Wonder Traits

]]
for i=0,27 do
    local key = findObjectKey("Wonder",i)
    if key then
        fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
    else
        print("Warning: could not find entry in object table for wonder "..tostring(i))
    end
end
io.write(fileOutput)
fileOutput = 
[[

-- Base Terrain Traits

]]
for mp =0,(n_maps-1) do
    for terrainIndex = 0,terrainTypesPerMap[mp]-1 do
        local key = findObjectKey("BaseTerrain",mp,terrainIndex)
        if key then
            fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
        else
            print("Warning: could not find entry in object table for BaseTerrain map "..tostring(mp)..", terrain "..tostring(terrainIndex))
        end
    end
end


io.write(fileOutput)
fileOutput = 
[[

-- Terrain Traits

]]
for mp =0,(n_maps-1) do
    for terrainIndex = 0,terrainTypesPerMap[mp]-1 do
        for resource = 0,2 do
            if not (terrainIndex == 2 and resource > 0) then
                local key = findObjectKey("Terrain",mp,terrainIndex,resource)
                if key then
                    fileOutput = fileOutput.."traits.assign(object."..key..",\"sample trait 1\")\n"
                else
                    print("Warning: could not find entry in object table for Terrain map "..tostring(mp)..", terrain "..tostring(terrainIndex)..", resource "..tostring(resource))
                end
            end
        end
    end
end
io.write(fileOutput)
fileOutput =
[[

return {}

]]
io.write(fileOutput)
io.close(file)
civ.sleep(1000)
print("")
print("Basic setTraits file written to "..fileLocation)
print("")

