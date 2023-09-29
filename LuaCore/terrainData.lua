
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


---@class terrainObject

--[[
This module is used to associate data with individual terrains.  Functions are used to
get the data and to change it, so you don't have to interact and maintain the underlying
tables directly.  These functions also check the data that you input, so that errors are
caught quickly rather than being saved in tables only to surface later.

This module provides "flags", which store boolean values, "counters", which store number
values, and "phrases", which store string values.  There is also some basic "generic"
data storage, which can store "state savable" data, and so is more flexible, but also has
fewer error checks and built in features.  

These flags, counters, and phrases have names, which are strings.  To access a piece of data,
you will need to have the terrain it is associated with, as well as the name, and whether the
data is a flag, counter, or phrase.  Then, you can use one of the provided functions
to interact with that data.

By default, all data is nil.  However, flags, counters, and phrases will not return nil
when you get their values (generic, however, will).  Instead, when you define a
data entry, you will define a default value which is to be returned if the data is nil.
Functions are provided to check if the underlying value is actually nil, and to reset
the data to nil if you need to.  A data value stops being nil when you assign it an
actual value.

You can set data to update periodically, during onTurn, onTribeTurnBegin, or onTribeTurnEnd
events.  Flags and Phrases can be reset to nil automatically, while counters and generic data
can be assigned update parameters or functions.  Usually, updates are only performed on
data which is already non-nil, but you can choose to update all if that is needed for your
functionality.  The update time can also be set to 'custom', which will only update the
data on specific function call.
]]
---@class terrainData
local terrainData = {}


--[[Defines a flag for terrain data, which keeps boolean values
* flagName = string
    - the name of the flag
* defaultValue = boolean | nil
    - If the underlying stored value is nil, this is the value the flag takes on.
    - Defaults to false.
* resetTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"|nil
    - Gives the time when the flag's stored value is reset to nil.
    - Defaults to "never".
    - "never" means never reset automatically
    - "onTurn" means at the very beginning of the onTurn event (before all other code)
    - "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
    - "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
    - if terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using terrainData.update
]]
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function terrainData.defineFlag(flagName,defaultValue,resetTime)
end


--[[Defines a flag for terrain data, which keeps boolean values.  This version of defineFlag allows you to add a moduleName to the flag name, which will prevent name collision between modules and code written for a specific scenario.,
for a specific scenario.
* moduleName = string
    - the name of the module
* flagName = string
    - the name of the flag
* defaultValue = boolean | nil
    - If the underlying stored value is nil, this is the value the flag takes on.
    - Defaults to false.
* resetTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"|nil
    - Gives the time when the flag's stored value is reset to nil.
    - Defaults to "never".
    - "never" means never reset automatically
    - "onTurn" means at the very beginning of the onTurn event (before all other code)
    - "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
    - "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
    - if terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using terrainData.update
]]
---@param moduleName string the name of the module
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function terrainData.defineModuleFlag(moduleName,flagName,defaultValue,resetTime)
end


---Returns the value associated with the `terrain`'s flag of `flagName`.
---If the value is nil, the default specified during the definition is returned.
---@param terrain terrainObject
---@param flagName string The name of the flag
---@param moduleName? string The name of the module (if applicable)
---@overload fun(terrain:terrainObject,flagName:string):boolean
---@return boolean The value associated with the `terrain`'s flag of `flagName`.
function terrainData.flagGetValue(terrain,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the terrain's flag of flagName to `true`.
---@param terrain terrainObject
---@param flagName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,flagName:string)
function terrainData.flagSetTrue(terrain,flagName,moduleName)
end


--Sets the value associated with the terrain's flag of flagName to `false`
---@param terrain terrainObject
---@param flagName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,flagName:string)
function terrainData.flagSetFalse(terrain,flagName,moduleName)
end

--Sets the value associated with the terrain's flag of flagName to the `value` 
--(true or false) specified.
---@param terrain terrainObject
---@param flagName string
---@param value boolean
---@param moduleName? string
function terrainData.flagSetValue(terrain,flagName,value,moduleName)
end


--Sets the value associated with the terrain's flag of flagName to nil
--(meaning that it returns the default value set when it was defined).
---@param terrain terrainObject
---@param flagName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,flagName:string)
function terrainData.flagReset(terrain,flagName,moduleName)
end


--Returns true if the underlying value of terrain's flagName flag is nil
--(including if all of the flag's keys are nil)
--and false otherwise.
---@param terrain terrainObject
---@param flagName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,flagName:string):boolean
---@return boolean
function terrainData.flagIsNil(terrain,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Define a counter for terrain data, which keeps numerical values
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
        + "incrementAll" same as increment, but is also applied to terrains with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to terrains with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,terrainID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,terrainID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using terrainData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,terrainID) -> numberOrNil
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
---@param updateTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the counter update happens. Default is "never".
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,terrainID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function terrainData.defineCounter(counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end



--[[
Defines a counter for terrain data, which keeps numerical values.  This version of defineCounter allows you to add a moduleName to the counter,
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
        + "incrementAll" same as increment, but is also applied to terrains with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to terrains with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,terrainID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,terrainID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using terrainData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,terrainID) -> numberOrNil
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
---@param updateTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the counter update happens. Default is "never".
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,terrainID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function terrainData.defineModuleCounter(moduleName,counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end


--Returns the value associated with the terrain's counter of counterName.
--If the value is nil, the default specified during the definition is returned.
---@param terrain terrainObject
---@param counterName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string)
---@return number
function terrainData.counterGetValue(terrain,counterName,moduleName)
end


--Sets the value associated with the terrain's counter of counterName to value.
--If this value is outside the counter's defined maxValue and minValue,
--those values are then applied.
--Returns the value the counter was set to.
---@param terrain terrainObject
---@param counterName string
---@param value number
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string,value:number)
---@return number
function terrainData.counterSetValue(terrain,counterName,value,moduleName)
end

--Adds the increment to the terrain's counterName current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param terrain terrainObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(terrain:terrainObject,counterName:string,increment:number):number
---@return number
function terrainData.counterAdd(terrain,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Subtracts the increment to the terrain's current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param terrain terrainObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(terrain:terrainObject,counterName:string,increment:number):number
---@return number
function terrainData.counterSubtract(terrain,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the counter's current value within the minValue and maxValue specified
--(This does not change the overall max and min set when defining the counter).
--Returns the value the counter was set to.
---@param terrain terrainObject
---@param counterName string
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string,minValue:number,maxValue:number):number
---@return number
function terrainData.counterSetWithin(terrain,counterName,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Returns true if the terrain's counterName is at least the threshold
--and false otherwise.
---@param terrain terrainObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string,threshold:number):boolean
---@return boolean
function terrainData.counterIsAtLeast(terrain,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end


--Returns true if the terrain's counterName is at most the threshold
--and false otherwise.
---@param terrain terrainObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string,threshold:number):boolean
---@return boolean
function terrainData.counterIsAtMost(terrain,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the terrain's counterName to nil
--(meaning that it returns the default value set when it was defined).
---@param terrain terrainObject
---@param counterName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string)
---@return void
function terrainData.counterReset(terrain,counterName,moduleName)
end


-- Returns true if the underlying value of terrain's counterName counter is nil
-- and false otherwise.
---@param terrain terrainObject
---@param counterName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,counterName:string):boolean
---@return boolean
function terrainData.counterIsNil(terrain,counterName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Defines a phrase for terrain data, which keeps string values.
* phraseName = string
    - The name of the phrase.
* defaultValue = string
    - If the underlying stored value is nil, this is the value the phrase takes on.
    - Default value is "".
* resetTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the phrase's stored value is reset to nil.
    - "never" means never reset automatically.
    - "onTurn" means at the very beginning of the onTurn event (before all other code).
    - "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code).
    - "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code).
    - If terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using terrainData.update.
    - Default value is "never".
]]
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function terrainData.definePhrase(phraseName,defaultValue,resetTime)
end




--[[
Defines a phrase for terrain data, which keeps string values.   This version of definePhrase allows you to add a module name to the phrase name, which
will prevent name collisions with phrases from other modules and code
written for a specific scenario.
* moduleName = string
    - The name of the module.
* phraseName = string
    - The name of the phrase.
* defaultValue = string
    - If the underlying stored value is nil, this is the value the phrase takes on.
    - Default value is "".
* resetTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the phrase's stored value is reset to nil.
    - "never" means never reset automatically.
    - "onTurn" means at the very beginning of the onTurn event (before all other code).
    - "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code).
    - "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code).
    - If terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using terrainData.update.
    - Default value is "never".
]]
---@param moduleName string The name of the module.
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function terrainData.defineModulePhrase(moduleName,phraseName,defaultValue,resetTime)
end


--Returns the value associated with the terrain's phrase of phraseName.
--If the associated value is nil, the default specified during the definition is returned.
---@param terrain terrainObject
---@param phraseName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,phraseName:string):string
---@return string
function terrainData.phraseGetValue(terrain,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the value associated with terrain's phraseName to value.
---@param terrain terrainObject
---@param phraseName string
---@param value string
---@param moduleName? string
---@overload fun(terrain:terrainObject,phraseName:string,value:string):void
function terrainData.phraseSetValue(terrain,phraseName,value,moduleName)
end


--Sets the value associated with the terrain's phraseName to nil.
--(meaning that it returns the default value set when it was defined)
---@param terrain terrainObject
---@param phraseName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,phraseName:string):void
function terrainData.phraseReset(terrain,phraseName,moduleName)
end




--Returns true if the underlying value of terrain's phraseName phrase is nil, and false otherwise.
---@param terrain terrainObject
---@param phraseName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,phraseName:string):boolean
---@return boolean
function terrainData.phraseIsNil(terrain,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end


--[[
Defines a generic entry for terrain data, and can keep any item that is "state savable" (since it must be saved in the state table).
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other terrainData types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using terrainData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all terrain, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,terrainID) --> value
    - Takes the existing value for terrain's generic data under dataName and the terrain's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,terrainID:number):any
function terrainData.defineGeneric(dataName,updateTime,updateAll,updateFunction)
end




--[[
Defines a generic entry for terrain data, and can keep any item that is "state savable" (since it must be saved in the state table).  This version of defineGeneric allows you 
to add a module name to the generic name, which will prevent name collisions with
generic data from other modules and code written for a specific scenario.
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other terrainData types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* moduleName = string
    - The name of the module using this data
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if terrain has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using terrainData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all terrain, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,terrainID) --> value
    - Takes the existing value for terrain's generic data under dataName and the terrain's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param moduleName string
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,terrainID:number):any
function terrainData.defineModuleGeneric(moduleName,dataName,updateTime,updateAll,updateFunction)
end

--Returns the value stored by the terrain's keyName, or the default value if the keyName is not set.
---@param terrain terrainObject
---@param keyName string
---@param moduleName? string
---@overload fun(terrain:terrainObject,keyName:string):any
---@return any
function terrainData.genericGetValue(terrain,keyName,moduleName)
end

--Changes the value stored by the terrain's keyName to value.
--Returns the value that was just set.
---@param terrain terrainObject
---@param keyName string
---@param value any
---@param moduleName? string
---@overload fun(terrain:terrainObject,keyName:string,value:any):any
---@return any
function terrainData.genericSetValue(terrain,keyName,value,moduleName)
end



--[[
Updates all of terrain's data keys that have an updateTime of time, unless
key is specified, in which case, update that key only.
    * time = "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
        - Update the terrain's data keys that have this updateTime.
        - Default is "custom".
    * tribe = nil|tribeObject
        - The tribe to consider the active tribe for onTribeTurnBegin and onTribeTurnEnd updates.
        - Default is nil.
    * key = nil|string
        - The key to update.
        - Default is nil, in which case all keys with the updateTime specified by time are updated.
    * moduleName = nil|string
        - The name of the module using this name, if applicable.
        - Default is nil.
]]
---@param terrain terrainObject
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param tribe? tribeObject
---@param key? string
---@param moduleName? string
---@overload fun(terrain:terrainObject,time:"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom",tribe:number,key:string)
function terrainData.update(terrain,time,tribe,key,moduleName)
end





--Updates data keys that have an updateTime of `time` for all terrains.
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Default is "custom".
---@param tribe? tribeObject The tribe to consider the active tribe for onTribeTurnBegin and onTribeTurnEnd updates. Default is nil.
function terrainData.generalUpdate(time,tribe)
end



--Associates the terrainData from the old terrain to the new one (deleting the association with the old one).
--newterrain can't be nil.
---@param oldterrain terrainObject
---@param newterrain terrainObject
function terrainData.transferData(oldterrain,newterrain)
end



--If newterrain is not nil, transfers the data from the old terrain to the new one (deleting the data for the old one).  If newterrain is nil, the data is deleted for oldterrain.
---@param oldterrain terrainObject
---@param newterrain terrainObject|nil
function terrainData.transferOrDeleteData(oldterrain,newterrain)
end


--Deletes the data associated with the terrain.
---@param terrain terrainObject
function terrainData.deleteData(terrain)
end


--Checks that the item is still the same terrain it was before (i.e. that the terrain hasn't been deleted and the ID reused).  If it has, eliminate all data for that terrain.
---@param terrain terrainObject
function terrainData.validate(terrain)
end


--Replaces existing values of the sameItemCheck with new ones.
---@param terrain terrainObject
function terrainData.changeValidationInfo(terrain)
end

---@module "supplementalData"
local supplementalData = require("supplementalData"):minVersion(2)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(10)
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."terrainData.lua")

local getTerrainID = gen.getTerrainID
local getTerrainOwner = function(terrain) return nil end
local verifyTerrain = function(terrain) return nil,nil,nil end
local getTerrainFromID = gen.getTerrainFromID

terrainData = supplementalData.buildModuleFunctions(
    "terrainData","terrain",civ.isTerrain,getTerrainID,
    getTerrainFromID,gen.iterateTerrain,getTerrainOwner,
    verifyTerrain)

gen.versionFunctions(terrainData,versionNumber,fileModified,"LuaCore\\terrainData.lua")

return terrainData