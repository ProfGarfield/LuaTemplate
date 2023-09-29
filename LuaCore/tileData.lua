local versionNumber = 3
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--

--[[
This module is used to associate data with individual tiles.  Functions are used to
get the data and to change it, so you don't have to interact and maintain the underlying
tables directly.  These functions also check the data that you input, so that errors are
caught quickly rather than being saved in tables only to surface later.

This module provides "flags", which store boolean values, "counters", which store number
values, and "phrases", which store string values.  There is also some basic "generic"
data storage, which can store "state savable" data, and so is more flexible, but also has
fewer error checks and built in features.  

These flags, counters, and phrases have names, which are strings.  To access a piece of data,
you will need to have the tile it is associated with, as well as the name, and whether the
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
---@class tileData
local tileData = {}


--[[Defines a flag for tile data, which keeps boolean values
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
    - if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using tileData.update
]]
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function tileData.defineFlag(flagName,defaultValue,resetTime)
end


--[[Defines a flag for tile data, which keeps boolean values.  This version of defineFlag allows you to add a moduleName to the flag name, which will prevent name collision between modules and code written for a specific scenario.,
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
    - if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using tileData.update
]]
---@param moduleName string the name of the module
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function tileData.defineModuleFlag(moduleName,flagName,defaultValue,resetTime)
end


---Returns the value associated with the `tile`'s flag of `flagName`.
---If the value is nil, the default specified during the definition is returned.
---@param tile tileObject
---@param flagName string The name of the flag
---@param moduleName? string The name of the module (if applicable)
---@overload fun(tile:tileObject,flagName:string):boolean
---@return boolean The value associated with the `tile`'s flag of `flagName`.
function tileData.flagGetValue(tile,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the tile's flag of flagName to `true`.
---@param tile tileObject
---@param flagName string
---@param moduleName? string
---@overload fun(tile:tileObject,flagName:string)
function tileData.flagSetTrue(tile,flagName,moduleName)
end


--Sets the value associated with the tile's flag of flagName to `false`
---@param tile tileObject
---@param flagName string
---@param moduleName? string
---@overload fun(tile:tileObject,flagName:string)
function tileData.flagSetFalse(tile,flagName,moduleName)
end

--Sets the value associated with the tile's flag of flagName to the `value` 
--(true or false) specified.
---@param tile tileObject
---@param flagName string
---@param value boolean
---@param moduleName? string
function tileData.flagSetValue(tile,flagName,value,moduleName)
end

--Sets the value associated with the tile's flag of flagName to nil
--(meaning that it returns the default value set when it was defined).
---@param tile tileObject
---@param flagName string
---@param moduleName? string
---@overload fun(tile:tileObject,flagName:string)
function tileData.flagReset(tile,flagName,moduleName)
end


--Returns true if the underlying value of tile's flagName flag is nil
--(including if all of the flag's keys are nil)
--and false otherwise.
---@param tile tileObject
---@param flagName string
---@param moduleName? string
---@overload fun(tile:tileObject,flagName:string):boolean
---@return boolean
function tileData.flagIsNil(tile,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Define a counter for tile data, which keeps numerical values
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
        + "incrementAll" same as increment, but is also applied to tiles with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to tiles with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tileID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tileID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using tileData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,tileID) -> numberOrNil
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
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,tileID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function tileData.defineCounter(counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end



--[[
Defines a counter for tile data, which keeps numerical values.  This version of defineCounter allows you to add a moduleName to the counter,
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
        + "incrementAll" same as increment, but is also applied to tiles with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to tiles with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tileID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tileID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using tileData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,tileID) -> numberOrNil
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
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,tileID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function tileData.defineModuleCounter(moduleName,counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end


--Returns the value associated with the tile's counter of counterName.
--If the value is nil, the default specified during the definition is returned.
---@param tile tileObject
---@param counterName string
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string)
---@return number
function tileData.counterGetValue(tile,counterName,moduleName)
end


--Sets the value associated with the tile's counter of counterName to value.
--If this value is outside the counter's defined maxValue and minValue,
--those values are then applied.
--Returns the value the counter was set to.
---@param tile tileObject
---@param counterName string
---@param value number
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string,value:number)
---@return number
function tileData.counterSetValue(tile,counterName,value,moduleName)
end

--Adds the increment to the tile's counterName current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param tile tileObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(tile:tileObject,counterName:string,increment:number):number
---@return number
function tileData.counterAdd(tile,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Subtracts the increment to the tile's current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param tile tileObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(tile:tileObject,counterName:string,increment:number):number
---@return number
function tileData.counterSubtract(tile,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the counter's current value within the minValue and maxValue specified
--(This does not change the overall max and min set when defining the counter).
--Returns the value the counter was set to.
---@param tile tileObject
---@param counterName string
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string,minValue:number,maxValue:number):number
---@return number
function tileData.counterSetWithin(tile,counterName,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Returns true if the tile's counterName is at least the threshold
--and false otherwise.
---@param tile tileObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string,threshold:number):boolean
---@return boolean
function tileData.counterIsAtLeast(tile,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end


--Returns true if the tile's counterName is at most the threshold
--and false otherwise.
---@param tile tileObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string,threshold:number):boolean
---@return boolean
function tileData.counterIsAtMost(tile,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the tile's counterName to nil
--(meaning that it returns the default value set when it was defined).
---@param tile tileObject
---@param counterName string
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string)
---@return void
function tileData.counterReset(tile,counterName,moduleName)
end


-- Returns true if the underlying value of tile's counterName counter is nil
-- and false otherwise.
---@param tile tileObject
---@param counterName string
---@param moduleName? string
---@overload fun(tile:tileObject,counterName:string):boolean
---@return boolean
function tileData.counterIsNil(tile,counterName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Defines a phrase for tile data, which keeps string values.
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
    - If tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using tileData.update.
    - Default value is "never".
]]
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function tileData.definePhrase(phraseName,defaultValue,resetTime)
end




--[[
Defines a phrase for tile data, which keeps string values.   This version of defineCounter allows you to add a module name to the phrase name, which
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
    - If tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using tileData.update.
    - Default value is "never".
]]
---@param moduleName string The name of the module.
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function tileData.defineModulePhrase(moduleName,phraseName,defaultValue,resetTime)
end


--Returns the value associated with the tile's phrase of phraseName.
--If the associated value is nil, the default specified during the definition is returned.
---@param tile tileObject
---@param phraseName string
---@param moduleName? string
---@overload fun(tile:tileObject,phraseName:string):string
---@return string
function tileData.phraseGetValue(tile,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the value associated with tile's phraseName to value.
---@param tile tileObject
---@param phraseName string
---@param value string
---@param moduleName? string
---@overload fun(tile:tileObject,phraseName:string,value:string):void
function tileData.phraseSetValue(tile,phraseName,value,moduleName)
end


--Sets the value associated with the tile's phraseName to nil.
--(meaning that it returns the default value set when it was defined)
---@param tile tileObject
---@param phraseName string
---@param moduleName? string
---@overload fun(tile:tileObject,phraseName:string):void
function tileData.phraseReset(tile,phraseName,moduleName)
end




--Returns true if the underlying value of tile's phraseName phrase is nil, and false otherwise.
---@param tile tileObject
---@param phraseName string
---@param moduleName? string
---@overload fun(tile:tileObject,phraseName:string):boolean
---@return boolean
function tileData.phraseIsNil(tile,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end


--[[
Defines a generic entry for tile data, and can keep any item that is "state savable" (since it must be saved in the state table).
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other tileData types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using tileData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all tile, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,tileID) --> value
    - Takes the existing value for tile's generic data under dataName and the tile's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,tileID:number):any
function tileData.defineGeneric(dataName,updateTime,updateAll,updateFunction)
end




--[[
Defines a generic entry for tile data, and can keep any item that is "state savable" (since it must be saved in the state table).  This version of defineGeneric allows you 
to add a module name to the generic name, which will prevent name collisions with
generic data from other modules and code written for a specific scenario.
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other tileData types have, but it is more flexible.
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
        + if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using tileData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all tile, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,tileID) --> value
    - Takes the existing value for tile's generic data under dataName and the tile's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param moduleName string
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,tileID:number):any
function tileData.defineModuleGeneric(moduleName,dataName,updateTime,updateAll,updateFunction)
end

--Returns the value stored by the tile's keyName, or the default value if the keyName is not set.
---@param tile tileObject
---@param keyName string
---@param moduleName? string
---@overload fun(tile:tileObject,keyName:string):any
---@return any
function tileData.genericGetValue(tile,keyName,moduleName)
end

--Changes the value stored by the tile's keyName to value.
--Returns the value that was just set.
---@param tile tileObject
---@param keyName string
---@param value any
---@param moduleName? string
---@overload fun(tile:tileObject,keyName:string,value:any):any
---@return any
function tileData.genericSetValue(tile,keyName,value,moduleName)
end



--[[
Updates all of tile's data keys that have an updateTime of time, unless
key is specified, in which case, update that key only.
* time = "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Update the tile's data keys that have this updateTime.
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
---@param tile tileObject
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param tribe? tribeObject
---@param key? string
---@param moduleName? string
---@overload fun(tile:tileObject,time:"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom",tribe:number,key:string)
function tileData.update(tile,time,tribe,key,moduleName)
end





--Updates data keys that have an updateTime of `time` for all tiles.
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Default is "custom".
---@param tribe? tribeObject The tribe to consider the active tribe for onTribeTurnBegin and onTribeTurnEnd updates. Default is nil.
function tileData.generalUpdate(time,tribe)
end



--Associates the tileData from the old tile to the new one (deleting the association with the old one).
--newtile can't be nil.
---@param oldtile tileObject
---@param newtile tileObject
function tileData.transferData(oldtile,newtile)
end



--If newTile is not nil, transfers the data from the old tile to the new one (deleting the data for the old one).  If newTile is nil, the data is deleted for oldTile.
---@param oldTile tileObject
---@param newTile tileObject|nil
function tileData.transferOrDeleteData(oldTile,newTile)
end


--Deletes the data associated with the tile.
---@param tile tileObject
function tileData.deleteData(tile)
end


--Checks that the item is still the same tile it was before (i.e. that the tile hasn't been deleted and the ID reused).  If it has, eliminate all data for that tile.
---@param tile tileObject
function tileData.validate(tile)
end


--Replaces existing values of the sameItemCheck with new ones.
---@param tile tileObject
function tileData.changeValidationInfo(tile)
end





local supplementalData = require("supplementalData"):minVersion(2)
local gen = require("generalLibrary"):minVersion(1)
local civlua = require("civlua")

-- You may wish to change this depending on the needs of your particular scenario.
-- This governs when tiles are subject to tribeTurnBegin and tribeTurnEnd updates
-- (if nil, they are updated during the onTurn update instead)
local getTileOwner = function(tile) return nil end
-- tiles are never removed from the game, so they have no need of verification
local verifyTile = function(tile) return nil,nil,nil end

tileData = supplementalData.buildModuleFunctions("tileData","tile",
    civ.isTile,gen.getTileID,gen.getTileFromID,civlua.iterateTiles, getTileOwner, verifyTile)

gen.versionFunctions(tileData,versionNumber,fileModified,"LuaCore".."\\".."tileData.lua")

return tileData
