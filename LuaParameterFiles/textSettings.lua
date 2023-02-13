
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


-- Note: this file is required by text.lua (though that requirement is optional)

local gen = require("generalLibrary"):minVersion(1)

-- a 'dictionary' table has information to populate tables
-- which will be used to help text.substitute work
-- dictionary[anyKey] = {singular=singularVersionOfWord, plural=pluralVersionOfWord, an=boolean}
--      an = true if it is 'an singularVersionOfWord' and false/nil if it is 'a singularVersionOfWord'
local dictionary = {
    {singular="unit",plural="units",an=false},
    {singular="Unit",plural="Units",an=false},
    {singular="improvement", plural="improvements", an=true},
    {singular="Improvement", plural="Improvements", an=true},
    {singular="city", plural="cities", an=false},
    {singular="City", plural="Cities", an=false},
    {singular="this", plural="these", },
    {singular="This", plural="These", },
    {singular="that", plural="those", },
    {singular="That", plural="Those", },
    {singular="is", plural="are", },
    {singular="Is", plural="Are", },
    {singular="Engineer", plural="Engineers",an=true},
}




-- Use this table to register special functionality for
-- text.substitute
-- substitutionTags["%%MYTAG"] = convertFn
--      If you register %%MYTAG, then substitute will search for
--      instances of %MYTAG in the rawText, in order to substitute
--      it for the result of convertFn(subTable[key])
--      Note: in Lua pattern matching, these characters need to be
--      'escaped' by %, including those in the tag:
--      ( ) % . + - * [ ? ^ $
--      this is why it is "%%MYTAG" instead of "%MYTAG"
--      tag is a string
--      convertFn is a function: convertFn(value) --> string

local substitutionTags = {}

-- These are the defaults provided by text.lua
-- you can override them if you really want to, but that could cause errors
-- in other modules.  They are here for example purposes
--substitutionTags["%%STRING"] = tostring
--substitutionTags["%%MONEY"] = function(val) return text.money(val) end
--substitutionTags["%%NAME"] = function(val) return val.name or val.type.name end
--substitutionTags["%%OWNER"] = function(val) return val.owner.name end
--substitutionTags["%%ADJECTIVE"] = function(val) return val.adjective or val.owner.adjective end

-- example/testing purpose entries, which are not included in the defaults
substitutionTags["%%CAPITAL"] = function(val)
    if not civ.isTribe(val) then
        val = val.owner
    end
    for city in civ.iterateCities() do
        if city.owner == val and city:hasImprovement(gen.original.iPalace) then
            return city.name
        end
    end
    return "Destroyed"
end
substitutionTags["%%TYPE"] = function(val) return val.type.name end



-- Use this table to register special functionality for
-- text.substitute
-- choiceTags["%%%?MYCHOICETAG"] = choiceFn
--      if you register "%%%?MYCHOICETAG, then text.substitute will search for
--      instances of %?MYCHOICETAG<key>{first text}{second text}
--      if choiceFn(substitutionTable[key]) == true, then 'first text' is the replacement, 
--      otherwise, 'second text' is the replacement.
--      Note: in Lua pattern matching, these characters need to be
--      'escaped' by %, including those in the tag:
--      ( ) % . + - * [ ? ^ $
--      this is why it is "%%%?MYTAG" instead of "%?MYTAG"
--      choiceFn is a function: choiceFn(value) --> boolean
local choiceTags = {}
-- These are the defaults provided by text.lua
-- you can override them if you really want to, but that could cause errors
-- in other modules.  They are here for example purposes
--choiceTags["%%%?TRUTHY"] = function(val) return not not val end
--choiceTags["%%%?PLURAL"] = function(val) return val ~= 1 end
--choiceTags["%%%?ZERO"] = function(val) return val == 0 end
--choiceTags["%%%?ONE"] = function(val) return val == 1 end


-- example/testing purpose entries, which are not included in the defaults
choiceTags["%%%?TWOPLUS"] = function(val) return val >= 2 end

local textSettings = {}
textSettings.dictionary = dictionary
textSettings.substitutionTags = substitutionTags
textSettings.choiceTags = choiceTags

gen.versionFunctions(textSettings,versionNumber,fileModified,"LuaParameterFiles".."\\".."textSettings.lua")
return textSettings
