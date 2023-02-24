

local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



-- This Module provides functions to read a rules.txt file and update the
-- corresponding Lua objects to apply this new rules system
-- It also provides 2 tables containing the rules currently in force
-- to facilitate resetting rules:
--      changeRules.currentlyAppliedRules
--          this is a table organized the same way as a table read by readRules
--      changeRules.authoritativeDefaultRules
--          this is a table with keys and values similar to the luaObjects
--          they are providing a default for.  More info is below.
--
--  Provided Functions:
--
--  changeRules.changeAllRules(rulesTable)
--  changeRules.changeAllRules(rulesTable,doNotChangeTransportSettings = nil)
--      runs all the changeRules functions below.
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      The function looks for the file in the scenario's folder for the file
--      if doNotChangeTransportSettings is true, 
--          unitType.nativeTransport, unitType.buildTransport, unitType.useTransport
--      are not updated
--      A @COSMIC2 section is optional (changeCosmic2Rules allowEmpty argument is true)
--
-- changeRules.changeUnitTypeRules(rulesTable, doNotChangeTransportSettings = nil)
-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
-- updates changeRules.currentlyAppliedRules["@UNITS"],
--          changeRules.currentlyAppliedRules["@UNITS_ADVANCED"],
--          changeRules.currentlyAppliedRules["@ATTACKS"]
--              if no @ATTACKS section, attack limitations are set to default movement allowance
--              If initial rules didn't have an @ATTACKS section, unitType.attacksPerTurn can't
--              be set, so the section is ignored in changed rules
--  updates changeRules.authoritativeDefaultRules[unitType] for all unit types in the game
--  changes the unitType objects for all units in the game to reflect new rules
--  if doNotChangeTransportSettings is true, 
--      unitType.nativeTransport, unitType.buildTransport, unitType.useTransport
--  are not updated
--
-- changeRules.changeImprovementRules(rulesTable)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      changes improvementObjects to correspond to the rules that rulesTable provides
--      updates changeRules.currentlyAppliedRules["@IMPROVE"]
--      updates changeRules.authoritativeDefaultRules[improvementObject]
--
-- changeRules.changeTechRules(rulesTable)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      changes tech objects to correspond to the rules that the rulesTable provies
--      updates changeRules.currentlyAppliedRules["@CIVILIZE"]
--      updates changeRules.currentlyAppliedRules["@CIVILIZE2"]
--      updates changeRules.authoritativeDefaultRules[techObject]
--      (Note: a tech with a 'no' prereq can't be added to the tech tree via Lua,
--      however, the techOjbect and authoritativeDefaultRules will still be changed)
--
-- changeRules.changeTerrainRules(rulesTable)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      changes terrain and baseTerrain objects to correspond to the rules that the rulesTable provies
--      updates changeRules.currentlyAppliedRules["@TERRAIN"]
--      updates changeRules.currentlyAppliedRules["@TERRAIN1"]/["@TERRAIN2"]/["@TERRAIN3"]
--      updates changeRules.authoritativeDefaultRules[baseTerrain]/[terrain]
--
-- changeRules.changeCosmic2Rules(rulesTable,allowEmpty=nil)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      updates changeRules.currentlyAppliedRules["@COSMIC2"]
--          replaces the line with the same key in the 0 column
--      updates changeRules.authoritativeDefaultRules["cosmic2"]["keyInNewRules"]
--      Note: if a key is omitted from the newly provided @COSMIC2 section, the previously
--      registered value is still used;
--      Note: If a key can't be changed with Lua, it is not updated in
--      changeRules.currentlyAppliedRules or changeRules.authoritativeDefaultRules
--      If the rules provided do not have a @COSMIC2 section, and allowEmpty is true
--      an empty table is used instead, so no error is triggered
--      if any movement multipliers are updated, all unit types have their movement 
--      updated as well.
--          local updatableCosmic2Keys = {
--          ["fortifydefense"] = true,
--          ["fortressdefense"] = true,
--          ["citywallsdefense"] = true,
--          ["coastalfortressdefense"] = true,
--          ["aegisvsairdefense"] = true,
--          ["aegisvsmissiledefense"] = true,
--          ["samdefense"] = true,
--          ["sdidefense"] = true,
--          ["terraindefenseforair"] = true,
--          ["terraindefenseforsea"] =true,
--          ["railroadmultiplier"] = true,
--          ["roadmultiplier"] = true,
--          ["rivermultiplier"] = true,
--          ["alpinemultiplier"] = true,
--          
--          }
--
--
--
-- changeRules.changeCosmicRules(rulesTable)
-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
-- updates changeRules.currentlyAppliedRules["@COSMIC"],
-- updates changeRules.authoritativeDefaultRules["civ.cosmic"]
--      note: civ.cosmic.roadMultiplier is never changed
--  
-- changeRules.changeRoadTrade(rulesTable)
-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
-- updates changeRules.currentlyAppliedRules["@ROADTRADE"],
-- updates changeRules.currentlyAppliedRules["@ROADTRADE1"], (if applicable)
-- updates changeRules.currentlyAppliedRules["@ROADTRADE2"], (if applicable)
-- updates changeRules.currentlyAppliedRules["@ROADTRADE3"], (if applicable)
-- updates changeRules.authoritativeDefaultRules["totpp.roadTrade"]
-- updates totpp.roadTrade
--  if the rules do not have an @ROADTRADE section, the defaults of
--  road trade only on desert, plains, and grassland are implemented
--
--
--  changeRules.authoritativeDefaultRules
--
--          changeRules.authoriativeDefaultRules[item]["propertyKey"]
--              The 'item' is one of the following Civ II objects:
--                  unitType, improvement, wonder, tech, baseTerrain,terrain.
--              The 'propertyKey' is a key for that kind of object
--                  (e.g. 'cost', 'prereq', 'move', etc.)
--          changeRules.authoritativeDefaultRules["civ.cosmic"]["propertyKey"]
--              gives value corresponding to civ.cosmic.propertyKey
--          changeRules.authoritativeDefaultRules["totpp.roadTrade"][map] = bitmask
--              map is either a mapObject or an integer 0,1,2,3 corresponding to a map
--                  gives value corresponding to totpp.roadTrade[map]
--          changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]["propertyKey"]
--              gives the value corresponding to totpp.movementMultipliers.propertyKey
--          changeRules.authoritativeDefaultRules["cosmic2"]["cosmic2Key"]
--              gives the value corresponding to the key in @COSMIC2 in the rules.txt
--              cosmic2Key is the column 0 entry in @COSMIC2, cosmic2Key is not case sensitive (but propertyKey is)
--              The values of some keys have been changes.  
--              0/1 keys are changed to true/false
--              movementMultiplier keys only have the multiplier, not the 0/1 disable/enable flag
--              Here are the defaults, to see how each is organized:
--[[              
                local cosmic2Defaults = {
                ["impassableair"] = false,
                ["tradegoldmultiplier"] = 100,
                ["tradesciencemultiplier"] = 100,
                ["tradewondermultiplier"] = 100,
                ["fortifydefense"] = 3,
                ["fortressdefense"] = 4,
                ["citywallsdefense"] = 6,
                ["coastalfortressdefense"] = 4,
                ["aegisvsairdefense"] = 6,
                ["aegisvsmissiledefense"] = 10,
                ["samdefense"] = 4,
                ["sdidefense"] = 4,
                ["terraindefenseforair"] = true,
                ["terraindefenseforsea"] = true,
                ["citypopulationlossattack"] = 0,
                ["citypopulationlosscapture"] = 0,
                ["unitshieldcolor"] = {16,8},
                ["nostackkills"] = false,
                ["eventheapsize"] = {106480,1},
                ["navigableriversintercardinal"] = true,
                ["numberofterraintypes"] = {[0] = 11,11,11,11},
                ["numberofanimatedresources"] = {[0] = 11,11,11,11},
                ["noincrementalrushbuy"] = false,
                ["railroadmultiplier"] =-1,
                ["roadmultiplier"] = 3,
                ["rivermultiplier"] = 3,
                ["alpinemultiplier"] = 3,
                ["productioncarryover"] = false,
                ["lwpreserveveterancy"] = false,
                ["cityspritespertribe"] = false,
                ["cityspritespermap"] = false,
                ["aicapitalizationlimit"] = 512,
                ["barbunitsupport"] = false,
                ["barboffensiveunitlimit"] = 16,
                ["barbresearch"] = false,
                ["playabletribes"] = flagStringToNumber("11111110"),
                ["playabledifficulties"] = flagStringToNumber("111111"),
                ["numberofunittypes"] = 80,
                ["numberoftechs"] = 100,
                }
--]]
--              
--
--              
--              
--

--      Potentially Unexpected Functionality
--          civ.cosmic.roadMultiplier is never changed, since it interferes with totpp.movementMultipliers
--          authoritativeDefaultRules[unitType].move stores the number in the rules.txt, while
--              unitType.move returns the 'atomic' movement points for the unit
--              this is so that changes to totpp.movementMultipliers doesn't force changes to all the units
--
--          In Lua, 'no' and 'nil' prerequisites are both represented as nil values to corresponding keys
--          In authoritativeDefaultRules, however, nil means no prerequisite, and false means the
--          item is excluded from the game, that is, 'no' prerequisite.
--          If rules are changed, units/improvements/wonders with 'no' as a prereq in the new rules 
--          will not have item.prereq changed.  This way, items that have 'no' as the prereq in all
--          versions of the rules will remain unbuildable.  If you need to remove the item from the 
--          game, choose a technology to be the "not buildable" technology, and assign that as
--          the prerequisite.  Note, authoritativeDefaultRules[item]["prereq"] will still be changed
--          to false if the rules assign a prereq of <no>, even though item.prereq will have its previous
--          prerequisite still.
--          Technologies with a prereq of 'no' can't be made researchable by changing their
--          prerequisites with Lua within the game.  authoritativeDefaultRules[tech] doesn't keep
--          track of this, and prerequisites will be changed with lua if new rules require it, even
--          if it doesn't change whether the tech can be researched in game. That is, if the rules
--          change a <no>,<no> tech to nil,nil, authoritativeDefaultRules[tech] will update prereq1
--          and prereq2 from false,false to nil,nil, even though the game won't change.
--
--          When cosmic2 rules are changed, only entries in the new @COSMIC2 section are changed.
--          E.g. if FortifyDefense, 4 was in the original @COSMIC2, and the changed rules @COSMIC2
--          section omits FortifyDefense, then changeRules.authoritativeDefaultRules["cosmic2"]["FortifyDefense"]
--          will still be 4, rather than being reverted to the default of 3.
--
--          If your initially loaded game does not have an @ATTACKS section, you can't add one in
--          a later rules.txt file. (or change attacksPerTurn in lua at all)
--
--          If you set a baseTerrain transformTo value to 'no'/nil, when it wasn't already 'no'/nil,
--          baseTerrain.transformTo will instead be set to that baseTerrain.  At the time of
--          creation, setting baseTerrain.transformTo = nil has the effect of setting
--          baseTerrain.transformTo = desertBaseTerrain
--          
--



local gen = require('generalLibrary'):minVersion(1)
local readRules = require("readRules")
local combatCalculator = require("combatCalculator"):minVersion(3)
local changeRules = {}

changeRules.currentlyAppliedRules = readRules.loadedRules


--
--  makes a function that reads the col entry of
--  ruleRow, and converts it to a number
local function toNum(col)
    return function(ruleRow) local cleanNumber = string.gsub(ruleRow[col],"%D","") return tonumber(cleanNumber) end
end


local function flagStringToNumber(flagString)
    local number = 0
    for i=1,string.len(flagString) do
        if string.sub(flagString,-i,-i) == "1" then
            number = number | (1<<(i-1))
        end
    end
    return number
end

-- makes a function that reads the col entry of ruleRow,
-- interprets it as a binary number, then converts that
-- binary number to an integer
local function flagStrToNum(col)
    return function(ruleRow) return flagStringToNumber(ruleRow[col]) end
end

-- makes a function that reads the col entry of ruleRow,
-- and returns it as a string
local function getStr(col)
    return function(ruleRow) return ruleRow[col] end
end

-- this is function to make debugging easier
local function superstring(item)
    if civ.isBaseTerrain(item) then
        return item.name
    end
    return tostring(item)
end
local techAbbreviationToID = {
["AFl"] = 0,
["Alp"] = 1,
["Amp"] = 2,
["Ast"] = 3,
["Ato"] = 4,
["Aut"] = 5,
["Ban"] = 6,
["Bri"] = 7,
["Bro"] = 8,
["Cer"] = 9,
["Che"] = 10,
["Chi"] = 11,
["CoL"] = 12,
["CA"] =  13,
["Cmb"] = 14,
["Cmn"] = 15,
["Cmp"] = 16,
["Csc"] = 17,
["Cst"] = 18,
["Cor"] = 19 ,
["Cur"] = 20,
["Dem"] = 21,
["Eco"] = 22,
["E1"] =  23,
["E2"] =  24,
["Eng"] = 25,
["Env"] = 26,
["Esp"] = 27,
["Exp"] = 28,
["Feu"] = 29,
["Fli"] = 30 ,
["Fun"] = 31,
["FP"] =  32,
["Gen"] = 33,
["Gue"] = 34,
["Gun"] = 35,
["Hor"] = 36,
["Ind"] = 37,
["Inv"] = 38,
["Iro"] = 39,
["Lab"] = 40,
["Las"] = 41,
["Ldr"] = 42,
["Lit"] = 43,
["Too"] = 44,
["Mag"] = 45,
["Map"] = 46,
["Mas"] = 47,
["MP"] =  48,
["Mat"] = 49,
["Med"] = 50,
["Met"] = 51,
["Min"] = 52,
["Mob"] = 53,
["Mon"] = 54,
["MT"] =  55,
["Mys"] = 56,
["Nav"] = 57,
["NF"] =  58,
["NP"] =  59,
["Phi"] = 60,
["Phy"] = 61,
["Pla"] = 62,
["Plu"] = 63,
["PT"] =  64,
["Pot"] = 65,
["Rad"] = 66,
["RR"] =  67,
["Rec"] = 68,
["Ref"] = 69,
["Rfg"] = 70,
["Rep"] = 71,
["Rob"] = 72,
["Roc"] = 73,
["San"] = 74,
["Sea"] = 75,
["SFl"] = 76,
["Sth"] = 77,
["SE"] =  78,
["Stl"] = 79,
["Sup"] = 80 ,
["Tac"] = 81,
["The"] = 82,
["ToG"] = 83,
["Tra"] = 84,
["Uni"] = 85,
["War"] = 86,
["Whe"] = 87,
["Wri"] = 88,
["..."] = 89,
["U1"] =  90,
["U2"] =  91,
["U3"] =  92,
["X1"] =  93,
["X2"] =  94,
["X3"] =  95,
["X4"] =  96,
["X5"] =  97,
["X6"] =  98,
["X7"] =  99,
["X64"] = 100,
["X65"] = 101,
["X66"] = 102,
["X67"] = 103,
["X68"] = 104,
["X69"] = 105,
["X6A"] = 106,
["X6B"] = 107,
["X6C"] = 108,
["X6D"] = 109,
["X6E"] = 110,
["X6F"] = 111,
["X70"] = 112,
["X71"] = 113,
["X72"] = 114,
["X73"] = 115,
["X74"] = 116,
["X75"] = 117,
["X76"] = 118,
["X77"] = 119,
["X78"] = 120,
["X79"] = 121,
["X7A"] = 122,
["X7B"] = 123,
["X7C"] = 124,
["X7D"] = 125,
["X7E"] = 126,
["X7F"] = 127,
["X80"] = 128,
["X81"] = 129,
["X82"] = 130,
["X83"] = 131,
["X84"] = 132,
["X85"] = 133,
["X86"] = 134,
["X87"] = 135,
["X88"] = 136,
["X89"] = 137,
["X8A"] = 138,
["X8B"] = 139,
["X8C"] = 140,
["X8D"] = 141,
["X8E"] = 142,
["X8F"] = 143,
["X90"] = 144,
["X91"] = 145,
["X92"] = 146,
["X93"] = 147,
["X94"] = 148,
["X95"] = 149,
["X96"] = 150,
["X97"] = 151,
["X98"] = 152,
["X99"] = 153,
["X9A"] = 154,
["X9B"] = 155,
["X9C"] = 156,
["X9D"] = 157,
["X9E"] = 158,
["X9F"] = 159,
["XA0"] = 160,
["XA1"] = 161,
["XA2"] = 162,
["XA3"] = 163,
["XA4"] = 164,
["XA5"] = 165,
["XA6"] = 166,
["XA7"] = 167,
["XA8"] = 168,
["XA9"] = 169,
["XAA"] = 170,
["XAB"] = 171,
["XAC"] = 172,
["XAD"] = 173,
["XAE"] = 174,
["XAF"] = 175,
["XB0"] = 176,
["XB1"] = 177,
["XB2"] = 178,
["XB3"] = 179,
["XB4"] = 180,
["XB5"] = 181,
["XB6"] = 182,
["XB7"] = 183,
["XB8"] = 184,
["XB9"] = 185,
["XBA"] = 186,
["XBB"] = 187,
["XBC"] = 188,
["XBD"] = 189,
["XBE"] = 190,
["XBF"] = 191,
["XC0"] = 192,
["XC1"] = 193,
["XC2"] = 194,
["XC3"] = 195,
["XC4"] = 196,
["XC5"] = 197,
["XC6"] = 198,
["XC7"] = 199,
["XC8"] = 200,
["XC9"] = 201,
["XCA"] = 202,
["XCB"] = 203,
["XCC"] = 204,
["XCD"] = 205,
["XCE"] = 206,
["XCF"] = 207,
["XD0"] = 208,
["XD1"] = 209,
["XD2"] = 210,
["XD3"] = 211,
["XD4"] = 212,
["XD5"] = 213,
["XD6"] = 214,
["XD7"] = 215,
["XD8"] = 216,
["XD9"] = 217,
["XDA"] = 218,
["XDB"] = 219,
["XDC"] = 220,
["XDD"] = 221,
["XDE"] = 222,
["XDF"] = 223,
["XE0"] = 224,
["XE1"] = 225,
["XE2"] = 226,
["XE3"] = 227,
["XE4"] = 228,
["XE5"] = 229,
["XE6"] = 230,
["XE7"] = 231,
["XE8"] = 232,
["XE9"] = 233,
["XEA"] = 234,
["XEB"] = 235,
["XEC"] = 236,
["XED"] = 237,
["XEE"] = 238,
["XEF"] = 239,
["XF0"] = 240,
["XF1"] = 241,
["XF2"] = 242,
["XF3"] = 243,
["XF4"] = 244,
["XF5"] = 245,
["XF6"] = 246,
["XF7"] = 247,
["XF8"] = 248,
["XF9"] = 249,
["XFA"] = 250,
["XFB"] = 251,
["XFC"] = 252,
["no"] = false,
}
-- makes a function that reads the col entry of ruleRow
-- interprets the string as the short form of a tech,
-- then returns the tech
-- "no" is returned as false instead of nil
local function toTech(col)
    return function(ruleRow) return techAbbreviationToID[ruleRow[col]] and civ.getTech(techAbbreviationToID[ruleRow[col]]) end
end


-- applyRuleRow(object,rowToKeyTable,ruleRow)
-- rowToKeyTable = {[key]=convertFn(ruleRow)}
local function applyRuleRow(object,rowToKeyTable,ruleRow)
    for key,convertFn in pairs(rowToKeyTable) do
        local value = convertFn(ruleRow)
        if value == false and (key == "prereq" or key == "prereq1" or key == "prereq2")
            and type(object) == "userdata" then
            -- This means there is a prerequisite of no, which is represented by false
            -- at time of writing, lua doesn't distinguish between not having a prerequisite
            -- and having a prerequisite of 'no'.  They are both represented as nil
            -- For techs, if the tech was excluded in the initial reading of the rules, 
            -- it can't be added by changing the prereq.
            -- However, unit/improvement prerequisites can be changed, and assigning nil
            -- to the prereq key makes them automatically buildable.  Hence, if the prereq
            -- is 'no', that is converted to false, and so nothing is assigned to the
            -- unit/improvement prereq.  This prevents giving units/improvements nil prereq
            -- when updating
        elseif civ.isBaseTerrain(object) and (key == "irrigateTo" or key == "canIrrigate" or key == "mineTo" or key == "canMine" or key == "transformTo") then
            -- do nothing the pairs irrigateTo, canIrrigate and mineTo,canMine have side effects
            -- on the other key in the pair for the baseTerrain object.  Hence, these
            -- keys for baseTerrain will be handled elsewhere
            -- if baseTerrain.transformTo is set to nil (even if it is already nil), it is instead
            -- set to desert, so do nothing here in this case
        else
            object[key] = value
        end
    end
end
    





--  changeRules.authoritativeDefaultRules[rulesObject][keyString] = value
--  This table is considered the to be the authority on what the
--  rules 'should' be at any given time.  E.g., if the movement of a unit type
--  is changed for a specific bonus/penalty, this is where to look to
--  get the 'normal' value again
--  a rulesObject is a civ object representing a line in rules.txt,
--  such as a unitType, or improvement object, but not a unit object,
--  tile object, or city object.
--  also, the following strings are valid keys:
--      "civ.cosmic"
--      "civ.game"
--      "civ.scen.params"
--      "totpp.roadTrade"
--      "totpp.movementMultipliers"
--      "cosmic2"
--      
--
--
local intVDI = {["number"] = {integer=true}}
local intNilVDI = {["number"] = {integer=true}, ["nil"] = true}
local boolVDI = {["boolean"] = true}
local stringVDI = {["string"] = true}
local techVDI = {["userdata"] = {["tech"] = civ.isTech},["nil"]=true}
local prereqVDI = {["userdata"] = {["tech"] = civ.isTech},["nil"]=true,["boolean"]="false"}
local baseTerrainVDI = {["userdata"] = {["baseTerrain"] = civ.isBaseTerrain}, ["nil"]=true}

-- changeRules.authoritativeDefaultRules["cosmic2"][cosmic2Key] = table of values, first index 1
local cosmic2WrittenDefaults = {
["ImpassableAir"] = {0},
["TradeGoldMultiplier"] = {100},
["TradeScienceMultiplier"] = {100},
["TradeWonderMultiplier"] = {100},
["FortifyDefense"] = {3},
["FortressDefense"] = {4},
["CityWallsDefense"] = {6},
["CoastalFortressDefense"] = {4},
["AegisVSAirDefense"] = {6},
["AegisVSMissileDefense"] = {10},
["SAMDefense"] = {4},
["SDIDefense"] = {4},
["TerrainDefenseForAir"] = {1},
["TerrainDefenseForSea"] = {1},
["CityPopulationLossAttack"] = {0},
["CityPopulationLossCapture"] = {0},
["UnitShieldColor"] = {16,8},
["NoStackKills"] = {0},
["EventHeapSize"] = {106480,1},
["NavigableRiversIntercardinal"] = {1},
["NumberOfTerrainTypes"] = {11,11,11,11},
["NumberOfAnimatedResources"] = {11,11,11,11},
["NoIncrementalRushBuy"] = {0},
["RailroadMultiplier"] = {0,-1},
["RoadMultiplier"] = {0,3},
["RiverMultiplier"] = {0,3},
["AlpineMultiplier"] = {0,3},
["ProductionCarryOver"] = {0},
["LWPreserveVeterancy"] = {0},
["CitySpritesPerTribe"] = {0},
["CitySpritesPerMap"] = {0},
["AICapitalizationLimit"] = {512},
["BarbUnitSupport"] = {0},
["BarbOffensiveUnitLimit"] = {16},
["BarbResearch"] = {0},
["PlayableTribes"] = {"0b11111110"},
["PlayableDifficulties"] = {"0b111111"},
["NumberOfTechs"] = {100},
["NumberOfUnitTypes"] = {80},

}
local cosmic2Defaults = {
["impassableair"] = false,
["tradegoldmultiplier"] = 100,
["tradesciencemultiplier"] = 100,
["tradewondermultiplier"] = 100,
["fortifydefense"] = 3,
["fortressdefense"] = 4,
["citywallsdefense"] = 6,
["coastalfortressdefense"] = 4,
["aegisvsairdefense"] = 6,
["aegisvsmissiledefense"] = 10,
["samdefense"] = 4,
["sdidefense"] = 4,
["terraindefenseforair"] = true,
["terraindefenseforsea"] = true,
["citypopulationlossattack"] = 0,
["citypopulationlosscapture"] = 0,
["unitshieldcolor"] = {16,8},
["nostackkills"] = false,
["eventheapsize"] = {106480,1},
["navigableriversintercardinal"] = true,
["numberofterraintypes"] = {[0] = 11,11,11,11},
["numberofanimatedresources"] = {[0] = 11,11,11,11},
["noincrementalrushbuy"] = false,
["railroadmultiplier"] =-1,
["roadmultiplier"] = 3,
["rivermultiplier"] = 3,
["alpinemultiplier"] = 3,
["productioncarryover"] = false,
["lwpreserveveterancy"] = false,
["cityspritespertribe"] = false,
["cityspritespermap"] = false,
["aicapitalizationlimit"] = 512,
["barbunitsupport"] = false,
["barboffensiveunitlimit"] = 16,
["barbresearch"] = false,
["playabletribes"] = flagStringToNumber("11111110"),
["playabledifficulties"] = flagStringToNumber("111111"),
["numberofunittypes"] = 80,
["numberoftechs"] = 100,
}

local function c2tf10(ruleRow,destTable)
    destTable[string.lower(ruleRow[0])] = (ruleRow[1] == "1")
end
local function c2toNum(ruleRow,destTable)
    destTable[string.lower(ruleRow[0])] = tonumber(ruleRow[1])
end
local function c2MakeRowTable(startIndex,endIndex)
    return function(ruleRow,destTable)
        local ruleRowIndex = 1
        local newTable = {}
        for i=startIndex,endIndex do
            newTable[i] = tonumber(ruleRow[ruleRowIndex])
            ruleRowIndex = ruleRowIndex+1
        end
        destTable[string.lower(ruleRow[0])] = newTable
    end
end
local function readMovement(ruleRow,destTable)
    destTable[string.lower(ruleRow[0])] = tonumber(ruleRow[2])
end




local cosmic2Instructions = {
["numberofunittypes"] = c2toNum,
["numberoftechs"] = c2toNum,
["impassableair"] = c2tf10,
["tradegoldmultiplier"] = c2toNum,
["tradesciencemultiplier"] = c2toNum,
["tradewondermultiplier"] = c2toNum,
["fortifydefense"] = c2toNum,
["fortressdefense"] = c2toNum,
["citywallsdefense"] = c2toNum,
["coastalfortressdefense"] = c2toNum,
["aegisvsairdefense"] = c2toNum,
["aegisvsmissiledefense"] = c2toNum,
["samdefense"] = c2toNum,
["sdidefense"] = c2toNum,
["terraindefenseforair"] = c2tf10,
["terraindefenseforsea"] = c2tf10,
["citypopulationlossattack"] = c2toNum,
["citypopulationlosscapture"] = c2toNum,
["unitshieldcolor"] = c2MakeRowTable(1,2),
["nostackkills"] = c2tf10,
["eventheapsize"] = c2MakeRowTable(1,2),
["navigableriversintercardinal"] = c2tf10,
["numberofterraintypes"] = c2MakeRowTable(0,3),
["numberofanimatedresources"] = c2MakeRowTable(0,3),
["noincrementalrushbuy"] = c2tf10,
["railroadmultiplier"] = readMovement,
["roadmultiplier"] = readMovement,
["rivermultiplier"] = readMovement,
["alpinemultiplier"] = readMovement,
["productioncarryover"] = c2tf10,
["lwpreserveveterancy"] = c2tf10,
["cityspritespertribe"] = c2tf10,
["cityspritespermap"] = c2tf10,
["aicapitalizationlimit"] = c2toNum,
["barbunitsupport"] = c2tf10,
["barboffensiveunitlimit"] = c2toNum,
["barbresearch"] = c2tf10,
["playabletribes"] = function(rR,dT) dT[string.lower(rR[0])] = flagStringToNumber(string.sub(rR[1],3,-1)) end,
["playabledifficulties"] = function(rR,dT) dT[string.lower(rR[0])] = flagStringToNumber(string.sub(rR[1],3,-1)) end,
}


local function initializeCosmic2()
    local outputTable = gen.copyTable(cosmic2Defaults)
    local cosmic2 = changeRules.currentlyAppliedRules["@COSMCI2"] or {}
    for _,ruleRow in pairs(cosmic2) do
        local rR0 = ruleRow[0]
        if type(rR0) == "string" and cosmic2Instructions[string.lower(rR0)] then
            cosmic2Instructions[string.lower(rR0)](ruleRow,outputTable)
        end
    end
    local mt = { 
        __index = function (t,k) 
            if cosmic2Instructions[string.lower(k)] then
                return rawget(t,string.lower(k)) 
            else
                error("changeRules module: @COSMIC2 doesn't have a key "..tostring(k))
            end end,
        __newindex = function(t,k,v)
            if cosmic2Instructions[string.lower(k)] then
                rawset(t,string.lower(k),v)
            else
                error("changeRules module: @COSMIC2 doesn't have a key "..tostring(k))
            end end,
        }
    setmetatable(outputTable,mt)
    return outputTable
end
local initialCosmic2 = initializeCosmic2()











local baseNewDefaultUnit, isDefaultUnit, metatableDefaultUnit = 
    gen.createDataType("DefaultUnit", {advancedFlags = intVDI, attack = intVDI, attacksPerTurn = intNilVDI,
        buildTransport = intVDI, cost = intVDI, defense = intVDI, domain = intVDI, expires = techVDI,
        firepower = intVDI, flags = intVDI, hitpoints = intVDI, id = intVDI, minimumBribe = intVDI,
        move = intVDI, name = stringVDI, nativeTransport = intVDI, notAllowedOnMap = intVDI, 
        prereq = prereqVDI, role = intVDI, range = intVDI, tribeMayBuild = intVDI, useTransport = intVDI},{},{},
        {id=true,name=true})
    
local unitTypeRowToKeyAUnits = {attack = toNum(5), cost = toNum(9), defense = toNum(6), domain = toNum(2), 
        expires = toTech(1), firepower = toNum(8), flags = flagStrToNum(13), hitpoints = toNum(7),
        move = toNum(3),  prereq = toTech(12), range = toNum(4), role = toNum(11), }

local unitTypeRowToKeyAUnits_Advanced = {advancedFlags = flagStrToNum(6), 
        buildTransport = flagStrToNum(3), minimumBribe = toNum(2),
        nativeTransport = flagStrToNum(5), notAllowedOnMap = flagStrToNum(1), 
        tribeMayBuild = flagStrToNum(0), useTransport = flagStrToNum(4)}


local function newDefaultUnit(id)
    if not civ.getUnitType(id) then
        return nil
    end
    local rulesTable = changeRules.currentlyAppliedRules
    local unitSection = rulesTable["@UNITS"]
    local advancedSection = rulesTable["@UNITS_ADVANCED"]
    local attacksSection = rulesTable["@ATTACKS"]
    local defaultUnit = {["id"]=id}
    applyRuleRow(defaultUnit,unitTypeRowToKeyAUnits,unitSection[id])
    applyRuleRow(defaultUnit,{name = getStr(0)},unitSection[id])
    applyRuleRow(defaultUnit,unitTypeRowToKeyAUnits_Advanced,advancedSection[id])
    -- if no attacks section, attacksPerTurn is nil
    defaultUnit["attacksPerTurn"] = attacksSection and tonumber(attacksSection[id//10][id%10])
    return baseNewDefaultUnit(defaultUnit)
end

local baseNewDefaultImprovement, isDefaultImprovement, metatableDefaultImprovement = 
    gen.createDataType("DefaultImprovement", {cantSell= boolVDI, cost = intVDI,
        id=intVDI,name=stringVDI,onCapture=intVDI,prereq=prereqVDI, upkeep=intVDI,},{},{},
        {id=true,name=true})

local improvementRowToKey = {cantSell = function(ruleRow) return (string.sub(ruleRow[4] or "00000000",-1,-1) == "1") end,
    cost = toNum(1), onCapture = function(ruleRow) return flagStringToNumber(string.sub(ruleRow[4] or "00000000",-3,-2)) end,
    prereq = toTech(3), upkeep = toNum(2)}

local function newDefaultImprovement(id)
    if not civ.getImprovement(id) then
        return nil
    end
    local rulesTable = changeRules.currentlyAppliedRules
    local improvementSection = rulesTable["@IMPROVE"]
    local defaultImprovement = {["id"]=id}
    applyRuleRow(defaultImprovement,improvementRowToKey,improvementSection[id])
    applyRuleRow(defaultImprovement,{name = getStr(0)},improvementSection[id])
    return baseNewDefaultImprovement(defaultImprovement)
end

local baseNewDefaultWonder, isDefaultWonder, metatableDefaultWonder = 
    gen.createDataType("DefaultWonder", {cost = intVDI, expires = techVDI, id = intVDI,
        name = stringVDI, prereq = prereqVDI,},{},{},{id=true,name=true})

local wonderRowToKeyImprove = {cost = toNum(1), --[[prereq = toTech(3),--]]}
    -- note prereq is get only in TOTPPv18
    -- when updating, 
local wonderRowToKeyEndWonder = {expires = toTech(0)}



local function newDefaultWonder(id)
    if not civ.getWonder(id) then
        return nil
    end
    local rulesTable = changeRules.currentlyAppliedRules
    local improvementSection = rulesTable["@IMPROVE"]
    local endWonderSection = rulesTable["@ENDWONDER"]
    local defaultWonder = {["id"]=id}
    applyRuleRow(defaultWonder,wonderRowToKeyImprove,improvementSection[id+40])
    --  remove prereq=toTech(3) when wonder.prereq is fixed to be set and not just get
    applyRuleRow(defaultWonder,{name = getStr(0),prereq = toTech(3),},improvementSection[id+40])
    applyRuleRow(defaultWonder,wonderRowToKeyEndWonder,endWonderSection[id])
    return baseNewDefaultWonder(defaultWonder)
end

local baseNewDefaultTech, isDefaultTech, metatableDefaultTech = 
    gen.createDataType("DefaultTech", {aiValue=intVDI, category = intVDI, epoch = intVDI,
    group = intVDI, id=intVDI, modifier=intVDI, name=stringVDI, prereq1 = prereqVDI,
    prereq2 = prereqVDI},{},{},{id=true,name=true})

local techRowToKeyCivilize = {aiValue=toNum(1), category = toNum(6), epoch = toNum(5),
    modifier=toNum(2), prereq1 = toTech(3), prereq2 = toTech(4)}

local techRowToKeyCivilize2 = {group = toNum(0)}

local function newDefaultTech(id)
    if not civ.getTech(id) then
        return nil
    end
    local rulesTable = changeRules.currentlyAppliedRules
    local civilizeSection = rulesTable["@CIVILIZE"]
    local civilize2Section = rulesTable["@CIVILIZE2"]
    local defaultTech = {["id"]=id}
    applyRuleRow(defaultTech,techRowToKeyCivilize,civilizeSection[id])
    applyRuleRow(defaultTech,{name = getStr(0)},civilizeSection[id])
    applyRuleRow(defaultTech,techRowToKeyCivilize2,civilize2Section[id])
    return baseNewDefaultTech(defaultTech)
end

local function getBaseTerrainID(baseTerrain)
    return 16*baseTerrain.map+baseTerrain.type
end
local function getTerrainID(terrain)
    return 16*3*terrain.map+3*terrain.type+terrain.resource
end

local baseTerrainAbbreviations = {
["Drt"] = 0, 
["Pln"] = 1, 
["Grs"] = 2, 
["For"] = 3, 
["Hil"] = 4, 
["Mou"] = 5, 
["Tun"] = 6, 
["Gla"] = 7, 
["Swa"] = 8, 
["Jun"] = 9, 
["Oce"] = 10, 
["Bbb"] = 11, 
["Ccc"] = 12, 
["Ddd"] = 13, 
["Eee"] = 14, 
["Fff"] = 15, 
}
local baseTerrainTypeToAbbreviations = {
[0]=   "Drt" , 
[1]=   "Pln" , 
[2]=   "Grs" , 
[3]=   "For" , 
[4]=   "Hil" , 
[5]=   "Mou" , 
[6]=   "Tun" , 
[7]=   "Gla" , 
[8]=   "Swa" , 
[9]=   "Jun" , 
[10]=  "Oce" ,  
[11]=  "Bbb" ,  
[12]=  "Ccc" ,  
[13]=  "Ddd" ,  
[14]=  "Eee" ,  
[15]=  "Fff" ,  

}

-- returns the base terrain of the relevant column of the rules (and relevant map)
-- or nil, if the entry isn't a baseTerrain abbreviation
local function toBaseTerrain(col,map)
    return function(ruleRow) return (baseTerrainAbbreviations[ruleRow[col]] and civ.getBaseTerrain(map,baseTerrainAbbreviations[ruleRow[col]])) end
end

--local function toBaseTerrain(col,map)
--    return function(ruleRow) 
--        if baseTerrainAbbreviations[ruleRow[col]] then
--            return civ.getBaseTerrain(map,baseTerrainAbbreviations[ruleRow[col]])
--        else
--            return nil
--        end
--    end
--end



local baseNewDefaultBaseTerrain, isDefaultBaseTerrain, metatableDefaultBaseTerrain = 
    gen.createDataType("DefaultBaseTerrain", {
    abbrev = stringVDI,
    canIrrigate = boolVDI,
    canMine = boolVDI,
    defense = intVDI,
    impassable = boolVDI,
    irrigateAI = intVDI,
    irrigateBonus = intVDI,
    irrigateTo = baseTerrainVDI,
    irrigateTurns = intVDI,
    map = intVDI,
    mineAI = intVDI,
    mineBonus = intVDI,
    mineTo = baseTerrainVDI,
    mineTurns = intVDI,
    moveCost = intVDI,
    name = stringVDI,
    transformTo = baseTerrainVDI,
    type = intVDI,
},{},{},{abbrev = true, map = true, name = true, type = true})

-- reads the entry of the column
-- if it is "no" (any case), false is returned,
-- otherwise, true is returned
local function noToFalse(col)
    return function(ruleRow) return not (string.lower(ruleRow[col]) == "no") end
end
-- reads the entry of the column
-- returns true if it is "yes" (any case)
-- false otherwise
local function yesToTrue(col)
    return function(ruleRow) return string.lower(ruleRow[col]) == "yes" end
end

local baseTerrainRowToKey0 = {
    canIrrigate = yesToTrue(6),
    canMine = yesToTrue(10),
    defense = toNum(2),
    impassable = yesToTrue(15),
    irrigateAI = toNum(9),
    irrigateBonus = toNum(7),
    irrigateTo = toBaseTerrain(6,0),
    irrigateTurns = toNum(8),
    mineAI = toNum(13),
    mineBonus = toNum(11),
    mineTo = toBaseTerrain(10,0),
    mineTurns = toNum(12),
    moveCost = toNum(1),
    transformTo = toBaseTerrain(14,0),
}
function console.printBaseTerrain(terrainID)
    local baseTer = civ.getBaseTerrain(0,terrainID)
    for key,_ in pairs(baseTerrainRowToKey0) do
        print(key,baseTer[key],type(baseTer[key]))
    end
end

local baseTerrainRowToKey1 = {
    canIrrigate = yesToTrue(6),
    canMine = yesToTrue(10),
    defense = toNum(2),
    impassable = yesToTrue(15),
    irrigateAI = toNum(9),
    irrigateBonus = toNum(7),
    irrigateTo = toBaseTerrain(6,1),
    irrigateTurns = toNum(8),
    mineAI = toNum(13),
    mineBonus = toNum(11),
    mineTo = toBaseTerrain(10,1),
    mineTurns = toNum(12),
    moveCost = toNum(1),
    transformTo = toBaseTerrain(14,1),
}

local baseTerrainRowToKey2 = {
    canIrrigate = yesToTrue(6),
    canMine = yesToTrue(10),
    defense = toNum(2),
    impassable = yesToTrue(15),
    irrigateAI = toNum(9),
    irrigateBonus = toNum(7),
    irrigateTo = toBaseTerrain(6,2),
    irrigateTurns = toNum(8),
    mineAI = toNum(13),
    mineBonus = toNum(11),
    mineTo = toBaseTerrain(10,2),
    mineTurns = toNum(12),
    moveCost = toNum(1),
    transformTo = toBaseTerrain(14,2),
}

local baseTerrainRowToKey3 = {
    canIrrigate = yesToTrue(6),
    canMine = yesToTrue(10),
    defense = toNum(2),
    impassable = yesToTrue(15),
    irrigateAI = toNum(9),
    irrigateBonus = toNum(7),
    irrigateTo = toBaseTerrain(6,3),
    irrigateTurns = toNum(8),
    mineAI = toNum(13),
    mineBonus = toNum(11),
    mineTo = toBaseTerrain(10,3),
    mineTurns = toNum(12),
    moveCost = toNum(1),
    transformTo = toBaseTerrain(14,3),
}

local bTRTK = {
    [0] = baseTerrainRowToKey0,
    [1] = baseTerrainRowToKey1,
    [2] = baseTerrainRowToKey2,
    [3] = baseTerrainRowToKey3,
}

local function newDefaultBaseTerrain(id)
    local w,h,maps = civ.getAtlasDimensions()
    local z = id//16
    local terrainType = id % 16
    if z > (maps-1) or terrainType > (initialCosmic2["numberofterraintypes"][z]-1) then
        return nil
    end
    local baseTerrainRowToKey = bTRTK[z]
    local terrainSuffix = tostring(z)
    if terrainSuffix == "0" then
        terrainSuffix = ""
    end
    local terrainRules = changeRules.currentlyAppliedRules["@TERRAIN"..terrainSuffix]
    local defaultBaseTerrain = {["type"] = terrainType, map = z, abbrev = baseTerrainTypeToAbbreviations[terrainType],}
    applyRuleRow(defaultBaseTerrain, baseTerrainRowToKey, terrainRules[terrainType])
    applyRuleRow(defaultBaseTerrain, {name=getStr(0)}, terrainRules[terrainType])
    return baseNewDefaultBaseTerrain(defaultBaseTerrain)
end

local baseNewDefaultTerrain, isDefaultTerrain, metatableDefaultTerrain = 
    gen.createDataType("DefaultBaseTerrain", {
        baseTerrain = baseTerrainVDI,
        food = intVDI,
        map = intVDI,
        name = stringVDI,
        resource = intVDI,
        shields = intVDI,
        trade = intVDI,
        type = intVDI,
    },{},{},{baseTerrain=true,map=true,name=true,resource=true,type=true})

local terrainRowToKey = {
    food = toNum(3),
    shields = toNum(4),
    trade = toNum(5),
}

local function newDefaultTerrain(id)
    local w,h,maps = civ.getAtlasDimensions()
    local z = id //(16*3)
    local terrainType = id % (16*3)
    terrainType = terrainType // 3
    local res = id % 3
    local numTerrain = initialCosmic2["numberofterraintypes"][z]
    if z > (maps-1) or terrainType > (numTerrain-1) then
        return nil
    end
    if terrainType == 2 and res > 0 then
        return nil
    end
    local terrainObject = civ.getTerrain(z,terrainType,res)
    local defaultTerrain = {
        baseTerrain = terrainObject.baseTerrain,
        map = z,
        resource = res,
        type = terrainType,
    }
    local terrainSuffix = tostring(z)
    if terrainSuffix == "0" then
        terrainSuffix = ""
    end
    local terrainRules = changeRules.currentlyAppliedRules["@TERRAIN"..terrainSuffix]
    applyRuleRow(defaultTerrain,terrainRowToKey,terrainRules[numTerrain*res+terrainType])
    applyRuleRow(defaultTerrain,{name=getStr(0)},terrainRules[numTerrain*res+terrainType])
    return baseNewDefaultTerrain(defaultTerrain)
end



local function createAuthoritativeDefaultRulesSubtable(newItemFn,minIndex,maxIndex)
    local outTable = {}
    for i=minIndex,maxIndex do
        outTable[i] = newItemFn(i)
    end
    return outTable
end

local rowNumberToCosmicKey = {
[16] = "communismPalaceDistance",
[ 2] = "foodEaten",
[ 3] = "foodRows",
[30] = "goodieHutsMask",
[31] = "helisPickupHuts",
[20] = "massThrustParadigm",
--[  ] = "numberOfUnitTypes",
[19] = "paradropRange",
[28] = "penaltyBetrayal",
[18] = "prodChangePenalty",
[ 8] = "riotFactor",
[ 0] = "roadMultiplier",
[17] = "scienceLostFundamentalism",
[21] = "scienceRateFundamentalism",
[24] = "scoreCentauri",
[22] = "scoreCitizen",
[27] = "scoreFutureTech",
[26] = "scorePeace",
[25] = "scorePollution",
[29] = "scoreUnitKilled",
[23] = "scoreWonder",
[ 6] = "settlersEatHigh",
[ 5] = "settlersEatLow",
[ 4] = "shieldRows",
[ 9] = "sizeAquaduct",
[10] = "sizeSewer",
[ 7] = "sizeUnhappiness",
[14] = "supportCommunism",
[15] = "supportFundamentalism",
[13] = "supportMonarchy",
[11] = "techParadigm",
[12] = "transformBase",
[ 1] = "triremeLost",
}

local function initializeCivCosmic()
    local cosmicTable = {}
    local rulesTable = changeRules.currentlyAppliedRules
    local cosmicSection = rulesTable["@COSMIC"]
    for i=0,29 do
        cosmicTable[rowNumberToCosmicKey[i]] = tonumber(cosmicSection[i][0])
    end
    cosmicTable[rowNumberToCosmicKey[30]] = flagStringToNumber(cosmicSection[30][0])
    cosmicTable[rowNumberToCosmicKey[31]] = tonumber(cosmicSection[31][0])
    cosmicTable["numberOfUnitTypes"] = initialCosmic2["numberofunittypes"]
    return cosmicTable
end

local function gcd(a,b)
    while b > 0 do
        a,b = b,a%b
    end
    return a
end
local function lcm(a,b)
    return a*b//gcd(a,b)
end

local function computeLCM(road,river,rail,alpine)
    return lcm(lcm(road,river),lcm(rail,alpine))
end

local function initializeMovementMultipliers()
    local hiddenKey = {}
    local mmTable = {
        [hiddenKey] = {
            road = initialCosmic2["roadmultiplier"],
            railroad = initialCosmic2["railroadmultiplier"],
            alpine = initialCosmic2["alpinemultiplier"],
            river = initialCosmic2["rivermultiplier"],
            aggregate = computeLCM(initialCosmic2["roadmultiplier"],
                initialCosmic2["rivermultiplier"],
                initialCosmic2["railroadmultiplier"],
                initialCosmic2["alpinemultiplier"])
        }
    }
    local mt = {
        __index = function(t,k)
            return t[hiddenKey][k]
        end,
        __newindex = function(t,k,v)
            if k == "aggregate" then
                error("changeRules.authoritativeDefaultRules: 'totpp.movementMultipliers': the value of the 'aggregate' key can't be set.  It is computed from other values.")
            elseif t[hiddenKey][k] then
                if type(v) ~= "number" or v ~= math.floor(v) then
                    error("changeRules.authoritativeDefaultRules: 'totpp.movementMultipliers': the value assigned to a key must be an integer.  Received: "..tostring(v))
                end
                t[hiddenKey][k] = v
                t[hiddenKey]["aggregate"] = computeLCM(t[hiddenKey]["road"],t[hiddenKey]["river"],t[hiddenKey]["railroad"],t[hiddenKey]["alpine"])
            else
                error("changeRules.authoritativeDefaultRules: 'totpp.movementMultipliers': the key "..tostring(k).." is invalid and so can't be set.")
            end
        end
    }
    setmetatable(mmTable,mt)
    return mmTable
end

local roadTradeAbbreviations = gen.copyTable(baseTerrainAbbreviations)
for i=0,15 do
    roadTradeAbbreviations[tostring(i)] = i
end

---@return bitmask
local function buildRoadTrade(z)
    local suffix = tostring(z)
    if suffix == "0" then
        suffix = ""
    end
    local terrainRules = changeRules.currentlyAppliedRules["@TERRAIN"..suffix]
    local roadTradeRules = changeRules.currentlyAppliedRules["@ROADTRADE"..suffix]
    local maskNum = 0
    -- if @ROADTRADE rules aren't there, the default of desert, plains, grassland is applicable
    if not roadTradeRules then
        return 7
    end
    for _,rulesRow in pairs(roadTradeRules) do
        local entry = rulesRow[0]
        if roadTradeAbbreviations[entry] then
            maskNum = maskNum | (1 << roadTradeAbbreviations[entry])
        else
            for i=0,15 do
                -- while there aren't always 16 base terrains, the terrain section
                -- will have more than 16 entries, due to specials, so we can check
                -- first 16 for names.  This could only cause an issue if a special
                -- name was submitted in the rules
                if terrainRules[i][0] == entry then
                    maskNum = maskNum | (1 << i)
                    break
                end
            end
        end
    end
    ---@cast maskNum bitmask
    return maskNum
end

local function initializeRoadTrade()
    local roadTradeTable = {}
    local w,h,maps = civ.getAtlasDimensions()
    for i=0,maps-1 do
        roadTradeTable[i] = buildRoadTrade(i)
    end
    local mt = {
        __index = function(t,k)
            if civ.isMap(k) then
                return t[k.id]
            else
                error("changeRules.authoritativeDefaultRules: 'totpp.roadTrade': The key must be a map id for a map in this game, or a map object.  Received: "..tostring(k))
            end
        end,
        __newindex = function(t,k,v)
            if civ.isMap(k) then
                t[k.id] = v
            else
                error("changeRules.authoritativeDefaultRules: 'totpp.roadTrade': The key must be a map id for a map in this game, or a map object.  Received: "..tostring(k))
            end
        end,
    }
    setmetatable(roadTradeTable,mt)
    return roadTradeTable
end


changeRules.authoritativeDefaultRules = {
    ["unitType"] = createAuthoritativeDefaultRulesSubtable(newDefaultUnit,0,civ.cosmic.numberOfUnitTypes-1),
    ["improvement"] = createAuthoritativeDefaultRulesSubtable(newDefaultImprovement,0,39),
    ["wonder"] = createAuthoritativeDefaultRulesSubtable(newDefaultWonder,0,27),
    ["tech"] = createAuthoritativeDefaultRulesSubtable(newDefaultTech,0,252),
    ["baseTerrain"] = createAuthoritativeDefaultRulesSubtable(newDefaultBaseTerrain,0,4*16-1),
    ["terrain"] = createAuthoritativeDefaultRulesSubtable(newDefaultTerrain,0,4*16*3-1),
    --["leader"] = {},
    ["civ.cosmic"] = initializeCivCosmic(),
    --["civ.game"] = {},
    --["civ.scen.params"] = {},
    ["totpp.roadTrade"] = initializeRoadTrade(),
    ["totpp.movementMultipliers"] = initializeMovementMultipliers(),
    ["cosmic2"] = initialCosmic2,
}

-- These variables make the first object check
-- the same kind of object as the last item processed
-- this is likely, if a loop is done
local lastFunction = function(key) return false end
local lastSubtableKey = ""

local fnKeyTable = {
    [civ.isUnitType] = "unitType",
    [civ.isImprovement] = "improvement",
    [civ.isWonder] = "wonder",
    [civ.isTech] = "tech",
    [civ.isBaseTerrain] = "baseTerrain",
    [civ.isTerrain] = "terrain",
    [civ.isLeader] = "leader",
}
local function getNonstandardID(key)
    if civ.isBaseTerrain(key) then
        return getBaseTerrainID(key)
    else
        return getTerrainID(key)
    end
end


local aDRMetatable = {
    __index = function(aDR,key)
        if lastFunction(key) then
            return aDR[lastSubtableKey][key.id or getNonstandardID(key)]
        end
        for fn, subtableKey in pairs(fnKeyTable) do
            if fn(key) then
                lastFunction = fn
                lastSubtableKey = subtableKey
                return aDR[subtableKey][key.id or getNonstandardID(key)]
            end
        end
        error("changeRules.authoritativeDefaultRules: the submitted key is invalid.  Received:"..tostring(key)) 
    end
}

setmetatable(changeRules.authoritativeDefaultRules,aDRMetatable)

console.defaults = changeRules.authoritativeDefaultRules
--[[
local defaults = console.defaults
local unit10 = civ.getUnitType(10)
for key,val in pairs(defaults[unit10]) do
    print(key,val)
end
print("\n\n\n")

local tech10 = civ.getTech(10)
for key,val in pairs(defaults[tech10]) do
    print(key,tostring(val))
end

print("\n\n\n")
local Improvement10 = civ.getImprovement(10)
for key,val in pairs(defaults[Improvement10]) do
    print(key,tostring(val))
end


print("\n\n\n")
local Wonder10 = civ.getWonder(10)
for key,val in pairs(defaults[Wonder10]) do
    print(key,tostring(val))
end

print("\n\n\n")
local BaseTerrain10 = civ.getBaseTerrain(0,10)
for key,val in pairs(defaults[BaseTerrain10]) do
    print(key,tostring(val))
end

print("\n\n\n")
local BaseTerrain9 = civ.getBaseTerrain(1,9)
for key,val in pairs(defaults[BaseTerrain9]) do
    print(key,tostring(val))
end

print("\n\n\n")
local Terrain10 = civ.getTerrain(0,10,1)
for key,val in pairs(defaults[Terrain10]) do
    print(key,tostring(val))
end

print("\n\n\n")
local Terrain9 = civ.getTerrain(1,9,2)
for key,val in pairs(defaults[Terrain9]) do
    print(key,tostring(val))
end

--]]

local updateUnitTypeRowToKeyAUnits_Advanced_noTransport = gen.copyTable(unitTypeRowToKeyAUnits_Advanced)
updateUnitTypeRowToKeyAUnits_Advanced_noTransport.buildTransport = nil
updateUnitTypeRowToKeyAUnits_Advanced_noTransport.useTransport = nil
updateUnitTypeRowToKeyAUnits_Advanced_noTransport.nativeTransport = nil

local function expectSection(rulesTable,sectionName,functionName)
    if not rulesTable[sectionName] then
        error("changeRules."..functionName..": the provided rules do not have a "..sectionName.." section.")
    end
end


local function updateUnit(id,unitSection,advancedSection,attacksSection,doNotChangeTransportSettings)
    local unitType = civ.getUnitType(id)
    if not unitType then
        return
    end
    local defaultUnitType = changeRules.authoritativeDefaultRules[unitType]
    applyRuleRow(defaultUnitType, unitTypeRowToKeyAUnits,unitSection[id])
    applyRuleRow(unitType, unitTypeRowToKeyAUnits,unitSection[id])
    applyRuleRow(defaultUnitType,unitTypeRowToKeyAUnits_Advanced,advancedSection[id])
    if doNotChangeTransportSettings then
        applyRuleRow(unitType,updateUnitTypeRowToKeyAUnits_Advanced_noTransport,advancedSection[id])
    else
        applyRuleRow(unitType,unitTypeRowToKeyAUnits_Advanced,advancedSection[id])
    end
    -- if the initial rules don't have an @ATTACKS section, unitType.attacksPerTurn is nil
    -- and can't be set.  So, don't change anything.
    if unitType.attacksPerTurn then
        defaultUnitType["attacksPerTurn"] = (attacksSection and tonumber(attacksSection[id//10][id%10])) or defaultUnitType["move"]
        unitType["attacksPerTurn"] = (attacksSection and tonumber(attacksSection[id//10][id%10])) or defaultUnitType["move"]
    end
    unitType.move = defaultUnitType["move"]*totpp.movementMultipliers.aggregate
end


-- changeRules.changeUnitTypeRules(rulesTable, doNotChangeTransportSettings = nil)
-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
-- updates changeRules.currentlyAppliedRules["@UNITS"],
--          changeRules.currentlyAppliedRules["@UNITS_ADVANCED"],
--          changeRules.currentlyAppliedRules["@ATTACKS"]
--              if no @ATTACKS section, attack limitations are set to default movement allowance
--              If initial rules didn't have an @ATTACKS section, unitType.attacksPerTurn can't
--              be set, so the section is ignored in changed rules
--  updates changeRules.authoritativeDefaultRules[unitType] for all unit types in the game
--
--  changes the unitType objects for all units in the game to reflect new rules
--
--  if doNotChangeTransportSettings is true, 
--      unitType.nativeTransport, unitType.buildTransport, unitType.useTransport
--  are not updated

function changeRules.changeUnitTypeRules(rulesTable, doNotChangeTransportSettings)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.unitTypeRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    expectSection(rulesTable,"@UNITS","changeUnitTypeRules")
    expectSection(rulesTable,"@UNITS_ADVANCED","changeUnitTypeRules")
    -- @ATTACKS doesn't have to exist
    changeRules.currentlyAppliedRules["@UNITS"] = rulesTable["@UNITS"]
    changeRules.currentlyAppliedRules["@UNITS_ADVANCED"] = rulesTable["@UNITS_ADVANCED"]
    changeRules.currentlyAppliedRules["@ATTACKS"]= rulesTable["@ATTACKS"]
    local unitSection = changeRules.currentlyAppliedRules["@UNITS"]
    local advancedSection =changeRules.currentlyAppliedRules["@UNITS_ADVANCED"] 
    local attacksSection = changeRules.currentlyAppliedRules["@ATTACKS"] 
    for i=0,civ.cosmic.numberOfUnitTypes-1 do
        updateUnit(i,unitSection,advancedSection,attacksSection,doNotChangeTransportSettings)
    end
end

local function updateImprovement(id,improvementSection)
    local improvementObject = civ.getImprovement(id)
    if not improvementObject then
        return 
    end
    local defaultImprovement = changeRules.authoritativeDefaultRules[improvementObject]
    applyRuleRow(defaultImprovement,improvementRowToKey,improvementSection[id])
    applyRuleRow(improvementObject,improvementRowToKey,improvementSection[id])
end

-- changeRules.changeImprovementRules(rulesTable)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      changes improvementObjects to correspond to the rules that rulesTable provides
--      updates changeRules.currentlyAppliedRules["@IMPROVE"]
--      updates changeRules.authoritativeDefaultRules[improvementObject]

function changeRules.changeImprovementRules(rulesTable)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeImprovementRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    expectSection(rulesTable,"@IMPROVE","changeImprovementRules")
    changeRules.currentlyAppliedRules["@IMPROVE"] = rulesTable["@IMPROVE"]
    local improvementSection = changeRules.currentlyAppliedRules["@IMPROVE"]
    for i=0,39 do
        updateImprovement(i,improvementSection)
    end
end

local function updateTech(id,civilizeSection,civilize2Section)
    local techObject = civ.getTech(id)
    if not techObject then
        return
    end
    local defaultTech = changeRules.authoritativeDefaultRules[techObject]
    applyRuleRow(defaultTech,techRowToKeyCivilize, civilizeSection[id])
    applyRuleRow(techObject,techRowToKeyCivilize, civilizeSection[id])
    applyRuleRow(defaultTech,techRowToKeyCivilize2, civilize2Section[id])
    applyRuleRow(techObject,techRowToKeyCivilize2, civilize2Section[id])
end

-- changeRules.changeTechRules(rulesTable)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      changes tech objects to correspond to the rules that the rulesTable provies
--      updates changeRules.currentlyAppliedRules["@CIVILIZE"]
--      updates changeRules.currentlyAppliedRules["@CIVILIZE2"]
--      updates changeRules.authoritativeDefaultRules[techObject]
--      (Note: a tech with a 'no' prereq can't be added to the tech tree via Lua,
--      however, the techOjbect and authoritativeDefaultRules will still be changed)

function changeRules.changeTechRules(rulesTable)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeTechRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    expectSection(rulesTable,"@CIVILIZE","changeTechRules")
    expectSection(rulesTable,"@CIVILIZE2","changeTechRules")
    changeRules.currentlyAppliedRules["@CIVILIZE"] = rulesTable["@CIVILIZE"]
    changeRules.currentlyAppliedRules["@CIVILIZE2"] = rulesTable["@CIVILIZE2"]
    local civilizeSection = changeRules.currentlyAppliedRules["@CIVILIZE"] 
    local civilize2Section = changeRules.currentlyAppliedRules["@CIVILIZE2"] 
    for i=0,changeRules.authoritativeDefaultRules["cosmic2"]["numberoftechs"]-1 do
        updateTech(i,civilizeSection,civilize2Section)
    end
end

local function updateBaseTerrain(map,type,terrainRules)
    local baseTerrain = civ.getBaseTerrain(map,type)
    if not baseTerrain then
        return
    end
    local baseTerrainRowToKey = bTRTK[map]
    local defaultBaseTerrain = changeRules.authoritativeDefaultRules[baseTerrain]
    applyRuleRow(defaultBaseTerrain,baseTerrainRowToKey,terrainRules[type])
    applyRuleRow(baseTerrain,baseTerrainRowToKey,terrainRules[type])
    -- due to assignment side effects for the pairs canIrrigate,irrigateTo
    -- and canMine,mineTo, are not assigned for baseTerrain by applyRuleRow
    local irrigateEntry = terrainRules[type][6]
    if baseTerrainAbbreviations[irrigateEntry] then
        baseTerrain.irrigateTo = civ.getBaseTerrain(map,baseTerrainAbbreviations[irrigateEntry])
    elseif string.lower(irrigateEntry) == "yes" then
        baseTerrain.canIrrigate = true
    elseif string.lower(irrigateEntry) == "no" then
        baseTerrain.canIrrigate = false
    else
        error("changeRules.changeTerrainRules: did not recognize the irrigation entry "..irrigateEntry.." for terrain "..baseTerrain.name)
    end
    local mineEntry = terrainRules[type][10]
    if baseTerrainAbbreviations[mineEntry] then
        baseTerrain.mineTo = civ.getBaseTerrain(map,baseTerrainAbbreviations[mineEntry])
    elseif string.lower(mineEntry) == "yes" then
        baseTerrain.canMine = true
    elseif string.lower(mineEntry) == "no" then
        baseTerrain.canMine = false
    else
        error("changeRules.changeTerrainRules: did not recognize the mining entry "..mineEntry.." for terrain "..baseTerrain.name)
    end
    -- setting baseTerrain.transformTo = nil actually results in baseTerrain.transformTo = desertBaseTerrain
    -- so, if a terrain is specified, set transformTo to that terrain
    -- if 'no' is specified, and transformTo is already nil, do nothing to preserve it
    -- if 'no' is specified, and transformTo is another terrainType, assign
    -- that baseTerrain as the transformTo value, as the best solution
    local transformEntry = terrainRules[type][14]
    if baseTerrainAbbreviations[transformEntry] then
        baseTerrain.transformTo = civ.getBaseTerrain(map,baseTerrainAbbreviations[transformEntry])
    elseif string.lower(transformEntry) == "no" then
        if baseTerrain.transformTo then
            baseTerrain.transformTo = baseTerrain
        end
    else
        error("changeRules.changeTerrainRules: did not recognize the transform entry "..transformEntry.." for terrain "..baseTerrain.name)
    end

end

local function updateTerrain(map,type,resource,terrainRules,numTerrain)
    if type == 2 and resource > 0 then
        return
    end
    local terrain = civ.getTerrain(map,type,resource)
    if not terrain then
        return
    end
    local defaultTerrain = changeRules.authoritativeDefaultRules[terrain]
    applyRuleRow(defaultTerrain, terrainRowToKey,terrainRules[numTerrain*resource+type])
    applyRuleRow(terrain, terrainRowToKey,terrainRules[numTerrain*resource+type])
end



-- changeRules.changeTerrainRules(rulesTable)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      changes terrain and baseTerrain objects to correspond to the rules that the rulesTable provies
--      updates changeRules.currentlyAppliedRules["@TERRAIN"]
--      updates changeRules.currentlyAppliedRules["@TERRAIN1"]/["@TERRAIN2"]/["@TERRAIN3"]
--      updates changeRules.authoritativeDefaultRules[baseTerrain]/[terrain]

function changeRules.changeTerrainRules(rulesTable)
    local w,h,maps = civ.getAtlasDimensions()
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeTerrainRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    for z = 0,maps-1 do
        local numTerrain = initialCosmic2["numberofterraintypes"][z]
        local terrainSuffix = tostring(z)
        if terrainSuffix == "0" then
            terrainSuffix = ""
        end
        local sectionName = "@TERRAIN"..terrainSuffix
        expectSection(rulesTable,sectionName,"changeTerrainRules")
        changeRules.currentlyAppliedRules[sectionName] = rulesTable[sectionName]
        local terrainRules = changeRules.currentlyAppliedRules[sectionName]
        for t=0,numTerrain-1 do
            updateBaseTerrain(z,t,terrainRules)
            for r=0,2 do
                updateTerrain(z,t,r,terrainRules,numTerrain)
            end
        end
    end
end

local cosmicKeyToDefenseModifierKey = {
["fortifydefense"] = "dFortified",
["fortressdefense"] = "dFortress",
["citywallsdefense"] = "dCityWalls",
["coastalfortressdefense"] = "dCoastalFortress",
["aegisvsairdefense"] = "dAegisFlagVsOtherAir",
["aegisvsmissiledefense"] = "dAegisFlagVsMissile",
["samdefense"] = "dSamMissileBattery",
["sdidefense"] = "dSdiDefenseVsMissile",
["terraindefenseforair"] = "dTerrainDefenseForAir",
["terraindefenseforsea"] = "dTerrainDefenseForSea",
}

local movementMultiplierCosmicKeys = {
["railroadmultiplier"] = "railroad",
["roadmultiplier"] = "road",
["rivermultiplier"] = "river",
["alpinemultiplier"] = "alpine",
}


local updatableCosmic2Keys = {
["fortifydefense"] = true,
["fortressdefense"] = true,
["citywallsdefense"] = true,
["coastalfortressdefense"] = true,
["aegisvsairdefense"] = true,
["aegisvsmissiledefense"] = true,
["samdefense"] = true,
["sdidefense"] = true,
["terraindefenseforair"] = true,
["terraindefenseforsea"] =true,
["railroadmultiplier"] = true,
["roadmultiplier"] = true,
["rivermultiplier"] = true,
["alpinemultiplier"] = true,

}



-- combatCalculator.setCombatModifier(modifierName,value)
    
-- changeRules.changeCosmic2Rules(rulesTable,allowEmpty=nil)
--      if rulesTable is a string, readRules.readRules is first applied to get a rules table
--      updates changeRules.currentlyAppliedRules["@COSMIC2"]
--          replaces the line with the same key in the 0 column
--      updates changeRules.authoritativeDefaultRules["cosmic2"]["keyInNewRules"]
--      Note: if a key is omitted from the newly provided @COSMIC2 section, the previously
--      registered value is still used;
--      Note: If a key can't be changed with Lua, it is not updated in
--      changeRules.currentlyAppliedRules or changeRules.authoritativeDefaultRules
--      If the rules provided do not have a @COSMIC2 section, and allowEmpty is true
--      an empty table is used instead, so no error is triggered
--      if any movement multipliers are updated, all unit types have their movement 
--      updated as well.

local function getReplacedRow(zeroColumn)
    for id =0,#changeRules.currentlyAppliedRules["@COSMIC2"] do
        local row = changeRules.currentlyAppliedRules["@COSMIC2"][id]
        if type(row[0]) == "string" then
            if string.lower(row[0]) == string.lower(zeroColumn) then
                return id
            end
        else
            -- if we get here, we've passed the last line of the section
            -- that is not empty
            return id
        end
    end
    return 1+ #changeRules.currentlyAppliedRules["@COSMIC2"]
end

function changeRules.changeCosmic2Rules(rulesTable,allowEmpty)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeCosmic2Rules: expected table or string.  Received: "..tostring(rulesTable))
    end
    local cosmic2Table = rulesTable["@COSMIC2"]
    if allowEmpty then
        cosmic2Table = cosmic2Table or {}
    else
        expectSection(rulesTable,"@COSMIC2","changeCosmic2Rules")
    end
    local movementUpdate = false
    for _,rulesRow in pairs(cosmic2Table) do
        local rR0 = rulesRow[0]
        if type(rR0)=="string" and updatableCosmic2Keys[string.lower(rR0)] then
            local lowerRR0 = string.lower(rR0)
            cosmic2Instructions[lowerRR0](rulesRow,changeRules.authoritativeDefaultRules["cosmic2"])
            changeRules.currentlyAppliedRules["@COSMIC2"][getReplacedRow(rR0)] = rulesRow
            if cosmicKeyToDefenseModifierKey[lowerRR0] then
                local val = changeRules.authoritativeDefaultRules["cosmic2"][lowerRR0]
                if type(val) == "number" then
                    combatCalculator.setCombatModifier(cosmicKeyToDefenseModifierKey[lowerRR0],val/2)
                else
                    combatCalculator.setCombatModifier(cosmicKeyToDefenseModifierKey[lowerRR0],val)
                end
            elseif movementMultiplierCosmicKeys[lowerRR0]  then
                movementUpdate = true
                changeRules.authoritativeDefaultRules["totpp.movementMultipliers"][movementMultiplierCosmicKeys[lowerRR0]]
                    = changeRules.authoritativeDefaultRules["cosmic2"][lowerRR0]
            end
        end
    end
    if movementUpdate then
        totpp.movementMultipliers.road = changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]["road"]
        totpp.movementMultipliers.railroad = changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]["railroad"]
        totpp.movementMultipliers.river = changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]["river"]
        totpp.movementMultipliers.alpine = changeRules.authoritativeDefaultRules["totpp.movementMultipliers"]["alpine"]
        for unitID=0,civ.cosmic.numberOfUnitTypes-1 do
            local unitType = civ.getUnitType(unitID)
            unitType.move = changeRules.authoritativeDefaultRules[unitType]["move"]*totpp.movementMultipliers.aggregate
        end
    end
end

-- changeRules.changeCosmicRules(rulesTable)
-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
-- updates changeRules.currentlyAppliedRules["@COSMIC"],
-- updates changeRules.authoritativeDefaultRules["civ.cosmic"]
--      note: civ.cosmic.roadMultiplier is never changed
--
function changeRules.changeCosmicRules(rulesTable)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.unitTypeRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    expectSection(rulesTable,"@COSMIC","changeCosmicRules")
    changeRules.currentlyAppliedRules["@COSMIC"] = rulesTable["@COSMIC"]
    local cosmicSection = changeRules.currentlyAppliedRules["@COSMIC"]
    local cosmicTable = changeRules.authoritativeDefaultRules["civ.cosmic"]
    -- road multiplier, no game change, so outside loop
    cosmicTable[rowNumberToCosmicKey[0]] = tonumber(cosmicSection[0][0])
    for i=1,29 do
        cosmicTable[rowNumberToCosmicKey[i]] = tonumber(cosmicSection[i][0])
        civ.cosmic[rowNumberToCosmicKey[i]] = cosmicTable[rowNumberToCosmicKey[i]]
    end
    cosmicTable[rowNumberToCosmicKey[30]] = flagStringToNumber(cosmicSection[30][0])
    civ.cosmic[rowNumberToCosmicKey[30]] = cosmicTable[rowNumberToCosmicKey[30]]
    cosmicTable[rowNumberToCosmicKey[31]] = tonumber(cosmicSection[31][0])
    civ.cosmic[rowNumberToCosmicKey[31]] = cosmicTable[rowNumberToCosmicKey[31]]
    --(number of unit types can't be set)
end

-- changeRules.changeRoadTrade(rulesTable)
-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
-- updates changeRules.currentlyAppliedRules["@ROADTRADE"],
-- updates changeRules.currentlyAppliedRules["@ROADTRADE1"], (if applicable)
-- updates changeRules.currentlyAppliedRules["@ROADTRADE2"], (if applicable)
-- updates changeRules.currentlyAppliedRules["@ROADTRADE3"], (if applicable)
-- updates changeRules.authoritativeDefaultRules["totpp.roadTrade"]
-- updates totpp.roadTrade
--  if the rules do not have an @ROADTRADE section, the defaults of
--  road trade only on desert, plains, and grassland are implemented
function changeRules.changeRoadTradeRules(rulesTable)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeRoadTradeRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    changeRules.currentlyAppliedRules["@ROADTRADE"] = rulesTable["@ROADTRADE"]
    changeRules.currentlyAppliedRules["@ROADTRADE1"] = rulesTable["@ROADTRADE1"]
    changeRules.currentlyAppliedRules["@ROADTRADE2"] = rulesTable["@ROADTRADE2"]
    changeRules.currentlyAppliedRules["@ROADTRADE3"] = rulesTable["@ROADTRADE3"]
    local w,h,maps = civ.getAtlasDimensions()
    for i=0,maps-1 do
        local roadTradeResult = buildRoadTrade(i)
        changeRules.authoritativeDefaultRules["totpp.roadTrade"][i] = roadTradeResult
        totpp.roadTrade[i]=roadTradeResult
    end
end

local function updateWonder(id)
    local wonderObject = civ.getWonder(id)
    if not wonderObject then
        return nil
    end
    local rulesTable = changeRules.currentlyAppliedRules
    local improvementSection = rulesTable["@IMPROVE"]
    local endWonderSection = rulesTable["@ENDWONDER"]
    local defaultWonder = changeRules.authoritativeDefaultRules[wonderObject]
    applyRuleRow(defaultWonder,wonderRowToKeyImprove,improvementSection[id+40])
    applyRuleRow(wonderObject,wonderRowToKeyImprove,improvementSection[id+40])
    applyRuleRow(defaultWonder,wonderRowToKeyEndWonder,endWonderSection[id])
    applyRuleRow(wonderObject,wonderRowToKeyEndWonder,endWonderSection[id])
end

function changeRules.changeWonderRules(rulesTable)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeWonderRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    expectSection(rulesTable,"@IMPROVE","changeImprovementRules")
    changeRules.currentlyAppliedRules["@IMPROVE"] = rulesTable["@IMPROVE"]
    changeRules.currentlyAppliedRules["@ENDWONDER"] = rulesTable["@ENDWONDER"]
    for i=0,27 do
        updateWonder(i)
    end
end


-- if rulesTable is a string, readRules.readRules is first applied to get a rules table
function changeRules.changeAllRules(rulesTable,doNotChangeTransportSettings)
    if type(rulesTable) == "string" then
        rulesTable = gen.getScenarioDirectory().."\\"..rulesTable
        rulesTable = readRules.readRules(rulesTable)
    end
    if type(rulesTable) ~= "table" then
        error("changeRules.changeAllRules: expected table or string.  Received: "..tostring(rulesTable))
    end
    changeRules.changeUnitTypeRules(rulesTable,doNotChangeTransportSettings)
    changeRules.changeImprovementRules(rulesTable)
    changeRules.changeWonderRules(rulesTable)
    changeRules.changeTechRules(rulesTable)
    changeRules.changeTerrainRules(rulesTable)
    changeRules.changeCosmic2Rules(rulesTable,true)
    changeRules.changeCosmicRules(rulesTable)
    changeRules.changeRoadTradeRules(rulesTable)
end


--function console.differences()
--    local bt = {}
--    for z=0,1 do
--        bt[z] = {}
--        for t = 0,10 do
--            bt[z][t] ={}
--            local baseTer = civ.getBaseTerrain(z,t)
--            for key,_ in pairs(baseTerrainRowToKey0) do
--                bt[z][t][key] = baseTer[key]
--            end
--        end
--    end
--    changeRules.changeTerrainRules("Rules.txt")
--    for z=0,1 do
--        for t = 0,10 do
--            local baseTer = civ.getBaseTerrain(z,t)
--            for key,_ in pairs(baseTerrainRowToKey0) do
--                if bt[z][t][key] ~= baseTer[key] then
--                    print(baseTer.name,key,superstring(bt[z][t][key]),superstring(baseTer[key]))
--                end
--            end
--        end
--    end
--    print("differences complete")
--end
--
--function console.printBaseTerrain(map,terrainID)
--    local baseTer = civ.getBaseTerrain(map,terrainID)
--    for key,_ in pairs(baseTerrainRowToKey0) do
--        print(key,baseTer[key],type(baseTer[key]))
--    end
--end



if _G.console then
    _G.console.changeRules= changeRules
end

gen.versionFunctions(changeRules,versionNumber,fileModified,"LuaCore".."\\".."readRules.lua")
return changeRules
