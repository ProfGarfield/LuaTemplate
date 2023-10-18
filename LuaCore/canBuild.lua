local versionNumber = 3
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


---@module "data"
local data = require("data"):minVersion(2)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
local canBuildVersion = versionNumber


-- canBuildFunctions.registerSupplementalCondition(itemType,function(defaultBuildFunction,city,item) --> bool)
--      registers a function for itemType with the same effect as the conditionFunction
--      .conditionFunction = function(defaultBuildFunction,city,item) --> bool
--      that is, if it returns false, the item can't be built.  If it returns true, the item
--      can be built as long as all other conditions are also met
--      these supplemental conditions are ignored if 

-- This module provides some basic functionality for governing whether
-- a city can build an item

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
--          the city can only build the item if the city can't build any items in the list
--          Be careful that the 'can build chain' does not form a loop
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .requireSomeAsAlternateProduction = unitTypeObject or improvementObject or wonderObject or table of these objects
--          the city can only build the item if the city can also build some of the other items in the list
--          next entry specifies how many
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
--          
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
--              nil means no change per turn
--          .tribeTotals = nil or {[luaObject or "cities" or "population" or "turn"] = number or nil}
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
--              nil means no change per turn
--          .globalTotals = nil or {[luaObject or "cities" or "population" or "turn"] = number or nil}
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
--              if the wonder is built and it is not expired, add the value to the production limit
--          .discoveredTechs = nil or {[techObject] = number or nil}
--              if the tech is discovered by any tribe, add the value to the production limit
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
--              you can use the line canBuildFunctions.disableSupplementalConditions()
--
--


local canBuildFunctions = {}
local supplementalUnitTypeConditions = {}
local supplementalImprovementConditions = {}
local supplementalWonderConditions = {}

-- supplementalItemConditions[item.id]= table of functions



-- canBuildFunctions.registerSupplementalCondition(itemType,function(defaultBuildFunction,city,item) --> bool)
--      registers a function for itemType with the same effect as the conditionFunction
--      .conditionFunction = function(defaultBuildFunction,city,item) --> bool
--      that is, if it returns false, the item can't be built.  If it returns true, the item
--      can be built as long as all other conditions are also met
--      these supplemental conditions are ignored if 
function canBuildFunctions.registerSupplementalCondition(itemType,conditionFn)
    --print("registering condition for "..itemType.name)
    local registrationTable = {}
    if civ.isUnitType(itemType) then
        registrationTable = supplementalUnitTypeConditions
    elseif civ.isImprovement(itemType) then
        registrationTable = supplementalImprovementConditions
    elseif civ.isWonder(itemType) then
        registrationTable = supplementalWonderConditions
    else
        error("canBuildFunctions.registerSupplementalCondition: first argument must be either a unitType, improvement, or wonder object.  Instead, received "..tostring(itemType))
    end
    registrationTable[itemType.id] = registrationTable[itemType.id] or {}
    if type(conditionFn) ~= "function" then
        error("canBuildFunctions.registerSupplementalCondition: second argument must be a function of the form function(defaultBuildFunction,city,item) --> bool.  Instead, received "..tostring(conditionFn))
    end
    registrationTable[itemType.id][1+#registrationTable[itemType.id]] = conditionFn
end





-- Changes table entries for easier programming below,
-- in particular, puts single object entries inside tables,
-- so that functions are simplified
--
-- Also creates a table indexed by tileId numbers for quicker
-- checking if a location is satisfied or not
-- all location values except functions are converted into a single table
-- indexed by tileID numbers, with a true value meaning it is in a table
-- city values are in a separate table indexed by city id numbers

local function techResearched(tech)
    for i=0,7 do
        if civ.getTribe(i):hasTech(tech) then
            return true
        end
    end
    return false
end

local nameOfThingBeingProcessed = nil -- This stores the name of the unit/improvement/wonder being processed,
-- to hopefully identify errors more easily
local typeOfThingBeingProcessed = nil -- This stores the type of thing being processed as a string

local showCurrentProcess = true

local function getThingBeingProcessed(idNumber)
    if typeOfThingBeingProcessed == "unitType" then
        return civ.getUnitType(idNumber)
    elseif typeOfThingBeingProcessed == "improvement" then
        return civ.getImprovement(idNumber)
    elseif typeOfThingBeingProcessed == "wonder" then
        return civ.getWonder(idNumber)
    end
end

local function changeNameOfThingBeingProcessed(idNumber)
    if typeOfThingBeingProcessed == "unitType" then
        nameOfThingBeingProcessed = civ.getUnitType(idNumber).name
    elseif typeOfThingBeingProcessed == "improvement" then
        nameOfThingBeingProcessed = civ.getImprovement(idNumber).name
    elseif typeOfThingBeingProcessed == "wonder" then
        nameOfThingBeingProcessed = civ.getWonder(idNumber).name
    end
end



local function postProcessParameterTable(parameterTable)
    local function makeNewLocationParameters(existingLocationTable)
        local width,height,maps = civ.getAtlasDimensions()
        local locationParametersTable = {}
        local tiles = {}
        local cities = {}
        local functions = {}
        local fIndex = 1
        for __,locationDatum in pairs(existingLocationTable) do
            if type(locationDatum) == "function" then
                functions[fIndex] = locationDatum
                fIndex = fIndex+1
            elseif type(locationDatum) == "number" then
                cities[locationDatum] = true
            elseif civ.isCity(locationDatum) then
                cities[locationDatum.id] = true
            elseif civ.isTile(locationDatum) then
                tiles[gen.getTileId(locationDatum)] = true
            elseif type(locationDatum) == "table" then
                if locationDatum[3] then
                    tiles[gen.getTileId(locationDatum[1],locationDatum[2],locationDatum[3])] = true
                else
                    for z=0,(maps-1) do
                        tiles[gen.getTileId(locationDatum[1],locationDatum[2],z)] = true
                    end
                end
            else
                error("There is data specifying a location that isn't a function, integer, city, tile, or table.")
            end
        end
        locationParametersTable["tiles"] = tiles
        locationParametersTable["cities"] = cities
        locationParametersTable["functions"] = functions
        return locationParametersTable
    end


    local function postProcessParameters(parameters,item)
       if parameters.location then
           if type(parameters.location) ~= "table" or (type(parameters.location)=="table" and type(parameters.location[1])=="number") then
               -- if entry not a table, easy to tell it needs to be 'wrapped' with a table
               -- if entry is a table, but first entry of that table is a number (not something else)
               -- then the entry is a single coordinate pair or triple, so it should be wrapped
               parameters.location = {parameters.location}
           end
       end
       if parameters.location then
            parameters.location = makeNewLocationParameters(parameters.location)
        end
       if parameters.forbiddenLocation then
           if type(parameters.forbiddenLocation) ~= "table" or(type(parameters.forbiddenLocation)=="table" and type(parameters.forbiddenLocation[1])=="number") then
               -- if entry not a table, easy to tell it needs to be 'wrapped' with a table
               -- if entry is a table, but first entry of that table is a number (not something else)
               -- then the entry is a single coordinate pair or triple, so it should be wrapped
               parameters.forbiddenLocation = {parameters.forbiddenLocation}
           end
       end
       if parameters.forbiddenLocation then
       parameters.forbiddenLocation = makeNewLocationParameters(parameters.forbiddenLocation)
        end
        -- these parameter keys should be wrapped in a table if necessary, but the parameter values won't be
        -- tables themselves
        local wrapKeyTable ={"allImprovements","someImprovements","forbiddenImprovements",
            "allTechs","someTechs","forbiddenTechs","allWonders","someWonders","forbiddenAlternateProduction",
            "requireSomeAsAlternateProduction","forbiddenTribes","forbiddenMaps"}
        for __,value in pairs(wrapKeyTable) do
            --if parameters[value] then
                --print(parameters[value])
            --end
            if parameters[value] and type(parameters[value]) ~="table" then
                parameters[value] = {[1]=parameters[value]}
            end
        end
        if parameters.alternateParameters then
            for key,value in pairs(parameters.alternateParameters) do
                postProcessParameters(value,item)
            end
        end
        if parameters.forbiddenTribes then
            local replacementTable = {}
            for key,value in pairs(parameters.forbiddenTribes) do
                if type(value) == "boolean" then
                    replacementTable[key] = value
                elseif civ.isTribe(value) then
                    replacementTable[value.id]=true
                else
                    error("canBuild processing: values in the forbiddenTribes table should either"..
                    " be booleans or tribeObjects.  However,\n\n"..
                    tostring(value).."\n\n has been provided.")
                end
            end
            parameters.forbiddenTribes = replacementTable
        end
        if parameters.forbiddenMaps then
            local replacementTable = {}
            for key,value in pairs(parameters.forbiddenMaps) do
                if type(value) == "boolean" then
                    replacementTable[key] = value
                elseif civ.isMap(value) then
                    replacementTable[value.id]=true
                else
                    error("canBuild processing: values in the forbiddenMaps table should either"..
                    " be booleans or mapObjects.  However,\n\n"..
                    tostring(value).."\n\n has been provided.")
                end
            end
            parameters.forbiddenMaps = replacementTable
        end
        if parameters.maxNumberTribe then
            parameters.tribeJointMaxWith = parameters.tribeJointMaxWith or {}
            local itemNotIncluded = true
            for luaObject,increment in pairs(parameters.tribeJointMaxWith) do
                local status,value = pcall(function(a,b) return a == b end,luaObject,item)
                if status and value then
                    itemNotIncluded = false
                end
                if not civ.isUnitType(luaObject) and not civ.isImprovement(luaObject) and not civ.isWonder(luaObject) then
                    error("canBuild processing: "..item.name.." has an invalid key in the tribeJointMaxWith table.  Keys must be unitType, Improvement, or Wonder objects.")
                end
                if type(increment) ~= "number" then
                    error("canBuild processing: "..item.name.." has an invalid value in the tribeJointMaxWith table.  Values must be numbers, but "..tostring(increment).." supplied instead for the key "..tostring(luaObject))
                end
            end
            if itemNotIncluded then
                parameters.tribeJointMaxWith[item] = 1
            end

        end
        if parameters.maxNumberGlobal then
            parameters.globalJointMaxWith = parameters.globalJointMaxWith or {}
            local itemNotIncluded = true
            for luaObject,increment in pairs(parameters.globalJointMaxWith) do
                local status,value = pcall(function(a,b) return a == b end,luaObject,item)
                if status and value then
                    itemNotIncluded = false
                end
                if not civ.isUnitType(luaObject) and not civ.isImprovement(luaObject) and not civ.isWonder(luaObject) then
                    error("canBuild processing: "..item.name.." has an invalid key in the tribeJointMaxWith table.  Keys must be unitType, Improvement, or Wonder objects.")
                end
                if type(increment) ~= "number" then
                    error("canBuild processing: "..item.name.." has an invalid value in the tribeJointMaxWith table.  Values must be numbers, but "..tostring(increment).." supplied instead for the key "..tostring(luaObject))
                end
            end
            if itemNotIncluded then
                parameters.globalJointMaxWith[item] = 1
            end
        end
    end
    for key,value in pairs(parameterTable) do
        changeNameOfThingBeingProcessed(key)
        if showCurrentProcess then
            print("Currently Processing "..nameOfThingBeingProcessed.." ("..tostring(key)..")")
        end
        postProcessParameters(value,getThingBeingProcessed(key))
    end
end


local allowedParameterKeys={}
allowedParameterKeys["forbiddenTribes"] =true
allowedParameterKeys["forbiddenMaps"] =true
allowedParameterKeys["location"] =true
allowedParameterKeys["forbiddenLocation"]=true
allowedParameterKeys["allImprovements"] =true
allowedParameterKeys["someImprovements"] =true
allowedParameterKeys["numberOfImprovements"] =true
allowedParameterKeys["forbiddenImprovements"] =true
allowedParameterKeys["allTechs"] =true
allowedParameterKeys["someTechs"] =true
allowedParameterKeys["numberOfTechs"] =true
allowedParameterKeys["forbiddenTechs"] =true
allowedParameterKeys["allFlagsMatch"] =true
allowedParameterKeys["someFlagsMatch"] =true
allowedParameterKeys["numberOfFlags"] =true
allowedParameterKeys["minimumPopulation"] =true
allowedParameterKeys["maximumPopulation"] =true
allowedParameterKeys["earliestTurn"] =true
allowedParameterKeys["latestTurn"] =true
allowedParameterKeys["allWonders"] =true
allowedParameterKeys["someWonders"] =true
allowedParameterKeys["numberOfWonders"] =true
allowedParameterKeys["overrideDefaultBuildFunction"] =true
allowedParameterKeys["forbiddenAlternateProduction"] =true
allowedParameterKeys["requireSomeAsAlternateProduction"] =true
allowedParameterKeys["numberOfAlternateProduction"]=true
allowedParameterKeys["conditionFunction"] =true
allowedParameterKeys["returnFalse"] =true
allowedParameterKeys["overrideFunction"] =true
allowedParameterKeys["alternateParameters"] =true
allowedParameterKeys["computerOnly"] =true
allowedParameterKeys["humanOnly"] =true
allowedParameterKeys["onlyBuildCoastal"] =true
allowedParameterKeys["onlyBuildShips"] =true
allowedParameterKeys["onlyBuildHydroPlant"] =true
allowedParameterKeys["maxNumberTribe"] = true
allowedParameterKeys["maxNumberGlobal"] = true
allowedParameterKeys["tribeJointMaxWith"] = true
allowedParameterKeys["globalJointMaxWith"] = true
allowedParameterKeys["ignoreSupplementalConditions"] = true


-- does rudimentary checks to make sure the parameter tables are formatted correctly
--  
--
local function parameterTableErrorCheck(parameterTable,pTableName)
    local throwError = false
    for index,entry in pairs(parameterTable) do
        if type(entry) ~= "table" then
            error(pTableName.." entry "..tostring(index).." is not a table.")
        end
        local integerErrorIndex = false
        for entryIndex,__ in pairs(entry) do
            if not allowedParameterKeys[entryIndex] then
                print(pTableName.." entry "..tostring(index).." has invalid parameter: "..entryIndex)
                if type(entryIndex) == "number" then
                    integerErrorIndex = true
                end
                throwError = true
            end
        end
        if integerErrorIndex then
            print("Note: having numbers as invalid parameters usually means you've forgotten to use { and } to make a table for another parameter.")
        end
    end
    if throwError then
        error(pTableName.." has invalid parameters.  See the list printed above.")
    end
end



local unitTypeParameters = {}
local improvementParameters = {}
local wonderParameters = {}

-- provide parameter tables
local function supplyUnitTypeParameters(unitTypeParametersTable)
    if type(unitTypeParametersTable) == "table" then
        typeOfThingBeingProcessed = "unitType"
        unitTypeParameters = unitTypeParametersTable
        parameterTableErrorCheck(unitTypeParametersTable,"Unit Type Parameters")
        postProcessParameterTable(unitTypeParameters)
    else
        error("supplyUnitTypeParameters: must provide a table as the argument")
    end
end
canBuildFunctions.supplyUnitTypeParameters = supplyUnitTypeParameters
local function supplyImprovementParameters(improvementParametersTable)
    if type(improvementParametersTable) == "table" then
        typeOfThingBeingProcessed = "improvement"
        improvementParameters = improvementParametersTable
        parameterTableErrorCheck(improvementParametersTable,"Improvement Parameters")
        postProcessParameterTable(improvementParameters)
    else
        error("supplyImprovementParameters: must provide a table as the argument")
    end
end
canBuildFunctions.supplyImprovementParameters = supplyImprovementParameters
local function supplyWonderParameters(wonderParametersTable)
    if type(wonderParametersTable) == "table" then
        typeOfThingBeingProcessed = "wonder"
        wonderParameters = wonderParametersTable
        parameterTableErrorCheck(wonderParametersTable,"Wonder Parameters")
        postProcessParameterTable(wonderParameters)
    else
        error("supplyWonderParameters: must provide a table as the argument")
    end
end
canBuildFunctions.supplyWonderParameters = supplyWonderParameters

local function computeMaxNumberTribe(settings,activeTribe,item)
    if type(settings) == "number" then
        return settings
    end
    local total = settings.base or 0
    if settings.turn then
        total = total + settings.turn*civ.getTurn()
    end
    if settings.tribeTotals then
        for object,increment in pairs(settings.tribeTotals) do
            if civ.isUnitType(object) then
                total = total +increment*canBuildFunctions.tribeUnitsOwnedByTypeID[object.id]
            elseif civ.isImprovement(object) then
                total = total + increment*canBuildFunctions.tribeImprovementsOwnedByID[object.id]
            elseif civ.isWonder(object) then
                total = total + increment*canBuildFunctions.tribeWondersOwnedByID[object.id]
            elseif civ.isTech(object) then
                if activeTribe:hasTech(object) then
                    total = total+increment
                end
            elseif civ.isTribe(object) then
                if object.id == activeTribe.id then
                    total = total + increment
                end
            elseif object == "cities" then
                total = total + increment*canBuildFunctions.tribeCities
            elseif object == "population" then
                total = total + increment*canBuildFunctions.tribePopulation
            end
        end
    end
    if settings.globalTotals then
        for object,increment in pairs(settings.globalTotals) do
            if civ.isUnitType(object) then
                total = total +increment*canBuildFunctions.globalUnitsOwnedByTypeID[object.id]
            elseif civ.isImprovement(object) then
                total = total + increment*canBuildFunctions.globalImprovementsOwnedByID[object.id]
            elseif civ.isWonder(object) then
                total = total + increment*canBuildFunctions.globalWondersOwnedByID[object.id]
            elseif civ.isTech(object) then
                for i=0,7 do
                    if civ.getTribe(i):hasTech(object) then
                        total = total + increment
                    end
                end
            elseif civ.isTribe(object) then
                if object.active then
                    total = total + increment
                end
            elseif object == "cities" then
                total = total + increment*canBuildFunctions.globalCities
            elseif object == "population" then
                total = total + increment*canBuildFunctions.globalPopulation
            end
        end
    end
    if settings.activeWondersTribe then
        for wonderObject,increment in pairs(settings.activeWondersTribe) do
            total = total + increment*canBuildFunctions.tribeActiveWondersOwnedByID[wonderObject.id]
        end
    end
    if settings.activeWondersForeign then
        for wonderObject,increment in pairs(settings.activeWondersForeign) do
            -- globalWonder - tribeWonder = foreignWonder
            total = total + increment*(canBuildFunctions.globalActiveWondersOwnedByID[wonderObject.id]
                - canBuildFunctions.tribeActiveWondersOwnedByID[wonderObject.id])
        end
    end
    if settings.discoveredTechs then
        for techObject,increment in pairs(settings.discoveredTechs) do
            if techResearched(techObject) then
                total = total+increment
            end
        end
    end
    if settings.trueFlags then
        for flagKey,value in pairs(settings.trueFlags) do
            if data.flagGetValue(flagKey) then
                total = total+value
            end
        end
    end
    if settings.counterValues then
        for counterKey,value in pairs(settings.counterValues) do
            total = total+ data.counterGetValue(counterKey)*value
        end
    end
    if settings.customFunction then
        total = total + settings.customFunction(activeTribe,item)
    end
    total = math.max(total, settings.min or total)
    total = math.min(total, settings.max or total)
    return math.floor(total)
end

local function computeMaxNumberGlobal(settings,activeTribe,item)
    if type(settings) == "number" then
        return settings
    end
    local total = settings.base or 0
    if settings.turn then
        total = total + settings.turn*civ.getTurn()
    end
    if settings.globalTotals then
        for object,increment in pairs(settings.globalTotals) do
            if civ.isUnitType(object) then
                total = total +increment*canBuildFunctions.globalUnitsOwnedByTypeID[object.id]
            elseif civ.isImprovement(object) then
                total = total + increment*canBuildFunctions.globalImprovementsOwnedByID[object.id]
            elseif civ.isWonder(object) then
                total = total + increment*canBuildFunctions.globalWondersOwnedByID[object.id]
            elseif civ.isTech(object) then
                for i=0,7 do
                    if civ.getTribe(i):hasTech(object) then
                        total = total + increment
                    end
                end
            elseif civ.isTribe(object) then
                if object.active then
                    total = total + increment
                end
            elseif object == "cities" then
                total = total + increment*canBuildFunctions.globalCities
            elseif object == "population" then
                total = total + increment*canBuildFunctions.globalPopulation
            end
        end
    end
    if settings.activeWonders then
        for wonderObject,increment in pairs(settings.activeWonders) do
            total = total + increment*canBuildFunctions.globalActiveWondersOwnedByID[wonderObject.id]
        end
    end
    if settings.discoveredTechs then
        for techObject,increment in pairs(settings.discoveredTechs) do
            if techResearched(techObject) then
                total = total+increment
            end
        end
    end
    if settings.trueFlags then
        for flagKey,value in pairs(settings.trueFlags) do
            if data.flagGetValue(flagKey) then
                total = total+value
            end
        end
    end
    if settings.counterValues then
        for counterKey,value in pairs(settings.counterValues) do
            total = total+ data.counterGetValue(counterKey)*value
        end
    end
    if settings.customFunction then
        total = total + settings.customFunction(activeTribe,item)
    end
    total = math.max(total, settings.min or total)
    total = math.min(total, settings.max or total)
    return math.floor(total)
end

-- this is defined below, but needs to be declared here
local customCanBuild = nil

-- supplementalConditionsSatisfied is a boolean, that is true if all the registered supplemental Conditions
-- are satisfied, and false if they are not
-- This way, they can be ignored if ignoreSupplementalConditions is set to true
local function parametersSatisfied(defaultBuildFunction,city,item,itemParameters,supplementalConditionsSatisfied)
    if itemParameters.overrideFunction and itemParameters.overrideFunction(defaultBuildFunction,city,item) then
        return true
    end
    if itemParameters.alternateParameters then
        for __,altParams in pairs(itemParameters.alternateParameters) do
            if parametersSatisfied(defaultBuildFunction,city,item,altParams) then
                return true
            end
        end
    end
    if itemParameters.returnFalse then
        return false
    end
    if itemParameters.overrideDefaultBuildFunction then
        if civ.isImprovement(item) and city:hasImprovement(item) then
            return false
        elseif civ.isWonder(item) and (item.city or item.destroyed) then
            return false
        end
    else
        if not defaultBuildFunction(city,item) then
            return false
        end
    end
    if itemParameters.forbiddenTribes and itemParameters.forbiddenTribes[city.owner.id] then
        return false
    end
    if itemParameters.forbiddenMaps then
        if itemParameters.forbiddenMaps[city.location.z] then
            return false
        end
    end
    if itemParameters.computerOnly and city.owner.isHuman then
        return false
    end
    if itemParameters.humanOnly and (not city.owner.isHuman) then
        return false
    end
    local function cityInLocList(city,locInfo)
        local cityLocation = city.location
        if locInfo["cities"][city.id] or locInfo["tiles"][gen.getTileId(cityLocation)] then
            return true
        end
        for __,locFunction in pairs(locInfo["functions"]) do
            if locFunction(cityLocation) then
                return true
            end
        end
        return false
    end
    if itemParameters.location then
        if not(cityInLocList(city,itemParameters.location)) then
            return false
        end
    end
    if itemParameters.forbiddenLocation then
        if cityInLocList(city,itemParameters.forbiddenLocation) then
            return false
        end
    end
    if itemParameters.allImprovements then
        --if type(itemParameters.allImprovements)~="table" then
        --    print(itemParameters.allImprovements.name)
        --end
        for __,improvementOrWonder in pairs(itemParameters.allImprovements) do
            if civ.isWonder(improvementOrWonder) then
                if city ~= improvementOrWonder.city then
                    return false
                end
            else
                if not city:hasImprovement(improvementOrWonder) then
                    return false
                end
            end
        end
    end
    if itemParameters.someImprovements and itemParameters.numberOfImprovements then
        local count = 0
        for __,improvementOrWonder in pairs(itemParameters.someImprovements) do
            if civ.isWonder(improvementOrWonder) then
                if city == improvementOrWonder.city then
                    count = count+1
                end
            else
                if city:hasImprovement(improvementOrWonder) then
                    count = count+1
                end
            end
        end
        if count < itemParameters.numberOfImprovements then
            return false
        end
    end
    if itemParameters.forbiddenImprovements then
        for __,improvementOrWonder in pairs(itemParameters.forbiddenImprovements) do
            if civ.isWonder(improvementOrWonder) then
                if city == improvementOrWonder.city then
                    return false
                end
            else
                if city:hasImprovement(improvementOrWonder) then
                    return false
                end
            end
        end
    end
    local cityTribe = city.owner
    if itemParameters.allTechs then
        for __,technology in pairs(itemParameters.allTechs) do
            if not cityTribe:hasTech(technology) then
                return false
            end
        end
    end
    if itemParameters.someTechs and itemParameters.numberOfTechs then
        local count = 0
        for __,technology in pairs(itemParameters.someTechs) do
            if cityTribe:hasTech(technology) then
                count = count+1
            end
        end
        if count < itemParameters.numberOfTechs then
            return false
        end
    end
    if itemParameters.forbiddenTechs then
        for __,technology in pairs(itemParameters.forbiddenTechs) do
            if cityTribe:hasTech(technology) then
                return false
            end
        end
    end
    if itemParameters.allFlagsMatch then
        for flagKey,bool in pairs(itemParameters.allFlagsMatch) do
            if data.flagGetValue(flagKey) ~= bool then
                return false
            end
        end
    end
    if itemParameters.someFlagsMatch and itemParameters.numberOfFlags then
        local count = 0
        for flagKey,bool in pairs(itemParameters.allFlagsMatch) do
            if data.flagGetValue(flagKey) == bool then
                count = count+1
            end
        end
        if count < itemParameters.numberOfFlags then
            return false
        end
    end
    if itemParameters.minimumPopulation and city.size < itemParameters.minimumPopulation then
        return false
    end
    if itemParameters.maximumPopulation and city.size > itemParameters.maximumPopulation then
        return false
    end
    if itemParameters.earliestTurn and civ.getTurn() < itemParameters.earliestTurn then
        return false
    end
    if itemParameters.latestTurn and civ.getTurn() > itemParameters.latestTurn then
        return false
    end
    if itemParameters.onlyBuildCoastal and not gen.isBuildCoastal(city) then
        return false
    end
    if itemParameters.onlyBuildShips and not gen.isBuildShips(city) then
        return false
    end
    if itemParameters.onlyBuildHydroPlant and not gen.isBuildHydroPlant(city) then
        return false
    end
    if itemParameters.allWonders then
        for __,wonder in pairs(itemParameters.allWonders) do
            if (not wonder.city) or wonder.city.owner ~= city.owner then
                return false
            end
        end
    end
    if itemParameters.someWonders and itemParameters.numberOfWonders then
        local count = 0
        for __,wonder in pairs(itemParameters.someWonders) do
            if wonder.city and wonder.city.owner == city.owner then
                count = count+1
            end
        end
        if count < itemParameters.numberOfWonders then
            return false
        end
    end
    if itemParameters.forbiddenAlternateProduction then
        for __,altItem in pairs(itemParameters.forbiddenAlternateProduction) do
            if customCanBuild(defaultBuildFunction,city,altItem) then
                return false
            end
        end
    end
    if itemParameters.requireSomeAsAlternateProduction and itemParameters.numberOfAlternateProduction then
        local count = 0
        for __,altItem in pairs(itemParameters.requireSomeAsAlternateProduction) do
            if customCanBuild(defaultBuildFunction,city,altItem) then
                count = count+1
            end
        end
        if count < itemParameters.numberOfAlternateProduction then
            return false
        end
    end
    if itemParameters.conditionFunction and not(itemParameters.conditionFunction(defaultBuildFunction,city,item)) then
        return false
    end
    -- check the supplemental conditions
    if not (itemParameters.ignoreSupplementalConditions or supplementalConditionsSatisfied) then
        return false
    end
    if itemParameters.maxNumberTribe then
        local maxNumber = nil
        if type(itemParameters.maxNumberTribe) == "number" then
            maxNumber = itemParameters.maxNumberTribe
        elseif type(itemParameters.maxNumberTribe) == "table" then
            maxNumber = computeMaxNumberTribe(itemParameters.maxNumberTribe,city.owner,item)
        elseif type(itemParameters.maxNumberTribe) == "function" then
            maxNumber = itemParameters.maxNumberTribe(city.owner,item)
            if type(maxNumber) ~= "number" then
                error("canBuild: "..tostring(item).." has invalid value for maxNumberTribe.  Value must be nil, integer, table, or function(tribe,item)-->number")
            end
        else
            error("canBuild: "..tostring(item).." has invalid value for maxNumberTribe.  Value must be nil, integer, table, or function(tribe,item)-->number")
        end
        local spaceUsed = 0
        local spaceForItem = 1
        for luaObject,spacePer in pairs(itemParameters.tribeJointMaxWith) do
            if civ.isUnitType(luaObject) then
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.tribeUnitsOwnedByTypeID[luaObject.id]
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.tribeUnitsUnderConstructionByTypeID[luaObject.id]
                if civ.isUnitType(city.currentProduction) and city.currentProduction == luaObject then
                    spaceUsed = spaceUsed - spacePer
                end
                if civ.isUnitType(item) and item == luaObject then
                    spaceForItem = spacePer
                end
            elseif civ.isImprovement(luaObject) then
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.tribeImprovementsOwnedByID[luaObject.id]
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.tribeImprovementsUnderConstructionByID[luaObject.id]
                if civ.isImprovement(city.currentProduction) and city.currentProduction == luaObject then
                    spaceUsed = spaceUsed - spacePer
                end
                if civ.isImprovement(item) and item == luaObject then
                    spaceForItem = spacePer
                end
            else
                spaceUsed = spaceUsed + spacePer.canBuildFunctions.tribeWondersOwnedByID[luaObject.id]
                spaceUsed = spaceUsed + spacePer.canBuildFunctions.tribeWondersUnderConstructionByID[luaObject.id]
                if civ.isWonder(city.currentProduction) and city.currentProduction == luaObject then
                    spaceUsed = spaceUsed - spacePer
                end
                if civ.isWonder(item) and item == luaObject then
                    spaceForItem = spacePer
                end
            end
        end
        -- add a small term to account for floating point arithmetic
        if spaceUsed + spaceForItem > maxNumber + 1e-6 then
            return false
        end
    end
    if itemParameters.maxNumberGlobal then
        local maxNumber = nil
        if type(itemParameters.maxNumberGlobal) == "number" then
            maxNumber = itemParameters.maxNumberGlobal
        elseif type(itemParameters.maxNumberGlobal) == "table" then
            maxNumber = computeMaxNumberGlobal(itemParameters.maxNumberGlobal,city.owner,item)
        elseif type(itemParameters.maxNumberGlobal) == "function" then
            maxNumber = itemParameters.maxNumberGlobal(city.owner,item)
            if type(maxNumber) ~= "number" then
                error("canBuild: "..tostring(item).." has invalid value for maxNumberGlobal.  Value must be nil, integer, table, or function(tribe,item)-->number")
            end
        else
            error("canBuild: "..tostring(item).." has invalid value for maxNumberGlobal.  Value must be nil, integer, table, or function(tribe,item)-->number")
        end
        local spaceUsed = 0
        local spaceForItem = 1
        for luaObject,spacePer in pairs(itemParameters.globalJointMaxWith) do
            if civ.isUnitType(luaObject) then
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.globalUnitsOwnedByTypeID[luaObject.id]
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.globalUnitsUnderConstructionByTypeID[luaObject.id]
                if civ.isUnitType(city.currentProduction) and city.currentProduction == luaObject then
                    spaceUsed = spaceUsed - spacePer
                end
                if civ.isUnitType(item) and item == luaObject then
                    spaceForItem = spacePer
                end
            elseif civ.isImprovement(luaObject) then
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.globalImprovementsOwnedByID[luaObject.id]
                spaceUsed = spaceUsed+spacePer*canBuildFunctions.globalImprovementsUnderConstructionByID[luaObject.id]
                if civ.isImprovement(city.currentProduction) and city.currentProduction == luaObject then
                    spaceUsed = spaceUsed - spacePer
                end
                if civ.isImprovement(item) and item == luaObject then
                    spaceForItem = spacePer
                end
            else
                spaceUsed = spaceUsed + spacePer.canBuildFunctions.globalWondersOwnedByID[luaObject.id]
                spaceUsed = spaceUsed + spacePer.canBuildFunctions.globalWondersUnderConstructionByID[luaObject.id]
                if civ.isWonder(city.currentProduction) and city.currentProduction == luaObject then
                    spaceUsed = spaceUsed - spacePer
                end
                if civ.isWonder(item) and item == luaObject then
                    spaceForItem = spacePer
                end
            end
        end
        -- add a small term to account for floating point arithmetic
        if spaceUsed + spaceForItem > maxNumber + 1e-6 then
            return false
        end
    end
    return true
end
canBuildFunctions.parametersSatisfied = parametersSatisfied

    
local initializationFunction = function(city)

end


function canBuildFunctions.supplyInitializationFunction(fn)
    if type(fn) == "function" then
        initializationFunction = fn
    else
        error("supplyInitializationFunction: must provide a function as the argument.")
    end
end

-- constructionStatistics
canBuildFunctions.tribeCities = 0
canBuildFunctions.globalCities = 0
canBuildFunctions.tribePopulation = 0
canBuildFunctions.globalPopulation = 0
canBuildFunctions.tribeUnitsOwnedByTypeID = {}
canBuildFunctions.globalUnitsOwnedByTypeID = {}
canBuildFunctions.tribeImprovementsOwnedByID = {}
canBuildFunctions.globalImprovementsOwnedByID = {}
canBuildFunctions.tribeUnitsUnderConstructionByTypeID = {}
canBuildFunctions.globalUnitsUnderConstructionByTypeID = {}
canBuildFunctions.tribeImprovementsUnderConstructionByID = {}
canBuildFunctions.globalImprovementsUnderConstructionByID = {}
canBuildFunctions.tribeWondersOwnedByID = {}
canBuildFunctions.globalWondersOwnedByID = {}
canBuildFunctions.tribeActiveWondersOwnedByID = {}
canBuildFunctions.globalActiveWondersOwnedByID = {}
canBuildFunctions.tribeWondersUnderConstructionByID = {}
canBuildFunctions.globalWondersUnderConstructionByID = {}
canBuildFunctions.globalTechOwnershipByID = {}

local function incrementTable(tableKey,idKey)
    canBuildFunctions[tableKey][idKey] = (canBuildFunctions[tableKey][idKey] or 0) + 1
end

local function incrementImprovementCounts(city,buildingTribe)
    for improvementTypeId = 0,39 do
        if city:hasImprovement(civ.getImprovement(improvementTypeId)) then
            incrementTable("globalImprovementsOwnedByID",improvementTypeId)
            if city.owner == buildingTribe then
                incrementTable("tribeImprovementsOwnedByID",improvementTypeId)
            end
        end
    end
end

local function incrementUnderConstruction(city,buildingTribe)
    local prod = city.currentProduction
    if civ.isUnitType(prod) then
        if city.owner == buildingTribe then
            incrementTable("tribeUnitsUnderConstructionByTypeID",prod.id)
        end
        incrementTable("globalUnitsUnderConstructionByTypeID",prod.id)
    elseif civ.isImprovement(prod) then
        if city.owner == buildingTribe then
            incrementTable("tribeImprovementsUnderConstructionByID",prod.id)
        end
        incrementTable("globalImprovementsUnderConstructionByID",prod.id)
    else
        if city.owner == buildingTribe then
            incrementTable("tribeWondersUnderConstructionByID",prod.id)
        end
        incrementTable("globalWondersUnderConstructionByID",prod.id)
    end
end

local function buildConstructionStatistics(city)
    local tribe = city.owner
    for techId = 0,255 do
        -- 253 is max number of techs, so 0-252 is probably enough
        if civ.getTech(techId) then
            local total = 0
            for i = 0,7 do
                if civ.getTribe(i):hasTech(civ.getTech(techId)--[[@as techObject]]) then
                    total = total + 1
                end
            end
            canBuildFunctions.globalTechOwnershipByID = total
        end
    end
    for unitTypeId = 0,civ.cosmic.numberOfUnitTypes-1 do
        canBuildFunctions.tribeUnitsOwnedByTypeID[unitTypeId] = 0
        canBuildFunctions.globalUnitsOwnedByTypeID[unitTypeId] = 0
        canBuildFunctions.tribeUnitsUnderConstructionByTypeID[unitTypeId] = 0
        canBuildFunctions.globalUnitsUnderConstructionByTypeID[unitTypeId] = 0
    end
    for improvementTypeId = 0,39 do
        canBuildFunctions.tribeImprovementsOwnedByID[improvementTypeId] = 0
        canBuildFunctions.globalImprovementsOwnedByID[improvementTypeId] = 0
        canBuildFunctions.tribeImprovementsUnderConstructionByID[improvementTypeId] = 0
        canBuildFunctions.globalImprovementsUnderConstructionByID[improvementTypeId] = 0
    end
    for wonderId = 0,27 do
        local wonder = civ.getWonder(wonderId)
        if wonder.city then
            if wonder.expires and techResearched(wonder.expires) then
                if wonder.city.owner == tribe then
                    canBuildFunctions.tribeWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.tribeActiveWondersOwnedByID[wonderId] = 0
                    canBuildFunctions.globalWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.globalActiveWondersOwnedByID[wonderId] = 0
                else
                    canBuildFunctions.tribeWondersOwnedByID[wonderId] = 0
                    canBuildFunctions.tribeActiveWondersOwnedByID[wonderId] = 0
                    canBuildFunctions.globalWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.globalActiveWondersOwnedByID[wonderId] = 0
                end
            else
                if wonder.city.owner == tribe then
                    canBuildFunctions.tribeWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.tribeActiveWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.globalActiveWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.globalWondersOwnedByID[wonderId] = 1
                else
                    canBuildFunctions.tribeWondersOwnedByID[wonderId] = 0
                    canBuildFunctions.tribeActiveWondersOwnedByID[wonderId] = 0
                    canBuildFunctions.globalActiveWondersOwnedByID[wonderId] = 1
                    canBuildFunctions.globalWondersOwnedByID[wonderId] = 1
                end
            end
        else
            canBuildFunctions.globalWondersOwnedByID[wonderId] = 0
            canBuildFunctions.globalActiveWondersOwnedByID[wonderId] = 0
            canBuildFunctions.tribeWondersOwnedByID[wonderId] = 0
            canBuildFunctions.tribeActiveWondersOwnedByID[wonderId] = 0
        end
    end
        canBuildFunctions.tribeCities = 0
        canBuildFunctions.globalCities = 0
        canBuildFunctions.tribePopulation = 0
        canBuildFunctions.globalPopulation = 0
    for unit in civ.iterateUnits() do
        if unit.owner == tribe then
            incrementTable("tribeUnitsOwnedByTypeID",unit.type.id)
        end
        incrementTable("globalUnitsOwnedByTypeID",unit.type.id)
    end
    for city in civ.iterateCities() do
        if city.owner == tribe then
            canBuildFunctions.tribeCities = canBuildFunctions.tribeCities + 1
            canBuildFunctions.tribePopulation = canBuildFunctions.tribePopulation + city.size
        end
        canBuildFunctions.globalCities = canBuildFunctions.globalCities + 1
        canBuildFunctions.globalPopulation = canBuildFunctions.globalPopulation + city.size
        incrementImprovementCounts(city,tribe)
        incrementUnderConstruction(city,tribe)
    end
end
canBuildFunctions.buildConstructionStatistics = buildConstructionStatistics


local computeConstructionStatisticsOnEveryInitialization = true

function canBuildFunctions.disableAutomaticBuildConstructionStatistics()
    computeConstructionStatisticsOnEveryInitialization = false
end












local ignoreAllSupplementalConditions = false
function canBuildFunctions.disableSupplementalConditions()
    civ.ui.text("disableSupplementalConditions")
    ignoreAllSupplementalConditions = true
end

local function supplementalConditionsSatisfied(conditionList,defaultBuildFunction,city,item)
    if ignoreAllSupplementalConditions then
        return true
    end
    for __,supFn in pairs(conditionList) do
        if not supFn(defaultBuildFunction,city,item) then
            return false
        end
    end
    return true
end


customCanBuild = function (defaultBuildFunction, city, item,ignoreInitalization)
    if not ignoreInitalization then
        initializationFunction(city)
        if computeConstructionStatisticsOnEveryInitialization then
            buildConstructionStatistics(city)
        end
    end
    local itemParameters = nil
    local supplementalFunctions = nil
    if civ.isUnitType(item) then
        itemParameters = unitTypeParameters[item.id]
        supplementalFunctions = supplementalUnitTypeConditions[item.id] or {}
    elseif civ.isImprovement(item) then
        itemParameters = improvementParameters[item.id]
        supplementalFunctions = supplementalImprovementConditions[item.id] or {}
    elseif civ.isWonder(item) then
        itemParameters = wonderParameters[item.id]
        supplementalFunctions = supplementalWonderConditions[item.id] or {}
    end
    if not itemParameters then
        -- no data for this item, so return default
        -- as long as no supplemental conditions 
        return (defaultBuildFunction(city,item) and supplementalConditionsSatisfied(supplementalFunctions,defaultBuildFunction,city,item))
    elseif type(itemParameters) ~= "table" then
        error("customCanBuild: the parameters for "..item.name.." are not in table form.")
    end

    -- if there are supplemental conditions, they'll be checked within parametersSatisfied
    return parametersSatisfied(defaultBuildFunction,city,item,itemParameters,supplementalConditionsSatisfied(supplementalFunctions,defaultBuildFunction,city,item))
end
canBuildFunctions.customCanBuild = customCanBuild


function canBuildFunctions.hideProcessingList()
    showCurrentProcess = false
end

function canBuildFunctions.makeAddBuildConditions(unitTypeBuild,improvementBuild,wonderBuild)
    local function addBuildConditions(itemTable,paramTable)
        if type(itemTable) ~= "table" then
            itemTable = {itemTable}
        end
        for _,item in pairs(itemTable) do
            local parameterTable = gen.copyTable(paramTable)
            local settingsTable = nil
            if civ.isUnitType(item) then
                settingsTable = unitTypeBuild
            elseif civ.isImprovement(item) then
                settingsTable = improvementBuild
            elseif civ.isWonder(item) then
                settingsTable = wonderBuild
            else
                error("canBuildFunctions.addBuildCondition: the item to add must be either a unitType object, improvementObject, or wonderObject.  Received instead: "..tostring(item))
            end
            local ID = item.id
            if settingsTable[ID] then
                settingsTable[ID].alternateParameters = settingsTable[ID].alternateParameters or {}
                settingsTable[ID].alternateParameters[1+#settingsTable[ID].alternateParameters] = parameterTable
            else
                settingsTable[ID] = parameterTable
            end
        end
    end
    return addBuildConditions
end

---Provides the defaultCanBuildFunction to feed to customCanBuild
---For canBuild.canCityBuild
---@param city cityObject
---@param item unitTypeObject|wonderObject|improvementObject
---@return boolean
local function defaultCanBuild(city,item)
    return city:canBuild(item)
end

--[[
Returns true if `city` can currently build `item`, and false otherwise.

If `doNotInitializeStatistics` is true, then Lua does not count the number of units/improvements/etc on the map and instead uses the values from the last time the statistics were initialized.

You should always recount the statistics when changing cities to one owned by a different tribe, when there is a chance that production orders have changed, and when there is a chance that units or improvements have been created or removed.
]]
---@param city cityObject
---@param item unitTypeObject|wonderObject|improvementObject
---@param doNotReCount? boolean If true, Lua does not count the number of units/improvements/etc. and instead uses the values from the last time the statistics were initialized.
---@return boolean
function canBuildFunctions.canCityBuild(city,item,doNotReCount)
    return customCanBuild(defaultCanBuild,city,item,doNotReCount)
end

--console.canCityBuild = canBuildFunctions.canCityBuild

canBuildFunctions.version = canBuildVersion
gen.versionFunctions(canBuildFunctions,versionNumber,fileModified,"LuaCore".."\\".."canBuild.lua")
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."canBuild.lua")

return canBuildFunctions


