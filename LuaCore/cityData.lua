local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

--  This module is used to associate data with individual cities.  Functions are used to
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
--  you will need to have the city it is associated with, as well as the name, and whether the
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
--      
--      Note: If you wish to access these functions from the Lua Console, use the prefix
--      console.cityData (e.g. console.cityData.flagSetTrue)

--  cityData.defineFlag(flagName,defaultValue=false,resetTime="never")
--      Defines a flag for city data, which keeps boolean values
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
--          if city has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using cityData.update
--          

--  cityData.defineModuleFlag(moduleName,flagName,defaultValue=false,resetTime="never")

--      Note: The optional parameter of moduleName prevents name conflicts
--      for flags used in a module/library.  

--  cityData.flagGetValue(city,flagName) --> boolean
--  cityData.flagGetValue(city,flagName,moduleName=nil) --> boolean
--      returns the value associated with the city's flag of flagName
--      if the value is nil, the default specified during the definition is returned

--  cityData.flagSetTrue(city,flagName) --> void
--  cityData.flagSetTrue(city,flagName,moduleName=nil) --> void
--      sets the value associated with the city's flag of flagName to True

--  cityData.flagSetFalse(city,flagName) --> void
--  cityData.flagSetFalse(city,flagName,moduleName=nil) --> void
--      sets the value associated with the city's flag of flagName to false

--  cityData.flagReset(city,flagName) --> void
--  cityData.flagReset(city,flagName,moduleName=nil) --> void
--      sets the value associated with the city's flag of flagName to nil,
--      (meaning that it returns the default value set when it was defined)

--  cityData.flagIsNil(city,flagName) --> boolean
--  cityData.flagIsNil(city,flagName,moduleName=nil) --> boolean
--      returns true if the underlying value of city's flagName flag is nil
--      (including if all keys are nil)
--      and false otherwise



-- cityData.defineCounter(counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)
--      Defines a counter for city data, which keeps numerical values
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
--          "incrementAll" same as increment, but is also applied to citys with nil as the underlying value of the counter
--          "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
--          "setAll" same as "set", but is also applied to citys with nil as the underlying value of the counter
--          "reset" sets the underlying counter value to nil
--          "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,cityID) (subject to maxValue and minValue), only for underlying values which are not nil
--          "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,cityID) (subject to maxValue and minValue), even for nil underlying values
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          Gives the time when the counter update happens
--          "never" means no update
--          "onTurn" means at the very beginning of the onTurn event (before all other code)
--          "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
--          "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
--          if city has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using cityData.update
--      updateParameter = number, nil, or function
--          if update is "increment","incrementAll", "set", "setAll" then this must be a number
--          if update is "none" or "reset", this is ignored and can be nil
--          if update is "function", this is a function(numberOrNil,<itemID>) -> numberOrNil
--      nonInteger = bool or nil
--          if true, the counter can take on non-integer values
--          if false, the value is rounded using math.floor(initialValue+0.5)
--          if nil, an error is thrown when the counter is set to a non-integer value


--  cityData.defineModuleCounter(moduleName,counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)


--  cityData.counterGetValue(city,counterName) --> number
--  cityData.counterGetValue(city,counterName, moduleName=nil) --> number
--      returns the value associated with the city's counter of counterName
--      if the value is nil, the default specified during the definition is returned


--  cityData.counterSetValue(city,counterName,value) --> number
--  cityData.counterSetValue(city,counterName,value,moduleName=nil) --> number
--      sets the value of the city's counterName to the specified value
--      if this value is outside the counter's defined maxValue and minValue,
--      those values are then applied
--      returns the value the counter was set to


--  cityData.counterAdd(city,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  cityData.counterAdd(city,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      adds the increment to the city's counterName current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to


--  cityData.counterSubtract(city,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  cityData.counterSubtract(city,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      subtracts the increment to the city's current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to


--  cityData.counterSetWithin(city,counterName,minValue=-math.huge,maxValue=math.huge) --> number
--  cityData.counterSetWithin(city,counterName,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      Sets the counter's current value within the minValue and maxValue specified
--      (This does not change the overall max and min set when defining the counter)
--      returns the value the counter was set to


--  cityData.counterIsAtLeast(city,counterName,threshold) --> bool
--  cityData.counterIsAtLeast(city,counterName,threshold,moduleName=nil) --> bool
--      returns true if the city's counterName is at least the threshold
--      and false otherwise


--  cityData.counterIsAtMost(city,counterName,threshold) --> bool
--  cityData.counterIsAtMost(city,counterName,threshold,moduleName=nil) --> bool
--      returns true if the city's counterName is at most the threshold
--      and false otherwise


--  cityData.counterReset(city,counterName) --> void
--  cityData.counterReset(city,counterName,moduleName=nil) --> void
--      sets the value associated with the city's counterName to nil
--      (meaning that it returns the default value set when it was defined)


--  cityData.counterIsNil(city,counterName) --> boolean
--  cityData.counterIsNil(city,counterName,moduleName=nil) --> boolean
--      returns true if the underlying value of city's counterName counter is nil
--      and false otherwise


-- cityData.definePhrase(phraseName,defaultValue="",resetTime="never")
--      Defines a phrase for city data, which keeps string values
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
--          if city has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using cityData.update


--  cityData.defineModulePhrase(moduleName,phraseName,defaultValue="",resetTime="never")


--  cityData.phraseGetValue(city,phraseName) --> string
--  cityData.phraseGetValue(city,phraseName,moduleName=nil) --> string
--      returns the value associated with the city's phrase of phraseName
--      if the value is nil, the default specified during the definition is returned


--  cityData.phraseSetValue(city,phraseName,value) --> void
--  cityData.phraseSetValue(city,phraseName,value,moduleName) --> void
--      sets the value associated with city's phraseName to value


--  cityData.phraseReset(city,phraseName) --> void
--  cityData.phraseReset(city,phraseName,moduleName) --> void
--      sets the value associated with the city's phraseName to nil
--      (meaning that it returns the default value set when it was defined)


--  cityData.phraseIsNil(city,phraseName) --> boolean
--  cityData.phraseIsNil(city,phraseName,moduleName=nil) --> boolean
--      returns true if the underlying value of city's phraseName phrase is nil
--      and false otherwise


-- cityData.defineGeneric(dataName,updateTime="never",updateAll=false,updateFunction=nil)
--      defines a generic entry for city data, and can keep any item that is
--      "state savable" (since it must be saved in the state table)
--      An item is "state savable" if it is either
--      nil
--      a number
--      a string
--      a boolean
--      a table with keys that are numbers or strings
--        and with values that are also state savable
--      "generic" data doesn't have the same guards against misuse 
--      that the other cityData types have, but it is more flexible
--      gen.isStateSavable(item) may be useful to you
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          updateTime defines when the updateFunction is executed
--          if city has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--      updateAll = nil or boolean
--          if true, the update function is applied to all city, not just those with
--          non-nil values for this generic data
--      updateFunction = function(value,cityID) --> value
--          takes the existing value for city's generic data under dataName
--          and the city's ID number, and produces a new
--          value for the generic data under dataName


-- cityData.defineModuleGeneric(moduleName,dataName,updateTime="never",updateFunction=nil)


--  cityData.genericGetValue(city,keyName) --> value
--  cityData.genericGetValue(city,keyName,moduleName) --> value
--      returns the value stored by the city's keyName


--  cityData.genericSetValue(city,keyName,value) --> value
--  cityData.genericSetValue(city,keyName,value,moduleName) --> value
--      changes the value stored by the city's keyName to value


-- cityData.update(city,time="custom",tribe=nil,key=nil)
-- cityData.update(city,time="custom",tribe=nil,key=nil,moduleName)
--      updates all of city's data keys that have an updateTime of time, unless
--      key is specified, in which case, update that key only
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is considered to be the active tribe, relevant for onTribeTurnBegin and onTribeTurnEnd updates
--      if key is specified, that key's update time must be the same as the time specified


-- cityData.generalUpdate(time="custom",tribe=nil)
--      updates data keys that have an updateTime of time for all citys 
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is the tribe considered to be the active tribe, 
--      relevant for onTribeTurnBegin and onTribeTurnEnd updates


-- cityData.transferData(oldcity,newcity)
--      associates the cityData from the old city to the new one
--      (deleting the association with the old one)
--      newcity can't be nil


-- cityData.transferOrDeleteData(oldcity,newcity)
--      if newcity is not nil, transfers the data from the
--      old city to the new one (deleting the data for the old one)
--      if newcity is nil, the data is deleted for oldcity


-- cityData.deleteData(city)
--      deletes the data associated with the city


-- cityData.validate(city)
--      checks that the item is still the same city it was before
--      by checking that it is on the same tile
--      i.e. that the city hasn't been deleted and the ID reused
--      If it has, eliminate all data for that city


-- cityData.changeValidationInfo(city)
--      replaces existing values of the sameItemCheck with new ones

local supplementalData = require("supplementalData"):minVersion(1)
local gen = require("generalLibrary"):minVersion(1)
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."cityData.lua")

local getCityID = function(city) return city.id end
local getCityOwner = function(city) return city.owner end
local verifyCity = function(city) return gen.getTileID(city.location), nil, nil end

local cityData = supplementalData.buildModuleFunctions("cityData","city",
    civ.isCity,getCityID,civ.getCity,civ.iterateCities,getCityOwner,verifyCity)

-- This is run as part of the onCityDestroyed event, after everything else
-- This even runs when civ.deleteCity is called

function cityData.onCityDestroyed(city)
    cityData.deleteData(city)
end
gen.versionFunctions(cityData,versionNumber,fileModified,"LuaCore".."\\".."cityData.lua")

if rawget(_G,"console") then
    _G["console"].cityData = cityData
end


return cityData
