local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


---@class wonderObject


--[[
This module is used to associate data with individual wonders.  Functions are used to
get the data and to change it, so you don't have to interact and maintain the underlying
tables directly.  These functions also check the data that you input, so that errors are
caught quickly rather than being saved in tables only to surface later.

This module provides "flags", which store boolean values, "counters", which store number
values, and "phrases", which store string values.  There is also some basic "generic"
data storage, which can store "state savable" data, and so is more flexible, but also has
fewer error checks and built in features.  

These flags, counters, and phrases have names, which are strings.  To access a piece of data,
you will need to have the wonder it is associated with, as well as the name, and whether the
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
---@class wonderData
local wonderData = {}


--[[Defines a flag for wonder data, which keeps boolean values
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
    - if wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using wonderData.update
]]
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function wonderData.defineFlag(flagName,defaultValue,resetTime)
end


--[[Defines a flag for wonder data, which keeps boolean values.  This version of defineFlag allows you to add a moduleName to the flag name, which will prevent name collision between modules and code written for a specific scenario.,
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
    - if wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using wonderData.update
]]
---@param moduleName string the name of the module
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function wonderData.defineModuleFlag(moduleName,flagName,defaultValue,resetTime)
end


---Returns the value associated with the `wonder`'s flag of `flagName`.
---If the value is nil, the default specified during the definition is returned.
---@param wonder wonderObject
---@param flagName string The name of the flag
---@param moduleName? string The name of the module (if applicable)
---@overload fun(wonder:wonderObject,flagName:string):boolean
---@return boolean The value associated with the `wonder`'s flag of `flagName`.
function wonderData.flagGetValue(wonder,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the wonder's flag of flagName to `true`.
---@param wonder wonderObject
---@param flagName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,flagName:string)
function wonderData.flagSetTrue(wonder,flagName,moduleName)
end


--Sets the value associated with the wonder's flag of flagName to `false`
---@param wonder wonderObject
---@param flagName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,flagName:string)
function wonderData.flagSetFalse(wonder,flagName,moduleName)
end

--Sets the value associated with the wonder's flag of flagName to the `value` 
--(true or false) specified.
---@param wonder wonderObject
---@param flagName string
---@param value boolean
---@param moduleName? string
function wonderData.flagSetValue(wonder,flagName,value,moduleName)
end


--Sets the value associated with the wonder's flag of flagName to nil
--(meaning that it returns the default value set when it was defined).
---@param wonder wonderObject
---@param flagName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,flagName:string)
function wonderData.flagReset(wonder,flagName,moduleName)
end


--Returns true if the underlying value of wonder's flagName flag is nil
--(including if all of the flag's keys are nil)
--and false otherwise.
---@param wonder wonderObject
---@param flagName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,flagName:string):boolean
---@return boolean
function wonderData.flagIsNil(wonder,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Define a counter for wonder data, which keeps numerical values
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
        + "incrementAll" same as increment, but is also applied to wonders with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to wonders with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,wonderID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,wonderID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using wonderData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,wonderID) -> numberOrNil
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
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,wonderID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function wonderData.defineCounter(counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end



--[[
Defines a counter for wonder data, which keeps numerical values.  This version of defineCounter allows you to add a moduleName to the counter,
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
        + "incrementAll" same as increment, but is also applied to wonders with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to wonders with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,wonderID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,wonderID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using wonderData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,wonderID) -> numberOrNil
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
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,wonderID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function wonderData.defineModuleCounter(moduleName,counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end


--Returns the value associated with the wonder's counter of counterName.
--If the value is nil, the default specified during the definition is returned.
---@param wonder wonderObject
---@param counterName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string)
---@return number
function wonderData.counterGetValue(wonder,counterName,moduleName)
end


--Sets the value associated with the wonder's counter of counterName to value.
--If this value is outside the counter's defined maxValue and minValue,
--those values are then applied.
--Returns the value the counter was set to.
---@param wonder wonderObject
---@param counterName string
---@param value number
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string,value:number)
---@return number
function wonderData.counterSetValue(wonder,counterName,value,moduleName)
end

--Adds the increment to the wonder's counterName current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param wonder wonderObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(wonder:wonderObject,counterName:string,increment:number):number
---@return number
function wonderData.counterAdd(wonder,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Subtracts the increment to the wonder's current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param wonder wonderObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(wonder:wonderObject,counterName:string,increment:number):number
---@return number
function wonderData.counterSubtract(wonder,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the counter's current value within the minValue and maxValue specified
--(This does not change the overall max and min set when defining the counter).
--Returns the value the counter was set to.
---@param wonder wonderObject
---@param counterName string
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string,minValue:number,maxValue:number):number
---@return number
function wonderData.counterSetWithin(wonder,counterName,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Returns true if the wonder's counterName is at least the threshold
--and false otherwise.
---@param wonder wonderObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string,threshold:number):boolean
---@return boolean
function wonderData.counterIsAtLeast(wonder,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end


--Returns true if the wonder's counterName is at most the threshold
--and false otherwise.
---@param wonder wonderObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string,threshold:number):boolean
---@return boolean
function wonderData.counterIsAtMost(wonder,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the wonder's counterName to nil
--(meaning that it returns the default value set when it was defined).
---@param wonder wonderObject
---@param counterName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string)
---@return void
function wonderData.counterReset(wonder,counterName,moduleName)
end


-- Returns true if the underlying value of wonder's counterName counter is nil
-- and false otherwise.
---@param wonder wonderObject
---@param counterName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,counterName:string):boolean
---@return boolean
function wonderData.counterIsNil(wonder,counterName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Defines a phrase for wonder data, which keeps string values.
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
    - If wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using wonderData.update.
    - Default value is "never".
]]
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function wonderData.definePhrase(phraseName,defaultValue,resetTime)
end




--[[
Defines a phrase for wonder data, which keeps string values.   This version of definePhrase allows you to add a module name to the phrase name, which
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
    - If wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using wonderData.update.
    - Default value is "never".
]]
---@param moduleName string The name of the module.
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function wonderData.defineModulePhrase(moduleName,phraseName,defaultValue,resetTime)
end


--Returns the value associated with the wonder's phrase of phraseName.
--If the associated value is nil, the default specified during the definition is returned.
---@param wonder wonderObject
---@param phraseName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,phraseName:string):string
---@return string
function wonderData.phraseGetValue(wonder,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the value associated with wonder's phraseName to value.
---@param wonder wonderObject
---@param phraseName string
---@param value string
---@param moduleName? string
---@overload fun(wonder:wonderObject,phraseName:string,value:string):void
function wonderData.phraseSetValue(wonder,phraseName,value,moduleName)
end


--Sets the value associated with the wonder's phraseName to nil.
--(meaning that it returns the default value set when it was defined)
---@param wonder wonderObject
---@param phraseName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,phraseName:string):void
function wonderData.phraseReset(wonder,phraseName,moduleName)
end




--Returns true if the underlying value of wonder's phraseName phrase is nil, and false otherwise.
---@param wonder wonderObject
---@param phraseName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,phraseName:string):boolean
---@return boolean
function wonderData.phraseIsNil(wonder,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end


--[[
Defines a generic entry for wonder data, and can keep any item that is "state savable" (since it must be saved in the state table).
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other wonderData types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using wonderData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all wonder, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,wonderID) --> value
    - Takes the existing value for wonder's generic data under dataName and the wonder's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,wonderID:number):any
function wonderData.defineGeneric(dataName,updateTime,updateAll,updateFunction)
end




--[[
Defines a generic entry for wonder data, and can keep any item that is "state savable" (since it must be saved in the state table).  This version of defineGeneric allows you 
to add a module name to the generic name, which will prevent name collisions with
generic data from other modules and code written for a specific scenario.
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other wonderData types have, but it is more flexible.
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
        + if wonder has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using wonderData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all wonder, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,wonderID) --> value
    - Takes the existing value for wonder's generic data under dataName and the wonder's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param moduleName string
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,wonderID:number):any
function wonderData.defineModuleGeneric(moduleName,dataName,updateTime,updateAll,updateFunction)
end

--Returns the value stored by the wonder's keyName, or the default value if the keyName is not set.
---@param wonder wonderObject
---@param keyName string
---@param moduleName? string
---@overload fun(wonder:wonderObject,keyName:string):any
---@return any
function wonderData.genericGetValue(wonder,keyName,moduleName)
end

--Changes the value stored by the wonder's keyName to value.
--Returns the value that was just set.
---@param wonder wonderObject
---@param keyName string
---@param value any
---@param moduleName? string
---@overload fun(wonder:wonderObject,keyName:string,value:any):any
---@return any
function wonderData.genericSetValue(wonder,keyName,value,moduleName)
end



--[[
Updates all of wonder's data keys that have an updateTime of time, unless
key is specified, in which case, update that key only.
    * time = "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
        - Update the wonder's data keys that have this updateTime.
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
---@param wonder wonderObject
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param tribe? tribeObject
---@param key? string
---@param moduleName? string
---@overload fun(wonder:wonderObject,time:"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom",tribe:number,key:string)
function wonderData.update(wonder,time,tribe,key,moduleName)
end





--Updates data keys that have an updateTime of `time` for all wonders.
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Default is "custom".
---@param tribe? tribeObject The tribe to consider the active tribe for onTribeTurnBegin and onTribeTurnEnd updates. Default is nil.
function wonderData.generalUpdate(time,tribe)
end



--Associates the wonderData from the old wonder to the new one (deleting the association with the old one).
--newwonder can't be nil.
---@param oldwonder wonderObject
---@param newwonder wonderObject
function wonderData.transferData(oldwonder,newwonder)
end



--If newwonder is not nil, transfers the data from the old wonder to the new one (deleting the data for the old one).  If newwonder is nil, the data is deleted for oldwonder.
---@param oldwonder wonderObject
---@param newwonder wonderObject|nil
function wonderData.transferOrDeleteData(oldwonder,newwonder)
end


--Deletes the data associated with the wonder.
---@param wonder wonderObject
function wonderData.deleteData(wonder)
end


--Checks that the item is still the same wonder it was before (i.e. that the wonder hasn't been deleted and the ID reused).  If it has, eliminate all data for that wonder.
---@param wonder wonderObject
function wonderData.validate(wonder)
end


--Replaces existing values of the sameItemCheck with new ones.
---@param wonder wonderObject
function wonderData.changeValidationInfo(wonder)
end


---@module "supplementalData"
local supplementalData = require("supplementalData"):minVersion(2)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(10)
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."wonderData.lua")

local getWonderID = function(wonder) return wonder.id end
local getWonderTribe = function(wonder) return (wonder.city and wonder.city.owner) end
local verifyWonder = function(wonder) return nil,nil,nil end

wonderData = supplementalData.buildModuleFunctions(
    "wonderData","wonder",civ.isWonder,getWonderID,
    civ.getWonder,gen.iterateWonders,getWonderTribe,
    verifyWonder)

gen.versionFunctions(wonderData,versionNumber,fileModified,"LuaCore\\wonderData.lua")
return wonderData