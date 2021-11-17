-- this file can be removed if you don't need 

local legacyEventBuilder = require("legacyEventBuilder")


-- set writeTextFile=true if you want to output the table into a text file,
-- false if it should just be returned
local writeTextFile=false

-- set showEventParsed=true to print the @ENDIF line number every time an event is
-- parsed without an error.  This could help for debugging 
local showEventParsed = true

-- Change this if the events text file you are converting has a different name
-- file is relative to the current directory
local eventTextFileName="legacyEvents.txt"

-- Change this if you don't want to use the default name for the output file
-- The OS time should hopefully prevent file overwrites
local eventOutputFileName=tostring(os.time()).."legacyEvents.lua"

-- If the scenario has a batch file, and the batch file changes the events,
-- put the turns that these events are valid into batchInfo
local batchInfo = nil
-- For example
-- batchInfo = {{[1]=firstValidTurn,[2]=lastValidTurn}}
-- batchInfo = {{[1]=firstValidTurn1,[2]=lastValidTurn1},{[1]=firstValidTurn2,[2]=lastValidTurn2},}
-- Then the trigger will only run on turns between a firstValidTurn and a LastValidTurn
-- If events change for some reason other than the turn, ask for help in the forums to make the events work

-- If you are trying to convert several sets of events changed by a batch file, add extra entries to the 
-- eventsToConvert table
local eventsToConvert={{eTFN=eventTextFileName,bI=batchInfo},--[[{eTFN=fileName2,bI=batchInfo2},]]}


--
--
--
--
--
--This stuff shouldn't have to be changed

local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
--print(eventsPath)
local scenarioFolderPath = string.gsub(eventsPath, "getLegacyEvents.lua", "?.lua")
--if string.find(package.path, scenarioFolderPath, 1, true) == nil then
--   package.path = package.path .. ";" .. scenarioFolderPath
--end
local currentFolder = string.gsub(eventsPath,"getLegacyEvents.lua","")
--print(currentFolder)

local legacy = require('legacyEventEngine')

local legacyTable = legacyEventBuilder.buildLegacyEvents(writeTextFile,showEventParsed,eventTextFileName,eventOutputFileName,
    batchInfo,eventsToConvert,scenarioFolderPath,currentFolder)

legacy.supplyLegacyEventsTable(legacyTable)

return legacyTable
