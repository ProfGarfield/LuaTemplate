
---@meta
---

--  -@alias patchTable {MouseWheel: boolean, DefenseBonus: boolean, TransformTech: boolean, ShieldColors: boolean, TerrainTypes: boolean, TradeRevenue: boolean, LuaScenario: boolean, FixEditControl: boolean, CityView: boolean, TransformCheck: boolean, ShipDisband: boolean, DirectShowAudio: boolean, CityWorkingTiles: boolean, EventHeap: boolean, ImprovementIcons: boolean, CityPopulationLoss: boolean, UnitOrientation: boolean, AcivateUnitScrollbar: boolean, MapLayout: boolean, ModifyReputation: boolean, CustomResources: boolean, Mutex: boolean, FixHostility: boolean, DiplomacyScreenCrash: boolean, ImpassableAir: boolean, Fertility: boolean, ResetCityName: boolean, Units: boolean, Cosmic: boolean, ZoomLevel: boolean, DecreaseCPUUse: boolean, RoadTrade: boolean, GlobalWarming: boolean, DebugScripts: boolean, UnitIndicators: boolean, TerrainOverlays: boolean, LuaScripting: boolean, EndPlayerTurn: boolean, Techs: boolean, SettlerFlags: boolean, Difficulty: boolean, MoveUnitEvent: boolean, Overview: boolean, Reporting: boolean, NoLimits: boolean, Playable: boolean, CombatAnimation: boolean, TakeTechnology: boolean, AITweaks: boolean, CivilopediaWonderGraphics: boolean, StealTech: boolean, NativeTransport: boolean, NavigableRivers: boolean, BuildTransporter: boolean, Mods: boolean, DirectShowMusic: boolean, DirectShowVideo: boolean, CitySprites: boolean, AttacksPerTurn: boolean, ProductionCarryOver: boolean, RRMultiplier: boolean, NoStackKills: boolean, LWSettings: boolean, CityUnitLimits: boolean, Landmarks: boolean, ImprovementFlags: boolean, MovementRate: boolean, SaveExt: boolean, EditTerrainKeys: boolean, TeleporterMapCheck: boolean, Throneroom: boolean, Movedebug: boolean, NoCD: boolean, CityWinUnitDisband: boolean, RushBuy: boolean, PikemenFlag: boolean, MajorObjective: boolean, CityWinUnitSelect: boolean, ResourceAnimationLoop: boolean, TOTPPConfig: boolean, CustomModResources: boolean, DisabledButton: boolean, HealthBars: boolean}

---@class totpp.patches
---@field Throneroom boolean 
---@field SaveExt boolean 
---@field ResourceAnimationLoop boolean 
---@field StealTech boolean 
---@field CombatAnimation boolean 
---@field TerrainOverlays boolean 
---@field BuildTransporter boolean 
---@field Units boolean 
---@field Difficulty boolean 
---@field MajorObjective boolean 
---@field CityWinUnitDisband boolean 
---@field NativeTransport boolean 
---@field HealthBars boolean 
---@field TradeRevenue boolean 
---@field CustomResources boolean 
---@field SettlerFlags boolean 
---@field ShipDisband boolean 
---@field Reporting boolean 
---@field ZoomLevel boolean 
---@field DefenseBonus boolean 
---@field NavigableRivers boolean 
---@field RoadTrade boolean 
---@field FixHostility boolean 
---@field Techs boolean 
---@field TeleporterMapCheck boolean 
---@field AcivateUnitScrollbar boolean 
---@field GlobalWarming boolean 
---@field MoveUnitEvent boolean 
---@field CityView boolean 
---@field LWSettings boolean 
---@field DebugScripts boolean 
---@field EndPlayerTurn boolean 
---@field Fertility boolean 
---@field Overview boolean 
---@field ProductionCarryOver boolean 
---@field DecreaseCPUUse boolean 
---@field DirectShowVideo boolean 
---@field Movedebug boolean 
---@field TOTPPConfig boolean 
---@field EditTerrainKeys boolean 
---@field Mutex boolean 
---@field PikemenFlag boolean 
---@field AttacksPerTurn boolean 
---@field CityWorkingTiles boolean 
---@field Mods boolean 
---@field LuaScripting boolean 
---@field Playable boolean 
---@field AITweaks boolean 
---@field Landmarks boolean 
---@field Cosmic boolean 
---@field CustomModResources boolean 
---@field UnitIndicators boolean 
---@field MapLayout boolean 
---@field MouseWheel boolean 
---@field ImprovementIcons boolean 
---@field CityUnitLimits boolean 
---@field CitySprites boolean 
---@field UnitOrientation boolean 
---@field TerrainTypes boolean 
---@field TransformTech boolean 
---@field DirectShowAudio boolean 
---@field ModifyReputation boolean 
---@field TakeTechnology boolean 
---@field CivilopediaWonderGraphics boolean 
---@field MovementRate boolean 
---@field RRMultiplier boolean 
---@field NoStackKills boolean 
---@field RushBuy boolean 
---@field DisabledButton boolean 
---@field DiplomacyScreenCrash boolean 
---@field ImprovementFlags boolean 
---@field EventHeap boolean 
---@field FixEditControl boolean 
---@field NoLimits boolean 
---@field DirectShowMusic boolean 
---@field CityPopulationLoss boolean 
---@field ResetCityName boolean 
---@field ImpassableAir boolean 
---@field TransformCheck boolean 
---@field NoCD boolean 
---@field LuaScenario boolean 
---@field CityWinUnitSelect boolean 
---@field ShieldColors boolean 

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

