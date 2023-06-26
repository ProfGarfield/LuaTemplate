--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

-- contains functionality for dealing with 
-- calendar dates and turns

---@class calendar
local calendar ={}
local gen = require("generalLibrary"):minVersion(1)
gen.versionFunctions(calendar,versionNumber,fileModified,"LuaCore".."\\".."calendar.lua")

-- calendar.turnFromDate(year,month,day,beforeAfterNearest = "nearest)
-- calendar.turnFromDate(year,month,beforeAfterNearest="nearest")
-- calendar.turnFromDate(year,beforeAfterNearest="nearest")
--      finds the turn corresponding to the date given
--      beforeAfterNearest is a string with 3 possible values,
--          (not case sensitive)
--          "before" means that the turn before the date will be chosen
--          e.g. year 1528 would occur on year 1520, not year 1530
--          "after" means that the turn after the date will be chosen
--          e.g. year 1521 would occur on year 1530, not 1520
--          "nearest" means that the turn nearest the date will be chosen
--              e.g. year 1528 would occur on year 1530, not 1520
--              for odd year increments, (years with turns are in <>)
--              <20>,21,22,23,24,<25>, years are split half way
--              21,22-><20>, 23,24-><25>
--              For even year increments
--              <20>,21,22,23,<24>, 21-><20>, 23-><24>
--              If 22 and month specified, months 1-6 -><20>, months 7-12-><24>
--              If no month specified, go to the later turn, 22-><24>
--              
--             Note: For the purposes of determining the 'nearest' when there are
--             monthly increments, days 0-15 go to the earlier month, days 16-31
--             go to the later month
--      year is an integer
--          the year in question.  Negative corresponds to BC years
--          NOTE: If increments are monthly, can't have year = 0,
--          since 0 year happens twice in the game, with a couple oddities
--      month is an integer 1 to 12
--          or string with month name or abbreviation (case doesn't matter,
--          but must be lower case in the table)
--          the month in question
--      day is an integer 1 to 31
local monthNames ={
["jan"]=1,
["january"]=1,
["feb"]=2,
["february"]=2,
["mar"]=3,
["march"]=3,
["apr"]=4,
["april"]=4,
["may"]=5,
["june"]=6,
["july"]=7,
["aug"]=8,
["august"]=8,
["sept"]=9,
["september"]=9,
["oct"]=10,
["october"]=10,
["nov"]=11,
["november"]=11,
["dec"]=12,
["december"]=12,
}
--
--
function calendar.turnFromDate(year,arg1,arg2,arg3)
    local fuzzyAllowed = {["before"]=true,["after"]=true,["nearest"]=true,}
    local month = nil
    local day = nil
    local fuzzy = "nearest"
    if type(arg1) == "number" then
        month = arg1
    elseif type(arg1) == "string" and monthNames[string.lower(arg1)] then
        month = monthNames[string.lower(arg1)]
    elseif type(arg1) == "string" and fuzzyAllowed[string.lower(arg1)] then
        fuzzy = arg1
    elseif type(arg1) ~="nil" then
        error("calendar.turnFromDate: second argument must be a month name, integer or 'before', 'after', 'nearest' or nil.  Actual value was: "..tostring(arg1))
    end
    if type(arg2) == "number" then
        day = arg2
    elseif type(arg2) == "string" then
        fuzzy = arg2
    elseif type(arg2) ~="nil" then
        error("calendar.turnFromDate: third argument must be 'before', 'after', 'nearest' or integer or nil.  Actual value was: "..tostring(arg2))
    end
    if type(arg3) == "string" and fuzzyAllowed[string.lower(arg1)] then
        fuzzy = arg3
    elseif type(arg3) ~="nil" then
        error("calendar.turnFromDate: fourth argument must be 'before', 'after', 'nearest' or nil.  Actual value was: "..tostring(arg3))
    end
    fuzzy = string.lower(fuzzy)
    if month and (month < 1 or month >12) then
        error("calendar.turnFromDate: month argument must be between 1 and 12.  Actual value was "..tostring(month))
    end
    if day and (day < 1 or day > 31) then
        error("calendar.turnFromDate: day argument must be between 1 and 31.  Actual value was "..tostring(day))
    end
    if fuzzy ~= "nearest" and fuzzy ~="after" and fuzzy ~= "before" then
        error("calendar.turnFromDate: string argument must be 'before', 'after', or 'nearest.'  Actual value was "..fuzzy)
    end
    if civ.scen.params.startingYear == 0 then
        error("This version of the calendar can't handle the default time track.")
    end
    if civ.scen.params.yearIncrement > 0 then
    -- year increments for turns
    -- Starting year for 0 elapsed turns is one less than the value of civ.scen.params.startingYear
    -- that is 5 means 4 AD, -3 means 4BC, or -4 in our reckoning
        local baseYear = civ.scen.params.startingYear -1
        local turnFloat = (year - baseYear)/civ.scen.params.yearIncrement
        local beforeTurn = math.floor(turnFloat)
        local afterTurn = math.ceil(turnFloat)
        if fuzzy == "before" then
            return beforeTurn
        elseif fuzzy == "after" then
            return afterTurn
        end
        -- if we're here, we must determine the 'closest'turn
        -- number of years between turns
        -- e.g. if yr 20 and 25 are turns, yrs 21,22,23,24 are between turns
        local yearsBetweenTurns = civ.scen.params.yearIncrement-1
        -- compute the year of the turn before the current year
        local beforeYear = baseYear+beforeTurn*civ.scen.params.yearIncrement
        if yearsBetweenTurns % 2 == 0 then
            -- even number of years between turns, can ignore months/days
            -- and just split based on the year, e.g. yr 21,22 -> Yr 20, yr 23,24 -> Yr 25
            if year - beforeYear <= yearsBetweenTurns/2 then
                return beforeTurn
            else
                return afterTurn
            end
        else
            if year - beforeYear <=math.floor(yearsBetweenTurns/2) then
                return beforeTurn
            elseif year - beforeYear > math.ceil(yearsBetweenTurns/2) then
                return afterTurn
            else
                -- we're right in that middle year, so months 1-6 go to the before year
                -- and months 7-12 go to the after year
                -- no month, go to after year
                if month and month <= 6 then
                    return beforeTurn
                else 
                    return afterTurn
                end
            end
        end
    elseif civ.scen.params.yearIncrement < 0 then
        if year == 0 then
            error("calendar.turnFromDate: can't have dates dates with year 0 if turn increments are in months.")
        end
        if not month then
            error("calendar.turnFromDate: must have a month value if turn increments are in months.")
        end
            
    -- month increments for turns
        -- convert everything to months, then operate as if 
        -- months are years

        -- The game seems to use this system of months
        --
        -- month_num    month   year
        --
        --
        --  13  Jan 1
        --  12  Dec 0
        --  11  Nov 0
        --  10 Oct 0
        --  9
        --  8
        --  7
        --  6
        --  5
        --  4
        --  3   Mar 0
        --  2   Feb 0           Note that January is skipped
        --  1   Dec 0
        --  0   Nov 0           Note: can't set this as starting year
        --  -1  Oct 0
        --  -2  Sep 0    
        --  -3
        --  -4
        --  -5
        --  -6
        --  -7
        --  -8
        --  -9  Feb 0
        --  -10 Jan 0
        --  -11 Dec 1
        --  -12 Nov 1
        --
        --  Convert the query month to the above system,
        --  base month is just the startingYear
        local queryMonth = nil
        if year > 0 then
            queryMonth = year*12+month
        elseif year < 0 then
            queryMonth = year*12-11+month
        else
            error("calendar.turnFromDate: can't have dates dates with year 0 if turn increments are in months.")
        end

        local baseMonth = civ.scen.params.startingYear
        local monthIncrement = -civ.scen.params.yearIncrement
        local turnFloat = (queryMonth - baseMonth)/monthIncrement
        local beforeTurn = math.floor(turnFloat)
        local afterTurn = math.ceil(turnFloat)
        if fuzzy == "before" then
            return beforeTurn
        elseif fuzzy == "after" then
            return afterTurn
        end
        -- if we're here, we must determine the 'closest'turn
        -- number of months between turns
        local monthsBetweenTurns = monthIncrement-1
        local beforeMonth = baseMonth+beforeTurn*monthIncrement
        if monthsBetweenTurns % 2 == 0 then
            if queryMonth - beforeMonth <= monthsBetweenTurns/2 then
                return beforeTurn
            else
                return afterTurn
            end
        else
            if queryMonth - beforeMonth <= math.floor(monthsBetweenTurns/2) then
                return beforeTurn
            elseif queryMonth-beforeMonth > math.ceil(monthsBetweenTurns/2) then
                return afterTurn
            else
                if day and day <= 15 then
                    return beforeTurn
                else
                    return afterTurn
                end
            end
        end
    else
        -- default turn rate
        error("This version of calendar.turnFromDate can't handle the default time track.")
    end
end

-- calendar.dateFromTurn(turn)--> integer, integer or nil
-- Returns the year and month (or nil, if not month increments)
-- for the turn
-- Default game years not currently supported

function calendar.dateFromTurn(turn)
    if civ.scen.params.yearIncrement > 0 then
        local baseYear = civ.scen.params.startingYear -1
        return baseYear+turn*civ.scen.params.yearIncrement, nil
    elseif civ.scen.params.yearIncrement < 0 then
        -- get the "month number", then convert it to the year and month
        local monthNumber = civ.scen.params.startingYear + turn*(-civ.scen.params.yearIncrement)
        if monthNumber >= 2 then
            local year = (monthNumber-1)//12 
            local month = monthNumber % 12
            if month == 0 then
                month = 12
            end
            return year,month
        else
            local year = -((-monthNumber+1)//12)
            local month = (monthNumber+11)%12
            if month == 0 then
                month = 12
            end
            return year,month
        end
    else
        error("calendar.dateFromTurn: dates from the default game mode are currently not available")
    end
end


return calendar
