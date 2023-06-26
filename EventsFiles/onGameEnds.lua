-- this file can be deleted if it is not used.
local register = {}

---&autoDoc onGameEnds
-- discreteEvents.onGameEnds and
-- consolidated.onGameEnds
-- also return booleans.  True means that the 
-- game ends as normal, which is the default behaviour.
-- If any of the registered functions return false, then
-- the game doesn't end
function register.onGameEnds(reason)

    return true
end
---&endAutoDoc

return register
