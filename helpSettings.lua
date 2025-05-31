local help = require("help")
local configuration = require("configuration")
local keyboard = require("keyboard")
local text = require("text")


-- Registers custom movement multiplier names
-- for use in the unit help text box.
help.registerCustomMovementMultiplierNames(
    "Road","Rail","River","Alpine")