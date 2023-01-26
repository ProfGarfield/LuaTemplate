
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--

local leaderBonus = require("leaderBonus"):minVersion(1)
local traits = require("traits")
local combatMod = require("combatModifiers")



--      Leader Bonuses and Tracking
--
--      This module keeps track of "leader" units and the units that are under the
--      command of a leader (receiving a leadership bonus).
--      This module also provides automatic combat bonuses using combatModifiers
--
--
--
--
--  leaderClass = {
--
--      rank = string (not "")
--          The tile/name of the leader class
--          e.g. "Napoleon", "General"
--      seniority = number
--          If a unit could be under the leadership of multiple
--          leaders, the leader with lower seniority is chosen.
--          If two potential leaders have the same seniority,
--          the unit with smaller id number is chosen
--      subordinates = unitType or trait or table of unitTypes and traits
--          Units of these types/traits can be commanded by this
--          class of leader
--      alwaysLeaderType = nil or unitType or trait or table of unitTypes and traits
--          Units of these types/traits ALWAYS have this leader class
--          if nil, no unit types are this leader class by default
--          If a trait is used here, it must not be assigned as a conditional trait
--          to any unit type
--      unitInitialization = nil or integer or table of integers
--          bestows this leader class on the units corresponding to these
--          id numbers when either of these functions are called
--              leaderBonus.initializeLeaders()
--              console.initializeLeaders()
--          Any unit with an id not in an initialization table
--          (and not a unitType that is always a leader class)
--          will have its leader class removed
--      attackModifier = nil or number or combatModifier
--          if nil, this leader provides no bonus when its
--          subordinates attack (unless you program that elsewhere)
--          if number, multiply the unit's attack by this value
--          if combatModifier, an attacking unit subordinate to this leader
--          gains benefit of the combat modifier (provided all other
--          conditions are also met)
--
--      defenseModifier = nil or number or combatModifier
--          if nil, this leader provides no bonus when its subordinates
--          defend (unless you program that elsewhere)
--          if number, multiply the unit's defense by this value
--          if combatModifier, a defending unit subordinate to this
--          leader class gains benefit of the combat modifier
--          (provided all other conditions are also met)
--
--      responsibilityRadius = number
--          units become subordinate to this leader within this
--          many tiles (provided there is not a more senior
--          leader) 0 means only units sharing the leader's
--          tile become subordinate
--          nil means 0
--
--      subordinationRadius = nil or number
--          units remain subordinate to this leader within this
--          many tiles, even if they leave the responsibility
--          radius of the leader (unless they come under the
--          responsibilityRadius of a more senior leader).
--          if nil, subordinationRadius is the same as the
--          responsibilityRadius
--
--      allMapCommand = boolean
--          if true, this leader can command units on all
--          maps (within appropriate radii)
--          if false or nil, the leader can only command
--          units on its own map
--

-- Combat Modifier Documentation

    -- Register a rule to modify combat
    -- combatMod.registerCombatModificationRule(combatModifier)
    --  registers a rule to modify combat
    --  see below for the specifications for a combatModifier table
    
    --      combatSpec = table{
    --      Note: all keys can be nil, in which case there is no modification
    --
    --          aCustomAdd = number -- add this to attack before multipliers are applied (negative number to subtract)
    --          dCustomAdd = number-- add this to defense before multipliers are applied (negative number to subract)
    --          aCustomMult = number-- multiply the attacker's strength by this much (to supply a custom bonus or penalty)
    --          dCustomMult = number-- multiply the defender's strength by this much (to supply a custom bonus or penalty)
    --          aAddFirepower = number -- add this to the attacker's firepower before any other calculations (negative number to subtract)
    --          dAddFirepower = number -- add this to the defender's firepower before any other calculations (negative number to subtract)
    --              If multiple combatSpec are applied, all aCustomAdd and dCustomAdd are summed together.
    --              These are applied before multiplicative bonuses/penalties
    --              If aCustomAdd reduces an attack value below 1, the attack will be set to 1
    --              If dCustomAdd reduces a defense value below 0, the value will be set to 0
    --
    --              If multiple combatSpec are applied, all aAddFirepower and dAddFirepower are summed together.
    --              These are applied before shore bombardment/caught in port etc. bonuses/penalties
    --              If firepower modifications would reduce a unit's firepower below 1, it is set to 1
    --
    --          aAdd_~~~~
    --          dAdd_~~~~
    --          aMult_~~~~
    --          dMult_~~~~
    --              This group of keys can be any string, as long as they start with aAdd_, dAdd_, aMult_, dMult_
    --              (i.e. ~~~~ is replaced by at least one character)
    --              In each category, the largest buff (aAdd_, dAdd_ > 0; aMult_,dMult_ > 1) and 
    --              debuff (aAdd_, dAdd_ < 0; aMult_,dMult_ < 1) among all applied combatSpecs in that
    --              category are applied, with all others ignored.  E.g. with these combatSpecs:
    --              aAdd_Many = -1,-2,-0.5,1,2,3
    --              aAdd_Few = -2.5,1, 0.5
    --              aAdd_Many -> 3 (max buff), -2 (max debuff)
    --              aAdd_Few -> -2.5 (only debuff), 1 (max buff)
    --              --> 3 - 2 - 2.5 + 1 = -0.5
    --              -0.5 is added to aCustomAdd total
    --              aMult_Some = 2.5, 1.25,0.75,0.33
    --              aMult_Some -> 2.5 (max buff), 0.33 (max debuff)
    --              --> 2.5*.33 = 0.825
    --              -->0.825 is multiplied with aCustomMult
    --              
    --
    --          [terrainIndex (integer)] = number
    --              terrainIndex is 3*16*terrain.map+3*terrain.type+terrain.resource
    --              if the number is specified, that terrain's defense multiplier is substituted for this one
    --              (e.g. 1.5 is equivlalent to a defense value set to 3 in the rules, since 3/2=1.5)
    --              Note: if any applied combatSpec uses dBaseTerrainCheck = false, no defense bonus is applied
    --              regardless of the keys in this section
    --              (except possibly river)
    --              if multiple combatSpec are applied, 
    --                  take the largest buff and largest debuff (additive), and applies both.
    --                  e.g. hills, default value 4 -> x2 defense
    --                  attempted overrides: 1,1.5, 2, 2.5, 3.5 
    --                  buffs are 2.5, 3.5 (since larger than 2) -> +0.5, +1.5 -> largest buff: +1.5
    --                  debuffs are 1, 1.5 (since smaller than 2) -> -1, -0.5 --> largest debuff: -1
    --                  resulting override: -1+1.5 = 0.5 -> 2+0.5 = 2.5 
    --
    --          [terrainOrBaseTerrain] = number
    --              assigning with terrain can be used in place of the terrainIndex integer
    --              if key is baseTerrain, it counts as all 3 terrain types with that baseTerrain
    --              (baseTerrain can only be used to assign values, not to get them)
    --              when initially creating the combatSpec, baseTerrain are assigned first, then
    --              the terrain is assigned.  After creation, baseTerrain will overwrite all 3
    --              corresponding terrain indices
    --
    --              Note: during creation, terrain and baseTerrain keys in the supplied table overwrite
    --              values supplied as terrain indices
    --
    --          aModifierName = number/bool (depending on modifier)
    --          dModifierName = number/bool (depending on modifier)
    --              if not nil, overrides the regular value for the combat modifer
    --              if multiple combatSpec are applied, and the modifier is a boolean,
    --                  the modifiers will all have to be false, so there is no conflict
    --              if multiple combatSpec are applied, and the modifier is a number
    --                  take the largest buff and largest debuff (additive), and applies both.
    --                  e.g. dCityWalls, default value 3
    --                  attempted overrides: 1, 2, 2.5, 3.5, 4
    --                  buffs are 3.5,4 (since larger than 3) -> +0.5, +1 -> largest buff: +1
    --                  debuffs are 1, 2, 2.5 (since smaller than 3) -> -2, -1, -0.5 --> largest debuff: -2
    --                  resulting override: -2+1 = -1 -> 3-1 = 2 -> dCityWalls = 2
    --
    --              This is the list:
    --[[
                    Modifiers that can be disabled by setting their value to "1" (the numeric value, without quotes):
                    	aVeteran
                    	aPartisans
                    	aParadrop
                    	aSneakAttack
                    	aEasiestLevelHumanAttacker
                    	aEasyLevelsHumanDefender
                    	aBarbarianAttackerVsHumanDefender
                    	aBarbarianAttackerVsAiDefender
                    	aBarbarianAttackerVsDefendersOnlyCity
                    	aBarbarianAttackerVsDefendersCapitalCity
                    	aBarbarianAttackerVsDefenderWithGreatWall
                    	aGreatWallVsBarbarianDefender
                    	aFirepowerCaughtInPort
                    	dVeteran
                    	dScramblingFighterVsBomber
                    	dScramblingFighterVsFighter
                    	dHelicopter
                    	dCityWalls
                    	dFortress
                    	dFortified
                    	dPikemenFlag
                    	dAegisFlagVsMissile
                    	dAegisFlagVsOtherAir
                    	dSdiDefenseVsMissile
                    	dSamMissileBattery
                    	dCoastalFortress
                    	dBarbarianDefenderArchers
                    	dBarbarianDefenderLegion
                    
                    Modifiers that can be disabled by setting their value to "false" (the boolean value, without quotes):
                    	aMovesRemainingCheck
                    	aFirepowerShoreBombardmentCheck
                    	dBaseTerrainCheck
                    	dFirepowerHelicopterCheck
                    	dFirepowerShoreBombardmentCheck
                    	dFirepowerCaughtInPortCheck
                    	dFirepowerSubmarineFlagCheck
                    
                    Modifiers that can be disabled by setting their value to "0" (the numeric value, without quotes):
                    	dRiverAddition
    ]]
    --          aModifier_~~~~
    --          dModifier_~~~~
    --          aOverride_~~~~
    --          dOverride_~~~~
    --              Keys that begin with aModifier_ or dModifier_ exist to represent combat modifiers
    --              like the ones built into the game (dCityWalls,dPikemenFlag, etc.)
    --              This program assumes that all such modifiers with the same name have the same value
    --              So you can, for example, have 2 instances of aModifier_CavalryCharge to represent
    --              different situations when the CavalryCharge bonus applies, but they should both give
    --              the same bonus
    --              Keys that begin with aOverride_ or dOverride_ will change the effects of the corresponding
    --              aModifier_ and dModifier_ keys in the same way that aModifierName and dModifierName work above
    
    -- combatModifier = {
    --  attacker = nil or traitString or unitType or table of traitString/unitType
    --      if nil, modifier applies to all attackers
    --      if traitString, the modifier applies if the attacker has the trait
    --      if unitType, the modifier applies if the attacker is of that unitType
    --      if table, any trait or unitType is allowed
    --  attackerDetail = nil or traitString or baseTerrain, or terrain, or cityImprovement, or tribe, or wonder, or table of these
    --      if nil, modifier applies to all attackers
    --      if terrain/baseTerrain, modifier applies if the attacker is on that kind of tile
    --      if cityImprovement, modifier applies if the attacker is on a city tile, and the city has that improvement
    --          (or, has a non-expired wonder providing that improvement)
    --      if tribe, modifier applies if the attacker is of that tribe
    --      if tech, modifier applies if the attacker has that tech
    --      if wonder, modifier applies if the wonder is owned by the tribe as long as it is not expired
    --      if unitType, modifier applies if the tile is shared with a unit of this type
    --      if traitString, the modifer applies if the terrain, baseTerrain, tribe, owned Tech, owned wonder, any city improvement, or any unit on tile has that trait
    --          NOTE: if the trait is for a wonder, it applies even if the wonder is expired
    --          (You can use a conditional trait to get around that.)
    --      if table, any entry is valid
    --  defender = nil or traitString or unitType or table of traitString/unitType
    --      if nil, modifier applies to all defenders
    --      if traitString, the modifier applies if the defender has the trait
    --      if unitType, the modifier applies if the defender is of that unitType
    --      if table, any trait or unitType is allowed
    --  defenderDetail = nil or traitString or baseTerrain, or terrain, tribe, or cityImprovement or table of these
    --      if nil, modifier applies to all defenders
    --      if terrain/baseTerrain, modifier applies if the defender is on that kind of tile
    --      if cityImprovement, modifier applies if the defender is on a city tile, and the city has that improvement
    --          (or, has a non-expired wonder providing that improvement)
    --      if tribe, modifier applies if the defender is of that particular tribe
    --      if tech, modifier applies if the defender has that tech
    --      if wonder, modifier applies if the tribe owns that wonder as long as it is not expired
    --      if unitType, modifier applies if the tile is shared with a unit of this type
    --      if traitString, the modifer applies if the terrain, baseTerrain, tribe, owned Tech, owned wonder, any city improvement, or any unit on tile has that trait
    --          NOTE: if the trait is for a wonder, it applies even if the wonder is expired
    --          (You can use a conditional trait to get around that.)
    --      if table, any entry is valid
    --  customCheck = nil or function(attacker,defender) --> boolean
    --      if nil, modifier applies if above specifications are valid
    --      if function, modifier applies if the function returns true, and false if it does not
    --
    --  combatSpec = combatSpec or nil
    --      the combatSpec to apply to combat if all the checks are true
    --      if nil, it counts as an empty table
    --      
    --  combatSpecKey = combatSpecValue
    --      adds combatSpeck key and value specified to the combatSpec provided, overriding
    --      the value for the key if applicable
    
    
    --  this is the behind the scenes combatModifier
    -- internalCombatModifier = {
    --  attackerUnitTypeID = nil or {[unitTypeID] = true}
    --  attackerTraits = nil or table of traits
    --      if both are nil, any attacker can get this bonus
    --      if the attacker's unitTypeID is in the attackerUnitTypeID table, it can get the bonus
    --      if the attacker has a trait in attackerTraits, it can get the bonus
    --  attackerDetailItems = nil or {[item]=function(unit,item)-->boolean}
    --      item can be terrain,baseTerrain,cityImprovement,tribe,tech
    --      function checks if the detail is satisfied
    --  attackerDetailTraits = nil or table of traits
    --  defenderUnitTypeID = nil or {[unitTypeID] = true}
    --  defenderTraits = nil or table of traits
    --      if both are nil, any defender can get this bonus
    --      if the defender's unitTypeID is in the defenderUnitTypeID table, it can get the bonus
    --      if the defender has a trait in defenderTraits, it can get the bonus
    --  defenderDetailItems = nil or {[item]=function(unit,item)-->boolean}
    --      item can be terrain,baseTerrain,cityImprovement,tribe,tech
    --      function checks if the detail is satisfied
    --  defenderDetailTraits = nil or table of traits
    --  customCheck = nil or function(attacker,defender) --> boolean
    --      if nil, modifier applies if other specifications are met
    --      if function, modifier only applies if function returns true (and other modifications are met)
    --
    --  combatSpec = combatSpec
    --      the combatSpec that applies if the conditions are true
    --
    --


--      Useful Leader Bonus Functions
--
--
-- leaderBonus.getCommanderRank(unit) -> string or false
-- if unit is subordinate to a leader class, return the leader's rank
-- otherwise, return false

-- leaderBonus.getRank(unit) --> string or false
--  if the unit has a leadership rank, return the name
--  of that rank.  Return false otherwise
--
--
-- leaderBonus.registerLeaderClass(leaderClass)
--  registers the leader class (can just be a table)
--
--  leaderBonus.newLeaderClass(leaderClassSpecs) --> leaderClass
--      creates a new leaderClass
--
--  leaderBonus.isLeaderClass(item) --> boolean
--
--
-- leaderBonus.makeSubordinate(unit,leaderUnit)
--      makes the unit subordinate to the leaderUnit, if the leaderUnit
--      if the leader unit has a rank and the unit can be subordinate
--      to that rank
--
-- leaderBonus.commissionLeader(unit,rank,noErrorIfFailure=false)
--      bestows the unit with the leader class corresponding to rank
--      if the unitType can't be made this leader (because it is an alwaysLeaderType),
--      an error is thrown, unless noErrorIfFailure is set to true, in which
--      case, nothing is done
--
-- leaderBonus.dismissLeader(unit,noErrorIfFailure=false)
--      removes the leaderClass (if any exists) from the unit
--      if the unit's type can't have leadership removed,
--      (because it is an alwaysLeaderType), an error will be
--      thrown, unless noErrorIfFailure is set to true
--
-- leaderBonus.changeRank(unit,newRank)
--      changes the rank of the leader, updates all subordinates to be commanded
--      by the new rank, then updates all nearby units in case leadership changes

-- leaderBonus.firstOutranksSecond(firstLeader,secondLeader) --> boolean
--      returns true if the firstLeader (unit) outranks the secondLeader (unit)
--      outrank means leaderClass.seniority is lower (or if they are equal, unitID is lower)
--      firstLeader must always be a unit, return false if firstLeader has no rank
--      secondLeader can be false/nil, if so, return true (provided firstLeader has a rank)
--      if secondLeader is a unit, it must have a rank
--
-- leaderBonus.updateCommander(unit)
--      checks if the unit's current commander can remain in command
--      and searches nearby for a higher ranking commander
--
-- leaderBonus.transferSubordination(unit,originalLeader,newLeader)
--      if the unit is subordinate to the original leader, make
--      it subordinate to the newLeader
--      if the unit is not subordinate to the original leader, do nothing

--  leaderBonus.initializeLeaders()
--  console.initializeLeaders()
--      uses the information in leaderClass.alwaysLeaderType and leaderClass.unitInitialization
--      to commission units as leaders

local gen = require("generalLibrary"):minVersion(4)
local object = require("object")
local traits = require("traits")

--[[
traits.allowedTraits("fighter","bomber","warship")
traits.assign({gen.original.uFighter, gen.original.uStlthFtr},"fighter")
traits.assign({gen.original.uBomber, gen.original.uStlthBmbr},"bomber")
traits.assign({gen.original.uDestroyer, gen.original.uCruiser, gen.original.uAEGISCruiser, 
        gen.original.uBattleship, gen.original.uCarrier},"warship")
        --]]

        --[[

leaderBonus.registerLeaderClass({
    rank = "Vice-Admiral",
    seniority = 2,
    subordinates = {"fighter","bomber",gen.original.uHelicopter},
    alwaysLeaderType = gen.original.uCarrier,
    attackModifier = 1.5,
    responsibilityRadius = 0,
    subordinationRadius = 5,
    allMapCommand = true,
})
leaderBonus.registerLeaderClass({
    rank = "Admiral",
    seniority = 1,
    subordinates = {"warship",gen.original.uHelicopter},
    alwaysLeaderType = gen.original.uBattleship,
    attackModifier = {
        attackerDetail = civ.getBaseTerrain(0,10),
        aCustomMult = 1.5,
    },
    defenseModifier = 3,
    responsibilityRadius = 1,
    subordinationRadius = 1,
    allMapCommand = true,
})

leaderBonus.registerLeaderClass({
    rank = "Captain",
    seniority = 3,
    subordinates = "warship",
    attackModifier = 1.25,
    unitInitialization = 13
})

--]]





local register = {}
gen.versionFunctions(register,versionNumber,fileModified,"MechanicsFiles".."\\".."leaderBonusSettings.lua")
return register
