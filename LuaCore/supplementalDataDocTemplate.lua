-- This is a template for data modules created from the supplementalData module

--  This module is used to associate data with individual <item>s.  Functions are used to
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
--  you will need to have the <item> it is associated with, as well as the name, and whether the
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

--  <item>Data.defineModuleFlag(moduleName,flagName,defaultValue=false,resetTime="never")

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
--          if update is "function", this is a function(numberOrNil,<itemID>) -> numberOrNil
--      nonInteger = bool or nil
--          if true, the counter can take on non-integer values
--          if false, the value is rounded using math.floor(initialValue+0.5)
--          if nil, an error is thrown when the counter is set to a non-integer value


--  <item>Data.defineModuleCounter(moduleName,counterName,defaultValue=0,minValue=-math.huge,maxValue=math.huge,update="none",updateTime="never",updateParameter=nil,nonInteger=nil)


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


--  <item>Data.defineModulePhrase(moduleName,phraseName,defaultValue="",resetTime="never")


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


-- <item>Data.defineModuleGeneric(moduleName,dataName,updateTime="never",updateFunction=nil)


--  <item>Data.genericGetValue(<item>,keyName) --> value
--  <item>Data.genericGetValue(<item>,keyName,moduleName) --> value
--      returns the value stored by the <item>'s keyName


--  <item>Data.genericSetValue(<item>,keyName,value) --> value
--  <item>Data.genericSetValue(<item>,keyName,value,moduleName) --> value
--      changes the value stored by the <item>'s keyName to value


-- <item>Data.update(<item>,time="custom",tribe=nil,key=nil)
-- <item>Data.update(<item>,time="custom",tribe=nil,key=nil,moduleName)
--      updates all of <item>'s data keys that have an updateTime of time, unless
--      key is specified, in which case, update that key only
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is considered to be the active tribe, relevant for onTribeTurnBegin and onTribeTurnEnd updates
--      if key is specified, that key's update time must be the same as the time specified


-- <item>Data.generalUpdate(time="custom",tribe=nil)
--      updates data keys that have an updateTime of time for all <item>s 
--      time can be "onTurn", "onTribeTurnBegin","onTribeTurnEnd", "custom"
--      tribe is the tribe considered to be the active tribe, 
--      relevant for onTribeTurnBegin and onTribeTurnEnd updates


-- <item>Data.transferData(old<item>,new<item>)
--      associates the <item>Data from the old <item> to the new one
--      (deleting the association with the old one)
--      new<item> can't be nil


-- <item>Data.transferOrDeleteData(old<item>,new<item>)
--      if new<item> is not nil, transfers the data from the
--      old <item> to the new one (deleting the data for the old one)
--      if new<item> is nil, the data is deleted for old<item>


-- <item>Data.deleteData(<item>)
--      deletes the data associated with the <item>


-- <item>Data.validate(<item>)
--      checks that the item is still the same <item> it was before
--      (i.e. that the <item> hasn't been deleted and the ID reused)
--      If it has, eliminate all data for that <item>


-- <item>Data.changeValidationInfo(<item>)
--      replaces existing values of the sameItemCheck with new ones

