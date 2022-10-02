
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file



local gen = require("generalLibrary"):minVersion(1)
local object = require("object")
local cityYield = {}
gen.versionFunctions(cityYield,versionNumber,fileModified,"MechanicsFiles".."\\".."calculateCityYield.lua")
local baseProduction = gen.computeBaseProduction
local strategicTargetsAvailable, strat = gen.requireIfAvailable("strategicTargets")

function cityYield.onCalculateCityYield(city,food,shields,trade)
    local extraFood,extraShields,extraTrade = 0,0,0 -- resources to add to compensate
            -- for terrain changes made during the city yield calculation
            -- If you remove the above line, remember to remove the references to
            -- these variables in the return line at the end of this function
    -- If you are not making any terrain production value changes in this
    -- function, you can take out the code below this line and above a
    -- corresponding line below
    -- Any changes to terrain production should go here
    
    -- verify strategic targets, in case terrain changes or something
    if strategicTargetsAvailable then
      for target in strat.iterateTargets(city) do
        strat.verifyTarget(target)
      end
    end
    


    -- Any changes to terrain production should be before this line
    local correctFood,correctShields,correctTrade = baseProduction(city)
    extraFood = correctFood-food
    food = correctFood
    extraShields = correctShields - shields
    shields = correctShields
    extraTrade = correctTrade - trade
    trade = correctTrade
    -- If you are not making any terrain production value change in this
    -- function, you can take out the code above this line and below
    -- the corresponding line above
    -- You can take out the lines even if you have a beforeProduction event
    -- that changes terrain production, since that has been compensated for
    -- in the events.lua file

    -- After this point, the variables food, shields, and trade will refer to their
    -- 'correct' values, even if you've changed terrain production values

    -- change the values of these variables to reflect the changes you would like to
    -- make to these different production values
    local foodChange = 0
    local shieldChangeBeforeWaste = 0 -- changes the value before factory/power plant applied
    local shieldChangeAfterWaste = 0 -- changes the value after factory/power plant applied
    local tradeChangeBeforeCorruption = 0 
    local tradeChangeAfterCorruption = 0 


    return  foodChange+extraFood,
            shieldChangeBeforeWaste + extraShields,
            shieldChangeAfterWaste,
            tradeChangeBeforeCorruption+ extraTrade,
            tradeChangeAfterCorruption
end


--  onCalculateCityYield (since 0.16)
--  civ.scen.onCalculateCityYield(function (city, food, shields, trade) -> (foodChange, shieldChangeBeforeWaste, shieldChangeAfterWaste, tradeChangeBeforeCorruption, tradeChangeAfterCorruption)) -> void
--  
--  Registers a function to be called every time a city calculates its total resource yield. Input is the city, and the food, shields and trade of its tiles. Returns a 5-tuple of modifiers, food change, shield change before waste, shield change after waste, trade change before corruption, trade change after corruption. These modifiers are applied at the following points in the calculation:
--  Calculate yield from all worked tiles
--  Run onCalculateCityYield
--  Add foodChange, shieldChangeBeforeWaste and tradeChangeBeforeCorruption
--  Add changes from food trade routes
--  Add shields from improvements
--  Calculate and subtract waste
--  Calculate corruption and add changes from commodity trade routes
--  Calculate corruption again (now using the value after trade routes) and subtract.
--  Add shieldChangeAfterWaste and tradeChangeAfterCorruption
--  Calculate Tax/Lux/Sci

return cityYield
