local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--  This module is used to associate data with individual tribes.  Functions are used to
--  get the data and to change it, so you don't have to interact and maintain the underlying
--  tables directly.  These functions also check the data that you input, so that errors are
--  caught quickly rather than being saved in tables only to surface later.
--
--  This module provides "flags", which store boolean values, "counters", which store number
--  values, and "phrases", which store string values.  There is also some basic "generic"
--  data storage, which can store "state savable" data, and so is more flexible, but also has
--  fewer error checks and built in features.  
--
--  These flags, counters, and phrases have names, which are strings.  To access a piece of data,
--  you will need to have the tribe it is associated with, as well as the name, and whether the
--  data is a flag, counter, or phrase.  Then, you can use one of the provided functions
--  to interact with that data.
--
--  By default, all data is nil.  However, flags, counters, and phrases will not return nil
--  when you get their values (generic, however, will).  Instead, when you define a
--  data entry, you will define a default value which is to be returned if the data is nil.
--  Functions are provided to check if the underlying value is actually nil, and to reset
--  the data to nil if you need to.  A data value stops being nil when you assign it an
--  actual value.
--
--  You can set data to update periodically, during onTurn, onTribeTurnBegin, or onTribeTurnEnd
--  events.  Flags and Phrases can be reset to nil automatically, while counters and generic data
--  can be assigned update parameters or functions.  Usually, updates are only performed on
--  data which is already non-nil, but you can choose to update all if that is needed for your
--  functionality.  The update time can also be set to 'custom', which will only update the
--  data on specific function call.
--
--


--      Note that flag, counter, and phrase names must be distinct, even between data types.
--      That is, flag names must be different from counter names and phrase names, etc.

--  tribeData.defineFlag(flagName,defaultValue=false,resetTime="never")
--      Defines a flag for tribe data, which keeps boolean values
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
--          if tribe has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using tribeData.update
--          

--  tribeData.defineModuleFlag(moduleName,flagName,defaultValue=false,resetTime="never")

--      Note: The optional parameter of moduleName prevents name conflicts
--      for flags used in a module/library.  

--  tribeData.flagGetValue(tribe,flagName) --> boolean
--  tribeData.flagGetValue(tribe,flagName,moduleName=nil) --> boolean
--      returns the value associated with the tribe's flag of flagName
--      if the value is nil, the default specified during the definition is returned

--  tribeData.flagSetTrue(tribe,flagName) --> void
--  tribeData.flagSetTrue(tribe,flagName,moduleName=nil) --> void
--      sets the value associated with the tribe's flag of flagName to True

--  tribeData.flagSetFalse(tribe,flagName) --> void
--  tribeData.flagSetFalse(tribe,flagName,moduleName=nil) --> void
--      sets the value associated with the tribe's flag of flagName to false

--  tribeData.flagReset(tribe,flagName) --> void
--  tribeData.flagReset(tribe,flagName,moduleName=nil) --> void
--      sets the value associated with the tribe's flag of flagName to nil,
--      (meaning that it returns the default value set when it was defined)

--  tribeData.flagIsNil(tribe,flagName) --> boolean
--  tribeData.flagIsNil(tribe,flagName,moduleName=nil) --> boolean
--      returns true if the underlying value of tribe's flagName flag is nil
--      (including if all keys are nil)
--      and false otherwise



-- tribeData.defineCounter(counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)
--      Defines a counter for tribe data, which keeps numerical values
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
--          "incrementAll" same as increment, but is also applied to tribes with nil as the underlying value of the counter
--          "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
--          "setAll" same as "set", but is also applied to tribes with nil as the underlying value of the counter
--          "reset" sets the underlying counter value to nil
--          "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tribeID) (subject to maxValue and minValue), only for underlying values which are not nil
--          "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tribeID) (subject to maxValue and minValue), even for nil underlying values
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          Gives the time when the counter update happens
--          "never" means no update
--          "onTurn" means at the very beginning of the onTurn event (before all other code)
--          "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
--          "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
--          if tribe has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using tribeData.update
--      updateParameter = number, nil, or function
--          if update is "increment","incrementAll", "set", "setAll" then this must be a number
--          if update is "none" or "reset", this is ignored and can be nil
--          if update is "function", this is a function(numberOrNil,<itemID>) -> numberOrNil
--      nonInteger = bool or nil
--          if true, the counter can take on non-integer values
--          if false, the value is rounded using math.floor(initialValue+0.5)
--          if nil, an error is thrown when the counter is set to a non-integer value


--  tribeData.defineModuleCounter(moduleName,counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)


--  tribeData.counterGetValue(tribe,counterName) --> number
--  tribeData.counterGetValue(tribe,counterName, moduleName=nil) --> number
--      returns the value associated with the tribe's counter of counterName
--      if the value is nil, the default specified during the definition is returned


--  tribeData.counterSetValue(tribe,counterName,value) --> number
--  tribeData.counterSetValue(tribe,counterName,value,moduleName=nil) --> number
--      sets the value of the tribe's counterName to the specified value
--      if this value is outside the counter's defined maxValue and minValue,
--      those values are then applied
--      returns the value the counter was set to


--  tribeData.counterAdd(tribe,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  tribeData.counterAdd(tribe,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      adds the increment to the tribe's counterName current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to


--  tribeData.counterSubtract(tribe,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  tribeData.counterSubtract(tribe,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      subtracts the increment to the tribe's current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to


--  tribeData.counterSetWithin(tribe,counterName,minValue=-math.huge,maxValue=math.huge) --> number
--  tribeData.counterSetWithin(tribe,counterName,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      Sets the counter's current value within the minValue and maxValue specified
--      (This does not change the overall max and min set when defining the counter)
--      returns the value the counter was set to


--  tribeData.counterIsAtLeast(tribe,counterName,threshold) --> bool
--  tribeData.counterIsAtLeast(tribe,counterName,threshold,moduleName=nil) --> bool
--      returns true if the tribe's counterName is at least the threshold
--      and false otherwise


--  tribeData.counterIsAtMost(tribe,counterName,threshold) --> bool
--  tribeData.counterIsAtMost(tribe,counterName,threshold,moduleName=nil) --> bool
--      returns true if the tribe's counterName is at most the threshold
--      and false otherwise


--  tribeData.counterReset(tribe,counterName) --> void
--  tribeData.counterReset(tribe,counterName,moduleName=nil) --> void
--      sets the value associated with the tribe's counterName to nil
--      (meaning that it returns the default value set when it was defined)


--  tribeData.counterIsNil(tribe,counterName) --> boolean
--  tribeData.counterIsNil(tribe,counterName,moduleName=nil) --> boolean
--      returns true if the underlying value of tribe's counterName counter is nil
--      and false otherwise


-- tribeData.definePhrase(phraseName,defaultValue="",resetTime="never")
--      Defines a phrase for tribe data, which keeps string values
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
--          if tribe has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using tribeData.update


--  tribeData.defineModulePhrase(moduleName,phraseName,defaultValue="",resetTime="never")


--  tribeData.phraseGetValue(tribe,phraseName) --> string
--  tribeData.phraseGetValue(tribe,phraseName,moduleName=nil) --> string
--      returns the value associated with the tribe's phrase of phraseName
--      if the value is nil, the default specified during the definition is returned


--  tribeData.phraseSetValue(tribe,phraseName,value) --> void
--  tribeData.phraseSetValue(tribe,phraseName,value,moduleName) --> void
--      sets the value associated with tribe's phraseName to value


--  tribeData.phraseReset(tribe,phraseName) --> void
--  tribeData.phraseReset(tribe,phraseName,moduleName) --> void
--      sets the value associated with the tribe's phraseName to nil
--      (meaning that it returns the default value set when it was defined)


--  tribeData.phraseIsNil(tribe,phraseName) --> boolean
--  tribeData.phraseIsNil(tribe,phraseName,moduleName=nil) --> boolean
--      returns true if the underlying value of tribe's phraseName phrase is nil
--      and false otherwise


-- tribeData.defineGeneric(dataName,updateTime="never",updateAll=false,updateFunction=nil)
--      defines a generic entry for tribe data, and can keep any item that is
--      "state savable" (since it must be saved in the state table)
--      An item is "state savable" if it is either
--      nil
--      a number
--      a string
--      a boolean
--      a table with keys that are numbers or strings
--        and with values that are also state savable
--      "generic" data doesn't have the same guards against misuse 
--      that the other tribeData types have, but it is more flexible
--      gen.isStateSavable(item) may be useful to you
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          updateTime defines when the updateFunction is executed
--          if tribe has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--      updateAll = nil or boolean
--          if true, the update function is applied to all tribe, not just those with
--          non-nil values for this generic data
--      updateFunction = function(value,tribeID) --> value
--          takes the existing value for tribe's generic data under dataName
--          and the tribe's ID number, and produces a new
--          value for the generic data under dataName


-- tribeData.defineModuleGeneric(moduleName,dataName,updateTime="never",updateFunction=nil)


--  tribeData.genericGetValue(tribe,keyName) --> value
--  tribeData.genericGetValue(tribe,keyName,moduleName) --> value
--      returns the value stored by the tribe's keyName


--  tribeData.genericSetValue(tribe,keyName,value) --> value
--  tribeData.genericSetValue(tribe,keyName,value,moduleName) --> value
--      changes the value stored by the tribe's keyName to value


-- tribeData.update(tribe,time="custom",tribe=nil,key=nil)
-- tribeData.update(tribe,time="custom",tribe=nil,key=nil,moduleName)
--      updates all of tribe's data keys that have an updateTime of time, unless
--      key is specified, in which case, update that key only
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is considered to be the active tribe, relevant for onTribeTurnBegin and onTribeTurnEnd updates
--      if key is specified, that key's update time must be the same as the time specified


-- tribeData.generalUpdate(time="custom",tribe=nil)
--      updates data keys that have an updateTime of time for all tribes 
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is the tribe considered to be the active tribe, 
--      relevant for onTribeTurnBegin and onTribeTurnEnd updates


-- tribeData.transferData(oldtribe,newtribe)
--      associates the tribeData from the old tribe to the new one
--      (deleting the association with the old one)
--      newtribe can't be nil


-- tribeData.transferOrDeleteData(oldtribe,newtribe)
--      if newtribe is not nil, transfers the data from the
--      old tribe to the new one (deleting the data for the old one)
--      if newtribe is nil, the data is deleted for oldtribe


-- tribeData.deleteData(tribe)
--      deletes the data associated with the tribe


-- tribeData.validate(tribe)
--      checks that the item is still the same tribe it was before
--      (i.e. that the tribe hasn't been deleted and the ID reused)
--      If it has, eliminate all data for that tribe


-- tribeData.changeValidationInfo(tribe)
--      replaces existing values of the sameItemCheck with new ones
--
local supplementalData = require("supplementalData"):minVersion(1)
local gen = require("generalLibrary"):minVersion(1)
local civlua = require("civlua")
--
local function getTribeID(tribe) return tribe.id end
local function returnTribe(tribe) return tribe end
local function verifyTribe(tribe) return nil,nil,nil end

local tribeData = supplementalData.buildModuleFunctions("tribeData","tribe",
    civ.isTribe, getTribeID, civ.getTribe,civlua.iterateTribes, returnTribe, verifyTribe)


gen.versionFunctions(tribeData,versionNumber,fileModified,"LuaCore".."\\".."tribeData.lua")

return tribeData

