local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


-- This module provides a way to store data the same way that
-- the supplementalData module makes possible for different civ objects,
-- like the unitData, cityData, tileData, etc. modules.
-- However, this module is for data that is not associated with any
-- civ object.  It is achieved by creating supplemental data for
-- the map object for map 0, and then providing functions that
-- call the supplemental data functions for that map object.

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(9)
---@module "supplementalData"
local supplementalData = require("supplementalData"):minVersion(1)

local map0 = civ.getMap(0)
local function isMapZero(item)
    return civ.isMap(item) and item.id == 0
end
local function getMapZeroID(map)
    return 0
end
local function getMapZero(mapZeroID)
    return map0
end
local function iterateMapZero()
    return coroutine.wrap(function()
        coroutine.yield(map0)
    end)
end
-- returning nil means that onTribeTurnEnd and onTribeTurnBegin updates
-- happen during the onTurn event
local function returnTribe(map)
    return nil
end
local function verifyMapZero(map)
    return nil,nil,nil
end

local mapZeroData = supplementalData.buildModuleFunctions("[note: subtract 1 from arg# for most errors] data","_",
    isMapZero, getMapZeroID, getMapZero, iterateMapZero,
    returnTribe,verifyMapZero)



--[[
This module is used to save general data, with functionality similar
to that provided by modules like unitData and cityData.  Functions are used to
get the data and to change it, so you don't have to interact and maintain the underlying
tables directly.  These functions also check the data that you input, so that errors are
caught quickly rather than being saved in tables only to surface later.

This module provides "flags", which store boolean values, "counters", which store number
values, and "phrases", which store string values.  There is also some basic "generic"
data storage, which can store "state savable" data, and so is more flexible, but also has
fewer error checks and built in features.  

These flags, counters, and phrases have names, which are strings.  To access a piece of data,
you will need to have the name and know whether the
data is a flag, counter, or phrase.  Then, you can use one of the provided functions
to interact with that data.

By default, all data is nil.  However, flags, counters, and phrases will not return nil
when you get their values (generic, however, will).  Instead, when you define a
data entry, you will define a default value which is to be returned if the data is nil.
Functions are provided to check if the underlying value is actually nil, and to reset
the data to nil if you need to.  A data value stops being nil when you assign it an
actual value.

You can set data to update periodically, during the onTurn event.
Flags and Phrases can be reset to nil automatically, while counters and generic data
can be assigned update parameters or functions.  Usually, updates are only performed on
data which is already non-nil, but you can choose to update all if that is needed for your
functionality.  The update time can also be set to 'custom', which will only update the
data on specific function call.
]]
---@class data
local data = {}

-- These tables are used to keep track of the names of data keys
-- assigned without a module component
local flagKeyList = {}
local counterKeyList = {}
local phraseKeyList = {}
local genericKeyList = {}


--[[Defines a flag, which keeps boolean values
* flagName = string
    - the name of the flag
* defaultValue = boolean | nil
    - If the underlying stored value is nil, this is the value the flag takes on.
    - Defaults to false.
* resetTime = "never"|"onTurn"|"custom"|nil
    - Gives the time when the flag's stored value is reset to nil.
    - Defaults to "never".
    - "never" means never reset automatically
    - "onTurn" means at the very beginning of the onTurn event (before all other code)
    - "custom" means the update must be programmed in manually using data.update
]]
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function data.defineFlag(flagName,defaultValue,resetTime)
    if resetTime and resetTime ~= "never" and resetTime ~= "onTurn" and resetTime ~= "custom" then
        error("data.defineFlag: resetTime (arg #3) must be nil, 'never', 'onTurn', or 'custom'")
    end
    mapZeroData.defineFlag(flagName,defaultValue,resetTime)
    flagKeyList[1+#flagKeyList] = flagName
end


--[[Defines a flag, which keeps boolean values.  This version of defineFlag allows you to add a moduleName to the flag name, which will prevent name collision between modules and code written for a specific scenario.,
for a specific scenario.
* moduleName = string
    - the name of the module
* flagName = string
    - the name of the flag
* defaultValue = boolean | nil
    - If the underlying stored value is nil, this is the value the flag takes on.
    - Defaults to false.
* resetTime = "never"|"onTurn"|"custom"|nil
    - Gives the time when the flag's stored value is reset to nil.
    - Defaults to "never".
    - "never" means never reset automatically
    - "onTurn" means at the very beginning of the onTurn event (before all other code)
    - "custom" means the update must be programmed in manually using data.update
]]
---@param moduleName string the name of the module
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function data.defineModuleFlag(moduleName,flagName,defaultValue,resetTime)
    if resetTime and resetTime ~= "never" and resetTime ~= "onTurn" and resetTime ~= "custom" then
        error("data.defineModuleFlag: resetTime (arg #4) must be nil, 'never', 'onTurn', or 'custom'")
    end
    mapZeroData.defineModuleFlag(moduleName, flagName, defaultValue, resetTime)
end


---Returns the value associated with the flag `flagName`.
---If the value is nil, the default specified during the definition is returned.
---@param flagName string The name of the flag
---@param moduleName? string The name of the module (if applicable)
---@overload fun(flagName:string):boolean
---@return boolean The value associated with the flag `flagName`.
function data.flagGetValue(flagName,moduleName)
    return mapZeroData.flagGetValue(map0,flagName,moduleName)
end



--Sets the value associated with the flag of flagName to `true`.
---@param flagName string
---@param moduleName? string
---@overload fun(flagName:string)
function data.flagSetTrue(flagName,moduleName)
    mapZeroData.flagSetTrue(map0,flagName,moduleName)
end


--Sets the value associated with the flag flagName to `false`
---@param flagName string
---@param moduleName? string
---@overload fun(flagName:string)
function data.flagSetFalse(flagName,moduleName)
    mapZeroData.flagSetFalse(map0,flagName,moduleName)
end

--Sets the value associated with the flag flagName to the `value`
--specified (true or false).
---@param flagName string
---@param value boolean
---@param moduleName? string
---@overload fun(flagName:string,value:boolean)
function data.flagSetValue(flagName,value,moduleName)
    mapZeroData.flagSetValue(map0,flagName,value,moduleName)
end


--Sets the value associated with the flag of flagName to nil
--(meaning that it returns the default value set when it was defined).
---@param flagName string
---@param moduleName? string
---@overload fun(flagName:string)
function data.flagReset(flagName,moduleName)
    mapZeroData.flagReset(map0,flagName,moduleName)
end


--Returns true if the underlying value of flagName flag is nil
--and false otherwise.
---@param flagName string
---@param moduleName? string
---@overload fun(flagName:string):boolean
---@return boolean
function data.flagIsNil(flagName,moduleName)
    return mapZeroData.flagIsNil(map0,flagName,moduleName)
end



--[[
Define a counter for  data, which keeps numerical values
* counterName = string
    - the name of the counter
* defaultValue = number
    - If the underlying stored value is nil, this is the value the counter takes on.
    - Default is 0.
* minValue = number
    - This is the smallest number the counter can be.  If anything would set the counter below this number,
    the counter is set to this number instead.
    - Default is `-math.huge`.
* maxValue = number
    - This is the largest number the counter can be.  If anything would set the counter above this number,
    the counter is set to this number instead
    - Default is `math.huge`.
* update = "none"|"increment"|"set"|"reset"|"function"| "incrementAll"|"setAll"|"functionAll"
    - This is the kind of update the counter receives each turn
        + "none" means no update
        + "increment" means that the updateParameter is added to the current value of the counter (subject to maxValue and minValue) ,
        +   but only if the counter isn't currently nil
        + "incrementAll" same as increment, but is also applied to s with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to s with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,ID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,ID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "custom" means the update must be programmed in manually using data.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil) -> numberOrNil
    - Default is nil.
* nonInteger = bool|nil
    - if true, the counter can take on non-integer values
    - if false, the value is rounded using math.floor(initialValue+0.5)
    - if nil, an error is thrown when the counter is set to a non-integer value
    - Default is nil.
]]
---@param counterName string the name of the counter
---@param defaultValue? number If the underlying stored value is nil, this is the value the counter takes on. Default is 0.
---@param minValue? number This is the smallest number the counter can be.  If anything would set the counter below this number, the counter is set to this number instead. Default is `-math.huge`.
---@param maxValue? number This is the largest number the counter can be.  If anything would set the counter above this number, the counter is set to this number instead. Default is `math.huge`.
---@param update? "none"|"increment"|"set"|"reset"|"function"| "incrementAll"|"setAll"|"functionAll" This is the kind of update the counter receives each turn. Default is "none".
---@param updateTime? "never"|"onTurn"|"custom" Gives the time when the counter update happens. Default is "never".
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function data.defineCounter(counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
    if updateTime ~= nil and updateTime ~= "never" and updateTime ~= "onTurn" and updateTime ~= "custom" then
        error("data.defineCounter: updateTime (arg #6) must be nil, 'never', 'onTurn', or 'custom'")
    end
    if (update == "function" or update == "functionAll") and type(updateParameter) ~= "function" then
        error("data.defineCounter: when the update argument (#5) is 'function' or 'functionAll', the updateParameter argument (#7) must be a function(numberOrNil) --> numberOrNil.  Received: "..tostring(updateParameter))
    end
    mapZeroData.defineCounter(counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
    counterKeyList[1+#counterKeyList] = counterName
end



--[[
Defines a counter for  data, which keeps numerical values.  This version of defineCounter allows you to add a moduleName to the counter,
which will prevent name collisions with counters written for other modules 
and code written for a specific scenario.
* moduleName = string
    - the name of the module
* counterName = string
    - the name of the counter
* defaultValue = number
    - If the underlying stored value is nil, this is the value the counter takes on.
    - Default is 0.
* minValue = number
    - This is the smallest number the counter can be.  If anything would set the counter below this number,
    the counter is set to this number instead.
    - Default is `-math.huge`.
* maxValue = number
    - This is the largest number the counter can be.  If anything would set the counter above this number,
    the counter is set to this number instead
    - Default is `math.huge`.
* update = "none"|"increment"|"set"|"reset"|"function"| "incrementAll"|"setAll"|"functionAll"
    - This is the kind of update the counter receives each turn
        + "none" means no update
        + "increment" means that the updateParameter is added to the current value of the counter (subject to maxValue and minValue) ,
        +   but only if the counter isn't currently nil
        + "incrementAll" same as increment, but is also applied to s with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to s with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,ID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,ID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "custom" means the update must be programmed in manually using data.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,ID) -> numberOrNil
    - Default is nil.
* nonInteger = boolean|nil
    - if true, the counter can take on non-integer values
    - if false, the value is rounded using math.floor(initialValue+0.5)
    - if nil, an error is thrown when the counter is set to a non-integer value
    - Default is nil.
]]
---@param moduleName string the name of the module
---@param counterName string the name of the counter
---@param defaultValue? number If the underlying stored value is nil, this is the value the counter takes on. Default is 0.
---@param minValue? number This is the smallest number the counter can be.  If anything would set the counter below this number, the counter is set to this number instead. Default is `-math.huge`.
---@param maxValue? number This is the largest number the counter can be.  If anything would set the counter above this number, the counter is set to this number instead. Default is `math.huge`.
---@param update? "none"|"increment"|"set"|"reset"|"function"| "incrementAll"|"setAll"|"functionAll" This is the kind of update the counter receives each turn. Default is "none".
---@param updateTime? "never"|"onTurn"|"custom" Gives the time when the counter update happens. Default is "never".
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,ID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function data.defineModuleCounter(moduleName,counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
    if updateTime ~= nil and updateTime ~= "never" and updateTime ~= "onTurn" and updateTime ~= "custom" then
        error("data.defineModuleCounter: updateTime (arg #7) must be nil, 'never', 'onTurn', or 'custom'")
    end
    if (update == "function" or update == "functionAll") and type(updateParameter) ~= "function" then
        error("data.defineModuleCounter: when the update argument (#6) is 'function' or 'functionAll', the updateParameter argument (#8) must be a function(numberOrNil) --> numberOrNil.  Received: "..tostring(updateParameter))
    end
    mapZeroData.defineModuleCounter(moduleName,counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)

end


--Returns the value associated with the counter of counterName.
--If the value is nil, the default specified during the definition is returned.
---@param counterName string
---@param moduleName? string
---@overload fun(counterName:string)
---@return number
function data.counterGetValue(counterName,moduleName)
    return mapZeroData.counterGetValue(map0,counterName,moduleName)
end


--Sets the value associated with the counter of counterName to value.
--If this value is outside the counter's defined maxValue and minValue,
--those values are then applied.
--Returns the value the counter was set to.
---@param counterName string
---@param value number
---@param moduleName? string
---@overload fun(counterName:string,value:number)
---@return number
function data.counterSetValue(counterName,value,moduleName)
    mapZeroData.counterSetValue(map0,counterName,value,moduleName)
end

--Adds the increment to the counter counterName current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(counterName:string,increment:number):number
---@return number
function data.counterAdd(counterName,increment,minValue,maxValue,moduleName)
    return mapZeroData.counterAdd(map0,counterName,increment,minValue,maxValue,moduleName)
end



--Subtracts the increment from the counter's current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(counterName:string,increment:number):number
---@return number
function data.counterSubtract(counterName,increment,minValue,maxValue,moduleName)
    return mapZeroData.counterSubtract(map0,counterName,increment,minValue,maxValue,moduleName)
end




--Sets the counter's current value within the minValue and maxValue specified
--(This does not change the overall max and min set when defining the counter).
--Returns the value the counter was set to.
---@param counterName string
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(counterName:string,minValue:number,maxValue:number):number
---@return number
function data.counterSetWithin(counterName,minValue,maxValue,moduleName)
    return mapZeroData.counterSetWithin(map0,counterName,minValue,maxValue,moduleName)
end



--Returns true if the counter counterName is at least the threshold
--and false otherwise.
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(counterName:string,threshold:number):boolean
---@return boolean
function data.counterIsAtLeast(counterName,threshold,moduleName)
    return mapZeroData.counterIsAtLeast(map0,counterName,threshold,moduleName)
end


--Returns true if the counter counterName is at most the threshold
--and false otherwise.
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(counterName:string,threshold:number):boolean
---@return boolean
function data.counterIsAtMost(counterName,threshold,moduleName)
    return mapZeroData.counterIsAtMost(map0,counterName,threshold,moduleName)
end



--Sets the value associated with the counter counterName to nil
--(meaning that it returns the default value set when it was defined).
---@param counterName string
---@param moduleName? string
---@overload fun(counterName:string)
---@return void
function data.counterReset(counterName,moduleName)
    mapZeroData.counterReset(map0,counterName,moduleName)
end


-- Returns true if the underlying value of the counterName counter is nil
-- and false otherwise.
---@param counterName string
---@param moduleName? string
---@overload fun(counterName:string):boolean
---@return boolean
function data.counterIsNil(counterName,moduleName)
    return mapZeroData.counterIsNil(map0,counterName,moduleName)
end



--[[
Defines a phrase for data, which keeps string values.
* phraseName = string
    - The name of the phrase.
* defaultValue = string
    - If the underlying stored value is nil, this is the value the phrase takes on.
    - Default value is "".
* resetTime = "never"|"onTurn"|"custom"
    - Gives the time when the phrase's stored value is reset to nil.
    - "never" means never reset automatically.
    - "onTurn" means at the very beginning of the onTurn event (before all other code).
    - "custom" means the update must be programmed in manually using data.update.
    - Default value is "never".
]]
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"custom" Gives the time when the phrase's stored value is reset to nil.
---@param allowedValuesTable? table A table of allowed values for the phrase.  If this is provided, then the phrase can only be set to a string that is a key or value in the table.  If it is not provided, then any string value is allowed.
function data.definePhrase(phraseName,defaultValue,resetTime,allowedValuesTable)
    if resetTime and resetTime ~= "never" and resetTime ~= "onTurn" and resetTime ~= "custom" then
        error("data.definePhrase: resetTime (arg #3) must be nil, 'never', 'onTurn', or 'custom'")
    end
    mapZeroData.definePhrase(phraseName,defaultValue,resetTime,allowedValuesTable)
    phraseKeyList[1+#phraseKeyList] = phraseName
end




--[[
Defines a phrase, which keeps string values. This version of definePhrase allows you to add a module name to the phrase name, which
will prevent name collisions with phrases from other modules and code
written for a specific scenario.
* moduleName = string
    - The name of the module.
* phraseName = string
    - The name of the phrase.
* defaultValue = string
    - If the underlying stored value is nil, this is the value the phrase takes on.
    - Default value is "".
* resetTime = "never"|"onTurn"|"custom"
    - Gives the time when the phrase's stored value is reset to nil.
    - "never" means never reset automatically.
    - "onTurn" means at the very beginning of the onTurn event (before all other code).
    - "custom" means the update must be programmed in manually using data.update.
    - Default value is "never".
]]
---@param moduleName string The name of the module.
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"custom" Gives the time when the phrase's stored value is reset to nil.
---@param allowedValuesTable? table A table of allowed values for the phrase.  If this is provided, then the phrase can only be set to a string that is a key or value in the table.  If it is not provided, then any string value is allowed.
function data.defineModulePhrase(moduleName,phraseName,defaultValue,resetTime,allowedValuesTable)
    if resetTime and resetTime ~= "never" and resetTime ~= "onTurn" and resetTime ~= "custom" then
        error("data.defineModulePhrase: resetTime (arg #4) must be nil, 'never', 'onTurn', or 'custom'")
    end
    mapZeroData.defineModulePhrase(moduleName,phraseName,defaultValue,resetTime,allowedValuesTable)
end


--Returns the value associated with the phrase phraseName.
--If the associated value is nil, the default specified during the definition is returned.
---@param phraseName string
---@param moduleName? string
---@overload fun(phraseName:string):string
---@return string
function data.phraseGetValue(phraseName,moduleName)
    return mapZeroData.phraseGetValue(map0,phraseName,moduleName)
end




--Sets the value associated with the phrase phraseName to value.
---@param phraseName string
---@param value string
---@param moduleName? string
---@overload fun(phraseName:string,value:string):void
function data.phraseSetValue(phraseName,value,moduleName)
    mapZeroData.phraseSetValue(map0,phraseName,value,moduleName)
end


--Sets the value associated with the phrase phraseName to nil.
--(meaning that it returns the default value set when it was defined)
---@param phraseName string
---@param moduleName? string
---@overload fun(phraseName:string):void
function data.phraseReset(phraseName,moduleName)
    mapZeroData.phraseReset(map0,phraseName,moduleName)
end




--Returns true if the underlying value of the phraseName phrase is nil, and false otherwise.
---@param phraseName string
---@param moduleName? string
---@overload fun(phraseName:string):boolean
---@return boolean
function data.phraseIsNil(phraseName,moduleName)
    return mapZeroData.phraseIsNil(map0,phraseName,moduleName)
end


--[[
Defines a generic data entry, and can keep any item that is "state savable" (since it must be saved in the state table).
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other data types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "custom" means the update must be programmed in manually using data.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all , not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value) --> value
    - Takes the existing value for generic data under dataName and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param dataName string
---@param updateTime? "never"|"onTurn"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any):any
function data.defineGeneric(dataName,updateTime,updateAll,updateFunction)
    if updateTime ~= nil and updateTime ~= "never" and updateTime ~= "onTurn" and updateTime ~= "custom" then
        error("data.defineGeneric: updateTime (arg #2) must be nil, 'never', 'onTurn', or 'custom'")
    end
    mapZeroData.defineGeneric(dataName,updateTime,updateAll,updateFunction)
    genericKeyList[1+#genericKeyList] = dataName
end




--[[
Defines a generic data entry, and can keep any item that is "state savable" (since it must be saved in the state table).  This version of defineGeneric allows you 
to add a module name to the generic name, which will prevent name collisions with
generic data from other modules and code written for a specific scenario.
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other data types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* moduleName = string
    - The name of the module using this data
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "custom" means the update must be programmed in manually using data.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all , not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value) --> value
    - Takes the existing value for the generic data under dataName and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param moduleName string
---@param dataName string
---@param updateTime? "never"|"onTurn"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any):any
function data.defineModuleGeneric(moduleName,dataName,updateTime,updateAll,updateFunction)
    if updateTime ~= nil and updateTime ~= "never" and updateTime ~= "onTurn" and updateTime ~= "custom" then
        error("data.defineModuleGeneric: updateTime (arg #3) must be nil, 'never', 'onTurn', or 'custom'")
    end
    mapZeroData.defineModuleGeneric(moduleName,dataName,updateTime,updateAll,updateFunction)
end

--Returns the value stored by keyName, or the default value if the keyName is not set.
---@param keyName string
---@param moduleName? string
---@overload fun(keyName:string):any
---@return any
function data.genericGetValue(keyName,moduleName)
    return mapZeroData.genericGetValue(map0,keyName,moduleName)
end

--Changes the value stored by keyName to `value`.
--Returns the value that was just set.
---@param keyName string
---@param value any
---@param moduleName? string
---@overload fun(keyName:string,value:any):any
---@return any
function data.genericSetValue(keyName,value,moduleName)
    return mapZeroData.genericSetValue(map0,keyName,value,moduleName)
end





--[[
Updates all data keys that have an updateTime of time, unless
key is specified, in which case, update that key only.
    * time = "onTurn"|"custom"
        - Update the 's data keys that have this updateTime.
        - Default is "custom".
    * key = nil|string
        - The key to update.
        - Default is nil, in which case all keys with the updateTime specified by time are updated.
    * moduleName = nil|string
        - The name of the module using this name, if applicable.
        - Default is nil.
]]
---@param time? "onTurn"|"custom"
---@param key? string
---@param moduleName? string
---@overload fun(time:"onTurn"|"custom",key:string)
function data.update(time,key,moduleName)
    mapZeroData.update(map0,time,key,moduleName)
end




--[[ Not Necessary

--Updates data keys that have an updateTime of `time` for all s.
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Default is "custom".
---@param tribe? tribeObject The tribe to consider the active tribe for onTribeTurnBegin and onTribeTurnEnd updates. Default is nil.
function data.generalUpdate(time,tribe)
end


--]]

--[[ Not Necessary 

--Associates the data from the old  to the new one (deleting the association with the old one).
--new can't be nil.
---@param old Object
---@param new Object
function data.transferData(old,new)
end

--]]

--[[ Not Necessary

--If new is not nil, transfers the data from the old  to the new one (deleting the data for the old one).  If new is nil, the data is deleted for old.
---@param old Object
---@param new Object|nil
function data.transferOrDeleteData(old,new)
end

--]]

--[[ Not Necessary

--Deletes the data associated with the .
---@param  Object
function data.deleteData()
end

--]]

--[[ Not Necessary

--Checks that the item is still the same  it was before (i.e. that the  hasn't been deleted and the ID reused).  If it has, eliminate all data for that .
---@param  Object
function data.validate()
end

--]]

--[[ Not Necessary

--Replaces existing values of the sameItemCheck with new ones.
---@param  Object
function data.changeValidationInfo()
end

--]]



-- Returns the list of all flag keys that have been defined without
-- a module component.
---@return table
function data.listOfFlagKeys()
    return gen.copyTable(flagKeyList)
end

-- Returns the list of all counter keys that have been defined without
-- a module component.
---@return table
function data.listOfCounterKeys()
    return gen.copyTable(counterKeyList)
end

-- Returns the list of all phrase keys that have been defined without
-- a module component.
---@return table
function data.listOfPhraseKeys()
    return gen.copyTable(phraseKeyList)
end

-- Returns the list of all generic keys that have been defined without
-- a module component.
---@return table
function data.listOfGenericKeys()
    return gen.copyTable(genericKeyList)
end

if rawget(_G,"console") then
    console.data = data
end

gen.versionFunctions(data,versionNumber,fileModified,"LuaCore\\data.lua")

return data