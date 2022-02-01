-- This file has several parts
-- 1. Some helper functions
-- 2. Adding the Classes and Libraries for the Test of Time Patch Project
--    Objects and the generic Lua objects
-- 3. Adding custom API elements that could not be parsed by the parser I wrote
--    (The raw text will preceed these additions)
-- 4. Adding automatically generated API elements
--    (The raw text will preceed these additions)
-- 5. Returning the API

--    1.  Helper Functions
local function addClass(doc,className,description,inherits,htmlDescription)
  doc[className] = {type="class",description=description, childs = {},inherits = inherits, htmlDescription = htmlDescription}
end

--    2.  Adding Classes and Libraries
--      (html descriptions are there so I can later use this same
--      table to make a web version of documentation)
local documentation = {}

local voidDescription = "\"Void\" isn't a proper data type in Lua.  Instead, it is an indication that a function or method is not returning a value at all.  A function with a simple <code>return</code>, or without a <code>return</code> line will return (or, rather, not return) a \"void\", wheras <code>return nil</code> will return a proper nil value.  If your function <em>never</em> returns useful information, returning \"void\" is appropriate.  However, if your code <em>sometimes</em> returns useful data, it should return nil when it does not."
local voidDescriptionHTML = "\"Void\" isn't a proper data type in Lua.  Instead, it is an indication that a function or method is not returning a value at all.  A function with a simple <code>return</code>, or without a <code>return</code> line will return (or, rather, not return) a \"void\", wheras <code>return nil</code> will return a proper nil value.  If your function <em>never</em> returns useful information, returning \"void\" is appropriate.  However, if your code <em>sometimes</em> returns useful data, it should return nil when it does not."
addClass(documentation,"void",voidDescription,"",voidDescriptionHTML )


local nilDescription = "The 'nil' data type has a single value nil, and tends to represent the absence of a value.  Nil is a data type which is native to Lua, and is considered 'falsy' in logical statements.  Unassigned keys in a table return nil as their value."
local nilDescriptionHTML = "The 'nil' data type has a single value nil, and tends to represent the absence of a value.  Nil is a data type which is native to Lua, and is considered 'falsy' in logical statements.  Unassigned keys in a table return nil as their value."
addClass(documentation,"nil",nilDescription,"",nilDescriptionHTML)  


local tableDescription = "A table is a data type native to Lua, and links \"keys\" (usually numbers or strings) to \"values\" (any kind of data, including other tables).  This is the only data structuring mechanism in Lua, and many of the data types documented here are simply tables with restrictions on their keys or values.  If a key has not been assigned a value, the table returns nil as the corresponding value, and assigning nil as a value to a key removes that key from the table."
local tableDescriptionHTML = "A table is a data type native to Lua, and links \"keys\" (usually numbers or strings) to \"values\" (any kind of data, including other tables).  This is the only data structuring mechanism in Lua, and many of the data types documented here are simply tables with restrictions on their keys or values.  If a key has not been assigned a value, the table returns nil as the corresponding value, and assigning nil as a value to a key removes that key from the table."
addClass(documentation,"table",tableDescription,"",tableDescriptionHTML)  


local numberDescription = "A number is a data type native to Lua, which allows numerical computations to be performed.  Fundamentally, Lua does not have separate data types for integers and numbers with a component after the decimal point, so any integer is also a number."
local numberDescriptionHTML = "A number is a data type native to Lua, which allows numerical computations to be performed.  Fundamentally, Lua does not have separate data types for integers and numbers with a component after the decimal point, so any integer is also a number."
addClass(documentation,"number",numberDescription,"",numberDescriptionHTML)  

local integerDescription = "An integer is a number without a fractional part.  Unlike other programming Languages, Lua does not distinguish between integers and 'floating point' numbers.  You can convert a number to an integer by using commands like math.floor and math.ceil."
local integerDescriptionHTML = "An integer is a number without a fractional part.  Unlike other programming Languages, Lua does not distinguish between integers and 'floating point' numbers.  You can convert a number to an integer by using commands like <code>math.floor</code> and <code>math.ceil</code>."
addClass(documentation,"integer",integerDescription,"",integerDescriptionHTML)  

local booleanDescription = "A boolean is a data type native to Lua with exactly two possible values, true and false.  These are often used when evaluating logical statements, but logical statements accept other values as well.  All values except false and nil are considered 'truthy', even values such as 0 or the empty string.";
local booleanDescriptionHTML = "A boolean is a data type native to Lua with exactly two possible values, <code>true</code> and <code>false</code>.  These are often used when evaluating logical statements, but logical statements accept other values as well.  All values except <code>false</code> and <code>nil</code> are considered 'truthy', even values such as 0 or the empty string.";
addClass(documentation,"boolean",booleanDescription,"",booleanDescriptionHTML)  

local stringDescription = "A string is a data type native to Lua which consists of a sequence of characters.  These often represent text to be displayed, but are also useful in other contexts.  Strings are commonly used as keys in tables, since they make code more readable."
local stringDescriptionHTML = "A string is a data type native to Lua which consists of a sequence of characters.  These often represent text to be displayed, but are also useful in other contexts.  Strings are commonly used as keys in tables, since they make code more readable."
addClass(documentation,"string",stringDescription,"",stringDescriptionHTML)  


local functionDescription = "A function is a sequence of instructions, which frequently depend on values that are provided (\"arguments\").  In Lua, functions are considered values, and can be stored in variables or tables.  They can also be supplied as arguments to other functions."
local functionDescriptionHTML = "A function is a sequence of instructions, which frequently depend on values that are provided (\"arguments\").  In Lua, functions are considered values, and can be stored in variables or tables.  They can also be supplied as arguments to other functions."
addClass(documentation,"function",functionDescription,"",functionDescriptionHTML)  

local bitmaskDescription = "A bitmask is an integer that is not meant to be interpreted as a number, but rather as a sequence of 1's and 0's (the binary representation of the number), with each 1 or 0 representing whether a condition is true or false.  Bitmasks often have functions written to facilitate their manipulation.  If none are available, Lua provides bitwise operators.Typically, the leftmost bit (the bit representing the largest value) is interpreted as negative.  Hence, the bitmask integer is not guaranteed to be positive."
local bitmaskDescriptionHTML = "<p>A bitmask is an integer that is not meant to be interpreted as a number, but rather as a sequence of 1's and 0's (the binary representation of the number), with each 1 or 0 representing whether a condition is true or false.  Bitmasks often have functions written to facilitate their manipulation.  If none are available, Lua provides bitwise operators.</p><p>Typically, the leftmost bit (the bit representing the largest value) is interpreted as negative.  Hence, the bitmask integer is not guaranteed to be positive.</p>"
addClass(documentation,"bitmask",bitmaskDescription,"",bitmaskDescriptionHTML)  


local idDescription = "An id number is a positive integer that corresponds to an object in the game or the rules.txt file.  If you know what kind of object the id corresponds to, you can then use the id to get the specific item in question.  The maximum value for an id will depend on its corresponding object.  For example, the maximum id for a tribe object is 7, but (at least for programming purposes) there is no limit to the id number of a unit."
local idDescriptionHTML = "An id number is a positive integer that corresponds to an object in the game or the rules.txt file.  If you know what <em>kind</em> of object the id corresponds to, you can then use the id to get the specific item in question.  The maximum value for an id will depend on its corresponding object.  For example, the maximum id for a tribe object is 7, but (at least for programming purposes) there is no limit to the id number of a unit."
addClass(documentation,"id",idDescription,"",idDescriptionHTML)  



local cityDescription = "A city object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a city in the game, and provides a means of interacting with that city."
local cityDescriptionHTML = "A city object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a city in the game, and provides a means of interacting with that city."
addClass(documentation,"cityObject",cityDescription,"",cityDescriptionHTML)  

local tileDescription = "A tile object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a map \"square\" in the game, and provides a means of interacting with it."
local tileDescriptionHTML = "A tile object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a map \"square\" in the game, and provides a means of interacting with it."
addClass(documentation,"tileObject",tileDescription,"",tileDescriptionHTML)  


local unitDescription = "A unit object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a unit in the game, and provides a means of interacting with it.  This should not be confused with the unit type object."
local unitDescriptionHTML = "A unit object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a unit in the game, and provides a means of interacting with it.  This should not be confused with the unit type object."
addClass(documentation,"unitObject",unitDescription,"",unitDescriptionHTML)  

local unitTypeDescription = "A unit type object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a unit type entry in the rules.txt, and provides a means of interacting with it.  This should not be confused with the unit object."
local unitTypeDescriptionHTML = "A unit type object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a unit type entry in the rules.txt, and provides a means of interacting with it.  This should not be confused with the unit object."
addClass(documentation,"unitTypeObject",unitTypeDescription,"",unitTypeDescriptionHTML)  

local tribeDescription = "A tribe object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a tribe, which is to say the characteristics of the tribe overall, in the game, and provides a means of interacting with it."
local tribeDescriptionHTML = "A tribe object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a tribe, which is to say the characteristics of the tribe overall, in the game, and provides a means of interacting with it."
addClass(documentation,"tribeObject",tribeDescription,"",tribeDescriptionHTML)  

local improvementDescription = "An improvement object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents an improvement entry in the rules.txt, and provides a means of interacting with it."
local improvementDescriptionHTML = "An improvement object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents an improvement entry in the rules.txt, and provides a means of interacting with it."
addClass(documentation,"improvementObject",improvementDescription,"",improvementDescriptionHTML)  

local techDescription = "A technology object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a technology entry in the rules.txt, and provides a means of interacting with it."
local techDescriptionHTML = "A technology object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a technology entry in the rules.txt, and provides a means of interacting with it."
addClass(documentation,"techObject",techDescription,"",techDescriptionHTML)  

local leaderDescription = "A leader object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the leader of a tribe, which is to say some characteristics of the tribe specific to the \"leader\", and provides a means of interacting with it."
local leaderDescriptionHTML = "A leader object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the leader of a tribe, which is to say some characteristics of the tribe specific to the \"leader\", and provides a means of interacting with it."
addClass(documentation,"leaderObject",leaderDescription,"",leaderDescriptionHTML)  


local wonderDescription = "A wonder object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a Wonder of the World, both its entry in the rules.txt and also its characteristics within the game."
local wonderDescriptionHTML = "A wonder object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a Wonder of the World, both its entry in the rules.txt and also its characteristics within the game."
addClass(documentation,"wonderObject",wonderDescription,"",wonderDescriptionHTML)  

local prodItemDescription = "A production item is an object that can be under production in a city.  It can be a unit type object, an improvement object, or a wonder object.  Note that it is a unit type object, not a unit object, since the unit hasn't been added to the game yet."
local prodItemDescriptionHTML = "A production item is an object that can be under production in a city.  It can be a unit type object, an improvement object, or a wonder object.  Note that it is a unit type object, not a unit object, since the unit hasn't been added to the game yet."
addClass(documentation,"prodItem",prodItemDescription,"unitTypeObject improvementObject wonderObject",prodItemDescriptionHTML)  

local spaceshipDescription = "A spaceship object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the status of a tribe's spaceship, and provides a means of interacting with it."
local spaceshipDescriptionHTML = "A spaceship object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the status of a tribe's spaceship, and provides a means of interacting with it."
addClass(documentation,"spaceshipObject",spaceshipDescription,"",spaceshipDescriptionHTML)  

local dialogDescription = "A dialog object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a text box that can be displayed to the player and provides properties and methods to customize it."
local dialogDescriptionHTML = "A dialog object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents a text box that can be displayed to the player and provides properties and methods to customize it."
addClass(documentation,"dialogObject",dialogDescription,"",dialogDescriptionHTML)  

local mapDescription = "A map object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the overall properties of one of the four possible maps in the game, and provides a means of interacting with it."
local mapDescriptionHTML = "A map object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the overall properties of one of the four possible maps in the game, and provides a means of interacting with it."
addClass(documentation,"mapObject",mapDescription,"",mapDescriptionHTML)  

local baseTerrainDescription = "A base terrain object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the 'basic' terrain characteristics for a terrain type, which is to say those aspects of terrain which do not change for special resources.  The 'terrain' object deals with the characteristics that do change for special resources."
local baseTerrainDescriptionHTML = "A base terrain object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the 'basic' terrain characteristics for a terrain type, which is to say those aspects of terrain which do not change for special resources.  The 'terrain' object deals with the characteristics that do change for special resources."
addClass(documentation,"baseTerrainObject",baseTerrainDescription,"",baseTerrainDescriptionHTML)  

local terrainDescription = "A terrain object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the terrain characteristics which change for special resources.  The 'base terrain' object deals with the characteristics that do not change for special resources."
local terrainDescriptionHTML = "A terrain object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents the terrain characteristics which change for special resources.  The 'base terrain' object deals with the characteristics that do not change for special resources."
addClass(documentation,"terrainObject",terrainDescription,"",terrainDescriptionHTML)  

local imageDescription = "A image object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents an image that can be displayed in a dialog object."
local imageDescriptionHTML = "A image object is a data type provided by the Test of Time Patch Project Lua Interpreter.  It represents an image that can be displayed in a dialog object."
addClass(documentation,"imageObject",imageDescription,"",imageDescriptionHTML)  

local commodityDescription = "A commodity object is a data type that describes a trade commodity that can be carried by trade units."
local commodityDescriptionHTML = "A commodity object is a data type that describes a trade commodity that can be carried by trade units."
addClass(documentation,"commodityObject",commodityDescription,"",commodityDescriptionHTML)  

local traderouteDescription = "A traderoute object is a data type that describes a trade route that exists between two cities, and offers a means of interacting with it.";
local traderouteDescriptionHTML = "A traderoute object is a data type that describes a trade route that exists between two cities, and offers a means of interacting with it.";
addClass(documentation,"traderouteObject",traderouteDescription,"",traderouteDescriptionHTML)  

local iteratorDescription = [[An iterator is a construct that enables a program to travers the elements of a collection or container.  Each time the iterator is called, a different element of the collection is provided.  In practice, an iterator is usually used as part of a generic for loop:
for unit in civ.iterateUnits() do
     civ.deleteUnit(unit)
end]]
local iteratorDescriptionHMTL = [[<p>An iterator is a construct that enables a program to travers the elements of a collection or container.  Each time the iterator is called, a different element of the collection is provided.  In practice, an iterator is usually used as part of a generic for loop:</p>
<pre>
<span id="L1" class="LineNr">1 </span><span class="Statement">for</span> unit <span class="Statement">in</span> <span class="CivFunc">civ.iterateUnits</span>() <span class="Statement">do</span>
<span id="L2" class="LineNr">2 </span>    <span class="CivFunc">civ.deleteUnit</span>(unit)
<span id="L3" class="LineNr">3 </span><span class="Statement">end</span>
</pre>]]
addClass(documentation,"iterator",iteratorDescription,"",iteratorDescriptionHMTL)

  documentation.civ = {
    type="lib",
    description = "The civ library provides tools for interacting with Civilization II: Test of Time.",
    childs = {
      ui = {
        type = "lib",
        description = "The civ.ui library provides functions to interact with the user interface, including creating text boxes.",
        childs = {},
        },            
      cosmic = {
        type = "lib",
        description = "The civ.cosmic library provides a means of interacting with the @COSMIC section of the Rules.txt.",
        childs = {},
      },
      game = {
        type = "lib",
        description = "The civ.game library provides a means of interacting with some game settings.",
        childs = {
            rules = { 
              type = "lib",
              description = "The civ.game.rules library provides a means of interacting with whether the map is flat, and possibly other stuff in the future.",
              childs = {},
              },
          },
        },
      scen = {
        type = "lib",
        description = "The civ.scen library provides functions to register code to the various 'execution points' for the purposes of creating scenario events.  It also has some sub libraries to interact with scenario parameters or compatibility settings.",
        childs = {
          params = {
            childs = {},
            type = "lib",
            description = "The civ.scen.params library provides access to scenario parameters.",
            },
          compatibility = {
            childs = {}, 
            type = "lib",
            description = "The civ.scen.compatibility library provides settings to allow backwards compatibility for the Test of Time Patch Project.",
          },
        },
      },
    },
  }

documentation.totpp = {
  type = "lib",
  description = "The `totpp` library provides data about TOTPP itself, and is also available for individual ToTPP patches to register sub-libraries in, to allow interacting with them from the game.",
  childs = {
    patches = {
      type = "lib",
      description = "Returns a table with the enabled status for all patches. The string keys are the same as the ones used in TOTPP.ini",
      childs = {},
    },
    version = {
      type = "lib",
      description = "Provides a means of determining the version of TOTPP.",
      childs = {},
    },
    movementMultipliers = {
      type = "lib",
      description = "Provided by the Movement multipliers patch.  Provides a means of accessing and changing the movement multipliers.",
      childs = {},
    },
    mod = {
      type = "lib",
      description = "Provides a means of accessing certain parameters for mods.",
      childs = {},
    },    
  },
}


--    3. Custom API elements that could not be parsed with my parser
--[[
onCalculateCityYield (since 0.16)
civ.scen.onCalculateCityYield(function (city, food, shields, trade) -> (foodChange, shieldChangeBeforeWaste, shieldChangeAfterWaste, tradeChangeBeforeCorruption, tradeChangeAfterCorruption)) -> void

Registers a function to be called every time a city calculates its total resource yield. Input is the city, and the food, shields and trade of its tiles. Returns a 5-tuple of modifiers, food change, shield change before waste, shield change after waste, trade change before corruption, trade change after corruption. These modifiers are applied at the following points in the calculation:
Calculate yield from all worked tiles
Run onCalculateCityYield
Add foodChange, shieldChangeBeforeWaste and tradeChangeBeforeCorruption
Add changes from food trade routes
Add shields from improvements
Calculate and subtract waste
Calculate corruption and add changes from commodity trade routes
Calculate corruption again (now using the value after trade routes) and subtract.
Add shieldChangeAfterWaste and tradeChangeAfterCorruption
Calculate Tax/Lux/Sci


onGameEnds
civ.scen.onGameEnds(function (reason) -> boolean) -> void

Registers a function that is called when the game ends. `reason` is an integer between 1 and 6:
1 and 2 - Space race victory. This does not trigger if `onCentauriArrival` has a callback registered.
3 - Conquest victory
4 - Defeat
5 - Retirement
6 - Macro ENDGAME action
Return `true` to end the game, `false` to keep playing.


onInitiateCombat (since 0.16)
civ.scen.onInitiateCombat(function (attacker, defender, attackerDie, attackerPower, defenderDie, defenderPower, isSneakAttack [since 0.17]) -> coroutine) -> void

Registers a function to be called every time combat is initiated. The callback takes seven parameters, the attacker, the defender, attackerDie ('die' as in dice, the attacker's chance to hit), attackerPower (attacker's firepower), defenderDie, defenderPower and isSneakAttack. Returns a coroutine that yields every time it wants to process a round, and returns when it wants combat to end. Example:

civ.scen.onInitiateCombat(function (attacker, defender, attackerDie, attackerPower, defenderDie, defenderPower)
  print("Attacker's die: 1d" .. attackerDie .. ", firepower: " .. attackerPower)
  print("Defender's die: 1d" .. defenderDie .. ", firepower: " .. defenderPower)
  return coroutine.create(function ()
    local round = 0
    while (round < 5 and attacker.hitpoints >= 0 and defender.hitpoints >= 0) do
      print("Round " .. round)
      print(attacker, defender)
      if round % 2 == 0 then
        attacker.damage = attacker.damage + 2
        coroutine.yield(true, defender) -- either attacker or defender
      else
        print("Attack bonus!")
        result = coroutine.yield(false, attackerDie * 2, attackerPower * 2)
        print(result.winner, result.attackerRoll, result.defenderRoll, result.reroll)
      end
      round = round + 1
    end
    print("End of combat")
  end)
end)
This example shows how to limit combat to five rounds, damages the attacker on even rounds and doubles the attacker's values on odd rounds.

If the coroutine yields true as its first value, the game's default combat resolution is skipped for that round and the designer is responsible for updating damage. The second value yielded is either the attacker or the defender, this is used to render animations etc. In this case the coroutine resumes without any values.

If the coroutine yields false as its first value, the game runs its default combat algorithm. The designer can additionally yield modified values for attackerDie, attackerPower, defenderDie and defenderPower (in this order) which will be used by the game for that round. In this case the coroutine resumes with the result of the round, a table containing four values:
winner, this is either attacker or defender.
attackerRoll, the result of the attacker's die roll
defenderRoll, the result of the defender's die roll
reroll, true if a reroll happened. This can happen only if the attacker is tribe 0, the defender is a unit guarding a city, and the city is the capital or the tribe has less than 8 cities in total and the attacker's die roll is higher than the defender's. A reroll can happen at most once.


onTurn
civ.scen.onTurn(function (turn) -> void) -> void

Registers a function that is called at the start of a turn. The basic sequence of this and other "turn" triggers is as follows:
`onTurn` fires
Non-tribe-specific updates take place
`onTribeTurnBegin` fires for tribe 0.
Tribe 0 cities are processed.
`onCityProcessingComplete` fires for tribe 0 (this fires even when a tribe has no cities).
Tribe 0 units move
`onTribeTurnEnd` fires for tribe 0.
All active tribes are processed in order according to the sequence for tribe 0
`onTribeTurnEnd` fires for tribe 7.
`onTurn` fires for the next turn.


flags (get/set)
civ.scen.params.flags -> integer

Bitmask representing scenario flags:

00000000 00000001 Total war
00000000 00000010 Use objective victory
00000000 00000100 Count wonders as objectives
00000000 00001000 Reveal cities
00000000 00010000 No government change
00000000 00100000 No tech conquest
00000000 01000000 No pollution
00000000 10000000 Terrain animation lockout
00000001 00000000 Unit animation lockout
00000010 00000000 .SPR file override
10000000 00000000 WWII AI

patches (get) (since 0.16)
totpp.patches -> table<string, boolean>

Returns a table with the enabled status for all patches. The string keys are the same as the ones used in TOTPP.ini
--]]

documentation["civ"]["childs"]["scen"]["childs"]["onCalculateCityYield"] = { type = "function", description = [[civ.scen.onCalculateCityYield(function (city, food, shields, trade) -> (foodChange, shieldChangeBeforeWaste, shieldChangeAfterWaste, tradeChangeBeforeCorruption, tradeChangeAfterCorruption)) -> void\n\nRegisters a function to be called every time a city calculates its total resource yield. Input is the city, and the food, shields and trade of its tiles. Returns a 5-tuple of modifiers, food change, shield change before waste, shield change after waste, trade change before corruption, trade change after corruption. These modifiers are applied at the following points in the calculation:
Calculate yield from all worked tiles
Run onCalculateCityYield
Add foodChange, shieldChangeBeforeWaste and tradeChangeBeforeCorruption
Add changes from food trade routes
Add shields from improvements
Calculate and subtract waste
Calculate corruption and add changes from commodity trade routes
Calculate corruption again (now using the value after trade routes) and subtract.
Add shieldChangeAfterWaste and tradeChangeAfterCorruption
Calculate Tax/Lux/Sci]], args = "(function(city,food,shields,trade) -> (foodChange, shieldChangeBeforeWaste, shieldChangeAfterWaste, tradeChangeBeforeCorruption, tradeChangeAfterCorruption))", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onGameEnds"] = { type = "function", description = [[civ.scen.onGameEnds(function (reason) -> boolean) -> void\n\nRegisters a function that is called when the game ends. `reason` is an integer between 1 and 6:
1 and 2 - Space race victory. This does not trigger if `onCentauriArrival` has a callback registered.
3 - Conquest victory
4 - Defeat
5 - Retirement
6 - Macro ENDGAME action
Return `true` to end the game, `false` to keep playing.
]], args = "(function(reason)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onInitiateCombat"] = { type = "function", description = [[civ.scen.onInitiateCombat(function (attacker, defender, attackerDie, attackerPower, defenderDie, defenderPower, isSneakAttack) -> coroutine) -> void\n\nRegisters a function to be called every time combat is initiated. The callback takes seven parameters, the attacker, the defender, attackerDie ('die' as in dice, the attacker's chance to hit), attackerPower (attacker's firepower), defenderDie, defenderPower and isSneakAttack. Returns a coroutine that yields every time it wants to process a round, and returns when it wants combat to end. Example:
  
civ.scen.onInitiateCombat(function (attacker, defender, attackerDie, attackerPower, defenderDie, defenderPower)
  print("Attacker's die: 1d" .. attackerDie .. ", firepower: " .. attackerPower)
  print("Defender's die: 1d" .. defenderDie .. ", firepower: " .. defenderPower)
  return coroutine.create(function ()
    local round = 0
    while (round < 5 and attacker.hitpoints >= 0 and defender.hitpoints >= 0) do
      print("Round " .. round)
      print(attacker, defender)
      if round % 2 == 0 then
        attacker.damage = attacker.damage + 2
        coroutine.yield(true, defender) -- either attacker or defender
      else
        print("Attack bonus!")
        result = coroutine.yield(false, attackerDie * 2, attackerPower * 2)
        print(result.winner, result.attackerRoll, result.defenderRoll, result.reroll)
      end
      round = round + 1
    end
    print("End of combat")
  end)
end)
This example shows how to limit combat to five rounds, damages the attacker on even rounds and doubles the attacker's values on odd rounds.

If the coroutine yields true as its first value, the game's default combat resolution is skipped for that round and the designer is responsible for updating damage. The second value yielded is either the attacker or the defender, this is used to render animations etc. In this case the coroutine resumes without any values.

If the coroutine yields false as its first value, the game runs its default combat algorithm. The designer can additionally yield modified values for attackerDie, attackerPower, defenderDie and defenderPower (in this order) which will be used by the game for that round. In this case the coroutine resumes with the result of the round, a table containing four values:
winner, this is either attacker or defender.
attackerRoll, the result of the attacker's die roll
defenderRoll, the result of the defender's die roll
reroll, true if a reroll happened. This can happen only if the attacker is tribe 0, the defender is a unit guarding a city, and the city is the capital or the tribe has less than 8 cities in total and the attacker's die roll is higher than the defender's. A reroll can happen at most once.
]], args = "(function(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower,isSneakAttack)->coroutine)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onTurn"] = { type = "function", description =[[civ.scen.onTurn(function (turn) -> void) -> void\n\nRegisters a function that is called at the start of a turn. The basic sequence of this and other \"turn\" triggers is as follows:
onTurn` fires
Non-tribe-specific updates take place
`onTribeTurnBegin` fires for tribe 0.
Tribe 0 cities are processed.
`onCityProcessingComplete` fires for tribe 0 (this fires even when a tribe has no cities).
Tribe 0 units move
`onTribeTurnEnd` fires for tribe 0.
All active tribes are processed in order according to the sequence for tribe 0
`onTribeTurnEnd` fires for tribe 7.
`onTurn` fires for the next turn.]], args = "(function(turn)->void)", returns = "(void)", valuetype = "void",}


documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["flags"] = { type = [[value]], description = [[(get/set)\nciv.scen.params.flags -> integer\n\nBitmask representing scenario flags:
00000000 00000001 Total war
00000000 00000010 Use objective victory
00000000 00000100 Count wonders as objectives
00000000 00001000 Reveal cities
00000000 00010000 No government change
00000000 00100000 No tech conquest
00000000 01000000 No pollution
00000000 10000000 Terrain animation lockout
00000001 00000000 Unit animation lockout
00000010 00000000 .SPR file override
10000000 00000000 WWII AI]], valuetype = "integer",}


-- totpp.patches
documentation.totpp.childs.patches.childs.EndPlayerTurn={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to EndPlayerTurn is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DirectShowAudio={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DirectShowAudio is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DirectShowVideo={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DirectShowVideo is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DecreaseCPUUse={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DecreaseCPUUse is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.NativeTransport={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to NativeTransport is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CityUnitLimits={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CityUnitLimits is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Playable={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Playable is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.HealthBars={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to HealthBars is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CityWorkingTiles={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CityWorkingTiles is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.MovementRate={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to MovementRate is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.LWSettings={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to LWSettings is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CivilopediaWonderGraphics={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CivilopediaWonderGraphics is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.NoStackKills={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to NoStackKills is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.MouseWheel={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to MouseWheel is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ResourceAnimationLoop={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ResourceAnimationLoop is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TradeRevenue={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TradeRevenue is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ImpassableAir={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ImpassableAir is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Throneroom={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Throneroom is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TeleporterMapCheck={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TeleporterMapCheck is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.LuaScripting={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to LuaScripting is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.MoveUnitEvent={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to MoveUnitEvent is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.NoLimits={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to NoLimits is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CityWinUnitSelect={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CityWinUnitSelect is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DebugScripts={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DebugScripts is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.SaveExt={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to SaveExt is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TransformCheck={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TransformCheck is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.UnitOrientation={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to UnitOrientation is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ImprovementIcons={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ImprovementIcons is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.MajorObjective={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to MajorObjective is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ModifyReputation={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ModifyReputation is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DefenseBonus={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DefenseBonus is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ShieldColors={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ShieldColors is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.StealTech={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to StealTech is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ProductionCarryOver={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ProductionCarryOver is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DirectShowMusic={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DirectShowMusic is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ResetCityName={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ResetCityName is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CityPopulationLoss={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CityPopulationLoss is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Movedebug={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Movedebug is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.BuildTransporter={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to BuildTransporter is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.EventHeap={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to EventHeap is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CityWinUnitDisband={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CityWinUnitDisband is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Difficulty={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Difficulty is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CustomModResources={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CustomModResources is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.UnitIndicators={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to UnitIndicators is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Mutex={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Mutex is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.LuaScenario={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to LuaScenario is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.FixHostility={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to FixHostility is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.EditTerrainKeys={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to EditTerrainKeys is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Units={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Units is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.SettlerFlags={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to SettlerFlags is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.NavigableRivers={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to NavigableRivers is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.RoadTrade={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to RoadTrade is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Reporting={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Reporting is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.AITweaks={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to AITweaks is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Landmarks={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Landmarks is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ZoomLevel={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ZoomLevel is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.FixEditControl={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to FixEditControl is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.MapLayout={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to MapLayout is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CombatAnimation={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CombatAnimation is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Mods={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Mods is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.RushBuy={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to RushBuy is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ShipDisband={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ShipDisband is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CitySprites={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CitySprites is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CityView={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CityView is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.PikemenFlag={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to PikemenFlag is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Techs={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Techs is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.AttacksPerTurn={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to AttacksPerTurn is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.ImprovementFlags={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to ImprovementFlags is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TerrainOverlays={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TerrainOverlays is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Overview={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Overview is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.GlobalWarming={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to GlobalWarming is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TransformTech={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TransformTech is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.AcivateUnitScrollbar={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to AcivateUnitScrollbar is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Cosmic={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Cosmic is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TakeTechnology={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TakeTechnology is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.RRMultiplier={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to RRMultiplier is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DiplomacyScreenCrash={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DiplomacyScreenCrash is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.NoCD={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to NoCD is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.Fertility={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to Fertility is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.CustomResources={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to CustomResources is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TOTPPConfig={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TOTPPConfig is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.TerrainTypes={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to TerrainTypes is enabled by the player and false otherwise."}
documentation.totpp.childs.patches.childs.DisabledButton={type="value",returns="(boolean)", valuetype="boolean",description = "Returns `true` if the patch corresponding to DisabledButton is enabled by the player and false otherwise."}



--    4.  Automatically Generated API elements
--    Raw Text
--[[
aggregate (get)
totpp.movementMultipliers.aggregate -> integer

Returns the aggregate movement multiplier (the lcm of the four multipliers above). This value is recalculated when setting any of the individual multipliers. This is an alias for `civ.cosmic.roadMultiplier`.


alpine (get/set - ephemeral)
totpp.movementMultipliers.alpine -> integer

Returns the alpine movement multiplier if it is set, `nil` otherwise.


railroad (get/set - ephemeral)
totpp.movementMultipliers.railroad -> integer

Returns the railroad movement multiplier if it is set, `nil` otherwise.


river (get/set - ephemeral)
totpp.movementMultipliers.river -> integer

Returns the river movement multiplier if it is set, `nil` otherwise.


road (get/set - ephemeral)
totpp.movementMultipliers.road -> integer

Returns the road movement multiplier if it is set, `nil` otherwise.


premadeMap (get)
totpp.mod.premadeMap -> boolean

Returns `true` if the game was started on a pre-made map, `false` otherwise. Only valid right after starting a new game.


active (get)
tribe.active -> boolean

Returns whether the tribe is active, i.e. a human or AI player in the current game.


adjective (get/set)
tribe.adjective -> string

Returns the adjectival form of the tribe's name (e.g. "Roman").


betrayals (get/set)
tribe.betrayals -> integer

Returns the number of times the tribe has betrayed another tribe.


futureTechs (get/set)
tribe.futureTechs -> integer

Returns the number of future techs the tribe has researched.


government (get/set)
tribe.government -> integer

Returns the government (0 - 6) of the tribe.


id (get)
tribe.id -> integer

Returns the id of the tribe.


isHuman (get/set)
tribe.isHuman -> boolean

Returns whether the tribe is a/the human player.


leader (get)
tribe.leader -> leader

Returns the leader of the tribe.


money (get/set)
tribe.money -> integer

Returns the amount of money/gold in the tribe's treasury.


name (get/set)
tribe.name -> string

Returns the name of the tribe (e.g. "Romans").


numCities (get)
tribe.numCities -> integer

Returns the number of cities the tribe has.


numTechs (get/set)
tribe.numTechs -> integer

Returns the number of techs the tribe has.


numUnits (get)
tribe.numUnits -> integer

Returns the number of units the tribe has.


patience (get/set)
tribe.patience -> integer

Returns the tribe's patience.


researchCost (get)
tribe.researchCost -> integer

Returns the research cost of the tribe.


researchProgress (get/set)
tribe.researchProgress -> integer

Returns the progress towards the current research (range between 0 and tribe.researchCost).


researching (get/set)
tribe.researching -> tech

Returns the tech the tribe is currently researching, or `nil` if not researching anything.


scienceRate (get)
tribe.scienceRate -> integer

Returns the science rate of the tribe.


spaceship (get)
tribe.spaceship -> spaceship

Returns the space ship object of the tribe.


taxRate (get)
tribe.taxRate -> integer

Returns the tax rate of the tribe.


enableTechGroup
tribe:enableTechGroup(techgroup, value) -> void

Alias for `civ.enableTechGroup(tribe, techgroup, value)`.


giveTech
tribe:giveTech(tech) -> void

Alias for `civ.giveTech(tribe, tech)`.


hasTech
tribe:hasTech(tech) -> boolean

Alias for `civ.hasTech(tribe, tech)`.


kill
tribe:kill() -> void

Alias for `civ.killTribe(tribe)`.


takeTech
tribe:takeTech(tech, collapse=false) -> void

Alias for `civ.takeTech(tribe, tech, collapse=false)`.


Properties

cantSell (get/set - ephemeral)
improvement.cantSell -> boolean

Returns `true` if the improvement cannot be sold, `false` otherwise. Requires the "Improvement flags" patch.


cost (get/set - ephemeral)
improvement.cost -> integer

Returns the cost of the improvement in rows. Multiply by civ.cosmic.shieldRows for the actual production cost.


id (get)
improvement.id -> integer

Returns the id of the improvement.


name (get)
improvement.name -> string

Returns the name of the improvement (e.g. "Barracks").


onCapture (get/set - ephemeral)
improvement.onCapture -> integer

Returns what happens to this improvement when a city is captured (0 - Default, 1 - Preserve, 2 - Destroy, 3 - Random). Requires the "Improvement flags" patch.


prereq (get/set - ephemeral)
improvement.prereq -> tech

Returns the prerequisite tech of the improvement.


upkeep (get/set - ephemeral) (since 0.16)
improvement.upkeep -> integer

Returns the upkeep cost of the improvement.


aiValue (get/set - ephemeral)
tech.aiValue -> integer

Returns the AI value of the tech.


category (get/set - ephemeral)
tech.category -> integer

Returns the category of the tech.


epoch (get/set - ephemeral)
tech.epoch -> integer

Returns the epoch of the tech.


group (get/set - ephemeral)
tech.group -> integer

Returns the group of the tech.


id (get)
tech.id -> integer

Returns the id of the tech.


modifier (get/set - ephemeral)
tech.modifier -> integer

Returns the modifier to the AI value based on leader personality.


name (get)
tech.name -> string

Returns the name of the tech.


prereq1 (get/set - ephemeral)
tech.prereq1 -> tech

Returns the first prerequisite of the tech.


prereq2 (get/set - ephemeral)
tech.prereq2 -> tech

Returns the second prerequisite of the tech.


researched (get)
tech.researched -> boolean

Returns whether or not any tribe has researched the tech.


attack (get/set - ephemeral)
leader.attack -> integer

Returns the "attack" value of the leader's personality.


cityStyle (get/set - ephemeral)
leader.cityStyle -> integer

Returns the leader's city style.


civilize (get/set - ephemeral)
leader.civilize -> integer

Returns the "civilize" value of the leader's personality.


color (get/set - ephemeral)
leader.color -> integer

Returns the leader's color.


expand (get/set - ephemeral)
leader.expand -> integer

Returns the "expand" value of the leader's personality.


female (get/set)
leader.female -> boolean

Returns whether or not the leader is female.


id (get)
leader.id -> integer

Returns the id of the leader.


name (get/set)
leader.name -> string

Returns the name of the leader.


city (get/set)
wonder.city -> city

Returns the city that has built the wonder, `nil` if not built yet or destroyed.


cost (get/set - ephemeral)
wonder.cost -> integer

Returns the cost of the wonder.


destroyed (get)
wonder.destroyed -> boolean

Returns whether or not the wonder is destroyed. Use wonder:destroy() to set this field.


expires (get/set - ephemeral)
wonder.expires -> tech

Returns the tech that renders the wonder obsolete, or `nil` if there isn't any.


id (get)
wonder.id -> integer

Returns the id of the wonder.


name (get)
wonder.name -> string

Returns the name of the wonder.


prereq (get/set - ephemeral)
wonder.prereq -> tech

Returns the prerequisite technology of the wonder.


destroy
wonder:destroy() -> void

Alias for `civ.destroyWonder(wonder)`.


attackSpent (get/set) (since 0.18)
unit.attackSpent -> integer

Returns the number of attacks spent by the unit (from the 'Attacks per turn' patch).


attributes (get/set)
unit.attributes -> integer

Returns the attributes of the unit (bitmask).


carriedBy (get/set)
unit.carriedBy -> unit

Returns the carrying unit if this unit is currently on board, `nil` otherwise. The game shares the memory location of this field with gotoTile.x, so don't use this field if gotoTile is not `nil`.


damage (get/set)
unit.damage -> integer

Returns the damage taken by the unit in hitpoints.


domainSpec (get/set) (since 0.16)
unit.domainSpec -> integer

Returns the value of the 'domain-specific counter' of the unit.


gotoTile (get/set)
unit.gotoTile -> tile

Returns the tile the unit is moving to under the goto order, or `nil` if it doesn't have the goto order.


hitpoints (get)
unit.hitpoints -> integer

Returns the number of hitpoints left. It is defined as unit.type.hitpoints - unit.damage.


homeCity (get/set)
unit.homeCity -> city

Returns the unit's home city, or `nil` if it doesn't have one.


id (get)
unit.id -> integer

Returns the unit's id.


location (get)
unit.location -> tile

Returns the unit's location.


moveSpent (get/set)
unit.moveSpent -> integer

Returns the number of moves spent by the unit.


order (get/set)
unit.order -> integer

Returns the current order of the unit.


owner (get/set)
unit.owner -> tribe

Returns the unit's owner.


type (get)
unit.type -> unittype

Returns the unit's type.


veteran (get/set)
unit.veteran -> boolean

Returns the veteran status of the unit.


visibility (get/set) (since 0.17)
unit.visibility -> integer

Returns the unit visibility mask.


activate
unit:activate() -> void

Activates a unit, clearing its orders, and, if it has a human owner and movement points left, selects it on the map.


teleport
unit:teleport(tile) -> void

Alias for `civ.teleportUnit(unit, tile)`.


advancedFlags (get/set - ephemeral) (since 0.16)
unittype.advancedFlags -> integer

Returns the 'advanced flags' settings of the unit type (bitmask).


attack (get/set - ephemeral)
unittype.attack -> integer

Returns the attack factor of the unit type.


attacksPerTurn (get/set - ephemeral) (since 0.18)
unittype.attacksPerTurn -> integer

Returns the number of attacks available per turn of the unit type (from the 'Attacks per turn' patch).


buildTransport (get/set)
unittype.buildTransport -> integer

Returns the 'build transport site' settings of the unit type (bitmask).


cost (get/set - ephemeral)
unittype.cost -> integer

Returns the cost of the unit type.


defense (get/set - ephemeral)
unittype.defense -> integer

Returns the defense factor of the unit type.


domain (get/set - ephemeral)
unittype.domain -> integer

Returns the domain of the unit type (0 - Ground, 1 - Air, 2 - Sea).


expires (get/set - ephemeral)
unittype.expires -> tech

Returns the tech that renders the unit obsolete, or `nil` if there isn't any.


firepower (get/set - ephemeral)
unittype.firepower -> integer

Returns the firepower of the unit type.


flags (get/set - ephemeral)
unittype.flags -> integer

Returns the flags of the unit type (bitmask).


hitpoints (get/set - ephemeral)
unittype.hitpoints -> integer

Returns the number of hit points of the unit type.


hold (get/set - ephemeral)
unittype.hold -> integer

Returns the number of holds of the unit type.


id (get)
unittype.id -> integer

Returns the id of the unit type.


minimumBribe (get/set - ephemeral) (since 0.16)
unittype.minimumBribe -> integer

Returns the minimum amount to bribe the unit type.


move (get/set - ephemeral)
unittype.move -> integer

Returns the movement rate of the unit type.


name (get)
unittype.name -> string

Returns the name of the unit type.


nativeTransport (get/set)
unittype.nativeTransport -> integer

Returns the 'native transport' settings of the unit type (bitmask).


notAllowedOnMap (get/set - ephemeral) (since 0.16)
unittype.notAllowedOnMap -> integer

Returns the 'not allowed on map' settings of the unit type (bitmask).


prereq (get/set - ephemeral)
unittype.prereq -> tech

Returns the prerequisite technology of the unit type, or `nil` if it doesn't have one.


range (get/set - ephemeral)
unittype.range -> integer

Returns the range of the unit type.


role (get/set - ephemeral)
unittype.role -> integer

Returns the role of the unit type.


tribeMayBuild (get/set - ephemeral) (since 0.16)
unittype.tribeMayBuild -> integer

Returns the 'tribe may build' settings of the unit type (bitmask).


useTransport (get/set)
unittype.useTransport -> integer

Returns the 'use transport site' settings of the unit type (bitmask).


canEnter
unittype:canEnter(tile) -> boolean

Alias for `civ.canEnter(unittype, tile)`


baseTerrain (get/set) (since 0.16)
tile.baseTerrain -> baseterrain

Returns the baseterrain object associated with the tile.


city (get)
tile.city -> city

Returns the city at the tile's location, or `nil` if there's no city there.


defender (get)
tile.defender -> tribe

Returns the tile's defender.


fertility (get/set)
tile.fertility -> integer

Returns the tile's fertility.


grasslandShield (get) (since 0.16)
tile.grasslandShield -> boolean

Returns `true` if the tile would have a shield when changed to grassland, `false` otherwise.


hasGoodieHut (get) (since 0.18.2)
tile.hasGoodieHut -> boolean

Returns `true` if the tile has a goodie hut, `false` otherwise.


improvements (get/set)
tile.improvements -> integer

Returns the tile's improvements (bitmask).


landmass (get/set)
tile.landmass -> integer

Returns the tile's landmass index.


owner (get/set)
tile.owner -> tribe

Returns the tribe owning the tile.


river (get/set)
tile.river -> boolean

Returns `true` if the tile has a river, `false` otherwise.


terrain (get/set) (since 0.16)
tile.terrain -> terrain

Returns the terrain object associated with the tile.


terrainType (get/set)
tile.terrainType -> integer

Returns the terrain type of the tile.


units (get)
tile.units -> iterator

Returns an iterator yielding all units at the tile's location.


visibility (get/set) (since 0.16)
tile.visibility -> integer

Returns the tile's visibility for each tribe (bitmask).


x (get)
tile.x -> integer

Returns the `x` coordinate of the tile.


y (get)
tile.y -> integer

Returns the `y` coordinate of the tile.


z (get)
tile.z -> integer

Returns the `z` coordinate of the tile (map number).


customResources (get/set)
map.customResources -> boolean

Returns `true` if custom resources are enabled for this map, `false` otherwise.


height (get)
map.height -> integer

Returns the height of the map.


id (get)
map.id -> integer

Returns the id of the map.


width (get)
map.width -> integer

Returns the width of the map.


copyDefaultResources
map:copyDefaultResources() -> void

Enables custom resources for this map and copies the default resource pattern. Requires the "Custom resources" patch.


getBaseTerrain
map:getBaseTerrain(terrainType) -> baseterrain

Alias for `civ.getBaseTerrain(map, terrainType)`


getTerrain
map:getTerrain(terrainType, resource) -> terrain

Alias for `civ.getTerrain(map, terrainType, resource)`


abbrev (get)
baseterrain.abbrev -> string

The terrain abbreviation for this baseterrain (e.g. 'Drt', 'Pln' etc.).


canIrrigate (get/set - ephemeral)
baseterrain.canIrrigate -> boolean

Returns `true` if the underlying terrain type allows irrigation, `false` otherwise.


canMine (get/set - ephemeral)
baseterrain.canMine -> boolean

Returns `true` if the underlying terrain type allows mining, `false` otherwise.


defense (get/set - ephemeral)
baseterrain.defense -> integer

The defense factor of the underlying terrain type.


impassable (get/set - ephemeral)
baseterrain.impassable -> boolean

Returns `true` if the underlying terrain type is impassable, `false` otherwise.


irrigateAI (get/set - ephemeral)
baseterrain.irrigateAI -> integer

The minimum government level needed for the AI to consider irrigating.


irrigateBonus (get/set - ephemeral)
baseterrain.irrigateBonus -> integer

The extra amount of food from irrigation.


irrigateTo (get/set - ephemeral)
baseterrain.irrigateTo -> baseterrain

If the irrigation order changes the underlying terrain type return the baseterrain of the new terrain type, `nil` otherwise.


irrigateTurns (get/set - ephemeral)
baseterrain.irrigateTurns -> integer

The number of turns for settlers to irrigate.


map (get)
baseterrain.map -> integer

The map associated with the baseterrain object.


mineAI (get/set - ephemeral)
baseterrain.mineAI -> integer

The minimum government level needed for the AI to consider mining.


mineBonus (get/set - ephemeral)
baseterrain.mineBonus -> integer

The extra amount of production from mining.


mineTo (get/set - ephemeral)
baseterrain.mineTo -> baseterrain

If the mine order changes the underlying terrain type return the baseterrain of the new terrain type, `nil` otherwise.


mineTurns (get/set - ephemeral)
baseterrain.mineTurns -> integer

The number of turns for settlers to mine.


moveCost (get/set - ephemeral)
baseterrain.moveCost -> integer

The movement cost of the underlying terrain type.


name (get)
baseterrain.name -> string

The name of this baseterrain.


transformTo (get/set - ephemeral)
baseterrain.transformTo -> baseterrain

If the underlying terrain type can be transformed return the baseterrain of the new terrain type, `nil` otherwise.


type (get)
baseterrain.type -> integer

The terrain type associated with the baseterrain object.


getTerrain
baseterrain:getTerrain(resource) -> terrain

Returns the terrain object corresponding to the underlying terrain type and the given resource.


baseTerrain (get)
terrain.baseTerrain -> baseterrain

The underlying baseterrain of the terrain object.


food (get/set - ephemeral)
terrain.food -> integer

The amount of food produced by the terrain.


map (get)
terrain.map -> integer

The map associated with the terrain object.


name (get)
terrain.name -> string

The name of the terrain.


resource (get)
terrain.resource -> integer

The resource associated with the terrain object.


shields (get/set - ephemeral)
terrain.shields -> integer

The amount of shields produced by the terrain.


trade (get/set - ephemeral)
terrain.trade -> integer

The amount of trade produced by the terrain.


type (get)
terrain.type -> integer

The terrain type associated with the terrain object.


attributes (get/set)
city.attributes -> integer

Returns the city's attributes (bitmask).


baseTrade (get)
city.baseTrade -> integer

Returns the number of trade arrows before trade routes.


coastal (get)
city.coastal -> boolean

Returns whether or not the city is on a coast (can build coastal improvements).


currentProduction (get/set) (since 0.16)
city.currentProduction -> prodItem

Returns the city's current production.


food (get/set)
city.food -> integer

Returns the quantity of food in store.


id (get)
city.id -> integer

Returns the city's id.


knownTo (get/set)
city.knownTo -> integer

Returns a bitmask indicating the tribes that have knowledge of this city.


location (get)
city.location -> tile

Returns the city's location. See the `relocate` method for a way to set this.


name (get/set)
city.name -> string

Returns the city's name.


numHappy (get)
city.numHappy -> integer

Returns the number of happy citizens.


numTradeRoutes (get)
city.numTradeRoutes -> integer

Returns the number of trade routes of the city.


numUnhappy (get)
city.numUnhappy -> integer

Returns the number of unhappy citizens.


originalOwner (get/set)
city.originalOwner -> tribe

Returns the city's original owner. This can be different from `owner` if the city was captured in the past.


owner (get/set)
city.owner -> tribe

Returns the city's owner.


science (get)
city.science -> integer

Returns the amount of science the city produces.


shields (get/set)
city.shields -> integer

Returns the number of shields towards the current item in production.


size (get/set)
city.size -> integer

Returns the city's size.


specialists (get/set)
city.specialists -> integer

Returns the city's specialists as a integer, 16 x 2 bits per specialist (0 - No specialist, 1 - Entertainer, 2 - Taxman, 3 - Scientist)


tax (get)
city.tax -> integer

Returns the amount of tax the city produces.


totalFood (get)
city.totalFood -> integer

Returns the total amount of food the city produces.


totalShield (get)
city.totalShield -> integer

Returns the total amount of shields the city produces.


totalTrade (get)
city.totalTrade -> integer

Returns the total amount of trade arrows the city produces (including trade routes).


turnsSinceCapture (get/set)
city.turnsSinceCapture -> integer

Returns the number of turns since the city was last captured.


workers (get/set)
city.workers -> integer

Returns a bitmask with the workers and specialists of the city.


addImprovement
city:addImprovement(improvement) -> void

Alias for `civ.addImprovement(city, improvement)`.


addTradeRoute (since 0.17)
city:addTradeRoute(destination, commodity) -> void

Adds a new trade route to city `destination`, with commodity `commodity`. Returns an error if all 3 trade slots are already in use.


canBuild
city:canBuild(item) -> boolean

Returns whether or not `item` can currently be built in the city. `item` can be a unittype, improvement or wonder.


hasImprovement
city:hasImprovement(improvement) -> boolean

Alias for `civ.hasImprovement(city, improvement)`.


popTradeRoute (since 0.17)
city:popTradeRoute() -> void

Removes the last trade route, or does nothing if no trade routes are in use.


relocate
city:relocate(tile) -> boolean

Relocates the city to the location given by `tile`. Returns `true` if successful, `false` otherwise (if a city is already present for example).


removeImprovement
city:removeImprovement(improvement) -> void

Alias for `civ.removeImprovement(city, improvement)`.


removeTradeRoute (since 0.17)
city:removeTradeRoute(id) -> void

Removes the trade route with index `id` (0-2). This shifts elements after `id` to fill gaps in the array, so references to trade routes may not be valid anymore after calling this.


addImprovement
civ.addImprovement(city, improvement) -> void

Adds city improvement `improvement` to city `city`.


canEnter
civ.canEnter(unittype, tile) -> boolean

Returns `true` if the given unittype can enter tile `tile`, `false` otherwise.


captureCity
civ.captureCity(city, tribe) -> void

Captures city `city` for tribe `tribe`.


createCity
civ.createCity(tribe, tile) -> city

Creates a city owned by `tribe` at the location given by `tile`. Returns `nil` if a city could not be created.


createUnit
civ.createUnit(unittype, tribe, tile) -> unit

Creates a unit of type `unittype`, owned by `tribe`, at the location given by `tile`.


deleteCity
civ.deleteCity(city) -> void

Deletes city `city` from the game.


deleteUnit
civ.deleteUnit(unit) -> void

Deletes unit `unit` from the game.


destroyWonder
civ.destroyWonder(wonder) -> void

Destroys wonder `wonder`, removing it from the game, and marking it as 'lost'.


enableTechGroup
civ.enableTechGroup(tribe, techgroup, value) -> void

Sets the value of tech group `techgroup` (0-7) to value `value` (0-2, 0 = can research, can own, 1 = can't research, can own, 2 = can't research, can't own) for tribe `tribe`.


endGame
civ.endGame(endscreens=false) -> void

Ends the game. `endscreens` is a boolean that determines whether to show the powergraph and related screens.


getActiveUnit
civ.getActiveUnit() -> unit

Returns the currently active unit.


getAtlasDimensions (since 0.16)
civ.getAtlasDimensions() -> width, height, number_of_maps

Returns three integers, the width and height of the map and the number of maps.


getBaseTerrain (since 0.16)
civ.getBaseTerrain(map, terrainType) -> baseterrain

Returns the base terrain object for the given map and terrain type.


getCity
civ.getCity(id) -> city

Returns the city with id `id`, or `nil` if it doesn't exist.


getCommodity (since 0.17)
civ.getCommodity(id) -> commodity

Returns the commodity with id `id` (0-15 for regular commodities, -1 for food supplies), or `nil` if it doesn't exist.


getCurrentTile
civ.getCurrentTile() -> tile

Returns the currently selected tile.


getCurrentTribe
civ.getCurrentTribe() -> tribe

Returns the currently active tribe.


getGameYear
civ.getGameYear() -> integer

Returns the current game year.


getImprovement
civ.getImprovement(id) -> improvement

Returns the improvement with id `id` (0-39), or `nil` if it doesn't exist.


getMap (since 0.16)
civ.getMap(id) -> map

Returns the map with id `id` (0-3) or `nil` if it doesn't exist.


getMapDimensions (deprecated since 0.16)
civ.getMapDimensions() -> width, height, number_of_maps

Alias for getAtlasDimensions.


getOpenCity (since 0.16)
civ.getOpenCity() -> city

Returns the city currently opened in the city window, `nil` if the city window is closed.


getPlayerTribe
civ.getPlayerTribe() -> tribe

Returns the player's tribe.


getTech
civ.getTech(id) -> tech

Returns the tech with id `id` (0-99), or `nil` if it doesn't exist.


getTerrain (since 0.16)
civ.getTerrain(map, terrainType, resource) -> terrain

Returns the terrain object for the given map, terrain type and resource.


getTile
civ.getTile(x, y, z) -> tile

Returns the tile with coordinates `x`, `y`, `z`, or `nil` if it doesn't exist.


getToTDir
civ.getToTDir() -> string

Returns the absolute path of the ToT installation directory.


getTribe
civ.getTribe(id) -> tribe

Returns the tech with id `id` (0-7), or `nil` if it doesn't exist.


getTurn
civ.getTurn() -> integer

Returns the current turn number.


getUnit
civ.getUnit(id) -> integer

Returns the unit with id `id`, or `nil` if it doesn't exist.


getUnitType
civ.getUnitType(id) -> unittype

Returns the unit type with id `id`, or `nil` if it doesn't exist.


getWonder
civ.getWonder(id) -> wonder

Returns the wonder with id `id` (0-27), or `nil` if it doesn't exist.


giveTech
civ.giveTech(tribe, tech) -> void

Gives tech `tech` to tribe `tribe`.


hasImprovement
civ.hasImprovement(city, improvement) -> void

Returns `true` if city `city` has improvement `improvement`, `false` otherwise.


hasTech
civ.hasTech(tribe, tech) -> boolean

Returns `true` if tribe `tribe` has tech `tech`, `false` otherwise.


isBaseTerrain (since 0.16)
civ.isBaseTerrain(object) -> boolean

Returns `true` if `object` is a base terrain, `false` otherwise.


isCity
civ.isCity(object) -> boolean

Returns `true` if `object` is a city, `false` otherwise.


isDialog (since 0.16)
civ.isDialog(object) -> boolean

Returns `true` if `object` is a dialog, `false` otherwise.


isImage (since 0.16)
civ.isImage(object) -> boolean

Returns `true` if `object` is an image, `false` otherwise.


isImprovement
civ.isImprovement(object) -> boolean

Returns `true` if `object` is a city improvement, `false` otherwise.


isLeader
civ.isLeader(object) -> boolean

Returns `true` if `object` is a leader, `false` otherwise.


isMap (since 0.16)
civ.isMap(object) -> boolean

Returns `true` if `object` is a map, `false` otherwise.


isTech
civ.isTech(object) -> boolean

Returns `true` if `object` is a tech, `false` otherwise.


isTerrain (since 0.16)
civ.isTerrain(object) -> boolean

Returns `true` if `object` is a terrain, `false` otherwise.


isTile
civ.isTile(object) -> boolean

Returns `true` if `object` is a tile, `false` otherwise.


isTradeRoute (since 0.17)
civ.isTradeRoute(object) -> boolean

Returns `true` if `object` is a trade route, `false` otherwise.


isTribe
civ.isTribe(object) -> boolean

Returns `true` if `object` is a tribe, `false` otherwise.


isUnit
civ.isUnit(object) -> boolean

Returns `true` if `object` is a unit, `false` otherwise.


isUnitType
civ.isUnitType(object) -> boolean

Returns `true` if `object` is a unit type, `false` otherwise.


isWonder
civ.isWonder(object) -> boolean

Returns `true` if `object` is a wonder, `false` otherwise.


iterateCities
civ.iterateCities() -> iterator

Returns an iterator yielding all cities in the game.


iterateUnits
civ.iterateUnits() -> iterator

Returns an iterator yielding all units in the game.


killTribe
civ.killTribe(tribe) -> void

Removes tribe `tribe` from the game. All its cities and units are removed.


makeAggression
civ.makeAggression(who, whom) -> void

Cancels any peace treaties between tribe `who` and tribe `whom`, and make `who` declare war on `whom`.


playMusic
civ.playMusic(trackNo or filename) -> void

Plays CD track `trackNo`, or with the DirectShow music patch enabled, play the file given by `filename`, where `filename` is relative to the 'Music' directory.


playSound
civ.playSound(filename) -> void

Plays the sound file given by `filename`.


playVideo
civ.playVideo(filename) -> void

Plays the video file given by `filename`.


removeImprovement
civ.removeImprovement(city, improvement) -> void

Removes city improvement `improvement` from city `city`.


sleep
civ.sleep(milliseconds) -> void

Sleeps for the given number of milliseconds.


takeTech
civ.takeTech(tribe, tech, collapse=false) -> void

Takes away tech `tech` from tribe `tribe`, the optional `collapse` parameter determines whether to take away all techs that have `tech` as a prerequisite somewhere up the tree.


teleportUnit
civ.teleportUnit(unit, tile) -> void

Teleports (i.e. moves at no cost) unit `unit` to tile `tile`. The unit is moved regardless of whether it is a valid location for the unit. To check this, see `civ.canEnter` and `civlua.isValidUnitLocation`.


centerView
civ.ui.centerView(tile) -> void

Centers the map on the given tile.


createDialog
civ.ui.createDialog() -> dialog

Creates and initializes a dialog. See the dialog section for more details.


loadImage
civ.ui.loadImage(filename, [x], [y], [width], [height]) -> image

Loads an image (BMP or GIF) from `filename`. Optionally accepts `x`, `y`, `width` and `height` to load part of the image.


loadTerrain
civ.ui.loadTerrain(map, filename1, filename2) -> void

Replaces terrain graphics for map number `map`, loading graphics from `filename1` (corresponding to "TERRAIN1.BMP") and `filename2` (corresponding to "TERRAIN2.BMP")


redrawMap
civ.ui.redrawMap() -> void

Redraws the entire map.


redrawTile
civ.ui.redrawTile(tile) -> void

Redraws the given tile.


setZoom
civ.ui.setZoom(integer) -> void

Sets the zoom level (range from -7 (max zoom out) to 8 (max zoom in)).


text
civ.ui.text(string) -> void

Display a pop-up text box with the given string as text.


zoomIn
civ.ui.zoomIn() -> void

Zooms in on the map (increases zoom level by 1).


zoomOut
civ.ui.zoomOut() -> void

Zooms out of the map (decreases zoom level by 1).


communismPalaceDistance (get/set - ephemeral)
cosmic.communismPalaceDistance -> integer

Returns the distance from palace used in happiness calculations under Communism.


foodEaten (get/set - ephemeral)
cosmic.foodEaten -> integer

Returns the amount of food eaten by each citizen each turn.


foodRows (get/set - ephemeral)
cosmic.foodRows -> integer

Returns the number of rows in the food box.


goodieHutsMask (get/set - ephemeral)
cosmic.goodieHutsMask -> integer

Returns the bitmask for goodie huts.


helisPickupHuts (get/set - ephemeral)
cosmic.helisPickupHuts -> integer

Returns whether helicopters (domain 1, range 0 units) pick up huts or not.


massThrustParadigm (get/set - ephemeral)
cosmic.massThrustParadigm -> integer

Returns the mass/thrust paradigm.


numberOfUnitTypes (get)
cosmic.numberOfUnitTypes -> integer

Returns the number of unit types from the @COSMIC2 key of the same name.


paradropRange (get/set - ephemeral)
cosmic.paradropRange -> integer

Returns the maximum paradrop range.


penaltyBetrayal (get/set - ephemeral)
cosmic.penaltyBetrayal -> integer

Returns the penalty to the civilization score for each betrayal of another tribe.


prodChangePenalty (get/set - ephemeral)
cosmic.prodChangePenalty -> integer

Returns the shield penalty percentage for changing production types.


riotFactor (get/set - ephemeral)
cosmic.riotFactor -> integer

Returns the riot factor based on the number of cities.


roadMultiplier (get/set - ephemeral)
cosmic.roadMultiplier -> integer

Returns the road movement multiplier.


scienceLostFundamentalism (get/set - ephemeral)
cosmic.scienceLostFundamentalism -> integer

Returns the percentage of science lost under Fundamentalism.


scienceRateFundamentalism (get/set - ephemeral)
cosmic.scienceRateFundamentalism -> integer

Returns the maximum effective science rate under Fundamentalism.


scoreCentauri (get/set - ephemeral)
cosmic.scoreCentauri -> integer

Returns the civilization score for each landing on Alpha Centauri first. Multiplied by number of habitats and success probability.


scoreCitizen (get/set - ephemeral)
cosmic.scoreCitizen -> integer

Returns the civilization score for each citizen.


scoreFutureTech (get/set - ephemeral)
cosmic.scoreFutureTech -> integer

Returns the civilization score for each future technology researched.


scorePeace (get/set - ephemeral)
cosmic.scorePeace -> integer

Returns the civilization score for each turn of peace after turn 199.


scorePollution (get/set - ephemeral)
cosmic.scorePollution -> integer

Returns the civilization score for each extant non-AI controlled polluted tile. Normally a negative value, i.e. a penalty.


scoreUnitKilled (get/set - ephemeral)
cosmic.scoreUnitKilled -> integer

Returns the civilization score for each unit killed.


scoreWonder (get/set - ephemeral)
cosmic.scoreWonder -> integer

Returns the civilization score for each wonder.


settlersEatHigh (get/set - ephemeral)
cosmic.settlersEatHigh -> integer

Returns the amount of food eaten by settlers for governments ≥ Communism.


settlersEatLow (get/set - ephemeral)
cosmic.settlersEatLow -> integer

Returns the amount of food eaten by settlers for governments ≤ Monarchy.


shieldRows (get/set - ephemeral)
cosmic.shieldRows -> integer

Returns the number of rows in the shield box.


sizeAquaduct (get/set - ephemeral)
cosmic.sizeAquaduct -> integer

Returns the city size that cannot be exceeded without an Aquaduct.


sizeSewer (get/set - ephemeral)
cosmic.sizeSewer -> integer

Returns the city size that cannot be exceeded without a Sewer System.


sizeUnhappiness (get/set - ephemeral)
cosmic.sizeUnhappiness -> integer

Returns the city size at which the first unhappy citizen appears at Chieftain difficulty.


supportCommunism (get/set - ephemeral)
cosmic.supportCommunism -> integer

Returns the number of units that are free of support under Communism.


supportFundamentalism (get/set - ephemeral)
cosmic.supportFundamentalism -> integer

Returns the number of units that are free of support costs under Fundamentalism.


supportMonarchy (get/set - ephemeral)
cosmic.supportMonarchy -> integer

Returns the number of units that are free of support under Monarchy.


techParadigm (get/set - ephemeral)
cosmic.techParadigm -> integer

Returns the tech paradigm. Scenarios use civ.scen.params.techParadigm instead of this value.


transformBase (get/set - ephemeral)
cosmic.transformBase -> integer

Returns the base time needed for engineers to transform terrain.


triremeLost (get/set - ephemeral)
cosmic.triremeLost -> integer

Returns the 1 in x chance of a trireme getting lost at sea.


activeTribes (get/set)
game.activeTribes -> integer

Returns the active tribe mask.


barbarianActivity (get/set)
game.barbarianActivity -> integer

Returns the level of barbarian activity.


difficulty (get/set)
game.difficulty -> integer

Returns the difficulty level.


gameYear (get/set)
game.gameYear -> integer

Returns the game year, or for scenarios with monthly increments, the number of months * 12.


humanPlayers (get/set)
game.humanPlayers -> integer

Returns the human players mask.


humanTribe (get)
game.humanTribe -> tribe

Returns the last active human tribe.


peaceTurns (get/set)
game.peaceTurns -> integer

Returns the number of turns of peace.


revealMap (get/set)
game.revealMap -> boolean

Returns whether or not the full map is revealed.


turnsElapsed (get/set)
game.turnsElapsed -> integer

Returns the number of turns elapsed.


flatWorld (get/set)
game.rules.flatWorld -> boolean

Returns `true` if the world map is flat, `false` otherwise.


onActivateUnit
civ.scen.onActivateUnit(function (unit, source, repeatMove [since 0.17]) -> void) -> void

Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving (see civ.scen.compatibility), `false` otherwise.


onCanBuild
civ.scen.onCanBuild(function (defaultBuildFunction, city, item) -> boolean) -> void

Registers a function to be called every time a check is done whether a city can build something or not. It is called for all unit types, improvements and wonders. The first parameter of the callback is the default build function, as implemented by the game. It takes the city and item as parameters. You can call this to produce a result for cases you don't need to handle yourself. `item` can be a unittype, improvement or wonder.
Return `true` if `city` is allowed to produce `item`, `false` if not.


onBribeUnit
civ.scen.onBribeUnit(function (unit, previousOwner) -> void) -> void

Registers a function that is called when a unit is bribed successfully. unit.owner is the new owner at this point, `previousOwner` the old owner.


onCanFoundCity (since 0.18)
civ.scen.onCanFoundCity(function (unit, advancedTribe) -> boolean) -> void

Registers a function that is called to determine if `unit` can found a city at the unit's location. `advancedTribe` is `true` when picking up a hut with `unit` triggers an advanced tribe. Return `true` to allow, `false` to disallow.


onCentauriArrival
civ.scen.onCentauriArrival(function (tribe) -> void) -> void

Registers a function that is called when a tribe's spaceship reaches its target. Just registering this function causes the game to not end at this point ("endgame override").


onChooseDefender (since 0.17)
civ.scen.onChooseDefender(function (defaultFunction, tile, attacker, isCombat) -> unit) -> void

Registers a function that is called every time a unit is chosen to defend a tile. The first parameter is the default function as implemented by the game. It takes `tile` and `attacker` as parameters. You can call this to produce a result for cases you don't need to handle yourself. The second parameter is the tile that's being considered, the third is the attacking unit, and the fourth, `isCombat`, is a boolean that indicates if this invocation will be followed by combat. This function is also called by the AI to determine its goals, in which case `isCombat` is false.


onCityDestroyed
civ.scen.onCityDestroyed(function (city) -> void) -> void

Registers a function that is called when a city is destroyed.


onCityFounded
civ.scen.onCityFounded(function (city) -> optional (function () -> void)) -> void

Registers a function to be called every time a city is founded. The callback takes the city as a parameter, and can optionally return a function (since 0.18) that is called to perform cleanup when the user cancels founding the city.


onCityProcessingComplete (since 0.18)
civ.scen.onCityProcessingComplete(function (turn, tribe) -> void) -> void

Registers a function that is called when a tribe's cities have been processed for that turn. See `onTurn` for interaction with other "turn" triggers.


onCityProduction
civ.scen.onCityProduction(function (city, prod) -> void) -> void

Registers a function that is called when a city completes its production order. The produced item `prod` is either a unit, improvement or wonder (this can be checked with the civ.is* functions).


onCityTaken
civ.scen.onCityTaken(function (city, defender) -> void) -> void

Registers a function that is called when a city is captured. `city` is the city changing hands, at this point city.owner is the new owner already. `defender` is the old owner.


onGetFormattedDate (since 0.18)
civ.scen.onGetFormattedDate(function (turn, defaultDateString) -> string) -> void

Registers a function that is called when the game needs to get the date string for a given turn (e.g. "4000 B.C." for turn 1). `turn` is the turn for which the date is requested (not always the current turn), and `defaultDateString` is the string as formatted by the game


onGetRushBuyCost (since 0.17)
civ.scen.onGetRushBuyCost(function (city, cost) -> integer) -> void

Registers a function that is called when calculating the cost to rush-buy a city's current production. It takes the city and the cost as calculated by the game as parameters. Returns an integer representing the new costs.


onKeyPress
civ.scen.onKeyPress(function (keyCode) -> void) -> void

Registers a function to be called every time a key is pressed.


onLoad
civ.scen.onLoad(function (string) -> void) -> void

Registers a function that is called when the game is loaded.


onNegotiation
civ.scen.onNegotiation(function (talker, listener) -> boolean) -> void

Registers a function that is called when two tribes attempt negotiations. `talker` is the tribe initiating the contact, `listener` the receiver. Return `true` to allow the negotiations to commence, `false` to deny.


onResolveCombat (deprecated since 0.16)
civ.scen.onResolveCombat(function (defaultResolutionFunction, defender, attacker) -> boolean) -> void

Registers a function to be called during every combat turn. The first parameter of the callback is the default resolution function, as implemented by the game. It takes the attacker and defender as parameters. You can call this to produce a result for cases you don't need to handle yourself.  Return `true` to continue combat, `false` to stop.  See onInitiateCombat for replacement.


onSave
civ.scen.onSave(function () -> string) -> void

Registers a function that is called when the game is saved.


onScenarioLoaded
civ.scen.onScenarioLoaded(function () -> void) -> void

Registers a function that is called when the scenario is loaded.


onSchism
civ.scen.onSchism(function (tribe) -> boolean) -> void

Registers a function that is called when a schism is triggered. This happens when the capital of a AI-controlled tribe with more than four cities is captured, and, if the attacker is human-controlled, it is ranked lower in power than the defender. If the attacker is AI-controlled the best human tribe must be ranked lower than the defender for the schism to trigger.
If the schism is allowed, a new tribe will be created that takes over about half the cities of the old tribe. If no new tribe can be created, the schism does not occur.  Return `true` to allow the schism to happen, `false` to deny.


onSelectMusic (since 0.18)
civ.scen.onSelectMusic(function (track) -> optional integer) -> void

Registers a function that is called when a new music track is to be played. `track` is either nil or an integer. If nil, the game wants to play a random track, if not nil it's either due to the user choosing a track from the menu (first track has id 0), or the game playing one of it's special tracks ("Funeral March" - track id 0, and "Ode to Joy" - track id 1). To handle special tracks, you can return nil to signal that the game should play the default track associated with that track id. If you want to handle this track id, call civ.playMusic (this will check the Music folder of the scenario first before falling back to the global Music folder) and return an integer, which is used to synchronize the track list in the menu. The track names can be added in @PICKMUSICTOT in Game.txt.


onTribeTurnBegin (since 0.18)
civ.scen.onTribeTurnBegin(function (turn, tribe) -> void) -> void

Registers a function that is called at the start of a tribe's turn. See `onTurn` for interaction with other "turn" triggers.


onTribeTurnEnd (since 0.18)
civ.scen.onTribeTurnEnd(function (turn, tribe) -> void) -> void

Registers a function that is called at the end of a tribe's turn. See `onTurn` for interaction with other "turn" triggers.


onUnitKilled
civ.scen.onUnitKilled(function (loser, winner) -> void) -> void

Registers a function that is called whenever a unit is killed. `loser` is the unit that is killed, `winner` is the unit responsible for it.


onUseNuclearWeapon (since 0.18)
civ.scen.onUseNuclearWeapon(function (unit, tile) -> boolean) -> void

Registers a function that is called when a nuclear weapon is used. This is also called when a spy plants a nuclear device in a city. `unit` is the weapon or the spy unit, `tile` is the location of the attack. Return `false` to abort the attack, `true` to proceed.


decisiveDefeat (get/set)
civ.scen.params.decisiveDefeat -> integer

Number of objectives required for a decisive defeat.


decisiveVictory (get/set)
civ.scen.params.decisiveVictory -> integer

Number of objectives required for a decisive victory.


marginalDefeat (get/set)
civ.scen.params.marginalDefeat -> integer

Number of objectives required for a marginal defeat.


marginalVictory (get/set)
civ.scen.params.marginalVictory -> integer

Number of objectives required for a marginal victory.


maxTurns (get/set)
civ.scen.params.maxTurns -> integer

Maximum number of turns before the scenario ends.


name (get/set)
civ.scen.params.name -> string

The name of the scenario.


objectivesProtagonist (get/set)
civ.scen.params.objectivesProtagonist -> tribe

Returns the objectives protagonist.


startingYear (get)
civ.scen.params.startingYear -> integer

Returns the starting year of the scenario.


techParadigm (get/set)
civ.scen.params.techParadigm -> integer

Returns the tech paradigm used by the scenario. Non-scenario games use civ.cosmic.techParadigm instead of this value.


yearIncrement (get/set)
civ.scen.params.yearIncrement -> integer

Returns the year increment (number of years per turn). Negative for monthly increments.


activateUnitEveryMove (get/set - ephemeral)
civ.scen.compatibility.activateUnitEveryMove -> boolean

If set to true, onActivateUnit will re-trigger for every tile the active unit moves. Defaults to false, in which case onActivateUnit triggers only once.


roadTrade (get/set - ephemeral) (since 0.16)
totpp.roadTrade[map] -> integer

Returns a bitmask with the terrain types that receive an initial trade arrow when a road is built. Provided by the Initial trade arrow for roads patch.


attitude (get/set)
tribe.attitude[otherTribe] -> integer

Returns the tribe's attitude to `otherTribe`.


reputation (get/set)
tribe.reputation[otherTribe] -> integer

Returns the tribe's reputation with `otherTribe`.


treaties (get/set)
tribe.treaties[otherTribe] -> integer

Returns the tribe's treaties with `otherTribe`.


visibleImprovements (get/set) (since 0.16)
tile.visibleImprovements[tribe] -> integer

Returns the tile's improvements as known by the given tribe (bitmask).


sizeForTribe (get/set) (since 0.16)
city.sizeForTribe[tribe] -> integer

Returns the city's size as known by the given tribe.


tradeRoutes (get) (since 0.17)
city.tradeRoutes[id] -> traderoute

Returns the trade route with id `id` (0-2), or `nil` if not in use.

--]]
documentation["totpp"]["childs"]["movementMultipliers"]["childs"]["aggregate"] = { type = [[value]], description = "(get)\ntotpp.movementMultipliers.aggregate -> integer\n\nReturns the aggregate movement multiplier (the lcm of the four multipliers above). This value is recalculated when setting any of the individual multipliers. This is an alias for `civ.cosmic.roadMultiplier`.", valuetype = "integer",}

documentation["totpp"]["childs"]["movementMultipliers"]["childs"]["alpine"] = { type = [[value]], description = "(get/set - ephemeral)\ntotpp.movementMultipliers.alpine -> integer\n\nReturns the alpine movement multiplier if it is set, `nil` otherwise.", valuetype = "integer",}

documentation["totpp"]["childs"]["movementMultipliers"]["childs"]["railroad"] = { type = [[value]], description = "(get/set - ephemeral)\ntotpp.movementMultipliers.railroad -> integer\n\nReturns the railroad movement multiplier if it is set, `nil` otherwise.", valuetype = "integer",}

documentation["totpp"]["childs"]["movementMultipliers"]["childs"]["river"] = { type = [[value]], description = "(get/set - ephemeral)\ntotpp.movementMultipliers.river -> integer\n\nReturns the river movement multiplier if it is set, `nil` otherwise.", valuetype = "integer",}

documentation["totpp"]["childs"]["movementMultipliers"]["childs"]["road"] = { type = [[value]], description = "(get/set - ephemeral)\ntotpp.movementMultipliers.road -> integer\n\nReturns the road movement multiplier if it is set, `nil` otherwise.", valuetype = "integer",}

documentation["totpp"]["childs"]["mod"]["childs"]["premadeMap"] = { type = [[value]], description = "(get)\ntotpp.mod.premadeMap -> boolean\n\nReturns `true` if the game was started on a pre-made map, `false` otherwise. Only valid right after starting a new game.", valuetype = "boolean",}

documentation["tribeObject"]["childs"]["active"] = { type = [[value]], description = "(get)\ntribe.active -> boolean\n\nReturns whether the tribe is active, i.e. a human or AI player in the current game.", valuetype = "boolean",}

documentation["tribeObject"]["childs"]["adjective"] = { type = [[value]], description = "(get/set)\ntribe.adjective -> string\n\nReturns the adjectival form of the tribe's name (e.g. \"Roman\").", valuetype = "string",}

documentation["tribeObject"]["childs"]["betrayals"] = { type = [[value]], description = "(get/set)\ntribe.betrayals -> integer\n\nReturns the number of times the tribe has betrayed another tribe.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["futureTechs"] = { type = [[value]], description = "(get/set)\ntribe.futureTechs -> integer\n\nReturns the number of future techs the tribe has researched.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["government"] = { type = [[value]], description = "(get/set)\ntribe.government -> integer\n\nReturns the government (0 - 6) of the tribe.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["id"] = { type = [[value]], description = "(get)\ntribe.id -> integer\n\nReturns the id of the tribe.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["isHuman"] = { type = [[value]], description = "(get/set)\ntribe.isHuman -> boolean\n\nReturns whether the tribe is a/the human player.", valuetype = "boolean",}

documentation["tribeObject"]["childs"]["leader"] = { type = [[value]], description = "(get)\ntribe.leader -> leader\n\nReturns the leader of the tribe.", valuetype = "leaderObject",}

documentation["tribeObject"]["childs"]["money"] = { type = [[value]], description = "(get/set)\ntribe.money -> integer\n\nReturns the amount of money/gold in the tribe's treasury.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["name"] = { type = [[value]], description = "(get/set)\ntribe.name -> string\n\nReturns the name of the tribe (e.g. \"Romans\").", valuetype = "string",}

documentation["tribeObject"]["childs"]["numCities"] = { type = [[value]], description = "(get)\ntribe.numCities -> integer\n\nReturns the number of cities the tribe has.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["numTechs"] = { type = [[value]], description = "(get/set)\ntribe.numTechs -> integer\n\nReturns the number of techs the tribe has.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["numUnits"] = { type = [[value]], description = "(get)\ntribe.numUnits -> integer\n\nReturns the number of units the tribe has.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["patience"] = { type = [[value]], description = "(get/set)\ntribe.patience -> integer\n\nReturns the tribe's patience.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["researchCost"] = { type = [[value]], description = "(get)\ntribe.researchCost -> integer\n\nReturns the research cost of the tribe.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["researchProgress"] = { type = [[value]], description = "(get/set)\ntribe.researchProgress -> integer\n\nReturns the progress towards the current research (range between 0 and tribe.researchCost).", valuetype = "integer",}

documentation["tribeObject"]["childs"]["researching"] = { type = [[value]], description = "(get/set)\ntribe.researching -> tech\n\nReturns the tech the tribe is currently researching, or `nil` if not researching anything.", valuetype = "techObject",}

documentation["tribeObject"]["childs"]["scienceRate"] = { type = [[value]], description = "(get)\ntribe.scienceRate -> integer\n\nReturns the science rate of the tribe.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["spaceship"] = { type = [[value]], description = "(get)\ntribe.spaceship -> spaceship\n\nReturns the space ship object of the tribe.", valuetype = "spaceshipObject",}

documentation["tribeObject"]["childs"]["taxRate"] = { type = [[value]], description = "(get)\ntribe.taxRate -> integer\n\nReturns the tax rate of the tribe.", valuetype = "integer",}

documentation["tribeObject"]["childs"]["enableTechGroup"] = { type = "method", description = "tribe:enableTechGroup(techgroup, value) -> void\n\nAlias for `civ.enableTechGroup(tribe, techgroup, value)`.", args = "(techgroup,value)", returns = "(void)", valuetype = "void",}

documentation["tribeObject"]["childs"]["giveTech"] = { type = "method", description = "tribe:giveTech(tech) -> void\n\nAlias for `civ.giveTech(tribe, tech)`.", args = "(techObject)", returns = "(void)", valuetype = "void",}

documentation["tribeObject"]["childs"]["hasTech"] = { type = "method", description = "tribe:hasTech(tech) -> boolean\n\nAlias for `civ.hasTech(tribe, tech)`.", args = "(techObject)", returns = "(boolean)", valuetype = "boolean",}

documentation["tribeObject"]["childs"]["kill"] = { type = "method", description = "tribe:kill() -> void\n\nAlias for `civ.killTribe(tribe)`.", args = "()", returns = "(void)", valuetype = "void",}

documentation["tribeObject"]["childs"]["takeTech"] = { type = "method", description = "tribe:takeTech(tech, collapse=false) -> void\n\nAlias for `civ.takeTech(tribe, tech, collapse=false)`.", args = "(techObject,collapse=false)", returns = "(void)", valuetype = "void",}

documentation["cantSell"] = { type = "function", description = "cantSell (get/set - ephemeral)\n\nimprovement.cantSell -> boolean", args = "(get/set-ephemeral)", returns = "(cantSell(get/set-ephemeral))", valuetype = "cantSell(get/set-ephemeral)",}

documentation["improvementObject"]["childs"]["cost"] = { type = [[value]], description = "(get/set - ephemeral)\nimprovement.cost -> integer\n\nReturns the cost of the improvement in rows. Multiply by civ.cosmic.shieldRows for the actual production cost.", valuetype = "integer",}

documentation["improvementObject"]["childs"]["id"] = { type = [[value]], description = "(get)\nimprovement.id -> integer\n\nReturns the id of the improvement.", valuetype = "integer",}

documentation["improvementObject"]["childs"]["name"] = { type = [[value]], description = "(get)\nimprovement.name -> string\n\nReturns the name of the improvement (e.g. \"Barracks\").", valuetype = "string",}

documentation["improvementObject"]["childs"]["onCapture"] = { type = [[value]], description = "(get/set - ephemeral)\nimprovement.onCapture -> integer\n\nReturns what happens to this improvement when a city is captured (0 - Default, 1 - Preserve, 2 - Destroy, 3 - Random). Requires the \"Improvement flags\" patch.", valuetype = "integer",}

documentation["improvementObject"]["childs"]["prereq"] = { type = [[value]], description = "(get/set - ephemeral)\nimprovement.prereq -> tech\n\nReturns the prerequisite tech of the improvement.", valuetype = "techObject",}

documentation["improvementObject"]["childs"]["upkeep"] = { type = [[value]], description = "(get/set - ephemeral)\nimprovement.upkeep -> integer\n\nReturns the upkeep cost of the improvement.", valuetype = "integer",}

documentation["techObject"]["childs"]["aiValue"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.aiValue -> integer\n\nReturns the AI value of the tech.", valuetype = "integer",}

documentation["techObject"]["childs"]["category"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.category -> integer\n\nReturns the category of the tech.", valuetype = "integer",}

documentation["techObject"]["childs"]["epoch"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.epoch -> integer\n\nReturns the epoch of the tech.", valuetype = "integer",}

documentation["techObject"]["childs"]["group"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.group -> integer\n\nReturns the group of the tech.", valuetype = "integer",}

documentation["techObject"]["childs"]["id"] = { type = [[value]], description = "(get)\ntech.id -> integer\n\nReturns the id of the tech.", valuetype = "integer",}

documentation["techObject"]["childs"]["modifier"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.modifier -> integer\n\nReturns the modifier to the AI value based on leader personality.", valuetype = "integer",}

documentation["techObject"]["childs"]["name"] = { type = [[value]], description = "(get)\ntech.name -> string\n\nReturns the name of the tech.", valuetype = "string",}

documentation["techObject"]["childs"]["prereq1"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.prereq1 -> tech\n\nReturns the first prerequisite of the tech.", valuetype = "techObject",}

documentation["techObject"]["childs"]["prereq2"] = { type = [[value]], description = "(get/set - ephemeral)\ntech.prereq2 -> tech\n\nReturns the second prerequisite of the tech.", valuetype = "techObject",}

documentation["techObject"]["childs"]["researched"] = { type = [[value]], description = "(get)\ntech.researched -> boolean\n\nReturns whether or not any tribe has researched the tech.", valuetype = "boolean",}

documentation["leaderObject"]["childs"]["attack"] = { type = [[value]], description = "(get/set - ephemeral)\nleader.attack -> integer\n\nReturns the \"attack\" value of the leader's personality.", valuetype = "integer",}

documentation["leaderObject"]["childs"]["cityStyle"] = { type = [[value]], description = "(get/set - ephemeral)\nleader.cityStyle -> integer\n\nReturns the leader's city style.", valuetype = "integer",}

documentation["leaderObject"]["childs"]["civilize"] = { type = [[value]], description = "(get/set - ephemeral)\nleader.civilize -> integer\n\nReturns the \"civilize\" value of the leader's personality.", valuetype = "integer",}

documentation["leaderObject"]["childs"]["color"] = { type = [[value]], description = "(get/set - ephemeral)\nleader.color -> integer\n\nReturns the leader's color.", valuetype = "integer",}

documentation["leaderObject"]["childs"]["expand"] = { type = [[value]], description = "(get/set - ephemeral)\nleader.expand -> integer\n\nReturns the \"expand\" value of the leader's personality.", valuetype = "integer",}

documentation["leaderObject"]["childs"]["female"] = { type = [[value]], description = "(get/set)\nleader.female -> boolean\n\nReturns whether or not the leader is female.", valuetype = "boolean",}

documentation["leaderObject"]["childs"]["id"] = { type = [[value]], description = "(get)\nleader.id -> integer\n\nReturns the id of the leader.", valuetype = "integer",}

documentation["leaderObject"]["childs"]["name"] = { type = [[value]], description = "(get/set)\nleader.name -> string\n\nReturns the name of the leader.", valuetype = "string",}

documentation["wonderObject"]["childs"]["city"] = { type = [[value]], description = "(get/set)\nwonder.city -> city\n\nReturns the city that has built the wonder, `nil` if not built yet or destroyed.", valuetype = "cityObject",}

documentation["wonderObject"]["childs"]["cost"] = { type = [[value]], description = "(get/set - ephemeral)\nwonder.cost -> integer\n\nReturns the cost of the wonder.", valuetype = "integer",}

documentation["wonderObject"]["childs"]["destroyed"] = { type = [[value]], description = "(get)\nwonder.destroyed -> boolean\n\nReturns whether or not the wonder is destroyed. Use wonder:destroy() to set this field.", valuetype = "boolean",}

documentation["wonderObject"]["childs"]["expires"] = { type = [[value]], description = "(get/set - ephemeral)\nwonder.expires -> tech\n\nReturns the tech that renders the wonder obsolete, or `nil` if there isn't any.", valuetype = "techObject",}

documentation["wonderObject"]["childs"]["id"] = { type = [[value]], description = "(get)\nwonder.id -> integer\n\nReturns the id of the wonder.", valuetype = "integer",}

documentation["wonderObject"]["childs"]["name"] = { type = [[value]], description = "(get)\nwonder.name -> string\n\nReturns the name of the wonder.", valuetype = "string",}

documentation["wonderObject"]["childs"]["prereq"] = { type = [[value]], description = "(get/set - ephemeral)\nwonder.prereq -> tech\n\nReturns the prerequisite technology of the wonder.", valuetype = "techObject",}

documentation["wonderObject"]["childs"]["destroy"] = { type = "method", description = "wonder:destroy() -> void\n\nAlias for `civ.destroyWonder(wonder)`.", args = "()", returns = "(void)", valuetype = "void",}

documentation["unitObject"]["childs"]["attackSpent"] = { type = [[value]], description = "(get/set)\nunit.attackSpent -> integer\n\nReturns the number of attacks spent by the unit (from the 'Attacks per turn' patch).", valuetype = "integer",}

documentation["unitObject"]["childs"]["attributes"] = { type = [[value]], description = "(get/set)\nunit.attributes -> integer\n\nReturns the attributes of the unit (bitmask).", valuetype = "bitmask",}

documentation["unitObject"]["childs"]["carriedBy"] = { type = [[value]], description = "(get/set)\nunit.carriedBy -> unit\n\nReturns the carrying unit if this unit is currently on board, `nil` otherwise. The game shares the memory location of this field with gotoTile.x, so don't use this field if gotoTile is not `nil`.", valuetype = "unitObject",}

documentation["unitObject"]["childs"]["damage"] = { type = [[value]], description = "(get/set)\nunit.damage -> integer\n\nReturns the damage taken by the unit in hitpoints.", valuetype = "integer",}

documentation["unitObject"]["childs"]["domainSpec"] = { type = [[value]], description = "(get/set)\nunit.domainSpec -> integer\n\nReturns the value of the 'domain-specific counter' of the unit.", valuetype = "integer",}

documentation["unitObject"]["childs"]["gotoTile"] = { type = [[value]], description = "(get/set)\nunit.gotoTile -> tile\n\nReturns the tile the unit is moving to under the goto order, or `nil` if it doesn't have the goto order.", valuetype = "tileObject",}

documentation["unitObject"]["childs"]["hitpoints"] = { type = [[value]], description = "(get)\nunit.hitpoints -> integer\n\nReturns the number of hitpoints left. It is defined as unit.type.hitpoints - unit.damage.", valuetype = "integer",}

documentation["unitObject"]["childs"]["homeCity"] = { type = [[value]], description = "(get/set)\nunit.homeCity -> city\n\nReturns the unit's home city, or `nil` if it doesn't have one.", valuetype = "cityObject",}

documentation["unitObject"]["childs"]["id"] = { type = [[value]], description = "(get)\nunit.id -> integer\n\nReturns the unit's id.", valuetype = "integer",}

documentation["unitObject"]["childs"]["location"] = { type = [[value]], description = "(get)\nunit.location -> tile\n\nReturns the unit's location.", valuetype = "tileObject",}
-- come back here

documentation["unitObject"]["childs"]["moveSpent"] = { type = [[value]], description = "(get/set)\nunit.moveSpent -> integer\n\nReturns the number of moves spent by the unit.", valuetype = "integer",}

documentation["unitObject"]["childs"]["order"] = { type = [[value]], description = "(get/set)\nunit.order -> integer\n\nReturns the current order of the unit.", valuetype = "integer",}

documentation["unitObject"]["childs"]["owner"] = { type = [[value]], description = "(get/set)\nunit.owner -> tribe\n\nReturns the unit's owner.", valuetype = "tribeObject",}

documentation["unitObject"]["childs"]["type"] = { type = [[value]], description = "(get)\nunit.type -> unitType\n\nReturns the unit's type.", valuetype = "unitTypeObject",}

documentation["unitObject"]["childs"]["veteran"] = { type = [[value]], description = "(get/set)\nunit.veteran -> boolean\n\nReturns the veteran status of the unit.", valuetype = "boolean",}

documentation["unitObject"]["childs"]["visibility"] = { type = [[value]], description = "(get/set)\nunit.visibility -> integer\n\nReturns the unit visibility mask.", valuetype = "integer",}

documentation["unitObject"]["childs"]["activate"] = { type = "method", description = "unit:activate() -> void\n\nActivates a unit, clearing its orders, and, if it has a human owner and movement points left, selects it on the map.", args = "()", returns = "(void)", valuetype = "void",}

documentation["unitObject"]["childs"]["teleport"] = { type = "method", description = "unit:teleport(tile) -> void\n\nAlias for `civ.teleportUnit(unit, tile)`.", args = "(tileObject)", returns = "(void)", valuetype = "void",}

documentation["unitTypeObject"]["childs"]["advancedFlags"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.advancedFlags -> integer\n\nReturns the 'advanced flags' settings of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["attack"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.attack -> integer\n\nReturns the attack factor of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["attacksPerTurn"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.attacksPerTurn -> integer\n\nReturns the number of attacks available per turn of the unit type (from the 'Attacks per turn' patch).", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["buildTransport"] = { type = [[value]], description = "(get/set)\nunitType.buildTransport -> integer\n\nReturns the 'build transport site' settings of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["cost"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.cost -> integer\n\nReturns the cost of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["defense"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.defense -> integer\n\nReturns the defense factor of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["domain"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.domain -> integer\n\nReturns the domain of the unit type (0 - Ground, 1 - Air, 2 - Sea).", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["expires"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.expires -> tech\n\nReturns the tech that renders the unit obsolete, or `nil` if there isn't any.", valuetype = "techObject",}

documentation["unitTypeObject"]["childs"]["firepower"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.firepower -> integer\n\nReturns the firepower of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["flags"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.flags -> integer\n\nReturns the flags of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["hitpoints"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.hitpoints -> integer\n\nReturns the number of hit points of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["hold"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.hold -> integer\n\nReturns the number of holds of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["id"] = { type = [[value]], description = "(get)\nunitType.id -> integer\n\nReturns the id of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["minimumBribe"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.minimumBribe -> integer\n\nReturns the minimum amount to bribe the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["move"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.move -> integer\n\nReturns the movement rate of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["name"] = { type = [[value]], description = "(get)\nunitType.name -> string\n\nReturns the name of the unit type.", valuetype = "string",}

documentation["unitTypeObject"]["childs"]["nativeTransport"] = { type = [[value]], description = "(get/set)\nunitType.nativeTransport -> integer\n\nReturns the 'native transport' settings of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["notAllowedOnMap"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.notAllowedOnMap -> integer\n\nReturns the 'not allowed on map' settings of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["prereq"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.prereq -> tech\n\nReturns the prerequisite technology of the unit type, or `nil` if it doesn't have one.", valuetype = "techObject",}

documentation["unitTypeObject"]["childs"]["range"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.range -> integer\n\nReturns the range of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["role"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.role -> integer\n\nReturns the role of the unit type.", valuetype = "integer",}

documentation["unitTypeObject"]["childs"]["tribeMayBuild"] = { type = [[value]], description = "(get/set - ephemeral)\nunitType.tribeMayBuild -> integer\n\nReturns the 'tribe may build' settings of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["useTransport"] = { type = [[value]], description = "(get/set)\nunitType.useTransport -> integer\n\nReturns the 'use transport site' settings of the unit type (bitmask).", valuetype = "bitmask",}

documentation["unitTypeObject"]["childs"]["canEnter"] = { type = "method", description = "unitType:canEnter(tile) -> boolean\n\nAlias for `civ.canEnter(unitType, tile)`", args = "(tileObject)", returns = "(boolean)", valuetype = "boolean",}

documentation["tileObject"]["childs"]["baseTerrain"] = { type = [[value]], description = "(get/set)\ntile.baseTerrain -> baseTerrain\n\nReturns the baseTerrain object associated with the tile.", valuetype = "baseTerrainObject",}

documentation["tileObject"]["childs"]["city"] = { type = [[value]], description = "(get)\ntile.city -> city\n\nReturns the city at the tile's location, or `nil` if there's no city there.", valuetype = "cityObject",}

documentation["tileObject"]["childs"]["defender"] = { type = [[value]], description = "(get)\ntile.defender -> tribe\n\nReturns the tile's defender.", valuetype = "tribeObject",}

documentation["tileObject"]["childs"]["fertility"] = { type = [[value]], description = "(get/set)\ntile.fertility -> integer\n\nReturns the tile's fertility.", valuetype = "integer",}

documentation["tileObject"]["childs"]["grasslandShield"] = { type = [[value]], description = "(get)\ntile.grasslandShield -> boolean\n\nReturns `true` if the tile would have a shield when changed to grassland, `false` otherwise.", valuetype = "boolean",}

documentation["tileObject"]["childs"]["hasGoodieHut"] = { type = [[value]], description = "(get)\ntile.hasGoodieHut -> boolean\n\nReturns `true` if the tile has a goodie hut, `false` otherwise.", valuetype = "boolean",}

documentation["tileObject"]["childs"]["improvements"] = { type = [[value]], description = "(get/set)\ntile.improvements -> integer\n\nReturns the tile's improvements (bitmask).", valuetype = "bitmask",}

documentation["tileObject"]["childs"]["landmass"] = { type = [[value]], description = "(get/set)\ntile.landmass -> integer\n\nReturns the tile's landmass index.", valuetype = "integer",}

documentation["tileObject"]["childs"]["owner"] = { type = [[value]], description = "(get/set)\ntile.owner -> tribe\n\nReturns the tribe owning the tile.", valuetype = "tribeObject",}

documentation["tileObject"]["childs"]["river"] = { type = [[value]], description = "(get/set)\ntile.river -> boolean\n\nReturns `true` if the tile has a river, `false` otherwise.", valuetype = "boolean",}

documentation["tileObject"]["childs"]["terrain"] = { type = [[value]], description = "(get/set)\ntile.terrain -> terrain\n\nReturns the terrain object associated with the tile.", valuetype = "terrainObject",}

documentation["tileObject"]["childs"]["terrainType"] = { type = [[value]], description = "(get/set)\ntile.terrainType -> integer\n\nReturns the terrain type of the tile.", valuetype = "integer",}

documentation["tileObject"]["childs"]["units"] = { type = [[value]], description = "(get)\ntile.units -> iterator\n\nReturns an iterator yielding all units at the tile's location.", valuetype = "iterator",}

documentation["tileObject"]["childs"]["visibility"] = { type = [[value]], description = "(get/set)\ntile.visibility -> integer\n\nReturns the tile's visibility for each tribe (bitmask).", valuetype = "bitmask",}

documentation["tileObject"]["childs"]["x"] = { type = [[value]], description = "(get)\ntile.x -> integer\n\nReturns the `x` coordinate of the tile.", valuetype = "integer",}

documentation["tileObject"]["childs"]["y"] = { type = [[value]], description = "(get)\ntile.y -> integer\n\nReturns the `y` coordinate of the tile.", valuetype = "integer",}

documentation["tileObject"]["childs"]["z"] = { type = [[value]], description = "(get)\ntile.z -> integer\n\nReturns the `z` coordinate of the tile (map number).", valuetype = "integer",}

documentation["mapObject"]["childs"]["customResources"] = { type = [[value]], description = "(get/set)\nmap.customResources -> boolean\n\nReturns `true` if custom resources are enabled for this map, `false` otherwise.", valuetype = "boolean",}

documentation["mapObject"]["childs"]["height"] = { type = [[value]], description = "(get)\nmap.height -> integer\n\nReturns the height of the map.", valuetype = "integer",}

documentation["mapObject"]["childs"]["id"] = { type = [[value]], description = "(get)\nmap.id -> integer\n\nReturns the id of the map.", valuetype = "integer",}

documentation["mapObject"]["childs"]["width"] = { type = [[value]], description = "(get)\nmap.width -> integer\n\nReturns the width of the map.", valuetype = "integer",}

documentation["mapObject"]["childs"]["copyDefaultResources"] = { type = "method", description = "map:copyDefaultResources() -> void\n\nEnables custom resources for this map and copies the default resource pattern. Requires the \"Custom resources\" patch.", args = "()", returns = "(void)", valuetype = "void",}

documentation["mapObject"]["childs"]["getBaseTerrain"] = { type = "method", description = "map:getBaseTerrain(terrainType) -> baseTerrain\n\nAlias for `civ.getBaseTerrain(map, terrainType)`", args = "(terrainType)", returns = "(baseTerrainObject)", valuetype = "baseTerrainObject",}

documentation["mapObject"]["childs"]["getTerrain"] = { type = "method", description = "map:getTerrain(terrainType, resource) -> terrain\n\nAlias for `civ.getTerrain(map, terrainType, resource)`", args = "(terrainType,resource)", returns = "(terrainObject)", valuetype = "terrainObject",}

documentation["baseTerrainObject"]["childs"]["abbrev"] = { type = [[value]], description = "(get)\nbaseTerrain.abbrev -> string\n\nThe terrain abbreviation for this baseTerrain (e.g. 'Drt', 'Pln' etc.).", valuetype = "string",}

documentation["baseTerrainObject"]["childs"]["canIrrigate"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.canIrrigate -> boolean\n\nReturns `true` if the underlying terrain type allows irrigation, `false` otherwise.", valuetype = "boolean",}

documentation["baseTerrainObject"]["childs"]["canMine"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.canMine -> boolean\n\nReturns `true` if the underlying terrain type allows mining, `false` otherwise.", valuetype = "boolean",}

documentation["baseTerrainObject"]["childs"]["defense"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.defense -> integer\n\nThe defense factor of the underlying terrain type.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["impassable"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.impassable -> boolean\n\nReturns `true` if the underlying terrain type is impassable, `false` otherwise.", valuetype = "boolean",}

documentation["baseTerrainObject"]["childs"]["irrigateAI"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.irrigateAI -> integer\n\nThe minimum government level needed for the AI to consider irrigating.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["irrigateBonus"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.irrigateBonus -> integer\n\nThe extra amount of food from irrigation.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["irrigateTo"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.irrigateTo -> baseTerrain\n\nIf the irrigation order changes the underlying terrain type return the baseTerrain of the new terrain type, `nil` otherwise.", valuetype = "baseTerrainObject",}

documentation["baseTerrainObject"]["childs"]["irrigateTurns"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.irrigateTurns -> integer\n\nThe number of turns for settlers to irrigate.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["map"] = { type = [[value]], description = "(get)\nbaseTerrain.map -> integer\n\nThe map associated with the baseTerrain object.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["mineAI"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.mineAI -> integer\n\nThe minimum government level needed for the AI to consider mining.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["mineBonus"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.mineBonus -> integer\n\nThe extra amount of production from mining.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["mineTo"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.mineTo -> baseTerrain\n\nIf the mine order changes the underlying terrain type return the baseTerrain of the new terrain type, `nil` otherwise.", valuetype = "baseTerrainObject",}

documentation["baseTerrainObject"]["childs"]["mineTurns"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.mineTurns -> integer\n\nThe number of turns for settlers to mine.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["moveCost"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.moveCost -> integer\n\nThe movement cost of the underlying terrain type.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["name"] = { type = [[value]], description = "(get)\nbaseTerrain.name -> string\n\nThe name of this baseTerrain.", valuetype = "string",}

documentation["baseTerrainObject"]["childs"]["transformTo"] = { type = [[value]], description = "(get/set - ephemeral)\nbaseTerrain.transformTo -> baseTerrain\n\nIf the underlying terrain type can be transformed return the baseTerrain of the new terrain type, `nil` otherwise.", valuetype = "baseTerrainObject",}

documentation["baseTerrainObject"]["childs"]["type"] = { type = [[value]], description = "(get)\nbaseTerrain.type -> integer\n\nThe terrain type associated with the baseTerrain object.", valuetype = "integer",}

documentation["baseTerrainObject"]["childs"]["getTerrain"] = { type = "method", description = "baseTerrain:getTerrain(resource) -> terrain\n\nReturns the terrain object corresponding to the underlying terrain type and the given resource.", args = "(resource)", returns = "(terrainObject)", valuetype = "terrainObject",}

documentation["terrainObject"]["childs"]["baseTerrain"] = { type = [[value]], description = "(get)\nterrain.baseTerrain -> baseTerrain\n\nThe underlying baseTerrain of the terrain object.", valuetype = "baseTerrainObject",}

documentation["terrainObject"]["childs"]["food"] = { type = [[value]], description = "(get/set - ephemeral)\nterrain.food -> integer\n\nThe amount of food produced by the terrain.", valuetype = "integer",}

documentation["terrainObject"]["childs"]["map"] = { type = [[value]], description = "(get)\nterrain.map -> integer\n\nThe map associated with the terrain object.", valuetype = "integer",}

documentation["terrainObject"]["childs"]["name"] = { type = [[value]], description = "(get)\nterrain.name -> string\n\nThe name of the terrain.", valuetype = "string",}

documentation["terrainObject"]["childs"]["resource"] = { type = [[value]], description = "(get)\nterrain.resource -> integer\n\nThe resource associated with the terrain object.", valuetype = "integer",}

documentation["terrainObject"]["childs"]["shields"] = { type = [[value]], description = "(get/set - ephemeral)\nterrain.shields -> integer\n\nThe amount of shields produced by the terrain.", valuetype = "integer",}

documentation["terrainObject"]["childs"]["trade"] = { type = [[value]], description = "(get/set - ephemeral)\nterrain.trade -> integer\n\nThe amount of trade produced by the terrain.", valuetype = "integer",}

documentation["terrainObject"]["childs"]["type"] = { type = [[value]], description = "(get)\nterrain.type -> integer\n\nThe terrain type associated with the terrain object.", valuetype = "integer",}

documentation["cityObject"]["childs"]["attributes"] = { type = [[value]], description = "(get/set)\ncity.attributes -> integer\n\nReturns the city's attributes (bitmask).", valuetype = "bitmask",}

documentation["cityObject"]["childs"]["baseTrade"] = { type = [[value]], description = "(get)\ncity.baseTrade -> integer\n\nReturns the number of trade arrows before trade routes.", valuetype = "integer",}

documentation["cityObject"]["childs"]["coastal"] = { type = [[value]], description = "(get)\ncity.coastal -> boolean\n\nReturns whether or not the city is on a coast (can build coastal improvements).", valuetype = "boolean",}

documentation["cityObject"]["childs"]["currentProduction"] = { type = [[value]], description = "(get/set)\ncity.currentProduction -> prodItem\n\nReturns the city's current production.", valuetype = "prodItem",}

documentation["cityObject"]["childs"]["food"] = { type = [[value]], description = "(get/set)\ncity.food -> integer\n\nReturns the quantity of food in store.", valuetype = "integer",}

documentation["cityObject"]["childs"]["id"] = { type = [[value]], description = "(get)\ncity.id -> integer\n\nReturns the city's id.", valuetype = "integer",}

documentation["cityObject"]["childs"]["knownTo"] = { type = [[value]], description = "(get/set)\ncity.knownTo -> integer\n\nReturns a bitmask indicating the tribes that have knowledge of this city.", valuetype = "bitmask",}

documentation["cityObject"]["childs"]["location"] = { type = [[value]], description = "(get)\ncity.location -> tile\n\nReturns the city's location. See the `relocate` method for a way to set this.", valuetype = "tileObject",}

documentation["cityObject"]["childs"]["name"] = { type = [[value]], description = "(get/set)\ncity.name -> string\n\nReturns the city's name.", valuetype = "string",}

documentation["cityObject"]["childs"]["numHappy"] = { type = [[value]], description = "(get)\ncity.numHappy -> integer\n\nReturns the number of happy citizens.", valuetype = "integer",}

documentation["cityObject"]["childs"]["numTradeRoutes"] = { type = [[value]], description = "(get)\ncity.numTradeRoutes -> integer\n\nReturns the number of trade routes of the city.", valuetype = "integer",}

documentation["cityObject"]["childs"]["numUnhappy"] = { type = [[value]], description = "(get)\ncity.numUnhappy -> integer\n\nReturns the number of unhappy citizens.", valuetype = "integer",}

documentation["cityObject"]["childs"]["originalOwner"] = { type = [[value]], description = "(get/set)\ncity.originalOwner -> tribe\n\nReturns the city's original owner. This can be different from `owner` if the city was captured in the past.", valuetype = "tribeObject",}

documentation["cityObject"]["childs"]["owner"] = { type = [[value]], description = "(get/set)\ncity.owner -> tribe\n\nReturns the city's owner.", valuetype = "tribeObject",}

documentation["cityObject"]["childs"]["science"] = { type = [[value]], description = "(get)\ncity.science -> integer\n\nReturns the amount of science the city produces.", valuetype = "integer",}

documentation["cityObject"]["childs"]["shields"] = { type = [[value]], description = "(get/set)\ncity.shields -> integer\n\nReturns the number of shields towards the current item in production.", valuetype = "integer",}

documentation["cityObject"]["childs"]["size"] = { type = [[value]], description = "(get/set)\ncity.size -> integer\n\nReturns the city's size.", valuetype = "integer",}

documentation["cityObject"]["childs"]["specialists"] = { type = [[value]], description = "(get/set)\ncity.specialists -> integer\n\nReturns the city's specialists as a integer, 16 x 2 bits per specialist (0 - No specialist, 1 - Entertainer, 2 - Taxman, 3 - Scientist)", valuetype = "integer",}

documentation["cityObject"]["childs"]["tax"] = { type = [[value]], description = "(get)\ncity.tax -> integer\n\nReturns the amount of tax the city produces.", valuetype = "integer",}

documentation["cityObject"]["childs"]["totalFood"] = { type = [[value]], description = "(get)\ncity.totalFood -> integer\n\nReturns the total amount of food the city produces.", valuetype = "integer",}

documentation["cityObject"]["childs"]["totalShield"] = { type = [[value]], description = "(get)\ncity.totalShield -> integer\n\nReturns the total amount of shields the city produces.", valuetype = "integer",}

documentation["cityObject"]["childs"]["totalTrade"] = { type = [[value]], description = "(get)\ncity.totalTrade -> integer\n\nReturns the total amount of trade arrows the city produces (including trade routes).", valuetype = "integer",}

documentation["cityObject"]["childs"]["turnsSinceCapture"] = { type = [[value]], description = "(get/set)\ncity.turnsSinceCapture -> integer\n\nReturns the number of turns since the city was last captured.", valuetype = "integer",}

documentation["cityObject"]["childs"]["workers"] = { type = [[value]], description = "(get/set)\ncity.workers -> integer\n\nReturns a bitmask with the workers and specialists of the city.", valuetype = "bitmask",}

documentation["cityObject"]["childs"]["addImprovement"] = { type = "method", description = "city:addImprovement(improvement) -> void\n\nAlias for `civ.addImprovement(city, improvement)`.", args = "(improvementObject)", returns = "(void)", valuetype = "void",}

documentation["cityObject"]["childs"]["addTradeRoute"] = { type = "method", description = "(since 0.17)\ncity:addTradeRoute(destination, commodity) -> void\n\nAdds a new trade route to city `destination`, with commodity `commodity`. Returns an error if all 3 trade slots are already in use.", args = "(destination,commodityObject)", returns = "(void)", valuetype = "void",}

documentation["cityObject"]["childs"]["canBuild"] = { type = "method", description = "city:canBuild(item) -> boolean\n\nReturns whether or not `item` can currently be built in the city. `item` can be a unitType, improvement or wonder.", args = "(item)", returns = "(boolean)", valuetype = "boolean",}

documentation["cityObject"]["childs"]["hasImprovement"] = { type = "method", description = "city:hasImprovement(improvement) -> boolean\n\nAlias for `civ.hasImprovement(city, improvement)`.", args = "(improvementObject)", returns = "(boolean)", valuetype = "boolean",}

documentation["cityObject"]["childs"]["popTradeRoute"] = { type = "method", description = "(since 0.17)\ncity:popTradeRoute() -> void\n\nRemoves the last trade route, or does nothing if no trade routes are in use.", args = "()", returns = "(void)", valuetype = "void",}

documentation["cityObject"]["childs"]["relocate"] = { type = "method", description = "city:relocate(tile) -> boolean\n\nRelocates the city to the location given by `tile`. Returns `true` if successful, `false` otherwise (if a city is already present for example).", args = "(tileObject)", returns = "(boolean)", valuetype = "boolean",}

documentation["cityObject"]["childs"]["removeImprovement"] = { type = "method", description = "city:removeImprovement(improvement) -> void\n\nAlias for `civ.removeImprovement(city, improvement)`.", args = "(improvementObject)", returns = "(void)", valuetype = "void",}

documentation["cityObject"]["childs"]["removeTradeRoute"] = { type = "method", description = "(since 0.17)\ncity:removeTradeRoute(id) -> void\n\nRemoves the trade route with index `id` (0-2). This shifts elements after `id` to fill gaps in the array, so references to trade routes may not be valid anymore after calling this.", args = "(id: integer)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["addImprovement"] = { type = "function", description = "civ.addImprovement(city, improvement) -> void\n\nAdds city improvement `improvement` to city `city`.", args = "(cityObject,improvementObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["canEnter"] = { type = "function", description = "civ.canEnter(unitType, tile) -> boolean\n\nReturns `true` if the given unitType can enter tile `tile`, `false` otherwise.", args = "(unitTypeObject,tileObject)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["captureCity"] = { type = "function", description = "civ.captureCity(city, tribe) -> void\n\nCaptures city `city` for tribe `tribe`.", args = "(cityObject,tribeObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["createCity"] = { type = "function", description = "civ.createCity(tribe, tile) -> city\n\nCreates a city owned by `tribe` at the location given by `tile`. Returns `nil` if a city could not be created.", args = "(tribeObject,tileObject)", returns = "(cityObject|nil)", valuetype = "cityObject",}

documentation["civ"]["childs"]["createUnit"] = { type = "function", description = "civ.createUnit(unitType, tribe, tile) -> unit\n\nCreates a unit of type `unitType`, owned by `tribe`, at the location given by `tile`.", args = "(unitTypeObject,tribeObject,tileObject)", returns = "(unitObject)", valuetype = "unitObject",}

documentation["civ"]["childs"]["deleteCity"] = { type = "function", description = "civ.deleteCity(city) -> void\n\nDeletes city `city` from the game.", args = "(cityObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["deleteUnit"] = { type = "function", description = "civ.deleteUnit(unit) -> void\n\nDeletes unit `unit` from the game.", args = "(unitObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["destroyWonder"] = { type = "function", description = "civ.destroyWonder(wonder) -> void\n\nDestroys wonder `wonder`, removing it from the game, and marking it as 'lost'.", args = "(wonderObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["enableTechGroup"] = { type = "function", description = "civ.enableTechGroup(tribe, techgroup, value) -> void\n\nSets the value of tech group `techgroup` (0-7) to value `value` (0-2, 0 = can research, can own, 1 = can't research, can own, 2 = can't research, can't own) for tribe `tribe`.", args = "(tribeObject,techgroup,value)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["endGame"] = { type = "function", description = "civ.endGame(endscreens=false) -> void\n\nEnds the game. `endscreens` is a boolean that determines whether to show the powergraph and related screens.", args = "(endscreens=false)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["getActiveUnit"] = { type = "function", description = "civ.getActiveUnit() -> unit\n\nReturns the currently active unit.", args = "()", returns = "(unitObject)", valuetype = "unitObject",}

documentation["civ"]["childs"]["getAtlasDimensions"] = { type = "function", description = "(since 0.16)\nciv.getAtlasDimensions() -> width, height, number_of_maps\n\nReturns three integers, the width and height of the map and the number of maps.", args = "()", returns = "(width: integer,height: integer,number_of_maps)", valuetype = "width: integer",}

documentation["civ"]["childs"]["getBaseTerrain"] = { type = "function", description = "(since 0.16)\nciv.getBaseTerrain(map, terrainType) -> baseTerrain\n\nReturns the base terrain object for the given map and terrain type.", args = "(mapObject,terrainType)", returns = "(baseTerrainObject)", valuetype = "baseTerrainObject",}

documentation["civ"]["childs"]["getCity"] = { type = "function", description = "civ.getCity(id) -> city\n\nReturns the city with id `id`, or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(cityObject|nil)", valuetype = "cityObject",}

documentation["civ"]["childs"]["getCommodity"] = { type = "function", description = "(since 0.17)\nciv.getCommodity(id) -> commodity\n\nReturns the commodity with id `id` (0-15 for regular commodities, -1 for food supplies), or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(commodityObject|nil)", valuetype = "commodityObject",}

documentation["civ"]["childs"]["getCurrentTile"] = { type = "function", description = "civ.getCurrentTile() -> tile\n\nReturns the currently selected tile.", args = "()", returns = "(tileObject)", valuetype = "tileObject",}

documentation["civ"]["childs"]["getCurrentTribe"] = { type = "function", description = "civ.getCurrentTribe() -> tribe\n\nReturns the currently active tribe.", args = "()", returns = "(tribeObject)", valuetype = "tribeObject",}

documentation["civ"]["childs"]["getGameYear"] = { type = "function", description = "civ.getGameYear() -> integer\n\nReturns the current game year.", args = "()", returns = "(integer)", valuetype = "integer",}

documentation["civ"]["childs"]["getImprovement"] = { type = "function", description = "civ.getImprovement(id) -> improvement\n\nReturns the improvement with id `id` (0-39), or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(improvementObject|nil)", valuetype = "improvementObject",}

documentation["civ"]["childs"]["getMap"] = { type = "function", description = "(since 0.16)\nciv.getMap(id) -> map\n\nReturns the map with id `id` (0-3) or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(mapObject|nil)", valuetype = "mapObject",}

documentation["civ"]["childs"]["getMapDimensions"] = { type = "function", description = "(deprecated since 0.16)\nciv.getMapDimensions() -> width, height, number_of_maps\n\nAlias for getAtlasDimensions.", args = "()", returns = "(width: integer,height: integer,number_of_maps)", valuetype = "width: integer",}

documentation["civ"]["childs"]["getOpenCity"] = { type = "function", description = "(since 0.16)\nciv.getOpenCity() -> city\n\nReturns the city currently opened in the city window, `nil` if the city window is closed.", args = "()", returns = "(cityObject|nil)", valuetype = "cityObject",}

documentation["civ"]["childs"]["getPlayerTribe"] = { type = "function", description = "civ.getPlayerTribe() -> tribe\n\nReturns the player's tribe.", args = "()", returns = "(tribeObject)", valuetype = "tribeObject",}

documentation["civ"]["childs"]["getTech"] = { type = "function", description = "civ.getTech(id) -> tech\n\nReturns the tech with id `id` (0-99), or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(techObject|nil)", valuetype = "techObject",}

documentation["civ"]["childs"]["getTerrain"] = { type = "function", description = "(since 0.16)\nciv.getTerrain(map, terrainType, resource) -> terrain\n\nReturns the terrain object for the given map, terrain type and resource.", args = "(mapObject,terrainType,resource)", returns = "(terrainObject)", valuetype = "terrainObject",}

documentation["civ"]["childs"]["getTile"] = { type = "function", description = "civ.getTile(x, y, z) -> tile\n\nReturns the tile with coordinates `x`, `y`, `z`, or `nil` if it doesn't exist.", args = "(x: integer,y: integer,z)", returns = "(tileObject|nil)", valuetype = "tileObject",}

documentation["civ"]["childs"]["getToTDir"] = { type = "function", description = "civ.getToTDir() -> string\n\nReturns the absolute path of the ToT installation directory.", args = "()", returns = "(string)", valuetype = "string",}

documentation["civ"]["childs"]["getTribe"] = { type = "function", description = "civ.getTribe(id) -> tribe\n\nReturns the tech with id `id` (0-7), or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(tribeObject|nil)", valuetype = "tribeObject",}

documentation["civ"]["childs"]["getTurn"] = { type = "function", description = "civ.getTurn() -> integer\n\nReturns the current turn number.", args = "()", returns = "(integer)", valuetype = "integer",}

documentation["civ"]["childs"]["getUnit"] = { type = "function", description = "civ.getUnit(id) -> integer\n\nReturns the unit with id `id`, or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(integer|nil)", valuetype = "integer",}

documentation["civ"]["childs"]["getUnitType"] = { type = "function", description = "civ.getUnitType(id) -> unitType\n\nReturns the unit type with id `id`, or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(unitTypeObject|nil)", valuetype = "unitTypeObject",}

documentation["civ"]["childs"]["getWonder"] = { type = "function", description = "civ.getWonder(id) -> wonder\n\nReturns the wonder with id `id` (0-27), or `nil` if it doesn't exist.", args = "(id: integer)", returns = "(wonderObject|nil)", valuetype = "wonderObject",}

documentation["civ"]["childs"]["giveTech"] = { type = "function", description = "civ.giveTech(tribe, tech) -> void\n\nGives tech `tech` to tribe `tribe`.", args = "(tribeObject,techObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["hasImprovement"] = { type = "function", description = "civ.hasImprovement(city, improvement) -> void\n\nReturns `true` if city `city` has improvement `improvement`, `false` otherwise.", args = "(cityObject,improvementObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["hasTech"] = { type = "function", description = "civ.hasTech(tribe, tech) -> boolean\n\nReturns `true` if tribe `tribe` has tech `tech`, `false` otherwise.", args = "(tribeObject,techObject)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isBaseTerrain"] = { type = "function", description = "(since 0.16)\nciv.isBaseTerrain(object) -> boolean\n\nReturns `true` if `object` is a base terrain, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isCity"] = { type = "function", description = "civ.isCity(object) -> boolean\n\nReturns `true` if `object` is a city, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isDialog"] = { type = "function", description = "(since 0.16)\nciv.isDialog(object) -> boolean\n\nReturns `true` if `object` is a dialog, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isImage"] = { type = "function", description = "(since 0.16)\nciv.isImage(object) -> boolean\n\nReturns `true` if `object` is an image, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isImprovement"] = { type = "function", description = "civ.isImprovement(object) -> boolean\n\nReturns `true` if `object` is a city improvement, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isLeader"] = { type = "function", description = "civ.isLeader(object) -> boolean\n\nReturns `true` if `object` is a leader, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isMap"] = { type = "function", description = "(since 0.16)\nciv.isMap(object) -> boolean\n\nReturns `true` if `object` is a map, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isTech"] = { type = "function", description = "civ.isTech(object) -> boolean\n\nReturns `true` if `object` is a tech, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isTerrain"] = { type = "function", description = "(since 0.16)\nciv.isTerrain(object) -> boolean\n\nReturns `true` if `object` is a terrain, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isTile"] = { type = "function", description = "civ.isTile(object) -> boolean\n\nReturns `true` if `object` is a tile, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isTradeRoute"] = { type = "function", description = "(since 0.17)\nciv.isTradeRoute(object) -> boolean\n\nReturns `true` if `object` is a trade route, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isTribe"] = { type = "function", description = "civ.isTribe(object) -> boolean\n\nReturns `true` if `object` is a tribe, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isUnit"] = { type = "function", description = "civ.isUnit(object) -> boolean\n\nReturns `true` if `object` is a unit, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isUnitType"] = { type = "function", description = "civ.isUnitType(object) -> boolean\n\nReturns `true` if `object` is a unit type, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["isWonder"] = { type = "function", description = "civ.isWonder(object) -> boolean\n\nReturns `true` if `object` is a wonder, `false` otherwise.", args = "(object)", returns = "(boolean)", valuetype = "boolean",}

documentation["civ"]["childs"]["iterateCities"] = { type = "function", description = "civ.iterateCities() -> iterator\n\nReturns an iterator yielding all cities in the game.", args = "()", returns = "(iterator)", valuetype = "iterator",}

documentation["civ"]["childs"]["iterateUnits"] = { type = "function", description = "civ.iterateUnits() -> iterator\n\nReturns an iterator yielding all units in the game.", args = "()", returns = "(iterator)", valuetype = "iterator",}

documentation["civ"]["childs"]["killTribe"] = { type = "function", description = "civ.killTribe(tribe) -> void\n\nRemoves tribe `tribe` from the game. All its cities and units are removed.", args = "(tribeObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["makeAggression"] = { type = "function", description = "civ.makeAggression(who, whom) -> void\n\nCancels any peace treaties between tribe `who` and tribe `whom`, and make `who` declare war on `whom`.", args = "(who: tribeObject,whom: tribeObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["playMusic"] = { type = "function", description = "civ.playMusic(trackNo or filename) -> void\n\nPlays CD track `trackNo`, or with the DirectShow music patch enabled, play the file given by `filename`, where `filename` is relative to the 'Music' directory.", args = "(trackNoorfilename)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["playSound"] = { type = "function", description = "civ.playSound(filename) -> void\n\nPlays the sound file given by `filename`.", args = "(filename: string)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["playVideo"] = { type = "function", description = "civ.playVideo(filename) -> void\n\nPlays the video file given by `filename`.", args = "(filename: string)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["removeImprovement"] = { type = "function", description = "civ.removeImprovement(city, improvement) -> void\n\nRemoves city improvement `improvement` from city `city`.", args = "(cityObject,improvementObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["sleep"] = { type = "function", description = "civ.sleep(milliseconds) -> void\n\nSleeps for the given number of milliseconds.", args = "(milliseconds: integer)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["takeTech"] = { type = "function", description = "civ.takeTech(tribe, tech, collapse=false) -> void\n\nTakes away tech `tech` from tribe `tribe`, the optional `collapse` parameter determines whether to take away all techs that have `tech` as a prerequisite somewhere up the tree.", args = "(tribeObject,techObject,collapse=false)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["teleportUnit"] = { type = "function", description = "civ.teleportUnit(unit, tile) -> void\n\nTeleports (i.e. moves at no cost) unit `unit` to tile `tile`. The unit is moved regardless of whether it is a valid location for the unit. To check this, see `civ.canEnter` and `civlua.isValidUnitLocation`.", args = "(unitObject,tileObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["centerView"] = { type = "function", description = "civ.ui.centerView(tile) -> void\n\nCenters the map on the given tile.", args = "(tileObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["createDialog"] = { type = "function", description = "civ.ui.createDialog() -> dialog\n\nCreates and initializes a dialog. See the dialog section for more details.", args = "()", returns = "(dialogObject)", valuetype = "dialogObject",}

documentation["civ"]["childs"]["ui"]["childs"]["loadImage"] = { type = "function", description = "civ.ui.loadImage(filename, [x], [y], [width], [height]) -> image\n\nLoads an image (BMP or GIF) from `filename`. Optionally accepts `x`, `y`, `width` and `height` to load part of the image.", args = "(filename: string,[x],[y],[width],[height])", returns = "(image)", valuetype = "image",}

documentation["civ"]["childs"]["ui"]["childs"]["loadTerrain"] = { type = "function", description = "civ.ui.loadTerrain(map, filename1, filename2) -> void\n\nReplaces terrain graphics for map number `map`, loading graphics from `filename1` (corresponding to \"TERRAIN1.BMP\") and `filename2` (corresponding to \"TERRAIN2.BMP\")", args = "(mapObject,filename1: string,filename2: string)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["redrawMap"] = { type = "function", description = "civ.ui.redrawMap() -> void\n\nRedraws the entire map.", args = "()", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["redrawTile"] = { type = "function", description = "civ.ui.redrawTile(tile) -> void\n\nRedraws the given tile.", args = "(tileObject)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["setZoom"] = { type = "function", description = "civ.ui.setZoom(integer) -> void\n\nSets the zoom level (range from -7 (max zoom out) to 8 (max zoom in)).", args = "(integer)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["text"] = { type = "function", description = "civ.ui.text(string) -> void\n\nDisplay a pop-up text box with the given string as text.", args = "(string)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["zoomIn"] = { type = "function", description = "civ.ui.zoomIn() -> void\n\nZooms in on the map (increases zoom level by 1).", args = "()", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["ui"]["childs"]["zoomOut"] = { type = "function", description = "civ.ui.zoomOut() -> void\n\nZooms out of the map (decreases zoom level by 1).", args = "()", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["cosmic"]["childs"]["communismPalaceDistance"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.communismPalaceDistance -> integer\n\nReturns the distance from palace used in happiness calculations under Communism.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["foodEaten"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.foodEaten -> integer\n\nReturns the amount of food eaten by each citizen each turn.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["foodRows"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.foodRows -> integer\n\nReturns the number of rows in the food box.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["goodieHutsMask"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.goodieHutsMask -> integer\n\nReturns the bitmask for goodie huts.", valuetype = "bitmask",}

documentation["civ"]["childs"]["cosmic"]["childs"]["helisPickupHuts"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.helisPickupHuts -> integer\n\nReturns whether helicopters (domain 1, range 0 units) pick up huts or not.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["massThrustParadigm"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.massThrustParadigm -> integer\n\nReturns the mass/thrust paradigm.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["numberOfUnitTypes"] = { type = [[value]], description = "(get)\nciv.cosmic.numberOfUnitTypes -> integer\n\nReturns the number of unit types from the @COSMIC2 key of the same name.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["paradropRange"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.paradropRange -> integer\n\nReturns the maximum paradrop range.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["penaltyBetrayal"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.penaltyBetrayal -> integer\n\nReturns the penalty to the civilization score for each betrayal of another tribe.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["prodChangePenalty"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.prodChangePenalty -> integer\n\nReturns the shield penalty percentage for changing production types.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["riotFactor"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.riotFactor -> integer\n\nReturns the riot factor based on the number of cities.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["roadMultiplier"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.roadMultiplier -> integer\n\nReturns the road movement multiplier.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scienceLostFundamentalism"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scienceLostFundamentalism -> integer\n\nReturns the percentage of science lost under Fundamentalism.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scienceRateFundamentalism"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scienceRateFundamentalism -> integer\n\nReturns the maximum effective science rate under Fundamentalism.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scoreCentauri"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scoreCentauri -> integer\n\nReturns the civilization score for each landing on Alpha Centauri first. Multiplied by number of habitats and success probability.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scoreCitizen"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scoreCitizen -> integer\n\nReturns the civilization score for each citizen.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scoreFutureTech"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scoreFutureTech -> integer\n\nReturns the civilization score for each future technology researched.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scorePeace"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scorePeace -> integer\n\nReturns the civilization score for each turn of peace after turn 199.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scorePollution"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scorePollution -> integer\n\nReturns the civilization score for each extant non-AI controlled polluted tile. Normally a negative value, i.e. a penalty.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scoreUnitKilled"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scoreUnitKilled -> integer\n\nReturns the civilization score for each unit killed.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["scoreWonder"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.scoreWonder -> integer\n\nReturns the civilization score for each wonder.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["settlersEatHigh"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.settlersEatHigh -> integer\n\nReturns the amount of food eaten by settlers for governments ≥ Communism.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["settlersEatLow"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.settlersEatLow -> integer\n\nReturns the amount of food eaten by settlers for governments ≤ Monarchy.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["shieldRows"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.shieldRows -> integer\n\nReturns the number of rows in the shield box.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["sizeAquaduct"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.sizeAquaduct -> integer\n\nReturns the city size that cannot be exceeded without an Aquaduct.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["sizeSewer"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.sizeSewer -> integer\n\nReturns the city size that cannot be exceeded without a Sewer System.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["sizeUnhappiness"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.sizeUnhappiness -> integer\n\nReturns the city size at which the first unhappy citizen appears at Chieftain difficulty.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["supportCommunism"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.supportCommunism -> integer\n\nReturns the number of units that are free of support under Communism.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["supportFundamentalism"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.supportFundamentalism -> integer\n\nReturns the number of units that are free of support costs under Fundamentalism.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["supportMonarchy"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.supportMonarchy -> integer\n\nReturns the number of units that are free of support under Monarchy.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["techParadigm"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.techParadigm -> integer\n\nReturns the tech paradigm. Scenarios use civ.scen.params.techParadigm instead of this value.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["transformBase"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.transformBase -> integer\n\nReturns the base time needed for engineers to transform terrain.", valuetype = "integer",}

documentation["civ"]["childs"]["cosmic"]["childs"]["triremeLost"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.cosmic.triremeLost -> integer\n\nReturns the 1 in x chance of a trireme getting lost at sea.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["activeTribes"] = { type = [[value]], description = "(get/set)\nciv.game.activeTribes -> integer\n\nReturns the active tribe mask.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["barbarianActivity"] = { type = [[value]], description = "(get/set)\nciv.game.barbarianActivity -> integer\n\nReturns the level of barbarian activity.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["difficulty"] = { type = [[value]], description = "(get/set)\nciv.game.difficulty -> integer\n\nReturns the difficulty level.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["gameYear"] = { type = [[value]], description = "(get/set)\nciv.game.gameYear -> integer\n\nReturns the game year, or for scenarios with monthly increments, the number of months * 12.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["humanPlayers"] = { type = [[value]], description = "(get/set)\nciv.game.humanPlayers -> integer\n\nReturns the human players mask.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["humanTribe"] = { type = [[value]], description = "(get)\nciv.game.humanTribe -> tribe\n\nReturns the last active human tribe.", valuetype = "tribeObject",}

documentation["civ"]["childs"]["game"]["childs"]["peaceTurns"] = { type = [[value]], description = "(get/set)\nciv.game.peaceTurns -> integer\n\nReturns the number of turns of peace.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["revealMap"] = { type = [[value]], description = "(get/set)\nciv.game.revealMap -> boolean\n\nReturns whether or not the full map is revealed.", valuetype = "boolean",}

documentation["civ"]["childs"]["game"]["childs"]["turnsElapsed"] = { type = [[value]], description = "(get/set)\nciv.game.turnsElapsed -> integer\n\nReturns the number of turns elapsed.", valuetype = "integer",}

documentation["civ"]["childs"]["game"]["childs"]["rules"]["childs"]["flatWorld"] = { type = [[value]], description = "(get/set)\nciv.game.rules.flatWorld -> boolean\n\nReturns `true` if the world map is flat, `false` otherwise.", valuetype = "boolean",}

documentation["civ"]["childs"]["scen"]["childs"]["onActivateUnit"] = { type = "function", description = "civ.scen.onActivateUnit(function (unit, source, repeatMove [since 0.17]) -> void) -> void\n\nRegisters a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving (see civ.scen.compatibility), `false` otherwise.", args = "(function(unit,source,repeatMove[since0.17])->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCanBuild"] = { type = "function", description = "civ.scen.onCanBuild(function (defaultBuildFunction, city, item) -> boolean) -> void\n\nRegisters a function to be called every time a check is done whether a city can build something or not. It is called for all unit types, improvements and wonders. The first parameter of the callback is the default build function, as implemented by the game. It takes the city and item as parameters. You can call this to produce a result for cases you don't need to handle yourself. `item` can be a unitType, improvement or wonder.", args = "(function(defaultBuildFunction,cityObject,item)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onBribeUnit"] = { type = "function", description = "civ.scen.onBribeUnit(function (unit, previousOwner) -> void) -> void\n\nRegisters a function that is called when a unit is bribed successfully. unit.owner is the new owner at this point, `previousOwner` the old owner.", args = "(function(unit,previousOwner)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCanFoundCity"] = { type = "function", description = "(since 0.18)\nciv.scen.onCanFoundCity(function (unit, advancedTribe) -> boolean) -> void\n\nRegisters a function that is called to determine if `unit` can found a city at the unit's location. `advancedTribe` is `true` when picking up a hut with `unit` triggers an advanced tribe. Return `true` to allow, `false` to disallow.", args = "(function(unit,advancedTribe)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCentauriArrival"] = { type = "function", description = "civ.scen.onCentauriArrival(function (tribe) -> void) -> void\n\nRegisters a function that is called when a tribe's spaceship reaches its target. Just registering this function causes the game to not end at this point (\"endgame override\").", args = "(function(tribe)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onChooseDefender"] = { type = "function", description = "(since 0.17)\nciv.scen.onChooseDefender(function (defaultFunction, tile, attacker, isCombat) -> unit) -> void\n\nRegisters a function that is called every time a unit is chosen to defend a tile. The first parameter is the default function as implemented by the game. It takes `tile` and `attacker` as parameters. You can call this to produce a result for cases you don't need to handle yourself. The second parameter is the tile that's being considered, the third is the attacking unit, and the fourth, `isCombat`, is a boolean that indicates if this invocation will be followed by combat. This function is also called by the AI to determine its goals, in which case `isCombat` is false.", args = "(function(defaultFunction,tileObject,attacker,isCombat)->unit)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCityDestroyed"] = { type = "function", description = "civ.scen.onCityDestroyed(function (city) -> void) -> void\n\nRegisters a function that is called when a city is destroyed.", args = "(function(city)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCityFounded"] = { type = "function", description = "civ.scen.onCityFounded(function (city) -> optional (function () -> void)) -> void\n\nRegisters a function to be called every time a city is founded. The callback takes the city as a parameter, and can optionally return a function (since 0.18) that is called to perform cleanup when the user cancels founding the city.", args = "(function(city)->optional(function())->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCityProcessingComplete"] = { type = "function", description = "(since 0.18)\nciv.scen.onCityProcessingComplete(function (turn, tribe) -> void) -> void\n\nRegisters a function that is called when a tribe's cities have been processed for that turn. See `onTurn` for interaction with other \"turn\" triggers.", args = "(function(turn,tribe)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCityProduction"] = { type = "function", description = "civ.scen.onCityProduction(function (city, prod) -> void) -> void\n\nRegisters a function that is called when a city completes its production order. The produced item `prod` is either a unit, improvement or wonder (this can be checked with the civ.is* functions).", args = "(function(city,prod)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onCityTaken"] = { type = "function", description = "civ.scen.onCityTaken(function (city, defender) -> void) -> void\n\nRegisters a function that is called when a city is captured. `city` is the city changing hands, at this point city.owner is the new owner already. `defender` is the old owner.", args = "(function(city,defender)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onGetFormattedDate"] = { type = "function", description = "(since 0.18)\nciv.scen.onGetFormattedDate(function (turn, defaultDateString) -> string) -> void\n\nRegisters a function that is called when the game needs to get the date string for a given turn (e.g. \"4000 B.C.\" for turn 1). `turn` is the turn for which the date is requested (not always the current turn), and `defaultDateString` is the string as formatted by the game", args = "(function(turn,defaultDateString)->string)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onGetRushBuyCost"] = { type = "function", description = "(since 0.17)\nciv.scen.onGetRushBuyCost(function (city, cost) -> integer) -> void\n\nRegisters a function that is called when calculating the cost to rush-buy a city's current production. It takes the city and the cost as calculated by the game as parameters. Returns an integer representing the new costs.", args = "(function(city,cost)->integer)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onKeyPress"] = { type = "function", description = "civ.scen.onKeyPress(function (keyCode) -> void) -> void\n\nRegisters a function to be called every time a key is pressed.", args = "(function(keyCode)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onLoad"] = { type = "function", description = "civ.scen.onLoad(function (string) -> void) -> void\n\nRegisters a function that is called when the game is loaded.", args = "(function(string)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onNegotiation"] = { type = "function", description = "civ.scen.onNegotiation(function (talker, listener) -> boolean) -> void\n\nRegisters a function that is called when two tribes attempt negotiations. `talker` is the tribe initiating the contact, `listener` the receiver. Return `true` to allow the negotiations to commence, `false` to deny.", args = "(function(talker,listener)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onResolveCombat"] = { type = "function", description = "(deprecated since 0.16)\nciv.scen.onResolveCombat(function (defaultResolutionFunction, defender, attacker) -> boolean) -> void\n\nRegisters a function to be called during every combat turn. The first parameter of the callback is the default resolution function, as implemented by the game. It takes the attacker and defender as parameters. You can call this to produce a result for cases you don't need to handle yourself. Return `true` to continue combat, `false` to stop. See onInitiateCombat for replacement.", args = "(function(defaultResolutionFunction,defender,attacker)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onSave"] = { type = "function", description = "civ.scen.onSave(function () -> string) -> void\n\nRegisters a function that is called when the game is saved.", args = "(function()->string)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onScenarioLoaded"] = { type = "function", description = "civ.scen.onScenarioLoaded(function () -> void) -> void\n\nRegisters a function that is called when the scenario is loaded.", args = "(function()->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onSchism"] = { type = "function", description = "civ.scen.onSchism(function (tribe) -> boolean) -> void\n\nRegisters a function that is called when a schism is triggered. This happens when the capital of a AI-controlled tribe with more than four cities is captured, and, if the attacker is human-controlled, it is ranked lower in power than the defender. If the attacker is AI-controlled the best human tribe must be ranked lower than the defender for the schism to trigger.", args = "(function(tribe)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onSelectMusic"] = { type = "function", description = "(since 0.18)\nciv.scen.onSelectMusic(function (track) -> optional integer) -> void\n\nRegisters a function that is called when a new music track is to be played. `track` is either nil or an integer. If nil, the game wants to play a random track, if not nil it's either due to the user choosing a track from the menu (first track has id 0), or the game playing one of it's special tracks (\"Funeral March\" - track id 0, and \"Ode to Joy\" - track id 1). To handle special tracks, you can return nil to signal that the game should play the default track associated with that track id. If you want to handle this track id, call civ.playMusic (this will check the Music folder of the scenario first before falling back to the global Music folder) and return an integer, which is used to synchronize the track list in the menu. The track names can be added in @PICKMUSICTOT in Game.txt.", args = "(function(track)->optionalinteger)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onTribeTurnBegin"] = { type = "function", description = "(since 0.18)\nciv.scen.onTribeTurnBegin(function (turn, tribe) -> void) -> void\n\nRegisters a function that is called at the start of a tribe's turn. See `onTurn` for interaction with other \"turn\" triggers.", args = "(function(turn,tribe)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onTribeTurnEnd"] = { type = "function", description = "(since 0.18)\nciv.scen.onTribeTurnEnd(function (turn, tribe) -> void) -> void\n\nRegisters a function that is called at the end of a tribe's turn. See `onTurn` for interaction with other \"turn\" triggers.", args = "(function(turn,tribe)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onUnitKilled"] = { type = "function", description = "civ.scen.onUnitKilled(function (loser, winner) -> void) -> void\n\nRegisters a function that is called whenever a unit is killed. `loser` is the unit that is killed, `winner` is the unit responsible for it.", args = "(function(loser,winner)->void)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["onUseNuclearWeapon"] = { type = "function", description = "(since 0.18)\nciv.scen.onUseNuclearWeapon(function (unit, tile) -> boolean) -> void\n\nRegisters a function that is called when a nuclear weapon is used. This is also called when a spy plants a nuclear device in a city. `unit` is the weapon or the spy unit, `tile` is the location of the attack. Return `false` to abort the attack, `true` to proceed.", args = "(function(unit,tile)->boolean)", returns = "(void)", valuetype = "void",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["decisiveDefeat"] = { type = [[value]], description = "(get/set)\nciv.scen.params.decisiveDefeat -> integer\n\nNumber of objectives required for a decisive defeat.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["decisiveVictory"] = { type = [[value]], description = "(get/set)\nciv.scen.params.decisiveVictory -> integer\n\nNumber of objectives required for a decisive victory.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["marginalDefeat"] = { type = [[value]], description = "(get/set)\nciv.scen.params.marginalDefeat -> integer\n\nNumber of objectives required for a marginal defeat.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["marginalVictory"] = { type = [[value]], description = "(get/set)\nciv.scen.params.marginalVictory -> integer\n\nNumber of objectives required for a marginal victory.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["maxTurns"] = { type = [[value]], description = "(get/set)\nciv.scen.params.maxTurns -> integer\n\nMaximum number of turns before the scenario ends.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["name"] = { type = [[value]], description = "(get/set)\nciv.scen.params.name -> string\n\nThe name of the scenario.", valuetype = "string",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["objectivesProtagonist"] = { type = [[value]], description = "(get/set)\nciv.scen.params.objectivesProtagonist -> tribe\n\nReturns the objectives protagonist.", valuetype = "tribeObject",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["startingYear"] = { type = [[value]], description = "(get)\nciv.scen.params.startingYear -> integer\n\nReturns the starting year of the scenario.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["techParadigm"] = { type = [[value]], description = "(get/set)\nciv.scen.params.techParadigm -> integer\n\nReturns the tech paradigm used by the scenario. Non-scenario games use civ.cosmic.techParadigm instead of this value.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["params"]["childs"]["yearIncrement"] = { type = [[value]], description = "(get/set)\nciv.scen.params.yearIncrement -> integer\n\nReturns the year increment (number of years per turn). Negative for monthly increments.", valuetype = "integer",}

documentation["civ"]["childs"]["scen"]["childs"]["compatibility"]["childs"]["activateUnitEveryMove"] = { type = [[value]], description = "(get/set - ephemeral)\nciv.scen.compatibility.activateUnitEveryMove -> boolean\n\nIf set to true, onActivateUnit will re-trigger for every tile the active unit moves. Defaults to false, in which case onActivateUnit triggers only once.", valuetype = "boolean",}

documentation["totpp"]["childs"]["roadTrade"] = { type = [[value]], description = "(get/set - ephemeral)\ntotpp.roadTrade[map] -> integer\n\nReturns a bitmask with the terrain types that receive an initial trade arrow when a road is built. Provided by the Initial trade arrow for roads patch.",} -- no valuetype for this table like property

documentation["tribeObject"]["childs"]["attitude"] = { type = [[value]], description = "(get/set)\ntribe.attitude[otherTribe] -> integer\n\nReturns the tribe's attitude to `otherTribe`.",} -- no valuetype for this table like property

documentation["tribeObject"]["childs"]["reputation"] = { type = [[value]], description = "(get/set)\ntribe.reputation[otherTribe] -> integer\n\nReturns the tribe's reputation with `otherTribe`.",} -- no valuetype for this table like property

documentation["tribeObject"]["childs"]["treaties"] = { type = [[value]], description = "(get/set)\ntribe.treaties[otherTribe] -> integer\n\nReturns the tribe's treaties with `otherTribe`.",} -- no valuetype for this table like property

documentation["tileObject"]["childs"]["visibleImprovements"] = { type = [[value]], description = "(get/set)\ntile.visibleImprovements[tribe] -> integer\n\nReturns the tile's improvements as known by the given tribe (bitmask).",} -- no valuetype for this table like property

documentation["cityObject"]["childs"]["sizeForTribe"] = { type = [[value]], description = "(get/set)\ncity.sizeForTribe[tribe] -> integer\n\nReturns the city's size as known by the given tribe.",} -- no valuetype for this table like property

documentation["cityObject"]["childs"]["tradeRoutes"] = { type = [[value]], description = "(get)\ncity.tradeRoutes[id] -> traderoute\n\nReturns the trade route with id `id` (0-2), or `nil` if not in use.",} -- no valuetype for this table like property

return {api=documentation, keyWordList = {
[[civ.cosmic.scoreFutureTech civ.cosmic.sizeSewer civlua.findCapital civ.getToTDir civ.cosmic.supportCommunism civ.game.peaceTurns civ.getMapDimensions totpp.patches.CityWinUnitSelect totpp.patches.DirectShowAudio civ.isTile hasImprovement civ.cosmic.roadMultiplier civ.scen.onNegotiation civ.isTribe totpp.patches.MovementRate civ.scen.params.decisiveVictory civ.cosmic.triremeLost civ.scen.onBribeUnit civlua.domain.ground civ.ui.redrawTile totpp.patches.NoCD totpp.patches.CivilopediaWonderGraphics civ.isTradeRoute civ.getUnit totpp.patches.Fertility civlua.terrain.forest civ.cosmic.scienceLostFundamentalism civlua.terrain.hills totpp.patches.ImpassableAir civ.isMap civ.game.difficulty totpp.patches.Units totpp.patches.DiplomacyScreenCrash civ.getBaseTerrain civ.isUnitType totpp.patches.Landmarks civ.scen.params.yearIncrement civ.scen.onCityTaken civ.getPlayerTribe civ.ui.zoomIn enableTechGroup civ.getCurrentTile giveTech canBuild civ.captureCity civ.cosmic.scorePollution totpp.patches.CustomModResources civlua.property totpp.patches.ShieldColors totpp.patches.AITweaks totpp.patches.ModifyReputation civ.isImprovement civ.cosmic.massThrustParadigm totpp.patches.FixEditControl civ.ui.loadTerrain civ.isLeader addImprovement civ.scen.params.marginalDefeat civ.scen.onSelectMusic totpp.patches.TerrainTypes civ.getCurrentTribe totpp.movementMultipliers.aggregate totpp.roadTrade totpp.patches.CustomResources civ.scen.params.startingYear totpp.patches.MajorObjective civ.deleteCity totpp.patches.CityPopulationLoss civ.cosmic.scoreUnitKilled civ.cosmic.foodRows totpp.patches.UnitIndicators civ.scen.onGameEnds civ.scen.onTurn civlua.terrain.glacier civ.ui.createDialog copyDefaultResources hasTech civ.getGameYear civ.getTile civ.isWonder civ.cosmic.prodChangePenalty totpp.patches.TakeTechnology totpp.patches.BuildTransporter civlua.terrain.tundra civ.getMap civ.scen.onCentauriArrival civ.scen.onCityDestroyed totpp.patches.DecreaseCPUUse civ.scen.params.decisiveDefeat totpp.movementMultipliers.road civ.scen.onResolveCombat addTradeRoute totpp.patches.Cosmic totpp.patches.ResetCityName civ.getTribe civ.game.gameYear civ.getCity teleport civ.cosmic.penaltyBetrayal civ.getImprovement civ.cosmic.communismPalaceDistance kill civ.isCity civ.cosmic.scoreWonder totpp.patches.GlobalWarming totpp.patches.TeleporterMapCheck civlua.terrain.grassland civ.ui.setZoom civ.scen.params.name totpp.patches.ZoomLevel totpp.patches.AcivateUnitScrollbar civ.isDialog civ.ui.centerView civlua.findCity totpp.patches.PikemenFlag totpp.patches.RoadTrade civlua.unserialize civ.getOpenCity civlua.findUnitType civ.scen.onKeyPress totpp.patches.LuaScripting civlua.iterateTribes civ.playVideo civ.scen.onTribeTurnBegin totpp.patches.DirectShowVideo civlua.domain.sea relocate civ.game.humanPlayers totpp.patches.NoStackKills civlua.terrain.plains totpp.patches.NavigableRivers civ.scen.onCityProcessingComplete totpp.patches.Difficulty civlua.terrain.swamp civ.getActiveUnit civ.scen.onSave civ.cosmic.sizeUnhappiness civ.iterateUnits totpp.patches.Throneroom civ.hasTech civ.getTerrain activate civ.addImprovement civ.scen.onCalculateCityYield totpp.patches.CitySprites totpp.patches.UnitOrientation civ.cosmic.settlersEatHigh civ.scen.onCanFoundCity totpp.movementMultipliers.railroad civlua.findTribe totpp.patches.ProductionCarryOver civ.cosmic.sizeAquaduct civlua.terrain.desert totpp.patches.LWSettings civ.sleep civ.cosmic.riotFactor totpp.patches.NativeTransport civ.cosmic.settlersEatLow civ.game.humanTribe getBaseTerrain canEnter totpp.patches.TradeRevenue totpp.patches.EditTerrainKeys totpp.mod.premadeMap totpp.movementMultipliers.river totpp.movementMultipliers.alpine totpp.patches.CityWinUnitDisband civlua.isValidUnitLocation civ.game.barbarianActivity civ.isTech totpp.patches.Mutex civ.cosmic.scienceRateFundamentalism totpp.patches.TerrainOverlays totpp.patches.ImprovementIcons totpp.patches.AttacksPerTurn totpp.patches.MoveUnitEvent totpp.patches.ResourceAnimationLoop civ.scen.onGetRushBuyCost destroy totpp.patches.ImprovementFlags totpp.patches.Playable civ.scen.params.objectivesProtagonist totpp.patches.TransformTech totpp.patches.SettlerFlags totpp.patches.EndPlayerTurn totpp.patches.DefenseBonus totpp.patches.MapLayout totpp.patches.LuaScenario totpp.patches.Techs civ.scen.compatibility.activateUnitEveryMove civ.playMusic civ.isBaseTerrain civ.scen.onTribeTurnEnd totpp.patches.DebugScripts totpp.patches.MouseWheel civlua.serialize civlua.createUnit totpp.patches.CityView totpp.patches.DirectShowMusic civ.isTerrain civ.playSound civ.ui.loadImage civ.game.activeTribes totpp.patches.CityUnitLimits civ.scen.onCanBuild totpp.patches.ShipDisband totpp.patches.StealTech totpp.patches.CityWorkingTiles totpp.patches.TransformCheck totpp.patches.RRMultiplier civ.getWonder civ.takeTech civ.cosmic.techParadigm totpp.patches.Movedebug civ.enableTechGroup civ.destroyWonder civ.scen.onSchism civ.scen.onUnitKilled removeImprovement totpp.patches.Reporting civ.iterateCities civ.cosmic.scoreCitizen totpp.patches.DisabledButton civ.cosmic.paradropRange civ.scen.params.techParadigm civ.deleteUnit civ.ui.text civ.makeAggression civ.scen.params.maxTurns civ.removeImprovement totpp.patches.Mods civlua.terrain.mountains civlua.justOnce totpp.patches.Overview civ.getCommodity civ.scen.onChooseDefender civ.scen.params.flags totpp.patches.TOTPPConfig civlua.iterateTiles civ.cosmic.goodieHutsMask removeTradeRoute civ.endGame civ.scen.onScenarioLoaded civ.scen.onCityFounded totpp.patches.SaveExt civ.cosmic.helisPickupHuts civ.getAtlasDimensions totpp.patches.FixHostility civ.createUnit civ.cosmic.foodEaten civ.game.rules.flatWorld totpp.patches.HealthBars civ.scen.onCityProduction civ.scen.params.marginalVictory totpp.patches.EventHeap civ.getUnitType civ.isImage takeTech civ.scen.onLoad civ.createCity civlua.domain.air totpp.patches.NoLimits civ.scen.onUseNuclearWeapon civ.cosmic.shieldRows civ.scen.onGetFormattedDate civ.isUnit civlua.terrain.ocean totpp.patches.RushBuy civ.hasImprovement civ.getTurn civ.cosmic.scoreCentauri civ.cosmic.scorePeace getTerrain popTradeRoute civ.cosmic.supportFundamentalism civlua.terrain.jungle civ.getTech civ.killTribe civ.giveTech civ.cosmic.supportMonarchy totpp.patches.CombatAnimation civ.game.turnsElapsed civ.scen.onInitiateCombat civ.canEnter civ.game.revealMap civ.teleportUnit civ.cosmic.numberOfUnitTypes civ.ui.redrawMap civ.cosmic.transformBase civ.ui.zoomOut civ.scen.onActivateUnit ]]
}}
