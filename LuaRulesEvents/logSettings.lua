local log = require("log")
local object = require("object")

local logSettings = {}

logSettings.combatReportFunction = log.combatReportFunction



-- Every battle is assigned a region for organizational purposes.
-- The region is determined by means of a "Geography Table"
--
-- A geographyTable is a table indexed by strings, with the 
-- following possible values
-- geographyTable["My Region Name"] = function(tile)-->boolean
--      The tile is considered in My Region Name if the function
--      returns true, and not in the region if the function returns false
-- geographyTable["My First Landmark Name"] = tile object
-- geographyTable["My Second Landmark Name"] = {integer,integer,integer}
-- geographyTable["My Third Landmark Name"] = {integer,integer,table of integers}
-- geographyTable["My Fourth Landmark Name"] = {integer,integer}
--      If the tile is not in any region, then it is placed in a 'region' "near"
--      a landmark.  A landmark described as a tile or as an integer triple
--      is only a landmark on a single map
--      A landmark described by a pair of integers is good for all maps
--      A landmark of the form {integer,integer,table of integers} is a
--      landmark for all the map numbers in table of integers
local geographyTable = {}



-- the short name tables (indexed by ID numbers)
-- provide alternate names for units and tribes 
-- to better fit reports
-- unitTypeShortNameTable[unitType.id]=shortNameString
local unitTypeShortNameTable = {}

-- the short name tables (indexed by ID numbers)
-- provide alternate names for units and tribes 
-- to better fit log reports
-- tribeShortNameTable[tribe.id] = shortNameString
local tribeShortNameTable = {}





log.setGeographyTable(geographyTable)
log.setUnitTypeShortNameTable(unitTypeShortNameTable)
log.setTribeShortNameTable(tribeShortNameTable)

return logSettings



