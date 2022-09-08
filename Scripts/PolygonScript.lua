local fileName = "PolygonScript.lua"
local scriptPath = string.gsub(debug.getinfo(1).source, "@", "")
local scriptFolder = string.gsub(scriptPath,fileName,"")
local scriptFolderPath = string.gsub(scriptPath, fileName, "?.lua")
local function removeLastFolder(text)
    text = string.sub(text,1,-2)
    if string.sub(text,-1,-1) == "\\" then
        return text
    else
        return removeLastFolder(text)
    end
end
--if string.find(package.path, scriptFolderPath, 1, true) == nil then
    package.path = ""
            ..scriptFolder.."?.lua;"
            ..removeLastFolder(scriptFolder).."?.lua;"
            ..removeLastFolder(scriptFolder).."LuaCore\\?.lua;"
--end
print(scriptFolder)
print(removeLastFolder(scriptFolder))
print("")
print(package.path)

local gen = require("generalLibrary")


local dialog = civ.ui.createDialog()
dialog:addText("PolygonScript will clear your existing key press events until you reload the game.  Choose Cancel if you don't want this to happen yet.")
dialog:addOption("Start doing Polygon Stuff.",1)
dialog:addOption("Tell me about PolygonScript.",2)
dialog:addOption("Cancel.",3)
local choice = dialog:show()
if choice == 3 then
    return
end

-- you can have up to 10 polygons
local polygonTable={
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
}

local activePolygon = 1
-- the unit that will mark the corners of each polygon
local polygonCornerMarkerUnitTable = {}
polygonCornerMarkerUnitTable[1] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[2] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[3] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[4] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[5] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[6] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[7] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[8] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[9] = civ.getUnitType(0)
polygonCornerMarkerUnitTable[10] = civ.getUnitType(0)
-- the unit that will mark the interior of each polygon
local tileInPolygonMarkerUnit = {}
tileInPolygonMarkerUnit[1] = civ.getUnitType(2)
tileInPolygonMarkerUnit[2] = civ.getUnitType(2)
tileInPolygonMarkerUnit[3] = civ.getUnitType(2)
tileInPolygonMarkerUnit[4] = civ.getUnitType(2)
tileInPolygonMarkerUnit[5] = civ.getUnitType(2)
tileInPolygonMarkerUnit[6] = civ.getUnitType(2)
tileInPolygonMarkerUnit[7] = civ.getUnitType(2)
tileInPolygonMarkerUnit[8] = civ.getUnitType(2)
tileInPolygonMarkerUnit[9] = civ.getUnitType(2)
tileInPolygonMarkerUnit[10] = civ.getUnitType(2)

if choice == 2 then
    local polygonScriptIntroText1 =
[[Welcome to the Polygon Script.  This script contains a few tools to 
help you use the gen.inPolygon function of the General Library. 
First, note that running this script overwrites the on key pressed events 
in your scenario.  You will have to reload your game again for them to 
work again.]]
local pSIT2=[[^]]
local pSIT3=[[You can store up to 10 polygons at a time.  You can change the polygon you are working on by pressing 'Tab'.]]
local pSIT4=[[^]]
local pSIT5=[[The 'K' key adds a vertex (corner) to the polygon and places a barbarian to mark the corner.  The unitType placed for each polygon can be changed in the file PolygonScript.lua.]]
local pSIT6=[[^]]
local pSIT7=[[The 'Backspace' key gives options related to each polygon. These are to place a marker unit on each square in the polygon, to clear the polygon of all interior marker units, to clear the polygon of all corner marker units, to place corner markers for the polygon, to empty the polygon, and to print a table constructor for the polygon to the console.]]

civ.ui.text(polygonScriptIntroText1)--,pSIT2,pSIT3,pSIT4,pSIT5,pSIT6,pSIT7)
civ.ui.text(pSIT3)
civ.ui.text(pSIT5)
civ.ui.text(pSIT7)

end

local function guessGoodDoesNotCross(vertexTable)
    local width,height,maps = civ.getMapDimensions()
    local eligibleDNC = {}
    for i=0,width-1 do
        eligibleDNC[i] = true
    end
    local vertices = #vertexTable
    if vertices == 0 then
        return 0
    end
    for i=1,vertices do
        local vertex1 = vertexTable[i]
        local vertex2 = vertexTable[i+1] or vertexTable[1]
        local x1 = vertex1[1]
        local x2 = vertex2[1]
        if x1 > x2 then
            x1,x2=x2,x1
        end
        x1 = math.floor(x1)
        x2 = math.floor(x2)
        if (x2-x1) < (x1+width-x2) then
            -- assume dateline not crossed, since shorter distance
            -- between 2 x values
            for j=x1,x2 do
                eligibleDNC[j] = nil
            end
        else
            -- date line crossed
            for j=0,x1 do
                eligibleDNC[j] = nil
            end
            for j=x2,width-1 do
                eligibleDNC[j] = nil
            end
        end
    end
    for i=0,width-1 do
        if eligibleDNC[i%width] and
            eligibleDNC[(i+1)%width] and
            eligibleDNC[(i+2)%width] and
            eligibleDNC[(i+3)%width] and
            eligibleDNC[(i+4)%width] 
        then
            return (i+2)%width
        end
    end
    return nil
end
    

civ.scen.onKeyPress(function(keyID)
    if keyID == 211 --[[tab]] then
        local changePolygonDialog = civ.ui.createDialog()
        for i=1,10 do
            changePolygonDialog:addOption("Polygon "..tostring(i).." ("..tostring(#(polygonTable[i])).." corners)",i)
        end
        activePolygon = changePolygonDialog:show()
    elseif keyID == 75 --[[k]] then
        local activePolygonVertexTable = polygonTable[activePolygon]
        local tile = civ.getCurrentTile()
        activePolygonVertexTable[#activePolygonVertexTable+1] = {tile.x,tile.y}
        civ.createUnit(polygonCornerMarkerUnitTable[activePolygon],civ.getTribe(0),tile)
    elseif keyID == 214 --[[backspace]] then
        local activePolygonVertexTable = polygonTable[activePolygon]
        activePolygonVertexTable.doesNotCrossThisX = activePolygonVertexTable.doesNotCrossThisX or guessGoodDoesNotCross(activePolygonVertexTable)
        local dialog = civ.ui.createDialog()
        dialog.title = "Options for Polygon "..tostring(activePolygon)
        dialog:addOption("Fill Polygon "..tostring(activePolygon).."  with marker units.",1)
        dialog:addOption("Clear Polygon "..tostring(activePolygon).." of interior marker units.",2)
        dialog:addOption("Clear Polygon "..tostring(activePolygon).." of corner marker units.",3)
        dialog:addOption("Place corner markers for "..tostring(activePolygon)..".",4)
        dialog:addOption("Delete Polygon "..tostring(activePolygon)..".",5)
        dialog:addOption("Print constructor for Polygon "..tostring(activePolygon).." to console.",6)
        dialog:addOption("Cancel.",7)
        local choice = dialog:show()
        if choice == 7 then
            return
        elseif choice ==1 then
            local xMax,yMax,maps = civ.getMapDimensions()
            for z=0,maps-1 do
                for y=0,yMax do
                    for x=0,xMax do
                        local tile = civ.getTile(x,y,z)
                        if tile and gen.inPolygon(tile,activePolygonVertexTable) then
                            civ.createUnit(tileInPolygonMarkerUnit[activePolygon],civ.getTribe(0),tile)
                        end
                    end
                end
            end
        elseif choice == 2 then
            local xMax,yMax,maps = civ.getMapDimensions()
            for z=0,maps-1 do
                for y=0,yMax do
                    for x=0,xMax do
                        local tile = civ.getTile(x,y,z)
                        if tile and gen.inPolygon(tile,activePolygonVertexTable) then
                            for unitOnTile in tile.units do
                                if unitOnTile.type == tileInPolygonMarkerUnit[activePolygon] and
                                    unitOnTile.owner == civ.getTribe(0) then
                                    civ.deleteUnit(unitOnTile)
                                    civ.ui.redrawTile(tile)
                                end
                            end
                        end
                    end
                end
            end
        elseif choice == 3 then
            for z=0,3 do
                for __,tileCoord in pairs(activePolygonVertexTable) do
                    if type(tileCoord) == "table" then
                        local tile = civ.getTile(tileCoord[1],tileCoord[2],z) 
                        if tile then
                            for unitOnTile in tile.units do
                                if unitOnTile.type == polygonCornerMarkerUnitTable[activePolygon] and
                                    unitOnTile.owner == civ.getTribe(0) then
                                    civ.deleteUnit(unitOnTile)
                                    civ.ui.redrawTile(tile)
                                end
                            end
                        end
                    end
                end
            end
        elseif choice == 4 then
            for z=0,3 do
                for __,tileCoord in pairs(activePolygonVertexTable) do
                    if type(tileCoord) == "table" then
                        local tile = civ.getTile(tileCoord[1],tileCoord[2],z) 
                        if tile then
                            civ.createUnit(polygonCornerMarkerUnitTable[activePolygon],civ.getTribe(0),tile)
                        end
                    end
                end
            end
        elseif choice == 5 then
            polygonTable[activePolygon] = {}
        elseif choice == 6 then
            local outputString = "polygon = {"
            for i=1,#activePolygonVertexTable do
                local t=activePolygonVertexTable[i]
                outputString = outputString.."{"..tostring(t[1])..","..tostring(t[2]).."},"
            end
            outputString = outputString.."doesNotCrossThisX="..tostring(activePolygonVertexTable.doesNotCrossThisX).."}"
            print(outputString)
        end
    end
end)


