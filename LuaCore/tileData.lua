local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--  This module is used to associate data with individual tiles.  Functions are used to
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
--  you will need to have the tile it is associated with, as well as the name, and whether the
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

--  tileData.defineFlag(flagName,defaultValue=false,resetTime="never")
--      Defines a flag for tile data, which keeps boolean values
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
--          if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using tileData.update
--          

--  tileData.defineModuleFlag(moduleName,flagName,defaultValue=false,resetTime="never")

--      Note: The optional parameter of moduleName prevents name conflicts
--      for flags used in a module/library.  

--  tileData.flagGetValue(tile,flagName) --> boolean
--  tileData.flagGetValue(tile,flagName,moduleName=nil) --> boolean
--      returns the value associated with the tile's flag of flagName
--      if the value is nil, the default specified during the definition is returned

--  tileData.flagSetTrue(tile,flagName) --> void
--  tileData.flagSetTrue(tile,flagName,moduleName=nil) --> void
--      sets the value associated with the tile's flag of flagName to True

--  tileData.flagSetFalse(tile,flagName) --> void
--  tileData.flagSetFalse(tile,flagName,moduleName=nil) --> void
--      sets the value associated with the tile's flag of flagName to false

--  tileData.flagReset(tile,flagName) --> void
--  tileData.flagReset(tile,flagName,moduleName=nil) --> void
--      sets the value associated with the tile's flag of flagName to nil,
--      (meaning that it returns the default value set when it was defined)

--  tileData.flagIsNil(tile,flagName) --> boolean
--  tileData.flagIsNil(tile,flagName,moduleName=nil) --> boolean
--      returns true if the underlying value of tile's flagName flag is nil
--      (including if all keys are nil)
--      and false otherwise



-- tileData.defineCounter(counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)
--      Defines a counter for tile data, which keeps numerical values
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
--          "incrementAll" same as increment, but is also applied to tiles with nil as the underlying value of the counter
--          "set" means the counter is set to the updateParameter, but only applies if the counter isn't currently nil
--          "setAll" same as "set", but is also applied to tiles with nil as the underlying value of the counter
--          "reset" sets the underlying counter value to nil
--          "function" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tileID) (subject to maxValue and minValue), only for underlying values which are not nil
--          "functionAll" sets the underlying counter value to the result of updateParameter(formerUnderlyingValue,tileID) (subject to maxValue and minValue), even for nil underlying values
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          Gives the time when the counter update happens
--          "never" means no update
--          "onTurn" means at the very beginning of the onTurn event (before all other code)
--          "onTribeTurnBegin" means at the very start of the onTribeTurnBegin event for the owner (before all other code)
--          "onTribeTurnEnd" means at the very end of the onTribeTurnEnd event for the owner (after all other code)
--          if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using tileData.update
--      updateParameter = number, nil, or function
--          if update is "increment","incrementAll", "set", "setAll" then this must be a number
--          if update is "none" or "reset", this is ignored and can be nil
--          if update is "function", this is a function(numberOrNil,<itemID>) -> numberOrNil
--      nonInteger = bool or nil
--          if true, the counter can take on non-integer values
--          if false, the value is rounded using math.floor(initialValue+0.5)
--          if nil, an error is thrown when the counter is set to a non-integer value


--  tileData.defineModuleCounter(moduleName,counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)


--  tileData.counterGetValue(tile,counterName) --> number
--  tileData.counterGetValue(tile,counterName, moduleName=nil) --> number
--      returns the value associated with the tile's counter of counterName
--      if the value is nil, the default specified during the definition is returned


--  tileData.counterSetValue(tile,counterName,value) --> number
--  tileData.counterSetValue(tile,counterName,value,moduleName=nil) --> number
--      sets the value of the tile's counterName to the specified value
--      if this value is outside the counter's defined maxValue and minValue,
--      those values are then applied
--      returns the value the counter was set to


--  tileData.counterAdd(tile,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  tileData.counterAdd(tile,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      adds the increment to the tile's counterName current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to


--  tileData.counterSubtract(tile,counterName,increment,minValue=-math.huge,maxValue=math.huge) --> number
--  tileData.counterSubtract(tile,counterName,increment,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      subtracts the increment to the tile's current value, but substituting minValue or maxValue
--      if the result is out of the range.  Then, the minimum and maximum values specified
--      when the counter was defined are applied (i.e. the minValue and maxValue here do not
--      override the defined min and max values)
--      returns the value the counter was set to


--  tileData.counterSetWithin(tile,counterName,minValue=-math.huge,maxValue=math.huge) --> number
--  tileData.counterSetWithin(tile,counterName,minValue=-math.huge,maxValue=math.huge,moduleName=nil) --> number
--      Sets the counter's current value within the minValue and maxValue specified
--      (This does not change the overall max and min set when defining the counter)
--      returns the value the counter was set to


--  tileData.counterIsAtLeast(tile,counterName,threshold) --> bool
--  tileData.counterIsAtLeast(tile,counterName,threshold,moduleName=nil) --> bool
--      returns true if the tile's counterName is at least the threshold
--      and false otherwise


--  tileData.counterIsAtMost(tile,counterName,threshold) --> bool
--  tileData.counterIsAtMost(tile,counterName,threshold,moduleName=nil) --> bool
--      returns true if the tile's counterName is at most the threshold
--      and false otherwise


--  tileData.counterReset(tile,counterName) --> void
--  tileData.counterReset(tile,counterName,moduleName=nil) --> void
--      sets the value associated with the tile's counterName to nil
--      (meaning that it returns the default value set when it was defined)


--  tileData.counterIsNil(tile,counterName) --> boolean
--  tileData.counterIsNil(tile,counterName,moduleName=nil) --> boolean
--      returns true if the underlying value of tile's counterName counter is nil
--      and false otherwise


-- tileData.definePhrase(phraseName,defaultValue="",resetTime="never")
--      Defines a phrase for tile data, which keeps string values
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
--          if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--          "custom" means the update must be programmed in manually using tileData.update


--  tileData.defineModulePhrase(moduleName,phraseName,defaultValue="",resetTime="never")


--  tileData.phraseGetValue(tile,phraseName) --> string
--  tileData.phraseGetValue(tile,phraseName,moduleName=nil) --> string
--      returns the value associated with the tile's phrase of phraseName
--      if the value is nil, the default specified during the definition is returned


--  tileData.phraseSetValue(tile,phraseName,value) --> void
--  tileData.phraseSetValue(tile,phraseName,value,moduleName) --> void
--      sets the value associated with tile's phraseName to value


--  tileData.phraseReset(tile,phraseName) --> void
--  tileData.phraseReset(tile,phraseName,moduleName) --> void
--      sets the value associated with the tile's phraseName to nil
--      (meaning that it returns the default value set when it was defined)


--  tileData.phraseIsNil(tile,phraseName) --> boolean
--  tileData.phraseIsNil(tile,phraseName,moduleName=nil) --> boolean
--      returns true if the underlying value of tile's phraseName phrase is nil
--      and false otherwise


-- tileData.defineGeneric(dataName,updateTime="never",updateAll=false,updateFunction=nil)
--      defines a generic entry for tile data, and can keep any item that is
--      "state savable" (since it must be saved in the state table)
--      An item is "state savable" if it is either
--      nil
--      a number
--      a string
--      a boolean
--      a table with keys that are numbers or strings
--        and with values that are also state savable
--      "generic" data doesn't have the same guards against misuse 
--      that the other tileData types have, but it is more flexible
--      gen.isStateSavable(item) may be useful to you
--      updateTime = "never", "onTurn", "onTribeTurnBegin", "onTribeTurnEnd", "custom"
--          updateTime defines when the updateFunction is executed
--          if tile has no owner, onTribeTurnBegin and onTribeTurnEnd updates happen
--          during the onTurn update
--      updateAll = nil or boolean
--          if true, the update function is applied to all tile, not just those with
--          non-nil values for this generic data
--      updateFunction = function(value,tileID) --> value
--          takes the existing value for tile's generic data under dataName
--          and the tile's ID number, and produces a new
--          value for the generic data under dataName


-- tileData.defineModuleGeneric(moduleName,dataName,updateTime="never",updateFunction=nil)


--  tileData.genericGetValue(tile,keyName) --> value
--  tileData.genericGetValue(tile,keyName,moduleName) --> value
--      returns the value stored by the tile's keyName


--  tileData.genericSetValue(tile,keyName,value) --> value
--  tileData.genericSetValue(tile,keyName,value,moduleName) --> value
--      changes the value stored by the tile's keyName to value


-- tileData.update(tile,time="custom",tribe=nil,key=nil)
-- tileData.update(tile,time="custom",tribe=nil,key=nil,moduleName)
--      updates all of tile's data keys that have an updateTime of time, unless
--      key is specified, in which case, update that key only
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is considered to be the active tribe, relevant for onTribeTurnBegin and onTribeTurnEnd updates
--      if key is specified, that key's update time must be the same as the time specified


-- tileData.generalUpdate(time="custom",tribe=nil)
--      updates data keys that have an updateTime of time for all tiles 
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is the tribe considered to be the active tribe, 
--      relevant for onTribeTurnBegin and onTribeTurnEnd updates


-- tileData.transferData(oldtile,newtile)
--      associates the tileData from the old tile to the new one
--      (deleting the association with the old one)
--      newtile can't be nil


-- tileData.transferOrDeleteData(oldtile,newtile)
--      if newtile is not nil, transfers the data from the
--      old tile to the new one (deleting the data for the old one)
--      if newtile is nil, the data is deleted for oldtile


-- tileData.deleteData(tile)
--      deletes the data associated with the tile


-- tileData.validate(tile)
--      checks that the item is still the same tile it was before
--      (i.e. that the tile hasn't been deleted and the ID reused)
--      If it has, eliminate all data for that tile


-- tileData.changeValidationInfo(tile)
--      replaces existing values of the sameItemCheck with new ones

local supplementalData = require("supplementalData"):minVersion(1)
local gen = require("generalLibrary"):minVersion(1)
local civlua = require("civlua")

-- You may wish to change this depending on the needs of your particular scenario.
-- This governs when tiles are subject to tribeTurnBegin and tribeTurnEnd updates
-- (if nil, they are updated during the onTurn update instead)
local getTileOwner = function(tile) return nil end
-- tiles are never removed from the game, so they have no need of verification
local verifyTile = function(tile) return nil,nil,nil end

local tileData = supplementalData.buildModuleFunctions("tileData","tile",
    civ.isTile,gen.getTileID,gen.getTileFromID,civlua.iterateTiles, getTileOwner, verifyTile)

gen.versionFunctions(tileData,versionNumber,fileModified,"LuaCore".."\\".."tileData.lua")

return tileData
