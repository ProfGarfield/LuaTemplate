---@meta

-- version: 0.18.4
---
---[Open in Browser](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/)
---



---"Void" isn't a proper data type in Lua. Instead, it is an indication that a function or method is not returning a value at all. A function with a simple <code>return</code>, or without a <code>return</code> line will return (or, rather, not return) a "void", whereas <code>return nil</code> will return a proper nil value. If your function <em>never</em> returns useful information, returning "void" is appropriate. However, if your code <em>sometimes</em> returns useful data, it should return nil when it does not.
---@class void

---@alias void_doc void


---The 'nil' data type has a single value nil, and tends to represent the absence of a value. Nil is a data type which is native to Lua, and is considered 'falsy' in logical statements. Unassigned keys in a table return nil as their value.
---<br>
---[Programming in Lua, 2.1 -- Nil](https://www.lua.org/pil/2.1.html)
---<br>
---[Tutorialspoint Lua -- Data Types](https://www.tutorialspoint.com/lua/lua_data_types.htm)
---@class nil

---@alias nil_doc nil


---A table is a data type native to Lua, and links "keys" (usually numbers or strings) to "values" (any kind of data, including other tables). This is the only data structuring mechanism in Lua, and many of the data types documented here are simply tables with restrictions on their keys or values. If a key has not been assigned a value, the table returns nil as the corresponding value, and assigning nil as a value to a key removes that key from the table.
---<br>
---[Programming in Lua, 2.5 -- Tables](https://www.lua.org/pil/2.5.html)
---@class table

---@alias table_doc table



---A number is a data type native to Lua, which allows numerical computations to be performed. Fundamentally, Lua does not have separate data types for integers and numbers with a component after the decimal point, so any integer is also a number.
---<br>
---[Programming in Lua, 2.3 -- Numbers](https://www.lua.org/pil/2.3.html)
---@class number

---@alias number_doc number




---An integer is a number without a fractional part. Unlike other programming Languages, Lua does not distinguish between integers and 'floating point' numbers. You can convert a number to an integer by using commands like <code>math.floor</code> and <code>math.ceil</code>.
---<br>
---[Programming in Lua, 2.3 -- Numbers](https://www.lua.org/pil/2.3.html)
---@class integer

---@alias integer_doc integer



---A boolean is a data type native to Lua with exactly two possible values, <code>true</code> and <code>false</code>. These are often used when evaluating logical statements, but logical statements accept other values as well. All values except <code>false</code> and <code>nil</code> are considered 'truthy', even values such as 0 or the empty string.
---<br>
---[Programming in Lua, 2.2 -- Booleans](https://www.lua.org/pil/2.2.html)
---@class boolean

---@alias boolean_doc boolean




---A string is a data type native to Lua which consists of a sequence of characters. These often represent text to be displayed, but are also useful in other contexts. Strings are commonly used as keys in tables, since they make code more readable.
---<br>
---[Programming in Lua, 2.4 -- Strings](https://www.lua.org/pil/2.4.html)
---@class string

---@alias string_doc string




---A function is a sequence of instructions, which frequently depend on values that are provided ("arguments"). In Lua, functions are considered values, and can be stored in variables or tables. They can also be supplied as arguments to other functions.
---<br>
---[Programming in Lua, 2.6 -- Functions](https://www.lua.org/pil/2.6.html)
---@class function

---@alias function_doc function


---Userdata is a data type native to Lua which represents objects that are not part of the Lua language. This data type is an overall data type for Civilization objects, such as units, cities, and tribes, particularly when dealing with native Lua functions.  For example, <code>type(civ.getUnitType(0))</code> returns <code>"userdata"</code>. 
---<br>
---[Programming in Lua, 2.7 -- Userdata and Threads](https://www.lua.org/pil/2.7.html)
---@class userdata

---@alias userdata_doc userdata


---A bitmask is an integer that is not meant to be interpreted as a number, but rather as a sequence of 1's and 0's (the binary representation of the number), with each 1 or 0 representing whether a condition is true or false. Bitmasks often have functions written to facilitate their manipulation. If none are available, Lua provides bitwise operators.</p><p>Typically, the leftmost bit (the bit representing the largest value) is interpreted as negative. Hence, the bitmask integer is not guaranteed to be positive.
---<br>
---[Lua 5.3 Reference Manual 3.4.2 -- Bitwise Operators](https://www.lua.org/manual/5.3/manual.html#3.4.2)
---<br>
---[Twos complement: Negative numbers in binary (Youtube Video)](https://www.youtube.com/watch?v=4qH4unVtJkE)
---@class bitmask: integer

---An id number is a positive integer that corresponds to an object in the game or the rules.txt file. If you know what <em>kind</em> of object the id corresponds to, you can then use the id to get the specific item in question. The maximum value for an id will depend on its corresponding object. For example, the maximum id for a tribe object is 7, but (at least for programming purposes) there is no limit to the id number of a unit.
---@alias id integer 

--[[An iterator is a construct that enables a program to traverse the elements of a collection or container. Each time the iterator is called, a different element of the collection is provided. In practice, an iterator is usually used as part of a generic for loop:
```lua 
for unit in civ.iterateUnits() do
  civ.deleteUnit(unit)
end
```]]
---<br>
---[Tutorialspoint: Lua -- Iterators](https://www.tutorialspoint.com/lua/lua_iterators.htm)
---@class iterator

---Accepts a tribeObject as the key, and returns an integer
---@class tribeToInt table<tribeObject,integer>

---A city object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a city in the game, and provides a means of interacting with that city.
---<br>
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#city)
---@class cityObject
---@field attributes bitmask (get/set) Returns the city's attributes (bitmask).
---@field baseTrade integer (get) Returns the number of trade arrows before trade routes.
---@field coastal boolean (get) Returns whether or not the city is on a coast (can build coastal improvements).
---@field currentProduction prodItem (get/set) Returns the city's current production.
---@field food integer (get/set) Returns the quantity of food in store.
---@field id integer (get) Returns the city's id.
---@field knownTo bitmask (get/set) Returns a bitmask indicating the tribes that have knowledge of this city.
---@field location tileObject (get) Returns the city's location. See the `relocate` method for a way to set this.
---@field name string (get/set) Returns the city's name.
---@field numHappy integer (get) Returns the number of happy citizens.
---@field numTradeRoutes integer (get) Returns the number of trade routes of the city.
---@field numUnhappy integer (get) Returns the number of unhappy citizens.
---@field originalOwner tribeObject (get/set) Returns the city's original owner. This can be different from `owner` if the city was captured in the past.
---@field owner tribeObject (get/set) Returns the city's owner.
---@field science integer (get) Returns the amount of science the city produces.
---@field shields integer (get/set) Returns the number of shields towards the current item in production.
---@field size integer (get/set) Returns the city's size.
---@field sizeForTribe tribeToInt (get/set) cityObject.sizeForTribe[tribe] -> integer Returns the city's size as known by the given tribe.
---@field specialists integer (get/set) Returns the city's specialists as a integer, 16 x 2 bits per specialist (0 - No specialist, 1 - Entertainer, 2 - Taxman, 3 - Scientist)
---@field tax integer (get) Returns the amount of tax the city produces.
---@field totalFood integer (get) Returns the total amount of food the city produces.
---@field totalShield integer (get) Returns the total amount of shields the city produces.
---@field totalTrade integer (get) Returns the total amount of trade arrows the city produces (including trade routes).
---@field turnsSinceCapture integer (get/set) Returns the number of turns since the city was last captured.
---@field workers bitmask (get/set) Returns a bitmask with the workers and specialists of the city.
---@field tradeRoutes traderouteObject|nil (get) Returns the trade route with id `id` (0-2), or `nil` if not in use.
local cityObject = {}

---Alias for `civ.addImprovement(city, improvement)`.
---@param improvement improvementObject
function cityObject:addImprovement(improvement) end

---Returns whether or not `item` can currently be built in the city. `item` can be a unitType, improvement or wonder.
---@param item prodItem
---@return boolean boolean
function cityObject:canBuild(item) end

---Alias for `civ.hasImprovement(city, improvement)`.
---@param improvement improvementObject
---@return boolean boolean
function cityObject:hasImprovement(improvement) end

---Relocates the city to the location given by `tile`. Returns `true` if successful, `false` otherwise (if a city is already present for example).
---@param tile tileObject
---@return boolean boolean
function cityObject:relocate(tile) end

---Alias for `civ.removeImprovement(city, improvement)`.
---@param improvement improvementObject
function cityObject:removeImprovement(improvement) end

---Adds a new trade route to city `destination`, with commodity `commodity`. Returns an error if all 3 trade slots are already in use.
---@param destination cityObject The destination city for the trade route.
---@param commodity commodityObject The trade route commodity.
function cityObject:addTradeRoute(destination,commodity) end

---Removes the last trade route, or does nothing if no trade routes are in use.
function cityObject:popTradeRoute() end

---Removes the trade route with index `id` (0-2). This shifts elements after `id` to fill gaps in the array, so references to trade routes may not be valid anymore after calling this.
---@param id id
function cityObject:removeTradeRoute(id) end



---A tile object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a map "square" in the game, and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#tile)
---@class tileObject
---@field baseTerrain baseTerrainObject (get/set) Returns the baseterrain object associated with the tile.
---@field city cityObject|nil (get) Returns the city at the tile's location, or `nil` if there's no city there.
---@field defender tribeObject|nil (get) Returns the tile's defender. Returns `nil` if the tile has no defender.
---@field fertility integer (get/set) Returns the tile's fertility.
---@field grasslandShield boolean (get) Returns `true` if the tile would have a shield when changed to grassland, `false` otherwise.
---@field improvements bitmask (get/set) Returns the tile's improvements (bitmask).
---@field landmass integer (get/set) Returns the tile's landmass index.
---@field owner tribeObject (get/set) Returns the tribe owning the tile.
---@field river boolean (get/set) Returns `true` if the tile has a river, `false` otherwise.
---@field terrain terrainObject (get/set) Returns the terrain object associated with the tile.
---@field terrainType integer (get/set) Returns an integer representing the terrain type of the tile, as well as whether the tile has a river, whether there is an special resource being animated, and whether an ocean resource is suppressed for being too far from land. It is recommended to use the baseTerrain property to check and change terrain types instead of this. If checking a terrain type with this property, use % 16 to only get the terrain index.
---@field units iterator (get) Returns an iterator yielding all units at the tile's location.
---@field visibility bitmask (get/set) Returns the tile's visibility for each tribe (bitmask).
---@field visibleImprovements bitmask (get/set) Returns the tile's improvements as known by the given tribe (bitmask).
---@field x integer (get) Returns the `x` coordinate of the tile.
---@field y integer (get) Returns the `y` coordinate of the tile.
---@field z integer (get) Returns the `z` coordinate of the tile (map number).
local tileObject = {}



---A unit object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a unit in the game, and provides a means of interacting with it. This should not be confused with the unit type object.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#unit)
---@class unitObject
---@field attributes bitmask (get/set) Returns the attributes of the unit (bitmask).
---@field carriedBy unitObject|nil (get/set) Returns the carrying unit if this unit is currently on board, `nil` otherwise.
---@field damage integer (get/set) Returns the damage taken by the unit in hitpoints.
---@field domainSpec integer (get/set) Returns the value of the 'domain-specific counter' of the unit.
---@field gotoTile tileObject|nil (get/set) Returns the tile the unit is moving to under the goto order, or `nil` if it doesn't have the goto order.
---@field hitpoints integer (get) Returns the number of hitpoints left. It is defined as unit.type.hitpoints - unit.damage.
---@field homeCity cityObject|nil (get/set) Returns the unit's home city, or `nil` if it doesn't have one.
---@field id id (get) Returns the unit's id.
---@field location tileObject (get) Returns the unit's location.
---@field moveSpent integer (get/set) Returns the number of moves spent by the unit.  Consider using `gen.spendMovementPoints` instead of setting directly.
---@field order integer (get/set) Returns the current order of the unit.
---@field owner tribeObject (get/set) Returns the unit's owner.
---@field type unitTypeObject (get) Returns the unit's type.
---@field veteran boolean (get/set) Returns the veteran status of the unit.
local unitObject = {}

---Activates a unit, clearing its orders, and, if it has a human owner and movement points left, selects it on the map.
function unitObject:activate() end

---Alias for `civ.teleportUnit(unit, tile)`.
---@param tile tileObject
function unitObject:teleport(tile) end



---A unit type object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a unit type entry in the rules.txt, and provides a means of interacting with it. This should not be confused with the unit object.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#unittype)
---@class unitTypeObject
---@field advancedFlags bitmask (get/set - ephemeral) Returns the 'advanced flags' settings of the unit type (bitmask).
---@field attack integer (get/set - ephemeral) Returns the attack factor of the unit type.
---@field buildTransport bitmask (get/set) Returns the 'build transport site' settings of the unit type (bitmask).
---@field cost integer (get/set - ephemeral) Returns the cost of the unit type.
---@field defense integer (get/set - ephemeral) Returns the defense factor of the unit type.
---@field domain integer (get/set - ephemeral) Returns the domain of the unit type (0 - Ground, 1 - Air, 2 - Sea).
---@field expires techObject|nil (get/set - ephemeral) Returns the tech that renders the unit obsolete, or `nil` if there isn't any.
---@field firepower integer (get/set - ephemeral) Returns the firepower of the unit type.
---@field flags bitmask (get/set - ephemeral) Returns the flags of the unit type (bitmask).
---@field hitpoints integer (get/set - ephemeral) Returns the number of hit points of the unit type.
---@field hold integer (get/set - ephemeral) Returns the number of holds of the unit type.
---@field id id (get) Returns the id of the unit type.
---@field minimumBribe integer (get/set - ephemeral) Returns the minimum amount to bribe the unit type.
---@field move integer (get/set - ephemeral) Returns the movement rate of the unit type.
---@field name string (get) Returns the name of the unit type.
---@field nativeTransport bitmask (get/set) Returns the 'native transport' settings of the unit type (bitmask).
---@field notAllowedOnMap bitmask (get/set - ephemeral) Returns the 'not allowed on map' settings of the unit type (bitmask).
---@field prereq techObject|nil (get/set - ephemeral) Returns the prerequisite technology of the unit type, or `nil` if it doesn't have one.
---@field range integer (get/set - ephemeral) Returns the range of the unit type.
---@field role integer (get/set - ephemeral) Returns the role of the unit type.
---@field tribeMayBuild bitmask (get/set - ephemeral) Returns the 'tribe may build' settings of the unit type (bitmask).
---@field useTransport bitmask (get/set) Returns the 'use transport site' settings of the unit type (bitmask).
local unitTypeObject = {}

---Alias for `civ.canEnter(unittype, tile)`
---@param tile tileObject
---@return boolean boolean
function unitTypeObject:canEnter(tile) end



---A tribe object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a tribe, which is to say the characteristics of the tribe overall, in the game, and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#tribe)
---@class tribeObject
---@field active boolean (get) Returns whether the tribe is active, i.e. a human or AI player in the current game.
---@field adjective string (get/set) Returns the adjectival form of the tribe's name (e.g. "Roman").
---@field attitude integer (get/set) Returns the tribe's attitude to `otherTribe`.
---@field betrayals integer (get/set) Returns the number of times the tribe has betrayed another tribe.
---@field futureTechs integer (get/set) Returns the number of future techs the tribe has researched.
---@field government integer (get/set) Returns the government (0 - 6) of the tribe.
---@field id id (get) Returns the id of the tribe.
---@field isHuman boolean (get/set) Returns whether the tribe is a/the human player.
---@field leader leaderObject (get) Returns the leader of the tribe.
---@field money integer (get/set) Returns the amount of money/gold in the tribe's treasury.
---@field name string (get/set) Returns the name of the tribe (e.g. "Romans").
---@field numCities integer (get) Returns the number of cities the tribe has.
---@field numTechs integer (get) Returns the number of techs the tribe has.
---@field numUnits integer (get) Returns the number of units the tribe has.
---@field patience integer (get/set) Returns the tribe's patience.
---@field reputation integer (get/set) Returns the tribe's reputation with `otherTribe`.
---@field researchCost integer (get) Returns the research cost of the tribe.
---@field researchProgress integer (get/set) Returns the progress towards the current research (range between 0 and tribe.researchCost).
---@field researching techObject|nil (get/set) Returns the tech the tribe is currently researching, or `nil` if not researching anything.
---@field scienceRate integer (get) Returns the science rate of the tribe.
---@field spaceship spaceshipObject (get) Returns the space ship object of the tribe.
---@field taxRate integer (get) Returns the tax rate of the tribe.
---@field treaties integer (get/set) Returns the tribe's treaties with `otherTribe`.
local tribeObject = {}


---Alias for `civ.enableTechGroup(tribe, techgroup, value)`.
---Sets the value of tech group `techgroup` (0-7) to value `value` (0-2, 0 = can research, can own, 1 = can't research, can own, 2 = can't research, can't own) for tribe.
---@param techgroup integer # integer in [0,7] 
---@param value 
---| 0 can research, can own
---| 1 can't research, can own
---| 2 can't research, can't own
function tribeObject:enableTechGroup(techgroup,value) end

---Alias for `civ.giveTech(tribe, tech)`.
---@param tech techObject
function tribeObject:giveTech(tech) end

---Alias for `civ.hasTech(tribe, tech)`.
---@param tech techObject
---@return boolean boolean
function tribeObject:hasTech(tech) end

---Alias for `civ.killTribe(tribe)`.
function tribeObject:kill() end

---Alias for `civ.takeTech(tribe, tech, collapse=false)`.
---@param tech techObject
---@param collapse boolean Default value is false.
function tribeObject:takeTech(tech,collapse) end



---An improvement object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents an improvement entry in the rules.txt, and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#improvement)
---@class improvementObject
---@field cantSell boolean (get/set - ephemeral) Returns `true` if the improvement cannot be sold, `false` otherwise. Requires the "Improvement flags" patch.
---@field cost integer (get/set - ephemeral) Returns the cost of the improvement in rows. Multiply by civ.cosmic.shieldRows for the actual production cost.
---@field id id (get) Returns the id of the improvement.
---@field name string (get) Returns the name of the improvement (e.g. "Barracks").
---@field onCapture integer (get/set - ephemeral) Returns what happens to this improvement when a city is captured (0 - Default, 1 - Preserve, 2 - Destroy, 3 - Random). Requires the "Improvement flags" patch.
---@field prereq techObject (get/set - ephemeral) Returns the prerequisite tech of the improvement.
---@field upkeep integer (get/set - ephemeral) Returns the upkeep cost of the improvement.
local improvementObject = {}



---A technology object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a technology entry in the rules.txt, and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#tech)
---@class techObject
---@field aiValue integer (get/set - ephemeral) Returns the AI value of the tech.
---@field category integer (get/set - ephemeral) Returns the category of the tech.
---@field epoch integer (get/set - ephemeral) Returns the epoch of the tech.
---@field group integer (get/set - ephemeral) Returns the group of the tech.
---@field id id (get) Returns the id of the tech.
---@field modifier integer (get/set - ephemeral) Returns the modifier to the AI value based on leader personality.
---@field name string (get) Returns the name of the tech.
---@field prereq1 techObject (get/set - ephemeral) Returns the first prerequisite of the tech.
---@field prereq2 techObject (get/set - ephemeral) Returns the second prerequisite of the tech.
---@field researched boolean (get) Returns whether or not any tribe has researched the tech.
local techObject = {}



---A leader object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents the leader of a tribe, which is to say some characteristics of the tribe specific to the "leader", and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#leader)
---@class leaderObject
---@field attack integer (get/set - ephemeral) Returns the "attack" value of the leader's personality.
---@field cityStyle integer (get/set - ephemeral) Returns the leader's city style.
---@field civilize integer (get/set - ephemeral) Returns the "civilize" value of the leader's personality.
---@field color integer (get/set - ephemeral) Returns the leader's color.
---@field expand integer (get/set - ephemeral) Returns the "expand" value of the leader's personality.
---@field female boolean (get/set) Returns whether or not the leader is female.
---@field id id (get) Returns the id of the leader.
---@field name string (get/set) Returns the name of the leader.
local leaderObject = {}



---A wonder object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a Wonder of the World, both its entry in the rules.txt and also its characteristics within the game.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#wonder)
---@class wonderObject
---@field city cityObject|nil (get/set) Returns the city that has built the wonder, `nil` if not built yet or destroyed.
---@field cost integer (get/set - ephemeral) Returns the cost of the wonder.
---@field destroyed boolean (get) Returns whether or not the wonder is destroyed. Use wonder:destroy() to set this field.
---@field expires techObject|nil (get/set - ephemeral) Returns the tech that renders the wonder obsolete, or `nil` if there isn't any.
---@field id id (get) Returns the id of the wonder.
---@field name string (get) Returns the name of the wonder.
---@field prereq techObject (get/set - ephemeral) Returns the prerequisite technology of the wonder.
local wonderObject = {}

---Alias for `civ.destroyWonder(wonder)`.
function wonderObject:destroy() end



---A production item is an object that can be under production in a city. It can be a unit type object, an improvement object, or a wonder object. Note that it is a unit type object, not a unit object, since the unit hasn't been added to the game yet.
---@alias prodItem
---| unitTypeObject
---| improvementObject
---| wonderObject


---A spaceship object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents the status of a tribe's spaceship, and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#spaceship)
---@class spaceshipObject
---@field fuel integer (get) Returns the number of fuel components of the space ship.
---@field habitation integer (get) Returns the number of habitation modules of the space ship.
---@field lifesupport integer (get) Returns the number of life support modules of the space ship.
---@field propulsion integer (get) Returns the number of propulsion components of the space ship.
---@field solar integer (get) Returns the number of solar modules of the space ship.
---@field structural integer (get) Returns the number of structural improvements of the space ship.
local spaceshipObject = {}



---A dialog object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents a text box that can be displayed to the player and provides properties and methods to customize it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#dialog)
---@class dialogObject
---@field height integer (get/set) Returns the height of the dialog. Normally this does not need to be set, since the height is automatically calculated from the height of the items.
---@field title string (get/set) Returns the title of the dialog.
---@field width integer (get/set) Returns the width of the dialog.
local dialogObject = {}

---Adds a checkbox to the dialog, with label given by `string`. `id` is an integer value that can be used in dialog:getCheckboxState to retrieve the state after calling dialog:show. `initial` is an optional boolean parameter, if set to `true` the checkbox will be checked initially. Can not be used in conjunction with dialog:addOption.
---@param string string
---@param id id
---@param initial boolean Default Value is false
function dialogObject:addCheckbox(string, id, initial) end

---Adds an image to the dialog.
---@param image imageObject
function dialogObject:addImage(image) end

---Adds a selectable option to the dialog, with label given by `string`. `id` is an integer value returned by dialog:show if this option was selected. Can not be used in conjunction with dialog:addCheckbox.
---@param string string
---@param id id
function dialogObject:addOption(string, id) end

---Adds a static text string to the dialog.
---@param string string
function dialogObject:addText(string) end

---Returns the state of the checkbox identified by `id` after dialog:show has been called.
---@param id id
---@return boolean boolean
function dialogObject:getCheckboxState(id) end

---Renders the dialog on screen. If this is an option dialog, returns the id of the selected option (see dialog:addOption). If this is a checkbox dialog, returns 0 if OK was pressed, -1 if Exit was pressed. Use dialog:getCheckboxState to query the individual checkboxes. This method can only be called once per dialog. It will return an error if invoked a second time.
---@return integer integer
function dialogObject:show() end

---A map object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents the overall properties of one of the four possible maps in the game, and provides a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#map)
---@class mapObject
---@field customResources boolean (get/set) Returns `true` if custom resources are enabled for this map, `false` otherwise.
---@field height integer (get) Returns the height of the map.
---@field id id (get) Returns the id of the map.
---@field width integer (get) Returns the width of the map.
local mapObject = {}

---Enables custom resources for this map and copies the default resource pattern. Requires the "Custom resources" patch.
function mapObject:copyDefaultResources() end

---Alias for `civ.getBaseTerrain(map, terrainType)`
---@param terrainId id The id number of the base terrain type sought
---@return baseTerrainObject baseTerrain
function mapObject:getBaseTerrain(terrainId) end


---Alias for `civ.getTerrain(map, terrainType, resource)`
---@param terrainId id The id number of the base terrain type sought.
---@param resource
---| 0 no resource
---| 1 fish resource
---| 2 whales resource
---@return terrainObject terrain
function mapObject:getTerrain(terrainId,resource) end



---A base terrain object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents the 'basic' terrain characteristics for a terrain type, which is to say those aspects of terrain which do not change for special resources. The 'terrain' object deals with the characteristics that do change for special resources.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#baseterrain)
---@class baseTerrainObject
---@field abbrev string (get) The terrain abbreviation for this baseTerrain (e.g. 'Drt', 'Pln' etc.).
---@field canIrrigate boolean (get/set - ephemeral) Returns `true` if the underlying terrain type allows irrigation, `false` otherwise.
---@field canMine boolean (get/set - ephemeral) Returns `true` if the underlying terrain type allows mining, `false` otherwise.
---@field defense integer (get/set - ephemeral) The defense factor of the underlying terrain type.
---@field impassable boolean (get/set - ephemeral) Returns `true` if the underlying terrain type is impassable, `false` otherwise.
---@field irrigateAI integer (get/set - ephemeral) The minimum government level needed for the AI to consider irrigating.
---@field irrigateBonus integer (get/set - ephemeral) The extra amount of food from irrigation.
---@field irrigateTo baseTerrainObject|nil (get/set - ephemeral) If the irrigation order changes the underlying terrain type return the baseTerrain of the new terrain type, `nil` otherwise.
---@field irrigateTurns integer (get/set - ephemeral) The number of turns for settlers to irrigate.
---@field map integer (get) The map associated with the baseTerrain object.
---@field mineAI integer (get/set - ephemeral) The minimum government level needed for the AI to consider mining.
---@field mineBonus integer (get/set - ephemeral) The extra amount of production from mining.
---@field mineTo baseTerrainObject|nil (get/set - ephemeral) If the mine order changes the underlying terrain type return the baseTerrain of the new terrain type, `nil` otherwise.
---@field mineTurns integer (get/set - ephemeral) The number of turns for settlers to mine.
---@field moveCost integer (get/set - ephemeral) The movement cost of the underlying terrain type.
---@field name string (get) The name of this baseTerrain.
---@field transformTo baseTerrainObject|nil (get/set - ephemeral) If the underlying terrain type can be transformed return the baseTerrain of the new terrain type, `nil` otherwise.
---@field type integer (get) The terrain type associated with the baseTerrain object.
local baseTerrainObject = {}

---Returns the terrain object corresponding to the underlying terrain type and the given resource.
---@param resource
---| 0 no resource
---| 1 fish resource
---| 2 whales resource
---@return terrainObject terrain
function baseTerrainObject:getTerrain(resource) end


---A terrain object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents the terrain characteristics which change for special resources. The 'base terrain' object deals with the characteristics that do not change for special resources.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#terrain)
---@class terrainObject
---@field baseTerrain baseTerrainObject (get) The underlying baseterrain of the terrain object.
---@field food integer (get/set - ephemeral) The amount of food produced by the terrain.
---@field map integer (get) The map associated with the terrain object.
---@field name string (get) The name of the terrain.
---@field resource integer (get) The resource associated with the terrain object.
---@field shields integer (get/set - ephemeral) The amount of shields produced by the terrain.
---@field trade integer (get/set - ephemeral) The amount of trade produced by the terrain.
---@field type integer (get) The terrain type associated with the terrain object.
local terrainObject = {}



---A image object is a data type provided by the Test of Time Patch Project Lua Interpreter. It represents an image that can be displayed in a dialog object.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#dialog)
---@class imageObject



---A commodity object is a data type that describes a trade commodity that can be carried by trade units.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#commodity)
---@class commodityObject
---@field id id (get) The id of the commodity (0-15 for regular commodities, -1 for food supplies).
---@field name string (get/set - ephemeral) The name of the commodity.
local commodityObject = {}



---A traderoute object is a data type that describes a trade route that exists between two cities, and offers a means of interacting with it.
---[Lua Function Reference](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#traderoute)
---@class traderouteObject
---@field commodity commodityObject (get/set) The commodity of the trade route.
---@field from cityObject (get) The origin of the trade route.
---@field id id (get) The id of the trade route.
---@field to cityObject (get/set) The destination of the trade route.
local traderouteObject = {}

---Alias for city:removeTradeRoute(id).
function traderouteObject:remove() end






--- The civ module provides functions which can interact directly with the game.  It is always in scope, so you never need to use a `require` call in order to access it.
---@class civ
---@field civ.ui civ.ui
---@field civ.cosmic civ.cosmic
---@field civ.game civ.game
---@field civ.scen civ.scen
civ = {}

---Adds city improvement `improvement` to city `city`.
---@param city cityObject
---@param improvement improvementObject
function civ.addImprovement(city,improvement) end

---Returns `true` if the given unittype can enter tile `tile`, `false` otherwise.
---@param unitType unitTypeObject
---@param tile tileObject
---@return boolean boolean
function civ.canEnter(unitType,tile) end

---Captures city `city` for tribe `tribe`.
---@param city cityObject
---@param tribe tribeObject
function civ.captureCity(city,tribe) end

---Creates a city owned by `tribe` at the location given by `tile`. Returns `nil` if a city could not be created.
---@param tribe tribeObject
---@param tile tileObject
---@return cityObject|nil city
function civ.createCity(tribe,tile) end

---Creates a unit of type `unittype`, owned by `tribe`, at the location given by `tile`.
---@param unitType unitTypeObject
---@param tribe tribeObject
---@param tile tileObject
---@return unitObject unit
function civ.createUnit(unitType,tribe,tile) end

---Deletes city `city` from the game.
---@param city cityObject
function civ.deleteCity(city) end

---Deletes unit `unit` from the game.
---Consider unsing `gen.defeatUnit`, `gen.killUnit`, `gen.deleteUnit`, or `gen.replaceUnit` instead, for event integration.
---<br>Deprecation flag is only here so that designers see the above notice.
---@param unit unitObject
---@deprecated
function civ.deleteUnit(unit) end

---Destroys wonder `wonder`, removing it from the game, and marking it as 'lost'.
---@param wonder wonderObject
function civ.destroyWonder(wonder) end

---Sets the value of tech group `techgroup` (0-7) to value `value` (0-2, 0 = can research, can own, 1 = can't research, can own, 2 = can't research, can't own) for tribe `tribe`.
---@param tribe tribeObject
---@param techgroup integer integer in [0,7]
---@param value 
---| 0 can research, can own
---| 1 can't research, can own
---| 2 can't research, can't own
function civ.enableTechGroup(tribe,techgroup,value) end

---Ends the game. `endscreens` is a boolean that determines whether to show the powergraph and related screens.
---@param endscreens boolean This argument is false by default.
function civ.endGame(endscreens) end

---Returns the currently active unit.
---@return unitObject unit
function civ.getActiveUnit() end

---Returns three integers, the width and height of the map and the number of maps.
---@return integer width
---@return integer height
---@return integer number_of_maps
function civ.getAtlasDimensions() end

---Returns the base terrain object for the given map and terrain type.
---@param map id|mapObject The map for the base terrain type we want, or its id.
---@param terrainId id The id number of the base terrain type sought
---@return baseTerrainObject baseTerrain
function civ.getBaseTerrain(map,terrainId) end

---Returns the city with id `id`, or `nil` if it doesn't exist.
---@param id id
---@return cityObject|nil city
function civ.getCity(id) end

---Returns the currently selected tile.
---@return tileObject tile
function civ.getCurrentTile() end

---Returns the currently active tribe.
---@return tribeObject tribe
function civ.getCurrentTribe() end

---Returns the current game year.
---@return integer integer
function civ.getGameYear() end

---Returns the improvement with id `id` (0-39), or `nil` if it doesn't exist.
---@param id id
---@return improvementObject|nil improvement
function civ.getImprovement(id) end

---Returns the map with id `id` (0-3) or `nil` if it doesn't exist.
---@param id id
---@return mapObject|nil map
function civ.getMap(id) end

---Alias for getAtlasDimensions. (deprecated since 0.16)
---@return integer width
---@return integer height
---@return integer number_of_maps
---@deprecated
function civ.getMapDimensions() end

---Returns the city currently opened in the city window, `nil` if the city window is closed.
---@return cityObject|nil city
function civ.getOpenCity() end

---Returns the player's tribe.
---@return tribeObject tribe
function civ.getPlayerTribe() end

---Returns the tech with id `id` (0-99), or `nil` if it doesn't exist.
---@param id id
---@return techObject|nil tech
function civ.getTech(id) end

---Returns the terrain object for the given map, terrain type and resource. Out of bound id's cause errors.
---@param map id|mapObject The map for the terrain we want, or its id.
---@param terrainId id The id number of the base terrain type sought.
---@param resource
---| 0 no resource
---| 1 fish resource
---| 2 whales resource
---@return terrainObject terrain
function civ.getTerrain(map,terrainId,resource) end

---Returns the tile with coordinates `x`, `y`, `z`, or `nil` if it doesn't exist.
---@param x integer the 'x' coordinate of the tile
---@param y integer the 'y' coordinate of the tile
---@param z integer the 'z' coordinate of the tile ([0,3])
---@return tileObject|nil tile
function civ.getTile(x,y,z) end

---Returns the absolute path of the ToT installation directory.
---@return string #
function civ.getToTDir() end

---Returns the tribe with id `id` (0-7), or `nil` if it doesn't exist.
---@param id id
---@return tribeObject|nil tribe
function civ.getTribe(id) end

---Returns the current turn number.
---@return integer #
function civ.getTurn() end

---Returns the unit with id `id`, or `nil` if it doesn't exist.
---@param id id
---@return unitObject|nil unit
function civ.getUnit(id) end

---Returns the unit type with id `id`, or `nil` if it doesn't exist.
---@param id id
---@return unitTypeObject|nil unitType
function civ.getUnitType(id) end

---Returns the wonder with id `id` (0-27), or `nil` if it doesn't exist.
---@param id id
---@return wonderObject|nil wonder
function civ.getWonder(id) end

---Gives tech `tech` to tribe `tribe`.
---@param tribe tribeObject
---@param tech techObject
function civ.giveTech(tribe,tech) end

---Returns `true` if city `city` has improvement `improvement`, `false` otherwise.
---@param city cityObject
---@param improvement improvementObject
function civ.hasImprovement(city,improvement) end

---Returns `true` if tribe `tribe` has tech `tech`, `false` otherwise.
---@param tribe tribeObject
---@param tech techObject
---@return boolean #
function civ.hasTech(tribe,tech) end

---Returns `true` if `object` is a base terrain, `false` otherwise.
---@param object any
---@return boolean #
function civ.isBaseTerrain(object) end

---Returns `true` if `object` is a city, `false` otherwise.
---@param object any
---@return boolean #
function civ.isCity(object) end

---Returns `true` if `object` is a dialog, `false` otherwise.
---@param object any
---@return boolean #
function civ.isDialog(object) end

---Returns `true` if `object` is an image, `false` otherwise.
---@param object any
---@return boolean #
function civ.isImage(object) end

---Returns `true` if `object` is a city improvement, `false` otherwise.
---@param object any
---@return boolean #
function civ.isImprovement(object) end

---Returns `true` if `object` is a leader, `false` otherwise.
---@param object any
---@return boolean #
function civ.isLeader(object) end

---Returns `true` if `object` is a map, `false` otherwise.
---@param object any
---@return boolean #
function civ.isMap(object) end

---Returns `true` if `object` is a tech, `false` otherwise.
---@param object any
---@return boolean #
function civ.isTech(object) end

---Returns `true` if `object` is a terrain, `false` otherwise.
---@param object any
---@return boolean #
function civ.isTerrain(object) end

---Returns `true` if `object` is a tile, `false` otherwise.
---@param object any
---@return boolean #
function civ.isTile(object) end

---Returns `true` if `object` is a tribe, `false` otherwise.
---@param object any
---@return boolean #
function civ.isTribe(object) end

---Returns `true` if `object` is a unit, `false` otherwise.
---@param object any
---@return boolean #
function civ.isUnit(object) end

---Returns `true` if `object` is a unit type, `false` otherwise.
---@param object any
---@return boolean #
function civ.isUnitType(object) end

---Returns `true` if `object` is a wonder, `false` otherwise.
---@param object any
---@return boolean #
function civ.isWonder(object) end

---Returns an iterator yielding all cities in the game.
---@return iterator #
function civ.iterateCities() end

---Returns an iterator yielding all units in the game.
---@return iterator #
function civ.iterateUnits() end

---Removes tribe `tribe` from the game. All its cities and units are removed.
---@param tribe tribeObject
function civ.killTribe(tribe) end

---Cancels any peace treaties between tribe `who` and tribe `whom`, and make `who` declare war on `whom`.
---@param who tribeObject The tribe declaring war.
---@param whom tribeObject The tribe not declaring war.
function civ.makeAggression(who,whom) end

---Plays CD track `trackNo`, or with the DirectShow music patch enabled, play the file given by `filename`, where `filename` is relative to the 'Music' directory.
---@param trackOrFilename integer|string Track number of cd or filename of music.
function civ.playMusic(trackOrFilename) end

---Plays the sound file given by `filename`.
---@param filename string
function civ.playSound(filename) end

---Plays the video file given by `filename`.
---@param filename string
function civ.playVideo(filename) end

---Removes city improvement `improvement` from city `city`.
---@param city cityObject
---@param improvement improvementObject
function civ.removeImprovement(city,improvement) end

---Sleeps for the given number of milliseconds.
---@param milliseconds integer
function civ.sleep(milliseconds) end

---Takes away tech `tech` from tribe `tribe`, the optional `collapse` parameter determines whether to take away all techs that have `tech` as a prerequisite somewhere up the tree.
---@param tribe tribeObject
---@param tech techObject
---@param collapse? boolean false by default
---@overload fun(tribe: tribeObject, tech:techObject)
function civ.takeTech(tribe,tech,collapse) end

---Teleports (i.e. moves at no cost) unit `unit` to tile `tile`. The unit is moved regardless of whether it is a valid location for the unit. To check this, see `civ.canEnter` and `civlua.isValidUnitLocation`.
---@param unit unitObject
---@param tile tileObject
function civ.teleportUnit(unit,tile) end

---Returns the commodity with id `id` (0-15 for regular commodities, -1 for food supplies), or `nil` if it doesn't exist.
---@param id id
---@return commodityObject|nil commodity
function civ.getCommodity(id) end

---Returns `true` if `object` is a trade route, `false` otherwise.
---@param object any
---@return boolean #
function civ.isTradeRoute(object) end

---
---@class civ.ui
civ.ui = {}

---Centers the map on the given tile.
---@param tile tileObject
function civ.ui.centerView(tile) end

---Creates and initializes a dialog. See the dialog section for more details.
---@return dialogObject dialog
function civ.ui.createDialog() end

---Loads an image (BMP or GIF) from `filename`. Optionally accepts `x`, `y`, `width` and `height` to load part of the image.
---@param filename string
---@param x integer pixel (x,y) is the top left corner of sub image
---@param y integer pixel (x,y) is the top left corner of sub image
---@param width integer width of sub image
---@param height integer height of sub image
---@return imageObject image
---@overload fun(filename: string):imageObject
function civ.ui.loadImage(filename, x, y, width, height) end

---Replaces terrain graphics for map number `map`, loading graphics from `filename1` (corresponding to "TERRAIN1.BMP") and `filename2` (corresponding to "TERRAIN2.BMP")
---@param map mapObject|integer
---@param filename1 string
---@param filename2 string
function civ.ui.loadTerrain(map,filename1,filename2) end

---Redraws the entire map.
function civ.ui.redrawMap() end

---Redraws the given tile.
---@param tile tileObject
function civ.ui.redrawTile(tile) end

---Sets the zoom level (range from -7 (max zoom out) to 8 (max zoom in)).
---@param integer integer
function civ.ui.setZoom(integer) end

---Display a pop-up text box with the given string as text.
---@param string string text to show in a text box
---@param ... string more text
---@overload fun(string:string)
function civ.ui.text(string, ...) end

---Zooms in on the map (increases zoom level by 1).
function civ.ui.zoomIn() end

---Zooms out of the map (decreases zoom level by 1).
function civ.ui.zoomOut() end

---
---@class civ.cosmic
---@field communismPalaceDistance integer (get/set - ephemeral) Returns the distance from palace used in happiness calculations under Communism.
---@field foodEaten integer (get/set - ephemeral) Returns the amount of food eaten by each citizen each turn.
---@field foodRows integer (get/set - ephemeral) Returns the number of rows in the food box.
---@field goodieHutsMask bitmask (get/set - ephemeral) Returns the bitmask for goodie huts.
---@field helisPickupHuts integer (get/set - ephemeral) Returns whether helicopters (domain 1, range 0 units) pick up huts or not.
---@field massThrustParadigm integer (get/set - ephemeral) Returns the mass/thrust paradigm.
---@field numberOfUnitTypes integer (get) Returns the number of unit types from the @COSMIC2 key of the same name.
---@field paradropRange integer (get/set - ephemeral) Returns the maximum paradrop range.
---@field penaltyBetrayal integer (get/set - ephemeral) Returns the penalty to the civilization score for each betrayal of another tribe.
---@field prodChangePenalty integer (get/set - ephemeral) Returns the shield penalty percentage for changing production types.
---@field riotFactor integer (get/set - ephemeral) Returns the riot factor based on the number of cities.
---@field roadMultiplier integer (get/set - ephemeral) Returns the road movement multiplier.
---@field scienceLostFundamentalism integer (get/set - ephemeral) Returns the percentage of science lost under Fundamentalism.
---@field scienceRateFundamentalism integer (get/set - ephemeral) Returns the maximum effective science rate under Fundamentalism.
---@field scoreCentauri integer (get/set - ephemeral) Returns the civilization score for each landing on Alpha Centauri first. Multiplied by number of habitats and success probability.
---@field scoreCitizen integer (get/set - ephemeral) Returns the civilization score for each citizen.
---@field scoreFutureTech integer (get/set - ephemeral) Returns the civilization score for each future technology researched.
---@field scorePeace integer (get/set - ephemeral) Returns the civilization score for each turn of peace after turn 199.
---@field scorePollution integer (get/set - ephemeral) Returns the civilization score for each extant non-AI controlled polluted tile. Normally a negative value, i.e. a penalty.
---@field scoreUnitKilled integer (get/set - ephemeral) Returns the civilization score for each unit killed.
---@field scoreWonder integer (get/set - ephemeral) Returns the civilization score for each wonder.
---@field settlersEatHigh integer (get/set - ephemeral) Returns the amount of food eaten by settlers for governments ≥ Communism.
---@field settlersEatLow integer (get/set - ephemeral) Returns the amount of food eaten by settlers for governments ≤ Monarchy.
---@field shieldRows integer (get/set - ephemeral) Returns the number of rows in the shield box.
---@field sizeAquaduct integer (get/set - ephemeral) Returns the city size that cannot be exceeded without an Aquaduct.
---@field sizeSewer integer (get/set - ephemeral) Returns the city size that cannot be exceeded without a Sewer System.
---@field sizeUnhappiness integer (get/set - ephemeral) Returns the city size at which the first unhappy citizen appears at Chieftain difficulty.
---@field supportCommunism integer (get/set - ephemeral) Returns the number of units that are free of support under Communism.
---@field supportFundamentalism integer (get/set - ephemeral) Returns the number of units that are free of support costs under Fundamentalism.
---@field supportMonarchy integer (get/set - ephemeral) Returns the number of units that are free of support under Monarchy.
---@field techParadigm integer (get/set - ephemeral) Returns the tech paradigm. Scenarios use civ.scen.params.techParadigm instead of this value.
---@field transformBase integer (get/set - ephemeral) Returns the base time needed for engineers to transform terrain.
---@field triremeLost integer (get/set - ephemeral) Returns the 1 in x chance of a trireme getting lost at sea.
civ.cosmic = {}

---
---@class civ.game
---@field civ.game.rules civ.game.rules
---@field activeTribes bitmask (get/set) Returns the active tribe mask.
---@field barbarianActivity integer (get/set) Returns the level of barbarian activity.
---@field difficulty integer (get/set) Returns the difficulty level.
---@field gameYear integer (get/set) Returns the game year, or for scenarios with monthly increments, the number of months * 12.
---@field humanPlayers bitmask (get/set) Returns the human players mask.
---@field humanTribe tribeObject (get) Returns the last active human tribe.
---@field peaceTurns integer (get/set) Returns the number of turns of peace.
---@field revealMap boolean (get/set) Returns whether or not the full map is revealed.
---@field turnsElapsed integer (get/set) Returns the number of turns elapsed.
civ.game = {}

---
---@class civ.game.rules
---@field flatWorld boolean (get/set) Returns `true` if the world map is flat, `false` otherwise.
civ.game.rules = {}

---
---@class civ.scen
---@field params civ.scen.params
---@field compatibility civ.scen.compatibility
civ.scen = {}

---Registers a function to be called every time a unit is activated. The callback takes the unit activated as a parameter, and the source of unit activation. `source` is `true` if activated by keyboard or mouse click, `false` if activated by the game itself. `repeatMove` is `true` if it's a repeat activation caused by moving (see civ.scen.compatibility), `false` otherwise.
---@param code fun(unit: unitObject, source: boolean, repeatMove: boolean)
function civ.scen.onActivateUnit(code) end

---Registers a function that is called when a unit is bribed successfully. unit.owner is the new owner at this point, `previousOwner` the old owner.
---@param code fun(unit: unitObject, previousOwner: tribeObject)
function civ.scen.onBribeUnit(code) end

--[[Registers a function to be called every time a city calculates its total resource yield. Input is the city, and the food, shields and trade of its tiles. Returns a 5-tuple of modifiers, food change, shield change before waste, shield change after waste, trade change before corruption, trade change after corruption. These modifiers are applied at the following points in the calculation:
<br>Calculate yield from all worked tiles
<br>Run onCalculateCityYield
<br>Add foodChange, shieldChangeBeforeWaste and tradeChangeBeforeCorruption
<br>Add changes from food trade routes
<br>Add shields from improvements
<br>Calculate and subtract waste
<br>Calculate corruption and add changes from commodity trade routes
<br>Calculate corruption again (now using the value after trade routes) and subtract.
<br>Add shieldChangeAfterWaste and tradeChangeAfterCorruption
<br>Calculate Tax/Lux/Sci]]
---@param code fun(city: cityObject, food:integer, shields:integer, trade:integer):foodChange:integer, shieldChangeBeforeWaste:integer, shieldChangeAfterWaste:integer, tradeChangeBeforeCorruption:integer, tradeChangeAfterCorruption:integer
function civ.scen.onCalculateCityYield(code) end

--[[
Registers a function to be called every time a check is done whether a city can build something or not. It is called for all unit types, improvements and wonders. The first parameter of the callback is the default build function, as implemented by the game. It takes the city and item as parameters. You can call this to produce a result for cases you don't need to handle yourself. `item` can be a unittype, improvement or wonder.
Return `true` if `city` is allowed to produce `item`, `false` if not. 
]]
---@param code fun(defaultBuildFunction:fun(city: cityObject, item: prodItem):cityCanBuildItemByDefault:boolean,city:cityObject,item: prodItem):cityCanBuildItem:boolean
function civ.scen.onCanBuild(code) end

--[[
Registers a function that is called to determine if `unit` can found a city at the unit's location. `advancedTribe` is `true` when picking up a hut with `unit` triggers an advanced tribe. Return `true` to allow, `false` to disallow.
]]
---@param code fun(unit: unitObject, advancedTribe: boolean):boolean
function civ.scen.onCanFoundCity(code) end

--[[
    Registers a function that is called when a tribe's spaceship reaches its target. Just registering this function causes the game to not end at this point ("endgame override").
]]
---@param code fun(tribe:tribeObject)
function civ.scen.onCentauriArrival(code) end

---@alias defaultChooseDefender fun(tile: tileObject,attacker: unitObject):chosenUnit:unitObject

--[[
Registers a function that is called every time a unit is chosen to defend a tile. The first parameter is the default function as implemented by the game. It takes `tile` and `attacker` as parameters. You can call this to produce a result for cases you don't need to handle yourself. The second parameter is the tile that's being considered, the third is the attacking unit, and the fourth, `isCombat`, is a boolean that indicates if this invocation will be followed by combat. This function is also called by the AI to determine its goals, in which case `isCombat` is false.
]]
---@param code fun(defaultFunction: defaultChooseDefender, tile:tileObject, attacker:unitObject, isCombat:boolean):chosenUnit:unitObject
function civ.scen.onChooseDefender(code) end


--[[
Registers a function that is called when a city is destroyed.
]]
---@param code fun(city:cityObject) 
function civ.scen.onCityDestroyed(code) end


--[[
Registers a function to be called every time a city is founded. The callback takes the city as a parameter, and can optionally return a function (since 0.18) that is called to perform cleanup when the user cancels founding the city.
]]
---@param code fun(city:cityObject)|fun(city:cityObject):fun()
function civ.scen.onCityFounded(code) end


--[[
Registers a function that is called when a tribe's cities have been processed for that turn. See `onTurn` for interaction with other "turn" triggers.
]]
---@param code fun(turn: integer, tribe:tribeObject)
function civ.scen.onCityProcessingComplete(code) end


---@alias producedItem
---| unitObject
---| improvementObject
---| wonderObject

--[[
Registers a function that is called when a city completes its production order. The produced item `prod` is either a unit, improvement or wonder (this can be checked with the civ.is* functions).
]]
---@param code fun(city:cityObject, prod:producedItem)
function civ.scen.onCityProduction(code) end


--[[
Registers a function that is called when a city is captured. `city` is the city changing hands, at this point city.owner is the new owner already. `defender` is the old owner.
]]
---@param code fun(city: cityObject, defender: tribeObject)
function civ.scen.onCityTaken(code) end


---@enum gameEndReasons
local gameEndReasons = {
  ["Space Race Victory by Active Player"] = 1,
  ["Space Race Victory by Another Player"] = 2,
  ["Conquest Victory"] = 3,
  ["Defeat"] = 4,
  ["Retirement"] = 5,
  ["Macro ENDGAME action"] = 6,
}

--[[
Registers a function that is called when the game ends. `reason` is an integer between 1 and 6:
<br>1 and 2 - Space race victory. This does not trigger if `onCentauriArrival` has a callback registered. 1 means victory by active player.
<br>3 - Conquest victory
<br>4 - Defeat
<br>5 - Retirement
<br>6 - Macro ENDGAME action
<br>Return `true` to end the game, `false` to keep playing.
]]
---@param code fun(reason:gameEndReasons):(gameIsOver:boolean)
function civ.scen.onGameEnds(code) end



--[[
Registers a function that is called when the game needs to get the date string for a given turn (e.g. "4000 B.C." for turn 1). `turn` is the turn for which the date is requested (not always the current turn), and `defaultDateString` is the string as formatted by the game
]]
---@param code fun(turn: integer, defaultDateString: string):(displayedDate: string)
function civ.scen.onGetFormattedDate(code) end


--[[
Registers a function that is called when calculating the cost to rush-buy a city's current production. It takes the city and the cost as calculated by the game as parameters. Returns an integer representing the new costs.
]]
---@param code fun(city:cityObject, defaultCost: integer):(costToComplete:integer)
function civ.scen.onGetRushBuyCost(code) end


--[[
Registers a function to be called every time combat is initiated. The callback takes seven parameters, the attacker, the defender, attackerDie ('die' as in dice, the attacker's chance to hit), attackerPower (attacker's firepower), defenderDie, defenderPower and isSneakAttack. Returns a coroutine that yields every time it wants to process a round, and returns when it wants combat to end. Example:

```lua
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
```

This example shows how to limit combat to five rounds, damages the attacker on even rounds and doubles the attacker's values on odd rounds.

If the coroutine yields true as its first value, the game's default combat resolution is skipped for that round and the designer is responsible for updating damage. The second value yielded is either the attacker or the defender, this is used to render animations etc. In this case the coroutine resumes without any values.

If the coroutine yields false as its first value, the game runs its default combat algorithm. The designer can additionally yield modified values for attackerDie, attackerPower, defenderDie and defenderPower (in this order) which will be used by the game for that round. In this case the coroutine resumes with the result of the round, a table containing four values:
- winner, this is either attacker or defender.
- attackerRoll, the result of the attacker's die roll
- defenderRoll, the result of the defender's die roll
- reroll, true if a reroll happened. 

This can happen only if the attacker is tribe 0, the defender is a unit guarding a city, and the city is the capital or the tribe has less than 8 cities in total and the attacker's die roll is higher than the defender's. A reroll can happen at most once.
]]
---@param code fun(attacker:unitObject, defender:unitObject, attackerDie:integer, attackerPower:integer, defenderDie:integer, defenderPower:integer, isSneakAttack:boolean):coroutine
function civ.scen.onInitiateCombat(code) end

---A coroutine is a line of execution, with its own stack and its own local variables; but sharing global variables and mostly anything else with other coroutines. Coroutines are collaborative: A program with coroutines is, at any given time, running only one of its coroutines and this running coroutine only suspends its execution when it explicitly requests to be suspended.
---
---[Programming in Lua, 9 -- Coroutines](https://www.lua.org/pil/9.html)
---
---[Tutorialspoint Lua -- Coroutines](https://www.tutorialspoint.com/lua/lua_coroutines.htm)
---@alias coroutine thread


---Thread is the name that Lua Language Server uses for a coroutine.  A coroutine is a line of execution, with its own stack and its own local variables; but sharing global variables and mostly anything else with other coroutines. Coroutines are collaborative: A program with coroutines is, at any given time, running only one of its coroutines and this running coroutine only suspends its execution when it explicitly requests to be suspended.
---
---[Programming in Lua, 9 -- Coroutines](https://www.lua.org/pil/9.html)
---
---[Tutorialspoint Lua -- Coroutines](https://www.tutorialspoint.com/lua/lua_coroutines.htm)
---@class thread

--[[
Registers a function to be called every time a key is pressed.
]]
---@param code function (keyCode:integer)
function civ.scen.onKeyPress(code) end


--[[
Registers a function that is called when the game is loaded.
]]
---@param code fun(savedData:string)
function civ.scen.onLoad(code) end


--[[
Registers a function that is called when two tribes attempt negotiations. `talker` is the tribe initiating the contact, `listener` the receiver. Return `true` to allow the negotiations to commence, `false` to deny.
]]
---@param code fun(talker:tribeObject, listener:tribeObject):(canTalk:boolean)
function civ.scen.onNegotiation(code) end


--[[
Registers a function to be called during every combat turn. The first parameter of the callback is the default resolution function, as implemented by the game. It takes the attacker and defender as parameters. You can call this to produce a result for cases you don't need to handle yourself.
Return `true` to continue combat, `false` to stop.

See onInitiateCombat for replacement.
]]
---@param code fun(defaultResolutionFunction:fun(defender:unitObject,attacker:unitObject):(combatContinues:boolean), defender:unitObject, attacker:unitObject):combatContinues:boolean
---@deprecated
function civ.scen.onResolveCombat(code) end



--[[
Registers a function that is called when the game is saved.
]]
---@param code fun():savedData:string
function civ.scen.onSave(code) end


--[[
Registers a function that is called when the scenario is loaded.  (This is whenever a game is loaded, not just when the scenario is started.)
]]
---@param code fun()
function civ.scen.onScenarioLoaded(code) end


--[[
Registers a function that is called when a schism is triggered. This happens when the capital of a AI-controlled tribe with more than four cities is captured, and, if the attacker is human-controlled, it is ranked lower in power than the defender. If the attacker is AI-controlled the best human tribe must be ranked lower than the defender for the schism to trigger.
If the schism is allowed, a new tribe will be created that takes over about half the cities of the old tribe. If no new tribe can be created, the schism does not occur.
Return `true` to allow the schism to happen, `false` to deny.
]]
---@param code fun(tribe:tribeObject):allowSchism:boolean
function civ.scen.onSchism(code) end

--[[
Registers a function that is called when a new music track is to be played. `track` is either nil or an integer. If nil, the game wants to play a random track, if not nil it's either due to the user choosing a track from the menu (first track has id 0), or the game playing one of it's special tracks ("Funeral March" - track id 0, and "Ode to Joy" - track id 1). To handle special tracks, you can return nil to signal that the game should play the default track associated with that track id. If you want to handle this track id, call civ.playMusic (this will check the Music folder of the scenario first before falling back to the global Music folder) and return an integer, which is used to synchronize the track list in the menu. The track names can be added in @PICKMUSICTOT in Game.txt.
]]
---@param code fun(track:integer|nil):integer|nil
function civ.scen.onSelectMusic(code) end


--[[
Registers a function that is called at the start of a tribe's turn. See `onTurn` for interaction with other "turn" triggers.
]]
---@param code fun(turn:integer, tribe:tribeObject)
function civ.scen.onTribeTurnBegin(code) end


--[[
Registers a function that is called at the end of a tribe's turn. See `onTurn` for interaction with other "turn" triggers.
]]
---@param code fun(turn:integer, tribe:tribeObject)
function civ.scen.onTribeTurnEnd(code) end


--[[
Registers a function that is called at the start of a turn. The basic sequence of this and other "turn" triggers is as follows:
<br>`onTurn` fires
<br>Non-tribe-specific updates take place
<br>`onTribeTurnBegin` fires for tribe 0.
<br>Tribe 0 cities are processed.
<br>`onCityProcessingComplete` fires for tribe 0 (this fires even when a tribe has no cities).
<br>Tribe 0 units move
<br>`onTribeTurnEnd` fires for tribe 0.
<br>All active tribes are processed in order according to the sequence for tribe 0
<br>`onTribeTurnEnd` fires for tribe 7.
<br>`onTurn` fires for the next turn
]]
---@param code fun(turn:integer)
function civ.scen.onTurn(code) end


--[[
Registers a function that is called whenever a unit is killed. `loser` is the unit that is killed, `winner` is the unit responsible for it.
]]
---@param code fun(loser:unitObject, winner:unitObject)
function civ.scen.onUnitKilled(code) end


--[[
Registers a function that is called when a nuclear weapon is used. This is also called when a spy plants a nuclear device in a city. `unit` is the weapon or the spy unit, `tile` is the location of the attack. Return `false` to abort the attack, `true` to proceed.
]]
---@param code fun(unit:unitObject, tile:tileObject):attackProceeds:boolean
function civ.scen.onUseNuclearWeapon(code) end

---
---@class civ.scen.params
---@field decisiveDefeat integer (get/set) Number of objectives required for a decisive defeat.
---@field decisiveVictory integer (get/set) Number of objectives required for a decisive victory.
---@field flags bitmask (get/set) Bitmask representing scenario flags:<br> <br>00000000 00000001 Total war <br>00000000 00000010 Use objective victory <br>00000000 00000100 Count wonders as objectives <br>00000000 00001000 Reveal cities <br>00000000 00010000 No government change <br>00000000 00100000 No tech conquest <br>00000000 01000000 No pollution <br>00000000 10000000 Terrain animation lockout <br>00000001 00000000 Unit animation lockout <br>00000010 00000000 .SPR file override <br>10000000 00000000 WWII AI
---@field marginalDefeat integer (get/set) Number of objectives required for a marginal defeat.
---@field marginalVictory integer (get/set) Number of objectives required for a marginal victory.
---@field maxTurns integer (get/set) Maximum number of turns before the scenario ends.
---@field name string (get/set) The name of the scenario.
---@field objectivesProtagonist tribeObject (get/set) Returns the objectives protagonist.
---@field startingYear integer (get) Returns the starting year of the scenario.
---@field techParadigm integer (get/set) Returns the tech paradigm used by the scenario. Non-scenario games use civ.cosmic.techParadigm instead of this value.
---@field yearIncrement integer (get/set) Returns the year increment (number of years per turn). Negative for monthly increments.
civ.scen.params = {}

---@class civ.scen.compatibility
---@field activateUnitEveryMove boolean If set to true, onActivateUnit will re-trigger for every tile the active unit moves. Defaults to false, in which case onActivateUnit triggers only once.  In the Lua Scenario Template, this is set to true in LuaParameterFiles\parameters.lua.
civ.scen.compatibility = {}




---


