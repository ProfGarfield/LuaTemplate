-- This file can be deleted if it is not being used
local register = {}

---&autoDoc onNegotiation
-- discreteEvents.onNegotiation and
-- consolidated.onNegotiation
-- also return booleans.  True means that the talker
-- can begin negotiations with the listener.
-- If any of the events return false, negotiations are
-- prevented, even if other negotiation events return true
function register.onNegotiation(talker,listener)
    return true
end
---&endAutoDoc

return register
