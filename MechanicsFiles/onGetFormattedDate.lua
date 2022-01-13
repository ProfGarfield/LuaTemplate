-- this file can be deleted if it is not necessary
--
--Registers a function that is called when the game needs to get the date string for a given turn (e.g. "4000 B.C." for turn 1). `turn` is the turn for which the date is requested (not always the current turn), and `defaultDateString` is the string as formatted by the game


local register = {}

function register.onGetFormattedDate(turn,defaultDateString)
    if _global.eventTesting then
        --print(turn,civ.getTurn())
        return "Testing Turn "..turn
    end
    return defaultDateString
end

return register
