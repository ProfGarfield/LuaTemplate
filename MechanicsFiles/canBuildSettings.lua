
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



local object = require("object")
local canBuildFunctions = require("canBuild"):minVersion(2)

-- canBuildParameters
--      Three tables, one for unitTypes, one for Improvements, one for Wonders
--      absent entry means use the defaultCanBuild function
-- canBuildObjectType[item.id]= {
--      .forbiddenTribes = {[tribeID]=bool}
--          if canBuildObjectType[item.id].forbiddenTribes[tribeID] is true, then the tribe with
--          tribeID can't build item, false or nil/absent means it can
--              
--              Alternate Usage
--          .forbiddenTribes = tribeObject or table of tribeObjects
--          if tribeObject is in the table, that tribe can't build the item
--
--      .forbiddenMaps = {[0] = bool,[1]=bool,[2]=bool,[3]=bool}
--          if canBuildObjectType[item.id].forbiddenMaps[mapCityIsOn] = true, then city can't build the item
--              false or nil means it can
--          absent means all maps are allowed
--
--              Alternate Usage
--              .forbiddenMaps = mapObject or table of mapObjects
--              if mapObject is in the table, the object can't be built by cities on that map
--
--      .location = {xCoord,yCoord} or {xCoord,yCoord,zCoord} or tileObject or cityObject or integer or function(tileObject)-->boolean or table of these kinds of objects
--          {xCoord,yCoord} if the city is located at (xCoord,yCoord) on any map, it can build the object
--          {xCoord,yCoord,zCoord} means the city must be located at those coordinates to build the object
--          tileObject means the city must be located at that tile
--          cityObject means the city must be that city
--          function means object can be built if function(city.location) returns true 
--          (and all other conditions are met), and can't be built otherwise
--          table of these things means that each entry in the table is checked, and if any one of them means the object can be built, then it can be built
--          absent means the object can be built at any location
--          (Note: Can't use integers to match city id, since code can't distinguish between several cities and a coordinate triple)
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .forbiddenLocation= {xCoord,yCoord} or {xCoord,yCoord,zCoord} or tileObject or cityObject or function(tileObject)-->boolean or table of these kinds of objects
--              see location details, except that a match in forbidden location prevents the item from being buitl
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .allImprovements = improvementObject or wonderObject or table of improvementObjects and wonderObjects
--          The city must have all improvements/wonders in the table to build the object
--          absent means no improvements needed (in this section)
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .someImprovements = improvementObject or wonderObject or table of improvementObjects and wonderObjects
--          The city must have some number of objects in the table to build the item in question.  The exact
--          number is governed by the next key
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfImprovements = integer
--          tells how many of the 'someImprovements' are needed to build the item
--          absent means ignore .someImprovements
--      .forbiddenImprovements = improvementObject or wonderObject or table of improvementObjects and wonderObjects
--          The city must have none of the improvements/wonders in the table to build the object
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .allTechs = technologyObject or table of technologyObjects
--          the civ must have all the technologies in the table to build the object
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .someTechs = technologies or table of technologyObjects
--          the civ must have some of the technologies in the table to build the object
--          the number is governed by the next key
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfTechs = integer
--          tells how many of the 'someTechs' are needed for the object to be built
--      .forbiddenTechs = technologyObject or table of technologyObjects
--          the civ must not have any of the technologies in the table to build the object
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .allFlagsMatch = {[flagKey]=boolean}
--          the city can only build the item if all the flags for the flagKeys in the table have the  
--          corresponding value
--          absent flag key (including [flagKey]=nil) doesn't affect production
--          absent means no restriction
--      .someFlagsMatch = {[flagKey]=boolean}
--          the city can only build the item if all the flags for the flagKeys in the table have the  
--          corresponding value
--          absent flag key (including [flagKey]=nil) doesn't affect production
--          absent means no restriction
--      .numberOfFlags = integer
--          tells how many of the 'someFlags' are needed for the object to be built
--      .minimumPopulation = integer
--          the city must have at least this many citizens to build the item
--          absent means 0
--      .maximumPopulation = integer 
--          the city can have at most this many citizens to build the item
--          absent means no maximum population
--      .earliestTurn = integer
--          item can't be built before this turn
--          absent means no restriction
--      .latestTurn = integer
--          item can't be built after this turn
--          absent means no restriction
--      .allWonders = wonderObject or table of wonderObject
--          the city's tribe must have all these wonders in order to build the item
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .someWonders = wonderObject or table of wonderObject
--          the city's tribe must have some of the wonders in order to build the item
--          the number is governed by the next key
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfWonders = integer
--          tells how many of 'someWonders' the tribe must have to build the item
--          absent means no restriction
--
--
--      .overrideDefaultBuildFunction = boolean or nil
--          if true, the in game function for determining if the item can be built is ignored
--          for improvements and wonders, a check will be made if the item has already been built
--          false, nil, absent means the game's regular conditions must also be met
--      .forbiddenAlternateProduction = unitTypeObject or imprvementObject or wonderObject or table of these objects
--          the city can only build the item if city:canBuild(item) returns false for all items in the list
--          Be careful that the 'can build chain' does not form a loop
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .requireSomeAsAlternateProduction = unitTypeObject or improvementObject or wonderObject or table of these objects
--          the city can only build the item if the city can build some of the items in the list
--          Be careful that the 'can build chain' does not form a loop
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfAlternateProduction = integer
--          tells how many of 'someAlternateProduction' is required
--          absent means no restriction
--      .conditionFunction = function(defaultBuildFunction,city,item) --> bool
--          if function returns true, item can be built if other conditions are met, if false, item can't be built
--          absent means no extra condition
--      .returnFalse = bool or nil
--          if true, item can't be built
--          if false or nil, refer to other conditions
--          (happens before overrideFunction and alternateParameters)
--      .overrideFunction = function(defaultBuildFunction,city,item) --> boolean
--          if function returns true, the city is automatically allowed to build the item, regardless of any
--          conditions that isn't met
--          if function returns false, the other conditions are checked
--      .alternateParameters = table of itemParameters
--          itemParameters is this table of restrictions on whether a given item can be produced
--          if the item in question satisfies any of the itemParameters in the table, it can be produced,
--          regardless of whether the 'top' itemParameters are satisfied
--          use this (or overrideFunction) if you want to have more than one valid way to produce the item
--          the 'table' format is important.  Unlike other parameters, you must enclose the value of 
--          alternateParameters in a table, even if there is only one itemParameters as the value
--      .computerOnly = bool or nil
--          if true, item can only be built by computer controlled players
--          if false or nil, either human or AI players can build
--          (in conjunction with alternateParameters, this can be used to have different conditions for the
--          ai and human players)
--      .humanOnly = bool or nil
--          if true, item can only be built by human controlled players
--          if false or nil, either human or AI players can build
--          (in conjunction with alternateParameters, this can be used to have different conditions for the
--          ai and human players)
--
--      .onlyBuildCoastal = bool or nil
--          if true, the item can only be built if the city has the 'coastal' flag,
--          that is, in the default game it could build harbors and offshore platforms
--      .onlyBuildShips = bool or nil
--          if true, the item can only be built if the city has the 'ship building' flag
--          that is, in the default game it could build sea units
--      .onlyBuildHydroPlant = bool or nil
--          if true, the item can only be built if the city has the 'can build hydro plant' flag
--          that is, the city could build hydro plants in the default game
--
--      .maxNumberTribe = nil or integer or table with the keys and values specified below
--                          or function(tribe,item) --> number
--          if nil, there is no maximum number of the item that can be built
--          if integer, the number is the maximum of the item that can be built by that tribe
--          if function, the returned value is the number of the item the tribe can build
--          if table, consider these keys and values, rounding down at the end of the calculation
--          .base = number or nil
--              base number 
--              nil means 0
--          .max = number or nil
--              maximum number even if calculation would be larger
--              nil means no limit
--          .min = number or nil
--              minimum number even if calculation would be larger
--              nil means no limit
--          .turn = number or nil
--              increment limit by the value each turn
--              nil means no change
--          .tribeTotals = nil or {[luaObject or "cities" or "population"] = number or nil}
--              for each luaObject the tribe owns, increment the limit by the corresponding value
--              nil means 0
--              if unitType, increment by the number of units owned
--              if improvement, increment by the number of cities that have that improvement
--              if wonder, increment if the wonder is owned by the tribe
--              if technology, increment if tribe has the technology
--              if tribe, increment by value if the tribeObject is the tribe building the object
--              if "cities", increment for each city owned by the tribe
--              if "population", increment for each population point of the tribe
--
--          .globalTotals = nil or {[luaObject or "cities" or "population"] = number or nil}
--              for each luaObject in the world, increment the limit by the corresponding value
--              nil means 0
--              if unitType, increment by the number of units owned by all players
--              if improvement, increment by the number of cities that have that improvement among all players
--              if wonder, increment if the wonder is owned by any tribe
--              if technology, increment for each tribe that has the technology
--              if tribe, increment by value if the tribeObject is active in the game
--              if "cities", increment for each city in the game
--              if "population", increment for each population point of all cities in the game
--          
--          .activeWondersTribe = nil or  {[wonderObject] = number or nil}
--              if the tribe owns the wonder, and it is not expired, add the increment
--          .activeWondersForeign = nil or  {[wonderObject] = number or nil}
--              if another tribe owns the wonder, and it is not expired, add the increment
--          .discoveredTechs = nil or {[techObject] = number or nil}
--              if the tech is discovered by any tribe, add the increment
--          .trueFlags = nil or {[flagKey] = number or nil}
--              if the flag associated with flagKey is true, add the value to the production limit
--          .counterValues = nil or {[counterKey] = number or nil}
--              for each counter specified by counterKey, multiply the value of the counter by the
--              number specified, and add that product to the production limit
--          .customFunction = nil or function(tribe,item) -> number
--              if a function is provided, add the output of the function to the production limit
--
--      .tribeJointMaxWith  = nil or {[luaObject] = number or nil}
--              each of the tribe's instance of luaObject in the table uses up a portion of the ownership
--              limit for the item in question, with that portion given by the value
--              e.g. unitTypeBuild[object.uSettlers.id] = {maxNumberTribe = 6, 
--                  tribeJointMaxWith = {[object.uEngineers]=2}}
--              and unitTypeBuild[object.uEngineers.id] = {maxNumberTribe = 3,
--                  tribeJointMaxWith = {[object.uSettlers] = 0.5}}
--              Here, the limit is 6 settlers, or 3 engineers, with an engineer using up 2 settler
--              allotments, and a settler using up 0.5 engineer allotments.
--              By default, the item we're checking if we can produce is given a cost of 1,
--              but we can specify a different number instead.  Here is another way to have
--              6 settlers or 3 engineers:
--              e.g. unitTypeBuild[object.uSettlers.id] = {maxNumberTribe = 6, 
--                  tribeJointMaxWith = {[object.uSettlers] = 1, [object.uEngineers]=2}}
--              and unitTypeBuild[object.uEngineers.id] = {maxNumberTribe = 6,
--                  tribeJointMaxWith = {[object.uSettlers] = 1, [object.uEngineers]=2}}
--              
--
--
--      .maxNumberGlobal = nil or integer or table with the keys and values specified below
--                          or function(tribe,item) --> number
--          if nil, there is no maximum number of the item that can be built
--          if integer, the number is the maximum of the item that can be built by all tribes together
--          if function, the returned value is the number of the item that can be built in the world
--          if table, consider these keys and values, rounding down at the end of the calculation
--          for the maximum number for all tribes together
--          .base = integer or nil
--              base number 
--              nil means 0
--          .max = integer or nil
--              maximum number even if calculation would be larger
--              nil means no limit
--          .min = integer or nil
--              minimum number even if calculation would be larger
--              nil means no limit
--          .turn = number or nil
--              increment limit by the value each turn
--              nil means no change
--          .globalTotals = nil or {[luaObject or "cities" or "population"] = number or nil}
--              for each luaObject in the world, increment the limit by the corresponding value
--              nil means 0
--              if unitType, increment by the number of units owned by all players
--              if improvement, increment by the number of cities that have that improvement among all players
--              if wonder, increment if the wonder is owned by any tribe
--              if technology, increment for each tribe that has the technology
--              if tribe, increment by value if the tribeObject is active in the game
--              if "cities", increment for each city in the game
--              if "population", increment for each population point of all cities in the game
--          
--          .activeWonders = nil or {[wonderObject] = number or nil}
--              if the wonder is built and it is not expired, add the increment
--          .discoveredTechs = nil or {[techObject] = number or nil}
--              if the tech is discovered by any tribe, add the increment
--          .trueFlags = nil or {[flagKey] = number or nil}
--              if the flag associated with flagKey is true, add the value to the production limit
--          .counterValues = nil or {[counterKey] = number or nil}
--              for each counter specified by counterKey, multiply the value of the counter by the
--              number specified, and add that product to the production limit
--          .customFunction = nil or function(tribe,item) -> number
--              if a function is provided, add the output of the function to the production limit
--
--      .globalJointMaxWith  = nil or {[luaObject] = number or nil}
--              each instance of luaObject in the table uses up a portion of the ownership
--              limit for the item in question, with that portion given by the value
--              e.g. unitTypeBuild[object.uSettlers.id] = {maxNumberGlobal = 6, 
--                  globalJointMaxWith = {[object.uEngineers]=2}}
--              and unitTypeBuild[object.uEngineers.id] = {maxNumberGlobal = 3,
--                  globalJointMaxWith = {[object.uSettlers] = 0.5}}
--              Here, the limit is 6 settlers, or 3 engineers, with an engineer using up 2 settler
--              allotments, and a settler using up 0.5 engineer allotments.
--              By default, the item we're checking if we can produce is given a cost of 1,
--              but we can specify a different number instead.  Here is another way to have
--              6 settlers or 3 engineers:
--              e.g. unitTypeBuild[object.uSettlers.id] = {maxNumberGlobal = 6, 
--                  globalJointMaxWith = {[object.uSettlers] = 1, [object.uEngineers]=2}}
--              and unitTypeBuild[object.uEngineers.id] = {maxNumberGlobal = 6,
--                  globalJointMaxWith = {[object.uSettlers] = 1, [object.uEngineers]=2}}
--              
--
--      .ignoreSupplementalConditions = bool or nil
--          if true, ignore any supplemental conditions for this item that have been registered by
--          canBuildFunctions.registerSupplementalCondition(itemType,
--              function(defaultBuildFunction,city,item) --> bool)
--          (Other modules may use the above function to register special building restrictions
--              due to unique features (e.g. strategic bombing module might prevent building a
--              factory if there is no tile for the target))
--              note: due to the implementation, the supplemental functions will still be computed
--
--              to disable the supplemental conditions (including computation of them) 
--              for all items (perhaps because they cause lag),
--              you can uncomment the line canBuildFunctions.disableSupplementalConditions()
--              found at the bottom of this file

--

local unitTypeBuild = {}
local improvementBuild = {}
local wonderBuild = {}
local addBuildConditions = canBuildFunctions.makeAddBuildConditions(unitTypeBuild,improvementBuild,wonderBuild)
-- addBuildConditions(item,buildabilityParameters)
--      adds the buildabilityParameters to the appropriate table and index for item.  If the item
--      already has buildabilityParameters registered, the new set of parameters are automatically
--      added to the alternateParameters table
-- addBuildConditions(tableOfItems,buildabilityParameters)
--      for each item in the table, register the buildability parameters as above






























-- canBuildFunctions.hideProcessingList() -- uncomment if you don't want the list of stuff being processed printed in the console

canBuildFunctions.supplyUnitTypeParameters(unitTypeBuild)
canBuildFunctions.supplyImprovementParameters(improvementBuild)
canBuildFunctions.supplyWonderParameters(wonderBuild)


-- constructionStatistics
-- These tables are updated every time the unit type with id 0 (settler slot)
-- is checked if it can be built.  The 'tribe' here is the tribe to which the
-- city under consideration belongs.
-- These tables are used for the supplied production limit functionality with tables,
-- though you may find it convenient to leverage them in your own functions.
-- For example, to check how many Aqueducts the tribe checking buildability has, 
-- you would write
--      canBuildFunctions.tribeImprovementsOwnedByID[object.uAqueduct.id]
-- or, to find out how many aqueducts are owned by all tribes together, you would use 
--      canBuildFunctions.globalImprovementsOwnedByID[object.uAqueduct.id]
--
--canBuildFunctions.tribeCities = 0
--canBuildFunctions.globalCities = 0
--canBuildFunctions.tribePopulation = 0
--canBuildFunctions.globalPopulation = 0
--canBuildFunctions.tribeUnitsOwnedByTypeID = {}
--canBuildFunctions.globalUnitsOwnedByTypeID = {}
--canBuildFunctions.tribeImprovementsOwnedByID = {}
--canBuildFunctions.globalImprovementsOwnedByID = {}
--canBuildFunctions.tribeUnitsUnderConstructionByTypeID = {}
--canBuildFunctions.globalUnitsUnderConstructionByTypeID = {}
--canBuildFunctions.tribeImprovementsUnderConstructionByID = {}
--canBuildFunctions.globalImprovementsUnderConstructionByID = {}
--canBuildFunctions.tribeWondersOwnedByID = {}
--canBuildFunctions.globalWondersOwnedByID = {}
--canBuildFunctions.tribeActiveWondersOwnedByID = {}
--canBuildFunctions.globalActiveWondersOwnedByID = {}
--canBuildFunctions.tribeWondersUnderConstructionByID = {}
--canBuildFunctions.globalWondersUnderConstructionByID = {}
--canBuildFunctions.globalTechOwnershipByID = {}
--
-- To disable this "initialization" (perhaps because it is causing noticeable lag), uncomment
-- the next line:
-- canBuildFunctions.disableAutomaticBuildConstructionStatistics()
-- You can add additional initialization instructions (even if the above line is run) with the
-- following function:
local function initialization(city)

end

-- disable the registered supplemental build conditions for all items by
-- uncommenting the line below
--canBuildFunctions.disableSupplementalConditions()
canBuildFunctions.supplyInitializationFunction(initialization)

local canBuildSettings = {}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(canBuildSettings,versionNumber,fileModified,"MechanicsFiles".."\\".."canBuildSettings.lua")

return canBuildSettings

