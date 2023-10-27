--
local versionNumber = 3
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
-- By default, each flag's 'continuous' status is global.  That is, if flag 1 is set to continuous for
-- tribe 2, then it is set to continuous for all tribes.  And, if flag 1 is not set to continuous for
-- tribe 3, then it is no longer continuous for all other tribes as well.
-- The legacy event engine can override this by including the line
-- @CONTINUOUSFLAGSPERTRIBE






local function requireIfAvailable(fileName)
    if package.loaded[fileName] then
        return true, require(fileName)
    else
        for _,searcher in ipairs(package.searchers) do
            local loader = searcher(fileName)
            if type(loader) == 'function' then
                return true, require(fileName)
            end
        end
        return false, nil
    end
end

local hashModuleFound, hash = requireIfAvailable("secureHashAlgorithm")
if not hashModuleFound then
    hash = {
        hash256 = function(str)
            return "1234567890123456789012345678901234567890123456789012345678901234"
        end
    }
end

local validatorModuleFound, legacyValidate = requireIfAvailable("legacyEventValidator")
if not validatorModuleFound then
    legacyValidate = {
        action = function() end
    }
end



local function buildLegacyEvents(writeTextFile,showEventParsed,eventTextFileName,eventOutputFileName,
    batchInfo,eventsToConvert,scenarioFolderPath,currentFolder)
    --
    -- set writeTextFile=true if you want to output the table into a text file,
    -- false if it should just be returned
    writeTextFile = writeTextFile or false
    
    -- set showEventParsed=true to print the @ENDIF line number every time an event is
    -- parsed without an error.  This could help for debugging 
    showEventParsed = showEventParsed or true
    
    -- Change this if the events text file you are converting has a different name
    -- file is relative to the current directory
    eventTextFileName = eventTextFileName or "events.txt"
    
    -- Change this if you don't want to use the default name for the output file
    -- The OS time should hopefully prevent file overwrites
    eventOutputFileName = eventOutputFileName  or tostring(os.time()).."legacyEvents.lua"
    
    -- If the scenario has a batch file, and the batch file changes the events,
    -- put the turns that these events are valid into batchInfo
    batchInfo = batchInfo or nil
    -- For example
    -- batchInfo = {{[1]=firstValidTurn,[2]=lastValidTurn}}
    -- batchInfo = {{[1]=firstValidTurn1,[2]=lastValidTurn1},{[1]=firstValidTurn2,[2]=lastValidTurn2},}
    -- Then the trigger will only run on turns between a firstValidTurn and a LastValidTurn
    -- If events change for some reason other than the turn, ask for help in the forums to make the events work
    
    -- If you are trying to convert several sets of events changed by a batch file, add extra entries to the 
    -- eventsToConvert table
    eventsToConvert = eventsToConvert or {{eTFN=eventTextFileName,bI=batchInfo},--[[{eTFN=fileName2,bI=batchInfo2},]]}
    
    
    --
    --
    --
    -- If you are an end user of this converter, it should be unnecessary to look below this point
    --
    --
    --
    --
    --
    
    local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
    -- this stuff shouldn't actually be necessary
    --scenarioFolderPath = scenarioFolderPath or string.gsub(eventsPath, "legacyEventBuilder.lua", "?.lua")
    --if string.find(package.path, scenarioFolderPath, 1, true) == nil then
    --   package.path = package.path .. ";" .. scenarioFolderPath
    --end
    _G.console=console or {}
    currentFolder = currentFolder or string.gsub(eventsPath,"legacyEventBuilder.lua","")
    
    local civlua=require("civluaModified")
    
    local atIfOpen=false
    local atAndOpen=false
    local atThenOpen=false
    
    
    local nextLineParameter={}
        nextLineParameter.maprect=true
        nextLineParameter.moveto=true
    
    local nextLineParameterOpen={}
        nextLineParameterOpen.maprect=false
        nextLineParameterOpen.moveto=false
    
    local multiLineParameter={}
        multiLineParameter.locations=true
        multiLineParameter["text"]=true
    
    local multiLineParameterOpen={}
        multiLineParameterOpen.locations=false
        multiLineParameterOpen["text"]=false
    
    
    local function isActionWord(line)
        local action={}
        action.justonce=true
        action.dontplaywonders=true
        action.delay=true
        action.playwavefile=true
        action.playavifile=true
        action.playcdtrack=true
        action.createunit=true
        action.moveunit=true
        action.transportable=true
        action.changeterrain=true
        action.makeaggression=true
        action.changemoney=true
        action.destroyacivilization=true
        action.givetechnology=true
        action.taketechnology=true
        action.enabletechnology=true
        action.text=true
        action.modifyreputation=true
        action.bestowimprovement=true
        action.endgameoverride=true
        action.endgame=true
        action.flag=true
        action.negotiator=true
        return action[line]
    end
    
    
    local actionOpen={}
    actionOpen.justonce=false
    actionOpen.delay=false
    actionOpen.dontplaywonders=false
    actionOpen.playwavefile=false
    actionOpen.playavifile=false
    actionOpen.playcdtrack=false
    actionOpen.createunit=false
    actionOpen.moveunit=false
    actionOpen.transportable=false
    actionOpen.changeterrain=false
    actionOpen.makeaggression=false
    actionOpen.changemoney=false
    actionOpen.destroyacivilization=false
    actionOpen.givetechnology=false
    actionOpen.taketechnology=false
    actionOpen.enabletechnology=false
    actionOpen.text=false
    actionOpen.modifyreputation=false
    actionOpen.bestowimprovement=false
    actionOpen.endgameoverride=false
    actionOpen.endgame=false
    actionOpen.flag=false
    actionOpen.negotiator=false
    
    
    local function getOpenAction()
        for action,isOpen in pairs(actionOpen) do
            if isOpen then
                return action
            end
        end
        return false
    end
    
    local eventTable = {}
    local eventTableIndex=1
    local lineNumber=0

    local function closeAllActions()
        if not eventTable[eventTableIndex]["THEN"] then
            error("Legacy Event Builder: Event File Line Number: "..lineNumber..".  The @THEN line seems to be missing or in the wrong place.")
        end
        if getOpenAction() then
            legacyValidate.action(eventTable[eventTableIndex]["THEN"][getOpenAction()],getOpenAction(),lineNumber)
        end
        for index,value in pairs(actionOpen) do
            actionOpen[index]=false
        end
    end

    -- Old code to convert coordinates
    --[[
    
    -- reads a line of coordinates x1,y1,x2,y2,x3,y3,x4,y4 (in string form)
    -- and transforms to table
    -- {{x1,y1},{x2,y2},{x3,y3},{x4,y4}}
    local function mapRectangleToTable(line)
        if line:sub(-1) == "," then
            line = line:sub(1,-2)
        end
        local oT={{},{},{},{}}
        oT[1][1],oT[1][2],oT[2][1],oT[2][2],oT[3][1],oT[3][2],oT[4][1],oT[4][2] = load("return "..line)()
        return oT
    end
    -- converts string "x1,y1" to table
    -- {x1,y1}
    local function mapCoordinateToTable(line)
        if line:sub(-1) == "," then
            line = line:sub(1,-2)
        end
        local oT={}
        oT[1],oT[2],oT[3] = load("return "..line)()
        return oT
    end
    --]]

    -- New code to convert coordinates
    
    local function removeCommentsTrailingSpaces(line)
        local semicolonLoc = string.find(line,";")
        if semicolonLoc then
            line = line:sub(1,semicolonLoc-1)
        end
        while line:sub(-1)==" " or line:sub(-1)=="\t" do
            line = line:sub(1,-2)
        end
        return line
    end

    local function removeLeadingSpaces(line)
        while line:sub(1,1)==" " or line:sub(1,1)=="\t" do
            line = line:sub(2)
        end
        return line
    end

    local function lineToTable(line)
        local function splitAtComma(line)
            local commaLoc = string.find(line,",")
            if commaLoc then
                return line:sub(1,commaLoc-1),line:sub(commaLoc+1)
            else
                return line,nil
            end
        end
        local remainingLine = line
        local currentEntry = nil
        local column = 0
        local table = {}
        repeat
            currentEntry,remainingLine = splitAtComma(remainingLine)
            currentEntry = removeCommentsTrailingSpaces(currentEntry)
            currentEntry = removeLeadingSpaces(currentEntry)
            table[column] = currentEntry
            column = column+1
        until column >= 30 or not remainingLine
        return table
    end

    -- reads a line of coordinates x1,y1,x2,y2,x3,y3,x4,y4 (in string form)
    -- and transforms to table
    -- {{x1,y1},{x2,y2},{x3,y3},{x4,y4}}
    local function mapRectangleToTable(line,lineNumber,fileNumber)
        local originalLine = line
        local function coordinateStringToNumber(coordinateString)
            local coordinateNumber = tonumber(coordinateString)
            if coordinateNumber == nil then
                error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The line after a 'maprect' line should be four coordinate pairs separated by commas (8 numbers separated by commas).  Received:\n"..originalLine)
            end
            return coordinateNumber
        end
        local function validateCoordinates(x,y,coordNumber)
            if x%2 ~= y%2 then
                error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The coordinates in a map rectangle must be even or odd in both the x and y component. Coordinate "..coordNumber.." is invalid.  Received:\n"..originalLine)
            end
        end
        if line:sub(-1) == "," then
            line = line:sub(1,-2)
        end
        local oT={{},{},{},{}}
        local lineTable = lineToTable(line)
        --oT[1][1], oT[1][2],oT[2][1],oT[2][2],oT[3][1],oT[3][2],oT[4][1],oT[4][2] = load("return "..line)()
        oT[1][1] = coordinateStringToNumber(lineTable[0])
        oT[1][2] = coordinateStringToNumber(lineTable[1])
        oT[2][1] = coordinateStringToNumber(lineTable[2])
        oT[2][2] = coordinateStringToNumber(lineTable[3])
        oT[3][1] = coordinateStringToNumber(lineTable[4])
        oT[3][2] = coordinateStringToNumber(lineTable[5])
        oT[4][1] = coordinateStringToNumber(lineTable[6])
        oT[4][2] = coordinateStringToNumber(lineTable[7])
        validateCoordinates(oT[1][1],oT[1][2],1)
        validateCoordinates(oT[2][1],oT[2][2],2)
        validateCoordinates(oT[3][1],oT[3][2],3)
        validateCoordinates(oT[4][1],oT[4][2],4)
        if oT[1][2] ~= oT[2][2] or oT[3][2] ~= oT[4][2] or
        oT[1][1] ~= oT[4][1] or oT[2][1] ~= oT[3][1]
        then
            error([[Legacy Event Builder: File Number: ]]..fileNumber..[[ Line Number: ]]..lineNumber..[[. Invalid 'maprect' coordinates. ]]..
                [[The maprect coordinates define the corners of the rectangular region. They must (1) be on the line immediately following the word maprect, (2) be separated by commas, and (3) be listed in the following specific order to be valid. (They also must be valid map coordinates.) The first coordinate must be the upper left corner; next comes the upper right, then lower right, and finally lower left. Thus:

	1--2
	4--3
    
    ]]
    ..[[Received: ]]..originalLine)
                end

        return oT
    end
    -- converts string "x1,y1" to table
    -- {x1,y1}
    local function mapCoordinateToTable(line,lineNumber,fileNumber)
        local originalLine = line
        local function coordinateStringToNumber(coordinateString,isZCoord)
            local coordinateNumber = tonumber(coordinateString)
            if coordinateNumber == nil and not isZCoord then
                error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The lines between a 'locations' line and an 'endlocations' line should each have one map coordinate (2 or 3 numbers separated by commas).  Received:\n"..originalLine)
            end
            return coordinateNumber
        end
        if line:sub(-1) == "," then
            line = line:sub(1,-2)
        end
        local oT={}
        local lineTable = lineToTable(line)
        --oT[1],oT[2],oT[3] = load("return "..line)()
        oT[1] = coordinateStringToNumber(lineTable[0],false)
        oT[2] = coordinateStringToNumber(lineTable[1],false)
        oT[3] = coordinateStringToNumber(lineTable[2],true)
        if oT[1] % 2 ~= oT[2] % 2 then
            -- invalid civ ii coordinates, x,y must be both even or both odd
            error("Legacy Event Builder File Number: "..fileNumber.." Line Number: "..lineNumber..".  A coordinate in Civ II must have the x and y component be both even or both odd.  Received:\n"..originalLine)
        end
        return oT
    end

    -- end of coordinate conversion code
    local function removeTrailingSpaces(line)
        while line:sub(-1)==" " or line:sub(-1)=="\t" do
            line = line:sub(0,-2)
        end
        return line
    end
    
    
    local totalEventString = ""
    for fileNumber,fileInfo in pairs(eventsToConvert) do
        lineNumber = 0
        local batchInfo = fileInfo.bI
        
        -- this keeps track of the event inputs, so that they can be
        -- hashed to determine if the events have changed
        for line in io.lines(currentFolder.."\\"..fileInfo.eTFN) do
            totalEventString = totalEventString..line.."\n"
            -- must remove everything after the semicolon, as it is not needed
            local semicolonLoc = string.find(line,";")
            if semicolonLoc then
                line = line:sub(1,semicolonLoc-1)
            end
            line = removeTrailingSpaces(line)
            -- line is the next line in events.txt, except for the newline character at the end of the line
            local originalCase=line
            -- since case doesn't matter in events.txt except for Text events
            line = string.lower(line)
            lineNumber=lineNumber+1 -- this means it is the current line
            if string.find(line, "os.execute") then
                error("Line "..tostring(lineNumber).." has the lua command os.execute, which can make changes to\n"..
                    "your computer if executed.  This line has no place in an events.txt file and might mean\n"..
                    "someone is trying to get you to run malicious code.  This parser does run a few lines of\n"..
                    "the events.txt it is trying to convert, so for safety this process will be canceled.")
            end
            if line == "" then
                -- ignore an empty line
            elseif line == "@continuousflagspertribe" then
                -- legacy event engine global continuous flags override
                eventTable["continuousFlagsPerTribe"]=true
            elseif line == "@if" then
                if atIfOpen or atAndOpen or atThenOpen then
                    error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The event just before this one seems to be missing the @ENDIF line.")
                end
                eventTable[eventTableIndex]={IF={}}
                atIfOpen=true
                eventTable[eventTableIndex]["BATCHINFO"]=batchInfo
                eventTable[eventTableIndex]["STARTLINE"]=lineNumber
            elseif line == "@and" then
                atIfOpen=false
                atAndOpen=true
                eventTable[eventTableIndex]["AND"]={}
            elseif line == "@then" then
                atIfOpen=false
                atAndOpen=false
                atThenOpen=true
                eventTable[eventTableIndex]["THEN"]={}
            elseif line == "@endif" then
                if multiLineParameterOpen["text"] then
                    error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The event has no ENDTEXT line.")
                end
                if multiLineParameterOpen["locations"] then
                    error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The event has no ENDLOCATIONS line.")
                end
                atIfOpen=false
                atAndOpen=false
                atThenOpen=false
                closeAllActions()
                eventTableIndex=eventTableIndex+1
                if showEventParsed then
                    print("File number "..tostring(fileNumber).." event ending at line "..tostring(lineNumber).." successfully parsed.  Event number is "..tostring(eventTableIndex-1)..".")
                end
            elseif atIfOpen then
                -- we're after the @IF line, but not yet at @AND
                -- find the index in the string of the = sign
                local eqLoc = string.find(line,"=")
                if eqLoc then
                    -- note: The turn parameter overwrites the turn triggertype in the parser
                    -- this doesn't matter since no other trigger type has a turn= parameter
                    -- There can be multiple map= parameters in a unitkilled trigger,
                    -- so these must be handled separately
                    if line:sub(1,eqLoc) =="map=" then
                        eventTable[eventTableIndex]["IF"]["map"]=eventTable[eventTableIndex]["IF"]["map"] or {}
                        eventTable[eventTableIndex]["IF"]["map"][tonumber(line:sub(eqLoc+1,eqLoc+1))]=true
                    end
                    -- If the line has an = sign then
                    -- if table has index of everything before = sign with value as everything after = sign
                    -- if what is after the equal sign is a number, store it as a number
                    eventTable[eventTableIndex]["IF"][line:sub(1,eqLoc-1)]=tonumber(line:sub(eqLoc+1)) or line:sub(eqLoc+1)
                else
                    -- note: The turn parameter overwrites the turn triggertype in the parser
                    -- this doesn't matter since no other trigger type has a turn= parameter
                    -- The current line doesn't have an = sign, so it is a trigger word or some other special word
                    eventTable[eventTableIndex]["IF"][line]=true
                end
            elseif atAndOpen then
                -- we're after the @AND line, but not yet at @THEN
                -- find the index in the string of the = sign
                local eqLoc = string.find(line,"=")
                if eqLoc then
                    -- note: The turn parameter overwrites the turn triggertype in the parser
                    -- this doesn't matter since no other trigger type has a turn= parameter
                    -- There can be multiple map= parameters in a unitkilled trigger,
                    -- so these must be handled separately
                    if line:sub(1,eqLoc) =="map=" then
                        eventTable[eventTableIndex]["AND"]["map"]=eventTable[eventTableIndex]["AND"]["map"] or {}
                        eventTable[eventTableIndex]["AND"]["map"][tonumber(line:sub(eqLoc+1,eqLoc+1))]=true
                    end
                    -- If the line has an = sign then
                    -- if table has index of everything before = sign with value as everything after = sign
                    -- if what is after the equal sign is a number, store it as a number
                    eventTable[eventTableIndex]["AND"][line:sub(1,eqLoc-1)]=tonumber(line:sub(eqLoc+1)) or line:sub(eqLoc+1)
                else
                    -- note: The turn parameter overwrites the turn triggertype in the parser
                    -- this doesn't matter since no other trigger type has a turn= parameter
                    -- The current line doesn't have an = sign, so it is a trigger word or some other special word
                    eventTable[eventTableIndex]["AND"][line]=true
                end
            elseif atThenOpen then
                -- we're after the @THEN line
                if nextLineParameterOpen.maprect then
                    -- put the map rectangle coordinates into the "maprect" index of the open action
                    eventTable[eventTableIndex]["THEN"][getOpenAction()]["maprect"]=mapRectangleToTable(line,lineNumber,fileNumber)
                    if eventTable[eventTableIndex]["THEN"][getOpenAction()]["maprect"][4][2] == nil then
                        error("Legacy Event Builder: File Number: "..fileNumber.." Line Number: "..lineNumber..".  The line after a 'maprect' line should be four coordinates separated by commas (8 numbers separated by commas).  Received:\n"..line)
                    end
                    -- close the nextLineParameter for maprect
                    nextLineParameterOpen.maprect=false
                elseif nextLineParameterOpen.moveto then
                    -- put the move to coordinates into the "moveto" index of the open action
                    eventTable[eventTableIndex]["THEN"][getOpenAction()]["moveto"]=mapCoordinateToTable(line,lineNumber,fileNumber)
                    -- close the nextLineParameter for moveto
                    nextLineParameterOpen.moveto=false
                elseif multiLineParameterOpen.locations then
                    if line == "endlocations" then
                        multiLineParameterOpen.locations=false
                    else
                        -- get the table of locations for the event, create it if it doesn't exist yet
                        eventTable[eventTableIndex]["THEN"][getOpenAction()]["locations"]=eventTable[eventTableIndex]["THEN"][getOpenAction()]["locations"] or {}
                        local locTable = eventTable[eventTableIndex]["THEN"][getOpenAction()]["locations"]
                        -- add the coordinates of the next location to the table
                        locTable[#locTable+1]=mapCoordinateToTable(line,lineNumber,fileNumber)
                    end
                elseif multiLineParameterOpen["text"] then
                    if line=="endtext" then
                        multiLineParameterOpen["text"]=false
                    elseif line=="no broadcast" then
                        -- the no broadcast parameter is set
                        eventTable[eventTableIndex]["THEN"][getOpenAction()]["no broadcast"]=true
                    else
                        -- The nth line of text is entered as key n in the text table
                        -- Use the original line and not the lowercase version,
                        local textTable = eventTable[eventTableIndex]["THEN"][getOpenAction()]["text"]
                        textTable[#textTable+1]=originalCase
                    end
                elseif line=="justonce" then
                    -- just once must be handled as a special case, since it is a one line action
                    -- this line isn't strictly necessary, since JustOnce is supposed to come right after @THEN, 
                    -- but just in case
                    closeAllActions()
                    eventTable[eventTableIndex]["THEN"]["justonce"]=true
                elseif line=="dontplaywonders" then
                    -- DONTPLAYWONDERS must be handled as a special case, since it is a one line action
                    closeAllActions()
                    eventTable[eventTableIndex]["THEN"]["dontplaywonders"]=true
                elseif line=="text" then
                    -- text must be handled as a special case, since it is both an action word and
                    -- a multiline parameter word
                    closeAllActions()
                    actionOpen[line]=true
                    multiLineParameterOpen[line]=true
                    eventTable[eventTableIndex]["THEN"][line]={["text"]={}}
                elseif isActionWord(line) then
                    -- this means a new action has been reached
                    -- close the previously open action
                    closeAllActions()
                    -- open the curren action, so we know where to put parameters
                    actionOpen[line]=true
                    -- make an empty table for the action
                    eventTable[eventTableIndex]["THEN"][line]={}
                -- open parameters for next line
                elseif nextLineParameter[line] then
                    nextLineParameterOpen[line]=true
                elseif multiLineParameter[line] then
                    multiLineParameterOpen[line]=true
            -- At this point, there is an open action, and we are adding parameters the table that represents it
                elseif string.find(line,"=") then
                    local eqLoc = string.find(line,"=")
                    if getOpenAction() then
                        -- If the line has an = sign then Action Table has index of everything before '=' sign,
                        -- index has value of everything after = sign
                        -- if what is after = sign is a number, store it as a number, not a string
                        eventTable[eventTableIndex]["THEN"][getOpenAction()][line:sub(1,eqLoc-1)]=tonumber(line:sub(eqLoc+1))
                        or line:sub(eqLoc+1)
                    else
                        -- this means we're trying to have a parameter with an = sign, but no open action to put it in
                        error("Event file "..tostring(fileNumber).." at line number "..tostring(lineNumber).." is:\n"..line.."\nThis appears to be attempting to assign a parameter value.  However, there is not a valid action word for this assignment on a previous line.")
                    end
                -- The next 3 actions take a single parameter without an = sign
                elseif actionOpen.playwavefile then
                    --play wave file action
                    --use the original case of the line
                    eventTable[eventTableIndex]["THEN"]["playwavefile"]=originalCase
                    -- the next action word will close this action, so don't worry about it here
                elseif actionOpen.playavifile then
                    --play wave file action
                    --use the original case of the line
                    eventTable[eventTableIndex]["THEN"]["playavifile"]=originalCase
                    -- the next action word will close this action, so don't worry about it here
                elseif actionOpen.playcdtrack then
                    --play wave file action
                    --use the original case of the line
                    eventTable[eventTableIndex]["THEN"]["playcdtrack"]=originalCase
                    -- the next action word will close this action, so don't worry about it here
                elseif getOpenAction() then
                -- at this point, we have a line without an '=' sign that doesn't correspond to an action or an @XXXX,
                -- or a parameter defined on the next line
                -- It must be a parameter or modifyer that is either used or not, so it is boolean
                -- set it as a key for the Action Table with value true
                    eventTable[eventTableIndex]["THEN"][getOpenAction()][line]=true
                else
                    -- if we get here, there is no open action and a line not recognized
                    error("Event file "..tostring(fileNumber).." at line number "..tostring(lineNumber).." is:\n"..line.."\nThis is not recognized as a valid action word, and there is not a valid action word on a previous line for this to be interpreted as a parameter.")
                end
            end
        end
    end -- multiple file conversion loop
    -- this provides a way of checking if the event file has been changed
    local eventFileHash = hash.hash256(totalEventString)
    eventTable["eventHash"]=eventFileHash

    -- Add the current version number of the legacy event builder
    eventTable["legacyEventBuilderVersion"]=versionNumber
    
    
    -- This Piece of Code was written by TheNamelessOne, creater of TOTPP
    
    local yield = coroutine.yield
    local function serialize_co(o)
      if type(o) == "number" or
         type(o) == "boolean" then
        yield(tostring(o))
      elseif type(o) == "string" then
        yield(string.format("%q", o))
      elseif type(o) == "table" then
        yield("{\r\n")
        for k, v in pairs(o) do
          yield("  [")
          serialize_co(k)
          yield("] = ")
          serialize_co(v)
          yield(",\r\n")
        end
        yield("}\r\n")
      elseif civ.isTile(o) then
        yield(string.format("civ.getTile(%d, %d, %d)", o.x, o.y, o.z))
      elseif civ.isUnit(o) then
        yield(string.format("civ.getUnit(%d)", o.id))
      elseif civ.isCity(o) then
        yield(string.format("civ.getCity(%d)", o.id))
      elseif civ.isTribe(o) then
        yield(string.format("civ.getTribe(%d)", o.id))
      elseif civ.isUnitType(o) then
        yield(string.format("civ.getUnitType(%d)", o.id))
      elseif civ.isImprovement(o) then
        yield(string.format("civ.getImprovement(%d)", o.id))
      elseif civ.isTech(o) then
        yield(string.format("civ.getTech(%d)", o.id))
      elseif civ.isWonder(o) then
        yield(string.format("civ.getWonder(%d)", o.id))
      else
        error("cannot serialize a " .. type(o))
      end
    end
    
    -- Return a string representation of object `o`.
    local function serialize(o)
      local t = {"return "}
      for s in coroutine.wrap(function () serialize_co(o) end) do
        table.insert(t, s)
      end
      return table.concat(t)
    end
    
    -- End of TheNamelessOne's code
    --
    if writeTextFile then
        local outputString=serialize(eventTable)
        outputString=string.gsub(outputString,"\r","")-- remove the carrage return character, since it was added with the newline
        -- and causes formatting issues in both VIM and notepad++ under WINE
        local file = io.open(currentFolder.."\\"..eventOutputFileName,"a")
        ---@cast file file*
        io.output(file)
        io.write(outputString)
        io.close(file)
    end
    return eventTable
end

local builder = {
    buildLegacyEvents=buildLegacyEvents,
}

local genFound, gen = requireIfAvailable("generalLibrary")
if genFound then
    gen:minVersion(1)
    gen.versionFunctions(builder,versionNumber,fileModified,"LuaCore".."\\".."buildLegacyEvents.lua")
end
return builder
