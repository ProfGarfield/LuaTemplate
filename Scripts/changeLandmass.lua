local gen = require("generalLibrary")

local landmassPolygon = {}
landmassPolygon[1] = {}
landmassPolygon[2] = {} -- make a note here, after the --, if you like,
landmassPolygon[3] = {} -- the -- is same as ; in regular Civ II rules
landmassPolygon[4] = {}
landmassPolygon[5] = {}
landmassPolygon[6] = {}
landmassPolygon[7] = {}
landmassPolygon[8] = {}
landmassPolygon[9] = {}
landmassPolygon[10] = {}
landmassPolygon[11] = {}
landmassPolygon[12] = {}
landmassPolygon[13] = {}
landmassPolygon[14] = {}
landmassPolygon[15] = {}
landmassPolygon[16] = {}
landmassPolygon[17] = {}
landmassPolygon[18] = {}
landmassPolygon[19] = {}
landmassPolygon[20] = {}
landmassPolygon[21] = {}
landmassPolygon[22] = {}
landmassPolygon[23] = {}
landmassPolygon[24] = {}
landmassPolygon[25] = {}
landmassPolygon[26] = {}
landmassPolygon[27] = {}
landmassPolygon[28] = {}
landmassPolygon[29] = {}
landmassPolygon[30] = {}
landmassPolygon[31] = {}
landmassPolygon[32] = {}
landmassPolygon[33] = {}
landmassPolygon[34] = {}
landmassPolygon[35] = {}
landmassPolygon[36] = {}
landmassPolygon[37] = {}
landmassPolygon[38] = {}
landmassPolygon[39] = {}
landmassPolygon[40] = {}
landmassPolygon[41] = {}
landmassPolygon[42] = {}
landmassPolygon[43] = {}
landmassPolygon[44] = {}
landmassPolygon[45] = {}
landmassPolygon[46] = {}
landmassPolygon[47] = {}
landmassPolygon[48] = {}
landmassPolygon[49] = {}
landmassPolygon[50] = {}
landmassPolygon[51] = {}
landmassPolygon[52] = {}
landmassPolygon[53] = {}
landmassPolygon[54] = {}
landmassPolygon[55] = {}
landmassPolygon[56] = {}
landmassPolygon[57] = {}
landmassPolygon[58] = {}
landmassPolygon[59] = {}
landmassPolygon[60] = {}
landmassPolygon[61] = {}
landmassPolygon[62] = {}
landmassPolygon[63] = {}
local dialog = civ.ui.createDialog()
dialog:addText("Do you wish to make the changes specified by the landmassPolygon table?")
dialog:addOption("Yes.",1)
dialog:addOption("No.", 2)
local choice = dialog:show()
if choice == 1 then
print("Changing Landmasses.  This could take some time.")
local xSize,ySize,maps = civ.getMapDimensions()
for i=1,63 do
    for z=0,(maps-1) do
        for y = 0,ySize do
            for x=0,xSize do
                local tile = civ.getTile(x,y,z)
                if tile and gen.inPolygon(tile,landmassPolygon[i])
                    and (tile.terrainType % 16 ~= 10) then
                    tile.landmass = i
                end
            end
        end
    end
    print("Landmass "..tostring(i).." complete.")
end
print("All Changes Complete.")
end

print("setLandmassNumber: xMin,xMax,yMin,yMax,landmassNumber")
    
function setLandmassNumber(xMin,xMax,yMin,yMax,landmass)
    for x=xMin,xMax do
        for y=yMin,yMax do
            for z=0,3 do
                if civ.getTile(x,y,z) and (civ.getTile(x,y,z).terrainType % 16 ~= 10) then
                    civ.getTile(x,y,z).landmass = landmass
                end
            end
        end
    end
end

