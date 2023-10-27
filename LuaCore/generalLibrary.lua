local versionNumber = 11
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


-- The General Lua Library
-- This set of code is meant to provide basic functionality
-- in order to facilitate the writing of events and
-- other Civilization II Libraries

-- BRIEF DOCUMENTATION
-- More documentation about how these functions work can
-- be found at their definition.

-- Any function here that accepts a tile will also
-- accept a table {[1]=x,[2]=y,[3]=z}, a table 
-- {[1]=x,[2]=y} and assume z = 0, or a table
-- {x=x,y=y,z=z}, or a table {x=x,y=y} and assume
-- z = 0
--
-- LIST OF FUNCTIONS
-- * means planned but not implemented
-- # means needs testing
--


--[[
---&autoDoc generalLibrary
The General Library offers a variety of tools to make it easier to build events. To access functions from the General Library, you should include the following line at the top of your file:
```lua
local gen = require("generalLibrary")
```
---&endAutoDoc
]]

--[[The General Library offers a variety of tools to make it easier to build events. To access functions from the General Library, you should include the following line at the top of your file:
```lua
local gen = require("generalLibrary")
```]]
---@class gen
local gen = {}

--[[
---&autoDoc genConstants
The gen.constants table provides numbers which are hard coded into the
game so that you don't need to have "magic numbers" in your code.  The
table `gen.c` is a copy of this table, for a slightly more compact
reference.
---&endAutoDoc
]]

---@enum gen.constants
gen.constants = {
    maxTribes = 8,
    maxTribeID = 7,
    maxUnitTypes = 189,
    maxUnitTypeID = 188,
    domainLand = 0,
    domainAir = 1,
    domainSea = 2,
    maxMoveSpent = 255,
    maxImprovements = 40,
    maxImprovementID = 39,
    maxWonders = 28,
    maxWonderID = 27,
    maxBaseTerrains = 64,
    maxBaseTerrainID = 63,
    maxBaseTerrainPerMap = 16,
    maxBaseTerrainType = 15,
    maxTerrains = 192,
    maxTerrainID = 191,
    maxMaps = 4,
    maxMapID = 3,
    maxTechID = 252,
    maxTechGroups = 8,
    maxTechGroupID = 7,
    techGroupCanOwnCanResearch = 0,
    techGroupCanOwnCannotResearch = 1,
    techGroupCannotOwnCannotResearch = 2,
    roleAttack = 0,
    roleDefend = 1,
    roleNavalSuperiority = 2,
    roleAirSuperiority = 3,
    roleSeaTransport = 4,
    roleSettle = 5,
    roleDiplomacy = 6,
    roleTrade = 7,
    epochAncient = 0,
    epochRenaissance = 1,
    epochIndustrialRevolution = 2,
    epochModern = 3,
    categoryMilitary = 0,
    categoryEconomic = 1,
    categorySocial = 2,
    categoryAcademic = 3,
    categoryApplied = 4,
    govtAnarchy = 0,
    govtDespotism = 1,
    govtMonarchy = 2,
    govtCommunism = 3,
    govtFundamentalism = 4,
    govtRepublic = 5,
    govtDemocracy = 6,
    resourceNone = 0,
    resourceFish = 1,
    resourceWhale = 2,
    grasslandType = 2,
    leaderAggressive = 1,
    leaderRational = -1,
    leaderExpansionist = 1,
    leaderPerfectionist = -1,
    leaderCivilized = 1,
    leaderMilitaristic = -1,
    leaderNeutral = 0,
    cityStyleBronzeAge = 0,
    cityStyleClassical = 1,
    cityStyleFarEast = 2,
    cityStyleMedieval = 3,
    oceanBaseTerrainType = 10,
}
gen.c = gen.constants


-- gen.requireIfAvailable(fileName) --> boolean, modulePrefix

--[[
Attempts to require the module called fileName
returns true, modulePrefix if the module is found
returns false, nil if no module is found
makes an error if there is a problem loading the module]]
---@param fileName string The name of the file to require
---@return boolean fileFound true if the module was found, false otherwise
---@return table|nil modulePrefix returns the module table if it was found, or nil if not
function gen.requireIfAvailable(fileName)
--     Note: if you change the function name here, the function can 
--     be copied and pasted if you don't want to require the general library 
    if package.loaded[fileName] then
---@diagnostic disable-next-line: redundant-return-value
        return true, require(fileName)
    else
        for _,searcher in ipairs(package.searchers) do
            local loader = searcher(fileName)
            if type(loader) == 'function' then
---@diagnostic disable-next-line: redundant-return-value
                return true, require(fileName)
            end
        end
        return false, nil
    end
end
--
--
--      Stuff below hasn't been documented on website
--
--  gen.original is a table of objects with keys based on 
--  the name of the item in the original game
--
--

-- FUNCTION IMPLEMENTATIONS
--

---@type table|boolean
local authoritativeDefaultRules = false

--[[This function is used to register the authoritativeDefaultRules
table from changeRules.lua to be used in the General Library.
All functions in the General Library will function appropriately
even if the authoritativeDefaultRules are never registered.]]
---@param aDRTable table
function gen.registerAuthoritativeDefaultRules(aDRTable)
    authoritativeDefaultRules = aDRTable
end

---@module customCosmic
local customCosmic = {}

--[[ This function is used to register the customCosmic functions,
so that some generalLibrary functions can use the information
registered by the customCosmic module.]]
---@param cc table # The table for the customCosmic module.
function gen.registerCustomCosmic(cc)
    customCosmic = cc
end


-- gen.checkBits(integer,string)-->boolean
-- Helper function (provided to this library as checkBits and gen.checkBits)

-- Compares the binary representation of an integer with
-- a string.  If the string has a 1 in a given place,
-- the binary representation of the integer should also
-- have a 1.  If the string has a 0 in a given place, the
-- binary representation should also have a 0. Any other
-- character in the string means the integer can have a
-- 0 or a 1.  If the integer representation is longer than
-- the string, the string is aligned with the smallest
-- part of the integer.
--[[
```lua
gen.checkBits(0b10101011,"xx10xwqp")-->true
gen.checkBits(0b10101011,"xx11xwqp")-->false
gen.checkBits(0b011110101011,"xx10xwqp")-->true
gen.checkBits(0b011110101011,"xx10xwqp")-->true
```]]
-- note: lua does not actually accept integers specified in binary 
-- (though it does for hexidecimal)
---@param bitmask integer|bitmask the number/bitmask to be checked
---@param bitString string specification of bits that should be checked
---@return boolean bitsMatch
function gen.checkBits(bitmask,bitString)
    local strlen = string.len(bitString)
    for i=1,strlen do
        local bitInt = 1<<(i-1)
        if bitString:sub(-i,-i) == "1" and bitmask & bitInt == 0 then
            -- ith bit isn't 1, but bitString specifies 1
            return false
        elseif bitString:sub(-i,-i) == "0" and bitmask & bitInt == bitInt then
            -- ith bit is 1, but bitString specifies 0
            return false
        end
    end
    -- if we get here, all specified bits match
    return true
end
local checkBits = gen.checkBits

-- gen.setBits(integer,string)-->integer
-- Helper function (provided to this library as setBits and gen.setBits)

-- Sets binary bits in an integer/bitmask to 1 or 0 based on
-- the information provided by a string.  Characters that 
-- are not 1 or 0 leave the corresponding bit unchanged
-- Last character of the string corresponds to the 1's bit
-- in the integer (string lines up to the least significant
-- part of the number).
--[[
```lua
gen.setBits(0b00000000,"xx10xxxx")-->0b00100000
gen.setBits(0b00000000,"xx10xx")-->0b00001000
gen.setBits(0b11111100,"xx0011xx")-->0b11001100
gen.setBits(0b10101011,"xx10xwqp")-->0b10101011
gen.setBits(0b10101011,"xx11xwqp")-->0b10111011
```]]
-- note: lua does not actually accept integers specified in binary (though it does for hexidecimal)
---@param bitmask integer|bitmask the bitmask to change
---@param bitString string specification of bits to set
---@return bitmask bitmask The integer/bitmask after the bits have been set
function gen.setBits(bitmask,bitString)
    local strlen = string.len(bitString)
    for i=1,strlen do
        local bitInt = 1<<(i-1)
        if bitString:sub(-i,-i) == "1" then
            bitmask = bitmask | bitInt
        elseif bitString:sub(-i,-i) == "0" then
            bitmask = bitmask & ~bitInt
        end
    end
    ---@cast bitmask bitmask
    return bitmask
end
local setBits = gen.setBits

-- gen.printBits(integer,numOfBits or nil) --> string

-- creates the binary representation of integer/bitmask,
-- including the numOfBits least significant bits
-- if numOfBits is nil, it defaults to 32
---@param bitmask bitmask the bits to print
---@param numOfBits integer the number of bits to show (default 32)
---@return string binaryRepresentation
function gen.bitmaskToString(bitmask,numOfBits)
    if not numOfBits then
        numOfBits = 32
    end
    if type(bitmask)~= "number" or type(numOfBits) ~= "number" then
        error("gen.printBits requires integer arguments.")
    end
    local concatTable = {}
    for i=1,numOfBits do
        if bitmask & 1<<(numOfBits-i) == 0 then
            concatTable[i]="0"
        else
            concatTable[i]="1"
        end
    end
    return table.concat(concatTable)
end
gen.printBits = gen.bitmaskToString

-- gen.isBit1(integer,bitNumber)--> boolean
-- Helper Function (provided as local and in gen table)

-- tells if bitNumber bit of integer/bitmask is 1 
-- (1st bit is the bit for the ones position)
--[[
```lua
gen.isBit1(0b00000010,2) -->true
gen.isBit1(0b11111110,1) -->false
```]]
-- note: lua does not actually accept integers specified in binary (though it does accept hexidecimal)
---@param bitmask integer/bitmask
---@param bitNumber integer
---@return boolean
function gen.isBit1(bitmask,bitNumber)
    return bitmask & 1<<(bitNumber-1) == 1<<(bitNumber-1)
end
local isBit1 = gen.isBit1

-- gen.isBit0(integer,bitNumber)--> boolean
-- Helper Function (provided as local and in gen table)

-- tells if bitNumber bit of integer is 0 
-- (1st bit is the bit for the ones position)
--[[
```lua
gen.isBit0(0b00000010,2) -->false
gen.isBit0(0b11111110,1) -->true
```]]
-- note: lua does not actually accept integers specified in binary (though it does accept hexidecimal)
---@param bitmask integer|bitmask
---@param bitNumber integer
---@return boolean
function gen.isBit0(bitmask,bitNumber)
    return bitmask & 1<<(bitNumber-1) == 0
end
local isBit0 = gen.isBit0

-- gen.setBit1(integer,bitNumber)-->integer
-- Helper Function (provided as local and in gen table)

-- sets bitNumber bit of the integer/bitmask to 1
-- (1st bit is the bit for the ones position)
--[[
```lua
gen.setBit1(0b00000000,3) --> 0b00000100
```]]
-- note: lua does not actually accept integers specified in binary (though it does accept hexidecimal)
---@param bitmask integer|bitmask
---@param bitNumber integer
---@return bitmask
function gen.setBit1(bitmask,bitNumber)
---@diagnostic disable-next-line: return-type-mismatch
	return bitmask | 1<<(bitNumber-1)
end
local setBit1 = gen.setBit1

-- gen.setBit0(integer,bitNumber)-->integer
-- Helper Function (provided as local and in gen table)

-- sets bitNumber bit of the integer/bitmask to 0
-- (1st bit is the bit for the ones position)
--[[
```lua
gen.setBit0(0b11111111,3) --> 0b11111011
```]]
-- note: lua does not actually accept integers specified in binary (though it does accept hexidecimal)
---@param bitmask integer|bitmask
---@param bitNumber integer
---@return bitmask
function gen.setBit0(bitmask,bitNumber)
---@diagnostic disable-next-line: return-type-mismatch
	return bitmask & ~(1<<(bitNumber-1))
end
local setBit0 = gen.setBit0

local thresholdTableMetatable = { __index = function(thresholdTable,key)
            if type(key) ~= "number" then
                return rawget(thresholdTable,key)
            else
                local bestIndexSoFar = -math.huge
                local bestValueSoFar = false
                for index,value in pairs(thresholdTable) do
                    if type(index) == "number" and key >= index and index >= bestIndexSoFar then
                        bestIndexSoFar = index
                        bestValueSoFar = value
                    end
                end
                return bestValueSoFar
            end
        end,}

-- A threshold table is a table where if a numerical key is indexed, and that
-- numerical key doesn't correspond to an index, the value of the largest
-- numerical index less than the key is used.
-- If there is no numerical index smaller than the key, false is returned
-- (nil is returned for non-numerical keys not in table)
-- Use an index -math.huge to provide values for arbitrarily small numerical keys
-- example 
-- myTable = gen.makeThresholdTable({[-1]=-1,[0]=0,[1]=1,})
-- myTable[-2] = false
-- myTable[-1] = -1
-- myTable[-0.6] = -1
-- myTable[3.5]=1
-- myTable["three"] = nil
-- myTable[0.5]=0
---@class thresholdTable: table

-- gen.makeThresholdTable(table or nil)-->thresholdTable

-- A threshold table is a table where if a numerical key is indexed, and that
-- numerical key doesn't correspond to an index, the value of the largest
-- numerical index less than the key is used.
-- If there is no numerical index smaller than the key, false is returned.
-- (nil is returned for non-numerical keys not in table)
-- Use an index -math.huge to provide values for arbitrarily small numerical keys.
-- Example:
--[[
    ```lua 
myTable = gen.makeThresholdTable({[-1]=-1,[0]=0,[1]=1,})
myTable[-2] --> false
myTable[-1] --> -1
myTable[-0.6] --> -1
myTable[3.5]-->1
myTable["three"] --> nil
myTable[0.5]-->0
```]]
-- makes an input a threshold table or creates an empty thresholdTable
-- Also returns the table value
---@param inputTable table|nil
---@return thresholdTable
---@overload fun():thresholdTable
function gen.makeThresholdTable(inputTable)
    inputTable = inputTable or {}
    return setmetatable(inputTable,thresholdTableMetatable)
end

-- applyWonderBonus(wonderObject or integer,tribeObject or integer)-->boolean
-- gen.isWonderActiveForTribe(wonderObject or integer,tribeObject or integer)-->boolean

-- Returns true if the `wonder` is owned by the `tribe` and is not expired, and false otherwise.
-- Integers corresponding to wonder/tribe ids can be used as arguments instead.
-- revisions by Knighttime, 2021-11-12
---@param wonder wonderObject|integer the wonder (or id of wonder) in question 
---@param tribe tribeObject|integer the tribe (or id of tribe) in question
---@return boolean wonderIsActive
function gen.isWonderActiveForTribe(wonder,tribe)
    if type(wonder) == "number" then
---@diagnostic disable-next-line: cast-local-type
        wonder = civ.getWonder(wonder)
    end
    if not wonder then
        error("gen.isWonderActiveForTribe: arg #1 must be either a wonderObject, or an integer ID for a wonder object.  Received: "..tostring(wonder))
    end
    if type(tribe) == "number" then
---@diagnostic disable-next-line: cast-local-type
        tribe = civ.getTribe(tribe)
    end
    if not tribe then
        error("gen.isWonderActiveForTribe: arg #2 must be either a tribeObject, or an integer ID for a tribe object.  Received: "..tostring(wonder))
    end
    --check if expired
	-- Kn: If barbarians (tribe 0) are the first to acquire a wonder expiration tech,
	--   the in-game popup appears announcing that this cancels the effect of the wonder.
	--   But it doesn't actually do so! The wonder continues to function until a
	--   non-barbarian tribe acquires the tech, so the loop below starts with 1.
    for i=1,7 do
---@diagnostic disable-next-line: param-type-mismatch
        if civ.getTribe(i) and wonder.expires and civ.hasTech(civ.getTribe(i), wonder.expires) then
            return false
        end
    end
    if wonder.city and wonder.city.owner == tribe then
        return true
    else 
        return false
    end
end
local applyWonderBonus = gen.isWonderActiveForTribe

--[[A tileAnalog is either a tileObject or a table with
one of the following forms: {[1]=x,[2]=y,[3]=z}, {[1]=x,[2]=y}
(and assumes z=0), {x=x,y=y,z=z}, or {x=x, y=y} (and assumes z=0).
The x,y,z values (but not keys) correspond to tile coordinates.
]]
---@alias tileAnalog 
---| tileObject
---| table {x=xCoord,y=yCoord,z=zCoord} or {xCoord,yCoord,zCoord} if zCoord nil, use map 0
--[[
# Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
]]

-- toTile(tile or table)-->tile
-- gen.toTile(tile or table)-->tile
-- Helper Function (provided to this library as toTile and gen.toTile)

-- If given a tile object, returns the tile.
-- If given coordinates for a tile, returns the tile.
-- Causes error otherwise
---@param tileAnalog tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return tileObject
function gen.toTile(tileAnalog)
    if civ.isTile(tileAnalog) then
        if civ.getTile(tileAnalog.x,tileAnalog.y,tileAnalog.z) then
            return tileAnalog
        else
            error("toTile: tile coordinates are ("..tostring(tileAnalog.x)..","..tostring(tileAnalog.y)..
            ","..tostring(tileAnalog.z).." which does not correspond to a tile on the map.  "..
            "the game is known to return a 'false tile' for loser.location in unit killed if the"..
            " attacking unit was the loser, though this may happen elsewhere as well.")
        end
    elseif type(tileAnalog) == "table" then
        local xVal = tileAnalog[1] or tileAnalog["x"]
        local yVal = tileAnalog[2] or tileAnalog["y"]
        local zVal = tileAnalog[3] or tileAnalog["z"] or 0
        if type(xVal)=="number" and type(yVal)=="number" and type(zVal)=="number" then
            local givenTile = civ.getTile(xVal,yVal,zVal)
            if givenTile then
                return givenTile
            else
                error("Table with values {"..tostring(xVal)..","..tostring(yVal)..
                        ","..tostring(zVal).."} does not correspond to a valid tile.")
            end
        else
            error("Table did not correspond to tile coordinates")
        end
    else
        error("Did not receive a tile object or table of coordinates.")
    end
end
local toTile = gen.toTile


-- by default, the map is considered flat
-- use gen.declareMapRound to say the map is round
-- with TOTPP v 16, we can access directly whether world is flat
-- reference to the variable flatMap has been removed in this
-- file, the variable itself is left to avoid errors
-- with the declareMap functions.
local flatMap = civ.game.rules.flatWorld

-- gen.isMapFlat()-->boolean
---Returns true if the game map is flat, and false if it is round.
---@return boolean mapIsFlat
function gen.isMapFlat()
    return civ.game.rules.flatWorld
end

-- gen.isMapRound()-->boolean
---Returns true if the game map is round, and false if it is flat.
---@return boolean mapIsRound
function gen.isMapRound()
    return not civ.game.rules.flatWorld
end

-- gen.declareMapFlat()-->void
-- tells this module that the map should be considered flat
-- for things like distances and adjacent squares
-- no longer has practical effect, since above
-- functions access world shape directly with TOTPP v16
---@deprecated
function gen.declareMapFlat()
    flatMap = true
end

-- gen.declareMapRound()-->void
---@deprecated
function gen.declareMapRound()
    flatMap = false
end

-- tileDist(locA,locB,zDist=0)
-- gen.tileDist(locA,locB,zDist=0)

-- Takes two tiles and a 'vertical distance' (0 if absent)
-- and computes the distance between them.
-- Doesn't pre-process arguments like gen.distance, so might be slightly
-- quicker (though this probably too trivial to ever matter).
-- Computes the distance you would get by counting tiles.
-- If you want the game's approximation of "Euclidean" distance that
-- is used in many game mechanics, use gen.gameMechanicDistance
---@param tileA tileObject
---@param tileB tileObject
---@param zDist? integer The distance between tiles with same x,y coordinates but differing in z by 1. 0 by default.
---@return integer
function gen.tileDist(tileA,tileB,zDist)
    zDist = zDist or 0
    if civ.game.rules.flatWorld then
        return (math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)+2*zDist*math.abs(tileA.z-tileB.z))//2
    else
        local xMax,yMax,zMax=civ.getAtlasDimensions()
        return math.min((math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)+2*zDist*math.abs(tileA.z-tileB.z))//2,
            (xMax-math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)+2*zDist*math.abs(tileA.z-tileB.z))//2)
    end
end
local tileDist = gen.tileDist

-- distance(tileUnitCityA,tileUnitCityB,zDist=0)-->integer
-- gen.distance(tileUnitCityA,tileUnitCityB,zDist=0)-->integer

-- returns the distance (1-norm, not Euclidean) (in terms of tiles, not coordinates) between 
-- objects A and B, that have a natural location (also converts doubles and triples of tables)

-- Takes two objects and a 'vertical distance' (0 if absent)
-- and computes the distance between them.  
-- zDist is the number of tiles that one unit of z coordinate "distance" is equivalent to
-- Computes the distance you would get by counting tiles.
-- If you want the game's approximation of "Euclidean" distance that
-- is used in many game mechanics, use gen.gameMechanicDistance
---@param itemA tileAnalog|unitObject|cityObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>cityObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param itemB tileAnalog|unitObject|cityObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>cityObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param zDist? integer The distance between tiles with same x,y coordinates but differing in z by 1. 0 by default.
---@return integer
function gen.distance(itemA,itemB,zDist)
    zDist = zDist or 0
    local locA = nil
    local locB = nil
    if type(itemA)=="table" then
        locA=toTile(itemA)
    elseif civ.isUnit(itemA) or civ.isCity(itemA) then
        locA=itemA.location
    elseif civ.isTile(itemA) then
        locA = itemA
    else
        error("gen.distance: first argument must be a tile (or coordinates of a tile), or a unit or a city. Received: "..tostring(itemA))
    end
    if type(itemB)=="table" then
        locB=toTile(itemB)
    elseif civ.isUnit(itemB) or civ.isCity(itemB) then
        locB=itemB.location
    elseif civ.isTile(itemB) then
        locB = itemB
    else
        error("gen.distance: second argument must be a tile (or coordinates of a tile), or a unit or a city. Received: "..tostring(itemB))
    end
    if civ.game.rules.flatWorld then
        return (math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2
    else
        local xMax,yMax,zMax=civ.getAtlasDimensions()
        return math.min((math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2,
            (xMax-math.abs(locA.x-locB.x)+math.abs(locA.y-locB.y)+2*zDist*math.abs(locA.z-locB.z))//2)
    end
end
local distance = gen.distance


-- gen.gameMechanicDistance(itemOnMap1,itemOnMap2)
--  provides a distance measure that is believed to be used
--  for internal distance calculations (such as caravan payments
--  or city corruption)
--  This distance is scaled to match the "Communism Palace Distance",
--  (based on the corruption work by Knighttime)
--  Diagonal movement is "1" distance, corner to corner is 1.5 (rounded down)
---@param itemA tileAnalog|unitObject|cityObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>cityObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param itemB tileAnalog|unitObject|cityObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>cityObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return integer
function gen.gameMechanicDistance(itemA,itemB)
    local locA = nil
    local locB = nil
    if type(itemA)=="table" then
        locA=toTile(itemA)
    elseif civ.isUnit(itemA) or civ.isCity(itemA) then
        locA=itemA.location
    elseif civ.isTile(itemA) then
        locA = itemA
    else
        error("gen.gameMechanicDistance: first argument must be a tile (or coordinates of a tile), or a unit or a city.")
    end
    if type(itemB)=="table" then
        locB=toTile(itemB)
    elseif civ.isUnit(itemB) or civ.isCity(itemB) then
        locB=itemB.location
    elseif civ.isTile(itemB) then
        locB = itemB
    else
        error("gen.gameMechanicDistance: second argument must be a tile (or coordinates of a tile), or a unit or a city.")
    end
    local xMax,yMax,zMax=civ.getAtlasDimensions()
    local xDiff = nil
    if civ.game.rules.flatWorld then
        xDiff = math.abs(locA.x-locB.x)
    else
        xDiff = math.min(math.abs(locA.x-locB.x),xMax-math.abs(locA.x-locB.x))
    end
    local yDiff = math.abs(locA.y-locB.y)
    local dist = math.floor(math.min(xDiff,yDiff)+(math.abs(xDiff-yDiff)*0.5*1.5))
    return dist
end



-- gen.hasIrrigation(tile)-->boolean

-- Returns true if tile has irrigation but no farm.
-- Returns false otherwise.
-- If you need to know if a tile has irrigation or farmland,
-- use gen.hasAgriculture(tile)
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasIrrigation(tile)
    tile = toTile(tile)
    local improvements = tile.improvements
    -- irrigation, but no mining, so not farmland
    return improvements & 0x04 == 0x04 and improvements & 0x08 == 0 
end

-- gen.placeIrrigation(tile)-->void

-- places irrigation on the tile provided
-- removes mines and farmland if present
-- does nothing if tile has a city
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeIrrigation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    end
    -- Set irrigation bit to 1
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements | 0x04
    -- Set mining bit to 0
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x08
end

-- gen.removeIrrigation(tile)-->void

-- If tile has irrigation but no farmland, removes the irrigation
-- Does nothing to farmland
-- Does nothing if tile has a city
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeIrrigation(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.city or tile.improvements & 0x0C == 0x0C then
        return
    end
    -- set irrigation bit to 0
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x04
end

-- gen.hasMine(tile)-->boolean

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasMine(tile) 
    tile = toTile(tile)
    local improvements = tile.improvements
    -- mining, but no irrigation, so not farmland
    return improvements & 0x08 == 0x08 and improvements & 0x04 == 0 
end

-- gen.placeMine(tile)-->void

-- places mines on the tile provided
-- removes irrigation and farmland if present
-- does nothing if tile has city
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeMine(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    -- set mining bit to 1
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements | 0x08
    -- set irrigation bit to 0
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x04
end

-- gen.placeMineUnderCity(tile) --> void

-- places mine on a tile, even if a city is present
-- removes irrigation and farmland if present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeMineUnderCity(tile)
    tile = toTile(tile)
    -- set mining bit to 1
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements | 0x08
    -- set irrigation bit to 0
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x04
end

-- gen.removeMine(tile)-->void

-- if tile has mining but no farmland, removes mines
-- does nothing to farmland
-- does nothing if tile has a city
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeMine(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.city or tile.improvements & 0x0C == 0x0C then
        return
    end
    -- set irrigation bit to 0
---@diagnostic disable-next-line: assign-type-mismatch
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x08
end

-- gen.removeMineUnderCity(tile)-->void

-- if tile has mining but no farmland, removes mines
-- does nothing to farmland
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeMineUnderCity(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.improvements & 0x0C == 0x0C then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch, assign-type-mismatch
    -- set mining bit to 0
---@diagnostic disable-next-line: assign-type-mismatch
---@diagnostic disable-next-line: assign-type-mismatch
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x08

end
-- gen.hasFarmland(tile)-->boolean

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasFarmland(tile)
    tile = toTile(tile)
    return tile.improvements & 0x0C == 0x0C
end

-- gen.placeFarmland(tile)-->void

-- places farmland on a tile (removing mining)
-- does nothing if a city is present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeFarmland(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements | 0x0C
end

-- gen.removeFarmland(tile)-->void

-- removes farmland if present
-- does nothing to irrigation or mining
-- does nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeFarmland(tile) 
    tile = toTile(tile)
    if (not tile.city) and (tile.improvements & 0x0C == 0x0C) then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = tile.improvements & ~0x0C
    end
end

-- gen.hasAgriculture(tile)-->bool

-- returns true if tile has irrigation or farmland
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasAgriculture(tile)
    tile = toTile(tile)
    return tile.improvements & 0x04 == 0x04
end

-- gen.improveAgriculture(tile) --> void

-- if tile has no irrigation, place irrigation (even if mining present)
-- if tile has irrigation, place farmland
-- if city do nothing
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.improveAgriculture(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasIrrigation(tile) then
        gen.placeFarmland(tile)
        return
    else
        gen.placeIrrigation(tile)
        return
    end
end

-- gen.degradeAgriculture(tile) --> void

-- if tile has farmland, reduce to irrigation
-- if tile has irrigation, remove
-- does nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.degradeAgriculture(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasFarmland(tile) then
        gen.placeIrrigation(tile)
        return
    else
        gen.removeIrrigation(tile)
    end
end

-- gen.removeAgriculture(tile) --> void

-- remove farmland and irrigation if present
-- do nothing to mining
-- do nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeAgriculture(tile)
    tile = toTile(tile)
    if (not tile.city) and gen.hasAgriculture(tile) then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = tile.improvements & ~0x0C
    end
end


-- gen.hasRoad(tile)-->boolean

-- returns true if tile has a road
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasRoad(tile) 
    tile = toTile(tile)
    return tile.improvements & 0x10 == 0x10 
end

-- gen.placeRoad(tile)-->void

-- places a road on the tile
-- does nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeRoad(tile) 
    tile=toTile(tile)
    if tile.city then 
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements | 0x10
end

-- gen.removeRoad(tile)-->void

-- removes a road if there is a road but no rail
-- doesn't touch rail or cities
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeRoad(tile)
    tile = toTile(tile)
    if tile.city or (tile.improvements & 0x30 == 0x30) then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements & ~0x10
end

-- gen.hasRailroad(tile)-->boolean

-- returns true if a tile has a railroad (and road)
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasRailroad(tile) 
    tile = toTile(tile)
    return tile.improvements & 0x30 == 0x30 

end

-- gen.placeRailroad(tile)-->void

-- places a railroad (and road) on a tile
-- does nothing if city is present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeRailroad(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = tile.improvements | 0x30
end

-- gen.removeRailroad(tile)-->void

-- removes railroad from a tile if it exits,
-- leaving road intact (if there is already road there)
-- does nothing if a city is present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeRailroad(tile) 
    tile = toTile(tile)
    if (tile.improvements & 0x30 == 0x30) and (not tile.city) then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = tile.improvements & ~0x20
    end
end
-- gen.hasTransportation(tile) --> boolean

-- returns true if tile has road or rail 
-- (but not if city, unless an event has placed a road)
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasTransportation(tile)
    tile = toTile(tile)
    return tile.improvements & 0x10 == 0x10 
end


-- gen.upgradeTransportation(tile) --> void

-- places railroad if road exists, otherwise places road
-- does nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.upgradeTransportation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasRoad(tile) then
        gen.placeRailroad(tile)
        return
    else
        gen.placeRoad(tile)
        return
    end
end

-- gen.degradeTransportation(tile) --> void

-- reduces railroad to road, if rail exists
-- if no rail but road, removes road
-- if no transportation, does nothing
-- if city does nothing
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.degradeTransportation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    elseif gen.hasRailroad(tile) then
        gen.removeRailroad(tile)
    else
        gen.removeRoad(tile)
    end
end

-- gen.removeTransportation(tile) -->void


-- removes road and rail, if it exists
-- does nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeTransportation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    else
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = tile.improvements & ~0x30
    end
end

-- gen.hasFortress(tile)-->boolean

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasFortress(tile)

    tile = toTile(tile)
    -- must be fortress, and not airbase
    return checkBits(tile.improvements,"x1xxxx0x")
end

-- gen.placeFortress(tile)-->void

-- places a fortress on a square, unless
-- there is already a city, transporter, or airbase on the tile
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeFortress(tile)
    tile = toTile(tile)
    if tile.city or isBit1(tile.improvements,2) then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = setBits(tile.improvements,"x1xxxx0x")
end

-- gen.placeFortressForce(tile)-->void

-- places fortress (replacing airbase/transporter if necessary)
-- If city on tile, nothing happens
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeFortressForce(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = setBits(tile.improvements,"x1xxxx0x")
    return
end

-- gen.removeFortress(tile)-->void

-- Checks that a fortress is in place (so as not to change
-- other terrain improvements), and if so, removes the fortress
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeFortress(tile) 
    tile = toTile(tile)
    if checkBits(tile.improvements,"x1xxxx0x") then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = setBit0(tile.improvements,7)
    end
end

-- gen.hasAirbase(tile)-->boolean

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasAirbase(tile) 
    tile = toTile(tile)
    return checkBits(tile.improvements,"x1xxxx1x")
end

-- gen.placeAirbase(tile)--> void

-- places an airbase on a tile as long as there is not already
-- pollution, fortress, or transporter on the tile
-- does nothing if city present
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeAirbase(tile)
    tile = toTile(tile)
    local tileImprovements = tile.improvements
    if tile.city or isBit1(tileImprovements,7) or isBit1(tileImprovements,8) then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = setBits(tile.improvements,"x1xxxx1x")
end

-- gen.placeAirbaseForce(tile)-->void

-- places airbase, removing fortress/transporter/pollution if necessary
-- if city on tile, nothing happens
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placeAirbaseForce(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = setBits(tile.improvements,"01xxxx1x")
end

-- gen.removeAirbase(tile)-->void

-- removes airbase, if one is on tile
-- (so that something else doesn't get removed)
-- nothing happens if tile is a city
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeAirbase(tile) 
    tile = toTile(tile)
    if checkBits(tile.improvements,"x1xxxx1x") and (not tile.city) then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = setBits(tile.improvements,"00xxxx0x")
    end
end

-- gen.hasPollution(tile)-->boolean

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasPollution(tile) 
    tile = toTile(tile)
    return checkBits(tile.improvements,"1xxxxx0x")

end

-- gen.placePollution(tile)-->void

-- places pollution, unless the tile has a city, airbase
-- or transporter already on the tile
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placePollution(tile) 
    tile = toTile(tile)
    if tile.city or isBit1(tile.improvements,2) then
        return
    end
---@diagnostic disable-next-line: assign-type-mismatch
    tile.improvements = setBits(tile.improvements,"1xxxxx0x")
end

-- gen.placePollutionForce(tile)-->void

-- places pollution, unless the tile has a city, 
-- transporters and airbases are removed
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.placePollutionForce(tile) 
    tile = toTile(tile)
    if tile.city then
        return
    end
    if gen.hasFortress(tile) then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = setBits(tile.improvements,"11xxxx0x")
    else
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = setBits(tile.improvements,"1xxxxx0x")
    end
end
-- gen.removePollution(tile)-->void

-- checks if tile has pollution, and if so, removes it
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removePollution(tile) 
    tile = toTile(tile)
    if checkBits(tile.improvements,"1xxxxx0x") then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = setBit0(tile.improvements,8)
    end
end

-- gen.hasTransporter(tile)-->boolean

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return boolean
function gen.hasTransporter(tile) 
    tile = toTile(tile)
    return checkBits(tile.improvements,"1xxxxx1x")
end

-- Placing transporters doesn't work.
-- This function simply produces an error.
-- (This function exists mainly to show this functionality wasn't overlooked.)
---@deprecated
function gen.placeTransporter(tile) 
    error("gen.placeTransporter: transporters can't be placed with Lua.  This function exists so that you know it wasn't overlooked.")
end


-- gen.removeTransporter(tile)-->void

---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
function gen.removeTransporter(tile) 
    tile = toTile(tile)
    if (not tile.city) and checkBits(tile.improvements,"1xxxxx1x") then
---@diagnostic disable-next-line: assign-type-mismatch
        tile.improvements = setBits(tile.improvements,"0xxxxx0x")
        return
    end
end

-- gen.setTerrainType(tile,terrainID)-->void

-- changes the terrain type of tile to terrainID
-- have this function, so that if
-- terrainType key functionality is changed, this
-- function can change instead of all code everywhere
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param terrainID integer the id (0-15) of the new baseTerrain type
function gen.setTerrainType(tile,terrainID)
    tile = toTile(tile)
    tile.baseTerrain = civ.getBaseTerrain(tile.z,terrainID)
    --tile.terrainType = terrainID
end
--

-- gen.isFortifying(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isFortifying(unit) 
    return unit.order == 0x01
end

-- gen.setToFortifying(unit)-->void

---@param unit unitObject
function gen.setToFortifying(unit) 
    unit.order = 0x01
end

-- gen.isFortified(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isFortified(unit) 
    return unit.order == 0x02
end

-- gen.setToFortified(unit)-->void

---@param unit unitObject
function gen.setToFortified(unit) 
    unit.order = 0x02
end

-- gen.isSleeping(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isSleeping(unit) 
    return unit.order == 0x03
end

-- gen.setToSleeping(unit)-->void

---@param unit unitObject
function gen.setToSleeping(unit) 
    unit.order = 0x03
end
--
-- gen.isBuildingFortress(unit) --> boolean

---@param unit unitObject
---@return boolean
function gen.isBuildingFortress(unit)
    return unit.order == 0x04
end


-- gen.setToBuildingFortress(unit)-->void

---@param unit unitObject
function gen.setToBuildingFortress(unit) 
    unit.order = 0x04
end
--
-- gen.isBuildingRoad(unit) --> boolean

---@param unit unitObject
---@return boolean
function gen.isBuildingRoad(unit)
    return unit.order == 0x05
end

-- gen.setToBuildingRoad(unit)-->void

---@param unit unitObject
function gen.setToBuildingRoad(unit) 
    unit.order = 0x05
end


-- gen.isIrrigating(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isIrrigating(unit) 
    return unit.order == 0x06
end

-- gen.setToIrrigating(unit)-->void

---@param unit unitObject
function gen.setToIrrigating(unit) 
    unit.order = 0x06
end

-- gen.isMining(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isMining(unit) 
    return unit.order == 0x07
end

-- gen.setToMining(unit)-->void

---@param unit unitObject
function gen.setToMining(unit) 
    unit.order = 0x07
end

-- gen.isTransformingTerrain(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isTransformingTerrain(unit) 
    return unit.order == 0x08
end

-- gen.setToTransformingTerrain(unit)-->void

---@param unit unitObject
function gen.setToTransformingTerrain(unit) 
    unit.order = 0x08
end

-- gen.isCleaningPollution(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isCleaningPollution(unit) 
    return unit.order == 0x09
end

-- gen.setToCleaningPollution(unit)-->void

---@param unit unitObject
function gen.setToCleaningPollution(unit) 
    unit.order = 0x09
end
-- gen.isBuildingAirbase(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isBuildingAirbase(unit) 
    return unit.order == 0x0A
end

-- gen.setToBuildingAirbase(unit)-->void

---@param unit unitObject
function gen.setToBuildingAirbase(unit) 
    unit.order = 0x0a
end

-- gen.isBuildingTransporter(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isBuildingTransporter(unit) 
    return unit.order == 0x0B
end

-- gen.setToBuildingTransporter(unit)-->void

---@param unit unitObject
function gen.setToBuildingTransporter(unit) 
    unit.order = 0x0B
end

-- gen.isGoingTo(unit)-->boolean

-- Returns true if the unit has a goto order, and false otherwise.
---@param unit unitObject
---@return boolean
function gen.isGoingTo(unit)
    return not not unit.gotoTile
end

-- gen.setToGoingTo(unit,tile or nil)-->void

-- gives the unit a goto order for the tile
-- if nil is submitted, and the unit already
-- has a goto order, the unit will be changed to no orders
-- (unit.gotoTile=nil results in an error)
-- if the unit has some other order, it will keep that order
-- note: this also accepts a table of coordinates as a tile
-- (just as all other tile functions do here)
---@param unit unitObject
---@param tile tileAnalog|nil if table, the table must be a tile of coordinates
function gen.setToGoingTo(unit,tile) 
    if tile == nil and unit.gotoTile then
        unit.order = 0xFF
        return
    elseif tile == nil then
        return
    end
    tile = toTile(tile)
    unit.gotoTile = tile
end

-- gen.isNoOrder(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isNoOrder(unit) 
    return unit.order == -1 --0xFF
end

-- gen.setToNoOrders(unit)-->void

---@param unit unitObject
function gen.setToNoOrders(unit) 
    unit.order = 0xFF
end

-- gen.isWaiting(unit)-->bool

---@param unit unitObject
---@return boolean
function gen.isWaiting(unit)
    return unit.attributes & 0x4000 == 0x4000
end
-- gen.setToWaiting(unit)-->void

---@param unit unitObject
function gen.setToWaiting(unit)
---@diagnostic disable-next-line: assign-type-mismatch
    unit.attributes = unit.attributes | 0x4000
end
-- gen.clearWaiting(unit)-->void

---@param unit unitObject
function gen.clearWaiting(unit)
---@diagnostic disable-next-line: assign-type-mismatch
    unit.attributes = unit.attributes & ~0x4000
end
-- gen.isParadropped(unit)-->boolean

---@param unit unitObject
---@return boolean
function gen.isParadropped(unit)
    return isBit1(unit.attributes,5)
end
-- gen.setParadropped(unit)-->void

---@param unit unitObject
function gen.setParadropped(unit)
    unit.attributes = setBit1(unit.attributes,5)
end
-- gen.clearParadropped(unit)-->void

---@param unit unitObject
function gen.clearParadropped(unit)
    unit.attributes = setBit0(unit.attributes,5)
end
-- gen.isMoved(unit)-->boolean

-- The game sets this flag when a unit moves (even if no movement points are spent).  The Unit won't heal on next turn if this flag is set.
---@param unit unitObject
---@return boolean
function gen.isMoved(unit)
    return isBit1(unit.attributes,7)
end
-- gen.setMoved(unit)-->void

-- The game sets this flag when a unit moves (even if no movement points are spent).  The Unit won't heal on next turn if this flag is set.
---@param unit unitObject
function gen.setMoved(unit)
    unit.attributes = setBit1(unit.attributes,7)
end
-- gen.clearMoved(unit)-->void

-- The game sets this flag when a unit moves (even if no movement points are spent).  The Unit won't heal on next turn if this flag is set.
---@param unit unitObject
function gen.clearMoved(unit)
    unit.attributes = setBit0(unit.attributes,7)
end


-- gen.isSeeTwoSpaces(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isSeeTwoSpaces(unitType) 
    return isBit1(unitType.flags,1)
end

-- gen.giveSeeTwoSpaces(unitType)-->void

---@param unitType unitTypeObject
function gen.giveSeeTwoSpaces(unitType) 
    unitType.flags = setBit1(unitType.flags,1)
end

-- gen.removeSeeTwoSpaces(unitType)-->void

---@param unitType unitTypeObject
function gen.removeSeeTwoSpaces(unitType) 
    unitType.flags = setBit0(unitType.flags,1)
end
-- Note: The typo is preserved, on the off chance that
-- someone used it
gen.removeSeeTowSpaces = gen.removeSeeTwoSpaces 

-- gen.isIgnoreZOC(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isIgnoreZOC(unitType) 
    return isBit1(unitType.flags,2)
end

-- gen.giveIgnoreZOC(unitType)-->void

---@param unitType unitTypeObject
function gen.giveIgnoreZOC(unitType) 
    unitType.flags = setBit1(unitType.flags,2)
end

-- gen.removeIgnoreZOC(unitType)-->void

---@param unitType unitTypeObject
function gen.removeIgnoreZOC(unitType) 
    unitType.flags = setBit0(unitType.flags,2)
end

-- gen.isAmphibious(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isAmphibious(unitType) 
    return isBit1(unitType.flags,3)
end

-- gen.giveAmphibious(unitType)-->void

---@param unitType unitTypeObject
function gen.giveAmphibious(unitType) 
    unitType.flags = setBit1(unitType.flags,3)
end
gen.giveAmpibious = gen.giveAmphibious -- backwards compatibility typo

-- gen.removeAmphibious(unitType)-->void

---@param unitType unitTypeObject
function gen.removeAmphibious(unitType) 
    unitType.flags = setBit0(unitType.flags,3)
end

-- gen.isSubmarine(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isSubmarine(unitType) 
    return isBit1(unitType.flags,4)
end

-- gen.giveSubmarine(unitType)-->void

---@param unitType unitTypeObject
function gen.giveSubmarine(unitType)
   unitType.flags = setBit1(unitType.flags,4)
end

-- gen.removeSubmarine(unitType)-->void

---@param unitType unitTypeObject
function gen.removeSubmarine(unitType) 
    unitType.flags = setBit0(unitType.flags,4)
end

-- gen.isAttackAir(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isAttackAir(unitType) 
    return isBit1(unitType.flags,5)
end

-- gen.giveAttackAir(unitType)-->void

---@param unitType unitTypeObject
function gen.giveAttackAir(unitType) 
    unitType.flags = setBit1(unitType.flags,5)
end

-- gen.removeAttackAir(unitType)-->void

---@param unitType unitTypeObject
function gen.removeAttackAir(unitType) 
    unitType.flags = setBit0(unitType.flags,5)
end

-- gen.isCoastal(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isCoastal(unitType) 
    return isBit1(unitType.flags,6)
end

-- gen.giveCoastal(unitType)-->void

---@param unitType unitTypeObject
function gen.giveCoastal(unitType) 
    unitType.flags = setBit1(unitType.flags,6)
end

-- gen.removeCoastal(unitType)-->void

---@param unitType unitTypeObject
function gen.removeCoastal(unitType) 
    unitType.flags = setBit0(unitType.flags,6)
end

-- gen.isIgnoreWalls(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isIgnoreWalls(unitType) 
    return isBit1(unitType.flags,7)
end

-- gen.giveIgnoreWalls(unitType)-->void

---@param unitType unitTypeObject
function gen.giveIgnoreWalls(unitType) 
    unitType.flags = setBit1(unitType.flags,7)
end
gen.giveIngoreWalls = gen.giveIgnoreWalls

-- gen.removeIgnoreWalls(unitType)-->void

---@param unitType unitTypeObject
function gen.removeIgnoreWalls(unitType) 
    unitType.flags = setBit0(unitType.flags,7)
end

-- gen.isCarryAir(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
 function gen.isCarryAir(unitType) 
    return isBit1(unitType.flags,8)
end

-- gen.giveCarryAir(unitType)-->void

---@param unitType unitTypeObject
function gen.giveCarryAir(unitType) 
    unitType.flags = setBit1(unitType.flags,8)
end

-- gen.removeCarryAir(unitType)-->void

---@param unitType unitTypeObject
function gen.removeCarryAir(unitType) 
    unitType.flags = setBit0(unitType.flags,8)
end

-- gen.isParadrop(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isParadrop(unitType) 
    return isBit1(unitType.flags,9)
end

-- gen.giveParadrop(unitType)-->void

---@param unitType unitTypeObject
function gen.giveParadrop(unitType) 
    unitType.flags = setBit1(unitType.flags,9)
end

-- gen.removeParadrop(unitType)-->void

---@param unitType unitTypeObject
function gen.removeParadrop(unitType) 
    unitType.flags = setBit0(unitType.flags,9)
end

-- gen.isAlpine(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isAlpine(unitType) 
    return isBit1(unitType.flags,10)
end

-- gen.giveAlpine(unitType)-->void

---@param unitType unitTypeObject
function gen.giveAlpine(unitType) 
    unitType.flags = setBit1(unitType.flags,10)
end

-- gen.removeAlpine(unitType)-->void

---@param unitType unitTypeObject
function gen.removeAlpine(unitType) 
    unitType.flags = setBit0(unitType.flags,10)
end

-- gen.isBonusAgainstHorse(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isBonusAgainstHorse(unitType) 
    return isBit1(unitType.flags,11)
end

-- gen.giveBonusAgainstHorse(unitType)-->void

---@param unitType unitTypeObject
function gen.giveBonusAgainstHorse(unitType) 
    unitType.flags = setBit1(unitType.flags,11)
end

-- gen.removeBonusAgainstHorse(unitType)-->void

---@param unitType unitTypeObject
function gen.removeBonusAgainstHorse(unitType) 
    unitType.flags = setBit0(unitType.flags,11)
end

-- gen.isFreeSupportUnderFundamentalism(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isFreeSupportUnderFundamentalism(unitType) 
    return isBit1(unitType.flags,12)
end

-- gen.giveFreeSupportUnderFundamentalism(unitType)-->void

---@param unitType unitTypeObject
function gen.giveFreeSupportUnderFundamentalism(unitType) 
    unitType.flags = setBit1(unitType.flags,12)
end

-- gen.removeFreeSupportUnderFundamentalism(unitType)-->void

---@param unitType unitTypeObject
function gen.removeFreeSupportUnderFundamentalism(unitType) 
    unitType.flags = setBit0(unitType.flags,12)
end

-- gen.isDestroyedAfterAttacking(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isDestroyedAfterAttacking(unitType) 
    return isBit1(unitType.flags,13)
end

-- gen.giveDestroyedAfterAttacking(unitType)-->void

---@param unitType unitTypeObject
function gen.giveDestroyedAfterAttacking(unitType) 
    unitType.flags = setBit1(unitType.flags,13)
end

-- gen.removeDestroyedAfterAttacking(unitType)-->void

---@param unitType unitTypeObject
function gen.removeDestroyedAfterAttacking(unitType) 
    unitType.flags = setBit0(unitType.flags,13)
end

-- gen.isBonusAgainstAir(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isBonusAgainstAir(unitType) 
    return isBit1(unitType.flags,14)
end

-- gen.giveBonusAgainstAir(unitType)-->void

---@param unitType unitTypeObject
function gen.giveBonusAgainstAir(unitType) 
    unitType.flags = setBit1(unitType.flags,14)
end

-- gen.removeBonusAgainstAir(unitType)-->void

---@param unitType unitTypeObject
function gen.removeBonusAgainstAir(unitType) 
    unitType.flags = setBit0(unitType.flags,14)
end

-- gen.isSpotSubmarines(unitType)-->boolean

---@param unitType unitTypeObject
---@return boolean
function gen.isSpotSubmarines(unitType) 
    return isBit1(unitType.flags,15)
end

-- gen.giveSpotSubmarines(unitType)-->void

---@param unitType unitTypeObject
function gen.giveSpotSubmarines(unitType) 
    unitType.flags = setBit1(unitType.flags,15)
end

-- gen.removeSpotSubmarines(unitType)-->void

---@param unitType unitTypeObject
function gen.removeSpotSubmarines(unitType) 
    unitType.flags = setBit0(unitType.flags,15)
end


-- gen.isCivilDisorder(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isCivilDisorder(city)
	return isBit1(city.attributes,1)
end

-- gen.setCivilDisorder(city)-->void

---@param city cityObject
function gen.setCivilDisorder(city)
	 city.attributes = setBit1(city.attributes,1)
end

-- gen.clearCivilDisorder(city)-->void

---@param city cityObject
function gen.clearCivilDisorder(city)
	 city.attributes = setBit0(city.attributes,1)
end

-- gen.isWeLoveTheKing(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isWeLoveTheKing(city)
	return isBit1(city.attributes,2)
end

-- gen.setWeLoveTheKing(city)-->void

---@param city cityObject
function gen.setWeLoveTheKing(city)
	 city.attributes = setBit1(city.attributes,2)
end

-- gen.clearWeLoveTheKing(city)-->void

---@param city cityObject
function gen.clearWeLoveTheKing(city)
	 city.attributes = setBit0(city.attributes,2)
end

-- gen.isImprovementSold(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isImprovementSold(city)
	return isBit1(city.attributes,3)
end

-- gen.setImprovementSold(city)-->void

---@param city cityObject
function gen.setImprovementSold(city)
	 city.attributes = setBit1(city.attributes,3)
end

-- gen.clearImprovementSold(city)-->void

---@param city cityObject
function gen.clearImprovementSold(city)
	 city.attributes = setBit0(city.attributes,3)
end

-- gen.isTechnologyStolen(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isTechnologyStolen(city)
	return isBit1(city.attributes,4)
end

-- gen.setTechnologyStolen(city)-->void

---@param city cityObject
function gen.setTechnologyStolen(city)
	 city.attributes = setBit1(city.attributes,4)
end

-- gen.clearTechnologyStolen(city)-->void

---@param city cityObject
function gen.clearTechnologyStolen(city)
	 city.attributes = setBit0(city.attributes,4)
end

-- gen.isAutoBuild(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isAutoBuild(city)
	return isBit1(city.attributes,5)
end

-- gen.setAutoBuild(city)-->void

---@param city cityObject
function gen.setAutoBuild(city)
	 city.attributes = setBit1(city.attributes,5)
end

-- gen.clearAutoBuild(city)-->void

---@param city cityObject
function gen.clearAutoBuild(city)
	 city.attributes = setBit0(city.attributes,5)
end


-- gen.isAttribute6(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute6(city)
	return isBit1(city.attributes,6)
end

-- gen.setAttribute6(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute6(city)
	 city.attributes = setBit1(city.attributes,6)
end

-- gen.clearAttribute6(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute6(city)
	 city.attributes = setBit0(city.attributes,6)
end

-- gen.isAttribute7(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute7(city)
	return isBit1(city.attributes,7)
end

-- gen.setAttribute7(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute7(city)
	 city.attributes = setBit1(city.attributes,7)
end

-- gen.clearAttribute7(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute7(city)
	 city.attributes = setBit0(city.attributes,7)
end

-- gen.isBuildCoastal(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isBuildCoastal(city)
	return isBit1(city.attributes,8)
end

-- gen.setBuildCoastal(city)-->void

---@param city cityObject
function gen.setBuildCoastal(city)
	 city.attributes = setBit1(city.attributes,8)
end

-- gen.clearBuildCoastal(city)-->void

---@param city cityObject
function gen.clearBuildCoastal(city)
	 city.attributes = setBit0(city.attributes,8)
end

-- gen.isAttribute9(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute9(city)
	return isBit1(city.attributes,9)
end

-- gen.setAttribute9(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute9(city)
	 city.attributes = setBit1(city.attributes,9)
end

-- gen.clearAttribute9(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute9(city)
	 city.attributes = setBit0(city.attributes,9)
end

-- gen.isAttribute10(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute10(city)
	return isBit1(city.attributes,10)
end

-- gen.setAttribute10(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute10(city)
	 city.attributes = setBit1(city.attributes,10)
end

-- gen.clearAttribute10(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute10(city)
	 city.attributes = setBit0(city.attributes,10)
end

-- gen.isAttribute11(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute11(city)
	return isBit1(city.attributes,11)
end

-- gen.setAttribute11(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute11(city)
	 city.attributes = setBit1(city.attributes,11)
end

-- gen.clearAttribute11(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute11(city)
	 city.attributes = setBit0(city.attributes,11)
end

-- gen.isBuildHydroPlant(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isBuildHydroPlant(city)
	return isBit1(city.attributes,12)
end

-- gen.setBuildHydroPlant(city)-->void

---@param city cityObject
function gen.setBuildHydroPlant(city)
	 city.attributes = setBit1(city.attributes,12)
end

-- gen.clearBuildHydroPlant(city)-->void

---@param city cityObject
function gen.clearBuildHydroPlant(city)
	 city.attributes = setBit0(city.attributes,12)
end

-- gen.isAttribute13(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute13(city)
	return isBit1(city.attributes,13)
end

-- gen.setAttribute13(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute13(city)
	 city.attributes = setBit1(city.attributes,13)
end

-- gen.clearAttribute13(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute13(city)
	 city.attributes = setBit0(city.attributes,13)
end

-- gen.isAttribute14(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute14(city)
	return isBit1(city.attributes,14)
end

-- gen.setAttribute14(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute14(city)
	 city.attributes = setBit1(city.attributes,14)
end

-- gen.clearAttribute14(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute14(city)
	 city.attributes = setBit0(city.attributes,14)
end

-- gen.isAttribute15(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute15(city)
	return isBit1(city.attributes,15)
end

-- gen.setAttribute15(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute15(city)
	 city.attributes = setBit1(city.attributes,15)
end

-- gen.clearAttribute15(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute15(city)
	 city.attributes = setBit0(city.attributes,15)
end

-- gen.isAttribute16(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute16(city)
	return isBit1(city.attributes,16)
end

-- gen.setAttribute16(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute16(city)
	 city.attributes = setBit1(city.attributes,16)
end

-- gen.clearAttribute16(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute16(city)
	 city.attributes = setBit0(city.attributes,16)
end

-- gen.isUsedAirport(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isUsedAirport(city)
	return isBit1(city.attributes,17)
end

-- gen.setUsedAirport(city)-->void

---@param city cityObject
function gen.setUsedAirport(city)
	 city.attributes = setBit1(city.attributes,17)
end

-- gen.clearUsedAirport(city)-->void

---@param city cityObject
function gen.clearUsedAirport(city)
	 city.attributes = setBit0(city.attributes,17)
end
gen.isAttribute17 = gen.isUsedAirport
gen.setAttribute17 = gen.setUsedAirport
gen.clearAttribute17 = gen.clearUsedAirport

-- gen.isAttribute18(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute18(city)
	return isBit1(city.attributes,18)
end

-- gen.setAttribute18(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute18(city)
	 city.attributes = setBit1(city.attributes,18)
end

-- gen.clearAttribute18(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute18(city)
	 city.attributes = setBit0(city.attributes,18)
end

-- gen.isAttribute19(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute19(city)
	return isBit1(city.attributes,19)
end

-- gen.setAttribute19(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute19(city)
	 city.attributes = setBit1(city.attributes,19)
end

-- gen.clearAttribute19(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute19(city)
	 city.attributes = setBit0(city.attributes,19)
end

-- gen.isAttribute20(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute20(city)
	return isBit1(city.attributes,20)
end

-- gen.setAttribute20(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute20(city)
	 city.attributes = setBit1(city.attributes,20)
end

-- gen.clearAttribute20(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute20(city)
	 city.attributes = setBit0(city.attributes,20)
end

-- gen.isAttribute21(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute21(city)
	return isBit1(city.attributes,21)
end

-- gen.setAttribute21(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute21(city)
	 city.attributes = setBit1(city.attributes,21)
end

-- gen.clearAttribute21(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute21(city)
	 city.attributes = setBit0(city.attributes,21)
end

-- gen.isBuildShips(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isBuildShips(city)
	return isBit1(city.attributes,22)
end

-- gen.setBuildShips(city)-->void

---@param city cityObject
function gen.setBuildShips(city)
	 city.attributes = setBit1(city.attributes,22)
end

-- gen.clearBuildShips(city)-->void

---@param city cityObject
function gen.clearBuildShips(city)
	 city.attributes = setBit0(city.attributes,22)
end

-- gen.isCityInvestigated(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isCityInvestigated(city)
	return isBit1(city.attributes,23)
end

-- gen.setCityInvestigated(city)-->void

---@param city cityObject
function gen.setCityInvestigated(city)
	 city.attributes = setBit1(city.attributes,23)
end

-- gen.clearCityInvestigated(city)-->void

---@param city cityObject
function gen.clearCityInvestigated(city)
	 city.attributes = setBit0(city.attributes,23)
end
gen.isAttribute23 = gen.isCityInvestigated
gen.setAttribute23 = gen.setCityInvestigated
gen.clearAttribute23 = gen.clearCityInvestigated

-- gen.isAttribute24(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute24(city)
	return isBit1(city.attributes,24)
end


-- gen.setAttribute24(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute24(city)
	 city.attributes = setBit1(city.attributes,24)
end

-- gen.clearAttribute24(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute24(city)
	 city.attributes = setBit0(city.attributes,24)
end

-- gen.isMilitaryAutoBuild(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isMilitaryAutoBuild(city)
	return isBit1(city.attributes,25)
end

-- gen.setMilitaryAutoBuild(city)-->void

---@param city cityObject
function gen.setMilitaryAutoBuild(city)
	 city.attributes = setBit1(city.attributes,25)
end

-- gen.clearMilitaryAutoBuild(city)-->void

---@param city cityObject
function gen.clearMilitaryAutoBuild(city)
	 city.attributes = setBit0(city.attributes,25)
end

-- gen.isDomesticAutoBuild(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isDomesticAutoBuild(city)
	return isBit1(city.attributes,26)
end

-- gen.setDomesticAutoBuild(city)-->void

---@param city cityObject
function gen.setDomesticAutoBuild(city)
	 city.attributes = setBit1(city.attributes,26)
end

-- gen.clearDomesticAutoBuild(city)-->void

---@param city cityObject
function gen.clearDomesticAutoBuild(city)
	 city.attributes = setBit0(city.attributes,26)
end

-- gen.isObjective(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isObjective(city)
	return isBit1(city.attributes,27)
end

-- gen.setObjective(city)-->void

---@param city cityObject
function gen.setObjective(city)
	 city.attributes = setBit1(city.attributes,27)
     -- objective flag overrides major objective flag, so 
     -- remove major objective flag if it exists
     city.attributes = setBit0(city.attributes,29)
end

-- gen.clearObjective(city)-->void

---@param city cityObject
function gen.clearObjective(city)
	 city.attributes = setBit0(city.attributes,27)
end

-- gen.isAttribute28(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute28(city)
	return isBit1(city.attributes,28)
end

-- gen.setAttribute28(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute28(city)
	 city.attributes = setBit1(city.attributes,28)
end

-- gen.clearAttribute28(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute28(city)
	 city.attributes = setBit0(city.attributes,28)
end

-- gen.isMajorObjective(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isMajorObjective(city)
	return isBit1(city.attributes,29)
end

-- gen.setMajorObjective(city)-->void

---@param city cityObject
function gen.setMajorObjective(city)
	 city.attributes = setBit1(city.attributes,29)
     -- objective flag overrides major objective flag, so 
     -- remove it
     city.attributes = setBit0(city.attributes,27)
end

-- gen.clearMajorObjective(city)-->void

---@param city cityObject
function gen.clearMajorObjective(city)
	 city.attributes = setBit0(city.attributes,29)
end

-- gen.isUsedTransporter(city)-->boolean

---@param city cityObject
---@return boolean
function gen.isUsedTransporter(city)
	return isBit1(city.attributes,30)
end
gen.isAttribute30 = gen.isUsedTransporter

-- gen.setUsedTransporter(city)-->void

---@param city cityObject
function gen.setUsedTransporter(city)
	 city.attributes = setBit1(city.attributes,30)
end
gen.setAttribute30 = gen.setUsedTransporter

-- gen.clearUsedTransporter(city)-->void

---@param city cityObject
function gen.clearUsedTransporter(city)
	 city.attributes = setBit0(city.attributes,30)
end
gen.clearAttribute30 = gen.clearUsedTransporter

-- gen.isAttribute31(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute31(city)
	return isBit1(city.attributes,31)
end

-- gen.setAttribute31(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute31(city)
	 city.attributes = setBit1(city.attributes,31)
end

-- gen.clearAttribute31(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute31(city)
	 city.attributes = setBit0(city.attributes,31)
end

-- gen.isAttribute32(city)-->boolean

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
---@return boolean
function gen.isAttribute32(city)
	return isBit1(city.attributes,32)
end

-- gen.setAttribute32(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.setAttribute32(city)
	 city.attributes = setBit1(city.attributes,32)
end

-- gen.clearAttribute32(city)-->void

-- The function of this byte in `city.attributes` is currently unknown.  If you discover it, please inform the Scenario League at Civfanatics.
---@param city cityObject
function gen.clearAttribute32(city)
	 city.attributes = setBit0(city.attributes,32)
end

--
--
-- gen.wonderModifiedMoves(unit)-->integer

-- Returns the movement allowance of a unit after
-- taking into account Nuclear Power tech, Magellan's Expedition, and Lighthouse.
-- Returns "atomic" movement points (that is, the movement recorded by `unit.moveSpent`, or "regular" movement points * `totpp.movementMultipliers.aggregate`
---@param unit unitObject
---@return integer atomicMovementPoints
function gen.fullHealthMovementAllowance(unit)
    if customCosmic.fullHealthMovementAllowance and customCosmic.isEnabled() then
        return customCosmic.fullHealthMovementAllowance(unit)
    end
    local fullHpMove = unit.type.move
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)--[[@as techObject]]) then
            fullHpMove = fullHpMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if applyWonderBonus(12,unit.owner) then
            fullHpMove = fullHpMove+2*totpp.movementMultipliers.aggregate
        end
        if applyWonderBonus(3,unit.owner) and not gen.isCoastal(unit.type) then
            fullHpMove = fullHpMove + totpp.movementMultipliers.aggregate
        end
    end
    return fullHpMove
end
gen.wonderModifiedMoves = gen.fullHealthMovementAllowance

-- maxMoves(unit)--> integer
-- gen.maxMoves(unit) --> integer
-- Helper Function (provided as both local function and in table

-- Returns movement allowance for a unit after taking damage
-- into account.
-- Returns "atomic" movement points (that is, the movement recorded by `unit.moveSpent`, or "regular" movement points * `totpp.movementMultipliers.aggregate`
---@param unit unitObject
---@return integer atomicMovementPoints
function gen.maxMoves(unit)
    if customCosmic.computeMovementAllowance and customCosmic.isEnabled() then
        return customCosmic.computeMovementAllowance(unit)
    end
    local fullHpMove = unit.type.move
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)--[[@as techObject]]) then
            fullHpMove = fullHpMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if applyWonderBonus(12,unit.owner) then
            fullHpMove = fullHpMove+2*totpp.movementMultipliers.aggregate
        end
        if applyWonderBonus(3,unit.owner) and not gen.isCoastal(unit.type) then
            fullHpMove = fullHpMove + totpp.movementMultipliers.aggregate
        end
    end
    local moveAllowance = (unit.hitpoints*fullHpMove)//unit.type.hitpoints
    local moveMult = totpp.movementMultipliers.aggregate
    if moveAllowance % moveMult > 0 then
        moveAllowance = moveAllowance - moveAllowance % moveMult + moveMult
    end
    if unit.type.domain == 0 or unit.type.domain >= 3 then
        return math.min(math.max( moveAllowance,moveMult),fullHpMove)
    elseif unit.type.domain == 1 then
        return fullHpMove
    elseif unit.type.domain == 2 then
        return math.min(math.max( moveAllowance,2*moveMult),fullHpMove)
    else
        -- shouldn't get here
        return math.min(math.max( moveAllowance,moveMult),fullHpMove)
    end
end
local maxMoves = gen.maxMoves

-- gen.moveRemaining(unit)

-- Returns gen.maxMoves-unit.moveSpent
-- bug fixed by Knighttime
---@param unit unitObject
---@return integer atomicMovementPoints
function gen.moveRemaining(unit)
	local actualMoveSpent = unit.moveSpent
	if actualMoveSpent < 0 then
		actualMoveSpent = actualMoveSpent + 256
	end
    return maxMoves(unit)-actualMoveSpent
end
local moveRemaining = gen.moveRemaining




-- computeBoundingRectangle(polygonTableOfCoordinates) -->{xMin=number,xMax=number,yMin=number,yMax=number,xBound}
--  computes x and y values which are guaranteed to have all valid polygon tiles
--  within them.  xBoundary is the value of doesNotCrossThisX, and 
--  xBoundary <= xMin, xMax <= mapWidth+xBoundary
--  calculations using this info should undo the xBoundary offset if relevant.
local function computeBoundingRectangle(polygonTable)
    local output = {}
    output.xBoundary = polygonTable.doesNotCrossThisX or 0
    local xBound = output.xBoundary
    local width,height,maps = civ.getAtlasDimensions()
    local xMin,yMin,xMax,yMax=width-1+xBound,height-1,0+xBound,0
    for _,coord in ipairs(polygonTable) do
        local x = coord[1]
        if x < xBound then
            x=x+width
        end
        if x < xMin then
            xMin = x
        end
        if x > xMax then
            xMax = x
        end
        local y = coord[2]
        if y < yMin then
            yMin = y
        end
        if y > yMax then
            yMax = y
        end
    end
    output.xMin = xMin
    output.xMax = xMax
    output.yMin = yMin
    output.yMax = yMax
    return output
end


--#gen.inPolygon(tile,tableOfCoordinates)-->bool

-- The table of coordinates defines the corners of the
-- polygon.  Returns true if the tile is within the
-- polygon defined by the table of coordinates, and
-- false otherwise.  Checking that the map is correct
-- must be done separately
-- The entry: `tableOfCoordinates.doesNotCrossThisX`
-- sets an x coordinate that the polygon does not
-- cross.  If absent, 0 is used,
-- meaning the polygon shouldn't cross the "date line".
--<br> Press CTRL+SHIFT+F4 and select the 'Start the Polygon Script' option to generate polygons.
---@param tile tileObject The tile to check
---@param tableOfCoordinates table Table of {[1]=xCoord, [2]=yCoord} without gaps in the integer keys.
---@return boolean tileIsInPolygon
function gen.inPolygon(tile,tableOfCoordinates)

-- Method (not necessary to understand for use)
-- (Note: I will use the "regular" mathematical coordinate system
-- in this explanation and code (i.e. positive y is "up" or "north").
-- All this does is reflect the coordinate system across the X-axis,
-- but it makes it easier for me to reason about.)
-- Suppose a line L connects the point (x,y) to
-- another point (X,Y), and (X,Y) is not in the
-- polygon.  If (x,y) is strictly in the polygon, the line
-- L will cross the boundary of the polygon an odd number
-- of times.  If (x,y) is strictly outside the polygon,
-- L will cross the boundary of the polygon an even number of
-- times.
-- It is easy enough to check the case where (x,y) is actually
-- on the boundary of the polygon, but difficulty arises
-- if a side of the polygon overlaps L.
-- Hence, we must avoid that case.
-- Also, there is some trouble in practice when L crosses a
-- vertex of the polygon (since it will look like it is
-- crossing two line segments, when there should only be a single
-- crossing counted.
--
-- For ease of calculation, it makes sense to use vertical
-- and/or horizontal lines for L, but this makes the likelihood
-- of a polygon side overlapping with L very high, and
-- runs in to the corner problem.
--
-- To avoid this, we will check points four points (x+-e,y+-e)
-- where e is small.  If only integer coordinates are used for the
-- polygon, this eliminates overlapping L with polygon sides, and
-- the possibility that L crosses a polygon vertex.
-- If any of the four points are considered "in" the
-- polygon, the tile is considered in the polygon, and
-- true is returned.  With e sufficiently small, this is unlikely
-- to "catch" tiles that "shouldn't" be in the polygon
--
-- To compensate for crossing the date line, if any x coordinate is
-- less than tableOfCoordinates.doesNotCrossThisX, that x coordinate is
-- replaced by x+mapWidth for all calculations (both tile coordinate and
-- tile x value itself
-- Note that if doesNotCrossThisX has 0 value, no compensation is made

    -- polygon doesn't cross this x value
    local xBound = tableOfCoordinates.doesNotCrossThisX or 0
    local width,height,maps = civ.getAtlasDimensions()
    local function isNumericallyEqual(LHS,RHS)
        return math.abs(LHS-RHS) <= 1e-6
    end
    -- gets the Y value of the intersection of 
    -- L1 and L2, where
    -- L1 is defined as x=xStar
    -- L2 is the line through (x1,y1) and (x2,y2)
    local function getYStar(xStar,x1,y1,x2,y2)
        if x1==x2 then
            return nil
            -- the lines are parallel, either no solution
            -- or lines overlap
        end
        return ((y2-y1)/(x2-x1))*(xStar-x1)+y1
    end
    -- returns true if (a,b) is on the line
    -- segment defined by (x1,y1) and (x2,y2)
    -- note line segment, not entire line
    local function pointInSegment(a,b,x1,y1,x2,y2)
        local xLow,xHigh = math.min(x1,x2),math.max(x1,x2)
        local yLow,yHigh = math.min(y1,y2),math.max(y1,y2)
        local LHS = (b-y1)*(x2-x1)
        local RHS = (y2-y1)*(a-x1)
        if a<xLow or a>xHigh or b<yLow or b>yHigh then
            return false
        else
            return isNumericallyEqual(LHS,RHS)
        end
    end
    -- path(a,b) means the path from (a,b) to the point
    -- (a,-3) from here on
    -- returns true if path(a,b) crosses segment(x1,y1,x2,y2)
    local function pathCrossesSegment(a,b,x1,y1,x2,y2)
        -- case where the same point is entered twice
        if x1==x2 and y1==y2 then
            return isNumericallyEqual(a,x1) and isNumericallyEqual(b,y1)
        end
        local xLow,xHigh = math.min(x1,x2),math.max(x1,x2)
        -- I don't check for numerical equality here, since xi,yi should
        -- be integers, and a,b will be integers and a small perturbation 
        if a < xLow or a > xHigh then
            return false
        end
        -- here, the line (a,b) (a,-3) crosses the segment(x1,y1)(x2,y2),
        -- but we have to check if path(a,b) crosses the segment(x1,y1,x2,y2)
        -- first, get yStar
        local yStar = getYStar(a,x1,y1,x2,y2)
        -- since b>-3 (well, we can choose -math.huge instead of -3 for the end point
        -- it really doesn't matter), path(a,b) crosses segment(x1,y1,x2,y2) if 
        -- yStar <= b
        -- so check yStar<b and check for numerical equality also, just in case
        return (yStar < b) or isNumericallyEqual(b,yStar)
    end
    local e = 1e-3
    local point = {x=tile.x,y=tile.y}
    local numberOfVertices = #tableOfCoordinates
    if numberOfVertices == 0 then
        return false
    elseif numberOfVertices == 1 then
        return point.x == tableOfCoordinates[1][1] and point.y == tableOfCoordinates[1][2]
    end
    -- compensate for the x boundary
    if point.x < xBound then
        point.x = point.x+width
    end
    local northEast = {x=point.x+e,y=point.y+e}
    local northWest = {x=point.x-e,y=point.y+e}
    local southEast = {x=point.x+e,y=point.y-e}
    local southWest = {x=point.x-e,y=point.y-e}
    local northEastCrossings = 0
    local northWestCrossings = 0
    local southEastCrossings = 0
    local southWestCrossings = 0
    for i=1,numberOfVertices-1 do
        -- note, we'll deal with the segment between the last vertex and the first
        -- as a separate line
        local x1=tableOfCoordinates[i][1]
        -- compensate for x boundary
        if x1 < xBound then
            x1 = x1+width
        end
        local y1=tableOfCoordinates[i][2]
        local x2=tableOfCoordinates[i+1][1]
        -- compensate for x boundary
        if x2 < xBound then
            x2 = x2+width
        end
        local y2=tableOfCoordinates[i+1][2]
        if pointInSegment(point.x,point.y,x1,y1,x2,y2) then
            return true
        end
        if pathCrossesSegment(northEast.x,northEast.y,x1,y1,x2,y2) then
            northEastCrossings=northEastCrossings+1
        end
        if pathCrossesSegment(northWest.x,northWest.y,x1,y1,x2,y2) then
            northWestCrossings=northWestCrossings+1
        end
        if pathCrossesSegment(southEast.x,southEast.y,x1,y1,x2,y2) then
            southEastCrossings=southEastCrossings+1
        end
        if pathCrossesSegment(southWest.x,southWest.y,x1,y1,x2,y2) then
            southWestCrossings=southWestCrossings+1
        end
    end
    -- note, we'll deal with the segment between the last vertex and the first
    -- as a separate line
    local x1=tableOfCoordinates[numberOfVertices][1]
    if x1 < xBound then
        x1 = x1+width
    end
    local y1=tableOfCoordinates[numberOfVertices][2]
    local x2=tableOfCoordinates[1][1]
    if x2 < xBound then
        x2 = x2+width
    end
    local y2=tableOfCoordinates[1][2]
    if pointInSegment(point.x,point.y,x1,y1,x2,y2) then
        return true
    end
    if pathCrossesSegment(northEast.x,northEast.y,x1,y1,x2,y2) then
        northEastCrossings=northEastCrossings+1
    end
    if pathCrossesSegment(northWest.x,northWest.y,x1,y1,x2,y2) then
        northWestCrossings=northWestCrossings+1
    end
    if pathCrossesSegment(southEast.x,southEast.y,x1,y1,x2,y2) then
        southEastCrossings=southEastCrossings+1
    end
    if pathCrossesSegment(southWest.x,southWest.y,x1,y1,x2,y2) then
        southWestCrossings=southWestCrossings+1
    end
    -- if the number of crossings for any of these is odd, then we
    -- return true, since at least one of the four nearby coordinates
    -- is inside the polygon
    return (northEastCrossings % 2 == 1) or (northWestCrossings % 2 == 1)
        or (southEastCrossings % 2 == 1) or (southWestCrossings % 2 == 1)
end


--  gen.getRandomTileInPolygon(polygonTableOfCoordinates,map=0,maxAttempts=100) -> tile

--[[
Generates a random tile within the polygon defined
by the table of coordinates (same as used by gen.inPolygon
and generated by the Polygon Script found in CTRL+SHIFT+F4).
Map is the map of the tile generated (0 by default).
This code is probabalistic, so after maxAttempts, the first
polygon coordinate is returned, and a text box displayed.
The console prints the polygon that caused the issue.
]]
--  Inspired by Pablostuka
---@param polygonTable table a table of coordinate pairs
---@param map? integer The map for the random tile (default 0)
---@param maxAttempts? integer the number of attempts to find an eligible square (default 100)
---@return tileObject
function gen.getRandomTileInPolygon(polygonTable,map,maxAttempts)
    map = map or 0
    maxAttempts = maxAttempts or 100
    local width,height,maps = civ.getAtlasDimensions()
    local boundary = computeBoundingRectangle(polygonTable)
    for i=0,maxAttempts do
        local xRand = nil
        local yRand = nil
        repeat
            xRand = math.random(boundary.xMin,boundary.xMax)
            xRand = xRand % width
            yRand = math.random(boundary.yMin,boundary.yMax)
        until yRand % 2 == xRand % 2
        local randomTile = civ.getTile(xRand,yRand,map)
        ---@cast randomTile tileObject
        if gen.inPolygon(randomTile,polygonTable) then
            return randomTile
        end
    end
    print("gen.getRandomTileInPolygon did not find a tile in the polygon below in "..maxAttempts.." tries.")
    print("If this is a frequent occurrence, you should either increase maxAttempts or devise a")
    print("New method for getting a random tile from this polygon")
    print(gen.tableToString(polygonTable))
    civ.ui.text("gen.getRandomTileInPolygon failed for a polygon, and a suitable default was used instead.  There is more information in the console.  If this message appears regularly, you should contact the scenario creator.")
---@diagnostic disable-next-line: return-type-mismatch
    return civ.getTile(polygonTable[1][1],polygonTable[1][2],map)

end



-- gen.cityCanSupportAnotherUnit(city)-->bool

--[[ Returns true if the city has enough production to support all existing units and at least one other unit.
Units that get free support under fundamentalism are still counted as
"supported", since they still take up a free support "slot" if they are
among the first 8 units supported by the city.]]
---@param city cityObject
---@return boolean
function gen.cityCanSupportAnotherUnit(city)
    local unitsSupported = 0
    -- check that unit's location is a tile, otherwise dead units show
    -- up in the count
    for unit in civ.iterateUnits() do
        if unit.homeCity and unit.homeCity == city and unit.type.role <= 5 and
            civ.getTile(unit.location.x,unit.location.y,unit.location.z) then
            unitsSupported = unitsSupported +1
        end
    end
	local freeSupport = 0
    local supportSource = civ.cosmic
    if customCosmic.getFreeSupport and customCosmic.isEnabled() then
        supportSource = customCosmic.getFreeSupport(city.owner)
    end
	local govtNumber = city.owner.government
	if govtNumber <= 1 then
		-- anarchy or despotism
		freeSupport = city.size
	elseif govtNumber == 2 then
		-- monarchy
		freeSupport = supportSource.supportMonarchy
	elseif govtNumber == 3 then
		-- communism
		freeSupport = supportSource.supportCommunism
	elseif govtNumber == 4 then
		freeSupport = supportSource.supportFundamentalism
	end
	return (freeSupport+city.totalShield - unitsSupported) > 0 
end

-- gen.rehomeUnitsInCapturedCity(city,defender) --> void

-- Re-homes units in a captured city to other cities owned by
-- the same tribe, so that they are not disbanded.
-- <br>If you are using the Lua Scenario Template, you can enable this feature in simpleSettings.lua. 
---@param city cityObject
---@param defender tribeObject
function gen.rehomeUnitsInCapturedCity(city,defender)
	local citySupportTable = {}
	for unit in civ.iterateUnits() do
    -- check that unit's location is a tile, otherwise dead units show
    -- up in the count
		if unit.homeCity and  civ.getTile(unit.location.x,unit.location.y,unit.location.z) and unit.type.role <= 5 then
			citySupportTable[unit.homeCity.id] = citySupportTable[unit.homeCity.id] or 0
			citySupportTable[unit.homeCity.id] = citySupportTable[unit.homeCity.id]+1
		end
	end
    local supportSource = civ.cosmic
    if customCosmic.getFreeSupport and customCosmic.isEnabled() then
        supportSource = customCosmic.getFreeSupport(city.owner)
    end
	local function canSupportAnotherUnit(city)
		local freeSupport = 0
		local govtNumber = city.owner.government
		if govtNumber <= 1 then
			-- anarchy or despotism
			freeSupport = city.size
		elseif govtNumber == 2 then
			-- monarchy
			freeSupport = supportSource.supportMonarchy
		elseif govtNumber == 3 then
			-- communism
			freeSupport = supportSource.supportCommunism
		elseif govtNumber == 4 then
			freeSupport = supportSource.supportFundamentalism
		end
		-- make sure citySupportTable has an entry for this city
		citySupportTable[city.id] = citySupportTable[city.id] or 0
		return (freeSupport+city.totalShield - citySupportTable[city.id])> 0 	
    end
	for unit in civ.iterateUnits() do
		if unit.owner == defender and unit.homeCity == city and civ.getTile(unit.location.x,unit.location.y,unit.location.z) then
			local bestCitySoFar = nil
			local bestDistanceSoFar = 1000000
			for candidateCity in civ.iterateCities() do
				if candidateCity.owner == defender and canSupportAnotherUnit(candidateCity) 
					and tileDist(candidateCity.location,unit.location) <bestDistanceSoFar then
					bestCitySoFar = candidateCity
					bestDistanceSoFar = tileDist(bestCitySoFar.location,unit.location)
				end
			end
			unit.homeCity = bestCitySoFar
			if unit.type.role <= 5 then
				citySupportTable[bestCitySoFar.id]= (citySupportTable[bestCitySoFar.id] or 0)+1
			end
		end
	end
end

--#gen.homeToNearestCity(unit)-->void

--  Finds the nearest city (of the same tribe) that can support another
--  unit, and sets the unit's home city to that city.
--  If there is no suitable city, the unit's home city isn't changed.
-- <br> Note: This counts the number of squares between the unit and the city, and ignores map differences.  This is not suitable for all applications (e.g. if maps are not "stacked", or if you're trying to re-create an existing game mechanic).
---@param unit unitObject
function gen.homeToNearestCity(unit)
    local bestDist = 1000000
    local bestCity = nil
    local function dist(unit,city)
        return tileDist(unit.location,city.location,0)
    end
    print(tostring(bestCity))
    for city in civ.iterateCities() do
        if city.owner == unit.owner and dist(unit,city) < bestDist and
            gen.cityCanSupportAnotherUnit(city) then
            bestCity = city
            bestDist = dist(unit,city)
        end
    end
    print(tostring(bestCity))
    if bestCity then
        unit.homeCity = bestCity
    end
end




-- gen.selectNextActiveUnit(activeUnit,source,customWeightFn)-->void
-- use as the first line inside the function given to
-- civ.scen.onActivateUnit(function(unit,source)-->void)
-- the line should be
--      gen.selectNextActiveUnit(unit,source,customWeightFn)
--      (note: if the arguments to function(unit,source)
--      arent called 'unit' and 'source', use the actual name)
-- Code sets all other units (owned by the same tribe)
-- to the wait order, except the next best unit
-- customWeightFn(unit,activeUnit)-->integer
-- gives 'weight' to each unit, and the unit with the lowest weight will
-- be activated next
-- By default, weight is +1 if unit is not same type as active unit
-- + 2 per square for distance between activeUnit and unit
-- + 10000 if on different maps
-- Units ordered to 'wait' are tracked, and won't be selected again until all
-- other units are also 'waiting'
--
-- No impact on AI tribes
-- 
-- This table keeps track of units manually ordered to wait
-- will not be preserved between save/load
local waitingUnits = {}
-- this makes sure the active unit is the one put into the waitingUnits table,
-- not the next unit the game would activate
local saveActiveUnit = nil

-- Part of custom unit selection (In the Lua Scenario Template, this can be activated in simpleSettings.lua -- enableCustomUnitSelection
--[[If you're not using the Template, add this code to the onKeyPress event:
```lua
    if civ.getActiveUnit() and keyID == 87 then
        gen.betterUnitManualWait()
    end
```]]
function gen.betterUnitManualWait()
    if saveActiveUnit then
        waitingUnits[saveActiveUnit.id]=true
    end
end

-- this empties the waitingUnits table, so that units
-- will appear according to the weight function
function gen.clearManualWait()
    for key,value in pairs(waitingUnits) do
        waitingUnits[key] = nil
    end
end


-- Part of custom unit selection (In the Lua Scenario Template, this can be activated in simpleSettings.lua -- enableCustomUnitSelection
--[[If you're not using the Template, use as the first line inside the function given to `civ.scen.onActivateUnit(function(unit,source)-->void)`.
The line should be
`gen.selectNextActiveUnit(unit,source,customWeightFn)`
(note: if the arguments to function(unit,source)
aren't called 'unit' and 'source', use the actual name)]]
---@param activeUnit unitObject
---@param source boolean
---@param customWeightFn fun(unit: unitObject, activeUnit:unitObject):integer returns the "weight" of each possible unit, and selects the lowest weight to be active next
function gen.selectNextActiveUnit(activeUnit,source,customWeightFn)
    if  (not civ.getCurrentTribe().isHuman) then
        -- If the AI is playing, we don't want to interfere
        return 
    end
    saveActiveUnit = activeUnit
    -- if unit activated manually, clear the manual wait for that unit
    if source then
        waitingUnits[activeUnit.id]=nil
    end
    local bestWaitingUnit = nil
    local bestWaitingValue = math.huge
    local bestNotWaitingUnit = nil
    local bestNotWaitingValue = math.huge
    local gotoUnitWithMovementLeft = false
    ---@param unit unitObject
    ---@param activeUnit unitObject
    ---@return integer
    local function defaultWeightFunction(unit,activeUnit)
        local weight = 0
        if unit.type ~= activeUnit.type then
            weight = weight+1
        end
        if unit.location.z ~= activeUnit.location.z then
            weight = weight+10000
        end
        weight = weight+tileDist(unit.location,activeUnit.location)
        return weight
    end
    customWeightFn = customWeightFn or defaultWeightFunction


    local activeTribe = civ.getCurrentTribe()
    for unit in civ.iterateUnits() do
        if unit.owner== activeTribe and moveRemaining(unit) > 0 and unit ~=activeUnit then
            if unit.order & 0xFF == 0xFF then
                gen.setToWaiting(unit)
                if waitingUnits[unit.id] and customWeightFn(unit,activeUnit) < bestWaitingValue then
                    bestWaitingUnit = unit
                    bestWaitingValue = customWeightFn(unit,activeUnit)
                end
                if not waitingUnits[unit.id] and customWeightFn(unit,activeUnit) < bestNotWaitingValue then
                    
                    bestNotWaitingUnit = unit
                    bestNotWaitingValue = customWeightFn(unit,activeUnit)
                end
            elseif unit.gotoTile then
                gotoUnitWithMovementLeft=true
            end
        end
    end
    if not (bestNotWaitingUnit or bestWaitingUnit) then
        -- only one active unit left
        return
    end
    if gotoUnitWithMovementLeft then
        -- we want to process all units with goto orders first
        -- so don't clear the 'wait' command for any unit
        return
    end
    if not bestNotWaitingUnit then
        -- all units are waiting, so clear the waitingUnits table
        for index,value in pairs(waitingUnits) do
            waitingUnits[index]=false
        end
        gen.clearWaiting(bestWaitingUnit)
    else
        gen.clearWaiting(bestNotWaitingUnit)
    end
end

local activationFunction = function(unit,source) error("Use gen.linkActivationFunction to specify the function to be run when a unit is activated.") end



-- gen.activate(unit)-->void

-- Deprecated.  This was written when unit:activate() did not run the civ.scen.onActivateUnit event.
-- use to activate a unit.  This assumes that the 'source' of the activation is true
-- (i.e. human generated).  Use gen.activateWithSource if false is needed (either sometimes or always)
---@deprecated
function gen.activate(unit)
    unit:activate()
    activationFunction(unit,true)
end

--#gen.activateSource(unit,source)-->void

-- Deprecated.  This was written when unit:activate() did not run the civ.scen.onActivateUnit event.
-- use to activate a unit and specify the source of the activation
---@deprecated
function gen.activateWithSource(unit,source)
    unit:activate()
    activationFunction(unit,source)
end

--#gen.linkActivationFunction(function(unit,source)-->void)-->void
-- If you are using the Lua Scenario Template, there is no need to worry about this function.
-- use to specify the code that should be run when a unit is
-- activated by gen.activate or gen.activateWtihSource
---@param activationFn fun(unit:unitObject, source:boolean)
function gen.linkActivationFunction(activationFn)
    if type(activationFn) == "function" then
        activationFunction = activationFn
    else
        error("gen.linkActivationFunction requires a function as the argument.")
    end
end


--gen.getActivationFunction()-->function(unit,source)
--provides the unit activation function linked to the general library
---@return fun(unit:unitObject,source:boolean)
function gen.getActivationFunction()
    return activationFunction
end


--gen.getTileID(tileObject or int,int or nil,int or nil)-->int 
--(by Knighttime, converts a tile or the coordinate of a tile to a single integer as an ID number)

-- Returns a single-value numeric key that uniquely identifies a tile on any map.
--[[ by Knighttime, modified by Prof. Garfield ]]
---@param tileORX integer|tileAnalog
---@param y? integer|nil
---@param z? integer|nil
---@return nil
---@overload fun(x:integer,y:integer,z:integer):integer
---@overload fun(tile: tileObject):integer
---@overload fun(coordinateTable: table):integer
function gen.getTileID (tileORX,y,z)
    local tile=nil
    if civ.isTile(tileORX) then
        tile = tileORX
    elseif type(tileORX) == "table" then
        tile = gen.toTile(tileORX)
    else

---@diagnostic disable-next-line: param-type-mismatch
        tile = civ.getTile(tileORX,y,z or 0)
    end
	if tile == nil then
		error("ERROR: \"getTileID\" function called with an invalid tile or coordinates")
		return nil
	end
	local mapWidth, mapHeight, mapQuantity = civ.getAtlasDimensions()
	local mapOffset = tile.z * mapWidth * mapHeight
	local tileOffset = tile.x + (tile.y * mapWidth)
	return mapOffset + tileOffset
end
gen.getTileId = gen.getTileID
local getTileId = gen.getTileId
local getTileID = gen.getTileId

-- gen.getTileFromID(tileID) --> tileObject

--- Takes an integer generated by `gen.getTileID`, and returns the corresponding tile (or nil, if the key doesn't correspond to a real tile).
---@param tileID integer
---@return tileObject|nil
function gen.getTileFromID(tileID)
    local mapWidth, mapHeight, mapQuantity = civ.getAtlasDimensions()
    local baseMapOffset = mapWidth*mapHeight
    local z = math.floor(tileID/baseMapOffset)
    if z < 0 or z >3 then
        print("getTileFromID: did not receive a valid ID")
        return nil
    end
    local tileOffset = tileID % baseMapOffset
    local y = math.floor(tileOffset/mapWidth)
    local x = tileOffset % mapWidth
    return civ.getTile(x,y,z)
end
gen.getTileFromId = gen.getTileFromID
local getTileFromId = gen.getTileFromId
local getTileFromID = gen.getTileFromId

---Returns an id number for the `baseTerrain` object.  This is different from `baseTerrain.type`, since `baseTerrain.type` is 0-15 for all maps, while this id changes for larger maps.
---@param baseTerrain baseTerrainObject
---@return integer
function gen.getBaseTerrainID(baseTerrain)
    return 16*baseTerrain.map+baseTerrain.type
end
gen.getBaseTerrainId = gen.getBaseTerrainID

--- nil, or a table containing the number of terrain types for each map
--- to be used for gen.getNumberOfTerrainTypes(map)
---@type nil|table
local numberOfTerrainTypes = nil

function gen.getNumberOfTerrainTypes(map)
    if civ.isMap(map) then
        map = map.id
    end
    local function numTerrain()
        local _,_,maps = civ.getAtlasDimensions()
        local resultTable = {}
        if authoritativeDefaultRules then
            resultTable = gen.copyTable(authoritativeDefaultRules["cosmic2"]["NumberOfTerrainTypes"])
        else
            for z = 0,maps-1 do
                for t=15,0,-1 do
                    local worked,_ = pcall(civ.getBaseTerrain,z,t)
                    if worked then
                        resultTable[z] = t+1
                        break
                    end
                end
                error("gen.getNumberOfTerrainTypes: map "..tostring(z)
                .." appears to have no terrain types.  Something is wrong.")
            end
        end
        for i=maps, gen.constants.maxMapID do
            resultTable[i] = 0
        end
        return resultTable
    end
    numberOfTerrainTypes = numberOfTerrainTypes or numTerrain()
    return numberOfTerrainTypes[map]
end




---Given an baseTerrain id, returns the corresponding baseTerrain object.
---@param id integer
---@return baseTerrainObject|nil
function gen.getBaseTerrainFromID(id)
    local w,h,maps = civ.getAtlasDimensions()
    local z = id//16
    local terrainType = id % 16
    if authoritativeDefaultRules then
        local numTerrain = authoritativeDefaultRules["cosmic2"]["NumberOfTerrainTypes"][z]
        if z > (maps-1) or terrainType > (numTerrain-1) then
            return nil
        end
        return civ.getBaseTerrain(z,terrainType)
    else
        local worked,result = pcall(civ.getBaseTerrain,z,terrainType)
        if worked then
            return result
        else
            return nil
        end
    end
end
gen.getBaseTerrainFromId = gen.getBaseTerrainFromID


---Returns an id number for the `terrain` object.  This is different from `terrain.type`, since `terrain.type` is 0-15, based on the underlying baseTerrain type.  This id number is different for each terrain type on each map.
---@param terrain terrainObject
---@return integer
function gen.getTerrainID(terrain)
    return 16*3*terrain.map+3*terrain.type+terrain.resource
end
gen.getTerrainId = gen.getTerrainID

---Returns a terrainObject from the corresponding id number created by gen.getTerrainID.
---@param id integer
---@return terrainObject|nil
function gen.getTerrainFromID(id)
    if id < 0 then
        return nil
    end
    local w,h,maps = civ.getAtlasDimensions()
    local z = id //(16*3)
    local terrainType = id % (16*3)
    terrainType = terrainType // 3
    local res = id % 3
    if authoritativeDefaultRules then
        local numTerrain = authoritativeDefaultRules["cosmic2"]["NumberOfTerrainTypes"][z]
        if z > (maps-1) or terrainType > (numTerrain-1) then
            return nil
        end
        if terrainType == 2 and res > 0 then
            return nil
        end
        return civ.getTerrain(z,terrainType,res)
    else
        local worked,result = pcall(civ.getTerrain,z,terrainType,res)
        if worked then
            return result
        else
            return nil
        end
    end
end
gen.getTerrainFromId = gen.getTerrainFromID

--gen.unitTypeOnTile(tile,unitTypeOrTableOfUnitType)-->bool

--Returns true if tile has any of the unit types listed in the table,
--false otherwise. A unit or units can be excluded from the check.
---@param tile tileObject The tile to try to find specific unit types on.
---@param unitTypeTable unitTypeObject|table<any,unitTypeObject> The unit type or types to check for.
---@param excludeFromCheck? unitObject|table<any,unitObject> These units are excluded from the check.  If they are of a matching unit type, the function still won't return true.  (Unless a different unit has a matching type.)
---@return boolean
---@overload fun(tile: tileObject, unitTypeTable: unitTypeObject|table<any,unitTypeObject>):boolean
function gen.unitTypeOnTile(tile,unitTypeTable,excludeFromCheck)
    if civ.isUnitType(unitTypeTable) then
        unitTypeTable = {unitTypeTable}
    end
    if type(unitTypeTable) ~= "table" then
        error("gen.unitTypeOnTile: Arg #2 must be a unit type or table of unit types.  Received: "..tostring(unitTypeTable))
    end
    local exclusionSet = {}
    if civ.isUnit(excludeFromCheck) then
        ---@cast excludeFromCheck unitObject
        exclusionSet[excludeFromCheck.id] = true
    elseif type(excludeFromCheck) == "table" then
        for key,unit in pairs(excludeFromCheck) do
            if not civ.isUnit(unit) then
        error("gen.unitTypeOnTile: Arg #3 must be a unit or table of units.  For key: "..tostring(key)..", Received: "..tostring(unit))
            end
            exclusionSet[unit.id] = true
        end
    elseif excludeFromCheck ~= nil then
        error("gen.unitTypeOnTile: Arg #3 must be a unit or table of units.  Received: "..tostring(excludeFromCheck))
    end
    for unit in tile.units do
        if not exclusionSet[unit.id] then
            for __,unitType in pairs(unitTypeTable) do
                if unit.type == unitType then
                    return true
                end
            end
        end
    end
    return false
end

--#gen.getAdjacentTiles(tile)-->tableOfTiles

-- Returns a table (indexed by integers) with all adjacent
-- tiles to the input tile.  Note: some keys will have nil values
-- if the tile is on the edge of the map.
---@param tile tileAnalog if table, should be a coordinate pair or triple
---@return table<integer,tileObject> tileTable table of adjacent tiles
function gen.getAdjacentTiles(tile)
    tile = toTile(tile)
    local xVal,yVal,zVal = tile.x,tile.y,tile.z
    if civ.game.rules.flatWorld then
        return {civ.getTile(xVal-2,yVal,zVal),
                civ.getTile(xVal-1,yVal+1,zVal),
                civ.getTile(xVal,yVal+2,zVal),
                civ.getTile(xVal+1,yVal+1,zVal),
                civ.getTile(xVal+2,yVal,zVal),
                civ.getTile(xVal+1,yVal-1,zVal),
                civ.getTile(xVal,yVal-2,zVal),
                civ.getTile(xVal-1,yVal-1,zVal),}
    else
        local xMax,yMax,zMax = civ.getAtlasDimensions()
        return {civ.getTile((xVal-2)%xMax,yVal,zVal),
                civ.getTile((xVal-1)%xMax,yVal+1,zVal),
                civ.getTile((xVal)%xMax,yVal+2,zVal),
                civ.getTile((xVal+1)%xMax,yVal+1,zVal),
                civ.getTile((xVal+2)%xMax,yVal,zVal),
                civ.getTile((xVal+1)%xMax,yVal-1,zVal),
                civ.getTile((xVal)%xMax,yVal-2,zVal),
                civ.getTile((xVal-1)%xMax,yVal-1,zVal),}
    end
end
local getAdjacentTiles = gen.getAdjacentTiles

-- gen.moveUnitAdjacent(unit,destRankFn=suitableDefault)-->tile or false

-- Moves the unit to an adjacent tile, choosing the tile based on  
-- `destRankFn(unit,tile)--> integer or false`.
-- Lower values mean preferred tiles, false means unit can't move to tile.
-- Default is prefer empty squares before squares with units on them.
-- Returns the tile the unit is moved to, or false if the unit can't be moved.
---@param unit unitObject
---@param destRankFn? fun(unit:unitObject, tile: tileObject):integer|false If the unit can be placed on the tile, return an integer (lower being more preferred).  If it can't, return false.
---@return tileObject|false destination The tile the unit was moved to, or false if it could not be moved.
function gen.moveUnitAdjacent(unit,destRankFn)
    local function defaultDestinationRank(theUnit,destTile)
        if (destTile.defender and destTile.defender ~=theUnit.owner) or(destTile.city and destTile.city.owner ~= theUnit.owner) or (not civ.canEnter(theUnit.type,destTile)) then
            return false
        end
        if destTile.defender then
            return 1
        else
            return 0
        end
    end
    destRankFn = destRankFn or defaultDestinationRank
    local bestTile = nil
    local bestRank = math.huge
    local tileList = getAdjacentTiles(unit.location)
    for __,destTile in pairs(tileList) do
        local rank = destRankFn(unit,destTile)
        if rank and rank < bestRank then
            bestTile = destTile
            bestRank = rank
        end
    end
    if bestTile then
        unit:teleport(bestTile)
        return bestTile
    else
        return false
    end
end
local moveUnitAdjacent = gen.moveUnitAdjacent

--#gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile)-->void

-- `isProtectingUnit(unit)-->bool`
-- if true, the unit is a 'protecting' unit that must be moved
-- e.g. air units with range >= 2 in air protected stacks
-- <br>`isProtectedUnit(unit)-->bool`
-- if true, the unit is a 'protected' unit, meaning that 'protecting' units
-- must be moved off square if one is on it
-- e.g. land and sea units in air protected stacks
-- <Br>`isProtectedTile(tile)-->bool`
-- if true, the protecting unit must be moved, if not it can stay
-- e.g. clear tiles are true in air protected stacks,
-- cities, airbases, tiles with carriers return false for air protected stacks
-- <br>`destRankFn(unit,tile)--> integer or false`.
-- The choice on where to move protecting units is based on this function.
-- Lower values mean preferred tiles, false means unit can't move to tile.
-- Default is prefer empty squares before squares with units on them.
---@param tile tileObject
---@param isProtectingUnit fun(unit:unitObject):boolean Returns true if the unit is a "protecting" unit that must be moved, false otherwise.
---@param isProtectedUnit fun(unit:unitObject):boolean Returns true if the unit is a unit that can be "protected" by protecting units, false otherwise.
---@param isProtectedTile fun(tile:tileObject):boolean Returns true if units can be protected on this tile, false otherwise.
---@param destRankFn? fun(unit:unitObject, tile: tileObject):integer|false If the unit can be placed on the tile, return an integer (lower being more preferred).  If it can't, return false.
function gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile,destRankFn)
    -- if the tile has no defender, it is not protected
    if tile.defender == nil then
        return
    end
    -- if the tile is not protected, we don't need to check anything
    if not isProtectedTile(tile) then
        return
    end
    local protectedUnitOnTile = false
    for unit in tile.units do
        if isProtectedUnit(unit) then
            protectedUnitOnTile = true
            break
        end
    end
    -- if there are no protected units
    if not protectedUnitOnTile then
        return
    end
    for unit in tile.units do
        if isProtectingUnit(unit) then
            moveUnitAdjacent(unit,destRankFn)
        end
    end
end

--#gen.clearAirProtection(tile)-->void
-- A basic function to move air units protecting stacks
-- from a tile.  See `gen.clearAirProtection` and `gen.clearAdjacentAirProtection`
-- for functions to actually use.
function gen.makeClearAirProtection()
    local function isProtectedTile(tile)
        if tile.city or gen.hasAirbase(tile) then
            return false
        end
        for unit in tile.units do
            if gen.isCarryAir(unit.type) then
                return false
            end
        end
        return true
    end
    local function isProtectingUnit(unit)
        if unit.type.domain == 1 and unit.type.range >= 2 then
            return true
        else
            return false
        end
    end
    local function isProtectedUnit(unit)
        return not isProtectingUnit(unit)
    end
    local function tileHasGroundUnit(tile)
        for unit in tile.units do
            if isProtectedUnit(unit) then
                return true
            end
        end
        return false
    end
    local function tileRank(unit,tile)
        -- don't want an air unit to be moved to a
        -- city, airbase, or carrier
        if not isProtectedTile(tile) then
            return false
        end
        if (tile.defender and tile.defender ~=unit.owner) or
            (tile.city and tile.city.owner ~= unit.owner) or
            (not civ.canEnter(unit.type,tile)) then
            return false
        end
        if tile.defender == nil then
            return 0
        elseif tileHasGroundUnit(tile) then
            return 2
        else
            return 1
        end
    end
    return function(tile)  gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile,tileRank) end
end
local clearAirProtection = gen.makeClearAirProtection()

---Clears standard Civ II Air protection from the tile.  That is, moves air units off the tile if they prevent ground/sea units on the tile from being attacked
---@param tile tileObject
function gen.clearAirProtection(tile)
    clearAirProtection(tile)
end


--#gen.clearAdjacentAirProtection(unit) -->void 

--Clears air protection for tiles adjacent to the unit, as long as those tiles are not owned by the unit's owner.
--[[In the Lua Scenario Template, simpleSettings.lua has the following settings:
```lua
simpleSettings.clearAdjacentAirProtectionAI = false
simpleSettings.clearAdjacentAirProtectionHuman = false
```]]
---@param unit unitObject
function gen.clearAdjacentAirProtection(unit)
    local tileList = getAdjacentTiles(unit.location)
    for __,tile in pairs(tileList) do
        if tile.defender and tile.defender ~= unit.owner then
            clearAirProtection(tile)
        end
    end
end

--#gen.inTable(object,table)--> bool

-- Returns `true` if the `object` is a value in the `table`, `false` otherwise
---comment
---@param object any
---@param table table
---@return boolean
function gen.inTable(object,table)
    for key,value in pairs(table) do
        if value == object then
            return true
        end
    end
    return false
end

--#gen.copyTable(table)-->table

-- Constructs (and returns) a new table with the same keys as the input.
-- Tables within the table are also copied.
-- Note: although this is meant for copying tables, 
-- the way the function is constructed, any value can be input and
-- returned.
---@param table any
---@return any
local function copyTable(table)
    if type(table) ~= "table" then
        return table
    end
    local newTable = {}
    for key,value in pairs(table) do
        newTable[key] = copyTable(value)
    end
    return newTable
end
gen.copyTable = copyTable

-- Constructs (and returns) a new table with the same keys as the input, 
-- as well as the same metatables. (The metatable is not copied, so that
-- customData is still recognised as the correct data.)
-- Tables within the table are also copied (along with their metatables).
-- Note: although this is meant for copying tables, 
-- the way the function is constructed, any value can be input and
-- returned.
---@param table any
---@return any
function gen.copyTableWithMetatable(table)
    if type(table) ~= "table" then
        return table
    end
    local newTable = {}
    setmetatable(newTable,getmetatable(table))
    for key,value in pairs(table) do
        newTable[key] = gen.copyTableWithMetatable(value)
    end
    return newTable
end

--#gen.errorForNilKey(table,tableName)-->void

-- Changes a table's metatable, so that an error is 
-- generated when a key with a nil
-- value is accessed from the table.
-- Useful for debugging in certain circumstances.
---@param table table 
---@param tableName string the name for the table you want to be used in error displays.
function gen.errorForNilKey(table,tableName)
    local mt = getmetatable(table) or {}
    setmetatable(table,mt)
    mt.__index = function(myTable,key) error("The "..tableName.." table doesn't have a value associated with "..tostring(key)..".") end
end

-- gen.noNewKey(table,tableName)-->void

-- Changes a table's metatable, so that an error is 
-- generated when assigning a value to a key 
-- which doesn't already exist in that table.
-- Useful for debugging in certain circumstances.
---@param table table 
---@param tableName string the name for the table you want to be used in error displays.
function gen.noNewKey(table,tableName)
    local mt = getmetatable(table) or {}
    setmetatable(table,mt)
    mt.__newindex = function(myTable,key)
        error("The "..tableName.." table can't accept values for indices that don't already exist.  Key value is: "..tostring(key))end
end

-- gen.noGlobal()
-- after gen.noGlobal is run, errors will be generated when trying to create a new
-- global variable, or when accessing a global variable that doesn't already exist
-- if you want to have a 'console' table to access certain functions from the console,
-- you should declare it (but you don't have to fill it) before running this function
-- In the Lua Scenario Template, this is run near the top of events.lua
function gen.noGlobal()
    local mt = getmetatable(_G) or {}
    setmetatable(_G,mt)
    mt.__index = function(myTable,key) 
        error("\nThe variable name '"..key.."' doesn't match any available local variables.\n"
        .."Consider the following possibilities:\n"
        .."Is '"..key.."' misspelled?\n"
        .."Was '"..key.."' misspelled on the line where it was defined?\n"
        .."(That is, was 'local "..key.."' misspelled?)\n"
        .."Was 'local "..key.."' defined inside a lower level code block?\n"
        .."For example:\n"
        .."if x > 3 then\n"
        .."    local "..key.." = 3\n"
        .."else\n"
        .."    local "..key.." = x\n"
        .."end\n"
        .."print("..key..")\n"
        .."If so, define '"..key.."' before the code block:\n"
        .."local "..key.." = nil -- add this line\n"
        .."if x > 3 then\n"
        .."    "..key.." = 3 -- remove local from this line\n"
        .."else\n"
        .."    "..key.." = x -- remove local from this line\n"
        .."end\n"
        .."print("..key..")\n"
        .."If you really did mean to access a global variable, write:\n"
        .."_global."..key.."\n"
        .."If you are trying to work in the console, use the command:\n"
        .."console.restoreGlobal()\n"
        .."to restore access to global variables (locals don't work well in the console)")
    end

    mt.__newindex = function(myTable,key)
        error("\nYou appear to have forgotten to put \'local\' before '"..key.."' the first time you used it.\n"
        .."If you really did mean to make a global variable, write:\n"
        .."_global."..key.."\n"
        .."If you are trying to define a variable in the console, use the command:\n"
        .."console.restoreGlobal()\n"
        .."to restore access to global variables (locals don't work well in the console)")
    end
    print('Global variables are disabled')
end


-- Allows Global variables to be used, if they have been disabled by
-- `gen.noGlobal`
function gen.restoreGlobal()
    local mt = getmetatable(_G) or {}
    setmetatable(_G,mt)
    mt.__index = nil
    mt.__newindex = nil
    print("You can now use global variables, including in the console.")
end
if rawget(_G,"console") then
    _G.console.restoreGlobal = gen.restoreGlobal
end


-- gen.cityRadiusTiles(cityOrTileOrCoordTable) --> table

--  Returns a table of tiles around a center tile, the 
--  size of a city 'footprint'.  The indices are listed below
--  and are based on how city.workers determines which tiles
--  are worked.
--
--      #       #       #       #       #
--          #       #       #       #       #
--      #       #       #       #       #
--          #       20      13      #       #
--      #       12      8       9       #
--          19      7       1       14      #
--      #       6       21      2       #
--          18      5       3       15      #
--      #       11      4       10      #
--          #       17      16      #       #
--      #       #       #       #       #
--          #       #       #       #       #
--
-- If the center is at the edge of the map, absent tiles have nil values
---@param input cityObject|tileAnalog If table, the table must be tile coordinates.
---@return table<integer,tileObject>
function gen.cityRadiusTiles(input)
    if civ.isCity(input) then
        input = input.location
    end
    local tile = toTile(input)
    local xVal = tile.x
    local yVal = tile.y
    local zVal = tile.z
    if civ.game.rules.flatWorld then
        return {
        [1] = civ.getTile(xVal+1,yVal-1,zVal),
        [2] = civ.getTile(xVal+2,yVal,zVal),
        [3] = civ.getTile(xVal+1,yVal+1,zVal),
        [4] = civ.getTile(xVal,yVal+2,zVal),
        [5] = civ.getTile(xVal-1,yVal+1,zVal),
        [6] = civ.getTile(xVal-2,yVal,zVal),
        [7] = civ.getTile(xVal-1,yVal-1,zVal),
        [8] = civ.getTile(xVal,yVal-2,zVal),
        [9] = civ.getTile(xVal+2,yVal-2,zVal),
        [10] = civ.getTile(xVal+2,yVal+2,zVal),
        [11] = civ.getTile(xVal-2,yVal+2,zVal),
        [12] = civ.getTile(xVal-2,yVal-2,zVal),
        [13] = civ.getTile(xVal+1,yVal-3,zVal),
        [14] = civ.getTile(xVal+3,yVal-1,zVal),
        [15] = civ.getTile(xVal+3,yVal+1,zVal),
        [16] = civ.getTile(xVal+1,yVal+3,zVal),
        [17] = civ.getTile(xVal-1,yVal+3,zVal),
        [18] = civ.getTile(xVal-3,yVal+1,zVal),
        [19] = civ.getTile(xVal-3,yVal-1,zVal),
        [20] = civ.getTile(xVal-1,yVal-3,zVal),
        [21] = civ.getTile(xVal,yVal,zVal),
        }
    else
        local width,height,maps = civ.getAtlasDimensions()
        return {
        [1] = civ.getTile((xVal+1)%width,yVal-1,zVal),
        [2] = civ.getTile((xVal+2)%width,yVal,zVal),
        [3] = civ.getTile((xVal+1)%width,yVal+1,zVal),
        [4] = civ.getTile((xVal)%width,yVal+2,zVal),
        [5] = civ.getTile((xVal-1)%width,yVal+1,zVal),
        [6] = civ.getTile((xVal-2)%width,yVal,zVal),
        [7] = civ.getTile((xVal-1)%width,yVal-1,zVal),
        [8] = civ.getTile((xVal)%width,yVal-2,zVal),
        [9] = civ.getTile((xVal+2)%width,yVal-2,zVal),
        [10] = civ.getTile((xVal+2)%width,yVal+2,zVal),
        [11] = civ.getTile((xVal-2)%width,yVal+2,zVal),
        [12] = civ.getTile((xVal-2)%width,yVal-2,zVal),
        [13] = civ.getTile((xVal+1)%width,yVal-3,zVal),
        [14] = civ.getTile((xVal+3)%width,yVal-1,zVal),
        [15] = civ.getTile((xVal+3)%width,yVal+1,zVal),
        [16] = civ.getTile((xVal+1)%width,yVal+3,zVal),
        [17] = civ.getTile((xVal-1)%width,yVal+3,zVal),
        [18] = civ.getTile((xVal-3)%width,yVal+1,zVal),
        [19] = civ.getTile((xVal-3)%width,yVal-1,zVal),
        [20] = civ.getTile((xVal-1)%width,yVal-3,zVal),
        [21] = civ.getTile((xVal)%width,yVal,zVal),
        }
    end
end

    

-- gen.getTilesInRadius(centre,radius,minRadius=0,maps=nil) --> table

--[[
Produces a table of nearby tiles to centre.  
Lower index means closer tile (or, same distance),
not counting z axis if multiple maps are used.
Keys start at 1, no missing indices (if a tile doesn't exist, there
won't be an empty entry, the next tile will use that entry).

centre = a tile or table of coordinates 
    central til around which we will find tiles

radius = integer
    is the distance (in tiles, not coordinates) from the centre to the furthest
    tiles desired

minRadius = integer
    is the distance in tiles from the centre for the nearest tile to be
    included (e.g. if you don't want centre itself, set minRadius to 1, if you
    want a ring only, set minRadius to radius)

maps = nil or integer in 0-3 or table of integers
    if nil, only get tiles from the map that centre is on
    if integer, only get tiles from that map
    if table of integers, tiles from all maps listed
    e.g. {1,3} means get tiles from maps 1 and 3]]
---@param centre tileAnalog if table, must be a table of coordinates.
---@param radius integer The number of tiles out you want to get.
---@param minRadius? integer 0 by default
---@param maps? integer|table if table, values are the maps to get the tiles from.  Same map as `centre` by default.
---@return table<integer,tileObject>
function gen.getTilesInRadius(centre,radius,minRadius,maps)
    centre = toTile(centre)
    local cX,cY,cZ = centre.x,centre.y,centre.z
    minRadius = minRadius or 0
    if type(radius) ~= "number" or math.floor(radius) ~= radius then
        error("gen.getTilesInRadius: radius (argument 2) must be an integer.  Received: "..tostring(radius))
    end
    if type(minRadius) ~= "number" or math.floor(minRadius) ~= minRadius then
        error("gen.getTilesInMinRadius: minRadius (argument 2) must be an integer.  Received: "..tostring(minRadius))
    end
    local doMap = {}
    if type(maps) == "number" then
        doMap[maps] = true
    elseif type(maps) == "table" then
        for __,mapNumber in pairs(maps) do
            doMap[mapNumber] = true
        end
    else
        doMap[centre.z] = true
    end
    local function addTileRing(centreX,centreY,rad,map,table,firstUnusedIndex,width) --> next unused index
        local index = firstUnusedIndex
        local twoDist = 2*rad
        if civ.game.rules.flatWorld then
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX+i,centreY+twoDist-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX+twoDist-i,centreY-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX-i,centreY-twoDist+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile(centreX-twoDist+i,centreY+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
        else
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX+i)%width,centreY+twoDist-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX+twoDist-i)%width,centreY-i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX-i)%width,centreY-twoDist+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
            for i=1,twoDist do
                local nextTile = civ.getTile((centreX-twoDist+i)%width,centreY+i,map)
                if nextTile then
                    table[index] = nextTile
                    index= index+1
                end
            end
        end
        -- the central tile won't be captured above
        if rad==0 then
            local nextTile = civ.getTile(centreX,centreY,map)
            if nextTile then
                table[index] = nextTile
                index= index+1
            end
        end
        return index
    end
    local mapWidth,mapHeight,numberOfMaps = civ.getAtlasDimensions()
    local tableOfTiles = {}
    local nextIndex = 1
    for rad = minRadius,radius do
        for z = 0,numberOfMaps-1 do
            if doMap[z] then
                nextIndex= addTileRing(cX,cY,rad,z,tableOfTiles,nextIndex,mapWidth)
            end
        end
    end
    return tableOfTiles               
end

-- gen.clearGapsInArray(table,lowestValue=1)-->void

-- Re-indexes all integer keys and values
-- in a table, so that there are no gaps.
-- Starts at lowestValue (1 by default), and maintains order
-- of integer keys
-- Non integer keys (including other numbers)
-- and integers below lowestValue are left unchanged
---@param table table
---@param lowestValue? integer default is 1
function gen.clearGapsInArray(table,lowestValue)
    lowestValue = lowestValue or 1
    local largestIndex = lowestValue-1
    for index,val in pairs(table) do
        if type(index) == "number" and index > largestIndex then
            largestIndex = index
        end
    end
    local nextIndex = lowestValue
    for i=lowestValue,largestIndex do
        if table[i] ~= nil then
            if nextIndex < i then
                table[nextIndex] = table[i]
                table[i] = nil
            end
            nextIndex = nextIndex+1
        end
    end
end

-- All integer values in the table are re-indexed so that they 
-- start at 1 and proceed without gaps.
-- All other keys are ignored.
---@param table table
function gen.makeArrayOneToN(table)
    local lowestIntKey = math.huge
    local highestIntKey = -math.huge
    local function isInt(number)
        return type(number)=="number" and number == math.floor(number)
    end
    local tempTable = {}
    for key,value in pairs(table) do
        if isInt(key) then
            if key < lowestIntKey then
                lowestIntKey = key
            end
            if key > highestIntKey then
                highestIntKey = key
            end
            tempTable[key] = value
            table[key] = nil
        end
    end
    local newIndex = 1
    for i=lowestIntKey,highestIntKey do
        if tempTable[i] ~= nil then
            table[newIndex] = tempTable[i]
            newIndex = newIndex+1
        end
    end
end

local musicFolder = ""
-- gen.playMusic(fileName)

-- Plays music from `fileName`, found in the folder set by
-- gen.setMusicDirectory (in Lua Scenario Template, this is <MainScenarioDirectory>\Sound).
--
-- gen.playMusic stops any currently playing game music in order
-- to play music, and the music won't play if the "music" is disabled in the menu.  This is different from playing a sound with civ.playSound, which doesn't stop any existing music.
function gen.playMusic(fileName)
    civ.playMusic(musicFolder.."\\"..fileName)
end

-- gen.setMusicDirectory(path)

-- Tells gen.playMusic to look in this directory for music files.
-- In the Lua Scenario Template, the directory is <MainScenarioDirectory>\Sound
---@param path string
function gen.setMusicDirectory(path)
    musicFolder = path
end

-- the ephemeralTable is a table for shared data
-- since it is not saved, it doesn't have to be serializeable,
-- so you don't have to worry about making keys and
-- values text or numbers
-- However, the information will not be preserved after a save and load
local ephemeralTable = {}
-- gen.getEphemeralTable()-->table

-- The ephemeralTable is a table for shared data.
-- Since it is not saved, it doesn't have to be serializeable,
-- so you don't have to worry about making keys and
-- values text or numbers.
-- However, the information will not be preserved after a save and load.
---@return table
function gen.getEphemeralTable()
    return ephemeralTable
end

--[[A state savable table can be saved in the 'state' table, which is to say, the table where data is saved to the saved game file. A state savable table is a table where the keys are integers and strings, and the values are integers, strings, and other state savable tables.]]
---@alias stateSavableTable table<string|number,boolean|string|number|table>|string|number|boolean

---@type string|stateSavableTable
local state = "stateNotLinked"

-- gen.linkState(stateTable)

-- Links the state table to the General Library
-- provides access to the state table so that
-- gen.getState() can provide it.
---@param stateTable stateSavableTable
function gen.linkState(stateTable)
    if type(stateTable) == "table" then
        state = stateTable
    else
        error("gen.linkState: linkState takes a table as an argument.")
    end
end

-- gen.getState()

-- Returns the state table submitted to `gen.linkState`.
-- If you're writing a module intended for use by others,
-- it is recommended that you use a linkState system with a 
-- sub table, so that table keys don't accidentally conflict
---@return stateSavableTable
function gen.getState()
    return state
end


---@type stateSavableTable|string
local genStateTable = "stateTableNotLinked"
-- gen.linkGeneralLibraryState(stateTable) --> void

-- Links a sub table of the state table for the purposes of
-- providing a table for functions in the General Library
-- this is distinct from getState, which provides a 
-- 'visible' state table to the end user
---@param stateTable stateSavableTable
function gen.linkGeneralLibraryState(stateTable)
    if type(stateTable) == "table" then
        genStateTable = stateTable
    else
        error("gen.linkGeneralLibraryState: linkGeneralLibraryState takes a table as an argument.")
    end
    genStateTable.limitedExecutions = genStateTable.limitedExecutions or {}
    genStateTable.persistentRandom = genStateTable.persistentRandom or {}
    genStateTable.tileMarkerTable = genStateTable.tileMarkerTable or {}
end


local discreteEventsFileFound, discreteEvents = gen.requireIfAvailable("discreteEventsRegistrar")
if discreteEventsFileFound then
    ---@cast discreteEvents -nil
    discreteEvents:minVersion(1)
    discreteEvents.linkStateToModules(function(state,stateTableKeys)
        local keyName = "designerState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        gen.linkState(state[keyName])
    end)
    discreteEvents.linkStateToModules(function(state,stateTableKeys)
        local keyName = "generalLibraryState"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        gen.linkGeneralLibraryState(state[keyName])
    end)
end


-- gen.limitedExecutions(key,maxTimes,limitedFunction)--> void

-- If the value at key is less than maxTimes, limitedFunction will execute,
-- and the value at key will increment by 1.
-- Otherwise, don't execute limitedFunction.
-- Note: limitedFunction()-->void
-- 
-- Example: Volunteers will be created in a capital up to 3 times for a certain trigger.
--[[```lua
gen.limitedExecutions("Tribe 1 Volunteers",3, function()
    text.simple("Young men flock to Washington to fight the South.")
    gen.createUnit(gen.original.uRiflemen, object.pUnion, object.lWashington, {})
end)
```]]
---@param key string|integer The key for this limited execution
---@param maxTimes integer The number of times the limited function will be executed
---@param limitedFunction fun() The function to execute a maximum number of times.
function gen.limitedExecutions(key,maxTimes,limitedFunction)
    genStateTable.limitedExecutions[key] = genStateTable.limitedExecutions[key] or 0
    if genStateTable.limitedExecutions[key] < maxTimes then
        genStateTable.limitedExecutions[key] = genStateTable.limitedExecutions[key]+1
        limitedFunction()
    end
end

-- gen.justOnce(key,limitedFunction) --> void

-- If justOnce has never been executed for this key before, then
-- the limited function will execute.  Otherwise, it won't.
-- (Wrapper for gen.limitedExecutions with maxTimes being 1.)
-- Example: Show a message once for a certain trigger
--[[```lua
gen.justOnce("Rebel Attack", function()
    text.simple("The Rebels have attacked Union troops.  We're now in a shooting war!","Secretary of Defense")
end)
```]]
function gen.justOnce(key,limitedFunction)
    gen.limitedExecutions(key,1,limitedFunction)
end

-- gen.isSinglePlayerGame() --> boolean

-- Returns true if there is exactly one human player, false otherwise.
---@return boolean
function gen.isSinglePlayerGame()
    local humanMask = civ.game.humanPlayers
    -- not humanMask >= 0, so don't have to worry about negatives
    if humanMask == 0 then
        -- no human player, so not single player game
        return false
    end
    -- if there is exactly one human player, then humanMask
    -- will be a power of 2, and so will have an integer logarithm
    return (math.log(humanMask,2) == math.floor(math.log(humanMask,2)))
end


-- gen.tableWrap(item)-->table
-- If item is a table, return the table
-- otherwise, return a table with the item as element 1.
-- This is useful so that functions can accept either a single
-- element or a table of such elements.
--  `needsWrapFn(item)-->boolean`
--  If true, item needs a wrapping table, if not, it doesn't
--  useful if you can distinguish between tables that represent other
--  data structures, and tables of such data structures.
--  By default, returns true if the item isn't a table, and false if it is.
---@param item any
---@param needsWrapFn fun(item:any):boolean Default: returns true if item is not a table, and false if it is.
---@return table
---@overload fun(item:any):table
function gen.tableWrap(item,needsWrapFn)
    needsWrapFn = needsWrapFn or function(item) return type(item)~="table" end
    if needsWrapFn(item) then
        return {item}
    else
        return item
    end
end

--
-- gen.copyUnitAttributes(parent,child)-->void

-- Copies the attributes of the `parent` unit to the `child` unit.
-- All attributes accessible through lua are copied (except unit type,
-- and unit id number)
--  Useful if a unit's type must be changed (by creating a new unit), but everything
--  else should stay the same
---@param parent unitObject The unit giving the attributes.
---@param child unitObject The unit receiving the attributes.
function gen.copyUnitAttributes(parent,child)
    child.owner = parent.owner
    child:teleport(parent.location)
    child.homeCity = parent.homeCity
    child.damage = parent.damage
    child.moveSpent = parent.moveSpent
    child.carriedBy = parent.carriedBy
    if parent.gotoTile then
        gen.setToGoingTo(child,parent.gotoTile)
    else
        child.order = parent.order
    end
    child.attributes = parent.attributes
    child.veteran = parent.veteran
    child.domainSpec = parent.domainSpec
end

-- gen.nearbyUnits(center,radius,maps={0,1,2,3}) --> iterator providing units
--[[
provides an iterator over all the units within radius
tiles of the center tile
maps = nil or integer in 0-3 or table of integers
    if integer, only get units from tiles from that map
    if table of integers, units from all maps listed
    e.g. {1,3} means get units from maps 1 and 3
    if nil, get units from all maps (this choice is for backwards compatibility)
]]
---@param center tileAnalog If table, must be a table of coordinates.
---@param radius integer How far away from the center you wish to get units.
---@param maps? integer|table If integer, get units from that map. If table, values are the maps to get the tiles from.  Get from all maps by default (for backwards compatibility).
---@return iterator
function gen.nearbyUnits(center,radius,maps)
    maps = maps or {0,1,2,3}
---@diagnostic disable-next-line: return-type-mismatch
    return coroutine.wrap(function ()
        for __,tile in pairs(gen.getTilesInRadius(center,radius,0,maps)) do
            for unit in tile.units do
                coroutine.yield(unit)
            end
        end
    end)
end



local defeatFunction = nil
local deathFunction = nil 
local deletionFunction = nil
local deathOutsideCombat = nil
-- gen.setDeathFunctions(defeatFunction,deathFunction,deletionFunction) --> void
-- Registers event functions for when units are killed/deleted.
-- If you are using the Lua Scenario Template, this is already
-- run in events.lua, and you do not need to use this function.
--      defeatFunction(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)--> nil or unit
--          function for when a unit is defeated either in game combat or in an event representing combat
--          if a unit is returned, that is a replacement unit for demotion
--      deathFunction(dyingUnit) --> void
--          for when a unit 'dies', either in standard or event combat, or through some other event 'kill'
--      deletionFunction(deletedUnit,replacingUnit=nil) --> void
--          maintenance for when a unit is deleted, either because of combat, death, replacement or some other 'administrative' situation.  If no replacing unit, the replacingUnit argument is nil
--  registers functions to be performed when a unit is defeated (either in game combat or events)
--  or deleted by events in some other way
--      deathNoCombatFn(dyingUnit) --> void
--          for when a unit dies, but not in combat or through the gen.defeatUnit function
---@param defeatFn fun(loser:unitObject,winner:unitObject,aggressor:unitObject,victim:unitObject,loserLocation:tileObject,winnerVetStatus:boolean,loserVetStatus:boolean):unitObject|nil
---@param deathFn fun(dyingUnit: unitObject)
---@param deletionFn fun(deletedUnit: unitObject, replacingUnit: nil|unitObject)
---@param deathNoCombatFn fun(dyingUnit: unitObject)
function gen.setDeathFunctions(defeatFn,deathFn,deletionFn,deathNoCombatFn)
    defeatFunction = defeatFn
    deathFunction = deathFn
    deletionFunction = deletionFn
    deathOutsideCombat = deathNoCombatFn
end

-- gen.defeatUnit(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->unit or nil

-- "Defeats" the loser, deletes the loser, and returns a unit if and only if the loser was demoted, otherwise nil is returned.
-- Runs the events for unit defeat, death, and deletion.
---@param loser unitObject
---@param winner unitObject
---@param aggressor unitObject 
---@param victim unitObject
---@param loserLocation tileObject
---@param winnerVetStatus boolean
---@param loserVetStatus boolean
---@return unitObject|nil survivingDemotedUnit
function gen.defeatUnit(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    local survivor = defeatFunction(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)
    if not survivor then
        deathFunction(loser)
    end
    deletionFunction(loser,survivor)
---@diagnostic disable-next-line: deprecated
    civ.deleteUnit(loser)
    return survivor
end

-- gen.killUnit(dyingUnit)-->void

-- "Kills" the dying unit, running events for 'death', 'death outside combat', and 'deletion'.
---@param dyingUnit unitObject
function gen.killUnit(dyingUnit)
    deathFunction(dyingUnit)
    deathOutsideCombat(dyingUnit)
    deletionFunction(dyingUnit,nil)
---@diagnostic disable-next-line: deprecated
    civ.deleteUnit(dyingUnit)
    return
end

-- gen.deleteUnit(deletedUnit,replacementUnit=nil)-->void

-- Deletes the deleted unit.
-- I the unit is being 'replaced', the replacing unit must be provided.
-- Runs events associated with unit deletion.
---@param deletedUnit unitObject
---@param replacementUnit unitObject|nil
function gen.deleteUnit(deletedUnit,replacementUnit)-->void
    replacementUnit=replacementUnit or nil
    deletionFunction(deletedUnit,replacementUnit)
---@diagnostic disable-next-line: deprecated
    civ.deleteUnit(deletedUnit)
    return
end

-- gen.replaceUnit(oldUnit,replacementType)--> unit

-- Creates a unit to replace the old unit, 
-- copies the old unit's attributes, and
-- deletes the old unit (applying the deletion function).
-- Returns the newly created unit.
---comment
---@param oldUnit unitObject
---@param replacementType unitTypeObject
---@return unitObject
function gen.replaceUnit(oldUnit,replacementType)
    local newUnit = civ.createUnit(replacementType,oldUnit.owner,oldUnit.location)
    gen.copyUnitAttributes(oldUnit,newUnit)
    gen.deleteUnit(oldUnit,newUnit)
    return newUnit
end

-- gen.makeAllowedTerrainFunction(allowedTilesTable) --> function(tile)-->bool
--Converts a table of integer values into a function that returns
--true if tile.baseTerrain.type is a value in the table, and false otherwise.
--If nil is entered, all terrain is allowed.
---@param allowedTilesList table<integer,integer>|nil
---@return fun(tile:tileObject):boolean
function gen.makeAllowedTerrainFunction(allowedTilesList)
    allowedTilesList = allowedTilesList or {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    local allowedTilesTable = {}
    for __,terrainID in pairs(allowedTilesList) do
        allowedTilesTable[terrainID] = true
    end
    ---@param tile tileObject
    ---@return boolean
    local function allowedTile(tile)
        return allowedTilesTable[tile.baseTerrain.type ] or false
    end
    return allowedTile
end

-- 
-- gen.nearbyUnoccupiedTiles(tile,distance,allowedTiles) --> table

--Returns the table of nearby unoccupied tiles.
--Indices start at 1 without gaps, but tiles are in no particular order.
--`centerTile` is the tile that you want to find other tiles near to (on same map).
--`distance` is the number of squares away that you can search.
--`allowedTiles` is either a table of integers such that a tile is acceptable if
--`possibleTile.baseTerrain.type` appears as a value in the table
--or a function `allowedTiles(possibleTile)-->bool`
--that returns true if the tile is allowed, and false if not.
--If `nil` is entered, all terrain is allowed.
---@param centerTile tileAnalog
---@param distance integer
---@param allowedTiles table<integer,integer>|fun(tile:tileObject):boolean
---@return table<integer,tileObject>
function gen.nearbyUnoccupiedTiles(centerTile,distance,allowedTiles)
    centerTile = toTile(centerTile)
    if type(allowedTiles) == "table" or type(allowedTiles) == "nil" then
        allowedTiles = gen.makeAllowedTerrainFunction(allowedTiles)
    end
    local newIndex = 1
    local tileList = {}
    for __,tile in pairs(gen.getTilesInRadius(centerTile,distance)) do
        if tile.defender == nil and tile.city == nil and allowedTiles(tile) then
            tileList[newIndex] = tile
            newIndex = newIndex+1
        end
    end
    return tileList
end

-- gen.getRandomNearbyUnoccupiedTile(tile,distance,allowedTiles) --> tile

--Returns a random unoccupied square near tile, on the same map.  Returns nil if there is no such tile.
--`centerTile` is the tile that you want to find other tiles near to (on same map).
--`distance` is the number of squares away that you can search.
--`allowedTiles` is either a table of integers such that a tile is acceptable if
--`possibleTile.baseTerrain.type` appears as a value in the table
--or a function `allowedTiles(possibleTile)-->bool`
--that returns true if the tile is allowed, and false if not.
--If `nil` is entered, all terrain is allowed.
---@param centerTile tileAnalog
---@param distance integer
---@param allowedTiles table<integer,integer>|fun(tile:tileObject):boolean
---@return tileObject|nil
function gen.getRandomNearbyUnoccupiedTile(centerTile,distance,allowedTiles)
    local tileList = gen.nearbyUnoccupiedTiles(centerTile,distance,allowedTiles)
    local numberOfTiles = #tileList
    if numberOfTiles > 0 then
        return tileList[math.random(1,numberOfTiles)]
    else
        return nil
    end
end

-- gen.isEmpty(table)-->bool

--Returns true if the table has no entries, and false otherwise.
--(I got this idea from stackoverflow, https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries )
---comment
---@param table table
---@return boolean
function gen.isEmpty(table)
    return next(table) == nil
end

--  gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
--Returns a table of nearby tiles, on the same map, that are either unoccupied or only has units/city of the `tribe`
--Indices start at 1 without gaps, but tiles are in no particular order.
--`centerTile` is the tile that you want to find other tiles near to (on same map).
--`distance` is the number of squares away that you can search.
--`allowedTiles` is either a table of integers such that a tile is acceptable if
--`possibleTile.baseTerrain.type` appears as a value in the table
--or a function `allowedTiles(possibleTile)-->bool`
--that returns true if the tile is allowed, and false if not.
--If `nil` is entered, all terrain is allowed.
--`tribe` the tribe that is searching for open tiles.
---@param centerTile tileAnalog
---@param distance integer
---@param allowedTiles table<integer,integer>|fun(tile:tileObject):boolean
---@param tribe tribeObject
---@return table<integer,tileObject>
function gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
    centerTile = toTile(centerTile)
    if type(allowedTiles) == "table"  or type(allowedTiles) == "nil" then
        allowedTiles = gen.makeAllowedTerrainFunction(allowedTiles)
    end
    local newIndex = 1
    local tileList = {}
    for __,tile in pairs(gen.getTilesInRadius(centerTile,distance)) do
        if (tile.defender == nil or tile.defender == tribe) and
            (tile.city == nil or (tile.city and tile.city.owner == tribe)) and
            allowedTiles(tile) then
            tileList[newIndex] = tile
            newIndex = newIndex+1
        end
    end
    return tileList
end

-- gen.getRandomNearbyOpenTileForTribe(tile,distance,allowedTiles,tribe) --> tile|nil

--Returns a random square near tile, on the same map, that is either empty or only has units/city of the same tribe.  Returns nil if there is no such tile.
--`centerTile` is the tile that you want to find other tiles near to (on same map).
--`distance` is the number of squares away that you can search.
--`allowedTiles` is either a table of integers such that a tile is acceptable if
--`possibleTile.baseTerrain.type` appears as a value in the table
--or a function `allowedTiles(possibleTile)-->bool`
--that returns true if the tile is allowed, and false if not.
--If `nil` is entered, all terrain is allowed.
--`tribe` the tribe that is searching for open tiles.
---@param centerTile tileAnalog
---@param distance integer
---@param allowedTiles table<integer,integer>|fun(tile:tileObject):boolean
---@param tribe tribeObject
---@return tileObject|nil
function gen.getRandomNearbyOpenTileForTribe(centerTile,distance,allowedTiles,tribe)
    local tileList = gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
    local numberOfTiles = #tileList
    if numberOfTiles > 0 then
        return tileList[math.random(1,numberOfTiles)]
    else
        return nil
    end
end







-- gen.createUnit(unitType,tribe,locations,options) --> table of units

--This is a createUnit function, meant to supersede civlua.createUnit.
--Returns a table of units, indexed by integers starting at 1 (unless no units were created.
---@param unitType unitTypeObject The type of unit to create.
---@param tribe tribeObject The owner of the new unit or units.
---@param locations tileAnalog|table<integer,tileAnalog> locations is one of the following:<br><br>tileObject<br>{xCoord,yCoord}<br>{xCoord,yCoord,zCoord}<br>{x=xCoord,y=yCoord}<br>{x=xCoord,y=yCoord,z=zCoord}<br>table<integer,above_types>
---@param options table options is a table with the following keys: <br><br> count : integer|nil <br> The number of units to create.  `nil` means 1.<br><br>randomize : boolean|nil <br> If true, randomize the list of locations.  If false or nil, try to place at the tile with the smallest index in the table first.<br><br>scatter : boolean|nil <br> If true, and if randomize is true, each unit is created on a random tile in the location table.<br><br>inCapital : boolean|nil <br> If true, attempt to place in the capital before other locations.  IN case of multiple capitals, capitals are ranked with smallest city id first.  randomize/scatter applies to list of capitals if this is selected.<br><br>veteran : boolean|number|nil <br> If true, make the created units veteran.  If a fraction between 0 and 1, each unit has this probability of being veteran.  If number 1 or more, this many of the count are made veteran (take floor).  If nil or false, no veterans.<br><br>homeCity : city|true|nil <br> If city, that city is the home city.  If true, the game selects the home city (probably the way a city is chosen if you crate a unit using the cheat menu).  If nil, no home city.<br><br>overrideCanEnter : boolean|nil <br> If true, the units will be placed even if unitType : canEnter(tile) returns false.  False or nil means follow the restriction.  civ.canEnter appears to check if the terrain is impassible, or if the unit can cross impassible.<br><br>overrideDomain : boolean|nil <br> If true, sea units can be created on land outside cities, and land units at sea.  False or nil means units can only be created where they could travel naturally.<br><br>overrideDefender : boolean|nil <br> If true, unit can be placed on tiles with enemy units or cities.  False or nil means the tile must have no enemy city, and no enemy defender.
---@return table
function gen.createUnit(unitType,tribe,locations,options)
    options = options or {}
    -- must copyTable locations, in case that table is used for multiple things
    -- mutating the original table could cause errors that are difficult to diagnose
    -- note: copyTable returns the input for things that are not tables
    locations = gen.copyTable(locations)
    if civ.isTile(locations) then
        -- toTile(locations) so that an error will be thrown if an invalid tile
        -- is used (e.g. loser.location if the loser is an attacker)
        locations = {toTile(locations)}
    elseif type(locations) =="table" then
        -- must copy the table, just in case it is referenced again
        if type(locations[1]) == "number" then
            -- if first index is a number, the table represents a single coordinate triple
            -- if the table is of tiles or coordinate triples, the first element will be either
            -- a table, a tile, or nil
            locations = {toTile(locations)}
        else
            -- make all the locations tiles
            for key,loc in pairs(locations) do
                locations[key] = toTile(loc)
            end
        end
    else
        error("gen.createUnit: Invalid argument for locations (arg 3).")
    end
    local function checkCanEnter(tile)
        return civ.canEnter(unitType,tile) or options.overrideCanEnter
    end
    local function checkDomain(tile)
        if options.overrideDomain then
            return true
        elseif unitType.domain == 2 then
            -- sea unit
            return (tile.terrainType % 16) == 10 or (tile.city and tile.city.coastal)
        elseif unitType.domain == 0 then
            -- land unit
            return (tile.terrainType % 16) ~= 10
        else
            -- air unit
            return true
        end
    end
    local function checkDefender(tile)
        if options.overrideDefender then
            return true
        end
        if tile.city and (tile.city.owner ~= tribe) then
            return false
        end
        if tile.defender and tile.defender ~= tribe then
            return false
        end
        return true
    end
    local function isTileValid(tile)
        if not tile then
            return false
        end
        return checkCanEnter(tile) and checkDomain(tile) and checkDefender(tile)
    end
    local capitals = {}
    if options.inCapital then
        for city in civ.iterateCities() do
            if city.owner == tribe and city:hasImprovement(civ.getImprovement(1)) then
                capitals[city.id] = city.location
            end
        end
    end
    for key,loc in pairs(capitals) do
        if not isTileValid(loc) then
            capitals[key] = nil
        end
    end
    for key,loc in pairs(locations) do
        if not isTileValid(loc) then
            locations[key] = nil
        end
    end
    local placementTable = nil
    if gen.isEmpty(capitals) then
        placementTable = locations
    else
        placementTable = capitals
    end
    gen.makeArrayOneToN(placementTable)
    local returnUnits = {}
    if gen.isEmpty(placementTable) then
        print("gen.createUnit: No units placed, since no valid location.")
        return returnUnits
    end
    local numToPlace = options.count or 1
    local vetCount = 0 
    ---@type true|number
    local vetChance = 0  
    if options.veteran == true then
        vetCount = numToPlace
        vetChance = 1
    elseif type(options.veteran) == "number" and options.veteran < 1 then
        vetCount = numToPlace
        vetChance = options.veteran
    elseif type(options.veteran) == "number" then
        vetCount = math.floor(options.veteran--[[@as number]])
        vetChance = 1
    end
    local placementTile = nil
    local placementTableSize = #placementTable
    if options.randomize then
        placementTile = placementTable[math.random(1,placementTableSize)]
    else
        placementTile = placementTable[1]
    end
    for i=1,numToPlace do
        if options.scatter and options.randomize then
            placementTile = placementTable[math.random(1,placementTableSize)]
        end
        ---@cast placementTile tileObject placementTable isn't empty, so placementTile won't be nil
        local newUnit = civ.createUnit(unitType,tribe,placementTile)
        returnUnits[i] = newUnit
        if i<=vetCount and (math.random() <= vetChance) then
            newUnit.veteran = true
        end
        if options.homeCity ~= true then
            -- if homeCity is true, the unit keeps the default home city it got when it was
            -- created
            -- if homeCity not specified, that means the unit has no home city, so next line works
            -- if homeCity is specified, next line works also
            newUnit.homeCity = options.homeCity
        end
    end
    return returnUnits
end

-- gen.getTileProduction(tile,city) --> integer (food), integer(shields), integer(trade)
-- Returns the tile production values, presuming that the city
-- given is the one working the tile.
-- That is to say, returns the values that would be seen on the tile in the city window.
-- Doesn't check if that city is actually working the tile.
---@param tile tileAnalog
---@param city cityObject
---@param ignoreCustomCosmic? boolean # If true, do not use the customCosmic city customisation to get production, refer to the current settings of terrain, baseTerrain and roadTrade.  If false or nil, refer to customCosmic module if it is available (otherwise, refer to current settings of terrain, baseTerrain and roadTrade).
---@return integer foodProduction
---@return integer shieldProduction
---@return integer tradeProduction
function gen.getTileProduction(tile,city,ignoreCustomCosmic)
    tile = toTile(tile)

    local terrainData = tile.terrain
    local baseTerrainData = tile.baseTerrain
    local roadTradeData = totpp.roadTrade
    if customCosmic.getCustomisedTerrainInfo and 
    (not ignoreCustomCosmic) and
    customCosmic.isEnabled()
    then
        baseTerrainData, terrainData, roadTradeData =
        customCosmic.getCustomisedTerrainInfo(tile,city)
    end
    local trade = terrainData.trade
    local shields = terrainData.shields
    local food = terrainData.food
    if baseTerrainData.type == 10 then
        -- the ocean has a different computation than
        -- other terrain in several areas
        -- road and river don't add trade to ocean
        -- colossus always adds trade to ocean, even if it doesn't
        -- have any trade production
        if civ.getWonder(2).city == city and applyWonderBonus(civ.getWonder(2)--[[@as wonderObject]],city.owner) then
            trade = trade+1
        end
        local tribeGovernment = city.owner.government
        if tribeGovernment >= 5 or (tribeGovernment >= 2 and gen.isWeLoveTheKing(city)) then
            -- republic/democracy bonus, wltkd for other gov'ts
            if trade >= 1 then
                trade = trade+1
            end
        elseif (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if trade >= 3 then
                trade = trade -1
            end
        end
        -- highways apply to ocean
        if (gen.hasRoad(tile) or tile.city) and city:hasImprovement(civ.getImprovement(25)--[[@as improvementObject]]) then
            trade = (3*trade)//2
        end
        -- pollution occurs after highway bonus
        -- 6 trade  -> 9 (highway) -> 5 (pollution) observed
        -- 6 trade -> 3 (pollution) -> 4 (highway) NOT observed
        if gen.hasPollution(tile) then
            trade = trade - (trade//2)
        end

        -- shields
        -- mining doesn't increase ocean shield production

        -- apply offshore platform
        if city:hasImprovement(civ.getImprovement(31)--[[@as improvementObject]]) then
            shields = shields+1
        end
        -- King Richard's Crusade
        if civ.getWonder(8).city == city and applyWonderBonus(civ.getWonder(8)--[[@as wonderObject]],city.owner) then
            shields = shields+1
        end
        -- railroads apply to ocean
        if gen.hasRailroad(tile) or (tile.city and city.owner:hasTech(civ.getTech(67)--[[@as techObject]])) then
            shields = (3*shields)//2
        end
        -- despotism seems to happen after railroads
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if shields >= 3 then
                shields = shields -1
            end
        end
        -- despotism is applied before pollution
        -- 6 ->5 (despotism)->3 (pollution) observed
        -- 6 ->3 (pollution) -> 2 (despotism) not observed
        if gen.hasPollution(tile) then
            shields = shields - (shields//2)
        end
        -- irrigation doesn't increase food production on the ocean
        -- Farmland doesn't affect it either

        -- apply harbour
        if city:hasImprovement(civ.getImprovement(30)--[[@as improvementObject]]) then
            food = food+1
        end
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if food >= 3 then
                food = food -1
            end
        end
        -- harbour is applied before pollution
        -- 7 ->8 (harbour) -> 4 (Pollution) observed
        -- 7 -> 4 (pollution) ->5 (harbour) Not observed
        -- despotism is applied before pollution
        -- 6 ->5 (despotism)->3 (pollution) observed
        -- 6 ->3 (pollution) -> 2 (despotism) not observed
        if gen.hasPollution(tile) then
            food = food - (food//2)
        end

    else
        -- calculation for non-ocean tiles

        -- river adds 1 trade to all tiles (except ocean)
        if tile.river  then
            trade = trade+1
        end
        -- road
        -- If the tile has a road, it gets +1 trade if it already has some trade,
        -- or if totpp.roadTrade says it should (baseTerrain.type+1, since id starts counting
        -- at 0, but isBit1 starts counting from 1
        -- Oceans don't get +1 road trade, ever
        if (gen.hasRoad(tile) or tile.city) and (isBit1(roadTradeData[tile.z],baseTerrainData.type+1) or trade > 0) then 
            trade = trade+1
        end
        -- apply colossus
        if civ.getWonder(2).city == city and trade >= 1 and applyWonderBonus(civ.getWonder(2)--[[@as wonderObject]],city.owner) then
            -- colossus adds 1 trade to each tile that already has a trade arrow,
            -- (also adds 1 trade to ocean even if no trade arrow, see above)
            trade = trade+1
        end
        -- republic/democracy trade bonus happens before highways are applied
        -- despotism penalty happens before highways
        local tribeGovernment = city.owner.government
        if tribeGovernment >= 5 or (tribeGovernment >= 2 and gen.isWeLoveTheKing(city)) then
            -- republic/democracy bonus, wltkd for other gov'ts
            if trade >= 1 then
                trade = trade+1
            end
        elseif (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if trade >= 3 then
                trade = trade -1
            end
        end
        -- Well known highways happen after republic/democracy bonus.  They also happen after despotism
        -- penalty.  4 trade square (3+1 for road) becomes 4 after highway and despotism,
        --  4->3 (despotism)->4(highway)  Observed`
        --  4 -> 6 (highway) -> 5 (despotism) Not observed
        -- apply highways bonus
        if (gen.hasRoad(tile) or tile.city) and city:hasImprovement(civ.getImprovement(25)--[[@as improvementObject]]) then
            trade = (3*trade)//2
        end
        -- pollution occurs after highway bonus
        -- 6 trade (5+road) -> 9 (highway) -> 5 (pollution) observed
        -- 6 trade -> 3 (pollution) -> 4 (highway) NOT observed
        if gen.hasPollution(tile) then
            trade = trade - (trade//2)
        end

        -- pollution occurs after despotism penalty, since 6 ->5 ->3 and not 6->3->2
        -- a bit more detail is below with the pollution penalty for food
        --shields
        -- Apply mine bonus.  
        -- A city gives the mine bonus only if the irrigation bonus is 0
        if gen.hasMine(tile) or (tile.city and baseTerrainData.irrigateBonus == 0)  then
            shields = shields + baseTerrainData.mineBonus
        end
        -- grasslands without shields don't produce shields, except with KRC, which gives +1
        -- Or, the 1 shield minimum from being on a city square
        if baseTerrainData.type == 2 and not tile.grasslandShield then
            shields = 0
        end
        -- cities (except on ocean) guarantee 1 shield of production
        if tile.city then
            shields = math.max(1,shields)
        end
        -- KRC happens after 1 shield minimum, before the railroad bonus
        -- King Richard's Crusade
        if civ.getWonder(8).city == city and applyWonderBonus(civ.getWonder(8)--[[@as wonderObject]],city.owner) then
            shields = shields+1
        end
        if gen.hasRailroad(tile) or (tile.city and city.owner:hasTech(civ.getTech(67)--[[@as techObject]])) then
            shields = (3*shields)//2
        end
        -- despotism seems to happen after railroads
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if shields >= 3 then
                shields = shields -1
            end
        end
        -- pollution occurs after despotism penalty, since 6 ->5 ->3 and not 6->3->2
        -- a bit more detail is below with the pollution penalty for food
        if gen.hasPollution(tile) then
            shields = shields - (shields//2)
        end


        -- tiles with city or irrigation get the irrigation bonus, regardless of whether
        -- the tile can actually be irrigated
        if tile.city or gen.hasAgriculture(tile) then
            food = food + baseTerrainData.irrigateBonus
        end
        -- don't need refrigeration tech to take advantage of farm production, just supermarket
        -- city tile counts as farmland even without refrigeration
        if city:hasImprovement(civ.getImprovement(24)--[[@as improvementObject]]) and (tile.city or gen.hasFarmland(tile)) then
            food = (3*food)//2
        end

        -- 4 food production pre farmland results in 5 production after applying supermarket,
        -- meaning that the despotism penalty applies after supermarkets (6-1=5 instead of 3*3/2 = 4)
        if (tribeGovernment == 1 and not gen.isWeLoveTheKing(city)) or tribeGovernment == 0 then
            -- despotism penalty if wltkd not in place, or anarchy always
            if food >= 3 then
                food = food -1
            end
        end

        -- pollution occurs after farmland, since 6 food before farm becomes 9 with farm then
        -- 5 after pollution.  Pollution before farm would mean 6 becomes 3 with pollution, then
        -- 4 after pollution
        -- pollution occurs after despotism.  6 food becomes 5 with despotism, becomes 3 after pollution
        -- If pollution were factored before despotism, 6 would become 3, which would become 2,
        -- 6->5->3 holds with and without farmland
        if gen.hasPollution(tile) then
            food = food - (food//2)
        end
    end
    return food, shields, trade
end
local getTileProduction = gen.getTileProduction

-- gen.computeBaseProduction(city)-->integer(food), integer(shields), integer(trade)

-- Computes the resources harvested by the city from the terrain.
-- Includes superhighway/supermarket/railroad bonus, but not factories/power plants.
---@param city cityObject
---@param ignoreCustomCosmic? boolean # If true, do not use the customCosmic city customisation to get production, refer to the current settings of terrain, baseTerrain and roadTrade.  If false or nil, refer to customCosmic module if it is available (otherwise, refer to current settings of terrain, baseTerrain and roadTrade).
---@return integer foodProduction
---@return integer shieldProduction
---@return integer tradeProduction
function gen.computeBaseProduction(city,ignoreCustomCosmic)
    local tileList = gen.cityRadiusTiles(city)
    local cityWorkers = city.workers
    local foodTotal = 0
    local shieldTotal = 0
    local tradeTotal = 0
    for workerIndex,tile in pairs(tileList) do
        if isBit1(cityWorkers,workerIndex) then
            local tileFood,tileShields,tileTrade = getTileProduction(tile,city,ignoreCustomCosmic)
            foodTotal = foodTotal+tileFood
            shieldTotal = shieldTotal+tileShields
            tradeTotal = tradeTotal+tileTrade
            --print(tile.x,tile.y,tileShields, shieldTotal)
        end
    end
    return foodTotal,shieldTotal,tradeTotal
end

-- gen.persistentRandom(key) --> number between 0 and 1
-- Checks the persistentRandom table (within the state table)
-- for a value associated with key. If it exits, the value is
-- returned.  If it does not exist, a random number between
-- 0 and 1 is generated, stored in the table under the key,
-- and also returned.<br>
--
-- Example of use: WWII scenario with seasons
-- You may want to have some games where the 1941 spring starts
-- in April, and other games where it starts in May.  When
-- determining whether to load winter or summer terrain stats during
-- 1941, you would use gen.persistentRandom("EarlySpring1941") < 0.5
-- as part of the season check in April, and load summer if the value is less than 0.5
-- and winter otherwise.  This way, each when each player starts their
-- game that month, they will all either get winter or summer terrain.
---@param key string # Key for the persistent random value.
---@return number # number between 0 and 1
function gen.persistentRandom(key)
    genStateTable.persistentRandom[key] = genStateTable.persistentRandom[key] or math.random()
    return genStateTable.persistentRandom[key]
end

-- gen.clearPersistentRandom(key) --> void
-- Sets the value associated with the key in the
-- persistentRandom table to nil.  This could either be for reuse of the key,
-- or to prevent the key from staying in the state table indefinitely.
---@param key string
function gen.clearPersistentRandom(key)
    genStateTable.persistentRandom[key] = nil
end

-- gen.getPersistentRandomTable() --> table
-- Returns the persistentRandom table.
---@return table<string,number>
function gen.getPersistentRandomTable()
---@diagnostic disable-next-line: return-type-mismatch
    return genStateTable.persistentRandom
end


-- gen.mergeTableValues(table,table,...) --> table

--  Accepts an arbitrary number of tables as
--  arguments and returns a table with all
--  the values from all the tables.
--  Table keys are lost, and replaced by
--  integers starting at 1.
--  Duplicate values will appear multiple times.
---@param ... table
---@return table
function gen.mergeTableValues(...)
    local argTable = {...}
    local output = {}
    local index = 1
    for __,table in pairs(argTable) do
        for __,value in pairs(table) do
            output[index] = value
            index=index+1
        end
    end
    return output
end

--[[The gen.original table provides a way to refer to game objects using 
the names that they have in the original game.  This is important, 
since many game mechanics depend on the specific id number of the object
in question, and code is much more readable if it uses names
instead of numbers.

Reference: [Test of Time Advance Slot Properties](http://sleague.civfanatics.com/index.php?title=Test_of_Time_Advance_Slot_Properties)
Credits:
 - CyberChrist who contributed many clarifications.
 - Harlan Thompson and Leon Marrick upon whose ground breaking research this tip is founded.
 - Cam Hills who assisted in the page design.

]]
---@class gen.original
gen.original = {}
--[[
]]
gen.original.aAdvancedFlight          = civ.getTech(0) --[[@as techObject]]
--[[ Doubles the literacy demographics. This is cumulative with the effects of Writing, University, and Literacy.
]]
gen.original.aAlphabet                = civ.getTech(1) --[[@as techObject]]
--[[
]]
gen.original.aAmphibiousWarfare       = civ.getTech(2) --[[@as techObject]]
--[[
]]
gen.original.aAstronomy               = civ.getTech(3) --[[@as techObject]]
--[[
]]
gen.original.aAtomicTheory            = civ.getTech(4) --[[@as techObject]]
--[[ Increases population based pollution.
Automobile works with Electronics to change city pictures to the modern style (6th row in the cities.bmp file).

Automobile works with Electronics to change the look of people to the modern style (4th row in the people.bmp file).
]]
gen.original.aAutomobile              = civ.getTech(5) --[[@as techObject]]
--[[
]]
gen.original.aBanking                 = civ.getTech(6) --[[@as techObject]]
--[[ Allows settlers units to construct roads (and railroads) in river squares.
]]
gen.original.aBridgeBuilding          = civ.getTech(7) --[[@as techObject]]  
--[[
]]
gen.original.aBronzeWorking           = civ.getTech(8) --[[@as techObject]]
--[[ Ceremonial Burial allows temples to make one additional person content. See also Mysticism.
]]
gen.original.aCeremonialBurial        = civ.getTech(9) --[[@as techObject]]
--[[
]]
gen.original.aChemistry               = civ.getTech(10) --[[@as techObject]]
--[[ Changes the types of Barbarians produced by Goody Huts.
Changes the types of sea-based random Barbarians units produced.
]]
gen.original.aChivalry                = civ.getTech(11) --[[@as techObject]]
--[[
]]
gen.original.aCodeOfLaws              = civ.getTech(12) --[[@as techObject]]
--[[
]]
gen.original.aCodeofLaws              = civ.getTech(12) --[[@as techObject]]
--[[
]]
gen.original.aCombinedArms            = civ.getTech(13) --[[@as techObject]]
--[[
]]
gen.original.aCombustion              = civ.getTech(14) --[[@as techObject]]
--[[ Allows the government type of the same name.
The discovery of Communism reduces the effect of Cathedrals by one.

Cities produce more partisans.
]]
gen.original.aCommunism               = civ.getTech(15) --[[@as techObject]]
--[[
]]
gen.original.aComputers               = civ.getTech(16) --[[@as techObject]]
--[[ Changes the types of Barbarians produced by Goody Huts.
]]
gen.original.aConscription            = civ.getTech(17) --[[@as techObject]]
--[[ Construction allows settler units to build Fortresses.
]]
gen.original.aConstruction            = civ.getTech(18) --[[@as techObject]]
--[[
]]
gen.original.aCorporation             = civ.getTech(19) --[[@as techObject]]
--[[
]]
gen.original.aCurrency                = civ.getTech(20) --[[@as techObject]]
--[[ Allows the government type of the same name.
Courthouses make one content citizen happy if the nation is operating under Democracy. However, the Democracy advance is not required for this effect to take place.
]]
gen.original.aDemocracy               = civ.getTech(21) --[[@as techObject]]
--[[
]]
gen.original.aEconomics               = civ.getTech(22) --[[@as techObject]]
--[[
]]
gen.original.aElectricity             = civ.getTech(23) --[[@as techObject]]
--[[ After the discovery of Electronics an additional citizen in each city is made content by coliseums.
Electronics works with Automobile to change city pictures to the modern style (6th row in the cities.bmp file).

Electronics works with Automobile to change the look of people to the modern style (4th row in the people.bmp file).
]]
gen.original.aElectronics             = civ.getTech(24) --[[@as techObject]]
--[[
]]
gen.original.aEngineering             = civ.getTech(25) --[[@as techObject]]
--[[ Decreases population based pollution.
]]
gen.original.aEnvironmentalism        = civ.getTech(26) --[[@as techObject]]
--[[
]]
gen.original.aEspionage               = civ.getTech(27) --[[@as techObject]]
--[[ Contrary to popular belief, Explosives does NOT inherently allow transformation orders or display the "New Order: Transform" message.
The ability to transform is inherent to unit in the Engineer slot of the RULES.TXT file. When this unit first becomes available the message will be displayed.
]]
gen.original.aExplosives              = civ.getTech(28) --[[@as techObject]]
--[[
]]
gen.original.aFeudalism               = civ.getTech(29) --[[@as techObject]]
--[[ Reduces by one third the amount of gold and science produced by caravan delivery. This affect is cumulative with all other modifiers.
]]
gen.original.aFlight                  = civ.getTech(30) --[[@as techObject]]
--[[ Allows the government type of the same name.
The Fundamentalism advance does NOT inherently allow Fanatics to be build. Only nations operating under the Fundamentalism government can build the Fanatics unit once the advance making the Fanatics available has been discovered.

Upon changing government type from Fundamentalism to any other type all cities producing Fanatics will switch to producing the unit in the Riflemen slot whether or not the nation has the prerequisite advance to build this unit.
]]
gen.original.aFundamentalism          = civ.getTech(31) --[[@as techObject]]
--[[ Eliminates the threat of Nuclear Power Plant meltdown.
Adds 25% to spaceship mass/thrust paradigm.
]]
gen.original.aFusionPower             = civ.getTech(32) --[[@as techObject]]
--[[
]]
gen.original.aGeneticEngineering      = civ.getTech(33) --[[@as techObject]]
--[[ Captured cities produce partisan defenders.
Changes the types of Barbarians units produced by Goody Huts.

Changes the types of land-based random Barbarians units produced.
]]
gen.original.aGuerrillaWarfare        = civ.getTech(34) --[[@as techObject]]
--[[ Makes obsolete all defensive role units with a defence strength less than that of the unit in the musketeer slot of the RULES.TXT.
Sells all Barracks when discovered.

Increases Barracks maintenance cost by one (cumulative with Mobile Warfare).

Changes the types of Barbarians produced by Goody Huts.

Changes the types of land-based random Barbarians units produced.
]]
gen.original.aGunpowder               = civ.getTech(35) --[[@as techObject]]
--[[
]]
gen.original.aHorsebackRiding         = civ.getTech(36) --[[@as techObject]]
--[[ Changes city picture to industrial (5th row in cities.bmp) in any non-fantasy game.
Changes the look of people to industrial (3th row in people.bmp).

Changes the types of land-based random Barbarians units produced.

Increases population based pollution.

Upon discovery the Industrialization advance oil appears as a supplied trade commodity in most cities.
]]
gen.original.aIndustrialization       = civ.getTech(37) --[[@as techObject]]
--[[ Reduces by 50% the amount of gold and science produced by caravan delivery. This modifier is NOT cumulative with Navigation or the Turn 200 effect, but is cumulative with the reductions of Railroad and Flight.
Free advances can no longer be gained from goody huts.

Invention works with Philosophy to change the citizen look to the Renaissance style (2nd row in the people.bmp file).

''Non-Fan'': Invention changes city pictures to the Renaissance style (7th row in cities.bmp file).
]]
gen.original.aInvention               = civ.getTech(38) --[[@as techObject]]
--[[ Changes the types of Barbarians produced by Goody Huts.
Changes the types of sea-based random Barbarians units produced.
]]
gen.original.aIronWorking             = civ.getTech(39) --[[@as techObject]]
--[[
]]
gen.original.aLaborUnion              = civ.getTech(40) --[[@as techObject]]
--[[
]]
gen.original.aLaser                   = civ.getTech(41) --[[@as techObject]]
--[[ Changes the types of Barbarians produced by Goody Huts.
]]
gen.original.aLeadership              = civ.getTech(42) --[[@as techObject]]
--[[ Doubles literacy demographics. This is cumulative with the effects of Alphabet, Writing, and University.
]]
gen.original.aLiteracy                = civ.getTech(43) --[[@as techObject]]
--[[
]]
gen.original.aMachineTools            = civ.getTech(44) --[[@as techObject]]
--[[ Changes the vessel type of sea-based random Barbarians.
]]
gen.original.aMagnetism               = civ.getTech(45) --[[@as techObject]]
--[[ Allows civilizations to exchange maps.
]]
gen.original.aMapMaking               = civ.getTech(46) --[[@as techObject]]
--[[
]]
gen.original.aMasonry                 = civ.getTech(47) --[[@as techObject]]
--[[ Increases population based pollution.
]]
gen.original.aMassProduction          = civ.getTech(48) --[[@as techObject]]
--[[
]]
gen.original.aMathematics             = civ.getTech(49) --[[@as techObject]]
--[[ Decreases your people's disease percentage by half.
]]
gen.original.aMedicine                = civ.getTech(50) --[[@as techObject]]
--[[ Changes the types of Barbarians produced by Goody Huts.
]]
gen.original.aMetallurgy              = civ.getTech(51) --[[@as techObject]]
--[[
]]
gen.original.aMiniaturization         = civ.getTech(52) --[[@as techObject]]
--[[ Sells all barracks and increases barracks maintenance cost by one.
Changes the types of land-based random Barbarians units produced. Ends piracy. Barbarians no longer appear by sea.
]]
gen.original.aMobileWarfare           = civ.getTech(53) --[[@as techObject]]
--[[ Allows the government type of the same name.
]]
gen.original.aMonarchy                = civ.getTech(54) --[[@as techObject]]
--[[Monotheism allows Cathedrals to make three people content. Note that Cathedrals do not function without the discovery of Monotheism or Theology and Mysticism.
Changes the types of Barbarians produced by Goody Huts.
]]
gen.original.aMonotheism              = civ.getTech(55) --[[@as techObject]]
--[[ Mysticism allows temples to make one additional person content. See also Ceremonial Burial.
]]
gen.original.aMysticism               = civ.getTech(56) --[[@as techObject]]
--[[ Reduces by 50% the amount of gold and science produced by caravan delivery. This modifier is NOT cumulative with Invention or the Turn 200 effect, but is cumulative with the reductions of Railroad and Flight.
Navigation reduces the chances of triremes floundering.

Changes the vessel type of sea-based random Barbarians.
]]
gen.original.aNavigation              = civ.getTech(57) --[[@as techObject]]
--[[ Upon discovery the Nuclear Fission advance uranium appears as a demanded trade commodity in most cities. Uranium begins appearing as a supplied trade commodity in new founded cities.
]]
gen.original.aNuclearFission          = civ.getTech(58) --[[@as techObject]]
--[[ Nuclear Power increases the movement allowance of ships by one.
]]
gen.original.aNuclearPower            = civ.getTech(59) --[[@as techObject]]
--[[ The civilization that first discovers Philosophy gains a free advance.
Invention works with Philosophy to change the look of people to the Renaissance style (2nd row in the people.bmp file).
]]
gen.original.aPhilosophy              = civ.getTech(60) --[[@as techObject]]
--[[
]]
gen.original.aPhysics                 = civ.getTech(61) --[[@as techObject]]
--[[ Increases population based pollution.
]]
gen.original.aPlastics                = civ.getTech(62) --[[@as techObject]]
--[[
]]
gen.original.aPlumbing                = civ.getTech(63) --[[@as techObject]]
--[[ Changes the types of Barbarians produced by Goody Huts.
]]
gen.original.aPolytheism              = civ.getTech(64) --[[@as techObject]]
--[[
]]
gen.original.aPottery                 = civ.getTech(65) --[[@as techObject]]
--[[ Radio allows settlers and engineers to construct air bases.
Makes the Airlift command appear in the Orders menu. You can conduct airlifts without the Radio advance.

The message about Airlifts and Airstrips will be displayed whenever Airports become available and NOT when Radio is invented.
]]
gen.original.aRadio                   = civ.getTech(66) --[[@as techObject]]
--[[ Reduces by one third the amount of gold and science produced by caravan delivery. This affect is cumulative with all other modifiers.

Railroad allows settlers and engineers to build railroads.

All city squares are automatically upgraded to railroad.
]]
gen.original.aRailroad                = civ.getTech(67) --[[@as techObject]]
--[[
]]
gen.original.aRecycling               = civ.getTech(68) --[[@as techObject]]
--[[
]]
gen.original.aRefining                = civ.getTech(69) --[[@as techObject]]
--[[ Allows settlers and engineers to double-irrigate lands.
All city squares are automatically upgraded to farmland (double-irrigation) when Refrigeration is discovered.

The benefits of double-irrigation, 50% food production bonus, will only be realized once the city has built the Supermarket improvement. Interestingly, the Refrigeration advance is not needed for this to take effect.
]]
gen.original.aRefrigeration           = civ.getTech(70) --[[@as techObject]]
--[[ Allows the government type of the same name.
]]
gen.original.aRepublic                = civ.getTech(71) --[[@as techObject]]
--[[
]]
gen.original.aRobotics                = civ.getTech(72) --[[@as techObject]]
--[[
]]
gen.original.aRocketry                = civ.getTech(73) --[[@as techObject]]
--[[ Decreases population based pollution.
]]
gen.original.aSanitation              = civ.getTech(74) --[[@as techObject]]
--[[ Seafaring reduces the chances of triremes floundering.
]]
gen.original.aSeafaring               = civ.getTech(75) --[[@as techObject]]
--[[
]]
gen.original.aSpaceFlight             = civ.getTech(76) --[[@as techObject]]
--[[
]]
gen.original.aStealth                 = civ.getTech(77) --[[@as techObject]]
--[[
]]
gen.original.aSteamEngine             = civ.getTech(78) --[[@as techObject]]
--[[
]]
gen.original.aSteel                   = civ.getTech(79) --[[@as techObject]]
--[[
]]
gen.original.aSuperconductor          = civ.getTech(80) --[[@as techObject]]
--[[ Changes the types of sea-based random Barbarians units produced.
]]
gen.original.aTactics                 = civ.getTech(81) --[[@as techObject]]
--[[ Theology improves the effectiveness of Cathedrals by one.
]]
gen.original.aTheology                = civ.getTech(82) --[[@as techObject]]
--[[
]]
gen.original.aTheoryOfGravity         = civ.getTech(83) --[[@as techObject]]
--[[
]]
gen.original.aTheoryofGravity         = civ.getTech(83) --[[@as techObject]]
--[[ Enables the display of demanded trade goods of foreign cities.
]]
gen.original.aTrade                   = civ.getTech(84) --[[@as techObject]]
--[[ Doubles literacy demographics. This is cumulative with the effects of Alphabet, Writing, and Literacy.
]]
gen.original.aUniversity              = civ.getTech(85) --[[@as techObject]]
--[[
]]
gen.original.aWarriorCode             = civ.getTech(86) --[[@as techObject]]
--[[
]]
gen.original.aWheel                   = civ.getTech(87) --[[@as techObject]]
--[[ Doubles the literacy demographics. This is cumulative with the effects of Alphabet, University, and Literacy.
]]
gen.original.aWriting                 = civ.getTech(88) --[[@as techObject]]
--[[ Reoccurring technology.
Increases game score by five points.
]]
gen.original.aFutureTechnology        = civ.getTech(89) --[[@as techObject]]
--[[
]]
gen.original.aUserDefTechA            = civ.getTech(90) --[[@as techObject]]
--[[ ''Fantasy'': Changes city picture to Modern (6th row in cities.bmp).
]]
gen.original.aUserDefTechB            = civ.getTech(91) --[[@as techObject]]
--[[
]]
gen.original.aUserDefTechC            = civ.getTech(92) --[[@as techObject]]
--[[ ''Fantasy'': Changes city picture to Industrial (5th row in cities.bmp).
]]
gen.original.aExtraAdvance1           = civ.getTech(93) --[[@as techObject]]
--[[ ''Fantasy'': Changes city picture to Alternate Modern (7th row in cities.bmp).
]]
gen.original.aExtraAdvance2           = civ.getTech(94) --[[@as techObject]]
--[[
]]
gen.original.aExtraAdvance3           = civ.getTech(95) --[[@as techObject]]
--[[
]]
gen.original.aExtraAdvance4           = civ.getTech(96) --[[@as techObject]]
--[[
]]
gen.original.aExtraAdvance5           = civ.getTech(97) --[[@as techObject]]
--[[
]]
gen.original.aExtraAdvance6           = civ.getTech(98) --[[@as techObject]]
--[[
]]
gen.original.aExtraAdvance7           = civ.getTech(99) --[[@as techObject]]
gen.original.uSettlers                = civ.getUnitType(0) --[[@as unitTypeObject]]
gen.original.uEngineers               = civ.getUnitType(1) --[[@as unitTypeObject]]   --Engineers
gen.original.uWarriors                = civ.getUnitType(2) --[[@as unitTypeObject]]
gen.original.uPhalanx                 = civ.getUnitType(3) --[[@as unitTypeObject]]
gen.original.uArchers                 = civ.getUnitType(4) --[[@as unitTypeObject]]
gen.original.uLegion                  = civ.getUnitType(5) --[[@as unitTypeObject]]
gen.original.uPikemen                 = civ.getUnitType(6) --[[@as unitTypeObject]]
gen.original.uMusketeers              = civ.getUnitType(7) --[[@as unitTypeObject]]
gen.original.uFanatics                = civ.getUnitType(8) --[[@as unitTypeObject]]
gen.original.uPartisans               = civ.getUnitType(9) --[[@as unitTypeObject]]
gen.original.uAlpineTroops            = civ.getUnitType(10) --[[@as unitTypeObject]]
gen.original.uRiflemen                = civ.getUnitType(11) --[[@as unitTypeObject]]
gen.original.uMarines                 = civ.getUnitType(12) --[[@as unitTypeObject]]
gen.original.uParatroopers            = civ.getUnitType(13) --[[@as unitTypeObject]]
gen.original.uMechInf                 = civ.getUnitType(14) --[[@as unitTypeObject]]
gen.original.uHorsemen                = civ.getUnitType(15) --[[@as unitTypeObject]]
gen.original.uChariot                 = civ.getUnitType(16) --[[@as unitTypeObject]]
gen.original.uElephant                = civ.getUnitType(17) --[[@as unitTypeObject]]
gen.original.uCrusaders               = civ.getUnitType(18) --[[@as unitTypeObject]]
gen.original.uKnights                 = civ.getUnitType(19) --[[@as unitTypeObject]]
gen.original.uDragoons                = civ.getUnitType(20) --[[@as unitTypeObject]]
gen.original.uCavalry                 = civ.getUnitType(21) --[[@as unitTypeObject]]
gen.original.uArmor                   = civ.getUnitType(22) --[[@as unitTypeObject]]
gen.original.uCatapult                = civ.getUnitType(23) --[[@as unitTypeObject]]
gen.original.uCannon                  = civ.getUnitType(24) --[[@as unitTypeObject]]
gen.original.uArtillery               = civ.getUnitType(25) --[[@as unitTypeObject]]
gen.original.uHowitzer                = civ.getUnitType(26) --[[@as unitTypeObject]]
gen.original.uFighter                 = civ.getUnitType(27) --[[@as unitTypeObject]]
gen.original.uBomber                  = civ.getUnitType(28) --[[@as unitTypeObject]]
gen.original.uHelicopter              = civ.getUnitType(29) --[[@as unitTypeObject]]
gen.original.uStlthFtr                = civ.getUnitType(30) --[[@as unitTypeObject]]
gen.original.uStlthBmbr               = civ.getUnitType(31) --[[@as unitTypeObject]]
gen.original.uTrireme                 = civ.getUnitType(32) --[[@as unitTypeObject]]
gen.original.uCaravel                 = civ.getUnitType(33) --[[@as unitTypeObject]]
gen.original.uGalleon                 = civ.getUnitType(34) --[[@as unitTypeObject]]
gen.original.uFrigate                 = civ.getUnitType(35) --[[@as unitTypeObject]]
gen.original.uIronclad                = civ.getUnitType(36) --[[@as unitTypeObject]]
gen.original.uDestroyer               = civ.getUnitType(37) --[[@as unitTypeObject]]
gen.original.uCruiser                 = civ.getUnitType(38) --[[@as unitTypeObject]]
gen.original.uAEGISCruiser            = civ.getUnitType(39) --[[@as unitTypeObject]]
gen.original.uBattleship              = civ.getUnitType(40) --[[@as unitTypeObject]]
gen.original.uSubmarine               = civ.getUnitType(41) --[[@as unitTypeObject]]
gen.original.uCarrier                 = civ.getUnitType(42) --[[@as unitTypeObject]]
gen.original.uTransport               = civ.getUnitType(43) --[[@as unitTypeObject]]
gen.original.uCruiseMsl               = civ.getUnitType(44) --[[@as unitTypeObject]]
gen.original.uNuclearMsl              = civ.getUnitType(45) --[[@as unitTypeObject]]   --Nuclear Msl
gen.original.uDiplomat                = civ.getUnitType(46) --[[@as unitTypeObject]]
gen.original.uSpy                     = civ.getUnitType(47) --[[@as unitTypeObject]]   --Spy
gen.original.uCaravan                 = civ.getUnitType(48) --[[@as unitTypeObject]]
gen.original.uFreight                 = civ.getUnitType(49) --[[@as unitTypeObject]]   --Freight
gen.original.uExplorer                = civ.getUnitType(50) --[[@as unitTypeObject]]
gen.original.uExtraLand               = civ.getUnitType(51) --[[@as unitTypeObject]]
gen.original.uExtraShip               = civ.getUnitType(52) --[[@as unitTypeObject]]
gen.original.uExtraAir                = civ.getUnitType(53) --[[@as unitTypeObject]]
gen.original.iNothing                 = civ.getImprovement(0) --[[@as improvementObject]]
gen.original.iPalace                  = civ.getImprovement(1) --[[@as improvementObject]]
gen.original.iBarracks                = civ.getImprovement(2) --[[@as improvementObject]]
gen.original.iGranary                 = civ.getImprovement(3) --[[@as improvementObject]]
gen.original.iTemple                  = civ.getImprovement(4) --[[@as improvementObject]]
gen.original.iMarketPlace             = civ.getImprovement(5) --[[@as improvementObject]]
gen.original.iLibrary                 = civ.getImprovement(6) --[[@as improvementObject]]
gen.original.iCourthouse              = civ.getImprovement(7) --[[@as improvementObject]]
gen.original.iCityWalls               = civ.getImprovement(8) --[[@as improvementObject]]
gen.original.iAqueduct                = civ.getImprovement(9) --[[@as improvementObject]]
gen.original.iBank                    = civ.getImprovement(10) --[[@as improvementObject]]
gen.original.iCathedral               = civ.getImprovement(11) --[[@as improvementObject]]
gen.original.iUniversity              = civ.getImprovement(12) --[[@as improvementObject]]
gen.original.iMassTransit             = civ.getImprovement(13) --[[@as improvementObject]]
gen.original.iColosseum               = civ.getImprovement(14) --[[@as improvementObject]]
gen.original.iFactory                 = civ.getImprovement(15) --[[@as improvementObject]]
gen.original.iManufacturingPlant      = civ.getImprovement(16) --[[@as improvementObject]]
gen.original.iSDIDefense              = civ.getImprovement(17) --[[@as improvementObject]]
gen.original.iRecyclingCenter         = civ.getImprovement(18) --[[@as improvementObject]]
gen.original.iPowerPlant              = civ.getImprovement(19) --[[@as improvementObject]]
gen.original.iHydroPlant              = civ.getImprovement(20) --[[@as improvementObject]]
gen.original.iNuclearPlant            = civ.getImprovement(21) --[[@as improvementObject]]
gen.original.iStockExchange           = civ.getImprovement(22) --[[@as improvementObject]]
gen.original.iSewerSystem             = civ.getImprovement(23) --[[@as improvementObject]]
gen.original.iSupermarket             = civ.getImprovement(24) --[[@as improvementObject]]
gen.original.iSuperhighways           = civ.getImprovement(25) --[[@as improvementObject]]
gen.original.iResearchLab             = civ.getImprovement(26) --[[@as improvementObject]]
gen.original.iSAMMissileBattery       = civ.getImprovement(27) --[[@as improvementObject]]
gen.original.iCoastalFortress         = civ.getImprovement(28) --[[@as improvementObject]]
gen.original.iSolarPlant              = civ.getImprovement(29) --[[@as improvementObject]]
gen.original.iHarbor                  = civ.getImprovement(30) --[[@as improvementObject]]
gen.original.iOffshorePlatform        = civ.getImprovement(31) --[[@as improvementObject]]
gen.original.iAirport                 = civ.getImprovement(32) --[[@as improvementObject]]
gen.original.iPoliceStation           = civ.getImprovement(33) --[[@as improvementObject]]
gen.original.iPortFacility            = civ.getImprovement(34) --[[@as improvementObject]]
gen.original.iTransporter             = civ.getImprovement(35) --[[@as improvementObject]]
gen.original.iSSStructural            = civ.getImprovement(36) --[[@as improvementObject]]
gen.original.iSSComponent             = civ.getImprovement(37) --[[@as improvementObject]]
gen.original.iSSModule                = civ.getImprovement(38) --[[@as improvementObject]]
gen.original.iCapitalization          = civ.getImprovement(39) --[[@as improvementObject]]
gen.original.wPyramids                = civ.getWonder(0) --[[@as wonderObject]]
gen.original.wHangingGardens          = civ.getWonder(1) --[[@as wonderObject]]
gen.original.wColossus                = civ.getWonder(2) --[[@as wonderObject]]
gen.original.wLighthouse              = civ.getWonder(3) --[[@as wonderObject]]
gen.original.wGreatLibrary            = civ.getWonder(4) --[[@as wonderObject]]
gen.original.wOracle                  = civ.getWonder(5) --[[@as wonderObject]]
gen.original.wGreatWall               = civ.getWonder(6) --[[@as wonderObject]]
gen.original.wSunTzusWarAcademy       = civ.getWonder(7) --[[@as wonderObject]]
gen.original.wKingRichardsCrusade     = civ.getWonder(8) --[[@as wonderObject]]
gen.original.wMarcoPolosEmbassy       = civ.getWonder(9) --[[@as wonderObject]]
gen.original.wMichelangelosChapel     = civ.getWonder(10) --[[@as wonderObject]]
gen.original.wCopernicusObservatory   = civ.getWonder(11) --[[@as wonderObject]]
gen.original.wMagellansExpedition     = civ.getWonder(12) --[[@as wonderObject]]
gen.original.wShakespearesTheatre     = civ.getWonder(13) --[[@as wonderObject]]
gen.original.wLeonardosWorkshop       = civ.getWonder(14) --[[@as wonderObject]]
gen.original.wJSBachsCathedral        = civ.getWonder(15) --[[@as wonderObject]]
gen.original.wIsaacNewtonsCollege     = civ.getWonder(16) --[[@as wonderObject]]
gen.original.wAdamSmithsTradingCo     = civ.getWonder(17) --[[@as wonderObject]]
gen.original.wDarwinsVoyage           = civ.getWonder(18) --[[@as wonderObject]]
gen.original.wStatueofLiberty         = civ.getWonder(19) --[[@as wonderObject]]
gen.original.wEiffelTower             = civ.getWonder(20) --[[@as wonderObject]]
gen.original.wWomensSuffrage          = civ.getWonder(21) --[[@as wonderObject]]
gen.original.wHooverDam               = civ.getWonder(22) --[[@as wonderObject]]
gen.original.wManhattanProject        = civ.getWonder(23) --[[@as wonderObject]]
gen.original.wUnitedNations           = civ.getWonder(24) --[[@as wonderObject]]
gen.original.wApolloProgram           = civ.getWonder(25) --[[@as wonderObject]]
gen.original.wSETIProgram             = civ.getWonder(26) --[[@as wonderObject]]
gen.original.wCureforCancer           = civ.getWonder(27) --[[@as wonderObject]]
gen.original.bDesert                  =civ.getBaseTerrain(0,0)  --Drt
gen.original.bPlains                  =civ.getBaseTerrain(0,1)  --Pln
gen.original.bGrassland               =civ.getBaseTerrain(0,2)  --Grs
gen.original.bForest                  =civ.getBaseTerrain(0,3)  --For
gen.original.bHills                   =civ.getBaseTerrain(0,4)  --Hil
gen.original.bMountains               =civ.getBaseTerrain(0,5)  --Mou
gen.original.bTundra                  =civ.getBaseTerrain(0,6)  --Tun
gen.original.bGlacier                 =civ.getBaseTerrain(0,7)  --Gla
gen.original.bSwamp                   =civ.getBaseTerrain(0,8)  --Swa
gen.original.bJungle                  =civ.getBaseTerrain(0,9)  --Jun
gen.original.bOcean                   =civ.getBaseTerrain(0,10)  --Oce
gen.original.tDesert                  =civ.getTerrain(0,0,0)
gen.original.tOasis                   =civ.getTerrain(0,0,1) -- Fish Resource
gen.original.tDesertOil               =civ.getTerrain(0,0,2) -- Whale Resource
gen.original.tPlains                  =civ.getTerrain(0,1,0)
gen.original.tBuffalo                 =civ.getTerrain(0,1,1) -- Fish Resource
gen.original.tWheat                   =civ.getTerrain(0,1,2) -- Whale Resource
gen.original.tGrassland               =civ.getTerrain(0,2,0)
gen.original.tForest                  =civ.getTerrain(0,3,0)
gen.original.tPheasant                =civ.getTerrain(0,3,1) -- Fish Resource
gen.original.tSilk                    =civ.getTerrain(0,3,2) -- Whale Resource
gen.original.tHills                   =civ.getTerrain(0,4,0)
gen.original.tCoal                    =civ.getTerrain(0,4,1) -- Fish Resource
gen.original.tWine                    =civ.getTerrain(0,4,2) -- Whale Resource
gen.original.tMountains               =civ.getTerrain(0,5,0)
gen.original.tGold                    =civ.getTerrain(0,5,1) -- Fish Resource
gen.original.tIron                    =civ.getTerrain(0,5,2) -- Whale Resource
gen.original.tTundra                  =civ.getTerrain(0,6,0)
gen.original.tGame                    =civ.getTerrain(0,6,1) -- Fish Resource
gen.original.tFurs                    =civ.getTerrain(0,6,2) -- Whale Resource
gen.original.tGlacier                 =civ.getTerrain(0,7,0)
gen.original.tIvory                   =civ.getTerrain(0,7,1) -- Fish Resource
gen.original.tGlacierOil              =civ.getTerrain(0,7,2) -- Whale Resource
gen.original.tSwamp                   =civ.getTerrain(0,8,0)
gen.original.tPeat                    =civ.getTerrain(0,8,1) -- Fish Resource
gen.original.tSpice                   =civ.getTerrain(0,8,2) -- Whale Resource
gen.original.tJungle                  =civ.getTerrain(0,9,0)
gen.original.tGems                    =civ.getTerrain(0,9,1) -- Fish Resource
gen.original.tFruit                   =civ.getTerrain(0,9,2) -- Whale Resource
gen.original.tOcean                   =civ.getTerrain(0,10,0)
gen.original.tFish                    =civ.getTerrain(0,10,1) -- Fish Resource
gen.original.tWhales                  =civ.getTerrain(0,10,2) -- Whale Resource
--]=]

gen.errorForNilKey(gen.original, "gen.original")

--[=[
gen.original = {
aAdvancedFlight          = civ.getTech(0) --[[@as techObject]],
aAlphabet                = civ.getTech(1) --[[@as techObject]],
aAmphibiousWarfare       = civ.getTech(2) --[[@as techObject]],
aAstronomy               = civ.getTech(3) --[[@as techObject]],
aAtomicTheory            = civ.getTech(4) --[[@as techObject]],
aAutomobile              = civ.getTech(5) --[[@as techObject]],   --Automobile
aBanking                 = civ.getTech(6) --[[@as techObject]],
aBridgeBuilding          = civ.getTech(7) --[[@as techObject]],   --Bridge Building
aBronzeWorking           = civ.getTech(8) --[[@as techObject]],
aCeremonialBurial        = civ.getTech(9) --[[@as techObject]],
aChemistry               = civ.getTech(10) --[[@as techObject]],
aChivalry                = civ.getTech(11) --[[@as techObject]],
aCodeofLaws              = civ.getTech(12) --[[@as techObject]],
aCodeOfLaws              = civ.getTech(12) --[[@as techObject]],
aCombinedArms            = civ.getTech(13) --[[@as techObject]],
aCombustion              = civ.getTech(14) --[[@as techObject]],
aCommunism               = civ.getTech(15) --[[@as techObject]],
aComputers               = civ.getTech(16) --[[@as techObject]],
aConscription            = civ.getTech(17) --[[@as techObject]],
aConstruction            = civ.getTech(18) --[[@as techObject]],
aCorporation             = civ.getTech(19) --[[@as techObject]],
aCurrency                = civ.getTech(20) --[[@as techObject]],
aDemocracy               = civ.getTech(21) --[[@as techObject]],
aEconomics               = civ.getTech(22) --[[@as techObject]],
aElectricity             = civ.getTech(23) --[[@as techObject]],
aElectronics             = civ.getTech(24) --[[@as techObject]],
aEngineering             = civ.getTech(25) --[[@as techObject]],
aEnvironmentalism        = civ.getTech(26) --[[@as techObject]],
aEspionage               = civ.getTech(27) --[[@as techObject]],
aExplosives              = civ.getTech(28) --[[@as techObject]],
aFeudalism               = civ.getTech(29) --[[@as techObject]],
aFlight                  = civ.getTech(30) --[[@as techObject]],
aFundamentalism          = civ.getTech(31) --[[@as techObject]],
aFusionPower             = civ.getTech(32) --[[@as techObject]],
aGeneticEngineering      = civ.getTech(33) --[[@as techObject]],
aGuerrillaWarfare        = civ.getTech(34) --[[@as techObject]],
aGunpowder               = civ.getTech(35) --[[@as techObject]],
aHorsebackRiding         = civ.getTech(36) --[[@as techObject]],
aIndustrialization       = civ.getTech(37) --[[@as techObject]],
aInvention               = civ.getTech(38) --[[@as techObject]],
aIronWorking             = civ.getTech(39) --[[@as techObject]],
aLaborUnion              = civ.getTech(40) --[[@as techObject]],
aLaser                   = civ.getTech(41) --[[@as techObject]],
aLeadership              = civ.getTech(42) --[[@as techObject]],
aLiteracy                = civ.getTech(43) --[[@as techObject]],
aMachineTools            = civ.getTech(44) --[[@as techObject]],
aMagnetism               = civ.getTech(45) --[[@as techObject]],
aMapMaking               = civ.getTech(46) --[[@as techObject]],
aMasonry                 = civ.getTech(47) --[[@as techObject]],
aMassProduction          = civ.getTech(48) --[[@as techObject]],
aMathematics             = civ.getTech(49) --[[@as techObject]],
aMedicine                = civ.getTech(50) --[[@as techObject]],
aMetallurgy              = civ.getTech(51) --[[@as techObject]],
aMiniaturization         = civ.getTech(52) --[[@as techObject]],
aMobileWarfare           = civ.getTech(53) --[[@as techObject]],
aMonarchy                = civ.getTech(54) --[[@as techObject]],
aMonotheism              = civ.getTech(55) --[[@as techObject]],
aMysticism               = civ.getTech(56) --[[@as techObject]],
aNavigation              = civ.getTech(57) --[[@as techObject]],
aNuclearFission          = civ.getTech(58) --[[@as techObject]],
aNuclearPower            = civ.getTech(59) --[[@as techObject]],
aPhilosophy              = civ.getTech(60) --[[@as techObject]],
aPhysics                 = civ.getTech(61) --[[@as techObject]],
aPlastics                = civ.getTech(62) --[[@as techObject]],
aPlumbing                = civ.getTech(63) --[[@as techObject]],
aPolytheism              = civ.getTech(64) --[[@as techObject]],
aPottery                 = civ.getTech(65) --[[@as techObject]],
aRadio                   = civ.getTech(66) --[[@as techObject]],
aRailroad                = civ.getTech(67) --[[@as techObject]],
aRecycling               = civ.getTech(68) --[[@as techObject]],
aRefining                = civ.getTech(69) --[[@as techObject]],
aRefrigeration           = civ.getTech(70) --[[@as techObject]],
aRepublic                = civ.getTech(71) --[[@as techObject]],
aRobotics                = civ.getTech(72) --[[@as techObject]],
aRocketry                = civ.getTech(73) --[[@as techObject]],
aSanitation              = civ.getTech(74) --[[@as techObject]],
aSeafaring               = civ.getTech(75) --[[@as techObject]],
aSpaceFlight             = civ.getTech(76) --[[@as techObject]],
aStealth                 = civ.getTech(77) --[[@as techObject]],
aSteamEngine             = civ.getTech(78) --[[@as techObject]],
aSteel                   = civ.getTech(79) --[[@as techObject]],
aSuperconductor          = civ.getTech(80) --[[@as techObject]],
aTactics                 = civ.getTech(81) --[[@as techObject]],
aTheology                = civ.getTech(82) --[[@as techObject]],
aTheoryofGravity         = civ.getTech(83) --[[@as techObject]],
aTheoryOfGravity         = civ.getTech(83) --[[@as techObject]],
aTrade                   = civ.getTech(84) --[[@as techObject]],
aUniversity              = civ.getTech(85) --[[@as techObject]],
aWarriorCode             = civ.getTech(86) --[[@as techObject]],
aWheel                   = civ.getTech(87) --[[@as techObject]],
aWriting                 = civ.getTech(88) --[[@as techObject]],
aFutureTechnology        = civ.getTech(89) --[[@as techObject]],
aUserDefTechA            = civ.getTech(90) --[[@as techObject]],
aUserDefTechB            = civ.getTech(91) --[[@as techObject]],
aUserDefTechC            = civ.getTech(92) --[[@as techObject]],
aExtraAdvance1           = civ.getTech(93) --[[@as techObject]],
aExtraAdvance2           = civ.getTech(94) --[[@as techObject]],
aExtraAdvance3           = civ.getTech(95) --[[@as techObject]],
aExtraAdvance4           = civ.getTech(96) --[[@as techObject]],
aExtraAdvance5           = civ.getTech(97) --[[@as techObject]],
aExtraAdvance6           = civ.getTech(98) --[[@as techObject]],
aExtraAdvance7           = civ.getTech(99) --[[@as techObject]],
uSettlers                = civ.getUnitType(0) --[[@as unitTypeObject]],
uEngineers               = civ.getUnitType(1) --[[@as unitTypeObject]],   --Engineers,
uWarriors                = civ.getUnitType(2) --[[@as unitTypeObject]],
uPhalanx                 = civ.getUnitType(3) --[[@as unitTypeObject]],
uArchers                 = civ.getUnitType(4) --[[@as unitTypeObject]],
uLegion                  = civ.getUnitType(5) --[[@as unitTypeObject]],
uPikemen                 = civ.getUnitType(6) --[[@as unitTypeObject]],
uMusketeers              = civ.getUnitType(7) --[[@as unitTypeObject]],
uFanatics                = civ.getUnitType(8) --[[@as unitTypeObject]],
uPartisans               = civ.getUnitType(9) --[[@as unitTypeObject]],
uAlpineTroops            = civ.getUnitType(10) --[[@as unitTypeObject]],
uRiflemen                = civ.getUnitType(11) --[[@as unitTypeObject]],
uMarines                 = civ.getUnitType(12) --[[@as unitTypeObject]],
uParatroopers            = civ.getUnitType(13) --[[@as unitTypeObject]],
uMechInf                 = civ.getUnitType(14) --[[@as unitTypeObject]],
uHorsemen                = civ.getUnitType(15) --[[@as unitTypeObject]],
uChariot                 = civ.getUnitType(16) --[[@as unitTypeObject]],
uElephant                = civ.getUnitType(17) --[[@as unitTypeObject]],
uCrusaders               = civ.getUnitType(18) --[[@as unitTypeObject]],
uKnights                 = civ.getUnitType(19) --[[@as unitTypeObject]],
uDragoons                = civ.getUnitType(20) --[[@as unitTypeObject]],
uCavalry                 = civ.getUnitType(21) --[[@as unitTypeObject]],
uArmor                   = civ.getUnitType(22) --[[@as unitTypeObject]],
uCatapult                = civ.getUnitType(23) --[[@as unitTypeObject]],
uCannon                  = civ.getUnitType(24) --[[@as unitTypeObject]],
uArtillery               = civ.getUnitType(25) --[[@as unitTypeObject]],
uHowitzer                = civ.getUnitType(26) --[[@as unitTypeObject]],
uFighter                 = civ.getUnitType(27) --[[@as unitTypeObject]],
uBomber                  = civ.getUnitType(28) --[[@as unitTypeObject]],
uHelicopter              = civ.getUnitType(29) --[[@as unitTypeObject]],
uStlthFtr                = civ.getUnitType(30) --[[@as unitTypeObject]],
uStlthBmbr               = civ.getUnitType(31) --[[@as unitTypeObject]],
uTrireme                 = civ.getUnitType(32) --[[@as unitTypeObject]],
uCaravel                 = civ.getUnitType(33) --[[@as unitTypeObject]],
uGalleon                 = civ.getUnitType(34) --[[@as unitTypeObject]],
uFrigate                 = civ.getUnitType(35) --[[@as unitTypeObject]],
uIronclad                = civ.getUnitType(36) --[[@as unitTypeObject]],
uDestroyer               = civ.getUnitType(37) --[[@as unitTypeObject]],
uCruiser                 = civ.getUnitType(38) --[[@as unitTypeObject]],
uAEGISCruiser            = civ.getUnitType(39) --[[@as unitTypeObject]],
uBattleship              = civ.getUnitType(40) --[[@as unitTypeObject]],
uSubmarine               = civ.getUnitType(41) --[[@as unitTypeObject]],
uCarrier                 = civ.getUnitType(42) --[[@as unitTypeObject]],
uTransport               = civ.getUnitType(43) --[[@as unitTypeObject]],
uCruiseMsl               = civ.getUnitType(44) --[[@as unitTypeObject]],
uNuclearMsl              = civ.getUnitType(45) --[[@as unitTypeObject]],   --Nuclear Msl,
uDiplomat                = civ.getUnitType(46) --[[@as unitTypeObject]],
uSpy                     = civ.getUnitType(47) --[[@as unitTypeObject]],   --Spy,
uCaravan                 = civ.getUnitType(48) --[[@as unitTypeObject]],
uFreight                 = civ.getUnitType(49) --[[@as unitTypeObject]],   --Freight,
uExplorer                = civ.getUnitType(50) --[[@as unitTypeObject]],
uExtraLand               = civ.getUnitType(51) --[[@as unitTypeObject]],
uExtraShip               = civ.getUnitType(52) --[[@as unitTypeObject]],
uExtraAir                = civ.getUnitType(53) --[[@as unitTypeObject]],
iNothing                 = civ.getImprovement(0) --[[@as improvementObject]],
iPalace                  = civ.getImprovement(1) --[[@as improvementObject]],
iBarracks                = civ.getImprovement(2) --[[@as improvementObject]],
iGranary                 = civ.getImprovement(3) --[[@as improvementObject]],
iTemple                  = civ.getImprovement(4) --[[@as improvementObject]],
iMarketPlace             = civ.getImprovement(5) --[[@as improvementObject]],
iLibrary                 = civ.getImprovement(6) --[[@as improvementObject]],
iCourthouse              = civ.getImprovement(7) --[[@as improvementObject]],
iCityWalls               = civ.getImprovement(8) --[[@as improvementObject]],
iAqueduct                = civ.getImprovement(9) --[[@as improvementObject]],
iBank                    = civ.getImprovement(10) --[[@as improvementObject]],
iCathedral               = civ.getImprovement(11) --[[@as improvementObject]],
iUniversity              = civ.getImprovement(12) --[[@as improvementObject]],
iMassTransit             = civ.getImprovement(13) --[[@as improvementObject]],
iColosseum               = civ.getImprovement(14) --[[@as improvementObject]],
iFactory                 = civ.getImprovement(15) --[[@as improvementObject]],
iManufacturingPlant      = civ.getImprovement(16) --[[@as improvementObject]],
iSDIDefense              = civ.getImprovement(17) --[[@as improvementObject]],
iRecyclingCenter         = civ.getImprovement(18) --[[@as improvementObject]],
iPowerPlant              = civ.getImprovement(19) --[[@as improvementObject]],
iHydroPlant              = civ.getImprovement(20) --[[@as improvementObject]],
iNuclearPlant            = civ.getImprovement(21) --[[@as improvementObject]],
iStockExchange           = civ.getImprovement(22) --[[@as improvementObject]],
iSewerSystem             = civ.getImprovement(23) --[[@as improvementObject]],
iSupermarket             = civ.getImprovement(24) --[[@as improvementObject]],
iSuperhighways           = civ.getImprovement(25) --[[@as improvementObject]],
iResearchLab             = civ.getImprovement(26) --[[@as improvementObject]],
iSAMMissileBattery       = civ.getImprovement(27) --[[@as improvementObject]],
iCoastalFortress         = civ.getImprovement(28) --[[@as improvementObject]],
iSolarPlant              = civ.getImprovement(29) --[[@as improvementObject]],
iHarbor                  = civ.getImprovement(30) --[[@as improvementObject]],
iOffshorePlatform        = civ.getImprovement(31) --[[@as improvementObject]],
iAirport                 = civ.getImprovement(32) --[[@as improvementObject]],
iPoliceStation           = civ.getImprovement(33) --[[@as improvementObject]],
iPortFacility            = civ.getImprovement(34) --[[@as improvementObject]],
iTransporter             = civ.getImprovement(35) --[[@as improvementObject]],
wPyramids                = civ.getWonder(0) --[[@as wonderObject]],
wHangingGardens          = civ.getWonder(1) --[[@as wonderObject]],
wColossus                = civ.getWonder(2) --[[@as wonderObject]],
wLighthouse              = civ.getWonder(3) --[[@as wonderObject]],
wGreatLibrary            = civ.getWonder(4) --[[@as wonderObject]],
wOracle                  = civ.getWonder(5) --[[@as wonderObject]],
wGreatWall               = civ.getWonder(6) --[[@as wonderObject]],
wSunTzusWarAcademy       = civ.getWonder(7) --[[@as wonderObject]],
wKingRichardsCrusade     = civ.getWonder(8) --[[@as wonderObject]],
wMarcoPolosEmbassy       = civ.getWonder(9) --[[@as wonderObject]],
wMichelangelosChapel     = civ.getWonder(10) --[[@as wonderObject]],
wCopernicusObservatory   = civ.getWonder(11) --[[@as wonderObject]],
wMagellansExpedition     = civ.getWonder(12) --[[@as wonderObject]],
wShakespearesTheatre     = civ.getWonder(13) --[[@as wonderObject]],
wLeonardosWorkshop       = civ.getWonder(14) --[[@as wonderObject]],
wJSBachsCathedral        = civ.getWonder(15) --[[@as wonderObject]],
wIsaacNewtonsCollege     = civ.getWonder(16) --[[@as wonderObject]],
wAdamSmithsTradingCo     = civ.getWonder(17) --[[@as wonderObject]],
wDarwinsVoyage           = civ.getWonder(18) --[[@as wonderObject]],
wStatueofLiberty         = civ.getWonder(19) --[[@as wonderObject]],
wEiffelTower             = civ.getWonder(20) --[[@as wonderObject]],
wWomensSuffrage          = civ.getWonder(21) --[[@as wonderObject]],
wHooverDam               = civ.getWonder(22) --[[@as wonderObject]],
wManhattanProject        = civ.getWonder(23) --[[@as wonderObject]],
wUnitedNations           = civ.getWonder(24) --[[@as wonderObject]],
wApolloProgram           = civ.getWonder(25) --[[@as wonderObject]],
wSETIProgram             = civ.getWonder(26) --[[@as wonderObject]],
wCureforCancer           = civ.getWonder(27) --[[@as wonderObject]],
bDesert                  =civ.getBaseTerrain(0,0),  --Drt,
bPlains                  =civ.getBaseTerrain(0,1),  --Pln,
bGrassland               =civ.getBaseTerrain(0,2),  --Grs,
bForest                  =civ.getBaseTerrain(0,3),  --For,
bHills                   =civ.getBaseTerrain(0,4),  --Hil,
bMountains               =civ.getBaseTerrain(0,5),  --Mou,
bTundra                  =civ.getBaseTerrain(0,6),  --Tun,
bGlacier                 =civ.getBaseTerrain(0,7),  --Gla,
bSwamp                   =civ.getBaseTerrain(0,8),  --Swa,
bJungle                  =civ.getBaseTerrain(0,9),  --Jun,
bOcean                   =civ.getBaseTerrain(0,10),  --Oce,
tDesert                  =civ.getTerrain(0,0,0),
tOasis                   =civ.getTerrain(0,0,1), -- Fish Resource,
tDesertOil               =civ.getTerrain(0,0,2), -- Whale Resource,
tPlains                  =civ.getTerrain(0,1,0),
tBuffalo                 =civ.getTerrain(0,1,1), -- Fish Resource,
tWheat                   =civ.getTerrain(0,1,2), -- Whale Resource,
tGrassland               =civ.getTerrain(0,2,0),
tForest                  =civ.getTerrain(0,3,0),
tPheasant                =civ.getTerrain(0,3,1), -- Fish Resource,
tSilk                    =civ.getTerrain(0,3,2), -- Whale Resource,
tHills                   =civ.getTerrain(0,4,0),
tCoal                    =civ.getTerrain(0,4,1), -- Fish Resource,
tWine                    =civ.getTerrain(0,4,2), -- Whale Resource,
tMountains               =civ.getTerrain(0,5,0),
tGold                    =civ.getTerrain(0,5,1), -- Fish Resource,
tIron                    =civ.getTerrain(0,5,2), -- Whale Resource,
tTundra                  =civ.getTerrain(0,6,0),
tGame                    =civ.getTerrain(0,6,1), -- Fish Resource,
tFurs                    =civ.getTerrain(0,6,2), -- Whale Resource,
tGlacier                 =civ.getTerrain(0,7,0),
tIvory                   =civ.getTerrain(0,7,1), -- Fish Resource,
tGlacierOil              =civ.getTerrain(0,7,2), -- Whale Resource,
tSwamp                   =civ.getTerrain(0,8,0),
tPeat                    =civ.getTerrain(0,8,1), -- Fish Resource,
tSpice                   =civ.getTerrain(0,8,2), -- Whale Resource,
tJungle                  =civ.getTerrain(0,9,0),
tGems                    =civ.getTerrain(0,9,1), -- Fish Resource,
tFruit                   =civ.getTerrain(0,9,2), -- Whale Resource,
tOcean                   =civ.getTerrain(0,10,0),
tFish                    =civ.getTerrain(0,10,1), -- Fish Resource,
tWhales                  =civ.getTerrain(0,10,2), -- Whale Resource,
}
--]=]


-- gen.isTileRevealed(tile,tribe) -> boolean

-- Returns true if `tile` is revealed to `tribe`, false otherwise.
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param tribe tribeObject
---@return boolean
function gen.isTileRevealed(tile,tribe)
    tile = toTile(tile)
    return isBit1(tile.visibility,tribe.id+1)
end

-- gen.revealTile(tile,tribe) -> void
-- makes `tile` visible to `tribe`
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param tribe tribeObject
function gen.revealTile(tile,tribe)
    tile = toTile(tile)
---@diagnostic disable-next-line: assign-type-mismatch
    tile.visibility = gen.setBit1(tile.visibility,tribe.id+1)
end

-- gen.coverTile(tile,tribe) -> void
-- covers a tile so it isn't visible to tribe (if it ever was)
---@param tile tileAnalog # Can be:<br><br>tileObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param tribe tribeObject
function gen.coverTile(tile,tribe)
    tile = toTile(tile)
---@diagnostic disable-next-line: assign-type-mismatch
    tile.visibility = gen.setBit0(tile.visibility,tribe.id+1)
end

-- gen.isUnitStackVisible(unitOrTile,tribe,emptyTileReturnValue=nil) --> boolean or emptyTileReturnValue

-- If a unit is provided, returns true if that unit is visible to tribe, and false if not.
-- Note: a tribe's own units are visible to it (even though unit.visibility doesn't show this).
-- If a tile is provided, returns true if there are units on the tile and the tribe can see them,
-- false if units are on the tile and the tribe can't see them, and
-- returns emptyTileReturnValue (default nil) if there are no units on the tile.
---@generic emptyTileReturnValue
---@param unitOrTile tileObject|unitObject 
---@param tribe tribeObject
---@param emptyTileReturnValue emptyTileReturnValue Default value is nil.
---@return boolean|emptyTileReturnValue
---@overload fun(unitOrTile: unitObject|tileObject, tribe: tribeObject):boolean|nil
function gen.isUnitStackVisible(unitOrTile,tribe,emptyTileReturnValue)
    if civ.isUnit(unitOrTile) then
        return (unitOrTile.owner == tribe) or isBit1(unitOrTile.visibility,tribe.id+1)
    end
    if civ.isTile(unitOrTile) then
        if not unitOrTile.defender then
            return emptyTileReturnValue
        end
        local unit = unitOrTile.units()
        return (unit.owner == tribe) or isBit1(unit.visibility,tribe.id+1)
    end
    error("gen.isUnitStackVisibile: first argument must be a unit or a tile.  Received: "..tostring(unitOrTile))
end


-- gen.revealUnitStack(unitOrTile,tribe) --> void

-- If a unit is provided, reveals that unit and all other units on the tile
-- to the tribe.
-- If a tile is provided, reveals all units on the tile to the tribe (if any are present).
---@param unitOrTile tileAnalog|unitObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param tribe tribeObject
function gen.revealUnitStack(unitOrTile,tribe)
    local tile = nil
    if civ.isUnit(unitOrTile) then
        tile = unitOrTile.location
    else
        tile = toTile(unitOrTile)
    end
    for unit in tile.units do
        unit.visibility = setBit1(unit.visibility,tribe.id+1)
    end
end

-- gen.hideUnitStack(unitOrTile,tribe) --> void

-- If a unit is provided, hides the unit and all other units on the tile from tribe
-- If a tile is provided, hides all units on the tile (if any are present)
---@param unitOrTile tileAnalog|unitObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param tribe tribeObject
function gen.hideUnitStack(unitOrTile,tribe)
    local tile = nil
    if civ.isUnit(unitOrTile) then
        tile = unitOrTile.location
    else
        tile = toTile(unitOrTile)
    end
    for unit in tile.units do
        unit.visibility = setBit0(unit.visibility,tribe.id+1)
    end
end


-- gen.isCityCharted(city,tribe) --> bool

-- Returns true if city is "knownTo" tribe (that is,
-- will appear on the map if the tile is visible), false otherwise.
---@param city cityObject
---@param tribe tribeObject
---@return boolean
function gen.isCityCharted(city,tribe)
    return isBit1(city.knownTo,tribe.id+1) and city.sizeForTribe[tribe] ~= 0
end

-- gen.chartCity(city,tribe,visibleSize=nil) --> void

-- Makes city visible to tribe on the map, setting it to visibleSize if provided.
-- If city.sizeForTribe[tribe] == 0 (the default value) after this, it is set to 1
-- since a city does not appear if city.sizeForTribe[tribe] == 0
-- does not change the visibility of the tile.
---@param city cityObject
---@param tribe tribeObject
---@param visibleSize? integer 1 by default.
---@overload fun(city:cityObject, tribe:tribeObject)
function gen.chartCity(city,tribe,visibleSize)
    if visibleSize then
        city.sizeForTribe[tribe] = visibleSize
    end
    city.sizeForTribe[tribe] = math.max(1,city.sizeForTribe[tribe])
    city.knownTo = setBit1(city.knownTo,tribe.id+1)
end

-- gen.unchartCity(city,tribe) --> void

-- Makes a `city` invisible to `tribe` (but doesn't cover the tile in black)
-- by changing the knownTo field.
---@param city any
---@param tribe any
function gen.unchartCity(city,tribe) 
    city.knownTo = setBit0(city.knownTo,tribe.id+1)
end

local function buildChartingFunctions(name,bitString)
    gen["is"..name.."Charted"] = function(tile,tribe)
        tile = toTile(tile)
        return checkBits(tile.visibleImprovements[tribe],bitString)
    end
    gen["chart"..name] = function(tile,tribe)
        tile = toTile(tile)
        tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],bitString)
    end
    local unBitString = string.gsub(bitString,"1","0")
    gen["unchart"..name] = function(tile,tribe)
        tile = toTile(tile)
        if checkBits(tile.visibleImprovements[tribe],bitString) then
            tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],unBitString)
        end
    end
end


-- gen.isIrrigationCharted(tile,tribe) --> bool

-- Returns true if tribe sees Irrigation on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isIrrigationCharted(tile,tribe) end
-- gen.chartIrrigation(tile,tribe) --> void

-- Charts Irrigation on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartIrrigation(tile,tribe) end
-- gen.unchartIrrigation(tile,tribe) --> void

-- Uncharts Irrigation on the tribe's map of tile, if Irrigation has been charted.
-- If Irrigation is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartIrrigation(tile,tribe) end
buildChartingFunctions("Irrigation","hgfe01ba")

-- gen.isMineCharted(tile,tribe) --> bool

-- Returns true if tribe sees Mine on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isMineCharted(tile,tribe) end

-- gen.chartMine(tile,tribe) --> void

-- Charts Mine on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartMine(tile,tribe) end

-- gen.unchartMine(tile,tribe) --> void

-- Uncharts Mine on the tribe's map of tile, if Mine has been charted.
-- If Mine is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartMine(tile,tribe) end
buildChartingFunctions("Mine","hgfe10ba")

-- gen.isFarmlandCharted(tile,tribe) --> bool

-- Returns true if tribe sees Farmland on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isFarmlandCharted(tile,tribe) end
-- gen.chartFarmland(tile,tribe) --> void

-- Charts Farmland on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartFarmland(tile,tribe) end
-- gen.unchartFarmland(tile,tribe) --> void

-- Uncharts Farmland on the tribe's map of tile, if Farmland has been charted.
-- If Farmland is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.unchartFarmland(tile,tribe) end
buildChartingFunctions("Farmland","hgfe11ba")

-- gen.isRoadCharted(tile,tribe) --> bool

-- Returns true if tribe sees Road on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isRoadCharted(tile,tribe) end

-- gen.chartRoad(tile,tribe) --> void

-- Charts Road on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartRoad(tile,tribe) end

-- gen.unchartRoad(tile,tribe) --> void

-- Uncharts Road on the tribe's map of tile, if Road has been charted.
-- If Road is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartRoad(tile,tribe) end
buildChartingFunctions("Road","hgf1dcba")

-- gen.isRailroadCharted(tile,tribe) --> bool

-- Returns true if tribe sees Railroad on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isRailroadCharted(tile,tribe) end

-- gen.chartRailroad(tile,tribe) --> void

-- Charts Railroad on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartRailroad(tile,tribe) end

-- gen.unchartRailroad(tile,tribe) --> void

buildChartingFunctions("Railroad","hg11dcba")
-- Uncharts Railroad on the tribe's map of tile, if Railroad has been charted.
-- If Railroad is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
gen.unchartRailroad = function(tile,tribe)
    tile = toTile(tile)
    if checkBits(tile.visibleImprovements[tribe],"hg11dcba") then
        tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],"hg0edcba")
    end
end
-- gen.unchartTransportation(tile,tribe) --> void
-- Uncharts road and railroad on the tribe's map of tile.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartTransportation(tile,tribe)
    tile = toTile(tile)
    tile.visibleImprovements[tribe] = setBits(tile.visibleImprovements[tribe],"hg00dcba")
end

-- gen.isFortressCharted(tile,tribe) --> bool

-- Returns true if tribe sees Fortress on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isFortressCharted(tile,tribe) end

-- gen.chartFortress(tile,tribe) --> void

-- Charts Fortress on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartFortress(tile,tribe) end

-- gen.unchartFortress(tile,tribe) --> void

-- Uncharts Fortress on the tribe's map of tile, if Fortress has been charted.
-- If Fortress is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartFortress(tile,tribe) end
buildChartingFunctions("Fortress","h1fedc0a")

-- gen.isAirbaseCharted(tile,tribe) --> bool

-- Returns true if tribe sees Airbase on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isAirbaseCharted(tile,tribe) end

-- gen.chartAirbase(tile,tribe) --> void

-- Charts Airbase on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartAirbase(tile,tribe) end

-- gen.unchartAirbase(tile,tribe) --> void

-- Uncharts Airbase on the tribe's map of tile, if Airbase has been charted.
-- If Airbase is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartAirbase(tile,tribe) end
buildChartingFunctions("Airbase","h1fedc1a")

-- gen.isPollutionCharted(tile,tribe) --> bool
-- Returns true if tribe sees Pollution on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isPollutionCharted(tile,tribe) end

-- gen.chartPollution(tile,tribe) --> void

-- Charts Pollution on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartPollution(tile,tribe) end

-- gen.unchartPollution(tile,tribe) --> void

-- Uncharts Pollution on the tribe's map of tile, if Pollution has been charted.
-- If Pollution is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartPollution(tile,tribe) end
buildChartingFunctions("Pollution","1gfedc0a")

-- gen.isTransporterCharted(tile,tribe) --> bool

-- Returns true if tribe sees Transporter on the tile, and false otherwise.
-- Does not consider if tile is revealed to the tribe.
---@param tile tileObject
---@param tribe tribeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isTransporterCharted(tile,tribe) end

-- gen.chartTransporter(tile,tribe) --> void

-- Charts Transporter on the tribe's map of tile, uncharting any conflicting improvements.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartTransporter(tile,tribe) end

-- gen.unchartTransporter(tile,tribe) --> void

-- Uncharts Transporter on the tribe's map of tile, if Transporter has been charted.
-- If Transporter is not charted, the chart remains unchanged.
---@param tile tileObject
---@param tribe tribeObject
function gen.unchartTransporter(tile,tribe) end
buildChartingFunctions("Transporter","1gfedc1a")

-- gen.chartTruthfully(tile,tribe) --> void
-- Reveals `tile` to `tribe`, and makes visible the tile improvements that actually exist.
---@param tile tileObject
---@param tribe tribeObject
function gen.chartTruthfully(tile,tribe)
    gen.revealTile(tile,tribe)
    if tile.city then
        gen.chartCity(tile.city,tribe,tile.city.size)
    end
    tile.visibleImprovements[tribe] = tile.improvements
end


local function buildAdvancedFlags(name,bitNumber)
    gen["is"..name] = function(unitType)
        return isBit1(unitType.advancedFlags,bitNumber)
    end
    gen["give"..name] = function(unitType)
        unitType.advancedFlags = setBit1(unitType.advancedFlags,bitNumber)
    end
    gen["remove"..name] = function(unitType)
        unitType.advancedFlags = setBit0(unitType.advancedFlags,bitNumber)
    end
end

-- gen.isInvisibleUntilAttack(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isInvisibleUntilAttack(unitType) end

-- gen.giveInvisibleUntilAttack(unitType) --> void

---@param unitType unitTypeObject
function gen.giveInvisibleUntilAttack(unitType) end

-- gen.removeInvisibleUntilAttack(unitType) --> void

---@param unitType unitTypeObject
function gen.removeInvisibleUntilAttack(unitType) end

buildAdvancedFlags("InvisibleUntilAttack",1)

-- gen.isNonDisbandable(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isNonDisbandable(unitType) end

-- gen.giveNonDisbandable(unitType) --> void

---@param unitType unitTypeObject
function gen.giveNonDisbandable(unitType) end

-- gen.removeNonDisbandable(unitType) --> void

---@param unitType unitTypeObject
function gen.removeNonDisbandable(unitType) end

buildAdvancedFlags("NonDisbandable",2)

-- gen.isZeroRangeAirUnitDamageOverride(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isZeroRangeAirUnitDamageOverride(unitType) end

-- gen.giveZeroRangeAirUnitDamageOverride(unitType) --> void

---@param unitType unitTypeObject
function gen.giveZeroRangeAirUnitDamageOverride(unitType) end

-- gen.removeZeroRangeAirUnitDamageOverride(unitType) --> void

---@param unitType unitTypeObject
function gen.removeZeroRangeAirUnitDamageOverride(unitType) end

buildAdvancedFlags("ZeroRangeAirUnitDamageOverride",3)

-- gen.isCannotBuyOffBarbarian(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isCannotBuyOffBarbarian(unitType) end

-- gen.giveCannotBuyOffBarbarian(unitType) --> void

---@param unitType unitTypeObject
function gen.giveCannotBuyOffBarbarian(unitType) end

-- gen.removeCannotBuyOffBarbarian(unitType) --> void

---@param unitType unitTypeObject
function gen.removeCannotBuyOffBarbarian(unitType) end

buildAdvancedFlags("CannotBuyOffBarbarian",4)

-- gen.isCanCrossImpassableTerrain(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isCanCrossImpassableTerrain(unitType) end

-- gen.giveCanCrossImpassableTerrain(unitType) --> void

---@param unitType unitTypeObject
function gen.giveCanCrossImpassableTerrain(unitType) end

-- gen.removeCanCrossImpassableTerrain(unitType) --> void

---@param unitType unitTypeObject
function gen.removeCanCrossImpassableTerrain(unitType) end

buildAdvancedFlags("CanCrossImpassableTerrain",5)

-- gen.isBarbarianWillNotExpire(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isBarbarianWillNotExpire(unitType) end

-- gen.giveBarbarianWillNotExpire(unitType) --> void

---@param unitType unitTypeObject
function gen.giveBarbarianWillNotExpire(unitType) end

-- gen.removeBarbarianWillNotExpire(unitType) --> void

---@param unitType unitTypeObject
function gen.removeBarbarianWillNotExpire(unitType) end

buildAdvancedFlags("BarbarianWillNotExpire",7)


-- gen.isOverrideSPR(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isOverrideSPR(unitType) end

-- gen.giveOverrideSPR(unitType) --> void

---@param unitType unitTypeObject
function gen.giveOverrideSPR(unitType) end

-- gen.removeOverrideSPR(unitType) --> void

---@param unitType unitTypeObject
function gen.removeOverrideSPR(unitType) end

buildAdvancedFlags("OverrideSPR",8)

local function buildAdvancedSettlerFlags(name,bitNumber)
    gen["is"..name] = function(unitType)
        -- a ~= b is xor when a and b are booleans
        return unitType.role == 5 ~= isBit1(unitType.advancedFlags,bitNumber)
    end
    gen["give"..name] = function(unitType)
        if unitType.role == 5 then
            -- if settler, the functionality is default, so set flag to 0
            unitType.advancedFlags = setBit0(unitType.advancedFlags,bitNumber)
        else
            -- if not settler, the functionality is not default, so set flag to 1
            unitType.advancedFlags = setBit1(unitType.advancedFlags,bitNumber)
        end
    end
    gen["remove"..name] = function(unitType)
        if unitType.role == 5 then
            -- if settler, the functionality is default, so set flag to 1 to remove it
            unitType.advancedFlags = setBit1(unitType.advancedFlags,bitNumber)
        else
            -- if not settler, the functionality is not default, so set flag to 0 to remove it
            unitType.advancedFlags = setBit0(unitType.advancedFlags,bitNumber)
        end
    end
end

--gen.isReducePopulationWhenBuilt(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isReducePopulationWhenBuilt(unitType) end

--gen.giveReducePopulationWhenBuilt(unitType) --> void

---@param unitType unitTypeObject
function gen.giveReducePopulationWhenBuilt(unitType) end

--gen.removeReducePopulationWhenBuilt(unitType) --> void

---@param unitType unitTypeObject
function gen.removeReducePopulationWhenBuilt(unitType) end

buildAdvancedSettlerFlags("ReducePopulationWhenBuilt",10)

-- gen.isRequiresFoodSupport(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isRequiresFoodSupport(unitType) end

-- gen.giveRequiresFoodSupport(unitType) --> void

---@param unitType unitTypeObject
function gen.giveRequiresFoodSupport(unitType) end

-- gen.removeRequiresFoodSupport(unitType) --> void

---@param unitType unitTypeObject
function gen.removeRequiresFoodSupport(unitType) end

buildAdvancedSettlerFlags("RequiresFoodSupport",11)


-- gen.isCanFoundCities(unitType) --> bool

---@param unitType unitTypeObject
---@return boolean
---@diagnostic disable-next-line: missing-return
function gen.isCanFoundCities(unitType) end

-- gen.giveCanFoundCities(unitType) --> void

---@param unitType unitTypeObject
function gen.giveCanFoundCities(unitType) end

-- gen.removeCanFoundCities(unitType) --> void

---@param unitType unitTypeObject
function gen.removeCanFoundCities(unitType) end

buildAdvancedSettlerFlags("CanFoundCities",12)


-- gen.isCanImproveTiles(unitType)--> bool

---@param unitType unitTypeObject
---@return boolean
gen.isCanImproveTiles = function(unitType)
    return unitType.role == 5 and isBit0(unitType.advancedFlags,13)
end
-- gen.giveCanImproveTiles(unitType,ignoreError=false) --> void

-- Bestows the ability to improve tiles to units with settler role.
-- Units without settler role produce an error, unless ignoreError
-- is set to true.
---@param unitType unitTypeObject
---@param ignoreError? boolean Default is false
---@overload fun(unitType:unitTypeObject)
gen.giveCanImproveTiles = function(unitType,ignoreError)
    if unitType.role == 5 then
        -- if settler, the functionality is default, so set flag to 0
        unitType.advancedFlags = setBit0(unitType.advancedFlags,13)
    elseif not ignoreError then
        error("gen.giveCanImproveTiles: only units with the settler role (unitType.role == 5) can be given the ability to improve tiles.  If you wish to suppress this error and have gen.giveCanImproveTiles simply do nothing when applied to non-settler role units, use\ngen.giveCanImproveTiles(unitType,true)")
    end
end

-- gen.removeCanImproveTiles(unitType,ignoreError=false) --> void

-- Removes the ability to improve tiles from units with settler role.
-- Units without settler role produce an error, unless ignoreError
-- is set to true.
---@param unitType unitTypeObject
---@param ignoreError? boolean Default is false
---@overload fun(unitType:unitTypeObject)
gen.removeCanImproveTiles = function(unitType,ignoreError)
    if unitType.role == 5 then
        -- if settler, the functionality is default, so set flag to 1 to remove it
        unitType.advancedFlags = setBit1(unitType.advancedFlags,13)
    elseif not ignoreError then
        error("gen.removeCanImproveTiles: only units with the settler role (unitType.role == 5) can be given the ability to improve tiles.  If you wish to suppress this error and have gen.giveCanImproveTiles simply do nothing when applied to non-settler role units, use\ngen.removeCanImproveTiles(unitType,true)")
    end
end

--[[A dataTable acts as an ordinary table, but, if desired, you can forbid values from being changed, forbid new key-value pairs from being stored, and forbid trying to access keys with a `nil` value.  These features can make debugging easier by causing an error to happen on the line the mistake is made.

The following functions can be used to control the data table's features:

gen.forbidReplacement(dataTable) --> void

gen.allowReplacement(dataTable) --> void

gen.forbidNewKeys(dataTable) --> void

gen.allowNewKeys(dataTable) --> void

gen.forbidNilValueAccess(dataTable) --> void

gen.allowNilValueAccess(dataTable) --> void

gen.restrictValues(dataTable,isValidValueFn,makeValidValueFn) --> void
]]
---@class dataTable:table

-- gen.makeDataTable(inputTable={},tableName="unnamed data table") --> dataTable

--  Makes a 'dataTable', which functions as a table, but with the ability to disable
--  overwriting values for existing keys,
--  adding new keys, and
--  requesting nil values (values for keys that don't exist).
--  (This functionality is achieved with a metatable.)
--  The `tableName` is a name for the table when an error is generated.
---@param inputTable? table The table to be made into a data table.  The table actually transformed, but it is also returned, if that is convenient.  Default is an empty table.
---@param tableName? string Default is 'unnamed data table'
---@return dataTable
---@overload fun(inputTable: table):dataTable
---@overload fun():dataTable
function gen.makeDataTable(inputTable,tableName)
    inputTable = inputTable or {}
    tableName = tableName or "unnamed data table"
    if type(tableName) ~= "string" then
        error("gen.makeDataTable: tableName argument (arg 2) must be a string.")
    end
    local metatable = {}
    metatable.dataRecord = {}
    for key,value in pairs(inputTable) do
        metatable.dataRecord[key] = value
        inputTable[key] = nil
    end
    metatable.type = "dataTable"
    metatable.forbidReplacement = false
    metatable.forbidNilValueAccess = false
    metatable.forbidNewKeys = false
    metatable.isValidValueFn = function(value) return true end
    metatable.makeValidValueFn = function(value) return value end
    metatable.__newindex = function(inputTbl,key,value)
        if metatable.dataRecord[key] ~= nil then
            if metatable.forbidReplacement then
                error("gen.makeDataTable: the table "..tableName.." can't have the values for existing keys reassigned.  The key "..tostring(key).." has already been assigned a value of "..tostring(metatable.dataRecord[key]).." and is now being assigned the value of "..tostring(value).." .")
            else
                if metatable.isValidValueFn(value) then
                    metatable.dataRecord[key] = value
                else
                    metatable.dataRecord[key] = metatable.makeValidValueFn(value)
                end
            end
        else
            if metatable.forbidNewKeys then
                error("gen.makeDataTable: the table "..tableName.." can't have values assigned to keys that do not already have values.  The key "..tostring(key).." has not already been assigned a value.")
            else
                if metatable.isValidValueFn(value) then
                    metatable.dataRecord[key] = value
                else
                    metatable.dataRecord[key] = metatable.makeValidValueFn(value)
                end
            end
        end
    end
    metatable.__index = function(inputTbl,key)
        local val = metatable.dataRecord[key]
        if val == nil and metatable.forbidNilValueAccess then
            error("gen.makeDataTable: the table "..tableName.." is not allowed to access values for keys that don't exist.  The key "..tostring(key).." does not have a value associated with it.")
        else
            return val
        end
    end
    metatable.__pairs = function(inputTbl)
        return pairs(metatable.dataRecord)
    end
    metatable.__ipairs = function(inputTbl)
        return ipairs(metatable.dataRecord)
    end

    inputTable = setmetatable(inputTable,metatable)
    return inputTable
end

-- gen.forbidReplacement(dataTable) --> void

--- Changes the `dataTable` so that non-nil values can not be changed.
---@param dataTable dataTable
function gen.forbidReplacement(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.forbidReplacement: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidReplacement = true
end

-- gen.allowReplacement(dataTable) --> void

--- Changes the `dataTable` so that non-nil values can be changed.
---@param dataTable dataTable
function gen.allowReplacement(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.allowReplacement: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidReplacement = false
end


-- gen.forbidNewKeys(dataTable) --> void

--- Changes the `dataTable` so that values can't be assigned to keys which currently have a nil value.
---@param dataTable dataTable
function gen.forbidNewKeys(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.forbidNewKeys: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNewKeys = true
end

-- gen.allowNewKeys(dataTable) --> void

--- Changes the `dataTable` so that values can once again be assigned to keys which currently have a nil value.
---@param dataTable dataTable
function gen.allowNewKeys(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.allowNewKeys: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNewKeys = false
end

-- gen.forbidNilValueAccess(dataTable) --> void

--- Changes the `dataTable` so that an error is generated if the program tries to access a key which currently has a nil value.
---@param dataTable dataTable
function gen.forbidNilValueAccess(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.forbidNilValueAccess: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNilValueAccess = true
end

-- gen.allowNilValueAccess(dataTable) --> void

--- Changes the `dataTable` so that an error is not generated if the program tries to access a key which currently has a nil value.
---@param dataTable dataTable
function gen.allowNilValueAccess(dataTable)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.allowNilValueAccess: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.forbidNilValueAccess = false
end


--[[Changes the `dataTable` so that only 'valid' values can be assigned to the dataTable.  If `isValidValueFunction(value)` returns true for a `value` assigned to the table, that value is added to the table.  Otherwise, `makeValidValueFunction(value)` is assigned to the dataTable (unless an error is generated).]]
---@param dataTable dataTable
---@param isValidValueFunction fun(value:any):boolean
---@param makeValidValueFunction fun(value:any):any
function gen.restrictValues(dataTable,isValidValueFunction,makeValidValueFunction)
    local mt = getmetatable(dataTable) or {}
    if mt.type ~= "dataTable" then
        error("gen.restrictValues: argument is not a data table.  Use gen.makeDataTable first.")
    end
    mt.isValidValueFn = isValidValueFunction
    mt.makeValidValueFn = makeValidValueFunction
end


local scenarioDirectory = nil

-- gen.setScenarioDirectory(directoryPath) --> void

--- Registers `directory` as the path to the current scenario's main directory.  This value is returned by `gen.getScenarioDirectory()`.  If you are using the Lua Scenario Template, this is handled in events.lua, and you do not need to worry about it.
---@param directory string
function gen.setScenarioDirectory(directory)
    if type(directory) == "string" then
        scenarioDirectory = directory
    else
        error("gen.setScenarioDirectory expects a string as the argument.")
    end
end

-- gen.getScenarioDirectory() --> string

---Returns the scenario's main directory.
---@return string scenarioMainDirectory
function gen.getScenarioDirectory()
    if scenarioDirectory then
        return scenarioDirectory
    else
        error("gen.getScenarioDirectory: scenario directory path has not been set.  Use gen.setScenarioDirectory in your events.lua file.  If you are using the Lua Scenario Template, there should be a local variable named scenarioFolder.  Try the line:\n gen.setScenarioDirectory(scenarioFolder)")
    end
end

-- gen.isStateSavable(item) --> boolean

-- Determines if an item is "state savable" , which is to say that
-- it can be added to the state table (the table containing the data that persists
-- after saving and loading) in its current state.
--  An item is "state savable" if it is either
--  <br>nil
--  <br>a number
--  <br>a string
--  <br>a boolean, or
--  <br>a table with keys that are numbers or strings
--    and with values that are also state savable
--  Note: table can't have a metatable
---comment
---@param item any
---@return boolean
function gen.isStateSavable(item)
  if type(item) == "table" then
    if getmetatable(item) then
        return false
    end
    for key,value in pairs(item) do
      if type(key) ~= "number" and type(key) ~="string" then
        return false
      end
      if not gen.isStateSavable(value) then
        return false
      end
    end
    return true
  elseif type(item) == "number" then
    return true
  elseif type(item) == "string" then
    return true
  elseif type(item) == "nil" then
    return true
  elseif type(item) == "boolean" then
    return true
  else
    return false
  end  
end

-- gen.calculateWeight(item,weightTable,extraArgument=nil) --> number or false

--[[
This function calculates the "weight" of the `item`, taking into account the `extraArgument`, and uses the `weightTable`.  Calculating weights can be a simple way to choose between various options (with a return of `false` meaning not to choose this option).

In practice, you will probably not use this function itself.  There are several functions that use this function to make choices:

    gen.getExtremeWeights
    gen.getBiggestWeights
    gen.getSmallestWeights

weightTable has functions as keys, and numbers or false as values

    {[keyFunc(item,extraArgument)->boolean] = number or boolean or string or function(item,extraArgument) -> number|false}

    for each key in the weight table, apply keyFunc to the item and extraArgument

    if keyFunc(item,extraArgument) then
        if the value is a number, add the number to the weight
        if the value is a string add item[value] to the weight
        if the value is a function, add value(item,extraArgument) to the weight
        if the value is false, return 'false' as the weight
        if the value is true, do nothing
    else
        if the value is a number, do nothing
        if the value is false, do nothing
        if the value is a string, do nothing
        if the value is true, return 'false' as the weight

    That is, false means that keyFunc must not apply to the item
    while true means that keyFunc must apply to the item

    default weight is 0
]]
---@generic weightItem
---@generic extraArg
---@param item weightItem
---@param weightTable table<fun(item:weightItem,extraArgument:extraArg):boolean, boolean|number|fun(item:weightItem, extraArgument:extraArg):(number|false)>
---@param extraArgument? extraArg Default is nil.
---@return number|boolean # If number, the item has this weight.  False means the item was not given a weight.  
function gen.calculateWeight(item,weightTable,extraArgument)
    local defaultWeight = 0
    for keyFunc, value in pairs(weightTable) do
        if keyFunc(item,extraArgument) then
            if type(value) == "number" then
                defaultWeight = defaultWeight + value
            elseif value == false then
                return false
            elseif type(value) == "string" then
                defaultWeight = defaultWeight + item[value]
            elseif type(value) == "function" then
                local v = value(item,extraArgument)
                if v == false then
                    return false
                end
                defaultWeight = defaultWeight + v
            elseif type(value) == "boolean" then
            else
                error("gen.calculateWeight: weightTable (2nd argument) values must be numbers, booleans, strings or functions.  Received: "..tostring(value))
            end
        else
            if value == true then
                return false
            end
        end
    end
    return defaultWeight
end
local calculateWeight = gen.calculateWeight

-- takes a new item and a new weight, and sorts them
-- into the sortedItems and sortedWeights list
-- if changeOrder(weight1,weight2) is true,
-- weight2 should be before weight1
-- changeOrder(nil,weight2) should always be true
-- If at the end there are more than maxLength items in the
-- list, the last item is removed

local function bubbleUp(sortedItems,sortedWeights,maxLength,newItem,newWeight,changeOrder)
    sortedItems[maxLength+1] = newItem
    sortedWeights[maxLength+1] = newWeight
    for i=maxLength,1,-1 do
        if changeOrder(sortedWeights[i],sortedWeights[i+1]) then
            sortedItems[i],sortedItems[i+1] = sortedItems[i+1],sortedItems[i]
            sortedWeights[i],sortedWeights[i+1] = sortedWeights[i+1],sortedWeights[i]
        else
            break
        end
    end
    sortedItems[maxLength+1] = nil
    sortedWeights[maxLength+1] = nil
end


-- gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction,getTopX,changeOrder,functionName,extraArgument)

--[[
This function is wrapped to construct `gen.getBiggestWeight` and `gen.getSmallestWeight`.  You probably want to use one of them.

listOrIterator
    if iterator, returns the items for consideration
    if table, each item is a value in the table, and the table consists only of those values
weightTableOrWeightFunction
    if weightTable, use gen.calculateWeight(item,weightTable,extraArgument) as the weight function
    a weightFunction(item,extraArgument) must return either a number or false.  When false is returned,
    the item is not considered at all
getTopX
    if absent, the item with the largest weight is returned, or nil if no valid item is found
    if integer, a table with that number of items is returned, with index 1 associated with the
    item of the largest weight, 2 the next highest weight and so on.  If there are fewer valid
    items, the corresponding values are nil
changeOrder function
    if changeOrder(weight1,weight2) is true,
    weight2 should be before weight1
    changeOrder(nil,weight2) should always be true
functionName string
    name of the function being created (since this is designed to be wrapped by another function), for error purposes.
]]
---@generic extraArg
---@generic itemToWeigh
---@param listOrIterator iterator|table
---@param weightTableOrWeightFunction table|fun(item:itemToWeigh,extraArgument:extraArg):(false|number)
---@param getTopX nil|integer
---@param changeOrder fun(weight1:number|false|nil,weight2:number|false):boolean
---@param functionName string
---@param extraArgument extraArg
---@return itemToWeigh|table<integer,itemToWeigh> # best item, or table of the best items, starting at 1 with the best item.
---@return number|table<integer,number> # Weight of best item, or table of weights of the best items, starting at 1 with the best weight
function gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction,getTopX,changeOrder,functionName,extraArgument)
    local weightFunction = nil 
    if type(weightTableOrWeightFunction) == "table" then
        weightFunction = function(item,extraArgument) return calculateWeight(item,weightTableOrWeightFunction,extraArgument) end
    elseif type(weightTableOrWeightFunction) == "function" then
        weightFunction = weightTableOrWeightFunction
    else
        error(functionName..": second argument must be either a table or a function(item)->(number or false).  Received: "..tostring(weightTableOrWeightFunction))
    end
    local iterator = nil
    if type(listOrIterator) == "function" then
        -- iterator provided
        iterator = listOrIterator
    elseif type(listOrIterator) == "table" then
        -- table provided
        iterator = coroutine.wrap( function() for _,item in pairs(listOrIterator) do coroutine.yield(item) end end)
    else
        error(functionName..": first argument must either be an iterator (a type of function), or a table.  Received: "..tostring(listOrIterator))
    end
    local maxLength = getTopX or 1
    local sortedItems = {}
    local sortedWeights = {}
    for item in iterator do
        local weight = weightFunction(item,extraArgument)
        if weight then
            bubbleUp(sortedItems,sortedWeights,maxLength,item,weight,changeOrder)
        end
    end
    if getTopX then
        return sortedItems,sortedWeights
    else
        return sortedItems[1],sortedWeights[1]
    end
end


-- gen.getBiggestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil

--[[
Finds the `getTopX` number items in `listOrIterator` with the highest weights.  
If `getTopX` is nil, the item with the largest weight, and its weight, are returned as two values.  If `getTopX` is not nil, two tables are returned instead, with items 1 being the largest value, and its weight, 2 the second largest value and its weight, and so on.
]]
---@generic itemToWeigh
---@generic extraArg
---@param listOrIterator iterator|table<any,itemToWeigh> # <br>If iterator, returns the items for consideration.<br><br>If table, each item is a value in the table, and all the table values are items for consideration.
---@param weightTableOrWeightFunction table|fun(item:itemToWeigh,extraArgument:extraArg):(false|number) # <br>If a table is provided, `gen.calculateWeight(item,weightTable,extraArgument)` is used to calculate the weight.<br><br>If a function is provided, it is used to calculate the weights.
---@param getTopX integer|nil # <br> If absent/nil, the item with the largest weight is returned, and the second return value returns its weight. <br><br> If integer, a table (indexed with integers starting at 1) with this many values is returned, with the item having the largest weight being at key 1, the second best item at key 2, and so on.  If there are not `getTopX` valid items, then nil is the value in the table for the relevant keys.  The second return value is a table of the weights of the `getTopX` items.
---@param extraArgument extraArg|nil # <br> This is an extra piece of data for computing the weights.
---@return itemToWeigh|table<integer, itemToWeigh>
---@return number|table<integer,number>
function gen.getBiggestWeights(listOrIterator,weightTableOrWeightFunction,getTopX,extraArgument)
    local changeFunction = function(weight1,weight2)
        return (type(weight2) == "number") and (weight1 == nil or weight1 < weight2)
    end
    local functionName = "gen.getBiggestWeights"
    return gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction, getTopX, changeFunction, functionName,extraArgument)
end


-- gen.getSmallestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil

--[[
Finds the `getTopX` number items in `listOrIterator` with the smallest weights.  
If `getTopX` is nil, the item with the smallest weight, and its weight, are returned as two values.  If `getTopX` is not nil, two tables are returned instead, with items 1 being the item with the smallest weight, and its weight, 2 the second largest value and its weight, and so on.
]]
---@generic itemToWeigh
---@generic extraArg
---@param listOrIterator iterator|table<any,itemToWeigh> # <br>If iterator, returns the items for consideration.<br><br>If table, each item is a value in the table, and all the table values are items for consideration.
---@param weightTableOrWeightFunction table|fun(item:itemToWeigh,extraArgument:extraArg):(false|number) # <br>If a table is provided, `gen.calculateWeight(item,weightTable,extraArgument)` is used to calculate the weight.<br><br>If a function is provided, it is used to calculate the weights.
---@param getTopX integer|nil # <br> If absent/nil, the item with the smallest weight is returned, and the second return value returns its weight. <br><br> If integer, a table (indexed with integers starting at 1) with this many values is returned, with the item having the smallest weight being at key 1, the second best item at key 2, and so on.  If there are not `getTopX` valid items, then nil is the value in the table for the relevant keys.  The second return value is a table of the weights of the `getTopX` items.
---@param extraArgument extraArg|nil # <br> This is an extra piece of data for computing the weights.
---@return itemToWeigh|table<integer, itemToWeigh>
---@return number|table<integer,number>
function gen.getSmallestWeights(listOrIterator,weightTableOrWeightFunction,getTopX,extraArgument)
    local changeFunction = function(weight1,weight2)
        return (type(weight2) == "number") and (weight1 == nil or weight1 > weight2)
    end
    local functionName = "gen.getSmallestWeights"
    return gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction, getTopX, changeFunction, functionName,extraArgument)
end



--
-- These are the options for markers, and the relevant charting functions
-- entries 4 and 5 are conflicting markers
local markerOptions = {}
markerOptions["irrigation"]={gen.isIrrigationCharted, gen.chartIrrigation,gen.unchartIrrigation, "mine","farmland"}
markerOptions["mine"]={gen.isMineCharted, gen.chartMine,gen.unchartMine,"irrigation","farmland"}
markerOptions["farmland"]={gen.isFarmlandCharted, gen.chartFarmland,gen.unchartFarmland,"irrigation","mine"}
markerOptions["road"]={gen.isRoadCharted, gen.chartRoad,gen.unchartRoad}
markerOptions["railroad"]={gen.isRailroadCharted, gen.chartRailroad,gen.unchartRailroad}
markerOptions["fortress"]={gen.isFortressCharted, gen.chartFortress,gen.unchartFortress,"airbase"}
markerOptions["airbase"]={gen.isAirbaseCharted, gen.chartAirbase,gen.unchartAirbase,"fortress"}
markerOptions["pollution"]={gen.isPollutionCharted, gen.chartPollution,gen.unchartPollution,"transporter"}
markerOptions["transporter"]={gen.isTransporterCharted, gen.chartTransporter,gen.unchartTransporter,"pollution"}

gen.markerOptions = markerOptions

local validMarkerOptionsList = 'Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".'
gen.validMarkerOptionsList = validMarkerOptionsList

-- tileMarkerInfo = {[tribe.id] = {"originalChart"=bitmask, "markerOption"=trueNil}}
-- if tileMarkerInfo[tribe.id]["markerOption"] is true, then a marker has been placed on that
-- tile, and not been removed by a function.
-- If the marker is not visible, the tribe must have recently observed the tile,
-- so originalChart will be updated to true chart if this is noticed

-- genStateTable.tileMarkerTable is initialized in gen.linkGeneralLibraryState
local function updateTileMarkerTable(tileMarkerInfo,tile)
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        local tribe = civ.getTribe(tribeID)
        for key,val in pairs(tribeMarkerInfo) do
            if key ~= "originalChart" then
                -- 1st entry in markerOptions[key] is the isImprovementCharted function,
                -- so, if it is not, the tile must have been observed by the relevant player
                -- (since the key is nil if the tile is not marked by the relevant key)
                -- or there is a conflicting marker
                if not markerOptions[key][1](tile,tribe) then
                    local conflictKey1 = markerOptions[key][4]
                    local conflictKey2 = markerOptions[key][5]
                    if (conflictKey1 and tribeMarkerInfo[conflictKey1] and 
                        markerOptions[conflictKey1][1](tile,tribe)) then
                    elseif (conflictKey2 and tribeMarkerInfo[conflictKey2] and 
                        markerOptions[conflictKey2][1](tile,tribe)) then
                    else
                        tribeMarkerInfo["originalChart"] = tile.improvements
                    end
                end
            end
        end
    end
end
-- markExists(tileMarkerInfo) --> boolean
-- returns true if a tribe has a mark on this tile, false otherwise
local function markExists(tileMarkerInfo)
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        for key, val in pairs(tribeMarkerInfo) do
            if key ~= "originalChart" then
                return true
            end
        end
    end
    return false
end


---@enum markerOptions
local MARKER_OPTIONS = {
    ["irrigation"]="irrigation",
    ["mine"]="mine",
    ["farmland"]="farmland",
    ["road"]="road",
    ["railroad"]="railroad",
    ["fortress"]="fortress",
    ["airbase"]="airbase",
    ["pollution"]="pollution",
    ["transporter"]="transporter",
}

-- gen.placeMarker(tile,tribe,markerOption)

--[[Places a "marker" on `tile` for `tribe`.

Placing a marker on a tile changes the visible improvements for that tile, so that the tribe can now see the `markerOption` ("irrigation", "pollution", etc.-- see below for the full list) on the tile.  However, information about the marker is stored in the state table (along with the originally visible improvements), so that the marker can be displayed again if it stops being visible.
]]
---@param tile tileObject The tile on which a "marker" will be placed.
---@param tribe tribeObject The tribe for whom the "marker" is visible.
---@param markerOption markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.placeMarker(tile,tribe,markerOption)
    markerOption = string.lower(markerOption)
    local tileID = gen.getTileId(tile) --[[@as integer]]
    genStateTable.tileMarkerTable[tileID] = genStateTable.tileMarkerTable[tileID] or {}
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    tileMarkerInfo[tribe.id] = tileMarkerInfo[tribe.id] or {["originalChart"]=tile.visibleImprovements[tribe]}
    --civ.ui.text(markerOption.." placed, originalChart: "..tileMarkerInfo[tribe.id]["originalChart"])
    -- markerOptions[key] are the charting functions (to chart, we want number 2)
    local chartingFunctions= markerOptions[markerOption]
    if not chartingFunctions then
        error("gen.placeMarker: the markerOption \""..markerOption.."\" is invalid.  Attempting to place marker on tile: "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    tileMarkerInfo[tribe.id][markerOption] = true
    chartingFunctions[2](tile,tribe)
end


-- gen.removeMarker(tile,tribe,markerOption) --> void

-- Removes the `markerOption` marker for `tribe` from `tile`, if it exist.
---@param tile tileObject The tile on which a "marker" will be removed.
---@param tribe tribeObject The tribe for whom the "marker" is no longer visible.
---@param markerOption markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.removeMarker(tile,tribe,markerOption)
    markerOption = string.lower(markerOption)
    local tileID = getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    if not tileMarkerInfo then
        return
    end
    updateTileMarkerTable(tileMarkerInfo,tile)
    -- markerOptions[key] are the charting functions
    local chartingFunctions= markerOptions[markerOption]
    if not chartingFunctions then
        error("gen.removeMarker: the markerOption \""..markerOption.."\" is invalid.  Attempting to remove marker on tile: "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    if not tileMarkerInfo[tribe.id] then
        return
    end
    tileMarkerInfo[tribe.id][markerOption] = nil
    -- show the original chart, then add back any other markers
    tile.visibleImprovements[tribe] = tileMarkerInfo[tribe.id]["originalChart"]
    for key,val in pairs(tileMarkerInfo[tribe.id]) do
        if key ~= "originalChart" then
            markerOptions[key][2](tile,tribe)
        end
    end
    --civ.ui.text(markerOption.." removed, originalChart: "..tileMarkerInfo[tribe.id]["originalChart"])
    -- if removing this eliminates all marks, then clear the data
    if not markExists(tileMarkerInfo) then
        genStateTable.tileMarkerTable[tileID--[[@as integer]]] = nil
        return
    end
end

-- gen.maintainTileMarkerTable() --> void

-- Checks the marker table for any marker data that can be removed
-- and remove it.
function gen.maintainTileMarkerTable()
---@diagnostic disable-next-line: param-type-mismatch
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable) do
        updateTileMarkerTable(tileMarkerInfo,getTileFromId(tileID))
        if not markExists(tileMarkerInfo) then
            genStateTable.tileMarkerTable[tileID] = nil
        end
    end
end

-- gen.removeMarkersFromTile(tile,tribeOrNil) --> void

--[[
Removes all markers on tile for the tribe, if tribe is omitted, removes markers for all tribes.]]
---@param tile tileObject The tile for which all markers will be removed.
---@param tribe? tribeObject The tribe for which the markers will be removed.  If nil, markers for all tribes are removed.
---@overload fun(tile:tileObject)
function gen.removeMarkersFromTile(tile,tribe)
    local tileID = getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        if (tribe and tribe.id == tribeID) or not tribe then
            tile.visibleImprovements[civ.getTribe(tribeID)] = tribeMarkerInfo["originalChart"]
            tileMarkerInfo[tribeID] = nil
        end
    end
    if not markExists(tileMarkerInfo) then
        genStateTable.tileMarkerTable[tileID --[[@as integer]]] = nil
    end
end

-- gen.removeAllMarkers(tribeOrNil,markerTypeOrNil) --> void

-- Removes all markers of `markerType` for tribe.
-- If tribe not specified, removes all markerType markers for all tribes.
-- If markerType not specified, removes all markers for tribe.
-- If neither specified, removes all markers for all tribes.
---@param tribe tribeObject|nil
---@param markerType markerOptions|nil # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.removeAllMarkers(tribe,markerType)
    markerType = markerType and string.lower(markerType)
    local tileMarkerTable = genStateTable.tileMarkerTable --[[@as table]]
    if not markerType then
        for tileID, tileMarkerInfo in pairs(tileMarkerTable --[[@as table]]) do
            gen.removeMarkersFromTile(getTileFromId(tileID)--[[@as tileObject]],tribe)
        end
        return
    end
    if not markerOptions[markerType] then
        error("gen.removeAllMarkers: the markerType \""..markerType.."\" is invalid.  Attempting to remove markers  for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    if tribe then
        for tileID, tileMarkerInfo in pairs(tileMarkerTable) do
            gen.removeMarker(getTileFromId(tileID)--[[@as tileObject]],tribe,markerType)
        end
        return
    end
    for tileID, tileMarkerInfo in pairs(tileMarkerTable) do
        for i=0,7 do
            local t = civ.getTribe(i)
            if t then
                gen.removeMarker(getTileFromId(tileID)--[[@as tileObject]],t,markerType)
            end
        end
    end
    return
end


local function displayMarks(tile,tileMarkerInfo,topMarkerType,secondMarkerType)
    if not tileMarkerInfo then
        return
    end
    for tribeID, tribeMarkerInfo in pairs(tileMarkerInfo) do
        local tribe = civ.getTribe(tribeID)
        for key,val in pairs(tribeMarkerInfo) do
            if key ~= "originalChart" then
                markerOptions[key][2](tile,tribe)
            end
        end
        if secondMarkerType and tribeMarkerInfo[secondMarkerType] then
            markerOptions[secondMarkerType][2](tile,tribe)
        end
        if topMarkerType and tribeMarkerInfo[topMarkerType] then
            markerOptions[topMarkerType][2](tile,tribe)
        end
    end
end



-- gen.showAllMarkersOnTile(tile,topMarkerTypeOrNil,secondMarkerTypeOrNil) --> void

-- Reapplies the charting functions for all markers
-- on the tile for all players.  If topMarkerType isnt
-- nil, that marker type is applied again last, in case
-- there are conflicting markers.
-- The secondMarkerType is applied just before the top marker type.
---@param tile tileObject
---@param topMarkerType markerOptions|nil # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
---@param secondMarkerType markerOptions|nil # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.showAllMarkersOnTile(tile,topMarkerType,secondMarkerType)
    topMarkerType = topMarkerType and string.lower(topMarkerType--[[@as string]])
    secondMarkerType = secondMarkerType and string.lower(topMarkerType--[[@as string]])
    local tileID = getTileID(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID]
    if topMarkerType and (not markerOptions[topMarkerType]) then
        error("gen.showAllMarkersOnTile: the topMarkerType \""..tostring(topMarkerType).."\" id invalid.  Attempting to show markers for tile "..tostring(tile)..".  "..validMarkerOptionsList)
    end
    if secondMarkerType and (not markerOptions[secondMarkerType]) then
        error("gen.showAllMarkersOnTile: the secondMarkerType \""..tostring(secondMarkerType).."\" id invalid.  Attempting to show markers for tile "..tostring(tile)..".  "..validMarkerOptionsList)
    end
    displayMarks(tile,tileMarkerInfo,topMarkerType,secondMarkerType)
end

-- gen.showAllMarkers(topMarkerTypeOrNil,secondMarkerTypeOrNil) --> void

-- Reapplies the charting functions for all markers
-- on all tiles for all players.  If topMarkerType isn't nil,
-- that marker type is applied last again, in case there
-- are conflicting markers.
-- The secondMarkerType is applied just before the top marker type.
---@param topMarkerType markerOptions|nil # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
---@param secondMarkerType markerOptions|nil # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.showAllMarkers(topMarkerType,secondMarkerType)
    topMarkerType = topMarkerType and string.lower(topMarkerType)
    secondMarkerType = secondMarkerType and string.lower(secondMarkerType)
    if topMarkerType and (not markerOptions[topMarkerType]) then
        error("gen.showAllMarkers: the topMarkerType \""..tostring(topMarkerType).."\" id invalid.  "..validMarkerOptionsList)
    end
    if secondMarkerType and (not markerOptions[secondMarkerType]) then
        error("gen.showAllMarkers: the secondMarkerType \""..tostring(secondMarkerType).."\" id invalid.  "..validMarkerOptionsList)
    end
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable--[[@as table]]) do
        local tile = getTileFromId(tileID)
        displayMarks(tile,tileMarkerInfo,topMarkerType,secondMarkerType)
    end
end

-- gen.hasMarker(tile,tribe,markerType)

-- Returns true if `tile` has a marker of `markerType` for `tribe`.
---@param tile tileObject 
---@param tribe tribeObject 
---@param markerType markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.hasMarker(tile,tribe,markerType)
    markerType = string.lower(markerType)
    if not markerOptions[markerType] then
        error("gen.hasMarker: the markerType \""..markerType.."\" is invalid.  Attempting to check for a marker at "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    local tileID = gen.getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID] or {}
    return not not (tileMarkerInfo[tribe.id] and tileMarkerInfo[tribe.id][markerType])
end

-- gen.isMarkerVisible(tile,tribe,markerType)

-- Returns true if the `tile` has the `markerType` and the `markerType` is charted, false otherwise.
---@param tile tileObject 
---@param tribe tribeObject 
---@param markerType markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.isMarkerVisible(tile,tribe,markerType)
    markerType = string.lower(markerType)
    if not markerOptions[markerType] then
        error("gen.hasMarker: the markerType \""..markerType.."\" is invalid.  Attempting to check for a marker at "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    return gen.hasMarker(tile,tribe,markerType) and markerOptions[markerType][1](tile,tribe)
end

-- gen.hideMarker(tile,tribe,markerType)

-- Uncharts the `markerType` marker for the `tribe`, but does not remove the marker.
-- Does nothing if the tribe doesn't have that marker
-- or if the marker is already hidden.
---@param tile tileObject 
---@param tribe tribeObject 
---@param markerType markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.hideMarker(tile,tribe,markerType)
    markerType = string.lower(markerType)
    if not markerOptions[markerType] then
        error("gen.hasMarker: the markerType \""..markerType.."\" is invalid.  Attempting to check for a marker at "..tostring(tile).." for tribe "..tostring(tribe)..".  "..validMarkerOptionsList)
    end
    -- (gen.isMarkerVisible checks if the marker is actually there)
    if not gen.isMarkerVisible(tile,tribe,markerType) then 
        return
    end
    -- show the original chart, then add back any other markers
    local tileID = gen.getTileId(tile)
    local tileMarkerInfo = genStateTable.tileMarkerTable[tileID] or {}
    tile.visibleImprovements[tribe] = tileMarkerInfo[tribe.id]["originalChart"]
    for key,val in pairs(tileMarkerInfo[tribe.id]) do
        if key ~= "originalChart" and key ~= markerType then
            markerOptions[key][2](tile,tribe)
        end
    end
end

-- gen.hideAllMarkersOnTile(tile,tribe)

-- Hides all markers on a given tile for the given tribe.
---@param tile tileObject 
---@param tribe tribeObject 
function gen.hideAllMarkersOnTile(tile,tribe)
    for key,_ in pairs(markerOptions) do
        gen.hideMarker(tile,tribe,key)
    end
end


-- gen.hideAllMarkers(tribeOrNil,markerTypeOrNil)
-- Hides all markers of the given type for that tribe.
-- If tribe not specified, hides all markers of given type for
-- all tribes.
-- If markerType not specified, hides markers of all types.
---comment
---@param tribeOrNil tribeObject|nil
---@param markerTypeOrNil nil|markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.hideAllMarkers(tribeOrNil,markerTypeOrNil)
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable--[[@as table]]) do
        if tribeOrNil then
            if markerTypeOrNil then
                gen.hideMarker(getTileFromID(tileID)--[[@as tileObject]],tribeOrNil,markerTypeOrNil)
            else
                gen.hideAllMarkersOnTile(getTileFromID(tileID)--[[@as tileObject]],tribeOrNil)
            end
        else
            for i=0,7 do
                local tribe = civ.getTribe(i)
                if tribe then
                    if markerTypeOrNil then
                        gen.hideMarker(getTileFromID(tileID)--[[@as tileObject]],tribe,markerTypeOrNil)
                    else
                        gen.hideAllMarkersOnTile(getTileFromID(tileID)--[[@as tileObject]],tribe)
                    end
                end
            end
        end
    end
end

-- gen.showMarker(tile,tribe,markerType)

-- Shows the `markerType` for the `tribe` on the `tile`, if the marker is on the `tile`.
---@param tile tileObject 
---@param tribe tribeObject 
---@param markerType markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.showMarker(tile,tribe,markerType)
    if gen.hasMarker(tile,tribe,markerType) then
        markerOptions[markerType][2](tile,tribe)
    end
end
-- gen.showMarkerOnAllTiles(tribe,markerType)

--- Shows the `markerType` to `tribe` on all tiles where it exists.
---@param tribe tribeObject 
---@param markerType markerOptions # Valid marker options are "irrigation", "mine", "farmland", "road", "railroad", "fortress", "airbase", "pollution", "transporter".
function gen.showMarkerOnAllTiles(tribe,markerType)
    for tileID, tileMarkerInfo in pairs(genStateTable.tileMarkerTable--[[@as table]]) do
        gen.showMarker(getTileFromID(tileID)--[[@as tileObject]],tribe,markerType)
    end
end




local outOfRangeMessageFn = function(unit)
    local message =  "Your aircraft has run out of fuel.  Fighter and Missile units must return to a city or Carrier at the end of each turn.  Bomber units must return at the end of their second turn."
    local dialog = civ.ui.createDialog()
    dialog.title = "Civ Rules: Fuel"
    dialog:addText(message)
    dialog:show()
    return
end

-- gen.setOutOfRangeMessage(textOrFunction,title=nil) --> void

-- This function registers what happens when Lua code causes a
-- unit to be destroyed because it is 'out of range/fuel'.  This could be
-- because events expended the last movement points of an aircraft,
-- or because land/sea units have been given a range using Lua.  
-- (No code is run when the standard game detects an aircraft to be
-- out of range)<br><br>
-- If `textOrFunction` is a string, the text is shown when a unit is 
-- lost due to being out of range, with %STRING1 substitutes for the unit type's name.  `title` provides the title for the box.
--
-- If `textOrFunction` is a `function(unit) -> void`, the
-- function is exectued, and is trusted to generate the 
-- the function is trusted to generate a suitable message.
-- <br><br> In the Lua Scenario Template, this function is called in `parameters.lua`
---@param textOrFunction string|fun(unit:unitObject)
---@param title? string|nil
function gen.setOutOfRangeMessage(textOrFunction,title)
    if type(textOrFunction) == "string" then
        local function fuelMessage(unit)
            if type(title) ~= "string" and type(title) ~= "nil" then
                error("gen.setOutOfRangeMessage: second argument should be a string or nil.  Received: "..tostring(title))
            end
            local message = string.gsub(textOrFunction,"%%STRING1",unit.type.name)
            local dialog = civ.ui.createDialog()
            dialog.title = title or ""
            dialog:addText(message)
            dialog:show()
            return
        end
        outOfRangeMessageFn = fuelMessage
        return
    end
    if type(textOrFunction) == "function" then
        outOfRangeMessageFn = textOrFunction
    end
    error("gen.setOutOfRangeMessage: First argument should be a string or a function(unit)-->void.  Received: "..tostring(textOrFunction))
end

-- gen.outOfRangeMessage(unit) --> void

-- Shows the 'out of range' message for `unit`.
-- The message is registered by `gen.setOutOfRangeMessage`.
---@param unit unitObject
function gen.outOfRangeMessage(unit)
    outOfRangeMessageFn(unit)
end

local rangeLimitsForLandAndSea = false
local rangeLimitsForLandAndSeaAI = false
local restoreRangeFunction = function(unit)
    return unit.location.city or gen.hasAirbase(unit.location)
end

-- gen.activateRangeForLandAndSea(restoreRangeFn=nil,applyToAI=false)

--[[
This function makes land and sea units obey the range field in the rules.txt (if they are not 0),
the same way that air units do.  If `applyToAI` is set to true, the AI will lose units as well, but the AI isn't programmed to respect these limitations.
<br><br>
In the Lua Scenario Template, this function is ready to use in simpleSettings.lua.
If you're not using the Template, then this function only works if you've set up the discrete events.
]]
---@param restoreRangeFn? nil|fun(unit:unitObject):boolean #<br>This function governs when a unit's range is restored.  It is checked when the unit enters a tile and also after the unit has been given its last order for the turn (i.e. when the unit has all movement expended and the next unit is activated, or at the end of the turn if it still has movement points e.g. if sleeping).  <br>If true, range is restored, if false range is not restored.<br>By default, range is restored in city squares and on airbases.<br>If you want to clear movement points (like for air units) do it in this function.
---@param applyToAI? nil|boolean # If true, the AI's units are lost if they go beyond their range.
function gen.activateRangeForLandAndSea(restoreRangeFn,applyToAI)
    if rangeLimitsForLandAndSea then
        print("WARNING gen.activateRangeForLandAndSea: this function appears to have been run more than once, so nothing further was done.  If you don't have range for land and sea, seek help from Prof. Garfield.")
        return
    end
    if not discreteEventsFileFound then
        print("WARNING gen.activateRangeForLandAndSea: discreteEventsRegistrar.lua was not found, so range for land and sea was not activated.")
        return
    end
    for i=0, civ.cosmic.numberOfUnitTypes-1 do
        local unitType = civ.getUnitType(i) --[[@as unitTypeObject]]
        if unitType.range > 0 and unitType.domain ~= 1 and (unitType.role == 5 or unitType.role == 7) then
            error("gen.activateRangeForLandAndSea: The unit type "..unitType.name.." ("..tostring(i)..") has been assigned a range of "..tostring(unitType.range).." along with a role of "..tostring(unitType.role)..".  However, settler and trade units (roles 5 and 7) can't be given these limitations (since they use domainSpec for their special roles.")
        end
    end
    rangeLimitsForLandAndSea = true
    rangeLimitsForLandAndSeaAI = applyToAI or false
    if restoreRangeFn then
        restoreRangeFunction = restoreRangeFn
        if type(restoreRangeFn) ~= "function" then
            error("gen.activateRangeForLandAndSea: the first argument must be either nil or a function(unit)-->bool.  Received "..tostring(restoreRangeFn))
        end
    end
    function discreteEvents.onFinalOrderGiven(unit)
        local unitType = unit.type
        if not (unit.owner.isHuman or rangeLimitsForLandAndSeaAI) then
            return
        end
        if unitType.domain == 1 or unitType.range == 0 then
            return
        end
        unit.domainSpec = unit.domainSpec+1
        if restoreRangeFunction(unit) then
            unit.domainSpec = 0
        end
        if unit.domainSpec >= unitType.range then
            outOfRangeMessageFn(unit)
            for possibleCargo in unit.location.units do
                if possibleCargo.carriedBy == unit then
                    gen.killUnit(possibleCargo)
                end
            end
            gen.killUnit(unit)
        end
    end
    function discreteEvents.onEnterTile(unit,previousTile)
        local unitType = unit.type
        if not (unit.owner.isHuman or rangeLimitsForLandAndSeaAI) then
            return
        end
        if unitType.domain == 1 or unitType.range == 0 then
            return
        end
        if restoreRangeFunction(unit) then
            unit.domainSpec = 0
        end
    end
    function discreteEvents.onTribeTurnEnd(turn,tribe)
        if not(tribe.isHuman or rangeLimitsForLandAndSeaAI) then
            return
        end
        for unit in civ.iterateUnits() do
            local unitType = unit.type
            if unit.owner == tribe and unitType.domain ~= 1 and unitType.range ~= 0
                and moveRemaining(unit) > 0 then
                unit.moveSpent = moveRemaining(unit)
                unit.domainSpec = unit.domainSpec + 1
                if restoreRangeFunction(unit) then
                    unit.domainSpec = 0
                end
                if unit.domainSpec >= unitType.range then
                    outOfRangeMessageFn(unit)
                    for possibleCargo in unit.location.units do
                        if possibleCargo.carriedBy == unit then
                            gen.killUnit(possibleCargo)
                        end
                    end
                    gen.killUnit(unit)
                end
            end
        end
    end
end

-- gen.spendMovementPoints(unit,points,multiplier=totpp.movementMultipliers.aggregate,maxSpent=255,minSpent=0) -> void

-- Increases the expended movement of the `unit` by `points`.
-- If the unit has a range (either natural or through `gen.activateRangeForLandAndSea`) and
-- uses up all its movement for the current turn, its domainSpec is incremented by 1
-- and the unit is killed if it is out of range.
-- (Exceptions: if the unit is the currently active unit and is a land or sea unit
-- with range, it won't increment domainSpec, since that is caught immediately
-- afterward with onFinalOrderGiven. A unit that has already spent its full movement allowance before the modifier is applied also won't increment)
-- By default, 'full' unit movement points are used, but a different `multiplier` can be specified 
-- e.g. 1 if you want to spend atomic movement points.
-- If points is negative, movement is restored to the unit.
-- If points is not an integer, math.floor(points*multiplier) is used.
-- Final move spent is bound between maxSpent and minSpent, which are by default
-- 255 and 0 respectively.
---@param unit unitObject
---@param points number
---@param multiplier? integer
---@param maxSpent? integer # default is 255
---@param minSpent? integer # default is 0
function gen.spendMovementPoints(unit,points,multiplier,maxSpent,minSpent)
    maxSpent = maxSpent or 255
    minSpent = minSpent or 0
    if customCosmic.getMovementMultipliers and customCosmic.isEnabled() then
        multiplier = customCosmic.getMovementMultipliers(unit).aggregate
    else
        multiplier = multiplier or totpp.movementMultipliers.aggregate
    end
	local actualMoveSpent = unit.moveSpent
	if actualMoveSpent < 0 then
		actualMoveSpent = actualMoveSpent + 256
	end
    local doNotIncrement = false
    local unitType = unit.type
    if actualMoveSpent >= unitType.move then
        doNotIncrement = true
    end
    actualMoveSpent = actualMoveSpent + math.floor(points*multiplier)
    actualMoveSpent = math.min(math.max(actualMoveSpent,minSpent),maxSpent)
    unit.moveSpent = actualMoveSpent
    if actualMoveSpent < unitType.move or unitType.range == 0 or 
        (unitType.domain ~= 1 and not(unit.owner.isHuman or rangeLimitsForLandAndSeaAI)) then
        return
    end
    if unitType.domain ~= 1 and unit == civ.getActiveUnit() then
        doNotIncrement = true
    end
    if not doNotIncrement then
        unit.domainSpec = unit.domainSpec + 1
    end
    if restoreRangeFunction(unit) then
        unit.domainSpec = 0
    end
    if unit.domainSpec >= unitType.range then
        outOfRangeMessageFn(unit)
        for possibleCargo in unit.location.units do
            if possibleCargo.carriedBy == unit then
                gen.killUnit(possibleCargo)
            end
        end
        gen.killUnit(unit)
    end
end

-- gen.getBearing(compassPoint,compassCentre) --> string | Inspired by Pablostuka

---@alias compassPoints
---| "N"
---| "S"
---| "E"
---| "W"
---| "NW"
---| "NE"
---| "SW"
---| "SE"
---| ""

-- Returns one of "N","S","E","W","NW","NE","SW","SE","" based on the locations
-- of the compassPoint and compassCentre.  "" is returned if compassPoint and compassCentre are the same tile.<br><br>
-- e.g. `gen.getBearing(Madrid,Paris) --> SW`
--      Madrid is South-West of Paris
--      We're finding the location of Madrid relative to Paris, hence
--      Paris is at the compass centre and we're looking for the
--      bearing of the compass point in the direction of Madrid
--      gen.getBearing(Paris,Madrid) --> NE
--      Paris is North-East of Madrid
-- compassPoint and compassCentre can be units, cities, or tiles
-- <br><br>Inspired by Pablostuka
---@param compassPoint tileAnalog|unitObject|cityObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>cityObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@param compassCentre tileAnalog|unitObject|cityObject # Can be:<br><br>tileObject<br><br>unitObject<br><br>cityObject<br><br>{[1]=xCoord,[2]=yCoord,[3]=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{[1]=xCoord,[2]=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)<br><br>{x=xCoord,y=yCoord,z=zCoord}<br>Converted to civ.getTile(xCoord,yCoord,zCoord) <br><br>{x=xCoord,y=yCoord}<br>Converted to civ.getTile(xCoord,yCoord,0)
---@return compassPoints bearing
function gen.getBearing(compassPoint,compassCentre)
    if type(compassPoint) == "table" then
        compassPoint = toTile(compassPoint)
    elseif civ.isTile(compassPoint) then
        compassPoint = compassPoint
    elseif civ.isUnit(compassPoint) then
        compassPoint = compassPoint.location
    elseif civ.isCity(compassPoint) then
        compassPoint = compassPoint.location
    else
        error("gen.getBearing: first argument must be a tile (or coordinates of a tile) or a unit or a city.  Received: "..tostring(compassPoint))
    end
    if type(compassCentre) == "table" then
        compassCentre = toTile(compassCentre)
    elseif civ.isTile(compassCentre) then
        compassCentre = compassCentre
    elseif civ.isUnit(compassCentre) then
        compassCentre = compassCentre.location
    elseif civ.isCity(compassCentre) then
        compassCentre = compassCentre.location
    else
        error("gen.getBearing: second argument must be a tile (or coordinates of a tile) or a unit or a city.  Received: "..tostring(compassPoint))
    end
    
    local compass = ""
    
    if compassPoint.y > compassCentre.y then   
        compass = "S"   
    elseif compassPoint.y < compassCentre.y then   
        compass = "N"       
    end   
    
    if civ.game.rules.flatWorld then
        if compassPoint.x > compassCentre.x then   
            compass = compass.."E"   
        elseif compassPoint.x < compassCentre.x then   
            compass = compass.."W"       
        end   
    else
        local mapWidth,_,_ = civ.getAtlasDimensions()
        local xDiff = math.abs(compassPoint.x-compassCentre.x)
        if xDiff <= (mapWidth - xDiff) then
            -- Shortest distance does not cross date line
            if compassPoint.x > compassCentre.x then   
                compass = compass.."E"   
            elseif compassPoint.x < compassCentre.x then   
                compass = compass.."W"       
            end   
        else
            -- Shortest distance crosses dateline
            -- so the larger x is actually to the west
            if compassPoint.x > compassCentre.x then
                compass = compass.."W"
            elseif compassPoint.x < compassCentre.x then   
                compass = compass.."E"       
            end   
        end
    end
    return compass
end

-- gen.tableToString(table)
-- Returns a string showing values in a table.
---@param table any # Although this is meant to be used on a table, any kind of value can be provided.  For non-table values, the `tostring` command is used.
---@return string # A representation of the table.
function gen.tableToString(table)
    if type(table) == "table" then
        local result = "{"
        for key,val in pairs(table) do
            if type(key) == "string" then
                result = result .."['"..key.."'] = "
            else
                result = result .."["..tostring(key).."] = "
            end
            result = result .. gen.tableToString(val)..","
        end
        result = result.."}"
        return result
    else
        return tostring(table)
    end

    --local str = civlua.serialize(table)
    --str = string.sub(str,8,-1)
    --str = string.gsub(str,"\n\r"," ")
    --str = string.gsub(str,"\n"," ")
    --return str
end


local vDIKeys = {["nil"]=true,["boolean"]=true,["function"]=true,["number"]=true,
    ["string"]=true,["table"]=true,["userdata"]=true,}

-- Value Specification
--  valueSpecification = {
--      ["nil"] = true or nil
--          if this key is true, the data can be nil
--      ["boolean"] = true, "true", "false", or nil
--          if this key is true, the data can be a boolean
--          if this key is "true", only true is allowed (false is not)
--          if this key is "false", only false is allowed (true is not)
--      ["function"] = true, string or nil
--          if this key is true or string, the data can be a function
--          the string describes the function e.g. function(unit) --> number
--          (the function is not tested)
--      ["number"] = {minVal=numberNil, maxVal = numberNil, integer=trueNil} or true
--          if this key is true, the data can be a number
--          the keys in the table specify minimum and maximum values, and whether
--          the number must be an integer
--          note: math.huge and -math.huge are considered both numbers and integer here
--      ["string"] = true or {[validString] = truthy}
--          if true, the data can be any string
--          if table, the data must be one of the keys in the table
--      ["table"] = string or true or {[1]=function(table)-->true or string,[2]=string}
--          if string, any table is accepted, and the string describes the kind of table needed
--          if true, any table is accepted, and the description is a table
--          if table, [1] is a function returns that true if the table is accepted,
--          and the problem with the table if it is not
--          [2] is the description of the table required
--      ["userdata"] = {[dataTypeName]=isDataTypeFn}
--          this table is a table of each of the allowable data types, with the
--          key being the name, and the function checking if it is that type
--          being the value
--  }
function gen.validateValueSpecificationKeys(validDataInfo)
    for key,val in pairs(validDataInfo) do
        if not vDIKeys[key] then
            error("gen.checkValidDataInfo: submitted validDataInfo has a bad key: "..key)
        end
    end
end
gen.checkValidDataInfo=gen.validateValueSpecificationKeys

--  gen.describeAllowableValues(valueSpecification) --> string

--  Takes a valueSpecification, and returns a string describing the valid values.
---@param valueSpecification table # A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
---@return string
function gen.describeAllowableValues(valueSpecification)
    local desc = ""
    if valueSpecification["nil"] then
        desc = desc.."nil, "
    end
    if valueSpecification["boolean"] == true then
        desc = desc.."boolean, "
    elseif valueSpecification["boolean"] == "true" then
        desc = desc.."true, "
    elseif valueSpecification["boolean"] == "false" then
        desc = desc.."false, "
    end
    if type(valueSpecification["function"]) == "string" then
        desc = desc..valueSpecification["function"]..", "
    elseif valueSpecification["function"] == true then
        desc = desc.."function, "
    end
    if valueSpecification["number"] == true then
        desc = desc.."number, "
    elseif valueSpecification["number"] then
        local number = "number"
        if valueSpecification["number"].integer then
            number = "integer"
        end
        if valueSpecification["number"].minVal and valueSpecification["number"].maxVal then
            desc = desc..number.." between "..tostring(valueSpecification["number"].minVal)
            .." and "..tostring(valueSpecification["number"].maxVal)..", "
        elseif valueSpecification["number"].minVal then
            desc = desc..number.." at least "..tostring(valueSpecification["number"].minValue)..", "
        elseif valueSpecification["number"].maxVal then
            desc = desc..number.." at most "..tostring(valueSpecification["number"].maxValue)..", "
        else
            desc = desc..number..", "
        end
    end
    if valueSpecification["string"] == true then
        desc = desc.."string, "
    elseif type(valueSpecification["string"]) == "table" then
        for validString,_ in pairs(valueSpecification["string"]) do
            desc = desc..'"'..validString..'", '
        end
    end
    if valueSpecification["table"] == true then
        desc = desc.."table, "
    elseif type(valueSpecification["table"]) == "string" then
        desc = desc..valueSpecification["table"]..", "
    elseif type(valueSpecification["table"]) == "table" then
        desc = desc..valueSpecification["table"][2]..", "
    end
    if type(valueSpecification["userdata"]) == "table" then
        for dataTypeName,_ in pairs(valueSpecification["userdata"]) do
            desc = desc..dataTypeName..", "
        end
    end
    return desc
end
gen.describeAllowableData = gen.describeAllowableValues


-- gen.validateFunctionArgument(data,moduleName,functionName,argumentNumber, argumentName,validDataInfo,extraInfo=nil) --> void or error

--  This validates a function's argument, and provides an error if a bad value is supplied.
---@param value any The argument passed to the function.
---@param moduleName string The name of the module the function is in (so generated errors are more informative).
---@param functionName string The name of the function this function is validating values for (so generated errors are more informative).
---@param argumentNumber integer The argument which is being validated (so generated errors are more informative).
---@param argumentName string The name of the argument which is being validated (so generated errors are more informative).
---@param extraInfo? string|nil Any extra information that might help in debugging, should an error occur.
---@param valueSpecification table # A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
function gen.validateFunctionArgument(value,moduleName,functionName,argumentNumber,argumentName,valueSpecification,extraInfo)
    gen.checkValidDataInfo(valueSpecification)
    local dataType = type(value)
    local vDI = valueSpecification[dataType]
    local function constructErrorMessage(data,moduleName,functionName,argumentNumber,argumentName,
                extraInfo, tableReturnInfo)
        local tostringResult = tostring(data)
        if type(data) == "table" then
            tostringResult = gen.tableToString(data)
        elseif type(data) == "string" then
            tostringResult = 'string<"'..data..'">'
        end
        local errorMessage = "module: "..moduleName.."; function: "..functionName.."; argument number: "
            ..tostring(argumentNumber).."; argument name: "..argumentName.."; "
        if extraInfo then
            errorMessage = errorMessage.."; extra information: "..extraInfo.."; "
        end
        errorMessage = errorMessage.."Expected :"..gen.describeAllowableData(valueSpecification)
            .."; Received: "..tostringResult
        if tableReturnInfo then
            errorMessage = errorMessage.."; Reported table problem: "..tableReturnInfo
        end
        return errorMessage
    end
    if not vDI then
        error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    end
    if dataType == "nil" then
        -- if nil isn't allowed, it is caught in not vDI
        return
    elseif dataType == "boolean" then
        if (vDI == true or tostring(value) == vDI) then
            return
        else
            error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo))
        end
    elseif dataType == "function" then
        -- The function is not checked beyond the fact that it is a function
        -- If the function isn't allowed, it is caught in not vDI
        return
    elseif dataType == "number" then
        if vDI == true then
            return
        end
        local minVal = vDI.minVal or -math.huge
        local maxVal = vDI.maxVal or math.huge
        local notInteger = not vDI.integer
        if value >= minVal and value <= maxVal and (notInteger or value == math.floor(value)) then
            return
        end
        error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    elseif dataType == "string" then
        if vDI == true or vDI[value] then
            return
        end
        error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    elseif dataType == "table" then
        if vDI == true or type(vDI) == "string" then
            -- don't check anything specific about the table
            return 
        end
        local errorString = vDI[1](value)
        if type(errorString) == "string" then
            error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo,errorString))
        end
    elseif dataType == "userdata" then
        for dataTypeName,isDataTypeFn in pairs(vDI) do
            if isDataTypeFn(value) then
                return
            end
        end
        error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    else
        error(constructErrorMessage(value,moduleName,functionName,argumentNumber,argumentName, extraInfo))
    end
end

-- gen.versionFunctions(moduleTable,versionNumber,fileMod,moduleFileName) -->void

--[[
Provides module with these methods<br>
`module:minVersion(vNumber)`<br>
Causes an error if the module's versionNumber is below vNumber.<br>
`module:recommendedVersion(vNumber)`<br>
Prints a warning to the console if the module's versionNumber is below vNumber.
<br>
Note: Using these methods will stop Lua Language Server from recognizing a require function.  To avoid this, use ---@module "fileName" on the line above:
```lua
---@module "someModuleName"
local someModule = require("someModuleName"):minVersion(2)
```
]]
---@param moduleTable table The table that has the module functions.
---@param vNum number the module's current version number
---@param fileMod boolean A boolean telling if the file has been modified by the scenario designer.  This way, the error can warn the designer that upgrading may remove some work they did.
---@param moduleFileName string The module's file name.
function gen.versionFunctions(moduleTable,vNum,fileMod,moduleFileName)
    local minVersion = function(self,minVersion)
        if vNum < minVersion then
            local message = "The "..moduleFileName.." file is out of date.  It is version "..tostring(vNum)..
            ", but one of your other files needs version "..tostring(minVersion).." or later.  "
            .."You should download the most recent version of the Lua Scenario Template, and replace "
            ..moduleFileName.." with the updated version."
            if fileMod then
                message = message.."\nIMPORTANT WARNING: it appears you've changed this file for your scenario."
                .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."

            end
            error(message)
        end
        return self
    end
    local recommendedVersion = function(self,recVersion)
        if vNum < recVersion then
            local message = "WARNING: The "..moduleFileName.." is out of date.  It is version "..tostring(vNum)..
            ", but one of your files recommends version "..tostring(recVersion).." or later.  "
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
    if moduleTable.minVersion or moduleTable.recommendedVersion or moduleTable.getVersion then
        error("gen.versionFunctions: this module has already assigned the minVersion, recommendedVersion or version keys.")
    end
    moduleTable.minVersion = minVersion
    moduleTable.recommendedVersion = recommendedVersion
    moduleTable.getVersion = vNum
end

gen.versionFunctions(gen,versionNumber,fileModified,"LuaCore".."\\".."generalLibrary.lua")

-- gen.registerEventsLuaVersion(versionNumber,fileMod,regressionNumber)
local eventsVersion = {}

-- In the Lua Scenario Template, this is called in events.lua, so you do not need to worry about it.
--  Registers version information for the events.lua file.<br>
--  versionNumber is the events.lua verison number<br>
--  fileMod is a boolean that should be true if events.lua has been modified by the scenario designer<br>
--  regressionNumber is incremented if events.lua has functionality removed<br>
---@param vNum number
---@param fileMod boolean
---@param regressionNumber number
function gen.registerEventsLuaVersion(vNum,fileMod,regressionNumber)
    eventsVersion.versionNumber = vNum
    eventsVersion.fileModified = fileMod
    eventsVersion.regressionNumber = regressionNumber
end

-- Checks that the events.lua file is up to date, so all of the module's tie ins to the rest of the code base work properly.
---@param minVersion number
---@param regNum number
---@param fileName string
function gen.minEventsLuaVersion(minVersion,regNum,fileName)
    if gen.isEmpty(eventsVersion) then
        print("WARNING: "..fileName.." expects to use version "..tostring(minVersion).." of the Lua Scenario Template, but no version of events.lua has been registered.  If you are using the Lua Scenario Template, this means your events.lua file is out of date.  If you are not, you can suppress this warning by adding the following line the first time in your code that you require the general library:\ngen.registerEventsLuaVersion("..minVersion..",false,"..regNum)
        return
    end
    if minVersion > eventsVersion.versionNumber then
        local message = "The events.lua file is out of date.  It is version "..tostring(eventsVersion.versionNumber)
        ..", but one of your other files needs version "..tostring(minVersion).." or later.  "
        .."You should download the most recent version of the Lua Scenario Template, and replace "
        .."events.lua with the updated version."
        if eventsVersion.fileModified then
            message = message.."\nIMPORTANT WARNING: it appears you've changed events.lua for your scenario."
            .."  Replacing this file will remove those changes.  You will have to reimplement them in the new version of the file."
        end
        if regNum > eventsVersion.regressionNumber then
            message = message.."\nIMPORTANT WARNING: it appears that events.lua has had some sort of functionality removed or changed.  Seek advice before updating."
        end
        error(message)
    end
end

-- Generates an error if the `value` doesn't satisfy the `valueSpec`.  This is a "building block" function, so you probably don't want to use it.
---@param tableDescription string A description of the table.
---@param key any The key being evaluated.
---@param value any The value being evaluated.
---@param extraInfo? string Extra information that might be useful when debugging.
---@param valueSpec table # A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
function gen.validateTableValue(tableDescription,key,value,valueSpec,extraInfo)
    gen.checkValidDataInfo(valueSpec)
    local data = value
    local dataType = type(data)
    local vDI = valueSpec[dataType]
    local function constructErrorMessage(data,tableDescription,key,extraInfo, tableReturnInfo)
        local tostringResult = tostring(data)
        if type(data) == "table" then
            tostringResult = gen.tableToString(data)
        elseif type(data) == "string" then
            tostringResult = 'string<"'..data..'">'
        end
        local errorMessage = tableDescription..": key: "..tostring(key).."; "
        errorMessage = errorMessage.."Expected :"..gen.describeAllowableData(valueSpec)
            .."; Received: "..tostringResult
        if tableReturnInfo then
            errorMessage = errorMessage.."; Reported table problem: "..tableReturnInfo
        end
        if extraInfo then
            errorMessage = errorMessage.."; extra information: "..extraInfo
        end
        return errorMessage
    end
    if not vDI then
        error(constructErrorMessage(data,tableDescription,key, extraInfo))
    end
    if dataType == "nil" then
        -- if nil isn't allowed, it is caught in not vDI
        return
    elseif dataType == "boolean" then
        if (vDI == true or tostring(data) == vDI) then
            return
        else
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
        end
    elseif dataType == "function" then
        -- The function is not checked beyond the fact that it is a function
        -- If the function isn't allowed, it is caught in not vDI
        return
    elseif dataType == "number" then
        if vDI == true then
            return
        end
        local minVal = vDI.minVal or -math.huge
        local maxVal = vDI.maxVal or math.huge
        local notInteger = not vDI.integer
        if data >= minVal and data <= maxVal and (notInteger or data == math.floor(data)) then
            return
        end
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
    elseif dataType == "string" then
        if vDI == true or vDI[data] then
            return
        end
            error(constructErrorMessage(data,tableDescription,key, extraInfo))
    elseif dataType == "table" then
        if vDI == true or type(vDI) == "string" then
            -- don't check anything specific about the table
            return 
        end
        local errorString = vDI[1](data)
        if type(errorString) == "string" then
            error(constructErrorMessage(data,tableDescription,key, extraInfo,errorString))
        end
    elseif dataType == "userdata" then
        for dataTypeName,isDataTypeFn in pairs(vDI) do
            if isDataTypeFn(data) then
                return
            end
        end
        error(constructErrorMessage(data,tableDescription,key, extraInfo))
    else
        error(constructErrorMessage(data,tableDescription,key, extraInfo))
    end
end

-- gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable) -->
--      newItemFunction(table) --> dataType,
--          creates (and validates) a new instance of the data type
--      isDataTypeFunction(value) --> boolean,
--          creates a function that checks if a value is the dataType
--      dataTypeMetatable
--          the metatable for the data type

--[[
Returns functions necessary to create a basic custom data type.  Such a data type
is a table, but uses a metatable to restrict the keys that are allowed to be used,
and the values that can be assigned to those keys.  This way, errors can be
generated when incorrect key-value pairs are assigned to the data type, rather
than when later code receives unexpected values.
<br>Several parameters are defined with "valueSpecification" tables.
A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
]]
---@param dataName string #<br>string<br><br> The name of the new data type.
---@param specificKeyTable table<any,table> #<br>specificKeyTable={[key]=valueSpecification}<br><br>Each `key` is a key that is allowed in the `dataName` data type, and values assigned to the `key` must satisfy the corresponding `valueSpecification`.
---@param generalKeyTable table<fun(possibleKey:any):boolean,table> #<br>generalKeyTable = {[function(possibleKey)-->boolean] = valueSpecification} <br><br> This table allows for keys of a general form to be used in the data type.  For a `possibleKey`, if any `function(possibleKey)` returns true, a value can be assigned to `possibleKey` as long as it satisfies the valueSpecification.
---@param defaultValueTable table #<br>defaultValueTable = {[key]=value}<br><br>When a new `dataName` is created, if `key` is not specified, assign the corresponding `value` to it.
---@param fixedKeyTable table<any,true> #<br>fixedKeyTable = {[key]=true}<br><br> If `key` is in this table, the new `dataName` can't change the value of the key after it is created.
---@param aliasKeyTable? nil|table<any,any>|fun(aliasKey:any):any #<br>aliasKeyTable = {[aliasKey] = key} or<br>fun(aliasKey)->key<br><br>If table, and the aliasKey is a key in the aliasKeyTable, then the associated key is used for indexing or assigning instead.<br>If function, all keys have the function applied to them, and the returned value is used as a key instead.
---@generic newDataType
---@return fun(table:table):newDataType # Creates a new instance of the `dataName` data type, assigning to it all the table key-value pairs in the `table`.<br>Generates an error if any key-value pairs are invalid.
---@return fun(item:any):boolean # Checks if `item` is an instance of the `dataName` data type, returns true if it is, and false otherwise.
---@return table # The [metatable](https://www.tutorialspoint.com/lua/lua_metatables.htm) for the `dataName` data type.  This is available in case you want to make more customizations to the data type.
function gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable,aliasKeyTable)
    aliasKeyTable = aliasKeyTable or {}
    local aliasKeyFunction = nil
    specificKeyTable = gen.copyTableWithMetatable(specificKeyTable)
    for key,vDI in pairs(specificKeyTable) do
        gen.checkValidDataInfo(vDI)
    end
    generalKeyTable = gen.copyTableWithMetatable(generalKeyTable)
    for key,vDI in pairs(generalKeyTable) do
        gen.checkValidDataInfo(vDI)
        if not vDI["nil"] then
            error("gen.createDataType: (creating "..dataName..") keys defined by the generalKeyTable must be allowed to have nil values.")
        end
    end
    defaultValueTable = gen.copyTableWithMetatable(defaultValueTable)
    fixedKeyTable = gen.copyTableWithMetatable(fixedKeyTable)
    local function validDataInfoForKey(key)
        if specificKeyTable[key] then
            return specificKeyTable[key]
        end
        for keyCheckFn,vDI in pairs(generalKeyTable) do
            if keyCheckFn(key) then
                return vDI
            end
        end
        return false
    end
    if type(aliasKeyTable) == "table" then
        aliasKeyTable = gen.copyTableWithMetatable(aliasKeyTable)
        for aliasKey,key in pairs(aliasKeyTable) do
            if not validDataInfoForKey(key) then
            error("gen.createDataType: (creating "..dataName..") The aliasKey "..tostring(aliasKey).." is translated to "..tostring(key)..", but that is not a valid key for this data type.")
            end
        end
        aliasKeyFunction = function(aliasKey)
            return aliasKeyTable[aliasKey] or aliasKey
        end
    elseif type(aliasKeyTable) == "function" then
        aliasKeyFunction = aliasKeyTable
    else
        error("gen.createDataType: arg#6 is supposed to be a table or a function (or nil).  Instead received: "..tostring(aliasKeyTable))
    end
    for key,value in pairs(defaultValueTable) do
        local vDI = validDataInfoForKey(key)
        if not vDI then
            error("gen.createDataType: (creating "..dataName..") the key "..tostring(key).." in the defaultValueTable is not a valid key for this data type.")
        end
        gen.validateTableValue("gen.createDataType (creating "..dataName..")",key,value,vDI)
    end
    for key,_ in pairs(fixedKeyTable) do
        local vDI = validDataInfoForKey(key)
        if not vDI then
            error("gen.createDataType: (creating "..dataName.." the key "..tostring(key).." in the fixedKeyTable is not a valid key for this data type.")
        end
    end
    local uniqueTableForDataType = {}
    local mt = {}
    mt.trueTableKey = uniqueTableForDataType
    mt.__index = function(t,aliasKey)
        local key = aliasKeyFunction(aliasKey)
        if validDataInfoForKey(key) then
            return t[uniqueTableForDataType][key]
        else
            error(dataName..".index: the key "..tostring(key).." (aliasKey: "..tostring(aliasKey)..") is not a valid key for "..dataName)
        end
    end
    mt.__newindex = function(t,aliasKey,value)
        local key = aliasKeyFunction(aliasKey)
        local vDI = validDataInfoForKey(key)
        if not vDI then
            error(dataName..".index: the key "..tostring(key).." (aliasKey:"..tostring(aliasKey)..") is not a valid key for "..dataName)
        end
        if fixedKeyTable[key] then
            error(dataName..".newIndex: the key "..tostring(key).." (aliasKey:"..tostring(aliasKey)..") can't be changed after the "..dataName.." is created.")
        end
        gen.validateTableValue(dataName,key,value,vDI)
        t[uniqueTableForDataType][key] = value
    end
    mt.__pairs = function(t)
        return pairs(t[uniqueTableForDataType])
    end
    mt.__ipairs = function(t)
        return ipairs(t[uniqueTableForDataType])
    end
    local function newItemFunction(table)
        local newData = {}
        newData[uniqueTableForDataType] = {}
        for key,value in pairs(defaultValueTable) do
            newData[uniqueTableForDataType][key] = value
        end
        for aliasKey,value in pairs(table) do
            local key = aliasKeyFunction(aliasKey)
            local vDI = validDataInfoForKey(key)
            if not vDI then
                error("new "..dataName..": the key "..tostring(key).." (aliasKey:"..tostring(aliasKey)..") is invalid.")
            end
            gen.validateTableValue("new "..dataName,key,value,vDI)
            newData[uniqueTableForDataType][key] = value
        end
        for key,vDI in pairs(specificKeyTable) do
            local value = newData[uniqueTableForDataType][key]
            gen.validateTableValue("new "..dataName,key,value,vDI,"(note: the most likely cause of this error is that this key can't be nil, a default value for the key was not provided when designing the constructor, and the key's value was not provided.")
        end
        setmetatable(newData,mt)
        return newData
    end

    local function isDataTypeFunction(value)
        return type(value) == "table" and getmetatable(value) == mt
    end
    return newItemFunction, isDataTypeFunction, mt
end

-- gen.valueSatisfiesValidDataInfo(value,validDataInfo)--> boolean
-- gen.valueSatisfiesSpecification(value,valueSpecification)-->boolean

--  Returns true if value satisfies the valueSpecification, false otherwise.
---@param value any
---@param valueSpecification table # A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
---@return boolean
function gen.valueSatisfiesSpecification(value,valueSpecification)
    local data = value
    local dataType = type(data)
    local vDI = valueSpecification[dataType]
    if not vDI then
        return false
    end
    if dataType == "nil" then
        -- if nil isn't allowed, it is caught in not vDI
        return true
    elseif dataType == "boolean" then
        if (vDI == true or tostring(data) == vDI) then
            return true
        else
            return false
        end
    elseif dataType == "function" then
        -- The function is not checked beyond the fact that it is a function
        -- If the function isn't allowed, it is caught in not vDI
        return true
    elseif dataType == "number" then
        if vDI == true then
            return true
        end
        local minVal = vDI.minVal or -math.huge
        local maxVal = vDI.maxVal or math.huge
        local notInteger = not vDI.integer
        if data >= minVal and data <= maxVal and (notInteger or data == math.floor(data)) then
            return true
        end
        return false
    elseif dataType == "string" then
        if vDI == true or vDI[data] then
            return true
        end
        return false
    elseif dataType == "table" then
        if vDI == true or type(vDI) == "string" then
            -- don't check anything specific about the table
            return true
        end
        local errorString = vDI[1](data)
        if type(errorString) == "string" then
            return false
        end
    elseif dataType == "userdata" then
        for dataTypeName,isDataTypeFn in pairs(vDI) do
            if isDataTypeFn(data) then
                return true
            end
        end
        return false
    else
        return false
---@diagnostic disable-next-line: missing-return
    end
end
gen.valueSatisfiesValidDataInfo = gen.valueSatisfiesSpecification



-- gen.tableOfVDI(validDataInfo) --> validDataInfo
-- gen.tableOfValueSpecification(valueSpecification) --> valueSpecification

--  Takes a valueSpecification, and returns a valueSpecification where
--  the valid data is a table where all values are of the
--  submitted valueSpecification.
---@param valueSpecification table # A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
---@return table valueSpecification
function gen.tableOfValueSpecification(valueSpecification)
    gen.checkValidDataInfo(valueSpecification)
    local vDI = gen.copyTable(valueSpecification)
    local function analysisFn(table)
        for key,value in pairs(table) do
            if not gen.valueSatisfiesValidDataInfo(value,vDI) then
                return "The key "..tostring(key).." has an invalid value of "..tostring(value).."."
            end
        end
        return true
    end
    return {["table"]={analysisFn,"A table with these values "..gen.describeAllowableData(vDI)}}
end
gen.tableOfVDI = gen.tableOfValueSpecification

-- gen.vDIOrTableOfVDI(validDataInfo) --> validDataInfo
-- valueSpecificationOrTableOfValueSpecification(valueSpecification) --> valueSpecification

--  Takes a valueSpecification, and returns a newValueSpecification.
--  The newValueSpecification allow both the original valueSpecification
--  and tables where values are the original valueSpecification.<br><br>
--  Limiation: the valueSpecification can't have a any tables as valid value types.  If you need that, consider `gen.tableOfValueSpecification` or writing a custom valueSpecification.
---@param valueSpecification table # A valueSpecification is a table with the following keys and values:<br><br>["nil"] = true or nil<br>If this key is true, the specified value can be nil.<br><br>["boolean"] = true, "true", "false", or nil<br>If this key is true (boolean value), the specified value can be a boolean.<br>If this key is "true" (string), then the specified value can be true, but not false.<br>If this key is "false" (string), then the specified value can be false, but not true.<br>If this key is nil, the specified value can't be a boolean.<br><br>["function"] = true, string, or nil<br>if this key is true or string, the specified value can be a function.<br>If string, the string describes the function, e.g. `function(unit)-->number`.  Value specification checks do not check if the function actually matches the description, only that it is a function.<br>If this key is nil, the specified value can't be a function.<br><br>["number"] = true or nil or {minVal=number/nil, maxVal=number/nil, integer=true/nil}<br>If true, the specified value can be any number.  If nil, the specified value can't be a number.<br>If table, any number must also be larger than the `minVal` (if specified) and smaller than the `maxVal` (if specified).  If the `integer` key is true, the value must also be an integer.<br><br>["string"] = true or {[validString] = truthy} or nil<br>If this key is true, any string is allowed.<br>If it is a table, any string value must be a key in that table, with a truthy (anything other than false/nil) associated value.<br>If nil, the value can't be a string.<br><br>["table"]=string, true, nil, or {[1]=function(table)->true or string, [2]=string}<br>If the key is a string, any table is accepted, and the string describes the kind of table needed.<br>If true, any table is accepted, and a generated description will be 'table'.<br>If the key is a table, the table's value for `1` is a function, which returns true if specified value is an acceptable table, and a string describing the problem if it is not.  The value for `2` is a string describing the required table, for generated descriptions/errors.<br>If nil, the specified value can't be a table.<br><br>["userdata"] = {[dataTypeName]=isDataTypeFn} or nil<br>The keys to this table are strings that describe acceptable userdata, and the values are functions which return true if the specified value matches the type, and false otherwise.<br>E.g.<br>`{["unitTypeObject"] = civ.isUnitType, ["cityObject"] = civ.isCity}`<br>Allows unitTypeObjects and cityObjects, but not other kinds of userdata.
---@return table newValueSpecification
function gen.valueSpecificationOrTableOfValueSpecification(valueSpecification)
    gen.checkValidDataInfo(valueSpecification)
    local vDI = gen.copyTable(valueSpecification)
    if vDI["table"] then
        error("gen.valueSpecificationOrTableOfValueSpecification: valueSpecification has a table as a kind of valid data.  This is invalid for this function.  You can use gen.tableOfValueSpecification, or write a custom valueSpecification.")
    end
    local function analysisFn(table)
        for key,value in pairs(table) do
            if not gen.valueSatisfiesValidDataInfo(value,vDI) then
                return "The key "..tostring(key).." has an invalid value of "..tostring(value).."."
            end
        end
        return true
    end
    local vDICopy = gen.copyTable(vDI)
    vDICopy["table"]={analysisFn,"A table with these values "..gen.describeAllowableData(vDI)}
    return vDICopy
end
gen.vDIOrTableOfVDI = gen.valueSpecificationOrTableOfValueSpecification
gen.valueSpecOrTable = gen.valueSpecificationOrTableOfValueSpecification

---Creates a value specification for custom data created by `gen.createDataType` (or any other data type that uses a table as the base).
---@param isItemFn fun(item:any):boolean # A function that returns true if the item is the appropriate data type, and false otherwise.
---@param failureDescription string # A message explaining that the item is not the appropriate data type.
---@param itemDescription string # A description of the data type.
---@return table
function gen.valueSpecForCustomData(isItemFn,failureDescription,itemDescription)
    local itemCheckFn = function(item)
        return isItemFn(item) or failureDescription
    end
    return {["table"]={itemCheckFn,itemDescription}}
end


-- stack data type
--      stack.push(value) --> void
--          adds value to the 'top' of the stack
--      stack.pop() --> value
--          removes value from the 'top' of the stack and returns the value
--          popping an empty stack returns nil
--      stack[i] --> value
--          returns the value of ith item from the 'top' of the stack
--          (the stack remains unchanged)
--          stack[1] is the top item of the stack (the same item stack.pop would remove)
--          if the stack doesn't have an ith item, return nil
--      stack.size --> integer
--          returns the number of items in the stack

--[[A "stack" is a data structure where you can 'push' a value onto the top of the stack, or you can 'pop' a value off the top of the stack.  The popped value is returned, but is no longer on the stack.  This implementation of the stack also lets you find the ith element in the stack, starting from the top, and lets you see the size of the stack.  See: [Wikipedia: Stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type))
<br><br> `stack.push = function(value:any)-->void` <br><br> When called, adds `value` to the top of the stack.<br>`stack.push(5)` adds `5` to the top of the stack.
<br><br> `stack.pop = function()-->any` <br><br> When called, removes the top item of the stack, and returns it.<br><br>If the stack is formed by<br>`stack.push(1)`<br>`stack.push(2)`<br>`stack.push(3)`<br>then<br>`stack.pop()`-->`3`<br>`stack.pop()`-->`2`<br>`stack.pop()`-->`1`<br>`stack.pop()`-->`nil`
<br><br> `stack.size = integer` <br><br> Returns the current size of the stack.
<br><br> `stack[i] = any` <br><br>`stack[i]` returns the ith value in the stack, counting from the top, or nil if there aren't `i` values in the stack. The stack remains unchanged.<br><br>If the stack is formed by `stack.push(1)`<br>`stack.push(2)`<br>`stack.push(3)`<br>then<br>`stack[1]`-->`3`<br>`stack[2]`-->`2`<br>`stack[3]`-->`1`<br>`stack[4]`-->`nil`]]
---@class stack
---@field push fun(value:any) # When called, adds `value` to the top of the stack.<br>`stack.push(5)` adds `5` to the top of the stack.
---@field pop fun():any # When called, removes the top item of the stack, and returns it.<br><br>If the stack is formed by `stack.push(1)`<br>`stack.push(2)`<br>`stack.push(3)`<br>then<br>`stack.pop()`-->`3`<br>`stack.pop()`-->`2`<br>`stack.pop()`-->`1`<br>`stack.pop()`-->`nil`
---@field size integer # Returns the current size of the stack.
---@field [integer] any # <br>`stack[i]` returns the ith value in the stack, counting from the top, or nil if there aren't `i` values in the stack. The stack remains unchanged.<br><br>If the stack is formed by `stack.push(1)`<br>`stack.push(2)`<br>`stack.push(3)`<br>then<br>`stack[1]`-->`3`<br>`stack[2]`-->`2`<br>`stack[3]`-->`1`<br>`stack[4]`-->`nil`

local stackDataKey = {}
local stackUnusedIndexKey = {}
local stackMT = {
    __index = function(stack,key)
        if type(key) == "number" then
            local topIndex = stack[stackUnusedIndexKey]
            return stack[stackDataKey][topIndex-key]
        elseif key == "size" then
            return stack[stackUnusedIndexKey]-1
        elseif key == "push" then
            return function(value)
                local topIndex = stack[stackUnusedIndexKey]
                stack[stackDataKey][topIndex] = value
                stack[stackUnusedIndexKey] = topIndex+1
            end
        elseif key == "pop" then
            return function()
                stack[stackUnusedIndexKey] = math.max(stack[stackUnusedIndexKey] - 1,1)
                local topIndex = stack[stackUnusedIndexKey] 
                local popValue = stack[stackDataKey][topIndex]
                stack[stackDataKey][topIndex] = nil
                return popValue
            end
        else
            error("The only valid keys for a stack are numbers, 'size', 'push', and 'pop'.")
        end
    end,
    __newindex = function(stack,key,value)
        error("stack: you can only add new values to a stack by using the 'push' command:\n"
        .."myStack.push("..tostring(value)..")..")
    end,
    __tostring = function(stack)
        local output = "stack<"
        local topIndex = stack[stackUnusedIndexKey]
        local stackData = stack[stackDataKey]
        for i=1,topIndex-1 do
            output = output..tostring(i).."="..tostring(stackData[topIndex-i])..", "
        end
        output = output..">"
        return output
    end,
}
-- gen.newEmptyStack() --> stack

-- Creates a stack with no values.
---@return stack
function gen.newEmptyStack()
    local stack = {[stackDataKey] = {},[stackUnusedIndexKey] = 1}
    setmetatable(stack,stackMT)
    return stack
end

-- gen.newStack(table = {}) --> stack

--generates a new stack, with integer
--values in the table pushed onto the stack
--starting from the smallest integer value
--(smallest value will be at the bottom of the stack).
--All other keys (including non-integer keys) and values are ignored.
---@param table? any # Default is an empty table.
---@return stack
function gen.newStack(table)
    local smallestNumber = math.huge
    local largestNumber = -math.huge
    table = table or {}
    for key,_ in pairs(table) do
        if type(key) == "number" and math.floor(key) == key then
            smallestNumber = math.min(key,smallestNumber)
            largestNumber = math.max(key,largestNumber)
        end
    end
    local stack = gen.newEmptyStack()
    if smallestNumber == math.huge then
        return stack
    end
    for i=smallestNumber,largestNumber do
        if table[i] then
            stack.push(table[i])
        end
    end
    return stack
end

-- gen.isStack(item) --> boolean

--Returns `true` if the item is a stack (created by gen.newStack/newEmptyStack)
--and `false` otherwise.
---@param item any
---@return boolean
function gen.isStack(item)
    return type(item) == "table" and getmetatable(item) == stackMT
end
    
-- gen.isInteger(item) --> boolean

-- Returns true if the item is an integer, and false otherwise.
---@param item any
---@return boolean
function gen.isInteger(item)
    return type(item) == "number" and math.floor(item) == item
end

---Returns an iterator for all unitType objects.
---@return iterator
function gen.iterateUnitTypes()
---@diagnostic disable-next-line: return-type-mismatch
    return coroutine.wrap(function()
        for id = 0,civ.cosmic.numberOfUnitTypes-1 do
            coroutine.yield(civ.getUnitType(id))
        end
    end)
end

---Returns an iterator for all improvement objects.
---@return iterator
function gen.iterateImprovements()
---@diagnostic disable-next-line: return-type-mismatch
    return coroutine.wrap(function()
        for id = 0,gen.constants.maxImprovementID do
            coroutine.yield(civ.getImprovement(id))
        end
    end)
end

---Returns an iterator for all wonder objects.
---@return iterator
function gen.iterateWonders()
---@diagnostic disable-next-line: return-type-mismatch
    return coroutine.wrap(function()
        for id = 0,gen.constants.maxWonderID do
            coroutine.yield(civ.getWonder(id))
        end
    end)
end

---Returns an iterator for all baseTerrain objects (for maps that are
--in the game).
---@return iterator
function gen.iterateBaseTerrain()
    local _,_,maps = civ.getAtlasDimensions()
---@diagnostic disable-next-line: return-type-mismatch
    return coroutine.wrap(function()
        for z=0,maps-1 do
            for t=0,gen.getNumberOfTerrainTypes(z)-1 do
                coroutine.yield(civ.getBaseTerrain(z,t))
            end
        end
    end)
end

---Returns an iterator for all terrain objects (for maps that
--are in the game).
---@return iterator
function gen.iterateTerrain()
    local _,_,maps = civ.getAtlasDimensions()
    local noResource = gen.constants.resourceNone
    local fishResource = gen.constants.resourceFish
    local whaleResource = gen.constants.resourceWhale
    local grasslandType = gen.constants.grasslandType
---@diagnostic disable-next-line: return-type-mismatch
    return coroutine.wrap(function()
        for z=0,maps-1 do
            for t=0,gen.getNumberOfTerrainTypes(z)-1 do
                coroutine.yield(civ.getTerrain(z,t,noResource))
                if t ~= grasslandType then
                    coroutine.yield(civ.getTerrain(z,t,fishResource))
                    coroutine.yield(civ.getTerrain(z,t,whaleResource))
                end
            end
        end
    end)
end

---Returns an iterator for all tech objects.
function gen.iterateTechs()
    return coroutine.wrap(function()
        for id = 0,gen.constants.maxTechID do
            coroutine.yield(civ.getTech(id))
        end
    end)
end

---Checks if the `baseTerrain` gets +1 trade production from a road.
---@param baseTerrain baseTerrainObject
function gen.isRoadTradeBonus(baseTerrain)
    return isBit1(totpp.roadTrade[baseTerrain.map],baseTerrain.type+1)
end

---Gives the `baseTerrain` +1 trade production from a road.
---@param baseTerrain baseTerrainObject
function gen.giveRoadTradeBonus(baseTerrain)
    local z = baseTerrain.map
    totpp.roadTrade[z] = setBit1(totpp.roadTrade[z],baseTerrain.type+1)
end

---Removes the +1 trade production from a road for `baseTerrain`.
---@param baseTerrain baseTerrainObject
function gen.removeRoadTradeBonus(baseTerrain)
    local z = baseTerrain.map
    totpp.roadTrade[z] = setBit0(totpp.roadTrade[z],baseTerrain.type+1)
end

-- mapTransportRelationships[map1ID][map2ID] = tableOfnumber or false
-- if false, there is no transport relationship between the maps
-- if tableOfNumber, each number corresponds to a flag position for
-- that transport relationship for nativeTransport, buildTransport,
-- useTransport.  (rightmost flag is 1, not 0)
---@type boolean|table
local mapTransportRelationships = false

local function registerMapTransportRelationships(callingFunctionName)
    if not authoritativeDefaultRules then
        error("The authoritativeDefaultRules (part of changeRules.lua) have not been registered with generalLibrary.lua.  "..callingFunctionName.." is therefore not available.")
    end
    local mTRs = {}
    for a=0,gen.c.maxMapID do
        mTRs[a] = {}
        for b=0,gen.c.maxMapID do
            mTRs[a][b] = false
        end
    end
    local list = authoritativeDefaultRules["map_transport_relationships"]
    for i=1,16 do
        local r = list[i]
        if r and r[1] and r[2] then
            mTRs[r[1]][r[2]] = mTRs[r[1]][r[2]] or {}
            mTRs[r[1]][r[2]][1+#mTRs[r[1]][r[2]]] = i
            mTRs[r[2]][r[1]] = mTRs[r[1]][r[2]] or {}
            mTRs[r[2]][r[1]][1+#mTRs[r[2]][r[1]]] = i
        end
    end
    return mTRs
end

---Finds the number of a map transporter relationship 
-- (or a table of all relationships, if `all` is true) which allows
-- transporter travel between `map1` and `map2`, with the first
-- relationship in @MAP_TRANSPORT_RELATIONSHIPS being represented
-- by 1.  If `map1` and `map2` are the same map, return `true`, even
-- if there is a relationship for that.  If there is no transport
-- relationship between the two maps, false is returned.
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param all? boolean # If true, return a table of all eligible relationship numbers (unless maps are the same, or there are none).
---@param functionName? string # If present, passes along a functionName to be displayed in case of error (particularly if changeRules.lua module is not found)
---@return boolean|integer|table
function gen.getMapTransportFlagNumber(map1,map2,all,functionName)
    functionName = functionName or "gen.getMapTransportFlagNumber"
    if civ.isMap(map1) then
        map1 = map1.id
    end
    if civ.isMap(map2) then
        map2 = map2.id
    end
    if map1 == map2 then
        return true
    end
    mapTransportRelationships = mapTransportRelationships
        or registerMapTransportRelationships(functionName)
    if all or type(mapTransportRelationships[map1][map2]) ~="table" then
        return mapTransportRelationships[map1][map2]
    else
        return mapTransportRelationships[map1][map2][1]
    end
end

---Returns true if the supplied bitmask indicates that transportation
-- can take place between `map1` and `map2` (or if they are the same map),
-- and false otherwise.
---@param map1 mapObject|integer
---@param map2 mapObject|integer
---@param transportBitmask bitmask
---@param functionName? string # Carries through the function name for the error if changeRules.lua is not available.
---@return boolean
function gen.isTransportBetweenMaps(map1,map2,transportBitmask,functionName)
    functionName = functionName or "gen.isTransportBetweenMaps"
    local mTFN = gen.getMapTransportFlagNumber(map1,map2,true,functionName)
    if type(mTFN) == "table" then
        for _,bitNumber in pairs(mTFN) do
            if isBit1(transportBitmask,bitNumber) then
                return true
            end
        end
        return false
    end
    ---@cast mTFN boolean -- at this point, it can't be a table
    return mTFN
end

---Returns true if `unitType` can natively teleport between `map1` and `map2`, and false otherwise.
--Always returns true if `map1` and `map2` are the same.
---@param unitType unitTypeObject
---@param map1 mapObject|integer
---@param map2 mapObject|integer
---@return boolean
function gen.isNativeTransportBetweenMaps(unitType,map1,map2)
    return gen.isTransportBetweenMaps(map1, map2, unitType.nativeTransport, "gen.isNativeTransportBetweenMaps")
end

---Returns true if `unitType` can build transporters between `map1` and `map2`, and false otherwise.
--Always returns true if `map1` and `map2` are the same.
---@param unitType unitTypeObject
---@param map1 mapObject|integer
---@param map2 mapObject|integer
---@return boolean
function gen.isBuildTransportBetweenMaps(unitType,map1,map2)
    return gen.isTransportBetweenMaps(map1, map2, unitType.buildTransport, "gen.isBuildTransportBetweenMaps")
end

---Returns true if `unitType` can build transporters between `map1` and `map2`, and false otherwise.
--Always returns true if `map1` and `map2` are the same.
---@param unitType unitTypeObject
---@param map1 mapObject|integer
---@param map2 mapObject|integer
---@return boolean
function gen.isUseTransportBetweenMaps(unitType,map1,map2)
    return gen.isTransportBetweenMaps(map1, map2, unitType.useTransport, "gen.isUseTransportBetweenMaps")
end

---Takes the `transportBitmask` for nativeTransport, buildTransport, useTransport,
--- and changes an appropriate bit to 1 so that transport exists
--- between the maps.  (If there are multiple map relationships
--- between `map1` and `map2`, there is no guarantee which one will
--- be enabled, and, in fact, one may be enabled even if another one
--- already grants the relationship.  If such details are important,
--- write a function manually.)
--- Returns the new bitmask.
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the original bitmask is returned.
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param transportBitmask bitmask
---@param suppressFailureError? boolean # set to true so that invalid map pairs do nothing instead of causing errors.
---@param functionName? string
---@return bitmask
function gen.giveTransportBetweenMaps(map1,map2,transportBitmask, suppressFailureError, functionName)
    functionName = functionName or "gen.giveTransportBetweenMaps"
    local mTFN = gen.getMapTransportFlagNumber(map1,map2,false,functionName)
    if type(mTFN) == "boolean" then
        if suppressFailureError then
            return transportBitmask
        end
        error(functionName..": The maps "..tostring(map1).." and "..tostring(map2).." are either the same map or have no transportation relationship between them.  You can disable this message and allow invalid map relationships to be ignored by setting argument #4 to true.")
    end
    return setBit1(transportBitmask,mTFN --[[@as integer]])
end

---Changes the `unitType`'s nativeTransport field so that the
--- unit can teleport between `map1` and `map2`.
--- (If there are multiple map relationships
--- between `map1` and `map2`, there is no guarantee which one will
--- be enabled, and, in fact, one may be enabled even if another one
--- already grants the relationship.  If such details are important,
--- write a function manually.)
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the nativeTransport field is unchanged.
---@param unitType unitTypeObject
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param suppressFailureError? boolean # if true, invalid map combinations do nothing instead of causing an error.
function gen.giveNativeTransportBetweenMaps(unitType,map1,map2,suppressFailureError)
    unitType.nativeTransport = gen.giveTransportBetweenMaps(map1,map2,
    unitType.nativeTransport,suppressFailureError,"gen.giveNativeTransportBetweenMaps")
end


---Changes the `unitType`'s buildTransport field so that the
--- unit can build teleporters between `map1` and `map2`.
--- (If there are multiple map relationships
--- between `map1` and `map2`, there is no guarantee which one will
--- be enabled, and, in fact, one may be enabled even if another one
--- already grants the relationship.  If such details are important,
--- write a function manually.)
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the buildTransport field is unchanged.
---@param unitType unitTypeObject
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param suppressFailureError? boolean # if true, invalid map combinations do nothing instead of causing an error.
function gen.giveBuildTransportBetweenMaps(unitType,map1,map2,suppressFailureError)
    unitType.buildTransport = gen.giveTransportBetweenMaps(map1,map2,
    unitType.buildTransport,suppressFailureError,"gen.giveBuildTransportBetweenMaps")
end

---Changes the `unitType`'s useTransport field so that the
--- unit can use teleporters between `map1` and `map2`.
--- (If there are multiple map relationships
--- between `map1` and `map2`, there is no guarantee which one will
--- be enabled, and, in fact, one may be enabled even if another one
--- already grants the relationship.  If such details are important,
--- write a function manually.)
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the useTransport field is unchanged.
---@param unitType unitTypeObject
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param suppressFailureError? boolean # if true, invalid map combinations do nothing instead of causing an error.
function gen.giveUseTransportBetweenMaps(unitType,map1,map2,suppressFailureError)
    unitType.useTransport = gen.giveTransportBetweenMaps(map1,map2,
    unitType.useTransport,suppressFailureError,"gen.giveUseTransportBetweenMaps")
end

---Takes the `transportBitmask` for nativeTransport, buildTransport, useTransport,
--- and changes all appropriate bit to 0 so that transport no longer exists
--- between the maps.  
--- Returns the new bitmask.
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the original bitmask is returned.
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param transportBitmask bitmask
---@param suppressFailureError? boolean # set to true so that invalid map pairs do nothing instead of causing errors.
---@param functionName? string
---@return bitmask
function gen.removeTransportBetweenMaps(map1,map2,transportBitmask, suppressFailureError, functionName)
    functionName = functionName or "gen.removeTransportBetweenMaps"
    local mTFN = gen.getMapTransportFlagNumber(map1,map2,true,functionName)
    if type(mTFN) == "boolean" then
        if suppressFailureError then
            return transportBitmask
        end
        error(functionName..": The maps "..tostring(map1).." and "..tostring(map2).." are either the same map or have no transportation relationship between them.  You can disable this message and allow invalid map relationships to be ignored by setting argument #4 to true.")
    end
    local returnBitmask = transportBitmask
    for _,bit in pairs(mTFN --[[@as table]]) do
        returnBitmask = setBit0(returnBitmask,bit)
    end
    return returnBitmask
end

---Changes the `unitType`'s nativeTransport field so that the
--- unit can't teleport between `map1` and `map2`.
--- (If there are multiple map relationships
--- between `map1` and `map2`, all will be removed.)
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the nativeTransport field is unchanged.
---@param unitType unitTypeObject
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param suppressFailureError? boolean # if true, invalid map combinations do nothing instead of causing an error.
function gen.removeNativeTransportBetweenMaps(unitType,map1,map2,suppressFailureError)
    unitType.nativeTransport = gen.removeTransportBetweenMaps(map1,map2,
    unitType.nativeTransport,suppressFailureError,"gen.removeNativeTransportBetweenMaps")
end


---Changes the `unitType`'s buildTransport field so that the
--- unit can't build teleporters between `map1` and `map2`.
--- (If there are multiple map relationships
--- between `map1` and `map2`, all will be set to 0.)
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the buildTransport field is unchanged.
---@param unitType unitTypeObject
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param suppressFailureError? boolean # if true, invalid map combinations do nothing instead of causing an error.
function gen.removeBuildTransportBetweenMaps(unitType,map1,map2,suppressFailureError)
    unitType.buildTransport = gen.removeTransportBetweenMaps(map1,map2,
    unitType.buildTransport,suppressFailureError,"gen.removeBuildTransportBetweenMaps")
end

---Changes the `unitType`'s useTransport field so that the
--- unit can't use teleporters between `map1` and `map2`.
--- (If there are multiple map relationships
--- between `map1` and `map2`, all will be set to 0)
--- If the maps are the same, or there is no possible transportation
--- between them, an error is thrown, unless `suppressFailureError`
--- is `true`, in which case the useTransport field is unchanged.
---@param unitType unitTypeObject
---@param map1 integer|mapObject
---@param map2 integer|mapObject
---@param suppressFailureError? boolean # if true, invalid map combinations do nothing instead of causing an error.
function gen.removeUseTransportBetweenMaps(unitType,map1,map2,suppressFailureError)
    unitType.useTransport = gen.removeTransportBetweenMaps(map1,map2,
    unitType.useTransport,suppressFailureError,"gen.removeUseTransportBetweenMaps")
end



-- gen.isAllowedOnMap(unitType,map) --> boolean

---Returns true if the `unitType` is allowed on `map`, and false otherwise.
---@param unitType unitTypeObject
---@param map integer|mapObject
---@return boolean
function gen.isAllowedOnMap(unitType,map)
    if civ.isMap(map) then
        map = map.id
    end
    return isBit0(unitType.notAllowedOnMap,map+1)
end

-- gen.giveAllowedOnMap(unitType,map) --> void


---Allows the `unitType` to be on `map`
---@param unitType unitTypeObject
---@param map integer|mapObject
function gen.giveAllowedOnMap(unitType,map)
    if civ.isMap(map) then
        map = map.id
    end
    unitType.notAllowedOnMap = setBit0(unitType.notAllowedOnMap,map+1)
end


-- gen.removeAllowedOnMap(unitType,map) --> void

---Forbids the `unitType` to be on `map`
---@param unitType unitTypeObject
---@param map integer|mapObject
function gen.removeAllowedOnMap(unitType,map)
    if civ.isMap(map) then
        map = map.id
    end
    unitType.notAllowedOnMap = setBit1(unitType.notAllowedOnMap,map+1)
end


-- Takes a table of items, and an iterator or table of all possible
-- items, and returns a list of all items that are not values
-- in the table.  If the iterator is a table, only the
-- values in the table are considered.
-- These functions might be useful:
-- `gen.iterateUnitTypes()`
-- `gen.iterateImprovements()`
-- `gen.iterateWonders()`
-- `gen.iterateBaseTerrain()`
-- `gen.iterateTerrain()`
---@param list table<any,any>
---@param itemIterator iterator|table<any,any>
---@return table<integer,any>
function gen.complementList(list,itemIterator)
    local complement = {}
    local index = 1
    local function isItemInList(item)
        for _,listItem in pairs(list) do
            if listItem == item then
                return true
            end
        end
        return false
    end
    if type(itemIterator) == "table" then
        for _,item in pairs(itemIterator) do
            if not isItemInList(item) then
                complement[index] = item
                index = index + 1
            end
        end
    else
        for item in itemIterator do
            if not isItemInList(item) then
                complement[index] = item
                index = index + 1
            end
        end
    end
    return complement
end

--[[
Returns an array of all the keys in the table with number values,
in descending order, starting with the largest value at index 1.

If there are multiple keys with the same value, the order of those
keys is not guaranteed.

Keys with non-number values are ignored.  If no key has a number value,
an empty table is returned.
]]
---@param table table
---@return table<integer,any>
function gen.sortTableKeysInDescendingValueOrder(table)
    local keys = {}
    local index = 1
    for key,value in pairs(table) do
        if type(value) == "number" then
            keys[index] = key
            index = index + 1
        end
    end
    _G.table.sort(keys,function(a,b)
        return table[a] > table[b]
    end)
    return keys
end

--[[
Returns an array of all the keys in the table with number values,
in increasing order, starting with the smallest value at index 1.

If there are multiple keys with the same value, the order of those
keys is not guaranteed.

Keys with non-number values are ignored.  If no key has a number value,
an empty table is returned.
]]
---@param table table
---@return table<integer,any>
function gen.sortTableKeysInAscendingValueOrder(table)
    local keys = {}
    local index = 1
    for key,value in pairs(table) do
        if type(value) == "number" then
            keys[index] = key
            index = index + 1
        end
    end
    table.sort(keys,function(a,b)
        return table[a] < table[b]
    end)
    return keys
end

local changeUnitValidationInfo = function(unit) end

--Registers a function that updates the validation information
--for a unit, to be called when a unit's owner is changed.
--(This is called in unitData.lua, and will probably not be used
--directly by a scenario creator.)
---@param changeValidationInfo fun(unit:unitObject)
function gen.registerUpdateUnitValidationInfo(changeValidationInfo)
    changeUnitValidationInfo = changeValidationInfo
end

local changeCityValidationInfo = function(city) end

--Registers a function that updates the validation information
--for a city, to be called when a city's owner is changed.
--(This is called in cityData.lua, and will probably not be used
--directly by a scenario creator.)
---@param changeValidationInfo fun(city:cityObject)
function gen.registerUpdateCityValidationInfo(changeValidationInfo)
    changeCityValidationInfo = changeValidationInfo
end




--[[
Changes the owner of the city and or units on the tile
to newOwner from the current owner.
]]
---@param tile tileObject
---@param newOwner tribeObject
function gen.transferTileContents(tile,newOwner)
    if tile.city then
        local originalOwner = tile.city.owner
        tile.city.owner = newOwner
        changeCityValidationInfo(tile.city)
        for unit in civ.iterateUnits() do
            if unit.owner == originalOwner and unit.homeCity == tile.city and unit.location ~= tile then
                print(tostring(unit))
                gen.homeToNearestCity(unit)   
            end
        end
    end
    for unit in tile.units do
        unit.owner = newOwner
        gen.homeToNearestCity(unit)
        changeUnitValidationInfo(unit)
    end
    tile.owner = newOwner
end


if rawget(_G,"console") then
    _G["console"].gen = gen
end

return gen

--#gen.isCivilDisorder(city)-->boolean
--#gen.setCivilDisorder(city)-->void
--#gen.clearCivilDisorder(city)-->void
--#gen.isWeLoveTheKing(city)-->boolean
--#gen.setWeLoveTheKing(city)-->void
--#gen.clearWeLoveTheKing(city)-->void
--#gen.isImprovementSold(city)-->boolean
--#gen.setImprovementSold(city)-->void
--#gen.clearImprovementSold(city)-->void
--#gen.isTechnologyStolen(city)-->boolean
--#gen.setTechnologyStolen(city)-->void
--#gen.clearTechnologyStolen(city)-->void
--#gen.isAutoBuild(city)-->boolean
--#gen.setAutoBuild(city)-->void
--#gen.clearAutoBuild(city)-->void
--#gen.isAttribute6(city)-->boolean
--#gen.setAttribute6(city)-->void
--#gen.clearAttribute6(city)-->void
--#gen.isAttribute7(city)-->boolean
--#gen.setAttribute7(city)-->void
--#gen.clearAttribute7(city)-->void
--#gen.isBuildCoastal(city)-->boolean
--#gen.setBuildCoastal(city)-->void
--#gen.clearBuildCoastal(city)-->void
--#gen.isAttribute9(city)-->boolean
--#gen.setAttribute9(city)-->void
--#gen.clearAttribute9(city)-->void
--#gen.isAttribute10(city)-->boolean
--#gen.setAttribute10(city)-->void
--#gen.clearAttribute10(city)-->void
--#gen.isAttribute11(city)-->boolean
--#gen.setAttribute11(city)-->void
--#gen.clearAttribute11(city)-->void
--#gen.isBuildHydroPlant(city)-->boolean
--#gen.setBuildHydroPlant(city)-->void
--#gen.clearBuildHydroPlant(city)-->void
--#gen.isAttribute13(city)-->boolean
--#gen.setAttribute13(city)-->void
--#gen.clearAttribute13(city)-->void
--#gen.isAttribute14(city)-->boolean
--#gen.setAttribute14(city)-->void
--#gen.clearAttribute14(city)-->void
--#gen.isAttribute15(city)-->boolean
--#gen.setAttribute15(city)-->void
--#gen.clearAttribute15(city)-->void
--#gen.isAttribute16(city)-->boolean
--#gen.setAttribute16(city)-->void
--#gen.clearAttribute16(city)-->void
--#gen.isUsedAirport(city)-->boolean
--#gen.setUsedAirport(city)-->void
--#gen.clearUsedAirport(city)-->void
--#gen.isAttribute18(city)-->boolean
--#gen.setAttribute18(city)-->void
--#gen.clearAttribute18(city)-->void
--#gen.isAttribute19(city)-->boolean
--#gen.setAttribute19(city)-->void
--#gen.clearAttribute19(city)-->void
--#gen.isAttribute20(city)-->boolean
--#gen.setAttribute20(city)-->void
--#gen.clearAttribute20(city)-->void
--#gen.isAttribute21(city)-->boolean
--#gen.setAttribute21(city)-->void
--#gen.clearAttribute21(city)-->void
--#gen.isBuildShips(city)-->boolean
--#gen.setBuildShips(city)-->void
--#gen.clearBuildShips(city)-->void
--#gen.isCityInvestigated(city)-->boolean
--#gen.setCityInvestigated(city)-->void
--#gen.clearCityInvestigated(city)-->void
--#gen.isAttribute24(city)-->boolean
--#gen.setAttribute24(city)-->void
--#gen.clearAttribute24(city)-->void
--#gen.isMilitaryAutoBuild(city)-->boolean
--#gen.setMilitaryAutoBuild(city)-->void
--#gen.clearMilitaryAutoBuild(city)-->void
--#gen.isDomesticAutoBuild(city)-->boolean
--#gen.setDomesticAutoBuild(city)-->void
--#gen.clearDomesticAutoBuild(city)-->void
--#gen.isObjective(city)-->boolean
--#gen.setObjective(city)-->void
--#gen.clearObjective(city)-->void
--#gen.isAttribute28(city)-->boolean
--#gen.setAttribute28(city)-->void
--#gen.clearAttribute28(city)-->void
--#gen.isMajorObjective(city)-->boolean
--#gen.setMajorObjective(city)-->void
--#gen.clearMajorObjective(city)-->void
--#gen.isUsedTransporter(city)-->boolean
--#gen.setUsedTransporter(city)-->void
--#gen.clearUsedTransporter(city)-->void
--#gen.isAttribute31(city)-->boolean
--#gen.setAttribute31(city)-->void
--#gen.clearAttribute31(city)-->void
--#gen.isAttribute32(city)-->boolean
--#gen.setAttribute32(city)-->void
--#gen.clearAttribute32(city)-->void



--#gen.toTile(tile or table)-->tile
--gen.hasIrrigation(tile)-->boolean
--gen.placeIrrigation(tile)-->void
--gen.removeIrrigation(tile)-->void
--#gen.hasMine(tile)-->boolean
--#gen.placeMine(tile)-->void
--#gen.placeMineUnderCity(tile)-->void
--#gen.removeMine(tile)-->void
--#gen.removeMineUnderCity(tile)-->void
--#gen.hasFarmland(tile)-->boolean
--#gen.placeFarmland(tile)-->void
--#gen.removeFarmland(tile)-->void
--#gen.hasAgriculture(tile)--> boolean
--#gen.improveAgriculture(tile) --> void
--#gen.degradeAgriculture(tile) --> void
--#gen.removeAgriculture(tile)--> void
--#gen.hasRoad(tile)-->boolean
--#gen.placeRoad(tile)-->void
--#gen.removeRoad(tile)-->void
--#gen.hasRailroad(tile)-->boolean
--#gen.placeRailroad(tile)-->void
--#gen.removeRailroad(tile)-->void
--#gen.hasTransportation(tile) --> boolean
--#gen.upgradeTransportation(tile) --> void
--#gen.degradeTransportation(tile) --> void
--#gen.removeTransportation(tile) -->void
--#gen.hasFortress(tile)-->boolean
--#gen.placeFortress(tile)-->void
--#gen.placeFortressForce(tile)-->void
--#gen.removeFortress(tile)-->void
--#gen.hasAirbase(tile)-->boolean
--#gen.placeAirbase(tile)-->void
--#gen.placeAirbaseForce(tile)-->void
--#gen.removeAirbase(tile)-->void
--#gen.hasPollution(tile)-->boolean
--#gen.placePollution(tile)-->void
--#gen.removePollution(tile)-->void
--#gen.hasTransporter(tile)-->boolean
--# NOTE: Can't placeTransporter
--#gen.removeTransporter(tile)-->void



--#gen.isFortifying(unit)-->boolean
--#gen.setToFortifying(unit)-->void
--#gen.isFortified(unit)-->boolean
--#gen.setToFortified(unit)-->void
--#gen.isSleeping(unit)-->boolean
--#gen.setToSleeping(unit)-->void
--#gen.isBuildingFortress(unit) --> boolean
--#gen.setToBuildingFortress(unit)-->void
--#gen.isBuildingRoad(unit) --> boolean
--#gen.setToBuildingRoad(unit)-->void
--#gen.isIrrigating(unit)-->boolean
--#gen.setToIrrigating(unit)-->void
--#gen.isMining(unit)-->boolean
--#gen.setToMining(unit)-->void
--#gen.isTransformingTerrain(unit)-->boolean
--#gen.setToTransformingTerrain(unit)-->void
--#gen.isBuildingAirbase(unit)-->boolean
--#gen.setToBuildingAirbase(unit)-->void
--#gen.isBuildingTransporter(unit)-->boolean
--#gen.setToBuildingTransporter(unit)-->void
--#gen.isGoingTo(unit)-->boolean
--#gen.setToGoingTo(unit,tile)-->void
--#gen.isNoOrder(unit)-->boolean
--#gen.setToNoOrders(unit)-->void
--#gen.isWaiting(unit)-->bool
--#gen.setToWaiting(unit)-->void
--#gen.clearWaiting(unit)-->void
--#gen.isParadropped(unit)-->void
--#gen.setParadropped(unit)-->void
--#gen.clearParadropped(unit)-->void
--#gen.isMoved(unit)-->boolean
--#gen.setMoved(unit)-->void
--#gen.clearMoved(unit)-->void

--#gen.isSeeTwoSpaces(unitType)-->boolean
--#gen.giveSeeTwoSpaces(unitType)-->void
--#gen.removeSeeTwoSpaces(unitType)-->void
--#gen.isIgnoreZOC(unitType)-->boolean
--#gen.giveIgnoreZOC(unitType)-->void
--#gen.removeIgnoreZOC(unitType)-->void
--#gen.isAmphibious(unitType)-->boolean
--#gen.giveAmphibious(unitType)-->void
--#gen.removeAmphibious(unitType)-->void
--#gen.isSubmarine(unitType)-->boolean
--#gen.giveSubmarine(unitType)-->void
--#gen.removeSubmarine(unitType)-->void
--#gen.isAttackAir(unitType)-->boolean
--#gen.giveAttackAir(unitType)-->void
--#gen.removeAttackAir(unitType)-->void
--#gen.isCoastal(unitType)-->boolean
--#gen.giveCoastal(unitType)-->void
--#gen.removeCoastal(unitType)-->void
--#gen.isIgnoreWalls(unitType)-->boolean
--#gen.giveIgnoreWalls(unitType)-->void
--#gen.removeIgnoreWalls(unitType)-->void
--#gen.isCarryAir(unitType)-->boolean
--#gen.giveCarryAir(unitType)-->void
--#gen.removeCarryAir(unitType)-->void
--#gen.isParadrop(unitType)-->boolean
--#gen.giveParadrop(unitType)-->void
--#gen.removeParadrop(unitType)-->void
--#gen.isAlpine(unitType)-->boolean
--#gen.giveAlpine(unitType)-->void
--#gen.removeAlpine(unitType)-->void
--#gen.isBonusAgainstHorse(unitType)-->boolean
--#gen.giveBonusAgainstHorse(unitType)-->void
--#gen.removeBonusAgainstHorse(unitType)-->void
--#gen.isFreeSupportUnderFundamentalism(unitType)-->boolean
--#gen.giveFreeSupportUnderFundamentalism(unitType)-->void
--#gen.removeFreeSupportUnderFundamentalism(unitType)-->void
--#gen.isDestroyedAfterAttacking(unitType)-->boolean
--#gen.giveDestroyedAfterAttacking(unitType)-->void
--#gen.removeDestroyedAfterAttacking(unitType)-->void
--#gen.isBonusAgainstAir(unitType)-->boolean
--#gen.giveBonusAgainstAir(unitType)-->void
--#gen.removeBonusAgainstAir(unitType)-->void
--#gen.isSpotSubmarines(unitType)-->boolean
--#gen.giveSpotSubmarines(unitType)-->void
--#gen.removeSpotSubmarines(unitType)-->void
-- gen.isInvisibleUntilAttack(unitType) --> bool
-- gen.giveInvisibleUntilAttack(unitType) --> void
-- gen.removeInvisibleUntilAttack(unitType) --> void
-- gen.isNonDisbandable(unitType) --> bool
-- gen.giveNonDisbandable(unitType) --> void
-- gen.removeNonDisbandable(unitType) --> void
-- gen.isZeroRangeAirUnitDamageOverride(unitType) --> bool
-- gen.giveZeroRangeAirUnitDamageOverride(unitType) --> void
-- gen.removeZeroRangeAirUnitDamageOverride(unitType) --> void
-- gen.isCannotBuyOffBarbarian(unitType) --> bool
-- gen.giveCannotBuyOffBarbarian(unitType) --> void
-- gen.removeCannotBuyOffBarbarian(unitType) --> void
-- gen.isCanCrossImpassableTerrain(unitType) --> bool
-- gen.giveCanCrossImpassableTerrain(unitType) --> void
-- gen.removeCanCrossImpassableTerrain(unitType) --> void
-- gen.isBarbarianWillNotExpire(unitType) --> bool
-- gen.giveBarbarianWillNotExpire(unitType) --> void
-- gen.removeBarbarianWillNotExpire(unitType) --> void
-- gen.isOverrideSPR(unitType) --> bool
-- gen.giveOverrideSPR(unitType) --> void
-- gen.removeOverrideSPR(unitType) --> void
-- gen.isReducePopulationWhenBuilt(unitType) --> bool
-- gen.giveReducePopulationWhenBuilt(unitType) --> void
-- gen.removeReducePopulationWhenBuilt(unitType) --> void
-- gen.isRequiresFoodSupport(unitType) --> bool
-- gen.giveRequiresFoodSupport(unitType) --> void
-- gen.removeRequiresFoodSupport(unitType) --> void
-- gen.isCanFoundCities(unitType) --> bool
-- gen.giveCanFoundCities(unitType) --> void
-- gen.removeCanFoundCities(unitType) --> void
-- gen.isCanImproveTiles(unitType)--> bool
-- gen.giveCanImproveTiles(unitType,ignoreError=false) --> void
-- gen.removeCanImproveTiles(unitType,ignoreError=false) --> void
-- gen.isAllowedOnMap(unitType,map) --> boolean
-- gen.giveAllowedOnMap(unitType,map) --> void
-- gen.removeAllowedOnMap(unitType,map) --> void
-- gen.isNativeTransportBetweenMaps(unitType, map1, map2) --> boolean
-- gen.giveNativeTransportBetweenMaps(unitType, map1, map2, suppressFailureError?) --> void
-- gen.removeNativeTransportBetweenMaps(unitType, map1, map2, suppressFailureError?) --> void
-- gen.isBuildTransportBetweenMaps(unitType, map1, map2) --> boolean
-- gen.giveBuildTransportBetweenMaps(unitType, map1, map2, suppressFailureError?) --> void
-- gen.removeBuildTransportBetweenMaps(unitType, map1, map2, suppressFailureError?) --> void
-- gen.isUseTransportBetweenMaps(unitType, map1, map2) --> boolean
-- gen.giveUseTransportBetweenMaps(unitType, map1, map2, suppressFailureError?) --> void
-- gen.removeUseTransportBetweenMaps(unitType, map1, map2, suppressFailureError?) --> void


-- gen.isTileRevealed(tile,tribe) -> boolean
-- gen.revealTile(tile,tribe) -> void
-- gen.coverTile(tile,tribe) -> void
-- gen.isCityCharted(city,tribe) --> bool
-- gen.chartCity(city,tribe,visibleSize=nil) --> void
-- gen.unchartCity(city,tribe) --> void
-- gen.isIrrigationCharted(tile,tribe) --> bool
-- gen.chartIrrigation(tile,tribe) --> void
-- gen.unchartIrrigation(tile,tribe) --> void
-- gen.isMineCharted(tile,tribe) --> bool
-- gen.chartMine(tile,tribe) --> void
-- gen.unchartMine(tile,tribe) --> void
-- gen.isFarmlandCharted(tile,tribe) --> bool
-- gen.chartFarmland(tile,tribe) --> void
-- gen.unchartFarmland(tile,tribe) --> void
-- gen.isRoadCharted(tile,tribe) --> bool
-- gen.chartRoad(tile,tribe) --> void
-- gen.unchartRoad(tile,tribe) --> void
-- gen.isRailroadCharted(tile,tribe) --> bool
-- gen.chartRailroad(tile,tribe) --> void
-- gen.unchartRailroad(tile,tribe) --> void
-- gen.unchartTransportation(tile,tribe) --> void
-- gen.isFortressCharted(tile,tribe) --> bool
-- gen.chartFortress(tile,tribe) --> void
-- gen.unchartFortress(tile,tribe) --> void
-- gen.isAirbaseCharted(tile,tribe) --> bool
-- gen.chartAirbase(tile,tribe) --> void
-- gen.unchartAirbase(tile,tribe) --> void
-- gen.isPollutionCharted(tile,tribe) --> bool
-- gen.chartPollution(tile,tribe) --> void
-- gen.unchartPollution(tile,tribe) --> void
-- gen.isTransporterCharted(tile,tribe) --> bool
-- gen.chartTransporter(tile,tribe) --> void
-- gen.unchartTransporter(tile,tribe) --> void
-- gen.chartTruthfully(tile,tribe) --> void


-- gen.placeMarker(tile,tribe,markerOption)
-- gen.removeMarker(tile,tribe,markerOption) --> void
-- gen.maintainTileMarkerTable() --> void
-- gen.removeAllMarkers(tribeOrNil,markerTypeOrNil) --> void
-- gen.showAllMarkersOnTile(tile,topMarkerTypeOrNil,secondMarkerTypeOrNil) --> void
-- gen.showAllMarkers(topMarkerTypeOrNil) --> void
-- gen.hasMarker(tile,tribe,markerType)
-- gen.isMarkerVisible(tile,tribe,markerType)
-- gen.hideMarker(tile,tribe,markerType)
-- gen.hideAllMarkers(tribeOrNil,markerTypeOrNil)
-- gen.showMarker(tile,tribe,markerType)
-- gen.showMarkerOnAllTiles(tribe,markerType)

--gen.checkBits(integer,string)-->boolean
--gen.setBits(integer,string)-->integer
--gen.printBits(integer,numOfBits or nil) --> string
--gen.isBit1(integer,bitNumber)--> boolean
--gen.isBit0(integer,bitNumber)--> boolean
--gen.setBit1(integer,bitNumber)-->integer
--gen.setBit0(integer,bitNumber)-->integer
-- gen.isTransportBetweenMaps(map1, map2, transportBitmask, functionName?) --> boolean
-- gen.giveTransportBetweenMaps(map1, map2, transportBitmask, suppressFailureError?, functionName?) --> bitmask
-- gen.removeTransportBetweenMaps(map1, map2, transportBitmask, suppressFailureError?, functionName?) --> bitmask

--#gen.inTable(object,table)--> bool
--#gen.copyTable(table)-->table
-- gen.copyTableWithMetatable(table) --> table
--#gen.isEmpty(table)-->bool
-- gen.mergeTableValues(table,table,...) --> table
--#gen.clearGapsInArray(table,lowestValue=1)
--#gen.tableWrap(item)-->table
--#gen.tableWrap(item,needsWrapFn)-->table
--#gen.errorForNilKey(table,tableName)-->void
--#gen.noNewKey(table,tableName)-->void
-- gen.isStateSavable(item) --> boolean
-- gen.tableToString(table) --> string
-- gen.makeDataTable(inputTable={},tableName="unnamed data table") --> dataTable
-- gen.forbidReplacement(dataTable) --> void
-- gen.allowReplacement(dataTable) --> void
-- gen.forbidNewKeys(dataTable) --> void
-- gen.allowNewKeys(dataTable) --> void
-- gen.forbidNilValueAccess(dataTable) --> void
-- gen.allowNilValueAccess(dataTable) --> void
--gen.makeThresholdTable(table or nil)-->thresholdTable
-- gen.persistentRandom(key) --> number between 0 and 1
-- gen.clearPersistentRandom(key) --> void
-- gen.getPersistentRandomTable() --> table
-- gen.newEmptyStack() --> stack
-- gen.newStack(table = {}) --> stack
-- gen.isStack(item) --> boolean

-- gen.getBaseTerrainID(baseTerrain) --> integer
-- gen.getBaseTerrainFromID(id) --> baseTerrain
-- gen.getTerrainID(terrain) --> integer
-- gen.getTerrainFromID(id) --> terrain
--#gen.getTileID(tileObject or int,int or nil,int or nil)-->int (by Knighttime, converts a tile/coordinates to a single integer as an ID number)
--#gen.getTileId(tileObject or int,int or nil,int or nil)-->int (by Knighttime, converts a tile/coordinates to a single integer as an ID number)
-- gen.getTileFromID(tileID) --> tileObject -- undoes gen.getTileID
-- gen.getTileFromId(tileID) --> tileObject -- undoes gen.getTileID


--#gen.rehomeUnitsInCapturedCity(city,defender) --> void
--#gen.linkActivationFunction(function(unit,source)-->void)-->void
--#gen.getActivationFunction()-->function(unit,source)
--#gen.noGlobal()
--#gen.linkState(stateTable)
--#gen.linkGeneralLibraryState(stateTable) --> void
--#gen.setDeathFunctions(defeatFunction,deathFunction,deletionFunction) --> void
-- gen.setScenarioDirectory(directoryPath) --> void
-- gen.getScenarioDirectory() --> string
-- gen.setOutOfRangeMessage(textOrFunction,title=nil) --> void
-- gen.outOfRangeMessage(unit) --> void
-- gen.activateRangeForLandAndSea(restoreRangeFn=nil,applyToAI=false)
-- gen.versionFunctions(moduleTable,versionNumber,fileMod,moduleFileName) -->void
-- gen.registerEventsLuaVersion(versionNumber,fileMod,regressionNumber)
--#gen.setMusicDirectory(path)

-- gen.calculateWeight(item,weightTable,extraArgument=nil) --> number or false
-- gen.getExtremeWeights(listOrIterator,weightTableOrWeightFunction,getTopX,changeOrder,functionName,extraArgument)
-- gen.getBiggestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil
-- gen.getSmallestWeights(listOrIterator,weightTableOrWeightFunction,getTopX=nil,extraArgument=nil) --> item or tableOfItems or nil, weight or tableOfWeights or nil

--  gen.describeAllowableData(validDataInfo) --> string
-- gen.validateFunctionArgument(data,moduleName,functionName,argumentNumber, argumentName,validDataInfo,extraInfo=nil) --> void or error
-- gen.createDataType(dataName,specificKeyTable,generalKeyTable,defaultValueTable,fixedKeyTable) --> newItemFunction, isDataTypeFunction
-- gen.valueSpecForCustomData(isItemFn, failureDescription, itemDescription) --> valueSpecification


--#gen.createUnit(unitType,tribe,locations,options) --> table of units
--#gen.copyUnitAttributes(parent,child)-->void
--#gen.defeatUnit(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)-->unit or nil
--#gen.killUnit(dyingUnit)-->void
--#gen.deleteUnit(deletedUnit,replacementUnit=nil)-->void
--#gen.replaceUnit(oldUnit,replacementType)--> unit
--#gen.limitedExecutions(key,maxTimes,limitedFunction)--> void
-- gen.justOnce(key,limitedFunction)-->void
--gen.isWonderActiveForTribe(wonderObject or integer,tribeObject or integer)-->boolean
--#gen.tileDist(locA,locB,zDist=0)-->integer
--#gen.distance(tileUnitCityA,tileUnitCityB,zDist=0)-->integer
--#gen.wonderModifiedMoves(unit)-->integer
--#gen.maxMoves(unit) --> integer
--#gen.moveRemaining(unit) --> integer
--#gen.inPolygon(tile,tableOfCoordinates)-->bool
--  gen.getRandomTileInPolygon(polygonTableOfCoordinates,map=0,maxAttempts=100) -> tile (inspired by Pablostuka)
--#gen.cityCanSupportAnotherUnit(city)-->bool
--#gen.homeToNearestCity(unit)-->void
--#gen.unitTypeOnTile(tile,unitTypeOrTableOfUnitType)-->bool
--#gen.getAdjacentTiles(tile)-->tableOfTiles
--#gen.moveUnitAdjacent(unit,destRankFn=suitableDefault)-->tile or bool
--#gen.unprotectTile(tile,isProtectingUnit,isProtectedUnit,isProtectedTile,destRankFn=suitableDefault)-->void
--#gen.clearAirProtection(tile)-->void
--#gen.clearAdjacentAirProtection(unit) -->void clears air protection for tiles adjacent to the unit that are not owned by the unit's owner
--#gen.cityRadiusTiles(cityOrTileOrCoordTable) --> table
--#gen.getTilesInRadius(centre,radius,minRadius=0,maps=nil) --> table
--#gen.playMusic(fileName)
--#gen.isSinglePlayerGame() --> boolean
--#gen.nearbyUnits(center,radius,maps={0,1,2,3}) --> iterator providing units
--#gen.makeAllowedTerrainFunction(allowedTilesTable) --> function(tile)-->bool
--#gen.nearbyUnoccupiedTiles(tile,distance,allowedTiles) --> table
--#gen.getRandomNearbyUnoccupiedTile(tile,distance,allowedTiles) --> tile
--#gen.nearbyOpenTilesForTribe(centerTile,distance,allowedTiles,tribe)
--#gen.getRandomNearbyOpenTileForTribe(tile,distance,allowedTiles,tribe) --> tile
-- gen.getTileProduction(tile,city) --> integer (food), integer(shields), integer(trade)
-- gen.computeBaseProduction(city)-->integer(food), integer(shields), integer(trade)
-- gen.spendMovementPoints(unit,points,multiplier=totpp.movementMultipliers.aggregate,maxSpent=255,minSpent=0) -> void
-- gen.getBearing(compassPoint,compassCentre) --> string | Inspired by Pablostuka
-- gen.isInteger(item) --> boolean
-- gen.getMapTransportFlagNumber(map1, map2, all?, functionName?) --> boolean|integer|table
-- gen.getNumberOfTerrainTypes(map) --> integer
--#gen.getState()-->table
--#gen.getEphemeralTable()-->table
-- gen.iterateUnitTypes() --> iterator
-- gen.iterateImprovements() --> iterator
-- gen.iterateWonders() --> iterator
-- gen.iterateBaseTerrain() --> iterator
-- gen.iterateTerrain() --> iterator
-- gen.isRoadTradeBonus(baseTerrain) --> boolean
-- gen.giveRoadTradeBonus(baseTerrain) -->boolean
-- gen.removeRoadTradeBonus(baseTerrain) --> boolean

--#gen.isMapFlat()-->boolean
--#gen.isMapRound()-->boolean
--#gen.declareMapFlat()-->void
--#gen.declareMapRound()-->void
--#gen.setTerrainType(tile,terrain)-->void
--#gen.activate(unit)-->void
--#gen.activateWithSource(unit,source)-->void

