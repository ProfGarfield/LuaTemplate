
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


local gen = require('generalLibrary'):minVersion(1)

-- Provides a function to read a Civ II ToT rules text file, and saves each value
-- (text between commas) in a table, for easier reference in game
-- Everything after the first semicolon in a line is ignored
-- Numerical values are saved as strings, tonumber can be used if a numerical
-- value is required
-- Leading and trailing whitespace are removed from each entry

-- Output table is as follows:
-- rulesTable[@SECTION][lineNumber][columnNumber] = columnValueString
-- Note: If the rules have @Section or @section, it is rendered to upper case
-- for storage in the rules table
-- line and column number both start at 0, since id values start at 0.
--
-- readRules.readRules(filePath) --> table
--      creates a table with rules.txt entries based on the file from filePath
-- readRules.loadedRules (table)
--      the result of readRules(scenarioFolder\rules.txt)
--      that is, the rules file that the game will load automatically

-- note: use gen.getScenarioDirectory() to get your scenario's directory
-- in order to read rules files.  E.g.
-- readRules.readRules(gen.getScenarioDirectory().."\\AltRules.txt")


local function removeCommentsTrailingSpaces(line)
    local semicolonLoc = string.find(line,";")
    if semicolonLoc then
        line = line:sub(1,semicolonLoc-1)
    end
    while line:sub(-1)==" " or line:sub(-1)=="\t" do
        line = line:sub(1,-2)
    end
    return line
end

local function removeLeadingSpaces(line)
    while line:sub(1,1)==" " or line:sub(1,1)=="\t" do
        line = line:sub(2)
    end
    return line
end

local function lineToTable(line)
    local function splitAtComma(line)
        local commaLoc = string.find(line,",")
        if commaLoc then
            return line:sub(1,commaLoc-1),line:sub(commaLoc+1)
        else
            return line,nil
        end
    end
    local remainingLine = line
    local currentEntry = nil
    local column = 0
    local table = {}
    repeat
        currentEntry,remainingLine = splitAtComma(remainingLine)
        currentEntry = removeCommentsTrailingSpaces(currentEntry)
        currentEntry = removeLeadingSpaces(currentEntry)
        table[column] = currentEntry
        column = column+1
    until column >= 30 or not remainingLine
    return table
end

--local tab = lineToTable("Code of Laws,       4, 1,  Alp, nil, 0, 2    ; CoL")
--for key,val in pairs(tab) do
--    print(key,val)
--end

local readRules = {}

function readRules.readRules(rulesPath,emptyTableInsteadOfError)
    local f = io.open(rulesPath, "r")
    if f == nil and emptyTableInsteadOfError then
        return {}
    elseif f == nil then
        error("readRules.readRules: the path \n"..rulesPath.."\n is not a valid file.")
    else
        io.close(f)
    end


    local rulesTable = {}
    local sectionKey = "@NOSECTION"
    rulesTable[sectionKey] = {}
    local lineNumber = 0;


    for line in io.lines(rulesPath) do
        line = removeCommentsTrailingSpaces(line)
        if line == "" then
            rulesTable[sectionKey][lineNumber] = {}
            lineNumber = lineNumber+1
        elseif line:sub(1,1) == "@" then
            sectionKey = string.upper(line)
            rulesTable[sectionKey] = {}
            lineNumber = 0
        else
            rulesTable[sectionKey][lineNumber] = lineToTable(line)
            lineNumber = lineNumber+1
        end
    end

    return rulesTable

end

local loadedRulesPath = gen.getScenarioDirectory().."\\rules.txt" 
local f = io.open(loadedRulesPath, "r")
if f == nil then
    loadedRulesPath = civ.getToTDir().."\\rules.txt"
else
    io.close(f)
end
readRules.loadedRules = readRules.readRules(loadedRulesPath)

gen.versionFunctions(readRules,versionNumber,fileModified,"LuaCore".."\\".."readRules.lua")
return readRules
