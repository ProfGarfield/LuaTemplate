-- this file can be deleted if you are not shipping custom music
--
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
local gen = require("generalLibrary"):minVersion(1)
local text = require("text")

-- By default, custom music is disabled
-- If you don't plan to use custom music, you
-- may wish to delete @PICKMUSICTOT from Game.txt,
-- so that the list from the Original folder is used instead.
-- (There is an "Extended Music For TOTPP" addition that I wrote
-- which benefits from modifying @PICKMUSICTOT, and which this
-- module will supersede if active
local useCustomMusic = false

if useCustomMusic and totpp.patches.DirectShowMusic then
    -- do everything else in this file

local trackList = {}

-- These are the files played for each of the options in
-- @PICKMUSICTOT
-- You can add extra entries to trackList, but you should
-- probably also add entries to @PICKMUSICTOT if you do
-- (stuff won't break if you don't, just some tracks won't
-- be selectable, or selected when being played)

trackList[0] =  "Funeral March.mp3"
trackList[1] =  "Ode to Joy.mp3"
trackList[2] =  "Crusade.mp3"
trackList[3] =  "Alien.mp3"
trackList[4] =  "Mongol Horde.mp3"
trackList[5] =  "The Apocalypse.mp3" -- note that in @PICKMUSICTOT, this is misspelled
trackList[6] =  "Jurassic Jungle.mp3"
trackList[7] =  "New World.mp3"
trackList[8] =  "Tolkien.mp3"
trackList[9] =  "Mars Expedition.mp3"
trackList[10] = "Jules Verne.mp3"
trackList[11] = "They're Here.mp3"
trackList[12] = "The Dome.mp3"


-- A check will be made to make sure all the files are available
-- If the scenario directory does not contain a music folder,
-- failure will be silent, and missing tracks will be replaced
-- with default tracks known to be available
-- Failure will also be silent if a file called missingmusic.txt
-- is in the music directory
-- Otherwise, an error will be thrown detailing the missing tracks.





-- Found this code on stackoverflow.com
-- https://stackoverflow.com/questions/5303174/how-to-get-list-of-directories-in-lua
local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen([[dir "]]..directory..[[" /b]])
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end
local scenarioDirFiles = scandir(gen.getScenarioDirectory())
local musicDirectoryExists = false
for key,value in pairs(scenarioDirFiles) do
    if string.lower(value) == "music" then
        musicDirectoryExists = true
    end
end

local localMusicFiles = scandir(gen.getScenarioDirectory().."\\Music")
local globalMusicFiles = scandir(civ.getToTDir().."\\Music")

-- these are the tracks that are guaranteed to be in
-- <Test of Time>\Music in order to make DirectShow Music work
local shippedTracks = {}
shippedTracks[0] =  "Funeral March.mp3"
shippedTracks[1] =  "Ode to Joy.mp3"
shippedTracks[2] =  "Crusade.mp3"
shippedTracks[3] =  "Alien.mp3"
shippedTracks[4] =  "Mongol Horde.mp3"
shippedTracks[5] =  "The Apocolypse.mp3"
shippedTracks[6] =  "Jurassic Jungle.mp3"
shippedTracks[7] =  "New World.mp3"
shippedTracks[8] =  "Tolkien.mp3"
shippedTracks[9] =  "Mars Expedition.mp3"
shippedTracks[10] = "Jules Verne.mp3"
shippedTracks[11] = "They're Here.mp3"
shippedTracks[12] = "The Dome.mp3"

local missingTracks = ""
local allTracksFound = true
for i=0,#trackList do
    if not gen.inTable(trackList[i],localMusicFiles) and not gen.inTable(trackList[i],globalMusicFiles) then
        print("Music: Could not find "..trackList[i])
        missingTracks = missingTracks..trackList[i]..", "
        allTracksFound = false
        if i <= 12 then
            trackList[i] = shippedTracks[i]
        else
            trackList[i] = shippedTracks[math.random(2,12)]
        end
    end
end
local missingmusicExists = false
for key,filename in pairs(localMusicFiles) do
    if string.lower(filename) == "missingmusic.txt" then
        missingmusicExists = true
        break
    end
end
if not allTracksFound then
    if musicDirectoryExists and not missingmusicExists then
        -- show message
        local message = "Notice: The following music files were not found.  You can suppress this message by adding an (empty) file called missingmusic.txt to the Music directory of this scenario, or by removing (or renaming) the Music directory.  This list is also printed to the console.  "..missingTracks:sub(1,-3)..".  Replacements have been chosen from the default Civ II music."
        text.simple(message)
    end
end


local function onSelectMusic(track)
    if track then
        civ.playMusic(trackList[track])
        return track
    else
        local choice = math.random(2,#trackList)
        -- note that #table gives a value i such that table[i] ~= nil
        -- but table[i+1] == nil.  Hence we don't have to worry
        -- about there being a 0 track
        civ.playMusic(trackList[choice])
        return choice
    end
end

--Registers a function that is called when a new music track is to be played. `track` is either nil or an integer. If nil, the game wants to play a random track, if not nil it's either due to the user choosing a track from the menu (first track has id 0), or the game playing one of it's special tracks ("Funeral March" - track id 0, and "Ode to Joy" - track id 1). To handle special tracks, you can return nil to signal that the game should play the default track associated with that track id. If you want to handle this track id, call civ.playMusic (this will check the Music folder of the scenario first before falling back to the global Music folder) and return an integer, which is used to synchronize the track list in the menu. The track names can be added in @PICKMUSICTOT in Game.txt.

civ.scen.onSelectMusic(onSelectMusic)
end

local customMusicIntegration = {}
gen.versionFunctions(customMusicIntegration,versionNumber,fileModified,"LuaParameterFiles".."\\".."customMusicIntegration.lua")

return customMusicIntegration
