-- 
--  You can use this file to set "traits" for different
--  kinds of civ objects.
--
--  You can generate a template file by using the script
--  makeSetTraits.lua
--
--  To access traits in other files, you must require
--  the traits module, but requiring this module is not necessary
--  in each file.
local traits = require("traits")
local object = require("object")
local gen = require("generalLibrary")

--[[
traits.allowedTraits("religiousBuilding","mounted","siege engine","science wonder")

traits.assign(gen.original.iCathedral,"religiousBuilding")
traits.assign(gen.original.iTemple,"religiousBuilding")

traits.assign({gen.original.uHorsemen, gen.original.uKnights, gen.original.uCrusaders,
        gen.original.uDragoons, gen.original.uCavalry}, "mounted")

traits.assign({gen.original.uCatapult, gen.original.uCannon, gen.original.uArtillery},"siege engine")

traits.assign({gen.original.wCopernicusObservatory, gen.original.wIsaacNewtonsCollege, gen.original.wSETIProgram},"science wonder")
--]]


return {}
