-- For a while, the civlua provided by TOTPP was superceeded
-- by civluaModified, which corrected a couple bugs
-- Those bugs have been fixed in civlua, so civluaModified
-- is just a passthrough for civlua now.  The require lines may be fixed at 
-- some point, but for now the passthrough exists just in case there is 
-- some sort of regression
local civlua = require("civlua")
return civlua
