
local versionNumber = 5
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
--  text.menu(menuTable,menuText,menuTitle="",canCancel=false,imageInfo=nil,dimensions={width=nil,height=nil},menuPage=1) --> integer,integer
--  (last 4 arguments can be in any order or omitted)
--
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
-- text.registerUnitsImage(filename)
-- text.unitTypeImage(unitTypeOrID) --> imageObject
-- text.newMenuRecord(specTable) --> menuRecord
-- text.isMenuRecord(item) --> bool
--  text.makeChooseNumberMenu(increments={1,10,50,100,500,1000, -1,-10,-100},extremes={min=0,max=10000},selectionKey="menuChosenNumber",nextMenu=nil,goBackOptions = {},menuName="Choose Number Menu")
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
local gen = require("generalLibrary"):minVersion(5)

--[[
The text module provides functions for displaying text boxes and menus.  It also provides code for manipulating strings, though
these are primarily useful to make messages that other functions
in the module will display.

The Civfanatics users [Knighttime](https://forums.civfanatics.com/members/knighttime.21777/) and [Pablostuka](https://forums.civfanatics.com/members/pablostuka.14725/) have contributed functionality to this module.
]]
---@class text
local text={}



gen.versionFunctions(text,versionNumber,fileModified,"LuaCore".."\\".."text.lua")
gen.minEventsLuaVersion(1,1,"LuaCore".."\\".."text.lua")

local textSettingsFound, textSettings = gen.requireIfAvailable("textSettings")
if not textSettingsFound then
    print("WARNING: text.lua did not find textSettings.lua.  Some functionality may not work as expected.")
    textSettings = {}
else
    textSettings:minVersion(1)
end
local dictionary = textSettings.dictionary or {}
local importSubstitutionTags = textSettings.substitutionTags or {}
local importChoiceTags = textSettings.choiceTags or {}

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

-- Set the number of lines per text box for some functions provided
-- by this module (especially menus).
-- By default, there is a setting in the configuration module
-- that will allow the player to change this setting.
---@param numberOfLines integer
function text.setLinesPerWindow(numberOfLines)
    linesPerWindow = math.max(math.floor(numberOfLines),minimumLinesPerWindow)
end
local setLinesPerWindow = text.setLinesPerWindow 

---Returns the current setting for the number of lines per text box,
---which functions in this module use to determine when to break a
---message or menu into multiple text boxes.
---@return integer
function text.getLinesPerWindow()
    return linesPerWindow
end
local getLinesPerWindow = text.getLinesPerWindow

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

---@type string|table
local imageTable = "imageTableNotSet"
local imageTableName = ""

--[[
This function lets you specify a table that is being used to store
imageObjects.  Some functions in this module will allow you to
specify an imageObject by providing a (string) table key.  
This function specifies the table that will be used to look up
the image.

If you generate an object.lua file using the script included
in the Lua Scenario Template, then the imageTable will be
set to the object file.
]]
---@param table table A table where images can be stored and looked up.
---@param tableName string A name for the table to use in error messages.
function text.setImageTable(table,tableName)
    if type(imageTableName) ~="string" then
        error("setImageTable: second argument must be a string, and should be the name of this table."
            .."The name provided will be given as part of error messages, to help you debug.")
    end
    if type(table) ~="table" then
        error("setImageTable: first argument must be a table, but a "..type(table)..
        "was provided instead.")
    else
        ---@cast imageTable table
        imageTable = table
        imageTableName = tableName
    end
end

-- used to do a protected call on the imageTable,
-- since trying to access a nil value from the
-- object table results in an error, and
-- we want a better error message
local function tableAccess(table,key)
    return table[key]
end

--[[
An `imageInfo` is one of the following:<br><br>
An `imageObject`. <br><br>
A `table` such that the first 5 values (some of which can be nil) are valid arguments for `civ.ui.loadImage`.  That is, `civ.ui.loadImage(imageObject[1],imageObject[2],imageObject[3],imageObject[4],imageObject[5])` returns a valid imageObject.<br><br>
A `string` that is the key corresponding to an `imageObject` in the `imageTable` registered by `text.setImageTable`.
]]
---@alias imageInfo string|imageObject|table

---Converts an `imageInfo` to an `imageObject`.
---@param input imageInfo # An `imageInfo` is one of the following:<br><br>An `imageObject`. <br><br>A `table` such that the first 5 values (some of which can be nil) are valid arguments for `civ.ui.loadImage`.<br><br>A `string` that is the key corresponding to an `imageObject` in the `imageTable` registered by `text.setImageTable`.
---@return imageObject
function text.toImage(input)
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
            error("text.toImage: "..imageTableName.."[\""..input.."\"] is not an image.\n"
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
local toImage = text.toImage

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

--[[
Takes an imageInfo and returns a string or table that can be saved in the state table and used to recover the image later.

If the imageInfo is a table of arguments for civ.ui.loadImage, then the table is returned.  An error is thrown if civ.ui.loadImage doesn't return a valid imageObject when called with those arguments.

If the imageInfo is a string, then the string is returned if it is a key for an image in the `imageTable` (registered by `text.setImageTable`).  An error is thrown if the string is not a key for an image in the `imageTable`.

If the imageInfo is an imageObject, then the image is searched for in the `imageTable`, and the key for that image is returned.  If the image is not found in the `imageTable`, then an error is thrown.
]]
---@param imageInfo imageInfo # An `imageInfo` is one of the following:<br><br>An `imageObject`. <br><br>A `table` such that the first 5 values (some of which can be nil) are valid arguments for `civ.ui.loadImage`.<br><br>A `string` that is the key corresponding to an `imageObject` in the `imageTable` registered by `text.setImageTable`.
---@return stateSavableTable
function text.toStateImage(imageInfo)
    if type(imageInfo) == "table" then
        validateArgumentTable(imageInfo,"stateImageReference")
        local bool, result = pcall(civ.ui.loadImage,imageInfo[1],imageInfo[2],imageInfo[3],imageInfo[4],imageInfo[5])
        if bool then
            ---@cast imageInfo stateSavableTable
            ---@diagnostic disable-next-line: return-type-mismatch
            return imageInfo 
        else
            error("stateImageReference: the table\n"
                .."{[1]=\""..tostring(imageInfo[1]).."\",\n"
                .." [2]="..tostring(imageInfo[2])..", [3]="..tostring(imageInfo[3])..",\n"
                .." [4]="..tostring(imageInfo[4])..", [5]="..tostring(imageInfo[5])..",}\n"
                .."Does not load a valid image when its values are provided to\n"
                .."civ.ui.loadImage.")
        end
    elseif type(imageInfo) == "string" then
        if type(imageTable) == "string" then
            error("text.stateImageReference: The 'Image Table' has not been set.\n"
                .."Your input was this: "..imageInfo.."\n"
                .."If this is a key to a table, and table["..imageInfo.."] is the image you want\n"
                .."to use, then you have not run text.setImageTable(imageTable,tableNameString).\n"
                .."If your input is a file path to access the image, use the following as your argument:\n"
                .."{[1]=\""..imageInfo.."\",}")
        end
        local bool,result = pcall(tableAccess,imageTable,imageInfo)
        if bool and civ.isImage(result) then
            ---@diagnostic disable-next-line: return-type-mismatch
            return imageInfo
        else
            error("text.stateImageReference: "..imageTableName.."[\""..imageInfo.."\"] is not an image.\n"
            .."If "..imageInfo.."\n"
            .."is the file path to access the image, then you should write it as:\n"
            .."{[1]=\""..imageInfo.."\",}")
        end
    elseif civ.isImage(imageInfo) then
        local imgKey = nil
---@diagnostic disable-next-line: param-type-mismatch
        for key,value in pairs(imageTable) do
            if civ.isImage(value) and value == imageInfo then
                imgKey = key
                break
            end
        end
        if imgKey then
            return imgKey
        else
            error("stateImageReference: the image provided is not in the "..imageTableName.." table.\n"
            .."An imageObject can't be saved to the state table directly, and\n"
            .."the imageOjbect provided is not a value in the "..imageTableName.." table,\n"
            .."so the corresponding key can't be saved in the state table.\n"
            .."If you think the image you provided IS in the "..imageTableName.." table,"
            .."you can provide the key it is saved in.  This error may be a result\n"
            .."of the fact that img1 = civ.ui.loadImage(\"myImage.bmp\")\n"
            .."img2 = civ.ui.loadImage(\"myImage.bmp\")\n"
            .."img1 == img2 returns false, since 2 different imageObjects are created.\n"
            .."Alternatively, you can provide a table `argTable` as an argument such that\n"
            .."civ.ui.loadImage(argTable[1],argTable[2],argTable[3],argTable[4],argTable[5])\n"
            .."loads your desired image.")
        end
    else
        error("text.stateImageReference: argument 1 has type "..type(imageInfo).."\n"
        .."but only tables, strings, and imageObjects are acceptable.")
    end
end
text.stateImageReference = text.toStateImage
local stateImageReference = text.toStateImage




-- linesInText(string) --> number
-- Determines how many lines of text are in a string, so that text boxes can be kept
-- to a manageable size
-- This can be improved by counting characters and font sizes
---@param string string
---@return integer
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
---@param string string
---@param maxLines? integer
---@return string
---@return string|nil
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

--[[
Adds some text to the dialog object, in such a way that the
character sequence \\n^ will cause a line break when the
dialog is displayed.
]]
---@param string string
---@param dialog dialogObject
function text.addMultiLineTextToDialog(string,dialog)
    local lineTable = {func.splitlines(string)}
    for i=1,#lineTable do
        dialog:addText(lineTable[i])
    end
end
local addMultiLineTextToDialog = text.addMultiLineTextToDialog

--  text.simple(string or tableOfStrings,title="",imageInfo=nil) --> void


--[[
Shows a text box with the message and title, splitting
into multiple text boxes if the string is very long.
If a table of strings is input, each string is shown in
order starting at tableOfStrings[1].  If an imageInfo
is provided, the image is shown in the text box.

The function determines how many lines of text are in the
message by counting newline characters (note that newline
characters by themselves do not cause a line break in the
text box).  If the message has too many lines, as determined
by the variable `linesPerWindow`, then the message is split
at a newline character.  (`linesPerWindow` can be changed
using text.setLinesPerWindow -- by default, the player can
change it using the configuration module.)

To create a line break in the text box, use the character
sequence \\n^ (newline, caret).

If you wish to break up a message into two text boxes
at a particular point, use the sequence of characters
'%PAGEBREAK' (not including quote marks).

If you wish to center a line of text, use the sequence
\\n^^ (newline, caret, caret).
]]
---@param stringOrTable string|string[]
---@param boxTitle? string # The title for the text box.  Defaults to ""
---@param imageInfo? imageInfo # The image to show in the text box.  Defaults to not showing an image.<br><br>An `imageInfo` is one of the following:<br><br>An `imageObject`. <br><br>A `table` such that the first 5 values (some of which can be nil) are valid arguments for `civ.ui.loadImage`.<br><br>A `string` that is the key corresponding to an `imageObject` in the `imageTable` registered by `text.setImageTable`.
function text.simple(stringOrTable,boxTitle,imageInfo)
    boxTitle = boxTitle or ""
    imageInfo = imageInfo and toImage(imageInfo)
    if type(stringOrTable)=="string" then
        ---@type string|nil
        local remainingString = stringOrTable 
        local textToShow = nil
        repeat
            textToShow,remainingString = splitTextForWindow(remainingString --[[@as string]])
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
            text.simple(stringOrTable[i],boxTitle,imageInfo)
        end
    else
        error("text.simple must have a string or a table of strings as the first argument.")
    end
end
local simple = text.simple


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
---@param tribeID integer|tribeObject # The tribe for whom the message should be added to the archive.
---@param messageBody string # The message to be displayed in the archive.
---@param messageTitle string # The title of the text box of the message.
---@param archiveTitle string # The title of the message in the archive menu.
---@param imageInfo? imageInfo # The image to show in the text box.  Defaults to not showing an image.<br><br>An `imageInfo` is one of the following:<br><br>An `imageObject`. <br><br>A `table` such that the first 5 values (some of which can be nil) are valid arguments for `civ.ui.loadImage`.<br><br>A `string` that is the key corresponding to an `imageObject` in the `imageTable` registered by `text.setImageTable`.
function text.addToArchive(tribeID,messageBody,messageTitle,archiveTitle,imageInfo)
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
local addToArchive = text.addToArchive

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

--[[
Displays a message to a tribe or tribes at the next possible opportunity,
either immediately (if the tribe is active), or during the onCityProcessingComplete execution point.

If an archive title is specified, the message will be added to the tribe's archive after it is shown.

Note: For backwards compatibility, the order of the last two arguments can be reversed.  The function will figure it out.
]]
---@param tribes tribeObject|integer|table<any,tribeObject|integer> # The tribe or tribes to whom the message should be displayed.  Integers reference the tribe's ID.
---@param messageBody string # The message to be displayed.
---@param messageTitle? string # The title of the text box of the message.
---@param archiveTitle? string # The title of the message in the archive menu.  If nil, the message will not be added to the archive.
---@param imageInfo? imageInfo # The image to show in the text box.  Defaults to not showing an image.<br><br>An `imageInfo` is one of the following:<br><br>An `imageObject`. <br><br>A `table` such that the first 5 values (some of which can be nil) are valid arguments for `civ.ui.loadImage`.<br><br>A `string` that is the key corresponding to an `imageObject` in the `imageTable` registered by `text.setImageTable`.
---@param broadcast? boolean # If true, the text box with the message will be displayed even if the tribe is controlled by an AI.  If false or absent, it will only be displayed if the tribe is controlled by a human.
function text.displayNextOpportunity(tribes,messageBody,messageTitle,archiveTitle,imageInfo,broadcast)
    displayNextOpportunity(tribes,messageBody,messageTitle,archiveTitle,imageInfo,broadcast)
end


-- text.displayAccumulatedMessages() --> void

--[[
Displays to the current player all messages that were to be displayed
at the next opportunity, then either archives or deletes the messages.

If the player is an AI, the messages will not be displayed, unless the broadcast parameter was true.

In the Lua Scenario Template, this is in the onCityProcessingComplete 
execution point, and the scenario designer should not need to call it.
]]
function text.displayAccumulatedMessages()
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


--  Menu Table Specification
--  menuTable[i]=optionName is the i'th option that will appear in the menu
--  and menu will return i if option is chosen
--  optionName will be a string
--  start counting at 1, can skip numbers (incl. 1), but don't have other entries in table


--[[
A menuTable represents the options that will appear in a menu.

The options will appear in order based on the keys of the table.

When an option is chosen in the menu, the key of the option will be returned.

The keys of the table must be integers, and the lowest allowable key is 1.
(0 represents the "cancel" option, which is not part of the menuTable.)  The menuTable does not have to have an option associated with every integer.  (It is even permissible to not have the key 1 associated with an option.)
]]
---@alias menuTable table<integer,string>


-- text.menu(menuTable,menuText,menuTitle="",canCancel=false,menuPage=1)-->integer,integer
-- text.menu(menuTable,menuText,menuTitle="",canCancel=false,imageInfo=nil,dimensions={width=nil,height=nil},menuPage=1) --> integer,integer
--  (last 4 arguments can be in any order or omitted)
-- returns the key of the menu table of the option chosen, second parameter returns menu page of selection
-- menuText is displayed above the options
-- menuTitle is the title of the menu
-- canCancel if true, offers a 'cancel' option on each page, returns 0 if selected
--           if false, there is no cancel option
-- menuPage is the "page" of the menu that is to be opened
-- imageInfo a way to get an image, either key for the imageTable, an imageObject,
--          or a table of arguments for civ.ui.loadImage
--  Arguments 4,5,6,7 (canCancel,imageInfo,menuPage,dimensions) can be in any order; the code will
--  figure out which is which
-- dimensions is a way to specify the size of the menu text box
--      {width=integerOrNil, height=integerOrNil}
--      can't have 1 as a key (that will be interpreted as an imageInfo)
--local function menu(menuTable,menuText,menuTitle,canCancel, menuPage,imageInfo,dimensions)
local function menu(menuTable,menuText,menuTitle,arg4, arg5,arg6,arg7)
    local canCancel = false
    local menuPage = 1
    local image = nil
    local dimensions = {}
    local function setArgument(arg)
        if type(arg) == "boolean" then
            canCancel = arg
        elseif type(arg) =="number" then
            menuPage = arg
        elseif type(arg) =="table" and not arg[1] then
            dimensions = arg
        elseif type(arg) ~= "nil" then
            image = toImage(arg)
        end
    end
    setArgument(arg4)
    setArgument(arg5)
    setArgument(arg6)
    setArgument(arg7)

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
        if dimensions.width then
            menuDialog.width = dimensions.width
        end
        if dimensions.height then
            menuDialog.height = dimensions.height
        end
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
    if dimensions.width then
        menuDialog.width = dimensions.width
    end
    if dimensions.height then
        menuDialog.height = dimensions.height
    end
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

--[[
This function displays a menu of options to the user, as defined by the menuTable.  The user can choose one of the options, and may or may not be given the option to "cancel" as a choice.  The function returns the index of the menuTable entry that was chosen, or 0 if the user cancels the menu.  If the menu has multiple pages, the function returns the page where the choice was made.
    ]]
---@param menuTable menuTable # A table of menu options.  The keys are the numbers that will be returned when the option is chosen.  The values are the text to display for each option.
---@param menuText string # The text to display above the menu options.
---@param menuTitle? string # The title of the menu's text box.  Defaults to "".
---@param canCancel? boolean # Whether or not the menu should have a "Cancel" option, which returns 0.  Defaults to false.
---@param imageInfo? imageInfo
---@param dimensions? {width:integer|nil, height:integer|nil} # The dimensions of the menu text box.  If not specified, the game will choose.
---@param menuPage? integer # The page of the menu to start on.  Defaults to 1.
---@return integer choice # The index of the menuTable entry that was chosen.
---@return integer menuPage # The page of the menu where the choice was made.  This could be useful if you want to be able to re-open the menu on the same page.
function text.menu(menuTable,menuText,menuTitle,canCancel,imageInfo,dimensions, menuPage)
    local choice,page = menu(menuTable,menuText,menuTitle,canCancel, menuPage,imageInfo,dimensions)
    return choice,page
end

--text.menu = menu

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

--[[
Purges (deletes) all archived messages that have been marked for purging
by the tribe.
]]
---@param tribeOrID tribeObject|integer # The tribe or tribe ID for whom to purge the archive.
function text.purgeArchive(tribeOrID)
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
local purgeArchive = text.purgeArchive

-- text.deleteAIArchives()-->void

--Deletes all messages saved in archives owned by AI Tribes
function text.deleteAIArchives()
    for i=0,7 do
        if not civ.getTribe(i).isHuman then
            for __,archiveMessage in pairs(textState.archive[i]) do
                archiveMessage.markedForPurging = true
            end
            purgeArchive(i)
        end
    end
end


-- Old version of substitute
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
--  text.substitute = substitute -- now using newSubstitute instead

-- toPlural[word] = pluralVersionOfWord
local toPlural = {}

-- toSingular[word] = singularVersionOfWord
local toSingular = {}

-- aOrAn[word] = 'a' or 'an'
--  depending on whether it is 'a word' or 'an word'
local aOrAn = {}

-- a 'dictionary' table has information to populate the above tables
-- which will be used to help text.newSubstitute work
-- dictionary[anyKey] = {singular=singularVersionOfWord, plural=pluralVersionOfWord, an=boolean}
--      an = true if it is 'an singularVersionOfWord' and false/nil if it is 'a singularVersionOfWord'

--[[
Registers a 'dictionary' table with the text module.  The dictionary table
should have the following format:
```
dictionary[anyKey] = {singular=singularVersionOfWord, plural=pluralVersionOfWord, an=boolean}
```
an = true if it is 'an singularVersionOfWord' and false/nil if it is 'a singularVersionOfWord'

The keys in the dictionary table do not matter.

The dictionary table is used to enhance the functionality of text.substitute.
]]
---@param dictionary table # A table with the above format
function text.registerDictionary(dictionary)
    for _,entry in pairs(dictionary) do
        if type(entry) == "table" then
            toPlural[entry.singular] = entry.plural
            toPlural[entry.plural] = entry.plural
            toSingular[entry.singular] = entry.singular
            toSingular[entry.plural] = entry.singular
            if entry.an then
                aOrAn[entry.singular] = "an"
                aOrAn[entry.plural] = "an"
            else
                aOrAn[entry.singular] = "a"
                aOrAn[entry.plural] = "a"
            end
        end
    end
end

text.registerDictionary(dictionary)



local substitutionTags = {}
substitutionTags["%%STRING"] = tostring
substitutionTags["%%MONEY"] = function(val) return text.money(val) end
substitutionTags["%%NAME"] = function(val) return val.name or val.type.name end
substitutionTags["%%OWNER"] = function(val) return val.owner.name end
substitutionTags["%%ADJECTIVE"] = function(val) return val.adjective or val.owner.adjective end

--[[ decided not to use this
-- text.registerSubstitutionTag(tag,convertFn) --> void
--  Registers a custom substitution tag, for text.substitute
--      If you register MYTAG, then substitute will search for
--      instances of %MYTAG in the rawText, in order to substitute
--      it for the result of convertFn(subTable[key])
--      Note: in Lua pattern matching, these characters need to be
--      'escaped' by %, including those in the tag:
--      ( ) % . + - * [ ? ^ $
--      tag is a string
--      convertFn is a function: convertFn(value) --> string
function text.registerSubstitutionTag(tag,convertFn)
    substitutionTags["%%"..tag] = convertFn
end

text.registerSubstitutionTag("ADJECTIVE",function(val) return val.adjective or val.owner.adjective end)
--]]

for tag,convertFn in pairs(importSubstitutionTags) do
    substitutionTags[tag] = convertFn
end

local choiceTags = {}
choiceTags["%%%?TRUTHY"] = function(val) return not not val end
choiceTags["%%%?PLURAL"] = function(val) return val ~= 1 end
choiceTags["%%%?ZERO"] = function(val) return val == 0 end
choiceTags["%%%?ONE"] = function(val) return val == 1 end

for tag,choiceFn in pairs(importChoiceTags) do
    choiceTags[tag] = choiceFn
end


--  newSubstitute
--  text.substitute(rawText, substitutionTable)
--
--      Substitutes occurrences of %?<TAG><key>{phrase one}{phrase two} with
--      phrase one      if the function the function registered with tag, evaluated
--                      on substitutionTable[key] returns true, and
--      phrase two      if the registered function returns false.
--      phrase one/two can have substitutions from later sections of this function
--      (see next phase for more details on <TAG>/<key>)
--      
--      Next, substitutes occurrences of %<TAG><key> with appropriate values derived
--      from the substitution table
--      <TAG> is a registered character sequence in substitutionTags (including those
--      registered via text.registerSubstitutionTag)
--      if <key> is a digit, get the value from the numeric key in the substitution table
--      e.g. %STRING1 gets replaced with tostring(substitutionTable[1])
--      Note, a digit key can only have 1 digit, that is, 0-9, so %STRING10 is forbidden.
--      if <key> is of the form [someKeyName], then get the string key from the substitution table,
--      e.g. %STRING[someKeyName] -> tostring(substitutionTable["someKeyName"])
--
--      After the %<TAG><key> substitutions, plural substitutions are checked for.
--      These are marked by %#some text#<key>
--      If substitutionTable[<key>] == 1, then 
--      %#some text#<key> --> toSingular[some text]
--      If substitutionTable[<key>] ~= 1, then 
--      %#some text#<key> --> toPlural[some text]
--      if toSingular[some text] == nil or toPlural[some text] == nil then
--      %#some text#<key> --> some text
--      note: toSingular and toPlural are populated by text.registerDictionary(dictionary),
--      where dictionary is from dictionary.lua, (or {}, if that file is unavailable)
--      and toSingular[singularVersionOfWord] = singularVersionOfWord exists, as does
--      toPlural[pluralVersionOfWord] = pluralVersionOfWord
--
--      After the plural substitutions, the indefinite articles a/an are generated
--      These are based on contents wrapped by %@ and @
--      '%@someWord@' --> aOrAn[someWord]..' someWord' --> 'a someWord'
--      or
--      %@anotherWord@ --> aOrAn[anotherWord]..' anotherWord' --> 'an anotherWord'
--      aOrAn is populated from dictionary.lua, like toSingular and toPlural
--      if the key is absent from aOrAn (i.e. dictionary.lua), then a is used, unless
--      the key starts with a,e,i,o,u, in which case an is used
--


local function substituteChoice(rawText,tag,choiceFn,substitutionTable)
    local function intSubstitute(int,phraseOne,phraseTwo)
        int = tonumber(int)
        if choiceFn(substitutionTable[int]) then
            return string.sub(phraseOne,2,-2) -- remove { and } from captured phraseOne
        else
            return string.sub(phraseTwo,2,-2) -- remove { and } from captured phraseTwo
        end
    end
    local function strSubstitute(key,phraseOne,phraseTwo)
        key = string.sub(key,2,-2) -- remove [ and ] from captured key
        if choiceFn(substitutionTable[key]) then
            return string.sub(phraseOne,2,-2) -- remove { and } from captured phraseOne
        else
            return string.sub(phraseTwo,2,-2) -- remove { and } from captured phraseTwo
        end
    end
    rawText = string.gsub(rawText,tag.."(%b[])(%b{})(%b{})",strSubstitute)
    rawText = string.gsub(rawText,tag.."(%d)(%b{})(%b{})",intSubstitute)
    return rawText
end

local function substituteTag(rawText,tag,fn,substitutionTable)
    local function intSubstitute(keyString)
        local key = tonumber(keyString)
        return tostring(fn(substitutionTable[key]))
    end
    local function strSubstitute(keyString)
        local key = string.sub(keyString,2,-2) -- remove [ and ] from captured keyString
        return tostring(fn(substitutionTable[key]))
    end
    rawText = string.gsub(rawText,tag.."(%d)",intSubstitute)
    rawText = string.gsub(rawText,tag.."(%b[])",strSubstitute)
    return rawText
end

local function fixPlural(rawText,substitutionTable)
    local function intSubstitute(wordString,keyString)
        local key = tonumber(keyString)
        wordString = string.sub(wordString,2,-2) -- remove # and # from captured wordString
        if substitutionTable[key] == 1 then
            return toSingular[wordString] or wordString
        else
            return toPlural[wordString] or wordString
        end
    end
    local function strSubstitute(wordString,keyString)
        local key = string.sub(keyString,2,-2) -- remove [ and ] from captured keyString
        wordString = string.sub(wordString,2,-2) -- remove # and # from captured wordString
        if substitutionTable[key] == 1 then
            return toSingular[wordString] or wordString
        else
            return toPlural[wordString] or wordString
        end
    end
    rawText = string.gsub(rawText,"%%(%b##)(%d)",intSubstitute)
    rawText = string.gsub(rawText,"%%(%b##)(%b[])",strSubstitute)
    return rawText
end

local vowel ={a=true,e=true,i=true,o=true,u=true,
              A=true,E=true,I=true,O=true,U=true,}
local function addIndefiniteArticle(rawText)
    local function affixArticle(word)
        word = string.sub(word,2,-2) -- remove @ and @ from captured key
        if aOrAn[word] then
            return aOrAn[word].." "..word
        elseif vowel[string.sub(word,1,1)] then
            return "an "..word
        else
            return "a "..word
        end
    end
    rawText = string.gsub(rawText,"%%(%b@@)",affixArticle)
    return rawText
end

--[[
Substitutes values from the substitutionTable into the rawText, based on 
tags in the rawText.

]]
---@param rawText string
---@param substitutionTable table<integer,any> # the values associated with the keys 0-9 are eligible to be used for substitution.
---@return string
function text.substitute(rawText,substitutionTable)
    if string.find(rawText,"%%%?") then
        for tag,choiceFn in pairs(choiceTags) do
            rawText = substituteChoice(rawText,tag,choiceFn,substitutionTable)
        end
    end
    for tag,convertFn in pairs(substitutionTags) do
        rawText = substituteTag(rawText,tag,convertFn,substitutionTable)
    end
    rawText = fixPlural(rawText,substitutionTable)
    rawText = addIndefiniteArticle(rawText)
    return rawText
end
--text.substitute = newSubstitute

function console.testSubstitution()
    local function rowsToMoney(type)
        local rows = type.cost
        return text.money(25*rows)
    end
    text.setMoney("%STRING1 Frying Pans","%STRING1 Frying Pan")
    substitutionTags["%%ROWSTOMONEY"] = rowsToMoney
    --text.registerSubstitutionTag("ROWSTOMONEY",rowsToMoney) -- this function commented out

    local rawText = "This unit is type %NAME[type] with cost %ROWSTOMONEY[type] "..
        "and owner %NAME[owner]."
---@diagnostic disable-next-line: param-type-mismatch
    local unit = civ.createUnit(civ.getUnitType(1),civ.getTribe(1),civ.getCity(0).location)
    print(text.substitute(rawText,unit))
    local genericText = "The unit is %ADJECTIVE[unit], with cost %ROWSTOMONEY[type], which is less than %MONEY1 and more than %MONEY2. [no substitution here]  We should create %STRING3 %#unit#3, or, maybe, only %STRING[one] %#units#[one]."
    local subTable = {unit = unit, type = unit.type, [1] = 300, [2] = 1, [3]=5, one=1}
    print(text.substitute(genericText,subTable))
    local genericText2 = "The unit is %ADJECTIVE[unit], with cost %ROWSTOMONEY[type], which is less than %MONEY1 and more than %MONEY2. [no substitution here]  We should create %STRING3 %#units#3, or, maybe, only %STRING[one] %#unit#[one].  %#no plural registered#[one] %#no plural registered#3 #a "
    print(text.substitute(genericText2,subTable))
    subTable["egypt"] = civ.getTribe(4)
    local genericText3 = "The unit is %@%ADJECTIVE[unit]@ unit, not %@%ADJECTIVE[egypt]@ unit.  %#That#3 %#is#3 also %?PLURAL3{units}{%@unit@}."
    print(text.substitute(genericText3,subTable))
    local genericText4 = "%?PLURAL3{There are %STRING3 %ADJECTIVE[unit] %#%NAME[unit]#3}{There is %@ADJECTIVE[unit] %#%NAME[unit]#3}, and %?PLURAL3{they}{it} %#is#3 white."
    print(text.substitute(genericText4,subTable))
    local genericText3 = "The unit is %@%ADJECTIVE[unit]@ unit, not %@%ADJECTIVE[egypt]@ unit.  %#That#[one] %#is#[one] also %?PLURAL[one]{units}{%@unit@}."
    print(text.substitute(genericText3,subTable))
    local genericText4 = "%?PLURAL[one]{There are %STRING[one] %ADJECTIVE[unit] %#%NAME[unit]#[one]}{There is %@%ADJECTIVE[unit]@ %#%NAME[unit]#[one]}, and %?PLURAL[one]{they}{it} %#is#[one] white."
    print(text.substitute(genericText4,subTable))
    local newSubTable = {count = 0, unit = unit}
    local genericText5 = "%?ZERO[count]{There are no}{}%?ONE[count]{There is one}{}%?TWOPLUS[count]{There are %STRING[count]}{} %ADJECTIVE[unit] %#%TYPE[unit]#[count] in %CAPITAL[unit]."
    print(text.substitute(genericText5,{count=0, unit=unit}))
    print(text.substitute(genericText5,{count=1, unit=unit}))
    print(text.substitute(genericText5,{count=2, unit=unit}))
    print(text.substitute(genericText5,{count=3, unit=unit}))
---@diagnostic disable-next-line: param-type-mismatch
    local egyptUnit = civ.createUnit(civ.getUnitType(1),civ.getTribe(4),civ.getTile(2,2,0))
    print(text.substitute(genericText5,{count=3, unit=egyptUnit}))
    print(text.substitute(genericText5,{count=0, unit=egyptUnit}))

end

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
local singleMoneyConvert = nil

--  text.money(amount) --> string
--  converts an integer to an appropriate string denoting money
local function money(amount)
    if type(moneyConvert) == "string" then
        if amount == 1 and singleMoneyConvert then
            return string.gsub(singleMoneyConvert,"%%STRING1",text.groupDigits(amount))
        else
            return string.gsub(moneyConvert,"%%STRING1",text.groupDigits(amount))
            --return text.substitute(moneyConvert,{text.groupDigits(amount)})
        end
    else
        return moneyConvert(amount)
    end
end
text.money = money


--  text.setMoney(convertString,singleMoneyConvertString=nil)-->void
--  sets the method of conversion of an integer to a money amount
--  text.money will subsitute %STRING1 for the money amount,
--  with digit separators added, and return the string
--  if the money converted is exactly one, and singleMoneyConvert
--  has been specified, that string will be used instead

local function setMoney(convertString,convertStringOne)
    if type(convertString) ~= "string" then
        error("text.setMoney: first argument must be a string.")
    end
    if type(convertStringOne) ~= "nil" and type(convertStringOne) ~= "string" then
        error("text.setMoney: second argument must be a string or nil.")
    end
    moneyConvert = convertString
    singleMoneyConvert = convertStringOne
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
-- (main reason for function is to avoid removing outright
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


-- unitTypeImages[unitTypeID] = imageObject
local unitTypeImages = {}

-- text.registerUnitsImage(filename)
--      registers the name of the units image file
--      to be used for text.unitTypeImage
--      
function text.registerUnitsImage(filename)
    local imageHeight = 64
    local imageWidth = 64
    local imagesInRow = 9
    for i=0,civ.cosmic.numberOfUnitTypes-1 do
        local row = i//imagesInRow
        local column = i % imagesInRow
        local x = 1+(column*(imageWidth+1))
        local y = 1+(row*(imageHeight+1))
        unitTypeImages[i] = civ.ui.loadImage(filename,x,y,imageWidth,imageHeight)
    end
end

-- text.unitTypeImage(unitTypeOrID) --> imageObject
--      provides the image of a unit, found in the file provided to
--      text.registerUnitsImage, or nil if there is no image
function text.unitTypeImage(unitTypeOrID)
    if civ.isUnitType(unitTypeOrID) then
        unitTypeOrID = unitTypeOrID.id
    end
    if type(unitTypeOrID) ~= "number" then
        error("text.unitTypeImage: argument must be a unitType or integer.  Received: "..tostring(unitTypeOrID))
    end
    return unitTypeImages[unitTypeOrID]
end


-- menuRecord(callingArgument=nil,history=gen.newEmptyStack(),menuRecordHistory = gen.newEmptyStack()) --> menuChoice, history,menuRecordHistory
--      A menuRecord either shows a menu to the player, or makes
--      a choice automatically (usually if the AI must 'use' the menu)
--      The behaviour of the menu is governed by the keys of the
--      menuRecord
--      history is a "stack" (data type) with previous choices recorded
--      callingArgument can be any value
--      menuRecordHistory is a "stack" of previous menuRecords called
--
--
--      menuGenerator =
--          {[integer] = menuOptionTable}
--              or
--          function(callingArgument,history) --> {[integer] = menuOptionTable}
--
--          where, the menuOptionTable = 
--              {choice=menuChoice, optionName=string, 
--              nextMenu = nil or menuRecord or integer>0, noFilter = boolOrNil,
--              <userDefKey> = <userUsefulValue>}
--
--
--          The menuGenerator is a function that takes the existing history of the
--          menu, and the callingArgument, and generates a table of menu options,
--          or it is already a table of menu options (called fullMenuTable below)
--
--          When the menuRecord is called, the optionName is shown to the player,
--          and the choice is the first returned value, unless nextMenu is a menuRecord.
--          If nextMenu is a menuRecord, then the choice value is pushed onto the history stack,
--          and the menu returns the result of nextMenuRecord(history,callingArgument)
--          (if choice needs multiple pieces of information, use a table)
--          If nextMenu is a number, go back in the history and menuRecordHistory that many
--          entries and revisit that menu (history and menuRecordHistory have most recent
--          additions removed). 1 means go to previous menu, 2 to 2nd previous menu, etc.
--          If number exceeds stack size, go to first menu (and any 'history' fed into the initial menu).
--  
--          The designer can also define extra keys (<userDefKey>) and values to facilitate
--          the other functions in the menuRecord
--          
--
--          default: {[1] = {choice=nil, optionName = "Default Choice", noFilter = true}}
--
--      canCancel = boolean
--          if canCancel is true, the menu has a 'cancel' option, which returns nil
--
--          default = false
--
--      menuFilter = function(menuOptionTable,callingArgument,history,fullMenuTable) --> bool or number
--
--          When the player is shown a menu, this function is applied to all 
--          entries in the menuTable produced by menuGenerator
--          (except those with noFilter, which count as returning true)
--          if false, the choice is excluded from the menu
--          if true, the item is included in the menu, at the same place
--          if number, all items with number weights are ordered so that
--          the biggest weights are first
--
--          default: nil (leave the generated menu unchanged)
--
--      menuText = string or function(callingArgument,history) --> string
--          provides the text for the menu
--          recentHistory = history[1] if history[1] is a table,
--                          {[1] = history[1]} if history[1] is a value
--          apply text.substitute to recentHistory 
--
--      default: ""
--
--      menuTitle = string or function(callingArgument,history) --> string
--          provides the text for the menu
--          recentHistory = history[1] if history[1] is a table,
--                          {[1] = history[1]} if history[1] is a value
--          apply text.substitute to recentHistory 
--
--      default: ""
--
--      autoChoice = function(callingArgument,history,fullMenuTable) --> boolean or menuOptionTable
--
--          if false, the menu is shown to the player
--          if true, the choice is made using autoChoiceWeights below
--          if menuOptionTable, that option is chosen
--
--          default: function(a,b,c) return false end
--              (don't choose anything)
--
--      autoChoiceWeights = function(menuOptionTable,callingArgument,history,fullMenuTable) --> bool or number
--          
--          generates weights for an automatic choice.  boolean weights (even true) are
--          never chosen, so the menuFilter choices can be reused.
--          weights less than 0 are never chosen.
--
--          default: nil (show a message to the player explaining this was supposed to be automatic,
--              and ask if they want a menu or an error)
--
--      menuImage = nil or imageObject or function(callingArgument,history) -->nil or imageObject
--          The image that will be shown in the menu text box
--
--          default: nil (no image)
--
--      menuName = string
--          a name for the menu in error messages
--          default: "Unknown Menu"
--
--      postProcessor = function(callingArgument,choice,history,menuRecordHistory) --> choiceValueReturnedByMenu
--          Allows for some processing of the data before going to the next menu,
--          or returning the choice (it does not apply if nextMenu has an integer value, since
--          in that case you're going back to a previous menu state)
--          This function is performed after the choice has been added to the history,
--          and after the current menuRecord has been added to the menuRecordHistory
--          If there is no nextMenu, the result of this function is returned as the choice
--          (the default function simply returns the choice)
--          If you wish to change the choice as recorded in the history, you must pop
--          the recorded choice from the history, and push the modified version.
--
--          default: function(callingArgument,choice,history,menuRecordHistory) return choice end
--
--
--
--
--      It is important to note that menuRecords work like unitTypeObjects or tmprovementObjects,
--      that is, changing the value of a key changes how that object works in EVERYWHERE
--      in your code, including in places where you've already assigned that menuRecord
--      as a value.
--
--      In particular, you can assign  menuRecordTwo as the value for nextMenu in 
--      a choice (or choices) for menuRecordOne, and fill in the details of  
--      menuRecordTwo later in your code.
--

local function isPositiveInt(item)
    return type(item) == "number" and math.floor(item) == item and item > 0
end


local function menuGeneratorCheck(table)
    for key,menuOptionTable in pairs(table) do
        if type(key) ~= "number" or math.floor(key) ~= key then
            return "menuGenerator Table must have only integer keys.  Received: "..tostring(key)
        end
        if type(menuOptionTable) ~= "table" then
            return "menuGenerator Table must have tables as values.  Received: "..tostring(menuOptionTable)
        end
        if type(menuOptionTable.optionName) ~= "string" then
            return "menuGenerator: table["..key.."].optionName = "..tostring(menuOptionTable.optionName)
            ..".  However, this value must exist and be a string."
        end
        local nextMenu = menuOptionTable.nextMenu
        if nextMenu ~= nil and (not text.isMenuRecord(nextMenu)) and (not isPositiveInt(nextMenu)) then
            return "menuGenerator: table["..key.."].nextMenu = "..tostring(nextMenu)..
            ".  However, this value must be nil, a menuRecord, or a positive integer."
        end
    end
    return true
end


local specificKeyTableMenuRecord = {
    menuGenerator = {["table"] = {menuGeneratorCheck,"{[int] =  {choice=menuChoice, optionName=string, nextMenu = nil or menuRecord or integer>0, noFilter = boolOrNil, <userDefKey> = <userUsefulValue>}}"}, ["function"] = "function(callingArgument,history) --> {[int] =  {choice=menuChoice, optionName=string, nextMenu = nil or menuRecord or integer>0, noFilter = boolOrNil, <userDefKey> = <userUsefulValue>}}"},
    menuFilter = {["nil"] = true, ["function"] = "function(menuOptionTable,callingArgument,history,fullMenuTable) --> bool or number",},
    menuText = {["string"]=true, ["function"] = "function(callingArgument,history) --> string",},
    menuTitle = {["string"]=true, ["function"] = "function(callingArgument,history) --> string",},
    autoChoice = {["function"] = "function(history,callingArgument,fullMenuTable) --> boolean or menuOptionTable"},
    autoChoiceWeights = {["nil"] = true,["function"] = "function(menuOptionTable,callingArgument,history,fullMenuTable) --> bool or number"},
    menuImage = {["nil"] = true, ["userdata"] = civ.isImage,["function"] = "function(callingArgument,history) --> imageObject"},
    menuName = {["string"] = true},
    width = {["nil"]=true, ["number"] = {minVal = 0, integer=true}},
    height = {["nil"]=true, ["number"] = {minVal = 0, integer=true}},
    canCancel = {["boolean"] = true},
    postProcessor = {["function"] = "function(callingArgument,choice,history,menuRecordHistory) --> choiceValueReturnedByMenu"},

}

local generalKeyTableMenuRecord = {}
local defaultValueTableMenuRecord = {
    menuGenerator = {[1] = {choice=nil, optionName = "Default Choice", noFilter = true}},
    menuText = "",
    menuTitle = "",
    autoChoice = function(a,b,c) return false end,
    menuName = "Unknown Menu",
    canCancel = false,
    postProcessor = function(c,choice,h,m) return choice end,
}
local fixedKeyTableMenuRecord = {}

local baseMakeMenuRecord, baseIsMenuRecord, menuRecordMetatable = 
    gen.createDataType("menuRecord", specificKeyTableMenuRecord, generalKeyTableMenuRecord,
        defaultValueTableMenuRecord, fixedKeyTableMenuRecord)

-- text.newMenuRecord(specTable) --> menuRecord
--      converts a specification table for a menuRecord
--      into a menuRecord
function text.newMenuRecord(specTable)
    specTable = specTable or {}
    return baseMakeMenuRecord(specTable)
end

    
-- text.isMenuRecord(item) --> bool
--      returns true if item is a menuRecord, and false otherwise
function text.isMenuRecord(item)
    return baseIsMenuRecord(item)
end


local function humanMenuChoice(record,callingArgument,history,fullMenuTable)
    local weightKey = {} -- using a table as a key means no key collisions
    local canCancel = record.canCancel
    -- menuTableTranslator[menuChoiceID] = {menuIndex = integer, weight = intOrBool}
    local menuTableTranslator = {}
    local translatorIndex = 1
    local minKey = math.huge
    local maxKey = -math.huge
    for key,value in pairs(fullMenuTable) do
        minKey = math.min(key,minKey)
        maxKey = math.max(key,maxKey)
    end
    local filter = record.menuFilter
    -- items in the toSortTable will be sorted, then added
    -- to the menuTableTranslator, items with true weight will be put
    -- directly into menuTableTranslator, since they should keep the same
    -- position in the table
    local toSortTable = {}
    local toSortTableIndex = 1
    for i=minKey,maxKey do
        local menuOptionTable = fullMenuTable[i]
        if menuOptionTable then
            if filter then
                local w = nil
                if menuOptionTable.noFilter then
                    w = true
                else
                    w = filter(menuOptionTable,callingArgument,history,fullMenuTable)
                end
                if w == true then
                    menuTableTranslator[translatorIndex] = {menuIndex = i, weight = w}
                    translatorIndex = translatorIndex+1
                elseif type(w) == "number" then
                    toSortTable[toSortTableIndex] = {menuIndex = i, weight = w}
                    toSortTableIndex = toSortTableIndex + 1
                    translatorIndex = translatorIndex+1
                elseif w ~= false then
                    -- if w==false, nothing is done
                    error("menuRecord: "..record.menuName..": The function assigned to menuFilter should only return numbers and booleans.  Received: "..tostring(w))
                end
            else
                menuTableTranslator[translatorIndex] = {menuIndex = i, weight=true}
                translatorIndex = translatorIndex +1
            end
        end
    end
    table.sort(toSortTable,function(a,b) return a.weight > b.weight end)
    translatorIndex = 1
    for i=1,toSortTableIndex-1 do
        while menuTableTranslator[translatorIndex] ~= nil do
            translatorIndex = translatorIndex+1
        end
        menuTableTranslator[translatorIndex] = toSortTable[i]
        translatorIndex = translatorIndex+1
    end
    local menuTable = {}

    for i,translationRecord in pairs(menuTableTranslator) do
        menuTable[i] = fullMenuTable[translationRecord.menuIndex].optionName
    end
    local menuText = ""
    if type(record.menuText) == "string" then
        menuText = record.menuText
    elseif type(record.menuText) == "function" then
        menuText = record.menuText(callingArgument,history)
        if type(menuText) ~= "string" then
            error("menuRecord: "..record.menuName..": The function assigned to menuText should only return strings.  Received: "..tostring(menuText))
        end
    end
    local recentHistory = gen.tableWrap(history[1])
    menuText = text.substitute(menuText,recentHistory)
    local menuTitle = ""
    if type(record.menuTitle) == "string" then
        menuTitle = record.menuTitle
    elseif type(record.menuTitle) == "function" then
        menuTitle = record.menuTitle(callingArgument,history)
        if type(menuTitle) ~= "string" then
            error("menuRecord: "..record.menuName..": The function assigned to menuTitle should only return strings.  Received: "..tostring(menuTitle))
        end
    end
    local recentHistory = gen.tableWrap(history[1])
    menuTitle = text.substitute(menuTitle,recentHistory)
    local image = record.menuImage
    if type(image) == "function" then
        image = image(callingArgument,history)
    end
    local choice = text.menu(menuTable,menuText,menuTitle,canCancel,image,{width=record.width, height=record.height})
    local menuOptionTable = nil
    if choice == 0 then
        menuOptionTable = {choice=nil, optionName = "Cancel", nextMenu = nil, noFilter = nil}
    else
        menuOptionTable = fullMenuTable[menuTableTranslator[choice].menuIndex]
    end
    return menuOptionTable
end

local function autoChoiceResultCheck(option,record)
    if type(option) ~= "table" then
        error(record.menuName..": autoChoice: the function registered to autoChoice should return either a boolean or {choice=menuChoice, optionName=string, nextMenu = nil or menuRecord or integer>0, noFilter = boolOrNil, <userDefKey> = <userUsefulValue>}.  Received "..type(option)..":"..tostring(option))
    end
    local nextMenu = option.nextMenu
    if nextMenu ~= nil and (not text.isMenuRecord(nextMenu)) and (not isPositiveInt(nextMenu)) then
        error(record.menuName..": autoChoice: the function registered to autoChoice returned a menuOptionTable where the nextMenu key was not nil, a menuRecord, nor a positive integer.  It was a "..type(nextMenu)..".  The menuOptionTable was: "..gen.tableToString(option))
    end
end

local function automaticMenuChoice(record,callingArgument,history,fullMenuTable)
    local autoChoiceWeights = record.autoChoiceWeights
    local weightsSoFar = 0
    local choicesTable = {}
    if autoChoiceWeights == nil then
        local message = "The menuRecord named "..record.menuName.." has tried to automatically complete a menu choice by relying on the 'autoChoiceWeights', but a weight function was never provided."
        local menuTable = {[1] = "Generate an error.",[2]="Let me choose manually instead."}
        local choice = text.menu(menuTable,message)
        if choice == 1 then
            error(message)
        else
            return humanMenuChoice(record,callingArgument,history,fullMenuTable)
        end
    end
    for key,menuOptionTable in pairs(fullMenuTable) do
        local weight = nil
        if menuOptionTable.noFilter then
            weight = true
        else
---@diagnostic disable-next-line: need-check-nil
            weight = autoChoiceWeights(menuOptionTable,callingArgument,history,fullMenuTable)
        end
        if type(weight) == "number" and weight > 0 then
            choicesTable[weightsSoFar] = menuOptionTable
            weightsSoFar = weightsSoFar+weight
        elseif type(weight) ~= "number" and type(weight) ~= "boolean" then
            error("menuRecord: "..record.menuName..": autoChoiceWeights should only return numbers and booleans.  Received: "..tostring(weight))
        end
    end
    local thresholdTable = gen.makeThresholdTable(choicesTable)
    --for key,val in pairs(thresholdTable) do
    --    print(key,val.optionName)
    --end
    --print(weightsSoFar)
    local randomNumber = weightsSoFar*math.random()
    return thresholdTable[randomNumber]
end





local function menuRecordCall(record,callingArgument,history,menuRecordHistory)
    history = history or gen.newEmptyStack()
    if not gen.isStack(history) then
        error("menuRecord: "..record.menuName..": Argument #2 (history) must be nil, or a stack.  Received: "..tostring(history))
    end
    menuRecordHistory = menuRecordHistory or gen.newEmptyStack()
    if not gen.isStack(menuRecordHistory) then
        error("menuRecord: "..record.menuName..": Argument #3 (menuRecordHistory) must be nil, or a stack.  Received: "..tostring(menuRecordHistory))
    end
    local menuSpec = nil
    if type(record.menuGenerator) == "table" then
        menuSpec = record.menuGenerator
    else
        menuSpec = record.menuGenerator(callingArgument,history)
    end
    if not menuGeneratorCheck(menuSpec) then
        error("menuRecord: "..record.menuName..": the function registered to menuGenerator should return a table of the form {[integer] = menuOptionTable,}, where menuOptionTable = {choice=menuChoice, optionName=string, nextMenu = nil or menuRecord or integer>0, noFilter = boolOrNil, <userDefKey> = <userUsefulValue>}.  Received: "..gen.tableToString(menuSpec))
    end
    local choiceResult = record.autoChoice(callingArgument,history,menuSpec)
    if choiceResult == false then
        choiceResult = humanMenuChoice(record,callingArgument,history,menuSpec)
    elseif choiceResult == true then
        choiceResult = automaticMenuChoice(record,callingArgument,history,menuSpec)
    else
        autoChoiceResultCheck(choiceResult,record)
    end
    if choiceResult.nextMenu == nil then
        -- the menu is concluded
        menuRecordHistory.push(record)
        history.push(choiceResult.choice)
        local processedChoice = record.postProcessor(callingArgument,choiceResult.choice,history,menuRecordHistory)
        return choiceResult.choice, history, menuRecordHistory
    elseif type(choiceResult.nextMenu) == "number" then
        -- go to previous menu states
        -- We don't want to go beyond the first menuRecordHistory item,
        -- although we can remove it from the stack
        local newRecord = nil
        for i=1,math.min(choiceResult.nextMenu,menuRecordHistory.size) do
            history.pop()
            newRecord = menuRecordHistory.pop()
        end
        -- if no newRecord, the currentRecord and history will work
        newRecord = newRecord or record
        return newRecord(callingArgument,history,menuRecordHistory)
    elseif text.isMenuRecord(choiceResult.nextMenu) then
        -- go to the next menu
        menuRecordHistory.push(record)
        history.push(choiceResult.choice)
        record.postProcessor(callingArgument,choiceResult.choice,history,menuRecordHistory)
        return choiceResult.nextMenu(callingArgument,history,menuRecordHistory)
    else
        error("menuRecord: "..record.menuName.." the nextMenu key of a menuOptionTable wasn't a menuRecord, integer, or nil.  The menuOptionTable is "..gen.tableToString(choiceResult))
    end
end

menuRecordMetatable.__call = menuRecordCall
menuRecordMetatable.__tostring = function(record) return "menuRecord<menuName="..record.menuName..">" end

-- This is some example menuRecord code
--  Some units are offered for sale for a given price and quantity
--  A human player must choose a category of units (domain = 0,1,2)
--  Then a unit type must be chosen,
--  Then, a city to create the unit(s) must be chosen, which must
--  be a port city if the unit type is naval.
--  Finally, confirmation must be given.
--  The human can cancel, but the AI will only do the equivalent if
--  it can't make a valid choice
--
--  If an AI is 'choosing', then it has 1/3 chance of choosing
--  each domain.  If the domain is land, units types are given
--  a weight equal to their attack value, and chosen at random.
--
--  If the domain is air, the AI chooses the cheapest choice.
--
--  If the domain is sea, the AI chooses the only among the choices
--  with the most units offered, and gives higher weight to unitTypes with
--  higher build cost
--  the AI does not have to have sufficient funds to make the purchase
local example = {}
--  The callingArgument will be the tribe buying the unit
example.categoryMenuRecord = text.newMenuRecord({menuName = "Category Menu"})
example.unitMenuRecord = text.newMenuRecord({menuName = "Unit Menu"})
example.cityMenuRecord = text.newMenuRecord({menuName = "City Menu"})
example.confirmMenuRecord = text.newMenuRecord({menuName = "Confirm Menu"})


--  First Menu: Choose a Unit Type Domain
--      In this menu, there are 3 choices plus cancel
--      If the tribe doesn't have a port city,
--      the sea option is removed
--
--      the same menu filter is used both for the human
--      and for the AI's autoChoiceWeights
--      the autoChoice just checks if the tribe is human or not


example.categoryMenuGenerator = {
    {choice = 0, optionName = "Land", nextMenu = example.unitMenuRecord},
    {choice = 1, optionName = "Air", nextMenu = example.unitMenuRecord},
    {choice = 2, optionName = "Sea", nextMenu = example.unitMenuRecord},
}
example.categoryMenuRecord.canCancel= true
--  This filter will be used both for the human and the autoChoiceWeights
function example.categoryMenuFilter(menuOptionTable,callingArgument,history,fullMenuTable)
    local tribe = callingArgument
    -- for land/air, return a weight of 1 for both
    if menuOptionTable.choice ~= 2 then
        return 1
    end
    -- here, we're at choice ==2, meaning sea
    -- we check if the tribe has a port city
    for city in civ.iterateCities() do
        if city.owner == tribe and gen.isBuildShips(city) then
            return 1
        end
    end
    -- if we're here, the tribe has no port city, so we don't want to
    -- offer them ships
    return false
end

function example.categoryAutoChoice(callingArgument,history,fullMenuTable)
    if callingArgument.isHuman then
        -- no auto choice, if the tribe is human
        return false
    else
        -- AI, but we want weights to be chosen
        return true
    end
end

example.categoryMenuRecord.menuGenerator = example.categoryMenuGenerator
example.categoryMenuRecord.menuFilter = example.categoryMenuFilter
example.categoryMenuRecord.autoChoice = example.categoryAutoChoice
example.categoryMenuRecord.autoChoiceWeights = example.categoryMenuFilter
example.categoryMenuRecord.menuText = "What kind of units do you wish to buy?"
example.categoryMenuRecord.menuTitle = "Procurement Minister"
-- Make the category menu tall and skinny just to demonstrate it.
example.categoryMenuRecord.height = 900
example.categoryMenuRecord.width = 100

-- Second Menu: Choose a Unit Type
--      A table is constructed for the menuGenerator field from the data in example.unitData
--      For a human, the filter is unitType domain and cost <= treasury
--      domain is taken from the first entry in the history stack
--      For the ai, behaviour is different based on the domain.
--          If air, choose a cheapest option and immediately return
--          For land, weight probability based on attack
--          For Sea, choose from the options that produce the most units,
--          with filtering help from an extra key in the menuOptionTable
--      There is also an option for humans to go back to the previous menu


-- example.unitData[unitType.id] = {numberToCreate, cost}
example.unitData = {
    [gen.original.uWarriors.id] = { 5, 100},
    [gen.original.uPhalanx.id] = { 4, 200},
    [gen.original.uMusketeers.id] = { 3, 300},
    [gen.original.uRiflemen.id] = {2, 400},
    [gen.original.uArmor.id] = {1, 500},
    [gen.original.uFighter.id] = {3, 600},
    [gen.original.uHelicopter.id] = {2,700},
    [gen.original.uStlthBmbr.id] = {1, 1000},
    [gen.original.uTrireme.id] = {3,300},
    [gen.original.uCaravel.id] = {2,300},
    [gen.original.uTransport.id] = {1,500},
    [gen.original.uSubmarine.id] = {3,1000},
}

example.unitMenuGenerator = {
    -- with noFilter = true, this won't be relevant in the menuFilter or autoChoiceWeights functions
    [-2] = {choice = nil, optionName = "Choose a different category.", nextMenu = 1, noFilter = true},
}
example.unitMenuRecord.canCancel = true
-- get the max quantity of sea units offered, to help
-- the autoChoice
example.maxSeaQuantity = 0
for key,val in pairs(example.unitData) do
    if civ.getUnitType(key).domain == 2 and val[1] > example.maxSeaQuantity then
        example.maxSeaQuantity = val[1]
    end
end
for key,val in pairs(example.unitData) do
    local choiceName = text.substitute("%STRING2 %NAME1 %#unit#2 for %MONEY3",{civ.getUnitType(key),val[1],val[2]})
    local seaQuantityValue = nil
    if val[1] == example.maxSeaQuantity and civ.getUnitType(key).domain == 2 then
        seaQuantityValue = true
    end
    example.unitMenuGenerator[key] = {choice={type = civ.getUnitType(key), quantity = val[1], cost = val[2]},
        optionName = choiceName, nextMenu = example.cityMenuRecord, seaQuantityExtra = seaQuantityValue,}
    -- seaQuantityExtra is a key to help a weight function determine if the sea unit type
    -- will produce the most units.
    -- (note: this method works because the AI isn't limited by budget in this example)
end
example.unitMenuRecord.menuGenerator = example.unitMenuGenerator
function example.unitMenuFilter(menuOptionTable,callingArgument,history,fullMenuTable)
    -- callingArgument left as a variable name for clarity
    local tribe = callingArgument
    local domain = history[1] -- domain integer was the choice of the previous menu
    if menuOptionTable.choice.cost > tribe.money then
        -- don't show choices that are too expensive for the human player
        return false
    end
    if menuOptionTable.choice.type.domain ~= domain then
        -- don't show choices from the wrong domain
        return false
    end
    -- don't give weights to change the order of the results
    return true
end
example.unitMenuRecord.menuFilter = example.unitMenuFilter
example.unitMenuRecord.menuText = "Please choose some units to acquire."
example.unitMenuRecord.menuTitle = "Procurement Minister"
function example.unitAutoChoice(callingArgument,history,fullMenuTable)
    local tribe = callingArgument
    if tribe.isHuman then
        return false
    end
    if history[1] == 1 then
        -- domain is Air, so choose the cheapest option
        -- make a generic menuOptionTable to start with
        local cheapestOption = {choice={type=nil, quantity=0, cost=math.huge}, optionName = ""}
        for key,menuOptionTable in pairs(fullMenuTable) do
            -- note, the 'choose a different category' choice appears in the full menu, with choice = nil
            -- so we must make sure that menuOption.choice exists here
            if menuOptionTable.choice and  menuOptionTable.choice.type.domain == 1 and 
                menuOptionTable.choice.cost < cheapestOption.choice.cost then
                cheapestOption = menuOptionTable
            end
        end
        if not cheapestOption.choice.type then
            -- no air unit was found, return a choice of nil
            -- a nil choice with no nextMenu will close the menu as if
            -- it were cancelled
            cheapestOption.choice = nil
        end
        return cheapestOption
    end
    -- 
    return true
end

function example.unitAutoChoiceWeights(menuOptionTable,callingArgument,history,fullMenuTable)
    if history[1] == 0 then
        -- ground domain chosen
        if menuOptionTable.choice.type.domain ~= 0 then
            return false
        else
            return menuOptionTable.choice.type.attack
        end
    end
    if history[1] == 1 then
        error("unitAutoChoiceWeights: it shouldn't be possible to be giving autochoice weights to air units.")
    end
    -- sea units
    if menuOptionTable.seaQuantityExtra then
        return menuOptionTable.choice.type.cost
    else
        return false
    end
end
example.unitMenuRecord.autoChoice = example.unitAutoChoice
example.unitMenuRecord.autoChoiceWeights = example.unitAutoChoiceWeights


-- Third Menu: Choose A City
--      This time, the menuGenerator is a function, which creates a list
--      of cities to choose.  The generated choice will also include
--      all the fields from the previous choice, for ease of use
--      in the next step, and when the function is returned
--
--      The menuGenerator will automatically filter out cities not owned
--      by the tribe.  Filtering out inland cities for naval units
--      will be done by the menuFilter function
--      Eligible cities will be displayed in descending order of population,
--      and the same function will be used to give the AI weights for cities.
--
--      Human tribes will offered a confirmation menu, while the AI result
--      will immediately return a choice

function example.cityMenuGenerator(callingArgument,history)
    local previousChoice = history[1]
    local tribe = callingArgument
    local generatedMenu = {
        [-2] = {choice = nil, optionName = "Choose a different unit domain.", nextMenu = 2, noFilter = true},
        [-1] = {choice = nil, optionName = "Choose a different unit.", nextMenu = 1, noFilter = true},
    }
    local nextMenu = nil
    if tribe.isHuman then
        nextMenu = example.confirmMenuRecord
    end
    for city in civ.iterateCities() do
        if city.owner == tribe then
            generatedMenu[city.id] = {choice = {city = city, type = previousChoice.type,
                    quantity = previousChoice.quantity, cost = previousChoice.cost,},
                optionName = city.name.." (pop. "..city.size..")", nextMenu = nextMenu,}
        end
    end
    return generatedMenu
end
example.cityMenuRecord.menuGenerator = example.cityMenuGenerator
example.cityMenuRecord.canCancel = true

function example.cityMenuFilter(menuOptionTable, callingArgument, history, fullMenuTable)
    -- 2 menus ago, the unit's domain was recorded in the history as an integer
    local domain = history[2]
    if domain == 2 and not gen.isBuildShips(menuOptionTable.choice.city) then
        return false
    else
        return menuOptionTable.choice.city.size
    end
end
example.cityMenuRecord.menuFilter = example.cityMenuFilter

function example.cityMenuText(callingArgument, history)
    local previousChoice = history[1]
    return text.substitute("Where do you wish to receive the %STRING1 %NAME2 %#unit#1?",
        {previousChoice.quantity, previousChoice.type})
end
example.cityMenuRecord.menuText = example.cityMenuText

-- The title for this example probably didn't have to be a function, but
-- it is here as an example
function example.cityMenuTitle(callingArgument,history)
    if history[2] == 0 then
        return text.substitute("Procuring Land %#Unit#[quantity]",history[1])
    elseif history[2] == 1 then
        return text.substitute("Procuring Air %#Unit#[quantity]",history[1])
    elseif history[2] == 2 then
        return text.substitute("Procuring Sea %#Unit#[quantity]",history[1])
    end
    return "Procuring Unit of Unknown Domain"
end
example.cityMenuRecord.menuTitle = example.cityMenuTitle

-- if the tribe is AI, return true to use the weight function for probabilities
example.cityMenuRecord.autoChoice = function(tribe,b,c) return not tribe.isHuman end

-- use the same weight function as for the menuFilter
example.cityMenuRecord.autoChoiceWeights = example.cityMenuFilter

-- show an image of the selected unit type
example.cityMenuRecord.menuImage = function(tribe,history)
    return text.unitTypeImage(history[1].type)
end

example.confirmMenuGenerator = function(tribe,history)
    local menuGenerator = {
        [-3] = {choice = nil, optionName = "No, choose a different unit domain.", nextMenu = 3, noFilter = true},
        [-2] = {choice = nil, optionName = "No, choose a different unit.", nextMenu = 2, noFilter = true},
        [-1] = {choice = nil, optionName = "No, choose a different city.", nextMenu = 1, noFilter = true},
        [1] = {choice = history[1], optionName = "Yes, that is correct.", noFilter=true} ,
    }
    return menuGenerator
end


example.confirmMenuRecord.menuGenerator = example.confirmMenuGenerator
-- will omit the canCancel option for this menu, just for show.
-- Don't need to filter this menu
example.confirmMenuRecord.menuText = "Do you wish to receive %STRING[quantity] %NAME[type] %#unit#[quantity] in %NAME[city] for %MONEY[cost]?"
example.confirmMenuRecord.menuTitle = "Confirm Procuring %NAME[city]"
-- don't need an autoChoice, since only humans receive this menu
-- similarly, don't need autoChoiceWeights

example.confirmMenuRecord.menuImage = function(tribe,history)
    return text.unitTypeImage(history[1].type)
end










console.text = text
--console.showUnitImage = function(unitOrID) text.simple("","",text.unitTypeImage(unitOrID)) end
--console.text.registerUnitsImage("unitsFile.bmp")

function console.sampleMenu(tribeID)
    if gen.isEmpty(unitTypeImages) then
        text.registerUnitsImage("Units.bmp")
    end
    local choice = example.categoryMenuRecord(civ.getTribe(tribeID))
    civ.ui.text(gen.tableToString(choice))
end

example.chosenCityName = {}
example.chosenUnitName = {}
example.domain = {land=0,air=0,sea=0}
example.domainToStr = {[0] = "land","air","sea"}
example.nameToDomain = {}
    for id,_ in pairs(example.unitData) do
        example.nameToDomain[civ.getUnitType(id).name] = example.domainToStr[civ.getUnitType(id).domain]
    end
function console.menuAutoTest(tribeID)
    example.chosenCityName = {}
    example.chosenUnitName = {}
    example.domain = {land=0,air=0,sea=0}
    local n = 5000
    if civ.getTribe(tribeID).isHuman then
        n=1
    end
    local function getDomain(choice)
        local unitType = choice.type
        if unitType.domain == 0 then
            return "land"
        elseif unitType.domain == 1 then
            return "air"
        else
            return "sea"
        end
    end
    local tribe = civ.getTribe(tribeID)
    for i=1,n do
        local choice = example.categoryMenuRecord(tribe)
        if choice and choice.type.domain == 2 and not gen.isBuildShips(choice.city) then
            error("Inland city chosen for ship")
        end
        --[1] is city, [2] is tribe
        example.chosenCityName[choice.city.name] = example.chosenCityName[choice.city.name] or 0
        example.chosenCityName[choice.city.name] = example.chosenCityName[choice.city.name] +1
        example.chosenUnitName[choice.type.name] = example.chosenUnitName[choice.type.name] or 0
        example.chosenUnitName[choice.type.name] = example.chosenUnitName[choice.type.name] +1
        example.domain[getDomain(choice)] = example.domain[getDomain(choice)] +1
    end
    for key,val in pairs(example.domain) do
        print(key,val/n)
    end
    for key,val in pairs(example.chosenCityName) do
        print(key,val/n)
    end
    for key,val in pairs(example.chosenUnitName) do
        print(key,val/example.domain[example.nameToDomain[key]])
    end
end


--  text.makeChooseNumberMenu(increments={1,10,50,100,500,1000, -1,-10,-100},extremes={min=0,max=10000},selectionKey="menuChosenNumber",nextMenu=nil,goBackOptions = {},menuName="Choose Number Menu",plusOptionWrapper="Add %STRING1",minusOptionWrapper="Subtract %STRING1",confirmOptionWrapper="Select %STRING1")
--      Creates a menu which allows the user to select a positive integer.
--      This is actually a series of menus, but using post processing,
--      it will only count as 1 element of history and menuRecordHistory.
--
--      The increments specifies the increments you want the user to be
--      able to select.  This table should have integer keys starting at 1
--      with no gaps.
--
--      This menu expects to receive the previous choice in the history
--      as a table, and will return a copy of that table with an
--      extra key, specified by selectionKey, that gives the chosen number.
--      (if the previous choice has selectionKey already specified, that acts
--      as a starting point for this menu, instead of 0)
--
--      The nextMenu specifies what menuRecord should be called once a final choice
--      has been made.  If nil, the menuRecord will return the choice.
--
--      goBackOptions = {[orderInt]={goBack=positiveInteger, optionName="Go Back Option Name"}}
--      Gives options to go back to previous menus, along with the name of such options.
--      orderInt is the order in which these options appear, level is the number of
--      menus to go back
--      orderInt should start at 1 and have no gaps
--
--      menuName = string
--          a name for the menuRecord that will appear in some error messages
--
--      plusOptionWrapper = string
--          A string for which text.substitute will be used to generate the option
--          name, with the increment substituting %STIRNG1
--          Applies when the option is positive
--          If nil, the option name will be "Add %STRING1"
--      minusOptionWrapper = string
--          A string for which text.substitute will be used to generate the option
--          name, with the increment substituting %STIRNG1
--          Applies when the option is negative
--          If nil, the option name will be "Subtract %STRING1"
--      confirmOptionWrapper = string
--          A string for which text.substitute will be used to generate the option
--          name, with the increment substituting %STIRNG1
--          Applies for the selection of the current number
--          
--
--      The menuRecord created will have a menuGenerator and postProcessor created already.
--      You still have to create the other entries in the menuRecord, like menuText, menuTitle,
--      and image.   You can use autoChoice to immediately return a choice, but don't 
--      try to use autoChoiceWeights.  Leave that as nil.
--
--      
--

function text.makeChooseNumberMenu(increments,extremes,selectionKey,nextMenu,goBackOptions,menuName,plusOptionWrapper,minusOptionWrapper,confirmOptionWrapper)
    increments = increments or {1,10,50,100,500,1000, -1,-10,-100}
    extremes = extremes or {min=0,max=10000}
    selectionKey = selectionKey or "menuChosenNumber"
    nextMenu = nextMenu or nil
    goBackOptions = goBackOptions or {}
    menuName = menuName or "Choose Number Menu"
    plusOptionWrapper = plusOptionWrapper or "Add %STRING1"
    minusOptionWrapper = minusOptionWrapper or "Subtract %STRING1"
    confirmOptionWrapper = confirmOptionWrapper or "Select %STRING1"
    local returnMenu = text.newMenuRecord({menuName=menuName})
    
    local function menuGen(callingArgument,history)
        local lastHistory = history[1] or {}
        local currentChoice = lastHistory[selectionKey] or 0
        local menu = {}
        local menuIndex = 1
        for i=1,#increments do
            local c = gen.copyTable(lastHistory)
            c[selectionKey] = c[selectionKey] or 0
            local maxBinding = false
            local minBinding = false
            if c[selectionKey] == extremes.max then
                maxBinding = true
            end
            if c[selectionKey] == extremes.min then
                minBinding = true
            end
            c[selectionKey] = math.min(extremes.max,math.max(extremes.min,currentChoice+increments[i]))
            local inc = increments[i]
            if inc >= 0 and not maxBinding then
                menu[menuIndex] = {choice = c, nextMenu = returnMenu, optionName = text.substitute(plusOptionWrapper,{inc})}
                menuIndex = menuIndex+1
            elseif inc < 0 and not minBinding then
                menu[menuIndex] = {choice = c, nextMenu = returnMenu, optionName = text.substitute(minusOptionWrapper,{math.abs(inc)}),
            }
                menuIndex = menuIndex+1
            end
        end
        local c = gen.copyTable(lastHistory)
        c[selectionKey] = currentChoice
        menu[menuIndex] = {choice = c, nextMenu = nextMenu, optionName = text.substitute(confirmOptionWrapper,{currentChoice})}
        menuIndex = menuIndex+1
        for i=1,#goBackOptions do
            menu[menuIndex] = {choice = nil, nextMenu = goBackOptions[i].goBack, 
                optionName = goBackOptions[i].optionName}
            menuIndex = menuIndex+1
        end
        return menu
    end

    local function postProcess(callingArgument,choice,history,menuRecordHistory)
        local recentHistory = history.pop()
        local recentMenuHistory = menuRecordHistory.pop()
        -- remove previous history also
        -- but first, check to make sure you are removing an instance of
        -- the same menu
        if menuRecordHistory[1] == returnMenu then
            history.pop()
            menuRecordHistory.pop()
        end
        -- add back most recent choice
        history.push(recentHistory)
        menuRecordHistory.push(recentMenuHistory)
        return choice
    end
    returnMenu.menuGenerator = menuGen
    returnMenu.postProcessor = postProcess
    return returnMenu
end

-- In this menu example, the human will 'hire' some mercenaries
--  The first menu will choose a mercenary type, the second will choose
--  a quantity of that unit type, and the third menu will confirm the choice
--  They will not be able to choose a number of mercenaries they can't afford
--  The callingArgument is the tribe

example.hireMercMenu = text.newMenuRecord({menuName="Choose Mercenary"})
example.confirmMenu = text.newMenuRecord({menuName="Confirm Mercenary Choice"})
example.chooseNumberMenu = text.makeChooseNumberMenu({1,5,10,-1,-10},{min=0,max=25},"quantity",
    example.confirmMenu, {{goBack=1, optionName="Choose Different Mercenary Type."}},"Choose number Menu")
        
-- specifying a quantity in these options initializes the choose number menu to something other than 0.
-- This is omitted from the archer selection to test the nil case

-- The quantity here
example.mercenaryList = {
    [1] = {choice = {type = gen.original.uWarriors, costPer = 10, quantity = 5}, optionName = "Hire "..gen.original.uWarriors.name.." (10 each)",nextMenu = example.chooseNumberMenu},
    [2] = {choice = {type = gen.original.uPhalanx, costPer = 15, quantity = 3}, optionName = "Hire "..gen.original.uPhalanx.name.." (15 each)",nextMenu = example.chooseNumberMenu},
    [3] = {choice = {type = gen.original.uArchers, costPer = 20, quantity=nil}, optionName = "Hire "..gen.original.uArchers.name.." (20 each)",nextMenu = example.chooseNumberMenu},
}

example.hireMercMenu.menuGenerator = example.mercenaryList
example.hireMercMenu.menuText = "What type of mercenary should we hire?"
example.hireMercMenu.menuTitle = "Hire Mercenaries"

example.chooseNumberMenu.menuText = function(callingArgument,history)
    local lastChoice = history[1]
    local substitutionTable = gen.copyTable(lastChoice)
    -- the lastChoice might not have a default quantity (due to tests), so use the default quantity of 0
    substitutionTable.quantity = substitutionTable.quantity or 0
    substitutionTable.totalCost = substitutionTable.quantity*substitutionTable.costPer
    local menuText = text.substitute("We are going to hire %STRING[quantity] %#%NAME[type]#[quantity] for %MONEY[totalCost].  Do you wish to make any changes?",substitutionTable)
    return menuText
end
example.chooseNumberMenu.menuTitle = "Hire Mercenaries"
-- filter out options which are too expensive
example.chooseNumberMenu.menuFilter = function(optionTable,tribe,history,fullMenuTable)
    
    if optionTable.choice and optionTable.choice.quantity*optionTable.choice.costPer > tribe.money then
        return false
    end
    return true
end

example.confirmMenu.menuGenerator = function(tribe,history)
    local menu = {}
    menu[1] = {choice = nil, optionName = "No, the amount to hire is incorrect.", nextMenu = 1}
    menu[2] = {choice = nil, optionName = "No, we should hire a different type of mercenary.", nextMenu = 2}
    menu[3] = {choice = history[1], optionName = "Yes, make the arrangements."}
    return menu
end

example.confirmMenu.menuText = function(callingArgument,history)
    local lastChoice = history[1]
    local substitutionTable = gen.copyTable(lastChoice)
    substitutionTable.totalCost = lastChoice.quantity*lastChoice.costPer
    local menuText = text.substitute("We are going to hire %STRING[quantity] %#%NAME[type]#[quantity] for %MONEY[totalCost].  Is this correct?",substitutionTable)
    return menuText
end

example.confirmMenu.menuTitle = "Confirm"

function console.hireMercTest()
    civ.ui.text(gen.tableToString(example.hireMercMenu(civ.getCurrentTribe())))
end
    



return text















