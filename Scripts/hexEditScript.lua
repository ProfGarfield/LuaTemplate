---@module "generalLibrary"
local gen = require("generalLibrary")
local text = require("text")

local scenDir = gen.getScenarioDirectory()

local inputFileName = "hexedit.sav"
local outputFileName = "hexout.sav"

local file = io.open(scenDir.."\\"..inputFileName,"rb")


local initialMessage = [[
Welcome to the Hex Editor Script
^
^Please load the file you wish to edit (if it is not this game)
and then save it as ]]..inputFileName..[[ in this scenario's
directory.
^
^This script takes information from the active game, so it is
important that ]]..inputFileName..[[ was just saved.
^
^This script will create a new file called ]]..outputFileName..[[,
which will replace the existing file if there is one.
^
^Are you ready to proceed?]]

local menuOptions = {
    [1] = "No, stop the script.",
    [2] = "Yes, I have saved the file "..inputFileName..", and "..outputFileName.." can be overwritten."
}
local choice = text.menu(menuOptions,initialMessage,"Hex Edit Script")
if choice == 1 then
    return
end

local hexEditOptionNames = {}
local optionNameDescriptions = {}
hexEditOptionNames[1] = "Initialize Sum Of City Sizes"
optionNameDescriptions[1] = [[Each tribe has a variable that keeps track
of the tribe's population (sum of the city sizes). 
This governs plunder calculations.  This variable is set to 0 
at the start of the game, and appears to only be updated when a tribe's
cities are processed at the start of its turn.  Consequently, if 
a city is captured before the tribe's turn in a scenario, its entire
treasury is plundered.  This option initializes the sum of the city sizes
variable for each tribe, so that the plunder calculations are correct.
]]

local function descriptionFunction(i)
    text.simple(optionNameDescriptions[i],"Hex Edit Script")
end

local menuDescriptions = {}
local mdOffset = 3
for i=1,#hexEditOptionNames do
    menuDescriptions[i+mdOffset] = hexEditOptionNames[i]
end

local function scriptDescriptions()
    local menuText = "Here are the possible hex editing tasks you can perform.  Select one to see its description.  No tasks will be performed.  You will select tasks in a checkbox menu in the next section."
    menuDescriptions[1] = "Proceed to performing hex editing tasks."
    local choice = text.menu(menuDescriptions,menuText,"Hex Edit Script",true)
    if choice == 1 then
        return 1
    elseif choice == 0 then
        return 0
    end
    descriptionFunction(choice-mdOffset)
    return scriptDescriptions()
end

if scriptDescriptions() == 0 then
    return
end

local hexEditCheckBoxes = {}
for i=1,#hexEditOptionNames do
    hexEditCheckBoxes[i] = false
end



local checkboxMessage = [[
Select the hex editing tasks you would like to perform.
]]
text.checkboxMenu(hexEditOptionNames,hexEditCheckBoxes,checkboxMessage,"Hex Edit Script")


if not file then
    civ.ui.text("Save a file named "..inputFileName.." in the scenario directory and try again.")
    return
end

local data = file:read("a")

if string.sub(data,1,8) ~= "CIVILIZE" then
    civ.ui.text("The file "..inputFileName" is not a save file.")
    io.close(file)
    return
end

local function changeBytes(dataStr,offset,type,number)
    if type ~= "byte" and type ~= "short" then
        error("type must be 'byte' or 'short'")
    end
    if type == "byte" then
        if number < 0 or number > 255 then
            error("number must be between 0 and 255")
        end
        local byte = string.char(number)
        dataStr = dataStr:sub(1,offset)..byte..dataStr:sub(offset+2)
        return dataStr
    end
    if type == "short" then
        if number < 0 or number > 65535 then
            error("number must be between 0 and 65535")
        end
        local byte1 = string.char(math.floor(number/256))
        local byte2 = string.char(number%256)
        dataStr = dataStr:sub(1,offset)..byte2..byte1..dataStr:sub(offset+3)
        return dataStr
    end
end

local function readBytes(dataStr,offset,type)
    if type ~= "byte" and type ~= "short" then
        error("type must be 'byte' or 'short'")
    end
    if type == "byte" then
        return string.byte(dataStr:sub(offset,offset))
    end
    if type == "short" then
        return string.byte(dataStr:sub(offset,offset))*256+string.byte(dataStr:sub(offset+1,offset+1))
    end
end

--[[
-- change all the tribe's money 
for i=1,7 do
    data = changeBytes(data,2954+3348*i,"short",i*1000+(i+1)*100+(i+2)*10+(i+3)*1)
end
civ.ui.text("Changed all tribe's money")
]]

local offsetTable = {
    sumOfTheCitySizes = 3060,
}
local tribeVar1Offset = 242
local tribeVar2Offset = 3348

if hexEditCheckBoxes[1] then
    -- initialize sum of the city sizes
    local citizenCount = {[0]=0,[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0}
    for city in civ.iterateCities() do
        citizenCount[city.owner.id] = citizenCount[city.owner.id] + city.size
    end
    for i=0,7 do
        data = changeBytes(data,offsetTable.sumOfTheCitySizes+tribeVar2Offset*i,"short",citizenCount[i])
    end
    civ.ui.text("Initialized sum of the city sizes")
end

civ.ui.text("Writing to "..outputFileName)

local out = io.open(scenDir.."\\"..outputFileName,"wb")
out:write(data)
io.close(file)
io.close(out)


