--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- The functions in this file are used to collect information
-- in order to generate a Describe.txt for the civilopedia
--
-- The structure of the generated files will mimic the version
-- of the Civilopedia Describe.txt provided by Knighttime's 
-- Medieval Millennium
--
--
-- Purpose of the Civilopedia Module
--
-- The Civilopedia Module automatically generates a describe.txt
-- file based on information provided to it.  It allows the scenario
-- designer to add documentation to the Civilopedia at the same time
-- and place as the code which creates the feature.

-- Using the Civilopedia Module
--
-- The Civilopedia Module provides one main function:
-- civilopedia.description(object,description,extra)
-- It is used in slightly different ways depending
-- on what you want to add to the describe.txt file
-- that will be generated.
--
-- In all cases, the description string (the second argument)
-- will be added to the existing description for the object
-- in question.  Since there is no guarantee about the order
-- that the files will be required (and the corresponding
-- civilopedia.description function run), The text segments will not
-- necessarily be in the correct order, and you will have to change
-- them when you proofread the describe.txt file.
--
-- Take care to make sure that these function calls are outside your 
-- events, otherwise they won't contribute to the Civilopedia unless you
-- happen to trigger that event before generating the Pedia.
--
-- Technology Description
-- civilopedia.description(techObject,description)
--  Add string description for the advance corresponding to the techObject supplied.
--
-- Improvement Description
-- civilopedia.description(improvementObject,description)
--  Add string description to improvement corresponding to the improvementObject supplied.
--
-- Wonder Description
-- civilopedia.description(wonderObject,description)
--  Add string description to wonder corresponding to the wonderObject supplied.
--
-- Unit Type Description
-- civilopedia.description(unitTypeObject,description)
--  Add string description to unit type corresponding to the unitTypeObject supplied.
--
-- Terrain Description
-- civilopedia.description(terrainObject,description)
--  Add string description to terrain corresponding to the terrainObject supplied.
-- civilopedia.description(civ.getTerrain(map,2,0),description,"base")
--  Adds string description to the grassland replacement without shield for the given map,
--  and not to the shield version
-- civilopedia.description(civ.getTerrain(map,2,0),description,"shield")
--  Adds string description to the grassland replacement with shield for the given map, 
--  and not to the base version
-- civilopedia.description(civ.getTerrain(map,2,0),description)
--  Adds string description to all versions of the grassland replacement for the given map.
--
-- Government Description
-- civilopedia.description(governmentID,description)
--  Adds string description to the government corresponding to the governmentID (integer)
--  (i.e. 0=Anarchy, 1=Despotism, 2=Monarchy, 3=Communism, 4=Fundamentalism, 5=Republic, 6=Democracy)
-- civilopedia.description(governmentID,description,governmentName)
--  Adds string description to the government corresponding to the governmentID,
--  changes the name in the describe.txt to governmentName
--  Note: This change doesn't affect the name of governments in the game.
--  To do that, you change the Rules.txt @GOVERNMENTS
--
-- Game Concept Description
-- civilopedia.description(conceptName,description)
--  Adds string description to conceptName (string), adding the conceptName if it doesn't
--  already exist.
--  The Concepts are arranged by the game in alphabetical order.  If you want to prioritize
--  a concept, have the first character be a space.
--
-- Bulk Addition of Descriptions
-- civilopedia.description({list of objects},description)
--  adds description to all values in the table
--  
-- to generate the describe.txt file, input to the console
-- require("civilopedia").makeDescribeTxt()
-- or, with Lua scenario template, 
-- console.makeDescribeTxt()

local pedia = {}
local maxTechs = 253

local originalAdvancesNames = {

[0]="Advanced Flight",
"Alphabet",
"Amphibious Warfare",
"Astronomy",
"Atomic Theory",
"Automobile",
"Banking",
"Bridge Building",
"Bronze Working",
"Ceremonial Burial",
"Chemistry",
"Chivalry",
"Code of Laws",
"Combined Arms",
"Combustion",
"Communism",
"Computers",
"Conscription",
"Construction",
"Corporation",
"Currency",
"Democracy",
"Economics",
"Electricity",
"Electronics",
"Engineering",
"Environmentalism",
"Espionage",
"Explosives",
"Feudalism",
"Flight",
"Fundamentalism",
"Fusion Power",
"Genetic Engineering",
"Guerrilla Warfare",
"Gunpowder",
"Horseback Riding",
"Industrialization",
"Invention",
"Iron Working",
"Labor Union",
"Laser",
"Leadership",
"Literacy",
"Machine Tools",
"Magnetism",
"Map Making",
"Masonry",
"Mass Production",
"Mathematics",
"Medicine",
"Metallurgy",
"Miniaturization",
"Mobile Warfare",
"Monarchy",
"Monotheism",
"Mysticism",
"Navigation",
"Nuclear Fission",
"Nuclear Power",
"Philosophy",
"Physics",
"Plastics",
"Plumbing",
"Polytheism",
"Pottery",
"Radio",
"Railroad",
"Recycling",
"Refining",
"Refrigeration",
"Republic",
"Robotics",
"Rocketry",
"Sanitation",
"Seafaring",
"Space Flight",
"Stealth",
"Steam Engine",
"Steel",
"Superconductor",
"Tactics",
"Theology",
"Theory of Gravity",
"Trade",
"University",
"Warrior Code",
"Wheel",
"Writing",
"Future Technology",
"User Def Tech A",
"User Def Tech B",
"User Def Tech C",
"Extra Advance 1",
"Extra Advance 2",
"Extra Advance 3",
"Extra Advance 4",
"Extra Advance 5",
"Extra Advance 6",
"Extra Advance 7",
}

local originalImprovementsNames = {
[0]="Nothing",
"Palace",
"Barracks",
"Granary",
"Temple",
"MarketPlace",
"Library",
"Courthouse",
"City Walls",
"Aqueduct",
"Bank",
"Cathedral",
"University",
"Mass Transit",
"Colosseum",
"Factory",
"Manufacturing Plant",
"SDI Defense",
"Recycling Center",
"Power Plant",
"Hydro Plant",
"Nuclear Plant",
"Stock Exchange",
"Sewer System",
"Supermarket",
"Superhighways",
"Research Lab",
"SAM Missile Battery",
"Coastal Fortress",
"Solar Plant",
"Harbor",
"Offshore Platform",
"Airport",
"Police Station",
"Port Facility",
"Transporter",
"SS Structural",
"SS Component",
"SS Module",
"(Capitalization)",
}

local originalWonderNames = {
[0]="Pyramids",
"Hanging Gardens",
"Colossus",
"Lighthouse",
"Great Library",
"Oracle",
"Great Wall",
"Sun Tzu's War Academy",
"King Richard's Crusade",
"Marco Polo's Embassy",
"Michelangelo's Chapel",
"Copernicus' Observatory",
"Magellan's Expedition",
"Shakespeare's Theatre",
"Leonardo's Workshop",
"J. S. Bach's Cathedral",
"Isaac Newton's College",
"Adam Smith's Trading Co.",
"Darwin's Voyage",
"Statue of Liberty",
"Eiffel Tower",
"Women's Suffrage",
"Hoover Dam",
"Manhattan Project",
"United Nations",
"Apollo Program",
"SETI Program",
"Cure for Cancer",
}

local originalUnitNames = {
[0]="Settlers",
"Engineers",
"Warriors",
"Phalanx",
"Archers",
"Legion",
"Pikemen",
"Musketeers",
"Fanatics",
"Partisans",
"Alpine Troops",
"Riflemen",
"Marines",
"Paratroopers",
"Mech. Inf.",
"Horsemen",
"Chariot",
"Elephant",
"Crusaders",
"Knights",
"Dragoons",
"Cavalry",
"Armor",
"Catapult",
"Cannon",
"Artillery",
"Howitzer",
"Fighter",
"Bomber",
"Helicopter",
"Stlth Ftr.",
"Stlth Bmbr.",
"Trireme",
"Caravel",
"Galleon",
"Frigate",
"Ironclad",
"Destroyer",
"Cruiser",
"AEGIS Cruiser",
"Battleship",
"Submarine",
"Carrier",
"Transport",
"Cruise Msl.",
"Nuclear Msl.",
"Diplomat",
"Spy",
"Caravan",
"Freight",
"Explorer",
"Extra Land",
"Extra Ship",
"Extra Air",
}

local originalGovernemntNames = {
[0] = "Anarchy",
"Despotism",
"Monarchy",
"Communism",
"Fundamentalism",
"Republic",
"Democracy",
}



local ADVANCE_DESCRIPTIONS = {}
-- indexed by advances id

local IMPROVEMENT_DESCRIPTIONS = {}
-- indexed by improvement id

local WONDER_DESCRIPTIONS = {}
-- indexed by wonder id

local UNIT_DESCRIPTIONS = {}
-- indexed by unitType id

local TERRAIN_AND_RESOURCE_DESCRIPTIONS = {}
-- TERRAIN_AND_RESOURCE_DESCRIPTIONS[mapID][baseTerrainID][resourceID]
for mapID = 0,3 do
    TERRAIN_AND_RESOURCE_DESCRIPTIONS[mapID] = {}
    for baseTerrainID = 0,15 do
        TERRAIN_AND_RESOURCE_DESCRIPTIONS[mapID][baseTerrainID] = {}
        for resourceID = 0,2 do
            TERRAIN_AND_RESOURCE_DESCRIPTIONS[mapID][baseTerrainID][resourceID] = ""
        end
    end
end

local GOVERNMENT_DESCRIPTIONS = {}
-- GOVERNMENT_DESCRIPTIONS[governmentNumber]
local GOVERNMENT_NAMES = {
[0] = "Anarchy",
"Despotism",
"Monarchy",
"Communism",
"Fundamentalism",
"Republic",
"Democracy",
}


local CONCEPT_DESCRIPTIONS = {}
-- CONCEPT_DESCRIPTIONS["Concept Name"]

local function standardAddDescription(table,index,description)
    table[index] = table[index] or ""
    table[index] = table[index]..description.."\n\n"
end

local function addTerrainDescription(terrain,description,grasslandMod)
    local table = TERRAIN_AND_RESOURCE_DESCRIPTIONS
    local t = terrain
    if terrain.type == 2 then
        -- handle grassland special
        if not grasslandMod then
            -- add description to all versions of grassland
            table[t.map][2][0] = table[t.map][2][0]..description.."\n\n"
            table[t.map][2][1] = table[t.map][2][1]..description.."\n\n"
            table[t.map][2][2] = table[t.map][2][2]..description.."\n\n"
        elseif type(grasslandMod) ~= "string" then
            error('civilopedia.description: When adding a modifier for the grassland description, it must be either "shield" or "base", or nil. Received:'..tostring(grasslandMod))
        elseif string.lower(grasslandMod) == "shield" then
            -- add description to both resources
            table[t.map][2][1] = table[t.map][2][1]..description.."\n\n"
            table[t.map][2][2] = table[t.map][2][2]..description.."\n\n"
        elseif string.lower(grasslandMod) == "base" then
            -- add description only to base version of grassland
            -- (no shield)
            table[t.map][2][0] = table[t.map][2][0]..description.."\n\n"
        else
            error('civilopedia.description: When adding a modifier for the grassland description, it must be either "shield" or "base", or nil. Received:"'..tostring(grasslandMod)..'"')
        end
    else
        -- the table is already initialized
        table[t.map][t.type][t.resource] = table[t.map][t.type][t.resource]..description.."\n\n"
    end
end

local function addGovernmentDescription(govtID,description,name)
    if govtID < 0 or govtID > 6 or govtID ~= math.floor(govtID) then
        error("civilopedia.description: Can only add descriptions to integers between 0 and 6 (inclusive), because no other number corresponds to a Civilization II government.  Received:"..tostring(govtID))
    end
    if type(name) == "string" then
        GOVERNMENT_NAMES[govtID] = name
    elseif name then
        error("civilopedia.description: When adding a third argument for a government description, it must be a string.  received:"..tostring(name))
    end
    GOVERNMENT_DESCRIPTIONS[govtID] = GOVERNMENT_DESCRIPTIONS[govtID] or ""
    GOVERNMENT_DESCRIPTIONS[govtID] = GOVERNMENT_DESCRIPTIONS[govtID]..description.."\n\n"
end


function pedia.description(object,description,extra)
    if type(description) ~= "string" then
        error("civilopedia.description: The second argument (the description) must always be a string.  Instead recevied: "..tostring(description))
    end
    if type(object) == "table" then
        for _,value in pairs(object) do
            pedia.description(value,description,extra)
        end
        return
    end
    if type(object) == "string" then
        -- concept description
        standardAddDescription(CONCEPT_DESCRIPTIONS,object,description)
    elseif type(object) == "number" then
        -- government description
        addGovernmentDescription(object,description,extra)
    elseif type(object) == "nil" then
        error("civilopedia.description: attempt to add description for a nil.")
    elseif civ.isTech(object) then
        -- advance description
        standardAddDescription(ADVANCE_DESCRIPTIONS,object.id,description)
    elseif civ.isImprovement(object) then
        -- improvement description
        standardAddDescription(IMPROVEMENT_DESCRIPTIONS,object.id,description)
    elseif civ.isWonder(object) then
        -- wonder description
        standardAddDescription(WONDER_DESCRIPTIONS,object.id,description)
    elseif civ.isUnitType(object) then
        -- unit description
        standardAddDescription(UNIT_DESCRIPTIONS,object.id,description)
    elseif civ.isTerrain(object) then
        -- terrain description
        addTerrainDescription(object,description,extra)
    elseif civ.isBaseTerrain(object) then
        -- tell user to use terrain instead
        error("civilopedia.description: Can't add a description for a baseterrain object.  Provide a terrain object instead (civ.getTerrain(map,terrainType,resource))")
    else
        error("civilopedia.description: attempt to add description for an invalid object: "..tostring(object))
    end
end



local function generateIndexLine(lineNumber,object,description,originalNameTable)
    local originalName = ""
    if originalNameTable[lineNumber] then
        originalName = " ("..originalNameTable[lineNumber]..")"
    end
    local objectName = "Not Included"
    if type(object) == "string" then
        objectName = object
    elseif object and object.name then
        objectName = object.name
    end
    if not description or description == "" then
        return "-1,\t\t;\t"..lineNumber.."\t"..objectName..originalName.."\n"
    else
        return lineNumber..",\t\t;\t"..lineNumber.."\t"..objectName..originalName.."\n"
    end
end
local function generateDescriptionLine(number, object,description,originalNameTable)
    local originalName = ""
    if originalNameTable[number] then
        originalName = " ("..originalNameTable[number]..")"
    end
    local objectName = "Not Included"
    if type(object) == "string" then
        objectName = object
    elseif object and object.name then
        objectName = object.name
    end
    if not description or description == "" then
        return "@@"..number..",\t"..objectName..originalName.."\n\n"
    else
        return "@@"..number..",\t"..objectName..originalName.."\n"..description.."\n\n"
    end
end

local minVersion = function(self,minVersion)
    if versionNumber < minVersion then
        local message = "The LuaCore\\civilopedia.lua file is out of date.  It is version "..tostring(versionNumber)..
        ", but one of your other files needs version "..tostring(minVersion).." or later.  "
        .."You should download the most recent version of the Lua Scenario Template, and replace "
        .."LuaCore\\civilopedia with the updated version."
        if fileModified then
            message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
            .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."

        end
        error(message)
    end
    return self
end
local recommendedVersion = function(self,recVersion)
    local moduleFileName = "LuaCore\\civilopedia.lua"
    local vNum = versionNumber
    if vNum < recVersion then
        local message = "WARNING: The "..moduleFileName.." is out of date.  It is version "..tostring(vNum)..
        ", but one of your files recommends version "..tostring(minVersion).." or later.  "
        if fileMod then
            message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
            .."  Replacing this file will remove those changes.  This is not a mandatory update, so you (probably) don't have to make any changes.  However, you may still wish to bring code in from the new file for extra features."
        else
            message = message.." The fileModified variable at the top of the file does not indicate that you have made any changes to this file.  If this is actually the case, you can replace it with the most recent version from the Lua Scenario Template without any problem."
        end
        print(message.."\n")
    end
    return self
end
pedia.minVersion = minVersion
pedia.recommendedVersion = recommendedVersion
pedia.getVersion = versionNumber



function pedia.makeDescribeTxt()
local output = [==[
;
;   Civilopedia Descriptions Text File
;   Copyright (c) 1997 MicroProse Software, Inc.
;
;
]==]
output = output..os.date(";\tFile generated on %d %B, %Y using the Civilopedia module\n")
output = output..[==[
;   The generated file is based on the Describe.txt file that shipped
;   with Knighttime's Medieval Millennium mod
;

@ADVANCE_DESCRIPTIONS
]==]
output = output.."\n;\n@@ADVANCE_INDEX\n"
for i=0,maxTechs-1 do
    output = output..generateIndexLine(i,civ.getTech(i),ADVANCE_DESCRIPTIONS[i],originalAdvancesNames)
end
output = output.."-2,\t\t;\tMUST BE HERE! TERMINATOR!\n\n"

for i=0,maxTechs-1 do
    output = output..generateDescriptionLine(i,civ.getTech(i),ADVANCE_DESCRIPTIONS[i],originalAdvancesNames)
end

output = output..[==[
@IMPROVEMENT_DESCRIPTIONS
;
]==]

output = output.."@@IMPROVEMENT_INDEX\n"
for i=0,39 do
    output = output..generateIndexLine(i,civ.getImprovement(i),IMPROVEMENT_DESCRIPTIONS[i],originalImprovementsNames)
end
output = output.."-2,\t\t;\tMUST BE HERE! TERMINATOR!\n\n"
for i=0,39 do
    output = output..generateDescriptionLine(i,civ.getImprovement(i),IMPROVEMENT_DESCRIPTIONS[i],originalImprovementsNames)
end

output = output..[==[
@WONDER_DESCRIPTIONS
;
]==]
output = output.."@@WONDER_INDEX\n"
for i=0,27 do
    output = output..generateIndexLine(i,civ.getWonder(i),WONDER_DESCRIPTIONS[i],originalWonderNames)
end
output = output.."-2,\t\t;\tMUST BE HERE! TERMINATOR!\n\n"
for i=0,27 do
    output = output..generateDescriptionLine(i,civ.getWonder(i),WONDER_DESCRIPTIONS[i],originalWonderNames)
end

output = output..[==[
@UNIT_DESCRIPTIONS
;
]==]
output = output.."@@UNIT_INDEX\n"
for i=0,civ.cosmic.numberOfUnitTypes -1 do
    output = output..generateIndexLine(i,civ.getUnitType(i),UNIT_DESCRIPTIONS[i],originalUnitNames)
end
output = output.."-2,\t\t;\tMUST BE HERE! TERMINATOR!\n\n"
for i=0,civ.cosmic.numberOfUnitTypes -1 do
    output = output..generateDescriptionLine(i,civ.getUnitType(i),UNIT_DESCRIPTIONS[i],originalUnitNames)
end

local terrainLine = 0
local terrainIndexOutput = "@@TERRAIN_INDEX\n"
local terrainDescriptionOutput = ""
local width,height,mapNumber=civ.getAtlasDimensions()
for map=0,mapNumber-1 do
    for resourceID = 0,2 do
        for baseTerrainID=0,15 do
            if baseTerrainID==2 then
                terrainIndexOutput = terrainIndexOutput..generateIndexLine(terrainLine,
                    civ.getTerrain(map,2,0),TERRAIN_AND_RESOURCE_DESCRIPTIONS[map][2][resourceID],{})
                terrainDescriptionOutput = terrainDescriptionOutput..generateDescriptionLine(terrainLine,
                    civ.getTerrain(map,2,0),TERRAIN_AND_RESOURCE_DESCRIPTIONS[map][2][resourceID],{})
                terrainLine = terrainLine+1
            else
                local terrainExists,terrain = pcall(civ.getTerrain,map,baseTerrainID,resourceID)
                if terrainExists then
                    terrainIndexOutput = terrainIndexOutput..generateIndexLine(terrainLine,
                        civ.getTerrain(map,baseTerrainID,resourceID),
                        TERRAIN_AND_RESOURCE_DESCRIPTIONS[map][baseTerrainID][resourceID],{})
                    terrainDescriptionOutput = terrainDescriptionOutput..generateDescriptionLine(terrainLine,
                        civ.getTerrain(map,baseTerrainID,resourceID),
                        TERRAIN_AND_RESOURCE_DESCRIPTIONS[map][baseTerrainID][resourceID],{})
                    terrainLine = terrainLine+1
                end
            end
        end
    end
end
terrainIndexOutput = terrainIndexOutput.."-2,\t\t;\tMUST BE HERE! TERMINATOR!\n\n"
output = output..[==[

@TERRAIN_AND_RESOURCE_DESCRIPTIONS
;
]==]
output = output..terrainIndexOutput..terrainDescriptionOutput

output = output..[==[

@GOVERNMENT_DESCRIPTIONS
;
]==]

output = output.."@@GOVERNMENT_INDEX\n"
for i=0,6 do
    output = output..i..",\t\t;\t"..GOVERNMENT_NAMES[i].." ("..originalGovernemntNames[i]..")\n"
end
output = output.."-2,\t\t;\tMUST BE HERE! TERMINATOR!\n\n"
for i=0,6 do
    output = output.."@@"..GOVERNMENT_NAMES[i].."\n"..(GOVERNMENT_DESCRIPTIONS[i] or "").."\n\n"
end

output = output.."@CONCEPT_DESCRIPTIONS\n;\n"
for concept,description in pairs(CONCEPT_DESCRIPTIONS) do
    output = output.."@@"..concept.."\n"..description.."\n\n"
end
output = output.."\n\n\n@This must be here to terminate search!!!\n"

local destinationDirectory = civ.getToTDir()
local genHere, gen = pcall(require,"generalLibrary")
if genHere then
    gen.versionFunctions(pedia,versionNumber,fileModified,"LuaCore".."\\".."civilopedia.lua")
    local directoryFound, scenDir = pcall(gen.getScenarioDirectory)
    if directoryFound then
        destinationDirectory = scenDir
    end
end
local fileLocation = destinationDirectory.."\\"..tostring(os.time()).."describe.txt"

local file = io.open(fileLocation,"a")
io.output(file)
io.write(output)
io.close(file)
print("describe.txt file written to "..fileLocation)
end

if _G.console then
    console.makeDescribeTxt = pedia.makeDescribeTxt
end



return pedia
