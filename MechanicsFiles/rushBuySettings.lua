-- this file can be removed without breaking the events (though a warning will be printed to the console)

local register = {}



--Registers a function that is called when calculating 
--the cost to rush-buy a city's current production.
--It takes the city and the cost as calculated by the
--game as parameters. Returns an integer representing the new costs.
function register.onGetRushBuyCost(city,cost)
    return cost
end



return register
