local traits = require("traits")
local combatMod = {version = 1}

-- modification string has the following structure:
-- first char: +,*,-,=,~
-- remainder: number, number with percent, modificationName
-- Meaning and computation order
--      ~modificationName
--          ignore the modification associated with modificationName
--      ^
--



-- consider the attacking unit's type, tribe, tribe's techs, tribe's wonders
-- the improvements of the city the attacker is in, the terrain the attacker is on
--
-- consider the defending unit's type, tribe, tribe's techs, tribe's wonders,
-- the improvements of the city the defender is in, the terrain the defender is on
--
-- If the 

function combatMod.attacker(attackerTraits,defenceTraits,modificationString,modificationName)




return combatMod
