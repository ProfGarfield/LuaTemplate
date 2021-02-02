
local gen = require("generalLibrary")
local object = require("object")
local param = require("parameters")
local legacy = require("legacyEventEngine")
local scenarioLoaded = {}
function scenarioLoaded.scenarioLoadedFn()
    legacy.doScenarioLoadedEvents()
end
return scenarioLoaded
