local flag = require("flag")
local gen = require("generalLibrary")

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
--      .forbiddenMaps = {[0] = bool,[1]=bool,[2]=bool,[3]=bool}
--          if canBuildObjectType[item.id].forbiddenMaps[mapCityIsOn] = true, then city can't build the item
--              false or nil means it can
--          absent means all maps are allowed
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
--
--

-- Changes table entries for easier programming below,
-- in particular, puts single object entries inside tables,
-- so that functions are simplified
--
-- Also creates a table indexed by tileId numbers for quicker
-- checking if a location is satisfied or not
-- all location values except functions are converted into a single table
-- indexed by tileID numbers, with a true value meaning it is in a table
-- city values are in a separate table indexed by city id numbers
local function postProcessParameterTable(parameterTable)
    local function makeNewLocationParameters(existingLocationTable)
        local width,height,maps = civ.getMapDimensions()
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


    local function postProcessParameters(parameters)
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
            "requireSomeAsAlternateProduction",}
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
                postProcessParameters(value)
            end
        end
    end
    for key,value in pairs(parameterTable) do
        postProcessParameters(value)
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


-- does rudimentary checks to make sure the parameter tables are formatted correctly
--  
--
local function parameterTableErrorCheck(parameterTable,pTableName)
    local throwError = false
    for index,entry in pairs(parameterTable) do
        if type(entry) ~= "table" then
            error(pTableName.." entry "..tostring(index).." is not a table.")
        end
        for entryIndex,__ in pairs(entry) do
            if not allowedParameterKeys[entryIndex] then
                print(pTableName.." entry "..tostring(index).." has invalid parameter: "..entryIndex)
                throwError = true
            end
        end
        if throwError then
            error(pTableName.." has invalid parameters.  See the list printed above.")
        end
    end
end



local canBuildFunctions = {}
local unitTypeParameters = {}
local improvementParameters = {}
local wonderParameters = {}

-- provide parameter tables
local function supplyUnitTypeParameters(unitTypeParametersTable)
    if type(unitTypeParametersTable) == "table" then
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
        wonderParameters = wonderParametersTable
        parameterTableErrorCheck(wonderParametersTable,"Wonder Parameters")
        postProcessParameterTable(wonderParameters)
    else
        error("supplyWonderParameters: must provide a table as the argument")
    end
end
canBuildFunctions.supplyWonderParameters = supplyWonderParameters

-- this is defined below, but needs to be declared here
local customCanBuild = nil

local function parametersSatisfied(defaultBuildFunction,city,item,itemParameters)
    if itemParameters.returnFalse then
        return false
    end
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
    --[[
    local function cityInLocationList(city,tableOfLocationInfo)
        local cityLocation = city.location
        local cityX = cityLocation.x
        local cityY = cityLocation.y
        local cityZ = cityLocation.z
        for __,locationDatum in pairs(tableOfLocationInfo) do
            if type(locationDatum) == "table" then
                print(locationDatum[1],locationDatum[2],locationDatum[3])
                if locationDatum[3] and locationDatum[3] == cityZ and cityX == locationDatum[1]
                    and cityY == locationDatum[2] then
                    return true
                elseif cityX == locationDatum[1] and cityY == locationDatum[2] then
                    return true
                end
            elseif civ.isTile(locationDatum) then
                if cityLocation == locationDatum then
                    return true
                end
            elseif civ.isCity(locationDatum) then
                if city == locationDatum then
                    return true
                end
            elseif type(locationDatum) == "number" then
                if city.id == locationDatum then 
                    return true
                end
            -- if we get here, locationDatum is a function(tileObject)-->bool
            elseif locationDatum(cityLocation) then
                -- if bool is true, then the city qualifies
                return true
            end
        end
        return false
    end
    --]]
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
        --if not(cityInLocationList(city,itemParameters.location)) then
        if not(cityInLocList(city,itemParameters.location)) then
            return false
        end
    end
    if itemParameters.forbiddenLocation then
        --if cityInLocationList(city,itemParameters.forbiddenLocation) then
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
            if flag.value(flagKey) ~= bool then
                return false
            end
        end
    end
    if itemParameters.someFlagsMatch and itemParameters.numberOfFlags then
        local count = 0
        for flagKey,bool in pairs(itemParameters.allFlagsMatch) do
            if flag.value(flagKey) == bool then
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
    return true
end
canBuildFunctions.parametersSatisfied = parametersSatisfied

    


customCanBuild = function (defaultBuildFunction, city, item)
    local itemParameters = nil
    if civ.isUnitType(item) then
        itemParameters = unitTypeParameters[item.id]
    elseif civ.isImprovement(item) then
        itemParameters = improvementParameters[item.id]
    elseif civ.isWonder(item) then
        itemParameters = wonderParameters[item.id]
    end
    if not itemParameters then
        -- no data for this item, so return default
        return defaultBuildFunction(city,item)
    elseif type(itemParameters) ~= "table" then
        error("customCanBuild: the parameters for "..item.name.." are not in table form.")
    end
    return parametersSatisfied(defaultBuildFunction,city,item,itemParameters)
end
canBuildFunctions.customCanBuild = customCanBuild






return canBuildFunctions
