
---@meta
---

--  -@alias patchTable {MouseWheel: boolean, DefenseBonus: boolean, TransformTech: boolean, ShieldColors: boolean, TerrainTypes: boolean, TradeRevenue: boolean, LuaScenario: boolean, FixEditControl: boolean, CityView: boolean, TransformCheck: boolean, ShipDisband: boolean, DirectShowAudio: boolean, CityWorkingTiles: boolean, EventHeap: boolean, ImprovementIcons: boolean, CityPopulationLoss: boolean, UnitOrientation: boolean, AcivateUnitScrollbar: boolean, MapLayout: boolean, ModifyReputation: boolean, CustomResources: boolean, Mutex: boolean, FixHostility: boolean, DiplomacyScreenCrash: boolean, ImpassableAir: boolean, Fertility: boolean, ResetCityName: boolean, Units: boolean, Cosmic: boolean, ZoomLevel: boolean, DecreaseCPUUse: boolean, RoadTrade: boolean, GlobalWarming: boolean, DebugScripts: boolean, UnitIndicators: boolean, TerrainOverlays: boolean, LuaScripting: boolean, EndPlayerTurn: boolean, Techs: boolean, SettlerFlags: boolean, Difficulty: boolean, MoveUnitEvent: boolean, Overview: boolean, Reporting: boolean, NoLimits: boolean, Playable: boolean, CombatAnimation: boolean, TakeTechnology: boolean, AITweaks: boolean, CivilopediaWonderGraphics: boolean, StealTech: boolean, NativeTransport: boolean, NavigableRivers: boolean, BuildTransporter: boolean, Mods: boolean, DirectShowMusic: boolean, DirectShowVideo: boolean, CitySprites: boolean, AttacksPerTurn: boolean, ProductionCarryOver: boolean, RRMultiplier: boolean, NoStackKills: boolean, LWSettings: boolean, CityUnitLimits: boolean, Landmarks: boolean, ImprovementFlags: boolean, MovementRate: boolean, SaveExt: boolean, EditTerrainKeys: boolean, TeleporterMapCheck: boolean, Throneroom: boolean, Movedebug: boolean, NoCD: boolean, CityWinUnitDisband: boolean, RushBuy: boolean, PikemenFlag: boolean, MajorObjective: boolean, CityWinUnitSelect: boolean, ResourceAnimationLoop: boolean, TOTPPConfig: boolean, CustomModResources: boolean, DisabledButton: boolean, HealthBars: boolean}

---@class totpp.patches
---@field Throneroom boolean # Enables building of throne room improvements. This feature was never removed from ToT, just disabled. The patch also adds a new menu item to the game settings. <br>The associated key bindings are Shift-H to view the throne room, and Shift-Q as a unit order to build an improvement (cheat-mode only).<br><br>The text of the menu item ("Enable throne room.") can be overridden by adding a line to @GAMEOPTIONS in GAME.TXT.
---@field SaveExt boolean # Allows patches to store arbitrary data in the saved game file, by extending the format. Saved games with extensions are stored with version number '3' (ToT 1.1 uses '2'), so they cannot be read by the vanilla game.<br><br>Purely infrastructural, this patch does not modify anything visible in the game by itself, but makes extension data available to other patches.<br><br>Technical details:<br>Extension information is stored towards the end of the file (right after the 'Destroyed tribes' block, but before multiplayer / event data).<br>The first 4 bytes are the number of extensions, followed by that many extension blocks.<br>An extension consists of 3 parts, length (4 bytes), extension name (4 bytes, ASCII), and extension data ('length' bytes).
---@field ResourceAnimationLoop boolean # Fixes a bug where the last frame of a looping resource animation would be rendered even when animated resources were disabled.
---@field StealTech boolean # Fixes the rule 2 restrictions in @LEADERS2 so that forbidden technologies cannot be stolen.
---@field CombatAnimation boolean  #  Enables the 8-frame combat animation from Icons.bmp when animated units are disabled. For an example and placement see the 8 frames in Icons.gif in the ToT root folder, starting from coordinates (1, 356).
---@field TerrainOverlays boolean  # Enables custom overlays from TERRAIN2.bmp for arbitrary terrain types.<br><br>Overlays are configured with a new section @OVERLAYS in RULES.txt. This section consists of a list of terrain types followed by 3 numbers, e.g.:<br><br>@OVERLAYS<br>Forest, 16, 32, 133<br>Hills, 16, 32, 297<br>Mountains, 16, 48, 199<br>Boreal Forest, 16, 48, 363<br>Jungle, 3, 48, 461<br><br>- For the terrain type you can either use its ordinal index (0-15), the abbreviation used in @TERRAIN (Drt, Pln, etc.), or the full name as in this example.<br>- The first number is the number of tiles to read, either 1, 3 or 16. When 16, tiles are read in 2 rows of 8, similar to the original overlays. When 1 or 3, tiles are read from a single row.<br>The use for the 3-tile overlay is to prevent the dithering used between different terrain types to render on top of the tile. These tiles correspond to the three tiles in TERRAIN1.bmp.<br>- The second number is the height of the tiles, 32, 48 or 64.<br>- The third number is the y-coordinate in TERRAIN2.bmp from where to start reading the tiles. The starting x-coordinate is always 1.<br><br>Notes:<br>- Tiles are expected to be separated from each other by a one-pixel border.<br>- River tiles are always read from their original position of (1, 67). River mouths and coastal tiles shift down, they are read from right below the bottommost overlay.<br>- In the absence of an @OVERLAYS section, overlays are defined to correspond to a default TERRAIN2.bmp file.<br>- This patch replaces the mountain height patch, but respects the "MountainHeight" key in COSMIC2 for compatibility when no overlays are defined.<br>- @OVERLAYS1 .. @OVERLAYS3 can be used for secondary maps, similarly to @TERRAIN1-3.
---@field BuildTransporter boolean  #  Makes the build transporter map dialog not select invalid maps as the default option, and also fixes the check for invalid art types.
---@field Units boolean  #  
---@field Difficulty boolean  #  Fixes the crash for difficulty levels above Deity, and accepts an unlimited number of difficulties in the @DIFFICULTY section of RULES.TXT. In practice though, the limit is around 10, as very high levels will cause AI food / shield rows to go negative.
---@field MajorObjective boolean  #  Restores the x3 major objective for cities as in Fantastic Worlds.
---@field CityWinUnitDisband boolean  #  Disables the "Disband" option in the city screen's "Supported units" box for non-disbandable units.
---@field NativeTransport boolean  #  Makes native transport respect "not allowed on map" settings from @UNITS_ADVANCED.
---@field HealthBars boolean  #  Allows hiding of unit health bars for specific unit types, by setting the 16th bit of the flags in @UNITS (i.e. by adding a 1 on the left).
---@field TradeRevenue boolean  #  Enables the @COSMIC2 keys 'TradeGoldMultiplier', 'TradeScienceMultiplier' and 'TradeWonderMultiplier'.<br><br>For the first two, their value is a percentage applied to the gold/science revenue when a trade route is created. So at 50, revenues are halved. For 'TradeWonderMultiplier' it's a percentage of the cost of the trade unit that will be added to the wonder under construction, if the respective option is selected. Defaults to 100.
---@field CustomResources boolean  #  Adds support for maps with custom resource placement. Maps both with and without custom resources can be combined when loading maps in-game.<br>Saved games with custom-resource maps are incompatible with the vanilla game.<br>When loading a custom-resource map, the dialog that asks whether to randomize resources and huts will only randomize huts.<br><br>In cheat mode, custom resources can be enabled/disabled for a map by pressing Ctrl-F8. Subsequently, they can be placed on tiles with Ctrl-1 (resource #1) and Ctrl-2 (resource #2). Ctrl-0 removes a resource from a tile.
---@field SettlerFlags boolean  #  
---@field ShipDisband boolean  #  
---@field Reporting boolean  #  
---@field ZoomLevel boolean  #  
---@field DefenseBonus boolean  #  
---@field NavigableRivers boolean  #  
---@field RoadTrade boolean  #  
---@field FixHostility boolean  #  
---@field Techs boolean  #  
---@field TeleporterMapCheck boolean  #  
---@field AcivateUnitScrollbar boolean  #  
---@field GlobalWarming boolean  #  
---@field MoveUnitEvent boolean  #  
---@field CityView boolean  #  
---@field LWSettings boolean  #  
---@field DebugScripts boolean  #  
---@field EndPlayerTurn boolean  #  
---@field Fertility boolean  #  
---@field Overview boolean  #  
---@field ProductionCarryOver boolean  #  
---@field DecreaseCPUUse boolean  #  
---@field DirectShowVideo boolean  #  
---@field Movedebug boolean  #  
---@field TOTPPConfig boolean  #  
---@field EditTerrainKeys boolean  #  
---@field Mutex boolean  #  
---@field PikemenFlag boolean  #  
---@field AttacksPerTurn boolean # Enables a new section in RULES.TXT, @ATTACKS.<br>The numbers in this section define the number of attacks per turn per unit type. The section itself consist of a list of numbers, 10 per line, corresponding in order to the entries in @UNITS. For the Original game, it would look like this:<br><br>@ATTACKS<br>1, 2, 1, 1, 1, 1, 1, 1, 1, 1,<br>1, 1, 1, 1, 3, 2, 2, 2, 2, 2,<br>2, 2, 3, 1, 1, 1, 2, 10, 8, 6,<br>14, 12, 3, 3, 4, 4, 4, 6, 5, 5,<br>4, 3, 5, 5, 12, 16, 2, 3, 1, 2,<br>1, 1, 4, 8, 1, 1, 1, 1, 1, 1,<br>1, 1, 1, 1, 1, 1, 1, 1, 1, 1,<br>1, 1, 1, 1, 1, 1, 1, 1, 1, 1,<br><br>The number of attacks is limited by the movement rate, as each attack still costs 1 movement point.<br><br>The popup shown when a unit is out of attacks can be overridden in GAME.TXT using the key @ATTACKSPERTURN.   
---@field CityWorkingTiles boolean  #  
---@field Mods boolean  #  
---@field LuaScripting boolean  #  
---@field Playable boolean  #  
---@field AITweaks boolean  #  
---@field Landmarks boolean  #  
---@field Cosmic boolean  #  
---@field CustomModResources boolean  #  
---@field UnitIndicators boolean  #  
---@field MapLayout boolean  #  
---@field MouseWheel boolean  #  
---@field ImprovementIcons boolean  #  
---@field CityUnitLimits boolean  #  
---@field CitySprites boolean  #  
---@field UnitOrientation boolean  #  
---@field TerrainTypes boolean  #  
---@field TransformTech boolean  #  
---@field DirectShowAudio boolean  #  
---@field ModifyReputation boolean  #  
---@field TakeTechnology boolean  #  
---@field CivilopediaWonderGraphics boolean  #  
---@field MovementRate boolean  #  
---@field RRMultiplier boolean  #  
---@field NoStackKills boolean  #  
---@field RushBuy boolean  #  
---@field DisabledButton boolean  #  
---@field DiplomacyScreenCrash boolean  #  
---@field ImprovementFlags boolean  #  
---@field EventHeap boolean  #  
---@field FixEditControl boolean  #  
---@field NoLimits boolean  #  
---@field DirectShowMusic boolean  #  
---@field CityPopulationLoss boolean  #  
---@field ResetCityName boolean  #  
---@field ImpassableAir boolean  #  
---@field TransformCheck boolean  #  
---@field NoCD boolean  #  
---@field LuaScenario boolean  #  
---@field CityWinUnitSelect boolean  #  
---@field ShieldColors boolean  #  

---@class totpp
---@field version totpp.version
---@field movementMultipliers totpp.movementMultipliers
---@field mod totpp.mod
---@field patches totpp.patches (get) Returns a table with the enabled status for all patches. The string keys are the same as the ones used in TOTPP.ini
---@field roadTrade table<id|mapObject,bitmask> (get/set - ephemeral) totpp.roadTrade[map] -> bitmask <br> Returns a bitmask with the terrain types that receive an initial trade arrow when a road is built. Provided by the Initial trade arrow for roads patch.
totpp = {}

---
---@class totpp.version
---@field major integer (get) Returns the major version of the TOTPP dll.
---@field minor integer (get) Returns the minor version of the TOTPP dll.
---@field patch integer (get) Returns the patch version of the TOTPP dll.
totpp.version = {}

---
---@class totpp.movementMultipliers
---@field aggregate integer (get) Returns the aggregate movement multiplier (the lcm of the four multipliers above). This value is recalculated when setting any of the individual multipliers. This is an alias for `civ.cosmic.roadMultiplier`.
---@field alpine integer|nil (get/set - ephemeral) Returns the alpine movement multiplier if it is set, `nil` otherwise.
---@field railroad integer|nil (get/set - ephemeral) Returns the railroad movement multiplier if it is set, `nil` otherwise.
---@field river integer|nil (get/set - ephemeral) Returns the river movement multiplier if it is set, `nil` otherwise.
---@field road integer|nil (get/set - ephemeral) Returns the road movement multiplier if it is set, `nil` otherwise.
totpp.movementMultipliers = {}


---
---@class totpp.mod
---@field premadeMap boolean (get) Returns `true` if the game was started on a pre-made map, `false` otherwise. Only valid right after starting a new game.
totpp.mod = {}

