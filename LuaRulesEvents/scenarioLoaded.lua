
local gen = require("generalLibrary")
local object = require("object")
local param = require("parameters")
local legacy = require("legacyEventEngine")
local consolidated = require("consolidatedEvents")
local discreteEvents = require("discreteEventsRegistrar")
local scenarioLoaded = {}
function scenarioLoaded.scenarioLoadedFn()
    legacy.doScenarioLoadedEvents()
    consolidated.onScenarioLoaded()
    discreteEvents.performOnScenarioLoaded()
end
return scenarioLoaded
