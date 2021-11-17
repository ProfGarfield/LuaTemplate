-- This file can be deleted if it is not being used
local register = {}

-- discreteEvents.onSchism and
-- consolidated.onSchism
-- also return booleans.  True means that the tribe can schism
-- (default behaviour).
-- If any of the events return false, schism is 
-- prevented, even if other schism events return true
function register.onSchism(tribe)

    return true
end

return register
