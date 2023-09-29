
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



--[[
This module is used to associate data with individual techs.  Functions are used to
get the data and to change it, so you don't have to interact and maintain the underlying
tables directly.  These functions also check the data that you input, so that errors are
caught quickly rather than being saved in tables only to surface later.

This module provides "flags", which store boolean values, "counters", which store number
values, and "phrases", which store string values.  There is also some basic "generic"
data storage, which can store "state savable" data, and so is more flexible, but also has
fewer error checks and built in features.  

These flags, counters, and phrases have names, which are strings.  To access a piece of data,
you will need to have the tech it is associated with, as well as the name, and whether the
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
---@class techData
local techData = {}


--[[Defines a flag for tech data, which keeps boolean values
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
    - if tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using techData.update
]]
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function techData.defineFlag(flagName,defaultValue,resetTime)
end


--[[Defines a flag for tech data, which keeps boolean values.  This version of defineFlag allows you to add a moduleName to the flag name, which will prevent name collision between modules and code written for a specific scenario.,
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
    - if tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
    - during the onTurn update
    - "custom" means the update must be programmed in manually using techData.update
]]
---@param moduleName string the name of the module
---@param flagName string the name of the flag
---@param defaultValue? boolean If the underlying stored value is nil, this is the value the flag takes on. Defaults to false.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the flag's stored value is reset to nil. Defaults to "never".
function techData.defineModuleFlag(moduleName,flagName,defaultValue,resetTime)
end


---Returns the value associated with the `tech`'s flag of `flagName`.
---If the value is nil, the default specified during the definition is returned.
---@param tech techObject
---@param flagName string The name of the flag
---@param moduleName? string The name of the module (if applicable)
---@overload fun(tech:techObject,flagName:string):boolean
---@return boolean The value associated with the `tech`'s flag of `flagName`.
function techData.flagGetValue(tech,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the tech's flag of flagName to `true`.
---@param tech techObject
---@param flagName string
---@param moduleName? string
---@overload fun(tech:techObject,flagName:string)
function techData.flagSetTrue(tech,flagName,moduleName)
end


--Sets the value associated with the tech's flag of flagName to `false`
---@param tech techObject
---@param flagName string
---@param moduleName? string
---@overload fun(tech:techObject,flagName:string)
function techData.flagSetFalse(tech,flagName,moduleName)
end

--Sets the value associated with the tech's flag of flagName to the `value` 
--(true or false) specified.
---@param tech techObject
---@param flagName string
---@param value boolean
---@param moduleName? string
function techData.flagSetValue(tech,flagName,value,moduleName)
end


--Sets the value associated with the tech's flag of flagName to nil
--(meaning that it returns the default value set when it was defined).
---@param tech techObject
---@param flagName string
---@param moduleName? string
---@overload fun(tech:techObject,flagName:string)
function techData.flagReset(tech,flagName,moduleName)
end


--Returns true if the underlying value of tech's flagName flag is nil
--(including if all of the flag's keys are nil)
--and false otherwise.
---@param tech techObject
---@param flagName string
---@param moduleName? string
---@overload fun(tech:techObject,flagName:string):boolean
---@return boolean
function techData.flagIsNil(tech,flagName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Define a counter for tech data, which keeps numerical values
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
        + "incrementAll" same as increment, but is also applied to techs with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to techs with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,techID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,techID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using techData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,techID) -> numberOrNil
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
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,techID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function techData.defineCounter(counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end



--[[
Defines a counter for tech data, which keeps numerical values.  This version of defineCounter allows you to add a moduleName to the counter,
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
        + "incrementAll" same as increment, but is also applied to techs with nil as the underlying value of the counter
        + "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
        + "setAll" same as "set", but is also applied to techs with nil as the underlying value of the counter
        + "reset" sets the underlying counter value to nil
        + "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,techID) (subject to maxValue and minValue), only for underlying values which are not nil
        + "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,techID) (subject to maxValue and minValue), even for nil underlying values
    - Default is "none".
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - Gives the time when the counter update happens
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using techData.update
    - Default is "never".
* updateParameter = number|nil|function
    - if update is "increment","incrementAll", "set", "setAll" then this must be a number
    - if update is "none" or "reset", this is ignored and can be nil
    - if update is "function", this is a function(numberOrNil,techID) -> numberOrNil
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
---@param updateParameter? number|nil|function if update is "increment","incrementAll", "set", "setAll" then this must be a number. if update is "none" or "reset", this is ignored and can be nil. if update is "function", this is a function(numberOrNil,techID) -> numberOrNil. Default is nil.
---@param nonInteger? boolean|nil if true, the counter can take on non-integer values. if false, the value is rounded using math.floor(initialValue+0.5). if nil, an error is thrown when the counter is set to a non-integer value. Default is nil.
function techData.defineModuleCounter(moduleName,counterName,defaultValue,minValue,maxValue,update,updateTime,updateParameter,nonInteger)
end


--Returns the value associated with the tech's counter of counterName.
--If the value is nil, the default specified during the definition is returned.
---@param tech techObject
---@param counterName string
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string)
---@return number
function techData.counterGetValue(tech,counterName,moduleName)
end


--Sets the value associated with the tech's counter of counterName to value.
--If this value is outside the counter's defined maxValue and minValue,
--those values are then applied.
--Returns the value the counter was set to.
---@param tech techObject
---@param counterName string
---@param value number
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string,value:number)
---@return number
function techData.counterSetValue(tech,counterName,value,moduleName)
end

--Adds the increment to the tech's counterName current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param tech techObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(tech:techObject,counterName:string,increment:number):number
---@return number
function techData.counterAdd(tech,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Subtracts the increment to the tech's current value, but substituting minValue or maxValue
--if the result is out of the range.  Then, the minimum and maximum values specified
--when the counter was defined are applied (i.e. the minValue and maxValue here do not
--override the defined min and max values).
--Returns the value the counter was set to.
---@param tech techObject
---@param counterName string
---@param increment number
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string,increment:number,minValue:number,maxValue:number):number
---@overload fun(tech:techObject,counterName:string,increment:number):number
---@return number
function techData.counterSubtract(tech,counterName,increment,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the counter's current value within the minValue and maxValue specified
--(This does not change the overall max and min set when defining the counter).
--Returns the value the counter was set to.
---@param tech techObject
---@param counterName string
---@param minValue? number
---@param maxValue? number
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string,minValue:number,maxValue:number):number
---@return number
function techData.counterSetWithin(tech,counterName,minValue,maxValue,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Returns true if the tech's counterName is at least the threshold
--and false otherwise.
---@param tech techObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string,threshold:number):boolean
---@return boolean
function techData.counterIsAtLeast(tech,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end


--Returns true if the tech's counterName is at most the threshold
--and false otherwise.
---@param tech techObject
---@param counterName string
---@param threshold number
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string,threshold:number):boolean
---@return boolean
function techData.counterIsAtMost(tech,counterName,threshold,moduleName)
---@diagnostic disable-next-line: missing-return
end



--Sets the value associated with the tech's counterName to nil
--(meaning that it returns the default value set when it was defined).
---@param tech techObject
---@param counterName string
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string)
---@return void
function techData.counterReset(tech,counterName,moduleName)
end


-- Returns true if the underlying value of tech's counterName counter is nil
-- and false otherwise.
---@param tech techObject
---@param counterName string
---@param moduleName? string
---@overload fun(tech:techObject,counterName:string):boolean
---@return boolean
function techData.counterIsNil(tech,counterName,moduleName)
---@diagnostic disable-next-line: missing-return
end



--[[
Defines a phrase for tech data, which keeps string values.
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
    - If tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using techData.update.
    - Default value is "never".
]]
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function techData.definePhrase(phraseName,defaultValue,resetTime)
end




--[[
Defines a phrase for tech data, which keeps string values.   This version of definePhrase allows you to add a module name to the phrase name, which
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
    - If tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen during the onTurn update.
    - "custom" means the update must be programmed in manually using techData.update.
    - Default value is "never".
]]
---@param moduleName string The name of the module.
---@param phraseName string The name of the phrase.
---@param defaultValue? string If the underlying stored value is nil, this is the value the phrase takes on.
---@param resetTime? "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Gives the time when the phrase's stored value is reset to nil.
function techData.defineModulePhrase(moduleName,phraseName,defaultValue,resetTime)
end


--Returns the value associated with the tech's phrase of phraseName.
--If the associated value is nil, the default specified during the definition is returned.
---@param tech techObject
---@param phraseName string
---@param moduleName? string
---@overload fun(tech:techObject,phraseName:string):string
---@return string
function techData.phraseGetValue(tech,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end




--Sets the value associated with tech's phraseName to value.
---@param tech techObject
---@param phraseName string
---@param value string
---@param moduleName? string
---@overload fun(tech:techObject,phraseName:string,value:string):void
function techData.phraseSetValue(tech,phraseName,value,moduleName)
end


--Sets the value associated with the tech's phraseName to nil.
--(meaning that it returns the default value set when it was defined)
---@param tech techObject
---@param phraseName string
---@param moduleName? string
---@overload fun(tech:techObject,phraseName:string):void
function techData.phraseReset(tech,phraseName,moduleName)
end




--Returns true if the underlying value of tech's phraseName phrase is nil, and false otherwise.
---@param tech techObject
---@param phraseName string
---@param moduleName? string
---@overload fun(tech:techObject,phraseName:string):boolean
---@return boolean
function techData.phraseIsNil(tech,phraseName,moduleName)
---@diagnostic disable-next-line: missing-return
end


--[[
Defines a generic entry for tech data, and can keep any item that is "state savable" (since it must be saved in the state table).
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other techData types have, but it is more flexible.
The function `gen.isStateSavable(item)` may be useful to you.
* dataName = string
    - The name of the data entry.
* updateTime = "never"|"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
    - updateTime defines when the updateFunction is executed.
        + "never" means no update
        + "onTurn" means at the very beginning of the onTurn event (before all other code)
        + "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
        + "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
        + if tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using techData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all tech, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,techID) --> value
    - Takes the existing value for tech's generic data under dataName and the tech's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,techID:number):any
function techData.defineGeneric(dataName,updateTime,updateAll,updateFunction)
end




--[[
Defines a generic entry for tech data, and can keep any item that is "state savable" (since it must be saved in the state table).  This version of defineGeneric allows you 
to add a module name to the generic name, which will prevent name collisions with
generic data from other modules and code written for a specific scenario.
An item is "state savable" if it is one of the following:
    - nil
    - a number
    - a string
    - a boolean
    - a table with keys that are numbers or strings and with values that are also state savable
"generic" data doesn't have the same guards against misuse that the other techData types have, but it is more flexible.
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
        + if tech has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
        during the onTurn update
        + "custom" means the update must be programmed in manually using techData.update
    - Default is "never".
* updateAll = nil|boolean
    - If true, the update function is applied to all tech, not just those with non-nil values for this generic data.
    - Default is nil.
* updateFunction = function(value,techID) --> value
    - Takes the existing value for tech's generic data under dataName and the tech's ID number, and produces a new value for the generic data under dataName.
    - Default is nil.  However, this is only valid if updateTime is "never".
]]
---@param moduleName string
---@param dataName string
---@param updateTime? "never"|"onTurn"| "onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param updateAll? boolean
---@param updateFunction? fun(value:any,techID:number):any
function techData.defineModuleGeneric(moduleName,dataName,updateTime,updateAll,updateFunction)
end

--Returns the value stored by the tech's keyName, or the default value if the keyName is not set.
---@param tech techObject
---@param keyName string
---@param moduleName? string
---@overload fun(tech:techObject,keyName:string):any
---@return any
function techData.genericGetValue(tech,keyName,moduleName)
end

--Changes the value stored by the tech's keyName to value.
--Returns the value that was just set.
---@param tech techObject
---@param keyName string
---@param value any
---@param moduleName? string
---@overload fun(tech:techObject,keyName:string,value:any):any
---@return any
function techData.genericSetValue(tech,keyName,value,moduleName)
end



--[[
Updates all of tech's data keys that have an updateTime of time, unless
key is specified, in which case, update that key only.
    * time = "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
        - Update the tech's data keys that have this updateTime.
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
---@param tech techObject
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom"
---@param tribe? tribeObject
---@param key? string
---@param moduleName? string
---@overload fun(tech:techObject,time:"onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom",tribe:number,key:string)
function techData.update(tech,time,tribe,key,moduleName)
end





--Updates data keys that have an updateTime of `time` for all techs.
---@param time? "onTurn"|"onTribeTurnBegin"|"onTribeTurnEnd"|"custom" Default is "custom".
---@param tribe? tribeObject The tribe to consider the active tribe for onTribeTurnBegin and onTribeTurnEnd updates. Default is nil.
function techData.generalUpdate(time,tribe)
end



--Associates the techData from the old tech to the new one (deleting the association with the old one).
--newtech can't be nil.
---@param oldtech techObject
---@param newtech techObject
function techData.transferData(oldtech,newtech)
end



--If newtech is not nil, transfers the data from the old tech to the new one (deleting the data for the old one).  If newtech is nil, the data is deleted for oldtech.
---@param oldtech techObject
---@param newtech techObject|nil
function techData.transferOrDeleteData(oldtech,newtech)
end


--Deletes the data associated with the tech.
---@param tech techObject
function techData.deleteData(tech)
end


--Checks that the item is still the same tech it was before (i.e. that the tech hasn't been deleted and the ID reused).  If it has, eliminate all data for that tech.
---@param tech techObject
function techData.validate(tech)
end


--Replaces existing values of the sameItemCheck with new ones.
---@param tech techObject
function techData.changeValidationInfo(tech)
end

---@module "supplementalData"
local supplementalData = require("supplementalData"):minVersion(2)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(10)
gen.minEventsLuaVersion(1,1,"LuaCore\\techData.lua")

local getTechID = function(tech) return tech.id end
local getTechOwner = function(tech) return nil end
local verifyTech = function(tech) return nil,nil,nil end

techData = supplementalData.buildModuleFunctions(
    "techData","tech",civ.isTech,getTechID,
    civ.getTech,gen.iterateTechs,getTechOwner,verifyTech)

gen.versionFunctions(techData,versionNumber,fileModified,"LuaCore\\techData.lua")
return techData