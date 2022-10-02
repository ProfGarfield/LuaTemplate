local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



-- The context module is meant to facilitate the introduction
-- of code that should only be run in certain situations,
-- but is impractical to check for those situations every time
--
-- For example, you may want to have substantially different
-- events based on whether the scenario is being played
-- as single player or multiplayer.
--
-- First, we choose directory names where we're going to store
-- the separate code, for example SinglePlayer, and Multiplayer
--
-- Next, we must somewhere register our context checker function.
-- The context checker function determines which directory will
-- be checked for code.  If that function returns nil (as the
-- default version always does), then no context code is retrieved.
--
-- context.registerSelectContext(function()
--      if flag.value("multiplayerVersion") then
--          return "Multiplayer"
--      else
--          return "SinglePlayer"
--      end
-- end)
--
--  At some point, we will want to use some context dependant code.
--  To do so, we call:
--
--  context.aFileName.someFunction(arg)
--
--  At this point, context will run the selectContextFn (registered above)
--  and get a context directory name.  Suppose it is Multiplayer.
--
--  If Multiplayer\aFileName.lua does not exist, then a table with an 
--  empty function for every key is returned, so no computation is done
--  and nil is returned.
--  If  the file does exist, then someFunction is run from Multiplayer\aFileName.lua
--
--  -- require, helpers etc.
--  local prefix = {}
--  function prefix.someFunction(arg)
--      -- some code
--  end
--  -- possibly other code
--  return prefix
--
--  at this point, if someFunction doesn't exist in the file, there will be an error


local selectContextFunction = function () return nil end

local function registerSelectContext(selectContextFn)
    if type(selectContextFn) ~= "function" then
        error("context.registerSelectContext: argument must be a function")
    end
    selectContextFunction = selectContextFn
end


local function emptyFunction()
    return nil
end

local emptyContextTable = {}
local emptyContextMetatable = {__index = function(table,key) return emptyFunction end}
setmetatable(emptyContextTable,emptyContextMetatable)

--local function newIndexFn(myTable,key,value)
--
--end



local previousResults = {}

local function indexFn(myTable,key)
    local directory = selectContextFunction()
    if directory == nil then
        return emptyContextTable
    end
    if type(directory) ~= "string" then
        error("the function registered by context.registerSelectContext must return a string or nil.  Instead, the following was returned:\n"..tostring(directory))
    end
    local requirePath = directory.."\\"..key
    if previousResults[requirePath] then
        return previousResults[requirePath]
    end
    local fileFound, prefix = pcall(require,requirePath)
    if fileFound then
        previousResults[requirePath] = prefix
        return prefix
    else
        previousResults[requirePath] = emptyContextTable
        return emptyContextTable
    end
end


local superMetatable = {__index= indexFn,--[[ __newindex=newIndexFn]]}
local superTable = {version = versionNumber, registerSelectContext = registerSelectContext}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(superTable,versionNumber,fileModified,"LuaCore".."\\".."context.lua")
setmetatable(superTable,superMetatable)
return superTable


