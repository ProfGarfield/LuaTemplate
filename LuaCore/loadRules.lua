
local gen = require("generalLibrary")
local loadRules = {}

local setBits = gen.setBits
local function convertBitString(bitString)
    return setBits(0,bitString)
end

local mapTerTypes = {} -- number of terrain types per map, will be set when loading

local techKey = {}
techKey[0]  = "AFl"
techKey[1]  = "Alp"
techKey[2]  = "Amp"
techKey[3]  = "Ast"
techKey[4]  = "Ato"
techKey[5]  = "Aut"
techKey[6]  = "Ban"
techKey[7]  = "Bri"
techKey[8]  = "Bro"
techKey[9]  = "Cer"
techKey[10] = "Che"
techKey[11] = "Chi"
techKey[12] = "CoL"
techKey[13] = "CA"
techKey[14] = "Cmb"
techKey[15] = "Cmn"
techKey[16] = "Cmp"
techKey[17] = "Csc"
techKey[18] = "Cst"
techKey[19] = "Cor"
techKey[20] = "Cur"
techKey[21] = "Dem"
techKey[22] = "Eco"
techKey[23] = "E1"
techKey[24] = "E2"
techKey[25] = "Eng"
techKey[26] = "Env"
techKey[27] = "Esp"
techKey[28] = "Exp"
techKey[29] = "Feu"
techKey[30] = "Fli"
techKey[31] = "Fun"
techKey[32] = "FP"
techKey[33] = "Gen"
techKey[34] = "Gue"
techKey[35] = "Gun"
techKey[36] = "Hor"
techKey[37] = "Ind"
techKey[38] = "Inv"
techKey[39] = "Iro"
techKey[40] = "Lab"
techKey[41] = "Las"
techKey[42] = "Ldr"
techKey[43] = "Lit"
techKey[44] = "Too"
techKey[45] = "Mag"
techKey[46] = "Map"
techKey[47] = "Mas"
techKey[48] = "MP"
techKey[49] = "Mat"
techKey[50] = "Med"
techKey[51] = "Met"
techKey[52] = "Min"
techKey[53] = "Mob"
techKey[54] = "Mon"
techKey[55] = "MT"
techKey[56] = "Mys"
techKey[57] = "Nav"
techKey[58] = "NF"
techKey[59] = "NP"
techKey[60] = "Phi"
techKey[61] = "Phy"
techKey[62] = "Pla"
techKey[63] = "Plu"
techKey[64] = "PT"
techKey[65] = "Pot"
techKey[66] = "Rad"
techKey[67] = "RR"
techKey[68] = "Rec"
techKey[69] = "Ref"
techKey[70] = "Rfg"
techKey[71] = "Rep"
techKey[72] = "Rob"
techKey[73] = "Roc"
techKey[74] = "San"
techKey[75] = "Sea"
techKey[76] = "SFl"
techKey[77] = "Sth"
techKey[78] = "SE"
techKey[79] = "Stl"
techKey[80] = "Sup"
techKey[81] = "Tac"
techKey[82] = "The"
techKey[83] = "ToG"
techKey[84] = "Tra"
techKey[85] = "Uni"
techKey[86] = "War"
techKey[87] = "Whe"
techKey[88] = "Wri"
techKey[89] = "..."
techKey[90] = "U1"
techKey[91] = "U2"
techKey[92] = "U3"
techKey[93] = "X1"
techKey[94] = "X2"
techKey[95] = "X3"
techKey[96] = "X4"
techKey[97] = "X5"
techKey[98] = "X6"
techKey[99] = "X7"

local techIDFromKey = {}
for id,key in pairs(techKey) do
    techIDFromKey[key] = id
end

local function removeCommentsTrailingSpaces(line)
    local semicolonLoc = string.find(line,";")
    if semicolonLoc then
        line = line:sub(1,semicolonLoc)
    end
    while line:sub(-1)==" " or line:sub(-1)=="\t" do
        line = line:sub(0,-2)
    end
    return line
end

local function defaultSectionFunction(sectionLineNumber,lineString)
    return
end

local function lineToArgTable(lineString)
    local outputTable = {}
    local dx = 0
    local pattern = string.format("([^%s]+)", ",")
    string.gsub(s,pattern,function(c) outputTable[dx] = c dx=dx+1 end)
    return outputTable
end



local function cosmicFn(sectionLineNumber,lineString)
    if sectionLineNumber >= 32 then
        return
    end
    local fTable = {
        [0] = function(lineString) civ.cosmic.roadMultiplier = tonumber(lineString) end,     -- ; Road movement multiplier
        [1] = function(lineString) civ.cosmic.triremeLost = tonumber(lineString) end,     -- ; 1 in x chance Trireme lost (mod. by Seafaring, Navigation)
        [2] = function(lineString) civ.cosmic.foodEaten = tonumber(lineString) end,     -- ; # of food each citizen eats per turn
        [3] = function(lineString) civ.cosmic.foodRows = tonumber(lineString) end,     -- ; # of rows in food box (rows * city_size+1 = box)
        [4] = function(lineString) civ.cosmic.shieldRows = tonumber(lineString) end,     -- ; # of rows in shield box
        [5] = function(lineString) civ.cosmic.settlersEatLow = tonumber(lineString) end,     -- ; Settlers eat (govt <= Monarchy)
        [6] = function(lineString) civ.cosmic.settlersEatHigh = tonumber(lineString) end,     -- ; Settlers eat (govt >= Communism)
        [7] = function(lineString) civ.cosmic.sizeUnhappiness = tonumber(lineString) end,     -- ; City size for first unhappiness at Chieftain level
        [8] = function(lineString) civ.cosmic.riotFactor = tonumber(lineString) end,     -- ; Riot factor based on # cities (higher factor lessens the effect)
        [9] = function(lineString) civ.cosmic.sizeAquaduct = tonumber(lineString) end,     -- ; Aqueduct needed to exceed this size
        [10] = function(lineString) civ.cosmic.sizeSewer = tonumber(lineString) end,     --; Sewer System needed to exceed this size                                                        
        [11] = function(lineString) civ.cosmic.techParadigm = tonumber(lineString) end,     --; Tech paradigm (higher # slows research)                                                        
        [12] = function(lineString) civ.cosmic.transformBase = tonumber(lineString) end,     --; Base time for engineers to transform terrain (x2)                                              
        [13] = function(lineString) civ.cosmic.supportMonarchy = tonumber(lineString) end,     --; Monarchy  pays support for all units past this (max 8)                                         
        [14] = function(lineString) civ.cosmic.supportCommunism = tonumber(lineString) end,     --; Communism pays support for all units past this (max 8)                                         
        [15] = function(lineString) civ.cosmic.supportFundamentalism = tonumber(lineString) end,     --; Fundamentalism pays support for all units past this (max 8)                                    
        [16] = function(lineString) civ.cosmic.communismPalaceDistance = tonumber(lineString) end,     --; Communism is equivalent of this palace distance.                                               
        [17] = function(lineString) civ.cosmic.scienceLostFundamentalism = tonumber(lineString) end,     --; Fundamentalism loses this % of science                                                         
        [18] = function(lineString) civ.cosmic.prodChangePenalty = tonumber(lineString) end,     --; Percent shield penalty for production type change                                              
        [19] = function(lineString) civ.cosmic.paradropRange = tonumber(lineString) end,     --; Max paradrop range                                                                             
        [20] = function(lineString) civ.cosmic.massThrustParadigm = tonumber(lineString) end,     --; Mass/Thrust paradigm (increasing slows spaceship time)                                         
        [21] = function(lineString) civ.cosmic.scienceRateFundamentalism = tonumber(lineString) end,     --; Max effective science rate in fundamentalism (x10, so 5 = 50%)                                 
        [22] = function(lineString) civ.cosmic.scoreCitizen = tonumber(lineString) end,     --; Value of each citizen to the Civilization Score.                                               
        [23] = function(lineString) civ.cosmic.scoreWonder = tonumber(lineString) end,     --; Value of each wonder to the Civilization Score.                                                
        [24] = function(lineString) civ.cosmic.scoreCentauri = tonumber(lineString) end,     --; Reward for landing on A. Centauri first = this multiplier*(# of habitats)*(prob. of success)   
        [25] = function(lineString) civ.cosmic.scorePollution = tonumber(lineString) end,     --; Cost to Civilization Score (+ or -) for each extant non-AI controlled polluted tile.           
        [26] = function(lineString) civ.cosmic.scorePeace = tonumber(lineString) end,     --; For each turn of peace after turn 199, this amount *3 is added to Civilization Score.          
        [27] = function(lineString) civ.cosmic.scoreFutureTech = tonumber(lineString) end,     --; Value to the Civilization Score of each future tech researched.                                
        [28] = function(lineString) civ.cosmic.penaltyBetrayal = tonumber(lineString) end,     --; Penalty assessed to Civilization Score each time player betrays another race.                  
        [29] = function(lineString) civ.cosmic.scoreUnitKilled = tonumber(lineString) end,     --; Cost to Civilization Score (+ or -) for each unit destroyed.                                   
        [30] = function(lineString) civ.cosmic.goodieHutsMask = convertBitString(lineString) end,     --; bitmask for goodie huts, right bit =map0, 0=no goodie huts                                     
        [31] = function(lineString) civ.cosmic.helisPickupHuts = tonumber(lineString) end,     --; Helicopters pick up huts 0=no 1=yes                                                            
    }
    fTable[sectionLineNumber](lineString)
end

local function cosmic2Fn(sectionLineNumber,lineString)
    local fTable
    local firstCommaLoc = string.find(lineString,",")
    if firstCommaLoc then
        local key = lineString:sub(1,firstCommaLoc-1)
        local values = lineString:sub(firstCommaLoc+1,-1)
    end

end

local function improveFn(sectionLineNumber,lineString)
    -- can't change the name of the improvement




end

local function terrainFunction(sectionLineNumber,lineString,mapNumber)
    if sectionLineNumber < mapTerTypes[mapNumber] then
        -- main terrain definitions
        local argTable = lineToArgTable(lineString)
        local terrain = civ.getTerrain(mapNumber,sectionLineNumber,0)
        local baseTerrain = civ.getBaseTerrain(mapNumber,sectionLineNumber)
        -- don't need the name, (argTable[0]), since can't change that

        -- reset move cost
        baseTerrain.moveCost = tonumber(argTable[1])
        -- reset defense
        baseTerrain.defense = tonumber(argTable[2])
        -- reset base food production
        terrain.food = tonumber(argTable[3])
        -- reset base shield production
        terrain.shields = tonumber(argTable[4])
        -- reset base trade production
        terrain.trade = tonumber(argTable[5])


    else
        -- specials definitions
        --
    end


end


local function terrainFn(sectionLineNumber,lineString)
    terrainFunction(sectionLineNumber,lineString,0)
end
local function terrainFn1(sectionLineNumber,lineString)
    terrainFunction(sectionLineNumber,lineString,0)
end
local function terrainFn2(sectionLineNumber,lineString)
    terrainFunction(sectionLineNumber,lineString,0)
end
local function terrainFn3(sectionLineNumber,lineString)
    terrainFunction(sectionLineNumber,lineString,0)
end

-- enter all the section functions into this table
-- all section functions must be of the form secFunc(sectionLineNumber,lineString)-->void
local sectionFunctionTable = {}
sectionFunctionTable["@cosmic"] = cosmicFn


local linesSinceSection = 0 -- keeps track of the number of lines since the last @SECTION line
                            -- start counting at 0, since most id numbers, etc. start at 0
local currentSectionFunction = defaultSectionFunction
local function setSectionFunction(lineString)
    currentSectionFunction = sectionFunctionTable[string.lower(lineString)]
    if not currentSectionFunction then
        currentSectionFunction = defaultSectionFunction
    end
    linesSinceSection = 0
end




function loadRules.loadRules(filePath,terrainMap0,terrainMap1,terrainMap2,terrainMap3)
    mapTerTypes[0] = terrainMap0
    mapTerTypes[1] = terrainMap1
    mapTerTypes[2] = terrainMap2
    mapTerTypes[3] = terrainMap3
    
    for line in io.lines(filePath) do
        line = removeCommentsTrailingSpaces(line)
        linesSinceSection = linesSinceSection+1
        if line:sub(1,1) == "@" then
            setSectionFunction(line)
        else
            currentSectionFunction(linesSinceSection,line)
        end
    end
end


return loadRules
