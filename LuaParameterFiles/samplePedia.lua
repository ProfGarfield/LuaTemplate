-- this file is not linked to the rest of the template
-- If you want to run it to generate a sample describe.txt file,
-- input to the console:
-- require("samplePedia")
-- to generate the describe.txt file, input to the console
-- require("civilopedia").makeDescribeTxt()
-- or, with Lua scenario template, 
-- console.makeDescribeTxt()

local civilopedia = require("civilopedia")
local gen = require("generalLibrary")

-- Purpose of the Civilopedia Module
--
-- The Civilopedia Module automatically generates a describe.txt
-- file based on information provided to it.  It allows the scenario
-- designer to add documentation to the Civilopedia at the same time
-- and place as the code which creates the feature.

-- Using the Civilopedia Module
--
-- The Civilopedia Module provides one main function:
-- civilopedia.description(object,description,extra)
-- It is used in slightly different ways depending
-- on what you want to add to the describe.txt file
-- that will be generated.
--
-- In all cases, the description string (the second argument)
-- will be added to the existing description for the object
-- in question.  Since there is no guarantee about the order
-- that the files will be required (and the corresponding
-- civilopedia.description function run), The text segments will not
-- necessarily be in the correct order, and you will have to change
-- them when you proofread the describe.txt file.
--
-- Take care to make sure that these function calls are outside your 
-- events, otherwise they won't contribute to the Civilopedia unless you
-- happen to trigger that event before generating the Pedia.
--
-- Technology Description
-- civilopedia.description(techObject,description)
--  Add string description for the advance corresponding to the techObject supplied.
--
-- Improvement Description
-- civilopedia.description(improvementObject,description)
--  Add string description to improvement corresponding to the improvementObject supplied.
--
-- Wonder Description
-- civilopedia.description(wonderObject,description)
--  Add string description to wonder corresponding to the wonderObject supplied.
--
-- Unit Type Description
-- civilopedia.description(unitTypeObject,description)
--  Add string description to unit type corresponding to the unitTypeObject supplied.
--
-- Terrain Description
-- civilopedia.description(terrainObject,description)
--  Add string description to terrain corresponding to the terrainObject supplied.
-- civilopedia.description(civ.getTerrain(map,2,0),description,"base")
--  Adds string description to the grassland replacement without shield for the given map,
--  and not to the shield version
-- civilopedia.description(civ.getTerrain(map,2,0),description,"shield")
--  Adds string description to the grassland replacement with shield for the given map, 
--  and not to the base version
-- civilopedia.description(civ.getTerrain(map,2,0),description)
--  Adds string description to all versions of the grassland replacement for the given map.
--
-- Government Description
-- civilopedia.description(governmentID,description)
--  Adds string description to the government corresponding to the governmentID (integer)
--  (i.e. 0=Anarchy, 1=Despotism, 2=Monarchy, 3=Communism, 4=Fundamentalism, 5=Republic, 6=Democracy)
-- civilopedia.description(governmentID,description,governmentName)
--  Adds string description to the government corresponding to the governmentID,
--  changes the name in the describe.txt to governmentName
--  Note: This change doesn't affect the name of governments in the game.
--  To do that, you change the Rules.txt @GOVERNMENTS
--
-- Game Concept Description
-- civilopedia.description(conceptName,description)
--  Adds string description to conceptName (string), adding the conceptName if it doesn't
--  already exist.
--  The Concepts are arranged by the game in alphabetical order.  If you want to prioritize
--  a concept, have the first character be a space.
--
-- Bulk Addition of Descriptions
-- civilopedia.description({list of objects},description)
--  adds description to all values in the table


civilopedia.description(gen.original.uEngineers,"Works twice as fast as other settler units.")

civilopedia.description(gen.original.uFreight,"Trade delivery bonus is 50% more than other trade units.")

civilopedia.description(gen.original.uSpy,"Has better diplomatic function than other diplomacy units.")

civilopedia.description(gen.original.uNuclearMsl,"Owning this unit changes diplomacy to reflect nuclear capability.")

civilopedia.description({gen.original.uNuclearMsl, gen.original.uEngineers, gen.original.uFreight, gen.original.uSpy},"This unit has special features.")

civilopedia.description(gen.original.aAlphabet,"Doubles the literacy demographics. This is cummulative with the effects of Writing, University, and Literacy")
civilopedia.description(gen.original.aAutomobile,"Increases population based pollution.")
civilopedia.description(gen.original.aAutomobile,"Automobile works with Electronics to change city pictures to the modern style (6th row in the cities.bmp file).")
civilopedia.description(gen.original.aAutomobile,"Automobile works with Electronics to change the look of people to the modern style (4th row in the people.bmp file).")
civilopedia.description(gen.original.aBridgeBuilding,"Allows settlers units to construct roads (and railroads) in river squares.")
civilopedia.description(gen.original.aCeremonialBurial,"Ceremonial Burial allows temples to make one additional person content. See also Mysticism.")
civilopedia.description(gen.original.aChivalry,"Changes the types of Barbarians produced by Goody Huts.")
civilopedia.description(gen.original.aChivalry,"Changes the types of sea-based random Barbarians units produced.")
civilopedia.description(gen.original.aCommunism,"Allows the government type of the same name.")
civilopedia.description(gen.original.aCommunism,"The discovery of Communism reduces the effect of Cathedrals by one.")
civilopedia.description(gen.original.aCommunism,"Cities produce more partisans.")
civilopedia.description(gen.original.aConscription,"Changes the types of Barbarians produced by Goody Huts.")
civilopedia.description(gen.original.aConstruction,"Construction allows settler units to build Fortresses.")
civilopedia.description(gen.original.aDemocracy,"Allows the government type of the same name.")
civilopedia.description(gen.original.aElectronics,"After the discovery of Electronics an additional citizen in each city is made content by coliseums.")
civilopedia.description(gen.original.aElectronics,"Electronics works with Automobile to change city pictures to the modern style (6th row in the cities.bmp file).")
civilopedia.description(gen.original.aElectronics,"Electronics works with Automobile to change the look of people to the modern style (4th row in the people.bmp file).")
civilopedia.description(gen.original.aEnvironmentalism,"Decreases population based pollution.")
civilopedia.description(gen.original.aFlight,"Reduces by one third the amount of gold and science produced by caravan delivery. This affect is cumulative with all other modifiers.")
civilopedia.description(gen.original.aFundamentalism,"Allows the government type of the same name.")
civilopedia.description(gen.original.aFundamentalism,"The Fundamentalism advance does NOT inherently allow Fanatics to be build. Only nations operating under the Fundamentalism government can build the Fanatics unit once the advance making the Fanatics available has been discovered.")
civilopedia.description(gen.original.aFundamentalism,"Upon changing government type from Fundamentalism to any other type all cities producing Fanatics will switch to producing the unit in the Riflemen slot whether or not the nation has the prerequisite advance to build this unit.")
civilopedia.description(gen.original.aFusionPower,"Eliminates the threat of Nuclear Power Plant meltdown.")
civilopedia.description(gen.original.aFusionPower,"Adds 25% to spaceship mass/thrust paradigm.")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")
--civilopedia.description(gen.original.a,"")

civilopedia.description("Disband",[[When a friendly unit becomes obsolete, costs too much to maintain, or causes unhappiness among your population, you might want to eliminate the unit. To eliminate a unit, order it to disband by holding down the shift key and pressing "D", or by selecting "Disband" from the Orders menu. Once disbanded, the unit is permanently removed from the game.]])
civilopedia.description("Disband",[[When a unit is disbanded inside a friendly city, half of the unit's production cost in Shields is added to the production of whatever unit, Improvement, or Wonder is currently under production in the city.]])
civilopedia.description("Irrigation",[[When the early farmers moved down from the hills into the valleys of the Nile, Tigris, and Euphrates Rivers, they had to develop the technology of irrigation. The freshwater rivers passed through lands essentially barren due to the lack of rainfall. Through irrigation, water could be removed from the rivers and spread on the nearby land, making it suitable for farming.]])

civilopedia.description("Irrigation",[[Irrigation increases Food production in Grasslands, Plains, Deserts, and Hills. Only squares vertically or horizontally adjacent to water (Oceans or Rivers) or another irrigated square can be irrigated. After the discovery of Refrigeration, terrain squares can be double-irrigated to create farmland. Settlers and Engineers can be ordered to irrigate by pressing the "I" key, or by selecting "Build Irrigation" from the Orders menu.]],1)



civilopedia.description("Fortify",[[Roman legions on campaign halted their march early enough each evening to build a completely fortified camp for the night. They had learned the value of defensive fortifications when under attack. Where possible, it was the standard practice of most armies to build defensive works of some type whenever expecting an attack. Fortified defenders had their fighting strength multiplied, making it much harder to defeat them.]])

civilopedia.description("Fortify",[[Ground units can be ordered to fortify by pressing the "F" key, or by selecting "Fortify" from the Orders menu. The defensive value of fortified units is increased by 50 percent.]])

civilopedia.description("Fortress",[[Once your civilization has discovered Construction, Settlers and Engineers have the ability to construct fortresses. Fortresses can be utilized to defend city perimeters and to block key points of access from enemy armies. A properly manned fortress can provide an effective defense by doubling the defensive strength of all units stationed within. Unlike normal combat, units stacked within a fortress defend and are destroyed one at a time in battle, rather than being destroyed simultaneously. Fortresses themselves do not suffer damage in the attack.

Settlers and Engineers can construct fortresses by pressing the "F" key, or choosing the Build Fortress command from the Orders menu. Units within a fortress have their defensive strengths doubled. Under a Republic, units stationed inside fortresses built within three squares of their home city do not cause unhappiness.]])


civilopedia.description(civ.getTerrain(0,2,0),[[The areas of land between desert regions and forests in temperate and tropical climates usually consist of grasslands. These fertile regions, covered with various types of vegetation, once occupied large areas of North and South America, Africa, and Eurasia. These areas are characterized by marked wet and dry seasons, with annual periods of drought. Although many grasslands are naturally occurring, grasslands can also be created through deforestation of woodland areas. Grasslands are often cultivated and used as pastures and grazing lands. Because of the relatively low rainfall in these regions, the topsoil is high in nutrients. Grasslands are, therefore, well suited for growing crops, especially grain crops.]])

civilopedia.description(civ.getTerrain(0,2,0),[[No shields are produced on this type of grassland]],"base")
civilopedia.description(civ.getTerrain(0,2,0),[[Shields are produced on this type of grassland]],"shield")

civilopedia.description(civ.getTerrain(0,10,0),[[Only ships and aircraft can cross oceans.]])
civilopedia.description(civ.getTerrain(0,10,1),[[Fish are a good source of extra food.]])
civilopedia.description(civ.getTerrain(0,10,2),[[Whales are one of the best special resources in the early game.]])

civilopedia.description(0,[[Anarchy represents not so much a government type as the lack of any stable government. Anarchy occurs when your civilization's government falls, or when you decide to have a Revolution. After a few turns of Anarchy, you can rebuild a new government. Anarchy is similar to Despotism, except that the corruption rate is VERY HIGH. However, no taxes are collected during a period of Anarchy, and no scientific research is conducted.]],"Anarchy Renamed")

civilopedia.description(2,"Each city can support "..civ.cosmic.supportMonarchy.." units free of charge.  All other units cost one Shield per turn.")

civilopedia.description(gen.original.iAqueduct,"Allows a city to grow beyond size "..civ.cosmic.sizeAquaduct..".")

civilopedia.description(gen.original.wPyramids,"Counts as a "..gen.original.iGranary.name.." in every city.")


civilopedia.makeDescribeTxt()

return {}
