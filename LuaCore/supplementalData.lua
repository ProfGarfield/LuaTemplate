local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


-- This module is a module to build other modules.
-- The tools here build tools to associate extra data with 
-- game objects (e.g. unit or cities)
--
-- These are the functions built by the module
--
--  <item>Data.defineFlag(flagName,defaultValue=false,resetTime="never")
--      Defines a flag for <item> data, which keeps boolean values
--      flagName = string
--          the name of the flag
--      defaultValue = boolean
--          If the underlying stored value is nil, this is the value the flag takes on
--      resetTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom",
--          Gives the time when the flag's stored value is reset to nil
--          "never" means never reset automatically
--          "onTurn" means at the very beginning of the onTurn event (before all other code)
--          "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
--          "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
--          if <item> has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using <item>Data.update
--          


-- <item>Data.defineCounter(counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)
--      Defines a counter for <item> data, which keeps numerical values
--      counterName = string
--          the name of the counter
--      defaultValue = number
--          If the underlying stored value is nil, this is the value the counter takes on
--      minValue = number
--          This is the smallest number the counter can be.  If anything would set the counter below this number,
--          the counter is set to this number instead
--      maxValue = number
--          This is the largest number the counter can be.  If anything would set the counter above this number,
--          the counter is set to this number instead
--      update = "none", "increment", "set", "reset","function", "incrementAll", "setAll", "functionAll"
--          This is the kind of update the counter receives each turn
--          "none" means no update
--          "increment" means that the updateParameter is added to the current value of the counter (subject to maxValue and minValue) ,
--              but only if the counter isn't currently nil
--          "incrementAll" same as increment, but is also applied to <item>s with nil as the underlying value of the counter
--          "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
--          "setAll" same as "set", but is also applied to <item>s with nil as the underlying value of the counter
--          "reset" sets the underlying counter value to nil
--          "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,<item>ID) (subject to maxValue and minValue), only for underlying values which are not nil
--          "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,<item>ID) (subject to maxValue and minValue), even for nil underlying values
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          Gives the time when the counter update happens
--          "never" means no update
--          "onTurn" means at the very beginning of the onTurn event (before all other code)
--          "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
--          "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
--          if <item> has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using <item>Data.update
--      updateParameter = number, nil, or function
--          if update is "increment","incrementAll", "set", "setAll" then this must be a number
--          if update is "none" or "reset", this is ignored and can be nil
--          if update is "function", this is a function(numberOrNil,<item>ID) -> numberOrNil
--      nonInteger = bool or nil
--          if true, the counter can take on non-integer values
--          if false, the value is rounded using math.floor(initialValue+0.5)
--          if nil, an error is thrown when the counter is set to a non-integer value

-- <item>Data.definePhrase(phraseName,defaultValue="",resetTime="never")
--      Defines a phrase for <item> data, which keeps string values
--      phraseName = string
--          the name of the phrase
--      defaultValue = string
--          If the underlying stored value is nil, this is the value the phrase takes on
--      resetTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          Gives the time when the phrase's stored value is reset to nil
--          "never" means never reset automatically
--          "onTurn" means at the very beginning of the onTurn event (before all other code)
--          "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
--          "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
--          if <item> has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using <item>Data.update
--

-- <item>Data.defineGeneric(dataName,updateTime="never",updateAll=false,updateFunction=nil)
--      defines a generic entry for <item> data, and can keep any item that is
--      "state savable" (since it must be saved in the state table)
--      An item is "state savable" if it is either
--      nil
--      a number
--      a string
--      a boolean
--      a table with keys that are numbers or strings
--        and with values that are also state savable
--      "generic" data doesn't have the same guards against misuse 
--      that the other <item>Data types have, but it is more flexible
--      gen.isStateSavable(item) may be useful to you
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          updateTime defines when the updateFunction is executed
--          if <item> has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--      updateAll = nil or boolean
--          if true, the update function is applied to all <item>, not just those with
--          non-nil values for this generic data
--      updateFunction = function(value,<item>ID) --> value
--          takes the existing value for <item>'s generic data under dataName
--          and the <item>'s ID number, and produces a new
--          value for the generic data under dataName
--          
--
--  <item>Data.defineModuleFlag(moduleName,flagName,defaultValue=false,resetTime="never")
--  <item>Data.defineModuleCounter(moduleName,counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)
--  <item>Data.defineModulePhrase(moduleName,phraseName,defaultValue="",resetTime="never")
--      These functions define data using the moduleName as an added part of the key name, to prevent conflicts
-- <item>Data.defineModuleGeneric(moduleName,dataName,updateTime="never",updateFunction=nil)

--      Note that flag, counter, and phrase names must be distinct, even between data types.
--      That is, flag names must be different from counter names and phrase names, etc.
--


--      Note: The optional parameter of moduleName prevents name conflicts
--      for flags used in a module/library.  
--  <item>Data.flagGetValue(<item>,flagName) --> boolean
--  <item>Data.flagGetValue(<item>,flagName,moduleName=nil) --> boolean
--      returns the value associated with the <item>'s flag of flagName
--      if the value is nil, the default specified during the definition is returned
--  <item>Data.flagSetTrue(<item>,flagName) --> void
--  <item>Data.flagSetTrue(<item>,flagName,moduleName=nil) --> void
--      sets the value associated with the <item>'s flag of flagName to True
--  <item>Data.flagSetFalse(<item>,flagName) --> void
--  <item>Data.flagSetFalse(<item>,flagName,moduleName=nil) --> void
--      sets the value associated with the <item>'s flag of flagName to false
--  <item>Data.flagReset(<item>,flagName) --> void
--  <item>Data.flagReset(<item>,flagName,moduleName=nil) --> void
--      sets the value associated with the <item>'s flag of flagName to nil,
--      (meaning that it returns the default value set when it was defined)
--  <item>Data.flagIsNil(<item>,flagName) --> boolean
--  <item>Data.flagIsNil(<item>,flagName,moduleName=nil) --> boolean
--      returns true if the underlying value of <item>'s flagName flag is nil
--      (including if all keys are nil)
--      and false otherwise
--
--  --      
--  <item>Data.counterGetValue(<item>,counterName) --> number
--  <item>Data.counterGetValue(<item>,counterName, moduleName=nil) --> number
--      returns the value associated with the <item>'s counter of counterName
--      if the value is nil, the default specified during the definition is returned
--  <item>Data.counterSetValue(<item>,counterName,value) --> number
--  <item>Data.counterSetValue(<item>,counterName,value,moduleName=nil) --> number
--      sets the value of the <item>'s counterName to the specified value
--      if this value is outside the counter's defined maxValue and minValue,
--      those values are then applied
--      returns the value the counter was set to
--  <item>Data.counterAdd(<item>,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  <item>Data.counterAdd(<item>,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      adds the increment to the <item>'s counterName current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to
--  <item>Data.counterSubtract(<item>,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  <item>Data.counterSubtract(<item>,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      subtracts the increment to the <item>'s current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to
--  <item>Data.counterSetWithin(<item>,counterName,minValue=-math.huge,maxValue=math.huge) --> number
--  <item>Data.counterSetWithin(<item>,counterName,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      Sets the counter's current value within the minValue and maxValue specified
--      (This does not change the overall max and min set when defining the counter)
--      returns the value the counter was set to
--  <item>Data.counterIsAtLeast(<item>,counterName,threshold) --> bool
--  <item>Data.counterIsAtLeast(<item>,counterName,threshold,moduleName=nil) --> bool
--      returns true if the <item>'s counterName is at least the threshold
--      and false otherwise
--  <item>Data.counterIsAtMost(<item>,counterName,threshold) --> bool
--  <item>Data.counterIsAtMost(<item>,counterName,threshold,moduleName=nil) --> bool
--      returns true if the <item>'s counterName is at most the threshold
--      and false otherwise
--  <item>Data.counterReset(<item>,counterName) --> void
--  <item>Data.counterReset(<item>,counterName,moduleName=nil) --> void
--      sets the value associated with the <item>'s counterName to nil
--      (meaning that it returns the default value set when it was defined)
--  <item>Data.counterIsNil(<item>,counterName) --> boolean
--  <item>Data.counterIsNil(<item>,counterName,moduleName=nil) --> boolean
--      returns true if the underlying value of <item>'s counterName counter is nil
--      and false otherwise
--
--  <item>Data.phraseGetValue(<item>,phraseName) --> string
--  <item>Data.phraseGetValue(<item>,phraseName,moduleName=nil) --> string
--      returns the value associated with the <item>'s phrase of phraseName
--      if the value is nil, the default specified during the definition is returned
--  <item>Data.phraseSetValue(<item>,phraseName,value) --> void
--  <item>Data.phraseSetValue(<item>,phraseName,value,moduleName) --> void
--      sets the value associated with <item>'s phraseName to value
--  <item>Data.phraseReset(<item>,phraseName) --> void
--  <item>Data.phraseReset(<item>,phraseName,moduleName) --> void
--      sets the value associated with the <item>'s phraseName to nil
--      (meaning that it returns the default value set when it was defined)
--  <item>Data.phraseIsNil(<item>,phraseName) --> boolean
--  <item>Data.phraseIsNil(<item>,phraseName,moduleName=nil) --> boolean
--      returns true if the underlying value of <item>'s phraseName phrase is nil
--      and false otherwise
--
--  <item>Data.genericGetValue(<item>,keyName) --> value
--  <item>Data.genericGetValue(<item>,keyName,moduleName) --> value
--      returns the value stored by the <item>'s keyName
--
--  <item>Data.genericSetValue(<item>,keyName,value) --> value
--  <item>Data.genericSetValue(<item>,keyName,value,moduleName) --> value
--      changes the value stored by the <item>'s keyName to value


-- makeModuleKeyName(moduleName,keyName) --> string
-- if moduleName is nil, returns keyName
-- otherwise, makes a new key out of moduleName and keyName and returns that
--  
--

-- 
local gen = require("generalLibrary"):minVersion(1)
local discreteEvents = require("discreteEventsRegistrar"):minVersion(1)
local civlua = require("civlua")

local function makeModuleKeyName(moduleName,keyName)
    if moduleName then
        return "Module Name: "..moduleName.."Key Name: "..keyName
    else
        return keyName
    end
end

local supplementalData = {}

gen.versionFunctions(supplementalData,versionNumber,fileModified,"LuaCore".."\\".."supplementalData.lua")
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."supplementalData.lua")

-- linkStateFunctions[moduleName] = linkStateFunction
local linkStateFunctions = {}

local anyString = {["string"]=true}
local anyStringNil = {["nil"]=true,["string"]=true}
local anyNumber = {["number"]=true}
local anyNumberNil = {["nil"]=true,["number"]=true}

-- cullAllDataFunctions[moduleName] = cullAllDataFunction
local cullAllDataFunctions = {}

-- onTurnFunctions[moduleName] = onTurnModuleUpdate
local onTurnFunctions = {}

-- onTribeTurnBeginFunctions[moduleName] = onTribeTurnBeginUpdate
local onTribeTurnBeginFunctions = {}


-- onTribeTurnEndFunctions[moduleName] = onTribeTurnEndUpdate
local onTribeTurnEndFunctions = {}

-- keyDefinitions[keyName] = {
--      type = "flag", "counter", "phrase", "generic"
--          specifies the kind of data this key holds
--      defaultValue = bool, number, string, nil
--          the default value for the data type
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          the time to update or reset the data
--      updateAll = boolean
--          if true, all <item>s are updated, not just those with non-nil data
--          if false, only <item>s with non-nil data are updated
--          if nil, updateAll doesn't apply to this type
--      updateType = "none", "increment", "reset", "set", "function"
--          gives the kind of update that will be done
--      updateParameter = number or function(value,<item>ID) --> value
--          the number to increment or set the value to, or the
--          function to execute to get the new value
--      minValue = number or -math.huge or nil
--          the minimum value the counter can be
--          nil if not a counter
--      maxValue = number or math.huge or nil
--          the maximum value the counter can be
--          nil if not a counter
--      nonInteger = bool or nil
--          if data is counter
--          if true, the counter can take on non-integer values
--          if false, the counter rounds non-integer values before saving them
--          if nil, non-integer values generate an error when attempting to save them

-- <item>Datum = {
--      [key] = state-savable
--          duplicate names can't exist
--      [1],[2],[3] = state-savable
--          These values are compared with the result of sameItemCheck(<item>)
--



-- supplementalData.buildModuleFunctions(moduleName,itemName, isItem, getItemID, getItemFromID,
--          itemIteratorGenerator, sameItemCheck)
--      Builds a supplemental data type module for <item>s
--      moduleName = string
--          the name of the module
--          e.g. unitData
--      itemName = string
--          a name for <item> to be used in error messages
--      isItem = function(anything) --> bool
--          the function to check if something is an <item>
--          e.g. civ.isUnit
--      getItemID = function(<item>) --> integer >= 0
--          converts an <item> to a unique integer >= 0
--          e.g. function(unit) return unit.id end
--      getItemFromID = function(integer) --> <item> or nil
--          takes an integer and retrieves the item corresponding
--          to that ID, or nil if none exists
--          e.g. civ.getUnit
--      itemIteratorGenerator = function() --> iterator
--          a function that returns an iterator over all <item>s
--          e.g. civ.iterateUnits
--      getTribe = function(item) --> tribe or nil
--          For items upgraded onTribeTurnBegin or onTribeTurnEnd,
--          determines which tribe the update will happen for
--          if nil is returned, the item is updated in the onTurn update sequence
--          e.g. function(unit)  return unit.owner end
--      sameItemCheck = function(<item>) --> value1,value2,value3
--          generates 3 state savable values that are unlikely or impossible to be true
--          if the <item> has been destroyed and its id recycled
--          e.g. verifyUnit(unit) return unit.type.id, unit.owner.id, nil end
--          

local function doubleCheckFunctions(isItem,getItemID,getItemFromID,itemIteratorGenerator,getTribe,sameItemCheck)
    for item in itemIteratorGenerator() do
        if not isItem(item) then
            error("supplementalData.buildModuleFunctions: either the isItem function is incorrect, or the itemIteratorGenerator isn't generating the correct items")
        end
        local x1,x2,x3 = sameItemCheck(item)
        local y1,y2,y3 = sameItemCheck(item)
        if x1~=y1 or x2 ~= y2 or x3 ~= y3 then
            error("supplementalData.buildModuleFunctions: the sameItemCheck function doesn't yield consistent results.")
        end
        if item ~= getItemFromID(getItemID(item)) then
            error("supplementalData.buildModuleFunctions: the getItemFromID and getItemID functions are incorrect.")
        end
        if getTribe(item) ~= nil and not civ.isTribe(getTribe(item)) then
            error("supplementalData.buildModuleFunctions: the getTribe function is incorrect.")
        end


    end
end

function supplementalData.buildModuleFunctions(moduleName, itemName, isItem,
    getItemID,getItemFromID,itemIteratorGenerator,getTribe,sameItemCheck)
    doubleCheckFunctions(isItem,getItemID,getItemFromID,itemIteratorGenerator,getTribe,sameItemCheck)
    local itemData = {}
    local dataTable = "stateNotLinked"
    local function linkState(stateTable)
        if type(stateTable) == "table" then
            dataTable = stateTable
        else
            error(moduleName..".linkState: table expected as argument. Received: "..tostring(stateTable))
        end
    end
    if linkStateFunctions[moduleName] then
        error("supplementalData.buildModuleFunctions: the module name '"..moduleName.."' has already been used.  Choose a different module name.")
    end
    linkStateFunctions[moduleName] = linkState

    local keyDefinitions = {}
    local allowedUpdateTimes = {never=true, onTurn=true, onTribeTurnBegin=true, onTribeTurnEnd=true, custom=true}
    function itemData.defineFlag(flagName,defaultValue,resetTime)
        gen.validateFunctionArgument(flagName,moduleName,"defineFlag",1,"flagName",anyString)
        gen.validateFunctionArgument(defaultValue,moduleName,"defineFlag",2,"defaultValue",{["nil"]=true,["boolean"]=true},"flagName: "..flagName)
        defaultValue = defaultValue or false
        gen.validateFunctionArgument(resetTime,moduleName,"defineFlag",3,"resetTime",
            {["nil"]=true,["string"]=allowedUpdateTimes},"flagName: "..flagName)
        resetTime = resetTime or "never"
        if keyDefinitions[flagName] then
            error(moduleName..'.defineFlag: the flagName "'..flagName..'" is already in use.')
        end
        keyDefinitions[flagName] = {}
        local def = keyDefinitions[flagName]
        def.type = "flag"
        def.defaultValue = defaultValue
        def.updateTime = resetTime
        def.updateAll = nil
        def.updateType = "reset"
        def.updateParameter = nil
        def.minValue = nil
        def.maxValue = nil
        def.nonInteger = nil
    end
    function itemData.defineModuleFlag(modName,flagName,defaultValue,resetTime)
        if type(modName) ~= "string" or type(flagName) ~= "string" then
            error(moduleName..".defineModuleFlag: the moduleName or the keyName for a module Flag is not a string.  Received: moduleName: "..tostring(moduleName).." keyName: "..tostring(flagName))
        end
        itemData.defineFlag(makeModuleKeyName(modName,flagName),defaultValue,resetTime)
    end

    -- checks that the item is still the same item it was before
    -- (e.g. that the unit hasn't been killed and replaced)
    -- If it has, eliminate all data for that item
    function itemData.validate(item)
        local ID = getItemID(item)
        local datum = dataTable[ID]
        if datum then
            local val1,val2,val3 = sameItemCheck(item)
            if not (val1 == datum[1] and val2 == datum[2] and val3 == datum[3]) then
                dataTable[ID] = nil
            end
        end
    end
    local validateItem = itemData.validate

    -- performs some standard error checks
    -- makes sure the key has been defined, the item submitted is correct,
    -- and that the key matches the data type
    local function standardChecks(item,keyName,functionName,typeName)
        if not keyDefinitions[keyName] then
            error(moduleName.."."..functionName..": the key "..keyName.." has not been defined.")
        end
        if not isItem(item) then
            error(moduleName.."."..functionName..": first argument is not a "..itemName..".  Received: "..tostring(item))
        end
        if keyDefinitions[keyName].type ~= typeName then
            error(moduleName.."."..functionName..": the key "..keyName.." is not a "..typeName.." key.")
        end
    end

    function itemData.flagGetValue(item,flagName,modName)
        gen.validateFunctionArgument(flagName, moduleName, "flagGetValue",2, "flagName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "flagGetValue",3, "moduleName",anyStringNil,"flagName: "..flagName)
        flagName = makeModuleKeyName(modName,flagName) 
        standardChecks(item,flagName,"flagGetValue","flag")
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            return keyDefinitions[flagName].defaultValue
        end
        return dataTable[itemID][flagName] or keyDefinitions[flagName].defaultValue
    end

    -- guaranteeDatum(<item>) --> void
    --  validates the existing datum, then
    --  creates an entry in the dataTable for the <item>, if none exists
    local function guaranteeDatum(item)
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            local datum = {}
            datum[1], datum[2], datum[3] = sameItemCheck(item)
            dataTable[itemID] = datum
        end
    end

    function itemData.flagSetTrue(item,flagName,modName)
        gen.validateFunctionArgument(flagName, moduleName, "flagSetTrue",2, "flagName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "flagSetTrue",3, "moduleName",anyStringNil,"flagName: "..flagName)
        flagName = makeModuleKeyName(modName,flagName) 
        standardChecks(item,flagName,"flagSetTrue","flag")
        guaranteeDatum(item)
        local itemID = getItemID(item)
        dataTable[itemID][flagName] = true
    end

    function itemData.flagSetFalse(item,flagName,modName)
        gen.validateFunctionArgument(flagName, moduleName, "flagSetFalse",2, "flagName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "flagSetFalse",3, "moduleName",anyStringNil,"flagName: "..flagName)
        flagName = makeModuleKeyName(modName,flagName) 
        standardChecks(item,flagName,"flagSetFalse","flag")
        guaranteeDatum(item)
        local itemID = getItemID(item)
        dataTable[itemID][flagName] = false
    end

    -- returns true if the datum is "empty", which is to say,
    -- all keys are nil, except possibly for [1],[2],[3]
    local function isDatumEmpty(datum)
        for key,_ in pairs(datum) do
            if key ~= 1 and key ~= 2 and key ~= 3 then
                return false
            end
        end
        return true
    end

    -- if the datum corresponding to item has only nil values,
    -- the datum is eliminated
    local function cullDatum(item)
        local itemID = getItemID(item)
        if dataTable[itemID] and isDatumEmpty(dataTable[itemID]) then
            dataTable[itemID] = nil
        end
    end

    function itemData.flagReset(item,flagName,modName)
        gen.validateFunctionArgument(flagName, moduleName, "flagReset",2, "flagName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "flagReset",3, "moduleName",anyStringNil,"flagName: "..flagName)
        flagName = makeModuleKeyName(modName,flagName) 
        standardChecks(item,flagName,"flagReset","flag")
        validateItem(item)
        local itemID = getItemID(item)
        if dataTable[itemID] then
            dataTable[itemID][flagName] = nil
        end
        cullDatum(item)
    end

    function itemData.flagIsNil(item,flagName,modName)
        gen.validateFunctionArgument(flagName, moduleName, "flagIsNil",2, "flagName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "flagIsNil",3, "moduleName",anyStringNil,"flagName: "..flagName)
        flagName = makeModuleKeyName(modName,flagName) 
        standardChecks(item,flagName,"flagIsNil","flag")
        validateItem(item)
        local itemID = getItemID(item)
        return not (dataTable[itemID] and dataTable[itemID][flagName] ~= nil)
    end


    function itemData.defineCounter(counterName,defaultValue,minValue,maxValue,
        update, updateTime,updateParameter,nonInteger)
        gen.validateFunctionArgument(counterName,moduleName,"defineCounter",1,"counterName",anyString)
        gen.validateFunctionArgument(nonInteger,moduleName,"defineCounter",8,"nonInteger",
            {["nil"]=true, ["boolean"]=true},"counterName: "..counterName)
        if nonInteger then
            gen.validateFunctionArgument(defaultValue,moduleName,"defineCounter",2,"defaultValue",{["nil"]=true, ["number"]=true},"counterName: "..counterName)
            gen.validateFunctionArgument(minValue,moduleName,"defineCounter",3,"minValue",{["nil"]=true, ["number"]=true},"counterName: "..counterName)
            gen.validateFunctionArgument(maxValue,moduleName,"defineCounter",4,"maxValue",{["nil"]=true, ["number"]=true},"counterName: "..counterName)
        else
            gen.validateFunctionArgument(defaultValue,moduleName,"defineCounter",2,"defaultValue",{["nil"]=true, ["number"]={integer=true}}, "(note: the integer requirement is removed if argument 8, 'nonInteger', is set to true), counterName: "..counterName)
            gen.validateFunctionArgument(minValue,moduleName,"defineCounter",3,"minValue",{["nil"]=true, ["number"]={integer=true}}, "(note: the integer requirement is removed if argument 8, 'nonInteger', is set to true), counterName: "..counterName)
            gen.validateFunctionArgument(maxValue,moduleName,"defineCounter",4,"maxValue",{["nil"]=true, ["number"]={integer=true}}, "(note: the integer requirement is removed if argument 8, 'nonInteger', is set to true), counterName: "..counterName)
            gen.validateFunctionArgument(updateParameter,moduleName,"defineCounter",7,"updateParameter", {["nil"]=true, ["number"]={integer=true}, ["function"]=true}, "(note: the integer requirement is removed if argument 8, 'nonInteger', is set to true), counterName: "..counterName)
        end
        gen.validateFunctionArgument(update,moduleName,"defineCounter",5,"update",
            {["nil"]=true, ["string"]={["none"]=true,["increment"]=true,["set"]=true,["reset"]=true,
            ["function"]=true, ["incrementAll"]=true,["setAll"]=true,["functionAll"]=true}},"counterName: "..counterName)
        gen.validateFunctionArgument(updateTime,moduleName,"defineCounter",6,"updateTime", {["nil"]=true, ["string"]=allowedUpdateTimes},"counterName: "..counterName)

        defaultValue = defaultValue or 0
        minValue = minValue or -math.huge
        maxValue = maxValue or math.huge
        if minValue > defaultValue or minValue > maxValue or maxValue < defaultValue then
            error(moduleName..".defineCounter: defaultValue(arg2)="..defaultValue.." minValue(arg3)="..minValue.." maxValue(arg4)="..maxValue..".  These are must satisfy minValue<=defaultValue<=maxValue, but they do not.")
        end
        update = update or "none"
        updateTime = updateTime or "never"
        if (update == "function" or update == "functionAll") and type(updateParameter) ~= "function" then
            error(moduleName..".defineCounter: when the update argument (#5) is 'function' or 'functionAll', the updateParameter argument (#7) must be a function(numberOrNil,"..itemName.."ID) --> numberOrNil.  Received: "..tostring(updateParameter))
        end
        local numberUpdates = {["increment"]=true,["incrementAll"]=true,["set"]=true,["setAll"]=true}
        if numberUpdates[update] and type(updateParameter) ~= "number" then
            error(moduleName..".defineCounter: when the update argument (#5) is '"..update.."', the updateParameter argument (#7) must be a number.  Received: "..tostring(updateParameter))
        end
        if keyDefinitions[counterName] then
            error(moduleName..'.defineCounter: the counterName "'..counterName..'" is already in use.')
        end
        keyDefinitions[counterName] = {}
        local def = keyDefinitions[counterName]
        def.type = "counter"
        def.defaultValue = defaultValue
        def.updateTime = updateTime
        if string.sub(update,-3,-1) == "All" then
            def.updateAll = true
            def.updateType = string.sub(update,1,-4)
        else
            def.updateAll = false
            def.updateType = update
        end
        def.updateParameter = updateParameter
        def.minValue = minValue
        def.maxValue = maxValue
        def.nonInteger = nonInteger
    end
    function itemData.defineModuleCounter(modName,counterName,defaultValue,minValue,maxValue,
        update, updateTime,updateParameter,nonInteger)
        if type(modName) ~= "string" or type(counterName) ~= "string" then
            error(moduleName..".defineModuleCounter: the moduleName or the keyName for a module counter is not a string.  Received: moduleName: "..tostring(moduleName).." keyName: "..tostring(counterName))
        end
        itemData.defineCounter(makeModuleKeyName(modName,counterName),defaultValue,minValue,maxValue,
            update, updateTime,updateParameter,nonInteger)
    end


    function itemData.counterGetValue(item,counterName,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterGetValue",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterGetValue",3,"moduleName",anyStringNil,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterGetValue","counter")
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            return keyDefinitions[counterName].defaultValue
        end
        return dataTable[itemID][counterName] or keyDefinitions[counterName].defaultValue
    end
    
    local function integerErrorCheck(argument,functionName,keyName,argumentName,argumentPosition,nonInteger)
        if nonInteger ~= nil or argument == math.floor(argument) then
            return
        else
            error(moduleName.."."..functionName.." counter:"..keyName.." must be an integer.  However, "..argumentName.."(arg"..argumentPosition..") is "..tostring(argument))
        end
    end
    local function roundIfNecessary(value,nonInteger)
        if not nonInteger then
            return math.floor(value+0.5)
        else
            return value
        end
    end

    function itemData.counterSetValue(item,counterName,value,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterSetValue",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterSetValue",4,"moduleName",anyStringNil,"counterName: "..counterName)
        gen.validateFunctionArgument(value,moduleName,"counterSetValue",3,"value",anyNumber,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterSetValue","counter")
        guaranteeDatum(item)
        local itemID = getItemID(item)
        local def = keyDefinitions[counterName]
        integerErrorCheck(value,"counterSetValue",counterName,"value",3,def.nonInteger)
        local newValue = math.max(def.minValue,math.min(def.maxValue,value))
        newValue = roundIfNecessary(newValue,def.nonInteger)
        dataTable[itemID][counterName] = newValue
        return dataTable[itemID][counterName]
    end


    function itemData.counterAdd(item,counterName,increment,minValue,maxValue,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterAdd",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterAdd",6,"moduleName",anyStringNil,"counterName: "..counterName)
        gen.validateFunctionArgument(increment,moduleName,"counterAdd",3,"increment",anyNumber,"counterName: "..counterName)
        gen.validateFunctionArgument(minValue,moduleName,"counterAdd",4,"minValue",anyNumberNil,"counterName: "..counterName)
        gen.validateFunctionArgument(maxValue,moduleName,"counterAdd",5,"maxValue",anyNumberNil,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterAdd","counter")
        guaranteeDatum(item)
        minValue = minValue or -math.huge
        maxValue = maxValue or math.huge
        local itemID = getItemID(item)
        local def = keyDefinitions[counterName]
        integerErrorCheck(increment,"counterAdd",counterName,"increment",3,def.nonInteger)
        integerErrorCheck(minValue,"counterAdd",counterName,"minValue",4,def.nonInteger)
        integerErrorCheck(maxValue,"counterAdd",counterName,"maxValue",5,def.nonInteger)
        local newVal = dataTable[itemID][counterName] or def.defaultValue
        newVal = math.max(minValue, math.min(maxValue,newVal+increment))
        newVal = math.max(def.minValue, math.min(def.maxValue,newVal))
        newVal = roundIfNecessary(newVal,def.nonInteger)
        dataTable[itemID][counterName] = newVal
        return newVal
    end

    -- not just wrapping counterAdd, so that errors are just a bit more informative
    -- I don't want someone using counterSubtract, then getting errors for counterAdd
    function itemData.counterSubtract(item,counterName,increment,minValue,maxValue,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterSubtract",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterSubtract",6,"moduleName",anyStringNil,"counterName: "..counterName)
        gen.validateFunctionArgument(increment,moduleName,"counterSubtract",3,"increment",anyNumber,"counterName: "..counterName)
        gen.validateFunctionArgument(minValue,moduleName,"counterSubtract",4,"minValue",anyNumberNil,"counterName: "..counterName)
        gen.validateFunctionArgument(maxValue,moduleName,"counterSubtract",5,"maxValue",anyNumberNil,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterSubtract","counter")
        guaranteeDatum(item)
        minValue = minValue or -math.huge
        maxValue = maxValue or math.huge
        local itemID = getItemID(item)
        local def = keyDefinitions[counterName]
        integerErrorCheck(increment,"counterSubtract",counterName,"increment",3,def.nonInteger)
        integerErrorCheck(minValue,"counterSubtract",counterName,"minValue",4,def.nonInteger)
        integerErrorCheck(maxValue,"counterSubtract",counterName,"maxValue",5,def.nonInteger)
        local newVal = dataTable[itemID][counterName] or def.defaultValue
        newVal = math.max(minValue, math.min(maxValue,newVal-increment))
        newVal = math.max(def.minValue, math.min(def.maxValue,newVal))
        newVal = roundIfNecessary(newVal,def.nonInteger)
        dataTable[itemID][counterName] = newVal
        return newVal
    end

    function itemData.counterSetWithin(item,counterName,minValue,maxValue,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterSetWithin",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterSetWithin",5,"moduleName",anyStringNil,"counterName: "..counterName)
        gen.validateFunctionArgument(minValue,moduleName,"counterSetWithin",3,"minValue",anyNumberNil,"counterName: "..counterName)
        gen.validateFunctionArgument(maxValue,moduleName,"counterSetWithin",4,"maxValue",anyNumberNil,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterSetWithin","counter")
        guaranteeDatum(item)
        minValue = minValue or -math.huge
        maxValue = maxValue or math.huge
        local itemID = getItemID(item)
        local def = keyDefinitions[counterName] 
        integerErrorCheck(minValue,"counterSetWithin",counterName,"minValue",3,def.nonInteger)
        integerErrorCheck(maxValue,"counterSetWithin",counterName,"maxValue",4,def.nonInteger)
        local newVal = dataTable[itemID][counterName] or def.defaultValue
        newVal = math.max(minValue, math.min(maxValue,newVal))
        newVal = math.max(def.minValue, math.min(def.maxValue,newVal))
        newVal = roundIfNecessary(newVal,def.nonInteger)
        dataTable[itemID][counterName] = newVal
        return newVal
    end

    function itemData.counterIsAtLeast(item,counterName,threshold,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterIsAtLeast",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterIsAtLeast",4,"moduleName",anyStringNil,"counterName: "..counterName)
        gen.validateFunctionArgument(threshold,moduleName,"counterIsAtLeast",3,"threshold",anyNumber,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterIsAtLeast","counter")
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            return keyDefinitions[counterName].defaultValue >= threshold
        end
        return (dataTable[itemID][counterName] or keyDefinitions[counterName].defaultValue) >= threshold
    end

    function itemData.counterIsAtMost(item,counterName,threshold,modName)
        gen.validateFunctionArgument(counterName,moduleName,"counterIsAtMost",2,"counterName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"counterIsAtMost",4,"moduleName",anyStringNil,"counterName: "..counterName)
        gen.validateFunctionArgument(threshold,moduleName,"counterIsAtMost",3,"threshold",anyNumber,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName)
        standardChecks(item,counterName,"counterIsAtMost","counter")
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            return keyDefinitions[counterName].defaultValue <= threshold
        end
        return (dataTable[itemID][counterName] or keyDefinitions[counterName].defaultValue) <= threshold
    end

    function itemData.counterReset(item,counterName,modName)
        gen.validateFunctionArgument(counterName, moduleName, "counterReset",2, "counterName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "counterReset",3, "moduleName",anyStringNil,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName) 
        standardChecks(item,counterName,"counterReset","counter")
        validateItem(item)
        local itemID = getItemID(item)
        if dataTable[itemID] then
            dataTable[itemID][counterName] = nil
        end
        cullDatum(item)
    end

    function itemData.counterIsNil(item,counterName,modName)
        gen.validateFunctionArgument(counterName, moduleName, "counterIsNil",2, "counterName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "counterIsNil",3, "moduleName",anyStringNil,"counterName: "..counterName)
        counterName = makeModuleKeyName(modName,counterName) 
        standardChecks(item,counterName,"counterIsNil","counter")
        validateItem(item)
        local itemID = getItemID(item)
        return not (dataTable[itemID] and dataTable[itemID][counterName] ~= nil)
    end

    function itemData.definePhrase(phraseName,defaultValue,resetTime)
        gen.validateFunctionArgument(phraseName,moduleName,"definePhrase",1,"phraseName",anyString)
        gen.validateFunctionArgument(defaultValue,moduleName,"definePhrase",2,"defaultValue",{["nil"]=true,["string"]=true},"phraseName: "..phraseName)
        defaultValue = defaultValue or ""
        gen.validateFunctionArgument(resetTime,moduleName,"definePhrase",3,"resetTime",
            {["nil"]=true,["string"]=allowedUpdateTimes},"phraseName: "..phraseName)
        resetTime = resetTime or "never"
        if keyDefinitions[phraseName] then
            error(moduleName..'.definePhrase: the phraseName "'..phraseName..'" is already in use.')
        end
        keyDefinitions[phraseName] = {}
        local def = keyDefinitions[phraseName]
        def.type = "phrase"
        def.defaultValue = defaultValue
        def.updateTime = resetTime
        def.updateAll = nil
        def.updateType = "reset"
        def.updateParameter = nil
        def.minValue = nil
        def.maxValue = nil
        def.nonInteger = nil
    end
    function itemData.defineModulePhrase(modName,phraseName,defaultValue,resetTime)
        if type(modName) ~= "string" or type(phraseName) ~= "string" then
            error(moduleName..".defineModulePhrase: the moduleName or the keyName for a module phrase is not a string.  Received: moduleName: "..tostring(moduleName).." keyName: "..tostring(phraseName))
        end
        itemData.definePhrase(makeModuleKeyName(modName,phraseName),defaultValue,resetTime)
    end
        
    function itemData.phraseGetValue(item,phraseName,modName)
        gen.validateFunctionArgument(phraseName, moduleName, "phraseGetValue",2, "phraseName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "phraseGetValue",3, "moduleName",anyStringNil,"phraseName: "..phraseName)
        phraseName = makeModuleKeyName(modName,phraseName) 
        standardChecks(item,phraseName,"phraseGetValue","phrase")
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            return keyDefinitions[phraseName].defaultValue
        end
        return dataTable[itemID][phraseName] or keyDefinitions[phraseName].defaultValue
    end

    function itemData.phraseSetValue(item,phraseName,value,modName)
        gen.validateFunctionArgument(phraseName,moduleName,"phraseSetValue",2,"phraseName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"phraseSetValue",4,"moduleName",anyStringNil,"phraseName: "..phraseName)
        gen.validateFunctionArgument(value,moduleName,"phraseSetValue",3,"value",anyString,"phraseName: "..phraseName)
        phraseName = makeModuleKeyName(modName,phraseName)
        standardChecks(item,phraseName,"phraseSetValue","phrase")
        guaranteeDatum(item)
        local itemID = getItemID(item)
        dataTable[itemID][phraseName] = value
    end

    function itemData.phraseReset(item,phraseName,modName)
        gen.validateFunctionArgument(phraseName, moduleName, "phraseReset",2, "phraseName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "phraseReset",3, "moduleName",anyStringNil,"phraseName: "..phraseName)
        phraseName = makeModuleKeyName(modName,phraseName) 
        standardChecks(item,phraseName,"phraseReset","phrase")
        validateItem(item)
        local itemID = getItemID(item)
        if dataTable[itemID] then
            dataTable[itemID][phraseName] = nil
        end
        cullDatum(item)
    end

    function itemData.phraseIsNil(item,phraseName,modName)
        gen.validateFunctionArgument(phraseName, moduleName, "phraseIsNil",2, "phraseName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "phraseIsNil",3, "moduleName",anyStringNil,"phraseName: "..phraseName)
        phraseName = makeModuleKeyName(modName,phraseName) 
        standardChecks(item,phraseName,"phraseIsNil","phrase")
        validateItem(item)
        local itemID = getItemID(item)
        return not (dataTable[itemID] and dataTable[itemID][phraseName] ~= nil)
    end

    function itemData.defineGeneric(dataName,updateTime,updateAll, updateFunction)
        gen.validateFunctionArgument(dataName,moduleName,"defineGeneric",1,"dataName",anyString)
        gen.validateFunctionArgument(updateTime,moduleName,"defineGeneric",2,"updateTime",
            {["nil"]=true, ["string"]=allowedUpdateTimes},"dataName: "..dataName)
        gen.validateFunctionArgument(updateAll,moduleName,"defineGeneric",3,"updateAll",
            {["nil"]=true, ["boolean"]=true},"dataName: "..dataName)
        updateTime = updateTime or "never"
        updateAll = updateAll or false
        if updateTime == "never" then
            gen.validateFunctionArgument(updateFunction,moduleName,"defineGeneric",4,"updateFunction",
                {["nil"]=true,["function"]=true},"dataName: "..dataName)
        else
            gen.validateFunctionArgument(updateFunction,moduleName,"defineGeneric",4,"updateFunction",
                {["function"]=true},"(note: if updateTime(arg2)=='never' (or == nil), updateFunction can be nil)dataName: "..dataName)
        end
        if keyDefinitions[dataName] then
            error(moduleName..'.defineGeneric: the dataName "'..dataName..'" is already in use.')
        end
        keyDefinitions[dataName] = {}
        local def = keyDefinitions[dataName]
        def.type = "generic"
        def.defaultValue = nil
        def.updateTime = updateTime
        def.updateAll = updateAll
        if updateFunction then
            def.updateType = "function"
        else
            def.updateType = "none"
        end
        def.updateParameter = updateFunction
        def.minValue = nil
        def.maxValue = nil
        def.nonInteger = true
    end

    function itemData.defineModuleGeneric(modName,dataName,updateTime,updateAll,updateFunction)
        if type(modName) ~= "string" or type(dataName) ~= "string" then
            error(moduleName..".defineModulegeneric: the moduleName or the keyName for a module Generic is not a string.  Received: moduleName: "..tostring(moduleName).." keyName: "..tostring(dataName))
        end
        itemData.defineGeneric(makeModuleKeyName(modName,dataName),updateTime,updateAll,updateFunction)
    end

    function itemData.genericGetValue(item,dataName,modName)
        gen.validateFunctionArgument(dataName, moduleName, "genericGetValue",2, "dataName",anyString)
        gen.validateFunctionArgument(modName, moduleName, "genericGetValue",3, "moduleName",anyStringNil,"dataName: "..dataName)
        dataName = makeModuleKeyName(modName,dataName) 
        standardChecks(item,dataName,"genericGetValue","generic")
        validateItem(item)
        local itemID = getItemID(item)
        if not dataTable[itemID] then
            return keyDefinitions[dataName].defaultValue
        end
        return dataTable[itemID][dataName] or keyDefinitions[dataName].defaultValue
    end

    function itemData.genericSetValue(item,dataName,value,modName)
        gen.validateFunctionArgument(dataName,moduleName,"genericSetValue",2,"dataName",anyString)
        gen.validateFunctionArgument(modName,moduleName,"genericSetValue",4,"moduleName",anyStringNil,"dataName: "..dataName)
        --gen.validateFunctionArgument(value,moduleName,"genericSetValue",3,"value",anyString,"dataName: "..dataName)
        if not gen.isStateSavable(value) then
            error(moduleName..".genericSetValue: value(arg3) is not state savable.  Received "..tostring(value))
        end
        dataName = makeModuleKeyName(modName,dataName)
        standardChecks(item,dataName,"genericSetValue","generic")
        guaranteeDatum(item)
        local itemID = getItemID(item)
        dataTable[itemID][dataName] = value
        return dataTable[itemID][dataName]
    end
    
    -- if all <item>Data is nil for the <item>, removes the table
    local function cullAllData()
        for itemID, datum in pairs(dataTable) do
            if isDatumEmpty(datum) then
                dataTable[itemID] = nil
            elseif getItemFromID(itemID) then
                validateItem(getItemFromID(itemID))
            else
                dataTable[itemID] = nil
            end
        end
    end
    cullAllDataFunctions[moduleName] = cullAllData


    -- updates the data for itemID and key
    -- no protections against bad inputs
    -- used for case where datum already exists and is validated
    local function unprotectedUpdateKey(itemID,key)
        local def = keyDefinitions[key]
        if def.updateType == "none" then
            -- no update
            return
        end
        local updateType = def.updateType
        local datum = dataTable[itemID]
        if (not def.updateAll) and (datum == nil or datum[key] == nil) then
            -- no update necessary if the datum or key is nil, and not an updateall
            return
        end
        if datum == nil then
            guaranteeDatum(getItemFromID(itemID))
            datum = dataTable[itemID]
        end
        if updateType == "reset" then
            datum[key] = nil
            return
        elseif updateType == "increment" then
            local newVal = datum[key] or def.defaultValue
            newVal = newVal + def.updateParameter
            newVal = math.max(def.minValue,math.min(def.maxValue, newVal))
            newVal = roundIfNecessary(newVal,def.nonInteger)
            datum[key] = newVal
            return
        elseif updateType == "set" then
            local newVal = def.updateParameter
            newVal = math.max(def.minValue,math.min(def.maxValue, newVal))
            newVal = roundIfNecessary(newVal,def.nonInteger)
            datum[key] = newVal
            return
        elseif updateType == "function" then
            local newVal = def.updateParameter(datum[key],itemID)
            if type(newVal) ~= "number" and type(newVal) ~= "nil" and def.type == "counter" then
                error(moduleName..".update: the update function for key: "..key.." has produced a result that is neither nil nor a number.  If you need this flexibility, use a generic data instead of a counter.")
            end
            if type(newVal) == "number" then
                if def.nonInteger == nil and newVal ~= math.floor(newVal) then
                    error(moduleName..".update: the update function for key: "..key.." has produced a non-integer number. ("..tostring(newVal)..")  If you set the 8th argument of defineCounter to false, this will be rounded to the nearest integer automatically.  If you set the 8th argument to true, the integer result will remain.")
                end
                local minValue = def.minValue or -math.huge
                local maxValue = def.maxValue or math.huge
                newVal = math.max(minValue,math.min(maxValue, newVal))
                newVal = roundIfNecessary(newVal,def.nonInteger)
            end
            datum[key] = newVal
            return
        end
    end


    -- <item>Data.update(<item>,time="custom",tribe=nil,key=nil)
    -- <item>Data.update(<item>,time="custom",tribe=nil,key=nil,moduleName)
    --      updates all of <item>'s data keys that have an updateTime of time, unless
    --      key is specified, in which case, update that key only
    --      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
    --      tribe is the active tribe, relevant for onTribeTurnBegin and onTribeTurnEnd updates
    --      if key is specified, that key's update time must be the same as the time specified
    --
    function itemData.update(item,time,tribe,key,modName)
        if not isItem(item) then
            error(moduleName..".update: item(arg 1) is not a "..itemName..".  Received: "..tostring(item))
        end
        gen.validateFunctionArgument(time,moduleName,"update",2,"time",{["nil"]=true,["string"]={custom=true, onTurn=true, onTribeTurnBegin=true, onTribeTurnEnd=true}})
        gen.validateFunctionArgument(tribe,moduleName,"update",3,"tribe",{["nil"]=true,["userdata"]={["tribeObject"]=civ.isTribe}})
        gen.validateFunctionArgument(modName, moduleName, "update",5, "moduleName",anyStringNil)
        key = makeModuleKeyName(modName,key)
        time = time or "custom"
        if key and not keyDefinitions[key] then
            error(moduleName..".update: the key(arg 4) "..key.." has not been defined.  If you wish to update all keys for time '"..time.."' you can supply nil to argument 4 instead.")
        end
        if key and keyDefinitions[key].updateTime ~= time then
            error(moduleName..".update: the key (arg 4) "..key.." has an update time of '"..keyDefinitions[key].updateTime.."', but the time (arg 2) specified was '"..time.."'.")
        end
        local itemID = getItemID(item)
        if key then
            unprotectedUpdateKey(itemID,key)
            cullDatum(item)
            return
        end
        for key,def in pairs(keyDefinitions) do
            if def.updateTime == time and (time == "onTurn" or time == "custom" or getTribe(item) == tribe) then
                unprotectedUpdateKey(itemID,key)
            end
        end
        cullDatum(item)
        return
    end
    local updateItem = itemData.update

    -- updates all items that have a non-nil piece of data
    local function nonNilGeneralUpdate(time,tribe)
        for itemID, _ in pairs(dataTable) do
            if getItemFromID(itemID) then
                updateItem(getItemFromID(itemID),time,tribe)
            end
        end
    end

    local function fullGeneralUpdate(time,tribe)
        for item in itemIteratorGenerator() do
            updateItem(item,time,tribe)
        end
    end

    local function updateAllTime(time)
        for key,def in pairs(keyDefinitions) do
            if def.updateTime == time and def.updateAll then
                return true
            end
        end
        return false
    end

    function itemData.generalUpdate(time,tribe)
        gen.validateFunctionArgument(time,moduleName,"generalUpdate",1,"time",{["string"]={custom=true, onTurn=true, onTribeTurnBegin=true, onTribeTurnEnd=true}})
        gen.validateFunctionArgument(tribe,moduleName,"generalUpdate",2,"tribe",{["nil"]=true,["userdata"]={["tribeObject"]=civ.isTribe}})
        time = time or "custom"
        if updateAllTime(time) then
            fullGeneralUpdate(time,tribe)
        else
            nonNilGeneralUpdate(time,tribe)
        end
    end

    local function onTurnUpdate(turn)
        itemData.generalUpdate("onTurn",nil)
        itemData.generalUpdate("onTribeTurnBegin",nil)
        itemData.generalUpdate("onTribeTurnEnd",nil)
    end
    onTurnFunctions[moduleName] = onTurnUpdate

    local function onTribeTurnBeginUpdate(turn,tribe)
        itemData.generalUpdate("onTribeTurnBegin",tribe)
    end
    onTribeTurnBeginFunctions[moduleName] = onTribeTurnBeginUpdate
    
    local function onTribeTurnEndUpdate(turn,tribe)
        itemData.generalUpdate("onTribeTurnEnd",tribe)
    end
    onTribeTurnEndFunctions[moduleName] = onTribeTurnEndUpdate

    --<item>Data.transferData(old<item>,new<item>)
    --  associates the <item>Data from the old <item> to the new one
    --  (deleting the association with the old one)
    --  new<item> can't be nil
    function itemData.transferData(oldItem,newItem)
        gen.validateFunctionArgument(oldItem,moduleName,"transferData",1,"old"..itemName,{["userdata"]={[itemName]=isItem}})
        gen.validateFunctionArgument(newItem,moduleName,"transferData",2,"new"..itemName,{["userdata"]={[itemName]=isItem}})
        local oldItemID = getItemID(oldItem)
        local newItemID = getItemID(newItem)
        if newItemID == oldItemID then
            error(moduleName..".transferData: both oldItem (arg1) and newItem(arg2) have the same ID number: "..newItemID)
        end
        dataTable[newItemID] = dataTable[oldItemID]
        dataTable[oldItemID] = nil
        local check1,check2,check3 = sameItemCheck(newItem)
        dataTable[newItemID][1] = check1
        dataTable[newItemID][2] = check2
        dataTable[newItemID][3] = check3
        return
    end

    --<item>Data.transferOrDeleteData(old<item>,new<item>)
    --  if new<item> is not nil, transfers the data from the
    --  old <item> to the new one (deleting the data for the old one)
    --  if new<item> is nil, the data is deleted for old<item>
    function itemData.transferOrDeleteData(oldItem,newItem)
        gen.validateFunctionArgument(oldItem,moduleName,"transferOrDeleteData",1,"old"..itemName,{["userdata"]={[itemName]=isItem}})
        gen.validateFunctionArgument(newItem,moduleName,"transferOrDeleteData",2,"new"..itemName,{["nil"]=true,["userdata"]={[itemName]=isItem}})
        local oldItemID = getItemID(oldItem)
        if newItem then
            local newItemID = getItemID(newItem)
            if newItemID == oldItemID then
                error(moduleName..".transferOrDeleteData: both oldItem (arg1) and newItem(arg2) have the same ID number: "..newItemID)
            end
            if dataTable[oldItemID] == nil then
                -- no data, so nothing to transfer
                return
            end
            dataTable[newItemID] = dataTable[oldItemID]
            dataTable[oldItemID] = nil
            local check1,check2,check3 = sameItemCheck(newItem)
            dataTable[newItemID][1] = check1
            dataTable[newItemID][2] = check2
            dataTable[newItemID][3] = check3
        else
            dataTable[oldItemID] = nil
        end
        return
    end

    --<item>Data.deleteData(<item>)
    --  deletes the data associated with the <item>
    function itemData.deleteData(item)
        gen.validateFunctionArgument(item,moduleName,"deleteData",1,itemName,{["userdata"]={[itemName]=isItem}})
        local itemID = getItemID(item)
        dataTable[itemID] = nil
        return
    end

    --<item>Data.changeValidationInfo(<item>)
    -- replaces existing values of the sameItemCheck with new ones
    function itemData.changeValidationInfo(item)
        local itemID = getItemID(item)
        if dataTable[itemID] then
            local datum = dataTable[itemID]
            local val1,val2,val3 = sameItemCheck(item)
            datum[1] = val1
            datum[2] = val2
            datum[3] = val3
        end
        return
    end

    return itemData
end


function supplementalData.linkStateToModules(state,stateTableKeys)
    for moduleName,linkStateFn in pairs(linkStateFunctions) do
        local keyName = moduleName.."State"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkStateFn(state[keyName])
    end
end

function discreteEvents.linkStateToModules(state,stateTableKeys)
    supplementalData.linkStateToModules(state,stateTableKeys)
end

function supplementalData.cullAllData()
    for _,cullFunction in pairs(cullAllDataFunctions) do
        cullFunction()
    end
end

function supplementalData.onTurn(turn)
    for _,updateFunction in pairs(onTurnFunctions) do
        updateFunction(turn)
    end
end

function supplementalData.onTribeTurnBegin(turn,tribe)
    for _,updateFunction in pairs(onTribeTurnBeginFunctions) do
        updateFunction(turn,tribe)
    end
end
        
function supplementalData.onTribeTurnEnd(turn,tribe)
    for _,updateFunction in pairs(onTribeTurnEndFunctions) do
        updateFunction(turn,tribe)
    end
    supplementalData.cullAllData()
end


return supplementalData
