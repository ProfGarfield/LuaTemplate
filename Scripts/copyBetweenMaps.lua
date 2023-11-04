local sourceMap = 0 -- Map to copy info from
local destMap = 1 -- Map to copy info to

local copyResources = true
local copyImprovements = true


local width,height,maps = civ.getAtlasDimensions()

if not civ.getMap(destMap).customResources then
    error("Destination map must have custom resources enabled.  Use CTRL+F8.")
end

local function copyTile(x,y)
    if x % 2 ~= y % 2 then
        return
    end
    local sourceTile = civ.getTile(x,y,sourceMap)
    local destTile = civ.getTile(x,y,destMap)
    if not (sourceTile and destTile) then
        return
    end
    if copyImprovements then
        destTile.improvements = sourceTile.improvements
    end
    if not copyResources then
        return
    end
    if sourceTile.baseTerrain.type == 2 then
        return
    end
    if destTile.baseTerrain.type == 2 then
        return
    end
    local sourceResource = sourceTile.terrain.resource
    local destTerrain = destTile.baseTerrain:getTerrain(sourceResource)
    destTile.terrain = destTerrain
end
for x=0,width-1 do
    for y=0,height-1 do
        copyTile(x,y)       
    end
end