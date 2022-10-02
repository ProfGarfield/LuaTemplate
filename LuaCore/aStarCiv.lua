
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

local gen = require("generalLibrary"):minVersion(1)

local getTileId = gen.getTileId
local getTileFromId = gen.getTileFromId

local aStarCiv = {}
gen.versionFunctions(aStarCiv,versionNumber,fileModified,"LuaCore".."\\".."aStarCiv.lua")
-- start is a tile object or table of such objects (if multiple places can act as the 'start')
-- goal is a tile object or table of such objects (if any one of them is a valid goal)
-- heuristic(startTile,endTileOrTable) --> number
--      an estimate of the cost from startTile to endTile
--      if the goal is specified as a table of tiles, heuristic should be able to
--      accommodate that and accept a table of tiles as an argument
--      does NOT have to accommodate a table for startTile, even if multiple
--      starting locations are valid
--  neighbours(tile,start,goal)--> table of {neighbouringTile,cost from tile to neighbouring tile}
--      returns the neighbouring tiles of a tile, and the cost to get to them
--      start and goal are included parameters (in case, for example, you want to limit how far away the path can take
--  pathCost(orderedTableOfTiles)-->number
--  stopLookingHeuristicCost
--      If the best estimated cost (fScore) exceeds this cost, stop looking and return false
--      default is math.huge (explore all possibilities)
function aStarCiv.aStar(start,goal,heuristic,neighbours,pathCost,stopLookingHeuristicCost) --> cost,pathTable
    stopLookingHeuristicCost = stopLookingHeuristicCost or math.huge
    --_G.tilesExamined = 0
    local goalIDTable = {}
    if civ.isTile(goal) then
        goalIDTable[getTileId(goal)]=true
    else
        for __,goalTile in pairs(goal) do
            goalIDTable[getTileId(goalTile)]=true
        end
    end
    local gScoreTable = {} --gScoreTable[tileID] is cost of best known path from start to the tile with that ID
    local fScoreTable = {} --fScoreTable[tileID] is current best guess of cost of path from start to goal that goes through tile with that ID
    -- the openSet is the set of discovered nodes that many need to be (re-)expanded
    -- Will use openSetAdd(tile) and openSetGetBestTileID() so that this can be updated
    local openSet = {}
    local function openSetAdd(tile)
        openSet[getTileId(tile)]=true
    end
    local function openSetRemove(tile)
        openSet[getTileId(tile)] = nil
    end
    local function openSetRemoveID(tileID)
        openSet[tileID] = nil
    end
    local function openSetGetBestTileID()
        local bestID = nil
        local bestCost = math.huge
        for tileID,val in pairs(openSet) do
            if fScoreTable[tileID] < bestCost then
                bestCost = fScoreTable[tileID]
                bestID = tileID
            end
        end
        --gen.limitedExecutions('getBestTileID',20,function () print('bestID',bestID) end)
        -- returning nil stops the while loop below, and causes it to
        -- return false.  This can happen if there are no entires in the openSet table
        -- or if the bestCost is above the stopLookingHeuristicCost
        if bestCost > stopLookingHeuristicCost then
            return nil
        end
        return bestID
    end
    if civ.isTile(start) then
        fScoreTable[getTileId(start)] = heuristic(start,goal)
        gScoreTable[getTileId(start)] = 0
        openSetAdd(start)
    else
        for __,sTile in pairs(start) do
            fScoreTable[getTileId(sTile)] = heuristic(sTile,goal)
            gScoreTable[getTileId(sTile)] = 0
            openSetAdd(sTile)
        end
    end
    local cameFromTable = {} -- cameFromTable[tileID] gives tileID of the tile preceeding it on the best known path
    local function reconstructPath(currentTile) 
        local function inversePath(currentTileID,soFar,soFarLength)
            soFar[soFarLength+1]=getTileFromId(currentTileID)
            if cameFromTable[currentTileID] then
                return inversePath(cameFromTable[currentTileID],soFar,soFarLength+1)
            else
                return soFar
            end
        end
        local invPath = inversePath(getTileId(currentTile),{},0)
        local path = {}
        local len = #invPath
        for i=1,len do
            path[i] = invPath[len+1-i]
        end
        return path
    end
    local currentNodeID = openSetGetBestTileID()
    while currentNodeID do
        if goalIDTable[currentNodeID] then
            local path = reconstructPath(getTileFromId(currentNodeID))
            return pathCost(path),path
        end
        openSetRemoveID(currentNodeID)
        --gen.limitedExecutions('getTileFromID',5,function() print(getTileFromId(currentNodeID),currentNodeID) end)
        for __,neighbourInfoPair in pairs(neighbours(getTileFromId(currentNodeID))) do
            local neighbourTile = neighbourInfoPair[1]
            --if not neighbourTile.defender then
            --    civ.createUnit(civ.getUnitType(0),civ.getTribe(0),neighbourTile)
            --end
            --_G.tilesExamined = _G.tilesExamined+1
            local neighbourID = getTileId(neighbourTile)
            local neighbourCost = neighbourInfoPair[2]
            local tentativeScore = gScoreTable[currentNodeID]+neighbourCost
            if tentativeScore < (gScoreTable[neighbourID] or math.huge) then
                -- path to neighbour is better than previous one
                cameFromTable[neighbourID] = currentNodeID
                gScoreTable[neighbourID] = tentativeScore
                fScoreTable[neighbourID] = gScoreTable[neighbourID]+heuristic(neighbourTile,goal)
                openSetAdd(neighbourTile)
            end
        end
        currentNodeID = openSetGetBestTileID()
    end
    -- can't find a path
    return false
end

-- aStarCiv.findSeaPath(start,goal,tribe) -->number or false, table of tile or nil
-- finds the cost and path for a ship to get from
-- start to the goal. If start or goal is a table of
-- tiles instead of a tile, finds the shortest path between any start
-- tile and any goal tile
function aStarCiv.findSeaPath(start,goal,tribe)
    local function seaHeuristic(startTile,endTile)
        if civ.isTile(endTile) then
            return gen.tileDist(startTile,endTile)
        else
            local minDist = 10000
            for __,goalTile in pairs(endTile) do
                if gen.tileDist(startTile,goalTile) < minDist then
                    minDist = gen.tileDist(startTile,goalTile)
                end
            end
            return minDist
        end
    end
    local function seaNeighbours(tile,start,goal)
        local neighboursIndex = 1
        local neighboursTable = {}
        for __,possibleNeighbour in pairs(gen.getAdjacentTiles(tile)) do
            if possibleNeighbour.baseTerrain.type == 10 or (possibleNeighbour.city and possibleNeighbour.city.owner == tribe) then
                neighboursTable[neighboursIndex]={possibleNeighbour,1}
                neighboursIndex=neighboursIndex+1
            end
        end
        return neighboursTable
    end
    local function pathCost(path)
        return #path-1
    end
    local cost,path = aStarCiv.aStar(start,goal,seaHeuristic,seaNeighbours,pathCost)
    return cost,path
end

--function aStarCiv.markSeaPath(start,goal,tribe)
--    local startTime = os.clock()
--    local cost,path = aStarCiv.findSeaPath(start,goal,tribe)
--    local endTime = os.clock()
--    print(cost,endTime-startTime,_G.tilesExamined)
--    if path then
--        for __,tile in pairs(path) do
--            if not tile.defender then
--            civ.createUnit(civ.getUnitType(0),tribe,tile)
--            end
--        end
--    end
--end
--_G.aStarCiv=aStarCiv

    
return aStarCiv
