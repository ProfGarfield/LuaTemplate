
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file


-- The text.lua library supplies various functions related to displaying text, menus and checkbox option choices.
--
-- BY: Prof. Garfield with special thanks to Knighttime for convertTableToColumnText 
-- (and, by extension, all the tabulation functions), with some code from Pablostuka
--
-- USAGE
--      In Folder, or in lua folder
-- characterTable.lua (included, separate file in case it must be changed)
--
--      Code Body
-- local text = require("text")
--
-- state.textTable = state.textTable or {}
-- text.linkState(state.textTable)
--
--      civ.scen.onLoad
-- state.textTable = state.textTable or {}
-- text.linkState(state.textTable)
--
--      afterProduction (recommended, must implement after production event)
-- text.displayAccumulatedMessages()
--
--
--
--  FUNCTIONS PROVIDED
--  Note: if arg=value, value is default for arg if nil is entered
--  text.linkState(tableInState) --> void
--  text.getLinesPerWindow()-->integer
--  text.setLinesPerWindow(integer)--> void
--  text.addMultiLineTextToDialog(text,dialogObject) --> void
--  text.simple(string or tableOfStrings,title="") --> void
--  text.addToArchive(tribe or TribeID,messageBody,messageTitle,archiveTitle)-->void
--  text.displayNextOpportunity(tribe or tableOfTribes,messageBody,messageTitle="",
--              archiveTitle=nil, broadcast=nil)
--  text.displayAccumulatedMessages() --> void
--  text.menu(menuTable,menuText,menuTitle="",canCancel=false,menuPage=1)-->integer,integer
--  text.displayArchivedMessage(archivedMessage,archivePage=1,displayArchiveTable=nil,
--                              displayArchiveTableIndex=nil,
--                              archiveTitle = nil,
--                              archiveMessage = nil,
--                              showHidden = false,
--                              tribe=activeTribe,)
--  text.openArchive(archiveTitle="Archived Messages",archiveText="Choose a message to review.",
--                  archivePage=1,
--                  showHidden=false,tribe=activeTribe)-->void
--  text.purgeArchive(tribeOrTribeID) --> void
--  text.deleteAIArchives()-->void
--  text.substitute(rawText,substitutionTable)-->string
--  text.convertTableToColumnText (columnTable, dataTable, borderWidth) --> string | By Knighttime
--* text.makeTableText(table) --> void
--  text.copyTableAsText(table) --> table
--  text.simpleTabulation(tabulationData,title="",borderWidth=4) --> void | Knighttime Contribution
--  text.simpleTabTableToText(tabulationData,title="",borderWidth=4) --> string | Knighttime Contribution
--  text.tabulationMenu(tabMenuTable,menuText,menuTitle,canCancel,menuPage=1)-->integer | Knighttime Contribution
--  text.checkboxMenu(checkboxTable,menuText,menuTitle,menuPage=1)
--  text.groupDigits(integer)-->string
--  text.setDigitGroupSeparator(string)-->void
--  text.money(amount) --> string
--  text.setMoney(string)-->void
--  text.getVeteranTitle()-->string
--  text.setVeteranTitle(string)-->void
--  text.getShortVeteranTitle()-->string
--  text.setShortVeteranTitle(string)-->void
-- text.makeReverseListNoGaps(tableOfStrings,listLength=nil)-->string
-- text.niceList(table)-->string
-- text.coordinates(tile)-->string
-- text.lpad(str,length,character) --> string | By Pablostuka
-- text.rpad(str,length,character) --> string | By Pablostuka
-- text.pad(str,length,character) --> string | By Pablostuka
-- text.international(string) --> string | inspired by Pablostuka
-- text.i(string) --> string (alias for text.international)
-- text.upper(string) --> string
-- text.lower(string) --> string
-- text.iUpper(string) --> string
-- text.iLower(string) --> string
-- text.initCap(string) --> string | By Pablostuka
--
-- Control Sequences:
-- "%PAGEBREAK"
--      Start a new text window at this point, even if the page could display more text.
local pageBreakControl = "%%PAGEBREAK" -- note %% has to be used for % in string patterns for
--                  matching and substitution, but not in actual strings to display
-- 
-- Known Improvements Required
-- linesInText(text) -- currently only counts newline characters to find number of lines in text
--                      should count character width to determine instead
--
--
--
--
--

-- ========================================================
--
-- Module Variables and Functions to Change those variables
--
-- ========================================================


-- need func for splitlines
local func = require "functions"
-- Get the size of each character from the characterTable
local charSize = require("characterTable")
local gen = require("generalLibrary"):minVersion(1)

-- The functions this module provides are stored in the text table
local text={}
gen.versionFunctions(text,versionNumber,fileModified,"LuaCore".."\\".."text.lua")
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."text.lua")

-- textState allows this module to access the state table
local textState = "notLinked"


-- text.linkState(tableInState) --> void
-- links the state table to this module
-- and initializes sub-tables necessary for module to function
local function linkState(tableInState)
    if type(tableInState) ~= "table" then
        error("text.linkState takes a table as an argument.")
    else
        textState = tableInState
    end
    -- initialize the archive table if it doesn't exist
    textState.archive = textState.archive or {}
    -- initialize each tribe's archive
    for i=0,7 do
        textState.archive[i] = textState.archive[i] or {}
    end
    -- initialize the pending messages table
    -- these are messages to display when the player's turn arrives (after production)
    textState.pendingMessages = textState.pendingMessages or {}
    -- initialize each tribe's pending messages table
    for i=0,7 do
        textState.pendingMessages[i] = textState.pendingMessages[i] or {}
    end

end
text.linkState = linkState


-- requireIfAvailable(fileName) --> fileFound (bool), prefix (whatever is returned by a successful require, or nil)
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

local fileFound, discreteEvents = requireIfAvailable("discreteEventsRegistrar")
if fileFound then
    function discreteEvents.linkStateToModules(state,stateTableKeys)
        local keyName = "textTable"
        if stateTableKeys[keyName] then
            error('"'..keyName..'" is used as a key for the state table on at least two occasions.')
        else
            stateTableKeys[keyName] = true
        end
        -- link the state table to the module
        state[keyName] = state[keyName] or {}
        linkState(state[keyName])
    end
end



-- Maximum number of lines/options to show in a text window
local linesPerWindow = 12

-- Window must be able to display this many lines if necessary
local minimumLinesPerWindow = 8

--  text.setLinesPerWindow(integer)--> void
-- Set the lines per window
local function setLinesPerWindow(integer)
    linesPerWindow = math.max(math.floor(integer),minimumLinesPerWindow)
end
text.setLinesPerWindow = setLinesPerWindow

local function getLinesPerWindow()
    return linesPerWindow
end
text.getLinesPerWindow = getLinesPerWindow

-- ==============================================================
--
-- Module Functions
--
-- ==============================================================
--

-- the imageTable is the table where the text module will
-- look for imageObjects, when provided with a table key.
-- The imageTable can have other kinds of values also
-- In the Lua Scenario Template, it is the object file
--
-- This system allows for an image object to be stored in the state
-- table and referenced later.  The key corresponding to the image in the
-- imageTable is found, and stored, and then that key is referenced
-- when the image is needed.

local imageTable = "imageTableNotSet"
local tableName = ""

local function setImageTable(table,tableNm)
    if type(tableName) ~="string" then
        error("setImageTable: second argument must be a string, and should be the name of this table."
            .."The name provided will be given as part of error messages, to help you debug.")
    end
    if type(table) ~="table" then
        error("setImageTable: first argument must be a table, but a "..type(table)..
        "was provided instead.")
    else
        imageTable = table
        tableName = tableNm
    end
end
text.setImageTable = setImageTable

    -- used to do a protected call on the imageTable,
    -- since trying to access a nil value from the
    -- object table results in an error, and
    -- we want a better error message
local function tableAccess(table,key)
    return table[key]
end

-- text.toImage(input) --> imageObject
-- input: one of
--      imageObject --> returns this input
--      string --> returns imageTable[input] if it is an imageObject, error otherwise
--      table --> returns civ.ui.loadImage(table[1],table[2],table[3],table[4],table[5])

local function toImage(input)
    if type(input) == "table" then
        -- the table contains the arguments for civ.ui.loadImage
        return civ.ui.loadImage(input[1],input[2],input[3],input[4],input[5])
    elseif type(input) == "string" then
        -- this corresponds to a key for the image table
        if type(imageTable) == "string" then
            error("text.toImage: The 'Image Table' has not been set.\n"
                .."Your input was this: "..input.."\n"
                .."If this is a key to a table, and table["..input.."] is the image you want\n"
                .."to use, then you have not run text.setImageTable(imageTable,tableNameString).\n"
                .."If your input is a file path to access the image, use the following as your argument:\n"
                .."{[1]=\""..input.."\",}")
        end
        
        local bool, val = pcall(tableAccess,imageTable,input)
        if bool and civ.isImage(val) then
            return val
        else
            error("text.toImage: "..tableName.."[\""..input.."\"] is not an image.\n"
            .."If "..input.."\n"
            .."is the file path to access the image, then you should write it as:\n"
            .."{[1]=\""..input.."\",}")
        end
    elseif civ.isImage(input) then
        return input
    else
        error("text.toImage: argument 1 has type "..type(input).."\n"
        .."but only tables, strings, and imageObjects are acceptable.")
    end
end
text.toImage = toImage

-- returns an error if any table or sub table consists of stuff other
-- than numbers and strings
local function validateArgumentTable(table,functionName)
    for key,value in pairs(table) do
        if type(key) ~= "string" and type(key) ~="number" then
            error(functionName..": the table submitted as an argument can only have numbers and strings as keys.")
        end
        if type(value) ~="string" and type(value) ~="number" and type(value) ~="table" then
            error(functionName..": the table submitted as an argument can only have numbers, strings, and tables as values.")
        end
        if type(value) == "table" then
            validateArgumentTable(value)
        end
    end
end

-- text.toStateImage(imageInput) --> string or stateSaveableTable
-- added this, since it makes more sense in the documentation
-- text.stateImageReference(imageInput) --> string or stateSaveableTable
--      transforms the imageInput to a reference that
--      can be saved in the state table, either the
--      key referencing the image in the imageTable,
--      or the table of commands to load the image with civ.ui.loadImage


local function stateImageReference(imageInput)
    if type(imageInput) == "table" then
        validateArgumentTable(imageInput,"stateImageReference")
        local bool, result = pcall(civ.ui.loadImage,imageInput[1],imageInput[2],imageInput[3],imageInput[4],imageInput[5])
        if bool then
            return imageInput
        else
            error("stateImageReference: the table\n"
                .."{[1]=\""..tostring(imageInput[1]).."\",\n"
                .." [2]="..tostring(imageInput[2])..", [3]="..tostring(imageInput[3])..",\n"
                .." [4]="..tostring(imageInput[4])..", [5]="..tostring(imageInput[5])..",}\n"
                .."Does not load a valid image when its values are provided to\n"
                .."civ.ui.loadImage.")
        end
    elseif type(imageInput) == "string" then
        if type(imageTable) == "string" then
            error("text.stateImageReference: The 'Image Table' has not been set.\n"
                .."Your input was this: "..input.."\n"
                .."If this is a key to a table, and table["..input.."] is the image you want\n"
                .."to use, then you have not run text.setImageTable(imageTable,tableNameString).\n"
                .."If your input is a file path to access the image, use the following as your argument:\n"
                .."{[1]=\""..input.."\",}")
        end
        local bool,result = pcall(tableAccess,imageTable,imageInput)
        if bool and civ.isImage(result) then
            return imageInput
        else
            error("text.stateImageReference: "..tableName.."[\""..imageInput.."\"] is not an image.\n"
            .."If "..imageInput.."\n"
            .."is the file path to access the image, then you should write it as:\n"
            .."{[1]=\""..imageInput.."\",}")
        end
    elseif civ.isImage(imageInput) then
        local imgKey = nil
        for key,value in pairs(imageTable) do
            if civ.isImage(value) and value == imageInput then
                imgKey = key
                break
            end
        end
        if imgKey then
            return imgKey
        else
            error("stateImageReference: the image provided is not in the "..tableName.." table.\n"
            .."An imageObject can't be saved to the state table directly, and\n"
            .."the imageOjbect provided is not a value in the "..tableName.." table,\n"
            .."so the corresponding key can't be saved in the state table.\n"
            .."If you think the image you provided IS in the "..tableName.." table,"
            .."you can provide the key it is saved in.  This error may be a result\n"
            .."of the fact that img1 = civ.ui.loadImage(\"myImage.bmp\")\n"
            .."img2 = civ.ui.loadImage(\"myImage.bmp\")\n"
            .."img1 == img2 returns false, since 2 different imageObjects are created.\n"
            .."Alternatively, you can provide a table `argTable` as an argument such that\n"
            .."civ.ui.loadImage(argTable[1],argTable[2],argTable[3],argTable[4],argTable[5])\n"
            .."loads your desired image.")
        end
    else
        error("text.stateImageReference: argument 1 has type "..type(input).."\n"
        .."but only tables, strings, and imageObjects are acceptable.")
    end
end
text.stateImageReference = stateImageReference
text.toStateImage = stateImageReference




-- linesInText(string) --> number
-- Determines how many lines of text are in a string, so that text boxes can be kept
-- to a manageable size
-- This can be improved by counting characters and font sizes
local function linesInText(string)
    local linesSoFar = 1
    -- if very first character in the string is a newline, don't count that as a line
    -- (i.e. subtract 1)
    if string:sub(1,1) == "\n" then
        linesSoFar = 0
    end
    for __ in string.gmatch(string,"\n") do
        linesSoFar = linesSoFar+1
    end
    return linesSoFar
end

-- splitTextForWindow(string,maxLines=linesPerWindow)-->string,string or nil
-- Takes a string, and splits it into two strings if it is too long
-- for a single window.  If the string fits in one window, the second return value is nil
local function splitTextForWindow(string,maxLines)
    maxLines = maxLines or linesPerWindow
    local firstPageBreakStart,firstPageBreakEnd = string.find(string,pageBreakControl)
    firstPageBreakStart = firstPageBreakStart or math.huge -- allows for simple comparison check
    -- to see if a pagebreak starts in a string segment
    

    local function tooMuchText(stringSegment)
        return linesInText(stringSegment) > maxLines or stringSegment:len() >= firstPageBreakStart 
    end
    if not tooMuchText(string) then
        return string,nil
    end
    local function binarySearch(string,knownLow,knownHigh)
        if knownLow >= knownHigh -1 then
            return knownLow
        end
        -- if difference between knownLow and knownHigh >=2, then the gap
        -- becomes smaller, if not, then we returned above, so binarySearch terminates
        local newBoundary = (knownLow+knownHigh)//2
        if tooMuchText(string:sub(1,newBoundary)) then
            return binarySearch(string,knownLow,newBoundary)
        else
            return binarySearch(string,newBoundary,knownHigh)
        end
    end
    local lastCharIndex = binarySearch(string,1,string:len())
    -- If there is a page break, the binary search will stop at the character before the pagebreak
    -- starts (since tooMuchText returns true if the length of the stringSegment is longer than the first
    -- location of the pagebreak.  That means lastCharIndex+1 == firstPageBreakStart, and the pagebreak
    -- should be removed from the remaining string
    if lastCharIndex + 1 < firstPageBreakStart then
        -- no page break to remove
        return string:sub(1,lastCharIndex),string:sub(lastCharIndex+1)
    else
        -- remove page break control sequence from remaining string
        return string:sub(1,lastCharIndex),string:sub(firstPageBreakEnd+1)
    end
end

-- text.addMultiLineTextToDialog(text,dialogObject) --> void
-- adds text that is in multiple lines to a dialog object,
-- performing all necessary splitlines
local function addMultiLineTextToDialog(text,dialog)
    local lineTable = {func.splitlines(text)}
    for i=1,#lineTable do
        dialog:addText(lineTable[i])
    end
end
text.addMultiLineTextToDialog = addMultiLineTextToDialog

--  text.simple(string or tableOfStrings,title="",imageInfo=nil) --> void
--  shows a text box with the string and title, splitting
--  into multiple text boxes if the string is very long.
--  If a table of strings is input, each string is shown in
--  order starting at tableOfStrings[1]
--
local function simple(stringOrTable,boxTitle,imageInfo)
    boxTitle = boxTitle or ""
    imageInfo = imageInfo and toImage(imageInfo)
    if type(stringOrTable)=="string" then
        local remainingString = stringOrTable
        local textToShow = nil
        repeat
            textToShow,remainingString = splitTextForWindow(remainingString)
            local textBox = civ.ui.createDialog()
            textBox.title = boxTitle
            if imageInfo then
                textBox:addImage(imageInfo)
            end
            if textToShow then
                addMultiLineTextToDialog(textToShow,textBox)
                textBox:show()
            end
        until(remainingString == nil)
    elseif type(stringOrTable)=="table" then
        for i=1,#stringOrTable do
            if type(stringOrTable[i]) ~= "string" then
                error("text.simple must have a string or a table of strings as the first argument.")
            end
            simple(stringOrTable[i],boxTitle,imageInfo)
        end
    else
        error("text.simple must have a string or a table of strings as the first argument.")
    end
end
text.simple = simple


-- Pending Message Specification
-- .messageBody = string
--      The message to be displayed to the current player
-- .messageTitle = string or nil
--      The title of the text box for the message
--      nil means no title
-- .archiveTitle = string or nil
--      The title of the message in the archive menu
--      nil means don't archive message
-- .broadcast = bool or nil
--      If true, message will be displayed even if player is currently
--      an AI
--      false or nil means message will only be shown when the tribe is
--      played by a human
--  .messageImage = stateTableReady image

-- Archived Message Specification
--  .messageBody =string
--      The message to be displayed in the archive
--  .messageTitle = string or nil
--      The title of the text box of the message
--  .archiveTitle = string
--      The title of the message in the archive menu
--  .archiveTurn = integer
--      The turn the message was archived
--  .notHidden = bool
--      If true, message appears in the archive menu
--      If false, player must ask to display hidden messages
--  .markedForPurging = bool or nil
--      If true, message will be purged when purging operation is run
--  .messageImage = stateTableReady image
--
-- Largest index is the most recently archived item, and will be displayed first
-- in the archive

-- text.addToArchive(tribe or TribeID,messageBody,messageTitle,archiveTitle,imageInfo)-->void
-- Adds a message to a tribe's archive
local function addToArchive(tribeID,messageBody,messageTitle,archiveTitle,imageInfo)
    if civ.isTribe(tribeID) then
        tribeID = tribeID.id
    end
    local archivedMessage = {}
    archivedMessage.messageBody = messageBody
    archivedMessage.messageTitle = messageTitle
    archivedMessage.archiveTitle = archiveTitle
    archivedMessage.notHidden = true
    archivedMessage.archiveTurn = civ.getTurn()
    archivedMessage.messageImage = imageInfo and stateImageReference(imageInfo)
    local archiveTable = textState.archive[tribeID]
    archiveTable[#archiveTable+1] = archivedMessage
end
text.addToArchive=addToArchive

--  text.displayNextOpportunity(tribe or tableOfTribes,messageBody,messageTitle="",
--              archiveTitle=nil, broadcast=nil,imageInfo = nil)
--  Displays a message to a tribe (either object or id) at the next possible opportunity,
--  either immediately (if the tribe is active), or after the next production phase
--  imageInfo and broadcast can be in either order.  The function will figure it out
--  I would have made broadcast last, but can't for backwards compatibility
--  broadcast is either boolean or nil, anything else goes to image
local function displayNextOpportunity(tribeOrTable,messageBody,messageTitle,
                archiveTitle,arg5,arg6)
    local broadcast = nil
    local stateReadyImage = nil
    local function setArgument(arg)
        if type(arg) == "boolean" then
            broadcast = arg
        elseif type(arg) ~= "nil" then
            stateReadyImage = stateImageReference(arg)
        end
    end
    setArgument(arg5)
    setArgument(arg6)
    if type(messageBody)~="string" then
        error("text.displayNextOpportunity: messageBody (arg 2) must be a string. Current Type is "..type(messageBody)..".")
    end
    messageTitle = messageTitle or ""
    if type(messageTitle)~="string" then
        error("text.displayNextOpportunity: messageTitle (arg 3) must be a string or nil. Current Type is "..type(messageTitle)..".")
    end
    if archiveTitle and type(archiveTitle) ~= "string" then
        error("text.displayNextOpportunity: archiveTitle (arg 4) must be a string or nil. Current Type is "..type(archiveTitle)..".")
    end
    if civ.isTribe(tribeOrTable) then
        tribeOrTable = tribeOrTable.id
    end
    if type(tribeOrTable) ~= "table" and type(tribeOrTable) ~= "number" then
        error("text.displayNextOpportunity: tribeOrTable (arg 1) must be a tribe object, integer, or table of tribe objects or integers.  Current Type is "..type(tribeOrTable)..".")
    end
    if type(tribeOrTable) == "number" then 
        local tribeID = tribeOrTable
        if civ.getTribe(tribeID) == civ.getCurrentTribe() then
            if civ.getTribe(tribeID).isHuman or broadcast then
                simple(messageBody,messageTitle,stateReadyImage)
            end
            if archiveTitle then
                addToArchive(tribeOrTable,messageBody,messageTitle,archiveTitle,stateReadyImage)
            end
        else
            local pendingMessage = {}
            pendingMessage.messageBody=messageBody
            pendingMessage.messageTitle=messageTitle
            pendingMessage.archiveTitle=archiveTitle
            pendingMessage.broadcast = broadcast
            pendingMessage.messageImage = stateReadyImage
            local pendingMessageList = textState.pendingMessages[tribeID]
            pendingMessageList[#pendingMessageList+1] = pendingMessage
        end
    elseif type(tribeOrTable) == "table" then
        for __,tribe in pairs(tribeOrTable) do
            displayNextOpportunity(tribe,messageBody,messageTitle,archiveTitle,broadcast,stateReadyImage)
        end
    end
end
text.displayNextOpportunity=displayNextOpportunity

-- text.displayAccumulatedMessages() --> void
-- displays to the current player all messages that were to be displayed
-- at the next opportunity, then either archives or deletes the messages.
-- meant to go in the after production event
local function displayAccumulatedMessages()
    local tribeID = civ.getCurrentTribe().id
    local pendingMessagesTable = textState.pendingMessages[tribeID]
    for i=1,#pendingMessagesTable do
        local message = pendingMessagesTable[i]
        if civ.getCurrentTribe() == civ.getPlayerTribe() or message.broadcast then
            simple(message.messageBody,message.messageTitle,message.messageImage)
        end
        if message.archiveTitle then
            addToArchive(tribeID,message.messageBody,message.messageTitle,message.archiveTitle,message.messageImage)
        end
    end
    -- remove all pending messages for the active tribe, since they have been displayed
    for index,value in pairs(pendingMessagesTable) do
        pendingMessagesTable[index] = nil
    end
end
text.displayAccumulatedMessages = displayAccumulatedMessages


--  Menu Table Specification
--  menuTable[i]=optionName is the i'th option that will appear in the menu
--  and menu will return i if option is chosen
--  optionName will be a string
--  start counting at 1, can skip numbers (incl. 1), but don't have other entries in table

-- text.menu(menuTable,menuText,menuTitle="",canCancel=false,menuPage=1)-->integer,integer
-- returns the key of the menu table of the option chosen, second parameter returns menu page of selection
-- menuText is displayed above the options
-- menuTitle is the title of the menu
-- canCancel if true, offers a 'cancel' option on each page, returns 0 if selected
--           if false, there is no cancel option
-- menuPage is the "page" of the menu that is to be opened
-- imageInfo a way to get an image, either key for the imageTable, an imageObject,
--          or a table of arguments for civ.ui.loadImage
--  Arguments 4,5,6 (canCancel,imageInfo,menuPage) can be in any order; the code will
--  figure out which is which
--local function menu(menuTable,menuText,menuTitle,canCancel, menuPage,imageInfo)
local function menu(menuTable,menuText,menuTitle,arg4, arg5,arg6)
    local canCancel = false
    local menuPage = 1
    local image = nil
    local function setArgument(arg)
        if type(arg) == "boolean" then
            canCancel = arg
        elseif type(arg) =="number" then
            menuPage = arg
        elseif type(arg) ~= "nil" then
            image = toImage(arg)
        end
    end
    setArgument(arg4)
    setArgument(arg5)
    setArgument(arg6)

    local menuTextLines = linesInText(menuText)
    menuTitle = menuTitle or ""
    menuPage = menuPage or 1
    local menuTableEntries = 0
    local maxMenuIndex = 0
    for index,val in pairs(menuTable) do
        menuTableEntries = menuTableEntries+1
        if index > maxMenuIndex then
            maxMenuIndex = index
        end
    end
    -- find the number of options possible per window
    -- the 2 is the forward and backward 
    local optionsPerPage = linesPerWindow - menuTextLines - 2
    if canCancel then
        optionsPerPage = optionsPerPage -1
    end
    local numberOfMenuOptions = menuTableEntries
    if numberOfMenuOptions <= optionsPerPage+2 then
        local menuDialog = civ.ui.createDialog()
        menuDialog.title = menuTitle
        addMultiLineTextToDialog(menuText,menuDialog)
        for i=1,maxMenuIndex do
            if menuTable[i] then
                menuDialog:addOption(menuTable[i],i)
            end
        end
        if canCancel then
            menuDialog:addOption("Cancel",0)
        end
        if image then
            menuDialog:addImage(image)
        end
        return menuDialog:show(),1
    end
    -- menu has too many options, so must be split into multiple pages
    local numberOfPages = math.ceil(menuTableEntries/optionsPerPage)
    local menuDialog = civ.ui.createDialog()
    if menuPage > numberOfPages then
        menuPage = numberOfPages
    elseif menuPage < 1 then
        menuPage = 1
    end
    menuDialog.title = menuTitle.." Page "..tostring(menuPage).." of "..tostring(numberOfPages)
    addMultiLineTextToDialog(menuText,menuDialog)
    if menuPage < numberOfPages then
        menuDialog:addOption("Next Page",-2)
    end
    if menuPage > 1 then
        menuDialog:addOption("Previous Page",-1)
    end
    local actualEntriesCount = 0
    -- this allows for missing keys in the menuTable
    -- go through all possible menu entries, counting each valid entry
    -- when you reach an entry count corresponding to the menu page you are supposed
    -- to be on, start adding entries to the menu dialog, until you get beyond that point
    for j = 1,maxMenuIndex do
        if menuTable[j] then
            actualEntriesCount = actualEntriesCount+1
            if actualEntriesCount >= ((menuPage-1)*optionsPerPage)+1 and
                actualEntriesCount <= math.min(menuPage*optionsPerPage,menuTableEntries) then
                menuDialog:addOption(menuTable[j],j)
            end
        end
    end
    if canCancel then
        menuDialog:addOption("Cancel",0)
    end
    if image then
        menuDialog:addImage(image)
    end
    local choice = menuDialog:show()
    if choice == -2 then
        return menu(menuTable,menuText,menuTitle,canCancel,menuPage+1,image)
    elseif choice == -1 then
        return menu(menuTable,menuText,menuTitle,canCancel,menuPage-1,image)
    elseif choice == 0 then
        return 0,menuPage
    else
        return choice,menuPage
    end
end
text.menu = menu

-- text.displayArchivedMessage(archivedMessage,archivePage=1,displayArchiveTable=nil,
--                              displayArchiveTableIndex=nil,
--                              archiveTitle = nil,
--                              archiveMessage = nil,
--                              showHidden = false,
--                              tribe=activeTribe,)
-- archivedMessage is an "Archived Message" (specified earlier)
-- archivePage is the page of the archive menu to return to
-- displayArchiveTable is the table of archived messages, for using "previous" and "next" options
--      "previous" and "next" not available if this not specified
-- displayArchiveTableIndex is the index in displayArchiveTable, for use with "previous" and "next" options
-- archiveTitle,archiveMessage,showHidde,tribe are arguments to use openArchive again
local function displayArchivedMessage(archivedMessage,archivePage,displayArchiveTable,displayArchiveTableIndex,
                archiveTitle,archiveMessage,showHidden,tribe)
    archiveTitle = archiveTitle or "Archived Messages"
    archiveMessage = archiveMessage or "Choose a message to review."
    archivePage = archivePage or 1
    showHidden = showHidden or false
    tribe = tribe or civ.getCurrentTribe()
    simple(archivedMessage.messageBody,archivedMessage.messageTitle,archivedMessage.messageImage)
    local chosenOption = nil
    repeat
        local menuOptionList = {}
        if displayArchiveTableIndex and displayArchiveTable then
            if displayArchiveTableIndex < #displayArchiveTable then
                menuOptionList[1] = "Next"
            end
            if displayArchiveTableIndex > 1 then
                menuOptionList[2] = "Previous"
            end
        end
        menuOptionList[3] = "Menu"
        menuOptionList[4] = "Close"
        if archivedMessage.notHidden then
            menuOptionList[5] = "Hide"
        else
            menuOptionList[5] = "Unhide"
        end
        if archivedMessage.markedForPurging then
            menuOptionList[6] = "Clear purging mark"
        else
            menuOptionList[6] = "Mark for purging"
        end
        menuOptionList[7] = "Read again."
        chosenOption = menu(menuOptionList,"","",false,1)
        if chosenOption == 5 then
            archivedMessage.notHidden = not(archivedMessage.notHidden)
        end
        if chosenOption == 6 then
            archivedMessage.markedForPurging = not(archivedMessage.markedForPurging)
        end
    until( chosenOption ~= 5 and chosenOption ~= 6)
    if chosenOption == 1 then
        return displayArchivedMessage(displayArchiveTable[displayArchiveTableIndex+1],archivePage,
                displayArchiveTable,displayArchiveTableIndex+1,archiveTitle,archiveMessage,
                showHidden,tribe)
    elseif chosenOption == 2 then
        return displayArchivedMessage(displayArchiveTable[displayArchiveTableIndex-1],archivePage,
                displayArchiveTable,displayArchiveTableIndex-1,archiveTitle,archiveMessage,
                showHidden,tribe)
    elseif chosenOption == 3 then
        -- it appears that I must refer to openArchive as text.openArchive, since when this function is
        -- defined, openArchive is not yet defined, so I have to make it get the result from a table
        -- once it is needed.  I might have been able to make an openArchive local variable outside this function
        -- before it is defined
        return text.openArchive(archiveTitle,archiveMessage,archivePage,showHidden,tribe)
    elseif chosenOption == 4 then
        return 
    elseif chosenOption == 7 then
        return displayArchivedMessage(archivedMessage,archivePage,displayArchiveTable,displayArchiveTableIndex,
                archiveTitle,archiveMessage,showHidden,tribe)
    end
end
text.displayArchivedMessage = displayArchivedMessage

    
-- text.openArchive(archiveTitle="Archived Messages",archiveText="Choose a message to review.",
--                  archivePage=1,
--                  showHidden=false,tribe=activeTribe)-->void
-- Allows the player to review the archived messages
-- archiveTitle allows the user to change the title of the archive,
--      e.g. to Newspaper
-- archiveText allows the user to change the menuText for the archive
-- archivePage is the initial page of the archive menu
-- showHidden shows archived messages that have been marked hidden if true
-- tribe chooses the archive to open, active tribe by default
--
local function openArchive(archiveTitle,archiveMessage,archivePage,showHidden,tribe)
    archiveTitle = archiveTitle or "Archived Messages"
    archiveMessage = archiveMessage or "Choose a message to review."
    archivePage = archivePage or 1
    showHidden = showHidden or false
    tribe = tribe or civ.getCurrentTribe()
    local tribeID = tribe.id
    -- table for the archive menu
    local menuTable = {}
    -- archived messages available for selection
    local displayArchiveTable = {}
    local index = 1
    local fullArchive = textState.archive[tribeID]
    for i=#fullArchive,1,-1 do
        if fullArchive[i].notHidden or showHidden then
            local turnsAgo = civ.getTurn()-fullArchive[i].archiveTurn
            local hiddenPurge = ""
            if not fullArchive[i].notHidden then
                hiddenPurge = hiddenPurge..", H"
            end
            if fullArchive[i].markedForPurging then
                hiddenPurge = hiddenPurge..", P"
            end
            if turnsAgo == 0 then
                menuTable[index] = fullArchive[i].archiveTitle.." (This Turn"..hiddenPurge..")"
            elseif turnsAgo == 1 then
                menuTable[index] = fullArchive[i].archiveTitle.." (Last Turn"..hiddenPurge..")"
            else
                menuTable[index] = fullArchive[i].archiveTitle.." ("..tostring(turnsAgo).." Turns Back"..hiddenPurge..")"
            end
            displayArchiveTable[index] = fullArchive[i]
            index = index+1
        end
    end
    local hideIndex = index
    if showHidden then
        menuTable[hideIndex] = "Hide messages marked hidden"
        menuTable[hideIndex+1] = "Delete messages marked for purging"
    else
        menuTable[hideIndex] = "Show messages marked hidden"
    end
    local choice,menuPage = menu(menuTable,archiveMessage,archiveTitle,true,archivePage)
    if choice == 0 then
        return 
    elseif choice == hideIndex then
        return openArchive(archiveTitle,archiveMessage,1,not(showHidden),tribe)
    elseif choice == hideIndex+1 then
        text.purgeArchive(tribe)
        return openArchive(archiveTitle,archiveMessage,1,showHidden,tribe)
    else
        return displayArchivedMessage(displayArchiveTable[choice],menuPage,displayArchiveTable,choice,archiveTitle,archiveMessage,showHidden,tribe)
    end
end
text.openArchive = openArchive

-- text.purgeArchive(tribeOrTribeID) --> void
-- purges all archived messages that have been marked for purging
-- for the current tribe
local function purgeArchive(tribeOrID)
    local tribeID = tribeOrID
    if civ.isTribe(tribeID) then
        tribeID = tribeID.id
    end
    -- keep the table with the archive in oldArchive
    local oldArchive = textState.archive[tribeID]
    --put a new, empty table in the place of the archives 
    textState.archive[tribeID]={}
    local newArchiveIndex = 1
    for i=1,#oldArchive do
        if not oldArchive[i].markedForPurging then
            textState.archive[tribeID][newArchiveIndex] = oldArchive[i]
            newArchiveIndex=newArchiveIndex+1
        end
    end
end
text.purgeArchive = purgeArchive

-- text.deleteAIArchives()-->void
-- deletes all messages in archives owned by AI Tribes
local function deleteAIArchives()
    for i=0,7 do
        if not civ.getTribe(i).isHuman then
            for __,archiveMessage in pairs(textState.archive[i]) do
                archiveMessage.markedForPurging = true
            end
            purgeArchive(i)
        end
    end
end
text.deleteAIArchives = deleteAIArchives

-- text.substitute(rawText,substitutionTable)-->string
-- substitutes %STRING1 with tostring(substitutionTable[1])
-- substitutes %STRING2 with tostring(substitutionTable[2])
--      .
--      .
--      .
-- substitutes %STRING9 with tostring(substitutionTable[9])
-- and 
-- substitutes %STRING0 with tostring(substitutionTable[0])
-- Note: %STRING10 and above forbidden, since the %STRING1 in %STRING10 might
--      be substituted first
local function substitute(rawText,substitutionTable)
    for i=0,9 do
        if substitutionTable[i] then
            rawText = string.gsub(rawText,"%%STRING"..tostring(i),tostring(substitutionTable[i]))
        end
    end
    return rawText
end
text.substitute = substitute


-- text.convertTableToColumnText(columnTable,dataTable,borderWidth)-->string
-- An example of the usage of this function can be found in the file
-- exampleConvertTableToColumnText.lua
-- which is a sample events.lua file
--[[
-- convertTableToColumnText provided by
columnText.lua
v1.0
by Knighttime
]]
local function convertTableToColumnText (columnTable, dataTable, borderWidth) --> string
    local LINE_DELIMITER = "\n^"
    local CHAR_PIXEL_WIDTH = charSize -- line added by Prof. Garfield to interface with this module
    local function round (decimal) --> integer
    	return math.floor(decimal + 0.5)
    end
	local messageText = ""
	if borderWidth == nil or borderWidth < 1 then
		borderWidth = 1
	end
	local columnCharPixelWidth = { }
	for columnNumber, columnData in ipairs(columnTable) do
		columnCharPixelWidth[columnNumber] = 0
		for _, data in ipairs(dataTable) do
			local pixelWidth = 0
			local stringData = tostring(data[columnData.column])
			if data[columnData.column] == nil then
				stringData = ""
			end
			for i = 1, #stringData do
				local charPixels = CHAR_PIXEL_WIDTH[string.byte(stringData, i)]
				if charPixels == nil then
					print("WARNING: text.lua found no pixel length for character " .. tostring(string.byte(stringData, i))) -- changed columnText to text, to reflect this module p.g.
					charPixels = 0
				end
				pixelWidth = pixelWidth + charPixels
			end
			if pixelWidth > columnCharPixelWidth[columnNumber] then
				columnCharPixelWidth[columnNumber] = pixelWidth
			end
		end
	end
	for _, data in ipairs(dataTable) do
		messageText = messageText .. LINE_DELIMITER
		local pixelDifferenceThisLine = 0
		for columnNumber, columnData in ipairs(columnTable) do
			local pixelWidth = 0
			local stringData = tostring(data[columnData.column])
			if data[columnData.column] == nil then
				stringData = ""
			end
			for i = 1, #stringData do
				local charPixels = CHAR_PIXEL_WIDTH[string.byte(stringData, i)]
				if charPixels == nil then
					charPixels = 0
				end
				pixelWidth = pixelWidth + charPixels
			end
			local pixelsNeeded = columnCharPixelWidth[columnNumber] - pixelWidth
			local spacesNeeded = round((pixelsNeeded + pixelDifferenceThisLine) / CHAR_PIXEL_WIDTH[32])
			pixelDifferenceThisLine = (pixelsNeeded + pixelDifferenceThisLine) - (spacesNeeded * CHAR_PIXEL_WIDTH[32])
			local columnBorderWidth = borderWidth
			if columnNumber == 1 then
				columnBorderWidth = 0
			end
			if columnData.align == "right" then
				messageText = messageText .. string.rep(" ", columnBorderWidth) .. string.rep(" ", spacesNeeded) .. stringData
			elseif columnData.align == "center" then
				messageText = messageText .. string.rep(" ", columnBorderWidth) .. string.rep(" ", round(spacesNeeded / 2)) .. stringData .. string.rep(" ", spacesNeeded - round(spacesNeeded / 2))
			else	-- default is left align
				messageText = messageText .. string.rep(" ", columnBorderWidth) .. stringData .. string.rep(" ", spacesNeeded)
			end
		end
	end
	return messageText
end
text.convertTableToColumnText = convertTableToColumnText

-- text.makeTableText(table) --> void
--      applies tostring on all table values, except other tables,
--      where it instead applies tostring on each of those table entries
local function makeTableText(table)
    for key,value in pairs(table) do
        if type(value) ~="table" then
            table[key]=tostring(value)
        else
            makeTableText(value)
        end
    end
end
text.makeTableText = makeTableText

-- text.copyTableAsText(table) --> table
--      creates a new table with the same keys and values, 
--      and replicates any subtables (with a new table),
--      All non-table values have tostring applied
local function copyTableAsText(table)
    -- base case for non-table values
    if type(table) ~="table" then
        return tostring(table)
    end
    local newTable = {}
    for key,value in pairs(table) do
        newTable[key] = copyTableAsText(value)
    end
    return newTable
end
text.copyTableAsText = copyTableAsText

-- text.simpleTabulation(tabulationData,title="",borderWidth=4) --> void
--      displays a formatted text based on the entries in in tabulationData
--      If table is large, it is split into multiple pages
--          tabulationData[m][n] is the value of the nth column in row m
--          tabulationData[0][n] is the header for the nth column
--          header is displayed on every page, nil means no header
--          columns are left alligned
--
local function simpleTabulation(tabulationData,title,borderWidth,page)
    title = title or ""
    page = page or 1
    borderWidth = borderWidth or 4
    local maxRows = linesPerWindow - 2 -- need two lines for previous/next
    if tabulationData[0] then
        maxRows = maxRows -1
    end
    local columnTable = {}
    local columnTotal= #tabulationData[1]
    for i=1,columnTotal do
        -- use a string for column name, since I want to make sure that 
        -- convertTableToColumnText will work, and I know it works with string keys
        columnTable[i] = {column="col"..tostring(i)}
    end
    local dataToShow = {}
    local index = 1
    if tabulationData[0] then
        local newRowTable = {}
        for i=1,columnTotal do
            newRowTable["col"..tostring(i)] = tostring(tabulationData[0][i])
        end
        dataToShow[index] = newRowTable
        index=index+1
    end
    if maxRows + 2 <= #tabulationData then -- don't need previous/next, since can be done on one page
        maxRows = maxRows + 2
    end
    for j=((page-1)*maxRows+1),math.min((page)*maxRows,#tabulationData) do
        local newRowTable = {}
        for i=1,columnTotal do
            newRowTable["col"..tostring(i)] = tostring(tabulationData[j][i])
        end
        dataToShow[index] = newRowTable
        index=index+1
    end
    local tableText = convertTableToColumnText(columnTable,dataToShow,borderWidth)
    if maxRows <= #tabulationData then
        return simple(tableText,title)
    end
    local backNextTable = {}
    if page == math.ceil(#tabulationData/maxRows) then
        backNextTable[1] = "Close"
    else
        backNextTable[2] = "Next"
    end
    if page > 1 then
        backNextTable[3] = "Previous"
    end
    local choice = menu(backNextTable,tableText,title,false)
    if choice == 1 then
        return
    elseif choice == 2 then
        return simpleTabulation(tabulationData,title,borderWidth,page+1)
    elseif choice == 3 then
        return simpleTabulation(tabulationData,title,borderWidth,page-1)
    end
end
text.simpleTabulation=simpleTabulation


-- text.simpleTabTableToText(tabulationData,borderWidth=4) --> string
--      Produces formatted text based on the entries in in tabulationData
--          tabulationData[m][n] is the value of the nth column in row m
--          tabulationData[0][n] is the header for the nth column (optional)
--          first row could also be used as the header
--          columns are left aligned
--          Two copies of borderWidth, since this was the old argument list 
-- text.simpleTabTableToText(tabulationData,title="",borderWidth=4) --> string
-- and title isn't actually necessary.  But, need backward compatibility

local function simpleTabTableToText(tabulationData,borderWidth1,borderWidth2)
    
    local borderWidth = 4
    if type(borderWidth1) == "number" then
        borderWidth = borderWidth1
    end
    if type(borderWidth2) == "number" then
        borderWidth = borderWidth2
    end
    local columnTable = {}
    local columnTotal= #tabulationData[1]
    for i=1,columnTotal do
        -- use a string for column name, since I want to make sure that 
        -- convertTableToColumnText will work, and I know it works with string keys
        columnTable[i] = {column="col"..tostring(i)}
    end
    local dataToShow = {}
    local index = 1
    if tabulationData[0] then
        local newRowTable = {}
        for i=1,columnTotal do
            newRowTable["col"..tostring(i)] = tostring(tabulationData[0][i])
        end
        dataToShow[index] = newRowTable
        index=index+1
    end
    for j=1,#tabulationData do
        local newRowTable = {}
        for i=1,columnTotal do
            newRowTable["col"..tostring(i)] = tostring(tabulationData[j][i])
        end
        dataToShow[index] = newRowTable
        index=index+1
    end
    local tableText = convertTableToColumnText(columnTable,dataToShow,borderWidth)
    return tableText
end
text.simpleTabTableToText = simpleTabTableToText

-- text.tabulationMenu(tabMenuTable,menuText,menuTitle,canCancel,menuPage=1)-->integer
--      Produces a menu based on menuTableData
--          tabMenuTable[m][n] is the value of the nth column in row m
--          returns the number m of the row selected
--          tabMenuTable must start at 1 and be uninterrupted
--          columns are left aligned

local function tabulationMenu(tabMenuTable,menuText,menuTitle,canCancel,menuPage)
    menuPage = menuPage or 1
    if tabMenuTable[0] then
        error("text.tabulationMenu, tabMenuTable (arg 1) can't have an entry in key 0."..
                "  If you want a header for each column, use the menuText argument (2).")
    end
    local menuTable = {func.splitlines(simpleTabTableToText(tabMenuTable))}
    return menu(menuTable,menuText,menuTitle,canCancel,menuPage)
end
text.tabulationMenu = tabulationMenu


-- text.tabulationWtihOptions(dataTable,columnTable,title="",borderWidth=4,headerRows=0,
--              firstPagePreviousSubstitute=nil,lastPageCloseSubstitute="Close",
--              regPageExtraOptionsTable={},lastPageExtraOptionsTable={},page=1)-->integer
--  dataTable[n] = table of key-value pairs to be displayed in the nth row
--  columnTable[m] = {column=dataKey,align=nil or "center" or "right" or "left"}
--          dataTable[n][dataKey] will be displayed in column n
--          align tells if the entry will be aligned left,right or center, nil means left
--  title is a string to be shown as the title of the text box
--  borderWidth is the minimum space between columns
--  headerRows is the number of rows that should be repeated at the top of each page
--  firstPagePreviousSubstitution = string or nil
--      if nil, the first page has no option in place of "previous"
--      if string, the option (which returns -1) is in the place of previous
--  lastPageCloseSubstitute = string or nil
--      if nil, "Close" is the option, and it returns 0
--      if string, the string is the option, and it returns 0
--  regPageExtraOptionsTable=nil or table of strings indexed by integers >=1
--      (integer keys do not need to be consecutive)
--      adds extra options at the bottom of each page, except the last page
--      in ascending order of key,
--      returns the key of the string
--  lastPageExtraOptionsTable=nil or table of strings indexed by integers >=1
--      (integer keys do not need to be consecutive)
--      adds extra options to the last page in ascending order of key,
--      returns the key of the string of the option chosen
--  page = integer
--      the page of the table to be displayed
--
local function tabulationWithOptions(dataTable,columnTable,title,borderWidth,headerRows,
                firstPagePreviousSubstitute,lastPageCloseSubstitute,regPageExtraOptionsTable,
                lastPageExtraOptionsTable,page)
    title = title or ""
    page = page or 1
    borderWidth = borderWidth or 4
    headerRows = headerRows or 0
    lastPageCloseSubstitute = lastPageCloseSubstitute or nil
    regPageExtraOptionsTable = regPageExtraOptionsTable or {}
    lastPageExtraOptionsTable = lastPageExtraOptionsTable or {}
    local regPageExtraOptionsNumber = 0
    local regPageExtraOptionsLargestKey = 0
    for key,value in pairs(regPageExtraOptionsTable) do
        regPageExtraOptionsNumber = regPageExtraOptionsNumber+1
        if key > regPageExtraOptionsLargestKey then
            regPageExtraOptionsLargestKey = key
        end
    end
    local lastPageExtraOptionsNumber = 0
    local lastPageExtraOptionsLargestKey = 0
    for key,value in pairs(lastPageExtraOptionsTable) do
        lastPageExtraOptionsNumber = lastPageExtraOptionsNumber+1
        if key > lastPageExtraOptionsLargestKey then
            lastPageExtraOptionsLargestKey = key
        end
    end
    local maxRowsRegPage = math.max(2,linesPerWindow - headerRows - regPageExtraOptionsNumber - 2) -- need two lines for previous/next
    local maxRowsLastPage =math.max(0, linesPerWindow - headerRows - lastPageExtraOptionsNumber - 2 )
    local dataRows = #dataTable - headerRows
    local numberOfRegularPages = dataRows//maxRowsRegPage
    if dataRows % maxRowsRegPage > maxRowsLastPage then
        -- this means there are too many left over data rows
        -- to fit on the last page
        numberOfRegularPages=numberOfRegularPages+1
    end
    local dataToShow = {}
    for i=1,headerRows do
        dataToShow[i]=dataTable[i]
    end
    local dataToShowIndex = headerRows+1
    for i=(page-1)*maxRowsRegPage+1,math.min(dataRows,page*maxRowsRegPage) do
        dataToShow[dataToShowIndex]=dataTable[i+headerRows]
        dataToShowIndex=dataToShowIndex+1
    end
    local menuTable={}
    -- menuTable must have an index starting at 1, and there are 4 possible default options,
    -- so, will add 5 to the menuTable key, and subtract afterward
    if page>numberOfRegularPages then
        -- doing last page
        menuTable[1] = lastPageCloseSubstitute
        if page == 1 then
            menuTable[4] = firstPagePreviousSubstitute
        else
            menuTable[3] = "Previous"
        end
        for i=1,lastPageExtraOptionsLargestKey do
            if lastPageExtraOptionsTable[i] then
                menuTable[i+5]=lastPageExtraOptionsTable[i]
            end
        end
    else
        -- doing some other page
        menuTable[2] = "Next"
        if page == 1 then
            menuTable[4] = firstPagePreviousSubstitute
        else
            menuTable[3] = "Previous"
        end
        for i=1,regPageExtraOptionsLargestKey do
            if regPageExtraOptionsTable[i] then
                menuTable[i+5]=regPageExtraOptionsTable[i]
            end
        end
    end
    local tableText = convertTableToColumnText(columnTable,dataToShow,borderWidth)
    local choice = menu(menuTable,tableText,title,false)
    -- undo addition of 5 to menu earlier
    choice = choice-5
    if choice == -4 then
        -- last page close was chosen
        return 0
    elseif choice == -3 then
        -- next was chosen
        return tabulationWithOptions(dataTable,columnTable,title,borderWidth,headerRows,
                firstPagePreviousSubstitute,lastPageCloseSubstitute,regPageExtraOptionsTable,
                lastPageExtraOptionsTable,page+1)
    elseif choice == -2 then
        return tabulationWithOptions(dataTable,columnTable,title,borderWidth,headerRows,
                firstPagePreviousSubstitute,lastPageCloseSubstitute,regPageExtraOptionsTable,
                lastPageExtraOptionsTable,page-1)
    elseif choice == -1 then
        -- first page previous substitute was chosen, so return -1
        return -1
    else
        -- some other menu choice was chosen
        return choice
    end
end
text.tabulationWithOptions=tabulationWithOptions


--  text.checkboxMenu(checkboxNameTable,checkboxStatusTable,menuText="",menuTitle="",menuPage=1)
--      checkboxNameTable[i] = string
--      is the line of text beside the checkbox in the menu.  Nil means option does not appear
--      Index starts at 1, appear in order, non numerical indices cause errors
--      checkboxStatusTable[i] = boolean or nil
--      if checkbox [i] is selected, checkboxStatusTable[i] is set to true, if unchecked, it is
--      set to false
--      menuText = string
--      Text shown before the checkboxes
--      menuTitle = string
--      title of the text box
--      menuPage = integer
--      If there is more than one page, the pages will be shown in turn
--      menuPage gives the page to display
--

local function checkboxMenu(checkboxNameTable,checkboxStatusTable,menuText,menuTitle,menuPage)
    local menuTextLines = linesInText(menuText)
    menuTitle = menuTitle or ""
    menuPage = menuPage or 1
    local menuTableEntries = 0
    local maxMenuIndex = 0
    for index, val in pairs(checkboxNameTable) do
        menuTableEntries = menuTableEntries+1
        if index > maxMenuIndex then
            maxMenuIndex = index
        end
    end
    local optionsPerPage = linesPerWindow - menuTextLines
    local numberOfPages = math.ceil(menuTableEntries/optionsPerPage)
    local menuDialog = civ.ui.createDialog()
    if numberOfPages > 1 then
        menuDialog.title = menuTitle.." Page "..tostring(menuPage).." of "..tostring(numberOfPages)
    else
        menuDialog.title = menuTitle
    end
    addMultiLineTextToDialog(menuText,menuDialog)
    local actualEntriesCount = 0
    -- this allows for missing keys in the menuTable
    -- go through all possible menu entries, counting each valid entry
    -- when you reach an entry count corresponding to the menu page you are supposed
    -- to be on, start adding entries to the menu dialog, until you get beyond that point
    local optionsDisplayedTable = {}
    for j = 1,maxMenuIndex do
        if checkboxNameTable[j] then
            actualEntriesCount = actualEntriesCount+1
            if actualEntriesCount >= ((menuPage-1)*optionsPerPage)+1 and
                actualEntriesCount <= math.min(menuPage*optionsPerPage,menuTableEntries) then
                menuDialog:addCheckbox(checkboxNameTable[j],j,checkboxStatusTable[j] or false)
                optionsDisplayedTable[j] = true
            end
        end
    end
    local result = menuDialog:show()
    if result == -1 then
        -- exit pressed
        return

    elseif result == 0 then
        -- OK pressed
        for key,value in pairs(optionsDisplayedTable) do
            checkboxStatusTable[key] = menuDialog:getCheckboxState(key)
        end
        if menuPage == numberOfPages then
            return
        else
            return checkboxMenu(checkboxNameTable,checkboxStatusTable,menuText,menuTitle,menuPage+1)
        end
    end
end
text.checkboxMenu = checkboxMenu




local digitGroupSeparator = ","

--  text.groupDigits(integer)-->string
--  takes floor of number, and adds a digit group
--  separator to split the integer, ie
--  12345 becomes 12,345
local function groupDigits(amount)
    amount = math.floor(amount)
    local numString = tostring(amount)
    
    local function addSeparator(numString)
        local digits = string.len(numString)
        if digits <= 3 then
            return numString
        elseif digits % 3 > 0 then
            return numString:sub(1,digits % 3)..digitGroupSeparator..addSeparator(numString:sub(digits%3 +1))
        else
            return numString:sub(1,3)..digitGroupSeparator..addSeparator(numString:sub(4))
        end
    end
    return addSeparator(tostring(amount))
end
text.groupDigits = groupDigits


--  text.setDigitGroupSeparator(string)-->void
--  sets the digit group separator
--  default digit group separator is ","
--  For no digit group separator, use ""
local function setDigitGroupSeparator(string)
    if type(string) ~= "string" then
        error("text.setDigitGroupSeparator: must have a string (even empty string) as an argument.")
    end
    digitGroupSeparator = string
end
text.setDigitGroupSeparator = setDigitGroupSeparator
--
--
local moneyConvert = "%STRING1 Gold"

--  text.money(amount) --> string
--  converts an integer to an appropriate string denoting money
local function money(amount)
    if type(moneyConvert) == "string" then
        return text.substitute(moneyConvert,{text.groupDigits(amount)})
    else
        return moneyConvert(amount)
    end
end
text.money = money


--  text.setMoney(string)-->void
--  sets the method of conversion of an integer to a money amount
--  text.money will subsitute %STRING1 for the money amount,
--  with digit separators added, and return the string

local function setMoney(convertString)
    if type(convertString) ~= "string" then
        error("text.setMoney: must be given a string as an argument.")
    end
    moneyConvert = convertString
end

text.setMoney = setMoney


local veteranTitle = "Veteran"
local shortVeteranTitle = "Vet"
--  text.getVeteranTitle()-->string
local function getVeteranTitle()
    return veteranTitle
end
text.getVeteranTitle = getVeteranTitle

--  text.setVeteranTitle(string)-->void
-- sets the string that is returned by text.getVeteranTitle()
local function setVeteranTitle(vetTitle)
    if type(vetTitle)~="string" then
        error("text.setVeteranTitle: argument must be a string.")
    end
    veteranTitle = vetTitle
end
text.setVeteranTitle = setVeteranTitle


--  text.getShortVeteranTitle()-->string
local function getShortVeteranTitle()
    return shortVeteranTitle
end
text.getShortVeteranTitle = getShortVeteranTitle
--  text.setShortVeteranTitle(string)-->void
--  sets the string returned by text.getShortVeteranTitle()
local function setShortVeteranTitle(shortVetTitle)
    if type(shortVetTitle) ~="string" then
        error("text.setShortVeteranTitle: argument must be a string.")
    end
    shortVeteranTitle = shortVetTitle
end
text.setShortVeteranTitle = setShortVeteranTitle

-- text.makeReverseListNoGaps(tableOfStrings,listLength=nil)-->string
--      Prints the values of the table, starting with the value
--      indexed by the largest integer, and moving backwards to 1
--      provides 'and' between the last 2 elements, and an
--      Oxford comma if there are 3 or more
--      no gaps may be in the table provided
--      If listLength is provided, that will be considered the
--      largest element, otherwise #tableOfStrings is used
local function makeReverseListNoGaps(tableOfStrings,listLength)
    listLength = listLength or #tableOfStrings
    if listLength == 1 then
        return tableOfStrings[1]
    elseif listLength == 2 then
        return tableOfStrings[2].." and "..tableOfStrings[1]
    end
    -- if here, list is of length 3 or more
    local listString = ""
    for i=listLength,2,-1 do
        listString = listString..tableOfStrings[i]..", "
    end
    -- the list of 3 or more elements has reached the last element
    listString = listString.."and "..tableOfStrings[1]
    return listString
end
text.makeReverseListNoGaps = makeReverseListNoGaps



-- text.niceList(table)-->string
--      returns a string with all the items in the list printed out,
--      with 'and' between the last 2, and an Oxford comma if there
--      are at least 3 elements
--      Only values indexed by integers are printed, starting with
--      the smallest integer.  Gaps are allowed
--      tostring is applied to all values in the list
local function niceList(table)
    local minValue = math.huge
    local maxValue = -math.huge
    local count = 0
    for index,value in pairs(table) do
        if type(index) == "number" and math.floor(index) == index then
            count = count+1
            if index > maxValue then
                maxValue = index
            end
            if index < minValue then
                minValue = index
            end
        end
    end
    local listTable = {}
    -- We're reversing the list to use
    -- makeReverseListNoGaps, so our lowest entry must be placed
    -- in place 'count', and decrement from there
    local nextIndex = count
    for i=minValue,maxValue,1 do
        if table[i] ~= nil then
            listTable[nextIndex] = tostring(table[i])
            nextIndex = nextIndex-1
        end
    end
    return makeReverseListNoGaps(listTable,count)
end
text.niceList = niceList

-- text.coordinates(tile)-->string
--  returns the coordinate triple in the form of a string
local function coordinates(tile)
    return text.substitute("%STRING1,%STRING2,%STRING3",{tile.x,tile.y,tile.z})
end
text.coordinates = coordinates

-- String manipulation

-- text.lpad(str,length,character) --> string | By Pablostuka
-- pad "character" to the left of string "str" to max of "lenght" by Pablostuka
local function lpad(str,length,character)
    return string.rep(character,length-#str)..str
end
text.lpad = lpad

-- text.rpad(str,length,character) --> string | By Pablostuka
-- pad "character" to the right of string "str" to max of "lenght"
local function rpad(str,length,character)
    return str..string.rep(character, length-#str)
end
text.rpad = rpad

-- text.pad(str,length,character) --> string | By Pablostuka
-- pad "character" on both sides of string "str" to max of "lenght"
local function pad(str,length,character)
    -- I use half of both length and str to ensure it's all properly centered
    local half = rpad(str,(length/2)+math.ceil(#str/2),character)
    -- rpad the already lpadded string to the full length
    local full = lpad(half,length,character)
    -- Ensure it doesn't exceed the max of lenght
    return string.sub(full, 1, length)
end
text.pad = pad



local extendedASCII = {
[128] = "€",
--[129] = "",
[130] = "‚",
[131] = "ƒ",
[132] = "„",
[133] = "…",
[134] = "†",
[135] = "‡",
[136] = "ˆ",
[137] = "‰",
[138] = "Š",
[139] = "‹",
[140] = "Œ",
--[141] = "",
[142] = "Ž",
--[143] = "",
--[144] = "",
[145] = "‘",
[146] = "’",
[147] = "“",
[148] = "”",
[149] = "•",
[150] = "–",
[151] = "—",
[152] = "˜",
[153] = "™",
[154] = "š",
[155] = "›",
[156] = "œ",
--[157] = "",
[158] = "ž",
[159] = "Ÿ",
--[160] = " ",
[161] = "¡",
[162] = "¢",
[163] = "£",
[164] = "¤",
[165] = "¥",
[166] = "¦",
[167] = "§",
[168] = "¨",
[169] = "©",
[170] = "ª",
[171] = "«",
[172] = "¬",
[173] = "­",
[174] = "®",
[175] = "¯",
[176] = "°",
[177] = "±",
[178] = "²",
[179] = "³",
[180] = "´",
[181] = "µ",
[182] = "¶",
[183] = "·",
[184] = "¸",
[185] = "¹",
[186] = "º",
[187] = "»",
[188] = "¼",
[189] = "½",
[190] = "¾",
[191] = "¿",
[192] = "À",
[193] = "Á",
[194] = "Â",
[195] = "Ã",
[196] = "Ä",
[197] = "Å",
[198] = "Æ",
[199] = "Ç",
[200] = "È",
[201] = "É",
[202] = "Ê",
[203] = "Ë",
[204] = "Ì",
[205] = "Í",
[206] = "Î",
[207] = "Ï",
[208] = "Ð",
[209] = "Ñ",
[210] = "Ò",
[211] = "Ó",
[212] = "Ô",
[213] = "Õ",
[214] = "Ö",
[215] = "×",
[216] = "Ø",
[217] = "Ù",
[218] = "Ú",
[219] = "Û",
[220] = "Ü",
[221] = "Ý",
[222] = "Þ",
[223] = "ß",
[224] = "à",
[225] = "á",
[226] = "â",
[227] = "ã",
[228] = "ä",
[229] = "å",
[230] = "æ",
[231] = "ç",
[232] = "è",
[233] = "é",
[234] = "ê",
[235] = "ë",
[236] = "ì",
[237] = "í",
[238] = "î",
[239] = "ï",
[240] = "ð",
[241] = "ñ",
[242] = "ò",
[243] = "ó",
[244] = "ô",
[245] = "õ",
[246] = "ö",
[247] = "÷",
[248] = "ø",
[249] = "ù",
[250] = "ú",
[251] = "û",
[252] = "ü",
[253] = "ý",
[254] = "þ",
[255] = "ÿ",
}


-- text.international(string) --> string | inspired by Pablostuka, 
-- text.i(string) --> string (alias for text.international)
-- substitutes extended ascii characters for the correct character
-- (I'm pretty sure this is a formatting issue, where the text editor
-- shows an extended ascii character, but records it as 2 characters,
-- so a formatting change might also be effective, but this is still
-- likely to be a quick fix in many circumstances)
local function international(str)
    for charCode,charRepresentation in pairs(extendedASCII) do
        str = string.gsub(str,charRepresentation,string.char(charCode))
    end
    return str
end
text.international = international
text.i = international

-- lowerToUpper[lowerCaseChar] = upperCaseChar
local lowerToUpper = {}
for charCode = 224,254 do
    if charCode ~= 247 then -- exclude division symbol/multiplication symbol
        lowerToUpper[string.char(charCode)] = string.char(charCode-32)
    end
end
-- some extra lower/upper pairs
lowerToUpper[string.char(156)] = string.char(140)
lowerToUpper[string.char(154)] = string.char(138)
lowerToUpper[string.char(158)] = string.char(142)

-- text.upper(string) --> string
-- Makes string uppercase, including uppercasing the international characters
-- from the extended ASCII table
-- if you don't use international characters, string.upper is fine
local function upper(str)
    str = string.upper(str)
    for lowercase,uppercase in pairs(lowerToUpper) do
        str = string.gsub(str,lowercase, uppercase)
    end
    return str
end
text.upper = upper

-- text.lower(string) --> string
-- Makes string lowercase, including lowercasing the international characters
-- from the extended ASCII table
-- if you don't use international characters, string.lower is fine
local function lower(str)
    str = string.lower(str)
    for lowercase,uppercase in pairs(lowerToUpper) do
        str = string.gsub(str,uppercase,lowercase)
    end
    return str
end
text.lower = lower

-- text.iUpper(string) --> string
-- fixes international characters and makes string upper case
local function iUpper(str)
    str = international(str)
    str = upper(str)
    return str
end
text.iUpper = iUpper

-- text.iLower(string) --> string
-- fixes international characters and makes string lower case
local function iLower(str)
    str = international(str)
    str = lower(str)
    return str
end
text.iLower = iLower


-- text.initCap(string) --> string | By Pablostuka
-- returns the first letter of each word in uppercase, all other letters in lowercase
local function initCap(str)
    -- 1) Convert entire text to lowercase
    str = iLower(str)
    -- 2) Convert to uppercase any character after a space
    -- Patterns (https://www.lua.org/pil/20.2.html)
    -- Captures (http://www.lua.org/pil/20.3.html)
    -- Use pattern consisting of %s (space characters) followed by %l (lower case letters)
    str = string.gsub(str,"(%s%l)",text.iUpper)
    -- 3) Convert first character to uppercase (if a pattern begins with a `^´, it will match only at the beginning of the subject string)
    return string.gsub(str,"^%l",text.iUpper)
end
text.initCap = initCap

-- English Equivalent
-- Provides a conversion from extended ascii to English characters
-- (main reason for function is to remove avoid removing outright
-- non-english characters when making the object table)

local englishEquivalent = {
    [string.char(138)] = "S",
    [string.char(140)] = "OE",
    [string.char(142)] = "Z",
    [string.char(154)] = "s",
    [string.char(156)] = "oe",
    [string.char(158)] = "z",
    [string.char(159)] = "Y",
    [string.char(192)] = "A",
    [string.char(193)] = "A",
    [string.char(194)] = "A",
    [string.char(195)] = "A",
    [string.char(196)] = "A",
    [string.char(197)] = "A",
    [string.char(198)] = "AE",
    [string.char(199)] = "C",
    [string.char(200)] = "E",
    [string.char(201)] = "E",
    [string.char(202)] = "E",
    [string.char(203)] = "E",
    [string.char(204)] = "I",
    [string.char(205)] = "I",
    [string.char(206)] = "I",
    [string.char(207)] = "I",
    [string.char(208)] = "D",
    [string.char(209)] = "N",
    [string.char(210)] = "O",
    [string.char(211)] = "O",
    [string.char(212)] = "O",
    [string.char(213)] = "O",
    [string.char(214)] = "O",
    [string.char(216)] = "O",
    [string.char(217)] = "U",
    [string.char(218)] = "U",
    [string.char(219)] = "U",
    [string.char(220)] = "U",
    [string.char(221)] = "Y",
    [string.char(222)] = "TH",
    [string.char(223)] = "ss",
    [string.char(224)] = "a",
    [string.char(225)] = "a",
    [string.char(226)] = "a",
    [string.char(227)] = "a",
    [string.char(228)] = "a",
    [string.char(229)] = "a",
    [string.char(230)] = "ae",
    [string.char(231)] = "c",
    [string.char(232)] = "e",
    [string.char(233)] = "e",
    [string.char(234)] = "e",
    [string.char(235)] = "e",
    [string.char(236)] = "i",
    [string.char(237)] = "i",
    [string.char(238)] = "i",
    [string.char(239)] = "i",
    [string.char(240)] = "o",
    [string.char(241)] = "n",
    [string.char(242)] = "o",
    [string.char(243)] = "o",
    [string.char(244)] = "o",
    [string.char(245)] = "o",
    [string.char(246)] = "o",
    [string.char(248)] = "o",
    [string.char(249)] = "u",
    [string.char(250)] = "u",
    [string.char(251)] = "u",
    [string.char(252)] = "u",
    [string.char(253)] = "y",
    [string.char(254)] = "th",
    [string.char(255)] = "y",

}

-- text.anglicise(string) --> string
--  replaces international characters with English equivalents
--  Intended for constructing object.lua file, but might have
--  other uses
function text.anglicise(str)
    for char,replacement in pairs(englishEquivalent) do
        str = string.gsub(str,char,replacement)
    end
    return str
end
text.englishEquivalent = englishEquivalent

return text















