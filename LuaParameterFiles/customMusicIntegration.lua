-- this file can be deleted if you are not shipping custom music

local gen = require("generalLibrary")
local customMusicFound,customMusic = gen.requireIfAvailable(civ.getToTDir().."\\lua\\customMusic")

-- The custom music module is not directly included in the Lua Scenario Template
-- because it involves overwriting files in <ToT Directory>\Music,
-- and I think that should be something the end user actively chooses to allow 
-- or not.
--
-- The end user adds some lua files to <ToT Directory>\lua in order to enable
-- custom music, in particular customMusic.lua.  The installation instructions
-- can be found through this link
-- https://forums.civfanatics.com/threads/totpp-custom-music-patch.650161/#post-15555342
--

--  How to Use
--  Create a directory <Main Scenario>\Music
--
--  In Game.txt, find the section @PICKMUSICTOT
--  Change the options provided to the names you wish to give the music
--  (Any option that is not changed will play the original music)
--  There should always be 13 tracks
--  
--  Add the .mp3 music files to <Main Scenario>\Music.
--  Rename these files to match the track names provided in @PICKMUSICTOT,
--  including spaces, but excluding the " marks at the start and end of the
--  name (if you didn't use " marks at the start and end, that's fine)
--  You can optionally place an underscore (_) at the start of the file, which
--  would enable the end user to easily copy your music to their <ToT Directory>\Music
--  folder to add it to a playlist
--
--  For example
--[[
@PICKMUSICTOT
@width=480
@title=Select Music
@options
"Funeral March"
"Ode to Joy"
"American Revolution"
"Aristotle's Pupil"
"Augustus Rises"
"Gautama Ponders"
"Hammurabi's Code"
"Harvest of the Nile"
"Jihad"
"Tenochitlan Revealed"
"The Civil War"
"The Great War"
"The Shining Path"
--]]

-- would have the following file names
--[[
Funeral March.mp3
Ode to Joy.mp3
American Revolution.mp3
Aristotle's Pupil.mp3
Augustus Rises.mp3
Gautama Ponders.mp3
Hammurabi's Code.mp3
Harvest of the Nile.mp3
Jihad.mp3
Tenochitlan Revealed.mp3
The Civil War.mp3
The Great War.mp3
The Shining Path.mp3
--]]

-- or 
--[[
_Funeral March.mp3
_Ode to Joy.mp3
_American Revolution.mp3
_Aristotle's Pupil.mp3
_Augustus Rises.mp3
_Gautama Ponders.mp3
_Hammurabi's Code.mp3
_Harvest of the Nile.mp3
_Jihad.mp3
_Tenochitlan Revealed.mp3
_The Civil War.mp3
_The Great War.mp3
_The Shining Path.mp3
--]]
-- Note that Funeral March and Ode to Joy would be optional to include, since
-- music with the same name will exist in the base Test of Time Music, which
-- would play if it is missing
-- (Actually, that is true of all the music examples here, since they are files
-- included with the Custom Music Patch)


if customMusicFound then
    customMusic.importMusic(gen.getScenarioDirectory())
end
