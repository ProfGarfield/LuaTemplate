local register = {}

-- register.onChooseDefender
--Registers a function that is called every time a unit is chosen to defend a tile.
--The first parameter is the default function as implemented by the game.
--It takes `tile` and `attacker` as parameters. You can call this to produce a 
--result for cases you don't need to handle yourself. The second parameter 
--is the tile that's being considered, the third is the attacking unit, and the 
--fourth, `isCombat`, is a boolean that indicates if this invocation will be 
--followed by combat. This function is also called by the AI to determine its 
--goals, in which case `isCombat` is false.

function register.onChooseDefender(defaultFunction,tile,attacker,isCombat)
    return defaultFunction(tile,attacker)
end


function register.onInitiateCombatMakeCoroutine(attacker,defender,attackerDie,attackerPower,defenderDie,defenderPower)

    local maxCombatRounds = math.huge -- If you want to limit combat to a specific number of
                                        -- turns, set this variable
    return coroutine.create(function()
        local round = 0
        while(round < maxCombatRounds and attacker.hitpoints >0 and defender.hitpoints > 0) do

            if false then
                -- If the coroutine yields true as its first value, 
                -- the game's default combat resolution is skipped for that round 
                -- and the designer is responsible for updating damage. 
                -- The second value yielded is either the attacker or the defender, 
                -- this is used to render animations etc. 
                -- In this case the coroutine resumes without any values.

                coroutine.yield(true,defender)
            else

                --If the coroutine yields false as its first value, 
                --the game runs its default combat algorithm. The designer 
                --can additionally yield modified values for attackerDie, 
                --attackerPower, defenderDie and defenderPower (in this order) 
                --which will be used by the game for that round.

                local newAttackerDie = nil
                local newAttackerFirepower = nil
                local newDefenderDie = nil
                local newDefenderFirepower = nil
                local result = coroutine.yield(false,newAttackerDie,newAttackerFirepower,newDefenderDie,newDefenderFirepower)

                --In this case the coroutine resumes with the result of the round, 
                --a table containing four values:
                    -- winner, this is either attacker or defender.
                    -- attackerRoll, the result of the attacker's die roll
                    -- defenderRoll, the result of the defender's die roll
                    -- reroll, true if a reroll happened. This can happen only 
                         -- if the attacker is tribe 0, the defender is a unit 
                         -- guarding a city, and the city is the capital or 
                         -- the tribe has less than 8 cities in total and 
                         -- the attacker's die roll is higher than the 
                         -- defender's. A reroll can happen at most once.


            end
            round = round+1
        end
        -- once we get here, combat stops
    end)
end


return register
