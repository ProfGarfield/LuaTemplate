
local versionNumber = 1
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file

local legacyValidate = {}

local _,_,maps = civ.getAtlasDimensions()

---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(11)
gen.versionFunctions(legacyValidate,versionNumber,fileModified,"LuaCore".."\\".."legacyEventValidator.lua")
local civlua = require("civlua")

local unitTypeNames = {["anyunit"]=true}
for unitType in gen.iterateUnitTypes() do
    unitTypeNames[string.lower(unitType.name)] = true
end

local tribeNames = {["triggerattacker"]=true, ["triggerdefender"]=true, ["triggerreceiver"]=true, ["anybody"]=true}
for tribe in civlua.iterateTribes() do
    tribeNames[string.lower(tribe.name)] = true
end

local cityNames = {["none"]=true}
for city in civ.iterateCities() do
	cityNames[string.lower(city.name)] = true
end

local cityNamesSpec = {["string"] = cityNames}
--local cityNamesSpec = {["string"] = true}

local actionValidationInfo = {}

actionValidationInfo["bestowimprovement"] = {
    race = {["string"] = tribeNames},
    improvement = {["number"] = {minval = 0, maxVal = 67, integer = true}},
    capital = {["nil"] = true,["string"] = {["yes"] = true, ["no"] = true, ["on"] = true, ["off"] = true, ["true"] = true, ["false"] = true}},
    wonders = {["nil"] = true,["string"] = {["yes"] = true, ["no"] = true, ["on"] = true, ["off"] = true, ["true"] = true, ["false"] = true}},
}

actionValidationInfo["changemoney"] = {
    receiver = {["string"] = tribeNames},
    amount = {["number"] = {integer=true}},
}

actionValidationInfo["changeterrain"] = {
    map = {["nil"]=true, ["number"] = {minVal=0,maxVal=maps-1,integer=true}},
    terraintype = {["number"] = {minVal=0,maxVal=15,integer=true}},
    exceptionmask = {["nil"]=true, ["number"] = {integer=true},["string"] = true},
    maprect = {["table"] = true},
}

actionValidationInfo["createunit"] = {
    owner = {["string"] = tribeNames},
    unit = {["string"] = unitTypeNames},
    count = {["nil"] = true, ["number"] = {minVal=0,maxVal=255,integer=true}},
    homecity=cityNamesSpec,
    incapital={["nil"]=true,["boolean"]=true},
    locations={["table"]=true},
}

actionValidationInfo["destroyacivilization"] = {
    whom = {["string"] = tribeNames},
}

actionValidationInfo["enabletechnology"] = {
    whom = {["string"] = tribeNames},
    technology = {["number"] = {minVal = 0, maxVal = gen.c.maxTechID, integer = true}},
    value={["number"]={minVal=0,maxVal=2,integer=true}},
}

actionValidationInfo["endgame"] = {
    endscreens = {["string"] = {["yes"] = true, ["no"] = true, ["on"] = true, ["off"] = true, ["true"] = true, ["false"] = true}},
}
-- don't check, since it isn't a table
--actionValidationInfo["endgameoverride"] = {}

actionValidationInfo["givetechnology"] = {
    technology = {["number"] = {minVal = 0, maxVal = gen.c.maxTechID, integer = true}},
    receiver = {["string"] = tribeNames},
}

actionValidationInfo["makeaggression"] = {
    who = {["string"] = tribeNames},
    whom = {["string"] = tribeNames},
}

actionValidationInfo["modifyreputation"] = {
    who = {["string"] = tribeNames},
    betray = {["nil"] = true, ["number"] = {minVal = 0, maxVal = 8, integer = true}},
    whom = {["nil"] = true, ["string"] = tribeNames},
    modifier = {["nil"] = true, ["number"] = {minVal = -100, maxVal = 100, integer = true}},
}

actionValidationInfo["moveunit"] = {
    unit = {["string"] = unitTypeNames},
    owner = {["string"] = tribeNames},
    map = {["nil"]=true, ["number"] = {minVal=0,maxVal=maps-1,integer=true}},
    maprect = {["table"] = true},
    moveto = {["table"] = true},
    numbertomove = {["nil"] = true, ["number"] = {minVal = 0, integer = true}, ["string"] = {["all"] = true}},
}
actionValidationInfo["negotiator"] = {
    who = {["number"] = {minVal = 1, maxVal = 21, integer = true}},
    type = {["string"] = {["talker"] = true, ["listener"] = true}},
    state = {["string"] = {["set"] = true, ["clear"] = true}},
}

-- no validation, since result isn't a table
--actionValidationInfo["playavifile"] = {}

-- no validation, since result isn't a table
--actionValidationInfo["playcdtrack"] = {}

-- no validation, since result isn't a table
--actionValidationInfo["playwavefile"] = {}

actionValidationInfo["taketechnology"] = {
    whom = {["string"] = tribeNames},
    collapse = {["nil"] = true, ["boolean"] = true},
    technology = {["number"] = {minVal = 0, maxVal = gen.c.maxTechID, integer = true}},
}

-- text is a special case, since it is a table, but it is a table of strings
actionValidationInfo["text"] = {
    nobroadcast = {["nil"] = true, ["boolean"] = true},
    text = {["nil"] = true, ["table"] = true},
}

actionValidationInfo["transport"] = {
    unit = {["string"] = unitTypeNames},
    state = {["string"] = {["on"] = true, ["off"] = true, ["set"] = true, ["clear"] = true}},
    mode = {["string"] = {["use"] = true, ["build"] = true, ["native"] = true}},
    type = {["number"] = {minVal = 0, maxVal = 15, integer = true}},
}

---Flags some kinds of errors in Legacy Events 
---During the building of the events
---@param actionTable any
---@param actionName any
function legacyValidate.action(actionTable,actionName,lineNumber)
    -- do nothing if there is no action validation information
    if not actionValidationInfo[actionName] then
        return
    end
    if not actionTable then
        error("Legacy Events Line Number "..lineNumber..":\n"
            .."The action \""..actionName.."\" did not produce an action table.\n\n"
            .."If you are confident that you have written the event correctly, please report it, since it may be a bug in the Legacy Events Builder.")
    end
        
    for key,dataSpec in pairs(actionValidationInfo[actionName]) do
        local tableValue = actionTable[key]
        if not gen.valueSatisfiesSpecification(tableValue,dataSpec) then
            local message = "Legacy Events Line Number "..lineNumber..":\n"
            message = message.."The action \""..actionName.."\" has an invalid value for the key \""..key.."\".\n"
            message = message.."The value is \""..tostring(tableValue).."\".\n\n"
            message = message.."If this value looks correct, then you may have found a bug in the Legacy Events validator.\n  Please report it.  Meanwhile, you can change the name of the module in LuaCore to _legacyEventValidator.lua to disable the validator.\n\n"
            message = message.."If you are confident that you have written the event correctly, please report it, since it may be a bug in the Legacy Events Builder."
            error(message)
        end
    end
end

return legacyValidate

--[[
Civilization II Test of Time (TM)
ENHANCED SCENARIO MACRO LANGUAGE
Copyright 1999 Hasbro Interactive
----------------------------------

Starting with the original Civilization II, you could use the Map Editor and other tools to build and play your own scenarios. With Conflicts in Civilization, we gave you a new tool--a primitive, but rather useful, macro language that allowed you (and us) to add predetermined events to a scenario. In Fantastic Worlds, we expanded the scope of this language. Well, we've done it again.

---------
 WARNING
---------

The scenario macro language is still a supplementary design tool, not a part of the game. It has not been tested as well as the game itself and could cause problems if used incorrectly. If you experience difficulties in the game after creating an events file, do not immediately call Customer Service. The best solution is to delete (or at least rename) the events file (events.txt). If you do so and the problems still persist, then call Customer Service.
The scenario macro language has been updated and greatly enhanced for this release. Those of you who have worked with it before will find both interesting new additions and some changes to familiar favorites. If this is your first experience with the macro language, relax--it's not too complicated, but with a little imagination you can do a lot with it. Let's jump right in.

Terminology
------------

Before we start explaining how to use this macro "language" (it's really not a full-scale language, but there's no better word for what it is), we should define a few terms.

* An Event is the combination of a Trigger and an Action. Each event is a simple cause-and-effect sequence. Events are the fundamental structure of this macro language.

* A Trigger is the specific game occurrence that activates a particular event. This is the cause.

* An Action is the consequence an event generates in response to its trigger. This is the effect.

* Both triggers and actions can have Parameters. Each parameter is a piece of information that helps tell the event specifically how to act. (If this isn't entirely clear yet, don't worry; there are plenty of examples ahead.) Some parameters are required, some are optional, and some are mutually exclusive. Regardless, parameters must always be in the correct order.

* A Modifier is a command that changes the way one or more actions work. Most modifiers are very similar to parameters, but because some are not, we needed to call them something different.

Essentially, you define events so that when the trigger happens, it triggers the action. Note that a single trigger can have multiple actions associated with it, but no one trigger can have more than one action of the same type.

The Events File
----------------

The first step in adding events to your scenario is to create a text file in the folder in which you're building the scenario. This file must be named events.txt and must be in the same folder as the scenario (.scn) file. All of the text you put in this file represents events you want in your scenario.

The events file must begin with the line:

@BEGINEVENTS

and end with the line:

@ENDEVENTS

These tell the game program that the file is, indeed, a valid events file.
The rest of the file consists of the definitions of the events themselves. It is extremely important that these definitions are in the correct format. That format is covered a little further on, but before we get there, there is one optional statement we should mention.

Debugging
-----------

One statement is not an event, but rather a tool you can use. If you add the line:

@DEBUG

immediately after the @BEGINEVENTS line, you enable the Event Parsing Debugger (EPD). This can help you find problems in your event files.

When you load the scenario and the events file, the EPD opens a file called report.txt and keeps track of each line of the event file as it is processed. Only valid statements that have been processed successfully appear in this file. Thus, if the parser runs into an invalid statement in your file, the listing in the report file will stop at the line before the problem statement. This should allow you to search out errors and repair them.

Make sure to take this line out of your events file when you're done debugging the scenario.

Event Definitions
------------------

Each event definition must follow a strict format. There are three parts to this format:

1) The Trigger Statement (@IF) defines the trigger for the event.

2) The Action Statement (@THEN) defines the actions associated with that trigger.

3) The End Statement (@ENDIF) tells the parser that there are no more actions for this trigger.

All put together, a valid event definition looks like this:

@IF
Trigger
@THEN
Action 1
Action 2
...
Action N
@ENDIF

where the words Trigger and Action represent valid triggers and actions as defined in the next section.

For example, say you want to remind the player on the 16th turn that they have only four more turns before the end of the scenario. The trigger is the beginning of turn 16, and the action is to display some text in a pop--up box. The definition of this event should look something like this:

@IF
TURN
turn=16
@THEN
TEXT
You have only four more turns to meet your victory conditions!
ENDTEXT
@ENDIF

At the start of the player's 16th turn, a text box pops up with the message "You have only four more turns to meet your victory conditions!" displayed in it.

Valid Format and Wildcard Values
---------------------------------

What constitutes a "valid" trigger or action? Essentially, any group of lines that is in the right place and follows the correct format. The group must begin with a recognized word--one of the trigger words or action words--and must contain the proper number of required parameters and a legitimate value for each one. Note that, to be legitimate, a value does not have to make sense. Thus, for example, the value Goober7 for a city name is legitimate, even if there is no city in the scenario by that name.

There are a few "wildcard" values that are legitimate for certain parameters.

Anybody	If a parameter requires a civilization name as its value, this value sets it so that any single civilization meets the requirements.

AnyUnit	If a parameter requires the name of a type of unit as its value, this value sets it so that any type of unit meets the requirements.

AnyCity	If a parameter requires the name of a city as its value, this value sets it so that any city meets the requirements.

Some triggers require you to specify (as parameters) the civilization that is attacking, defending, or receiving the object of the trigger. In these cases, you can also normally use Anybody in place of the name of a specific civilization. For those particular triggers, there are three other wildcard values you can use with the Receiver and Owner parameters of the associated actions.

TriggerAttacker	This specifies the civilization that was the aggressor ("who") in the happening that triggered the trigger.

TriggerDefender	This denotes whichever civilization was the defender ("whom") in the happening that triggered the trigger.

TriggerReceiver	This represents the civilization that has just received ("whom") the technology named in the ReceivedTechnology trigger.

Note that case (capitalization or lack thereof) is not important. "ANYBODY" is the same as "anybody" or "anYBoDy" as far as the event parser is concerned.

-----------
 NO SPACES
-----------

One important thing to remember is that you must not put spaces where they are not called for. This is especially vital before and after equal signs (=). Under no circumstances should there ever be a space next to an equals sign.

Now, let's go over all the recognized trigger words and action words, their parameters and modifiers, and the legitimate values thereof.

Triggers
---------

Every Trigger is a specific trigger word, which might be followed by one or more required parameters. Some triggers also allow optional parameters. Each parameter must be on a line by itself, in order and immediately after the trigger word. Also, any optional parameter must be followed by at least one required parameter. Here's a simple example:

@IF
CityTaken
city=Rome
attacker=Anybody
defender=Romans

is a valid Trigger.

Each parameter is the parameter word, which might be followed by the equals sign (=), then the value for that parameter. When a value must be entered exactly as written here, it is listed [in brackets]. (Case still doesn't matter.) Optional parameters are also listed [in brackets]. (Note: don't put the brackets in your events.)

Trigger Word		Parameters		Legitimate Values
--------------------------------------------------------------------------------
AlphaCentauriArrival	race=			civilization name
				size=			number 1 to 8 or [AnySize]
--------------------------------------------------------------------------------
BribeUnit			who=			bribing civilization name
				whom=			previous owner civilization name
				unittype=		unit index number
--------------------------------------------------------------------------------
CityDestroyed		city=			city name
				owner=		civilization name
--------------------------------------------------------------------------------
CityProduction		builder=		civilization name
				improvement=	improvement index number
					OR
				unit=			name of a type of unit
--------------------------------------------------------------------------------
CityTaken			city=			name of a city
				[UnitType=]		Spy
				attacker=		new owner civilization name
				defender=		previous owner civilization name
--------------------------------------------------------------------------------
Negotiation			talker=		civilization name
				talkertype=		[Human], [Computer], or [HumanOrComputer]
				listener=		civilization name
				listenertype=	[Human], [Computer], or [HumanOrComputer]
					OR
				talkermask=0b	21 yes/no indicators (0 or 1)
				listenermask=0b	21 yes/no indicators (0 or 1)
--------------------------------------------------------------------------------
NoSchism			defender=		civilization name
--------------------------------------------------------------------------------
RandomTurn			denominator=	number 1 to 1000
--------------------------------------------------------------------------------
ReceivedTechnology	receiver=		civilization name
				[FutureTech=]	number >1
				technology=		technology index number
--------------------------------------------------------------------------------
ScenarioLoaded
--------------------------------------------------------------------------------
Turn				turn=			number 1 to 1000 or [Every]
--------------------------------------------------------------------------------
TurnInterval		interval=		number 1 to 1000
--------------------------------------------------------------------------------
UnitKilled			unit=			name of a unit
				[Map=]		number of a map
				attacker=		civilization name
				[Defender Only]	
				defender=		civilization name
--------------------------------------------------------------------------------

AlphaCentauriArrival:

This trigger is activated when the spaceship or siege engine of the specified civilization (race) reaches its goal. The size parameter lets you specify that the ship or engine must include a specified number of working modules (this is not a minimum, the size must be an exact match to activate the trigger). In the Original and Extended Original games, this is the number of Habitation or Life Support modules, whichever is less. In the Fantasy game, this parameter refers to Mechanics and Weapon modules--in the Lalande 21185 game, Habitat and Lability Cell modules.
BribeUnit: Triggers when a unit of the specified type, belonging to the whom civilization, is bribed away by the who civilization. The unit index number is the position of the type of unit in the units list in the rules.txt file. Remember that the index numbers begin at zero (Settlers), and only go up to 79.

CityDestroyed:

When city, which is owned by the owner civilization, is destroyed (reduced to a population of zero), this trigger is activated. Note that this trigger includes an implied JustOnce modifier.

CityProduction:

If any city owned by the builder civilization completes the production of the specified item (regardless of whether it's built or bought), this trigger activates at the beginning of the next turn. You specify what item using either the improvement parameter or the unit parameter--never include both in the same trigger or event. The improvement index number is the position of the particular improvement in the list in the rules.txt file. Remember that the index numbers begin at zero (Nothing), and only go up to 67 (Cure for Cancer).

CityTaken:

This trigger is activated when a city changes ownership. It's excellent for reacting to key cities being captured. Attacker is the civilization that took the city, defender is the one who owned the city beforehand. The optional UnitType parameter has only one possible value--Spy. This sets the trigger to activate if the city changes hand via a bribed revolt.

Negotiation:

This is triggered when one civilization tries to initiate talks with another. When using this trigger, keep in mind that many things cause negotiations in the game, especially between computer--controlled players. Although it might be tempting to add some flavor to the game with a text pop--up whenever two civilizations try to meet ("Lincoln and Davis meet face to face, but Davis is adamant," for example), this can happen so often as to make the scenario unplayable. There are two ways to use this trigger: with types and with masks. Note that you must never mix parameters from the two methods.

The first method, using the type parameters, not only activates the trigger, but also automatically stops the two civilizations from talking to each other. Talker is the civilization initiating the contact, and listener is the intended receiver. The talkertype and listenertype parameters allow you to specifically include or exclude computer--controlled or human--controlled civilizations from this trigger.

The second method, using the mask parameters, creates lasting settings that determine which civilizations are allowed to initiate negotiations with which others (talkermask) and which are allowed to receive diplomatic overtures (listenermask). The 21 indicators for each control what civilizations are affected. Each of the indicators represents one of the leader entries in rules.txt, listed in reverse programmer notation. For example, talkermask=0b000000000000000000010 used with listenermask=0b000000000000000000101 would prevent leader 2 (Babylonians) from opening talks with leaders 1 and 3 (Romans and Germans)--and prevent them from listening--but it would not prevent the others from contacting leader 2. Even if you have not specified settings with this trigger (i.e., they're still in their default state), you can use the Negotiator action to modify them.

NoSchism:

In the uncommon case when someone captures or destroys the capital city of a large empire (the defender civilization), a schism might occur. In that situation, this trigger does two things. First, it prevents the schism from happening. Second, it activates any actions associated with it.
RandomTurn: Rather than a specific turn, this triggers an event on a turn chosen at random. Denominator is the "one in" number. That is, for example, if the denominator is 40, there is a one in 40 chance every turn that this event will be triggered.

ReceivedTechnology:

This one's activated when a civilization receives--through whatever means--the specified technology and every turn thereafter, as long as the civilization retains the advance. Note that this can cause some irregularities unless you really want the action to happen every turn for the rest of the game. (To prevent that, make sure to include the JustOnce modifier in the event.) Receiver is the civilization that gets the advance. The technology index number is the position of the particular advance in the advances list in the rules.txt file. Remember that the index numbers begin at zero (AFl), and only go up to 99 (X7). Also, note that Future Technology (90) can be received over and over and over without limit. The optional parameter FutureTech allows you to activate this trigger on the receipt of a specific iteration of Future Technology (or its equivalent)--Future Tech 4, for example.

ScenarioLoaded:

When a scenario is first loaded, this trigger is activated. Note that this trigger only works with one action: PlayCDTrack. Any other use will cause unpredictable results.

Turn:

Use this to have something happen at the beginning of a specific turn (or every turn).

TurnInterval:

This is a repeating trigger. The value of the interval parameter is the number of turns that pass between the last activation and the next. An interval of 4, for example, would trigger this event every fourth turn.

UnitKilled:

Use this when you want to respond to a particular unit being killed in battle. This is especially good for leaders, one--of--a--kind units, and special objectives. Attacker is the civilization that killed the unit, defender is the one who owned the unit. Note that this trigger normally activates no matter which unit actually initiated the combat. The optional Map parameter allows you to limit this trigger to times when a certain type of unit is killed in a certain place. Note that you can include more than one Map parameter in the same trigger (up to 3). The other optional parameter, Defender Only (note the space between the words--it's required), prevents this trigger from activating if the specified unit was the aggressor (i.e., it was killed by a unit that was simply defending itself).

Actions
--------

Actions, much like triggers, consist of a specific action word, which might be followed by one or more required parameters and optional parameters. Each parameter must be on a line by itself, in order and immediately after the action word. Also, any optional parameter must be followed by at least one required parameter. Here's a simple example:

@THEN
MakeAggression
who=Romans
whom=Carthaginians

is a valid Action.

Each parameter is the parameter word, which might be followed by the equals sign (=), then the value or values for that parameter. If there is no equals sign, then the value(s) begin on the next line. Many parameters continue over multiple lines, but the parameter word (and the equals sign if there is one) are not repeated. When a value must be entered exactly as written here, it is listed [in brackets]. (Case still doesn't matter.) Optional parameters are also listed [in brackets]. (Note: Don't put the brackets in your events.)

Note that, although a single trigger can cause multiple actions, each trigger can cause only one action of each type. You can, for example, use MoveUnit, ChangeMoney, and CreateUnit all in the same event, but you can't use CreateUnit twice (or more times) in the same event. If you wanted to create more than one unit, you would need to define another event using an identical trigger.

Action Word			Parameters			Legitimate Values
----------------------------------------------------------------------------------------------
BestowImprovement		improvement=		improvement index number
				race=				civilization name
				capital=			[Yes], [No], [On], [Off], [True], or [False]
				wonders=			[Yes], [No], [On], [Off], [True], or [False]
----------------------------------------------------------------------------------------------
ChangeMoney			receiver=			civilization name
				amount=			number
----------------------------------------------------------------------------------------------
ChangeTerrain		[Map=]			number of a map
				terraintype=		terrain index number
				[ExceptionMask=0b00000]	11 yes/no indicators (0 or 1)
				maprect			x1,y1,x2,y2,x3,y3,x4,y4
----------------------------------------------------------------------------------------------
CreateUnit			owner=			civilization name
				unit=				name of a type of unit
				[Count=]			number from 1 to 255
				veteran=			[Yes], [No], [False], or [True]
				homecity=			city name or [None]
				[InCapital]			
				locations
								x1,y1,z1
								...
								x10,y10,z10
				endlocations
----------------------------------------------------------------------------------------------
DestroyACivilization	whom=				civilization name
----------------------------------------------------------------------------------------------
EnableTechnology		whom=				civilization name
				technology=			technology index number
				value=			0, 1, or 2
----------------------------------------------------------------------------------------------
EndGame			endscreens=			[Yes], [No], [On], [Off], [True], or [False]
----------------------------------------------------------------------------------------------
EndGameOverride
----------------------------------------------------------------------------------------------
GiveTechnology		technology=			technology index number
				receiver=			civilization name
----------------------------------------------------------------------------------------------
MakeAggression		who=				aggressor civilization name
				whom=				victim civilization name
----------------------------------------------------------------------------------------------
ModifyReputation		who=				target civilization name
				betray=			number 0 to 8
					OR
				whom=				opining civilization name
					AND
				modifier=			number -100 to 100
----------------------------------------------------------------------------------------------
MoveUnit			unit=				name of a type of unit
				owner=			civilization name
				[Map=]			number of a map
				maprect			x1,y1,x2,y2,x3,y3,x4,y4
				moveto			x,y
				numbertomove=		number or [All]
----------------------------------------------------------------------------------------------
Negotiator			who=				number of leader (1-21)
				type=				[Talker] or [Listener]
				state=			[Set] or [Clear]
----------------------------------------------------------------------------------------------
PlayAVIFile							file name (*.avi)
----------------------------------------------------------------------------------------------
PlayCDTrack							number from 2 to 14
----------------------------------------------------------------------------------------------
PlayWaveFile						file name (*.wav)
----------------------------------------------------------------------------------------------
TakeTechnology		whom=				civilization name
				[Collapse]
				technology=			technology index number
----------------------------------------------------------------------------------------------
Text				[No Broadcast]
								text to be displayed
				EndText
----------------------------------------------------------------------------------------------
Transport			unit=				name of a type of unit
				state=			[On], [Off], [Set], or [Clear]
				mode=				[Use], [Build], or [Native]
				type=				number 0 to 15
----------------------------------------------------------------------------------------------

BestowImprovement:

Gives the specified city improvement or wonder to a city owned by the named civilization, without cost. The improvement index number is the position of the particular improvement in the list in the rules.txt file. Remember that the index numbers begin at zero (Nothing), and only go up to 67 (Cure for Cancer). Race is the civilization that is to get the improvement. What city the gift is placed in is determined for you. Each city is given a rating based on its size, whether it's the capital, and how many wonders are in the city. If you set the capital parameter False (or No or Off), this calculation ignores the capital factor. The wonders parameter controls the wonder factor in the same way. The top rated city gets the improvement unless you include the optional Randomize parameter, in which case the city is chosen at random from the top ten.

ChangeMoney:

This adds money to or subtracts it from a civilization's treasury. (Use a negative number for the amount to subtract.) If after the adjustment the treasury is less than zero, the treasury becomes zero, instead. Receiver is the affected civilization.

ChangeTerrain:

This changes all of the terrain in a specified rectangular region of the map (delineated by the coordinates you give) to the specified type. You specify the type using the terrain index number, which is the position of the desired terrain type in the terrain list in the rules.txt file. Remember that the index numbers begin at zero (for Desert), and only go up to 10 (Ocean).

The optional Map parameter allows you to specify on which of the possible maps (the number available depends on how many are in the particular scenario) the change should be made. Each action of this type affects only one map; the default is map 0.

The other optional parameter, ExceptionMask, allows you to specify that certain terrain types should not be affected by the change. Each of the eleven yes/no indicators represents one of the basic terrain types. This is in reverse programmer notation, which means that the last digit represents the first terrain type (Desert), and the first one represents the last type (Ocean). Any indicator that is set to 1 prevents every tile of the corresponding type from being changed; if an indicator is 0, that type changes as usual. No indicator should ever be set to anything but 1 or 0.

The coordinates define the corners of the rectangular region. They must (1) be on the line immediately following the word maprect, (2) be separated by commas, and (3) be listed in the following specific order to be valid. (They also must be valid map coordinates.) The first coordinate must be the upper left corner; next comes the upper right, then lower right, and finally lower left. Thus:

	1--2
	4--3

CreateUnit:

Creates from 1 to 255 new units (at no expense) with specified characteristics and places them at the first of the specified locations. If that placement is invalid for any reason, the program tries the subsequent locations (there can be up to 10), in order, until one works or it reaches the EndLocations parameter. The x and y in these locations represent horizontal and vertical coordinates on the scenario map. The z is an optional coordinate specifying on which map the units should be created; if no z is entered, this defaults to map 0. The optional parameter InCapital forces the unit to be created in the capital city of the specified civilization. Even though this causes the locations to be ignored, you still must include the required Locations and EndLocations parameters and at least one location. Finally, you can use the optional Randomize modifier to have the location chosen at random from the list.

DestroyACivilization:

This one is exactly what it sounds like. Cities, units, and everything else is completely wiped out. Whom is the civilization slated to meet its doom (as in, "for whom the bell tolls").

EnableTechnology:

Changes the permission state of the specified advance module for the specified civilization (whom). The technology index number is the position of the particular advance in the advances list in the rules.txt file. Remember that the index numbers begin at zero (AFl), and only go up to 99 (X7). The value is the new state--0=can research and own; 1=can't research, but can own; 2=can neither research nor own (i.e. can't acquire in any way). In rules.txt, advances are separated into modules; keep in mind that changing the permission state for any advance in a module changes the state for the entire module. Also note that for the game to function, every civilization must always have a possible research route to Future Technology (90). Therefore, the module that includes advance 90 and all of its ancestor prerequisites must always have a value of 0 for all civilizations. This action must not appear in the same event with a GiveTechnology or TakeTechnology action.

EndGame:

This does exactly what it sounds like; it ends the game. This is essentially equivalent to the player retiring. The endscreens parameter determines whether the information displays that usually show up at the close of a game (the POWERGraph, score, and so on) are shown.

EndGameOverride:

This prevents the game from ending normally when the spaceship or its equivalent reaches its destination. Note that this does not preclude someone winning by conquest.
GiveTechnology: Bestows the specified advance on the named civilization. The technology index number is the position of the particular advance in the advances list in the rules.txt file. Remember that the index numbers begin at zero (AFl), and only go up to 99 (X7). Also, note that Future Technology (90) can be received over and over and over without limit. Receiver is the civilization on which the bestowing is to descend. This action must not appear in the same event with an EnableTechnology or TakeTechnology action.

MakeAggression:

This action causes two civilizations to cancel their peace treaty, if one exists. Then who immediately declares war on whom.

ModifyReputation:

Changes the way other empires feel toward a specified civilization. Who is the civilization whose reputation is to be changed. Of the other parameters, you must have either Betray or the combination of Whom and Modifier. Betray sets the number of times that all other empires believe this civilization has betrayed allies. The higher this number is, the lower their opinion of the civilization will be. Use Whom if you only want to change the opinion of a specific other empire toward the Who civilization. Modifier is the amount by which you want to increase or decrease whom's disgust with who.

MoveUnit:

This scans a specified rectangular region of the map (maprect), then orders a specified number of the owner's units of the given type in that region to move to a certain location. The program only activates units that are (1) not fortified, (2) not on sentry duty, (3) not already headed for a destination, (4) not building fortifications, and (5) not nuclear weapons. MoveUnit does not affect units owned by human players. MOVEUNIT must not be used in the same event as the DelayPerFlag modifier.

The optional Map parameter allows you to specify which of the possible maps (the number available depends on how many are included in the particular scenario) the maprect and moveto locations refer to. Each action of this type affects only one map; the default is map 0.

The maprect coordinates define the corners of the rectangular region. They must (1) be on the line immediately following the word maprect, (2) be separated by commas, and (3) be listed in the following specific order to be valid. (They also must be valid map coordinates.) The first coordinate must be the upper left corner; next comes the upper right, then lower right, and finally lower left. Thus:

	1--2
	4--3

Negotiator:

Modifies the negotiation regulations for a specified civilization, either allowing or prohibiting talks between that empire and others. Who is the civilization affected, which you specify according to its position in the list of leaders in rules.txt (or, more likely, using a wildcard). Note that, unlike all the others, this list begins with 1, not 0. The type parameter determines which type of negotiation you want to change--talker controls those initiated by the who civilization, and listener those talks started by someone else. State is the prohibition setting; Set prevents the specified type of negotiations, and Clear allows them. Note that this action affects all of the settings of the specified type and all of the civilization's Negotiation statements; there is no way to change individual indicators. (Please read the description of the Negotiation trigger to get the rest of this story.)

PlayAVIFile:

Play the specified .avi file. The program searches the current scenario folder for the file, then (if it doesn't find it there) reverts to the game's default video folder.

PlayCDTrack:

Tells your computer's CD player to play the specified audio track. On the game CD--ROM, Track 1 is reserved for program information, so the first audio track is actually Track 2. Thus, the value must be 2 or greater. There are 13 music tracks on the Civilization II the Test of Time CD, so numbers above 14 will result in no music playing.

PlayWaveFile:

Play the specified .wav file. The program searches the sound subfolder of the current scenario folder for the file.

TakeTechnology:

Takes the specified advance away from the named civilization (if they have it). The technology index number is the position of the particular advance in the advances list in the rules.txt file. Remember that the index numbers begin at zero (AFl), and only go up to 99 (X7). Also, note that Future Technology (90) cannot be taken away. Whom is the civilization destined to take a step backward. As if losing a tech isn't bad enough, the optional parameter Collapse makes it devastating; this also takes away any advance that has the specified advance as a prerequisite--and all advances that have those as prerequisites, on up the tree. This action must not appear in the same event with an EnableTechnology or GiveTechnology action.

Text:

This simply presents a pop--up text box to the player. The box includes whatever text you put between the Text and EndText lines. You can enter up to 10 lines of 255 characters per line, but keep in mind both the memory limits and the amount of text that will fit on the screen at one time. Short messages are generally best. The optional No Broadcast parameter (note the space between the words--it's required) specifies that this message should be shown only to the triggering civilization ("who").

Transport:

The intermap transport abilities of each unit type are set in rules.txt. This action allows you to change those abilities for a specified type of unit (unit). The state parameter controls the new setting for the specified ability; On or Set enables the ability, while Off or Clear disables it. Mode determines which of the three types of transport ability you want to change--permission to Use a certain type of transport site, the ability to Build that type of site, or the Native ability to transport without a site. The type parameter sets which of the sixteen transport relationships (defined in rules.txt) you want to change. TRANSPORT must not be used in the same event as the DelayPerFlag modifier.

Note that unit types, civilization names, and so on must match the corresponding names in the rules.txt file exactly. Mismatches cause errors.

Modifiers
----------

Modifiers are special, optional parts of an event. They're not triggers or actions, but rather are used as a part of a trigger or action. Most of them act like optional parameters, except that they can be applied to more than one trigger or action--and they have unusual effects.

Note that a modifier must never be the last parameter of a trigger or action. At least one required parameter must follow the modifier in every case.

Modifier Word		Parameters		Legitimate Values
--------------------------------------------------------------------------------
@AND
--------------------------------------------------------------------------------
Continuous
--------------------------------------------------------------------------------
Delay				delay=		number 1 to 1000
--------------------------------------------------------------------------------
JustOnce
--------------------------------------------------------------------------------
Randomize
--------------------------------------------------------------------------------

@AND:

The @AND command is a logical modifier that allows you to set up an event so that the action(s) occur only if two triggers activate. You can have one and only one @AND in any single @IF statement (and none in the @THEN portion of the event), and this modifier works only with these triggers: BRIBEUNIT, CHECKFLAG, CITYDESTROYED, CITYPRODUCTION, CITYTAKEN, RANDOMTURN, RECEIVEDTECHNOLOGY, TURN, TURNINTERVAL, and UNITKILLED. Both triggers must be complete and valid. The @AND modifier goes on a line by itself between the last parameter of the first trigger and the trigger word of the second.

Continuous:

When a trigger is activated, it remains that way only until the current game turn ends. If you need a trigger to remain "true" for the rest of the game (to satisfy one half of an @AND modified trigger, for example, when the other half will be satisfied later), you must include the Continuous modifier in the definition of that trigger. This modifier is only valid for use with the CITYDESTROYED, CITYTAKEN, RANDOMTURN, TURN, and UNITKILLED triggers and the FLAG action.

Delay:

Delay affects all of the actions in a single event. It causes them to not take place until a specified number of turns after the trigger is activated. You set this number of turns using the required parameter delay= followed by a number. This modifier is valid with all actions and triggers. Note that you can use the Randomize modifier to make the delay a random number of turns chosen from between zero and the delay you specified. Delay must not be used in the same event as the DelayPerFlag modifier.

JustOnce:

This modifier affects the entire event; it tells the program to execute this event once and only once. If, for example, you wanted to do something special the first time a city is taken, but not afterward, you would use the CITYTAKEN trigger and include JustOnce as one of the consequent actions. The JustOnce statement should be included immediately after the @THEN statement. This modifier is valid with all actions and triggers.

Randomize:

When you want something chosen at random from the possible alternatives, include Randomize in the definition of the action. This modifier is only valid for use as a modifier of the Delay modifier and with three actions: BESTOWIMPROVEMENT, CREATEUNIT, and DELAYPERFLAG. (The effects are different for each, and they're described in the relevant action descriptions.)

Flags
------

With this version of the language, we've added the ability to use binary 'flags' to keep track of multiple situations throughout the game. Flags have many possible uses--far too many to enumerate here. The flag system includes a command, a trigger, an action, and a modifier, but for simplicity of explanation and because they all work together, we've collected them in this section, rather than spreading them out.

Flag Word		Parameters		Legitimate Values
--------------------------------------------------------------------------------
@INITFLAG
--------------------------------------------------------------------------------
Flag			[who=]		civilization name
			state=		[On], [Off], [Set], or [Clear]
			flag=			flag number (0 to 31)
				OR
			mask=0b		32 state indicators (0 or 1)
--------------------------------------------------------------------------------
CheckFlag		who=			civilization name, [Everybody], or [Somebody]
			[Technology=]	technology index number
			flag=			flag number (0 to 31)
				OR
			mask=0b		32 state indicators (0 or 1)
			[Threshold=]	number
				OR
			[Count=]		number
			State=		[On], [Off], [Set], or [Clear]
--------------------------------------------------------------------------------
DelayPerFlag	basedelay=		number 0 to 1000
			perflagdelay=	number 1 to 1000
			mask=0b		32 state indicators (0 or 1)
--------------------------------------------------------------------------------

@INITFLAG:

You cannot use flags unless they have been initialized--set to a beginning state of zero (the same as Off and Clear)--and this command is how you initialize them all. The @INITFLAG line belongs at the beginning of the events.txt file, immediately after the @DEBUG command.

Flag:

This is the flag action; you use it to change the state of one or more of the 32 flags (0 through 31) for each civilization. The optional parameter Who determines which civilization's flags you're setting; if you don't specify one, then you're changing the flags for every civilization. State determines whether you're marking flags as On (Set) or Off (Clear). The flag and mask parameters are mutually exclusive; you can only use one or the other in any single event. With flag, you specify the one flag, by number, that you want to affect. Mask, on the other hand, allows you to change several flags at once; each of the 32 indicators controls one flag (in reverse programmer notation, meaning that the first digit is flag 31 and the last one is flag 0), and every one you mark with a 1 will be set to the specified state. Keep in mind that unless you include the Continuous modifier, the flags remain set (and thus can activate a CHECKFLAG trigger) only until the end of the current turn.

CheckFlag:

This is the flag trigger; if the state of the flags you specify to be checked matches the state you indicate, the trigger is activated.

You determine what civilizations' flags are checked using the who parameter. Enter a name to limit the check to only that civilization's flags. The Somebody value requires that any one civilization's flags match, but it doesn't matter whose. Everybody stipulates that all civilizations contribute--the flags are combined, and for each flag checked, if anyone's flag matches, that flag is considered a match.

The optional Technology parameter has no effect unless you specify a single civilization in who. This causes the entire trigger to be ignored unless the specified civilization has that technology. The technology index number is the position of the particular advance in the advances list in the rules.txt file. Remember that the index numbers begin at zero (AFl), and only go up to 99 (X7).

The flag and mask parameters are mutually exclusive; you can have only one of the two in any single event. Flag specifies a single flag (0 through 31) you want to check. (If you use flag, Everybody and Somebody become equivalent to Anybody.) Each of the indicators in the mask represents one flag, in reverse programmer notation (31 is first and 0 is last). Those flags you mark with a 1 will be checked. The mask parameter, in turn, supports two mutually exclusive optional parameters, Threshold and Count. Using Count, you limit the trigger to activating only if the total number of matches is exactly the number you specify. Threshold, on the other hand, is a minimum; if the match total is equal to or more than the specified number, the trigger is activated.

The state parameter denotes what state you're checking for, On (Set) or Off (Clear). Whatever checked flags have the state you specify are considered matches.

DelayPerFlag:

This is the flag modifier, which allows you to delay the actions in an event a number of turns based on the state of selected flags. It's similar to the Delay modifier, and like Delay, it belongs in the action portion of the event. Basedelay is a constant; the actions will always be delayed by at least this number of turns. The perflagdelay is an additional delay based on how many of the flags specified in the mask are On (Set). Each of the indicators in the mask represents one flag, in reverse programmer notation (31 is first and 0 is last). Those flags you mark with a 1 will be checked. (Note that you cannot specify a civilization; everyone's flags are checked.) To figure the total delay, multiply the number of flags marked in the mask that are On by the perflagdelay, then add the basedelay. Note that perflagdelay is calculated only once, when the trigger is activated; if the states of the flags change after that, the delay is not affected. You can use the Randomize modifier to make the perflagdelay a random number of turns chosen from between zero and the actual calculated number. The DelayPerFlag modifier must not be used in the same event as Delay, TRANSPORT, or MOVEUNIT.

Memory Limits
--------------

There's a limit to how many events you can put into a scenario. If you run over that limit, your scenario simply won't run. The limit is not a number of events, but rather an amount of memory.

There is approximately 100 Kb of "heap" memory dedicated to events. This is all you get. Every event structure takes up some of this space--especially text messages, which take up lots of space. In addition, delayed actions (those using the DELAY modifier) create countdown timers that also take up memory space. If your delays pile up and you run out of memory because of it, the scenario won't crash, but any delayed actions that don't fit in memory will not ever take place.

It takes some doing to run out of memory, but if you do, there are a few simple tactics that might help:

* Shorten your text messages. Text takes up more memory than anything else, so getting rid of it helps quite a bit.

* Combine events. If you think about it, you can probably turn several events into one with minor changes.

* Eliminate unnecessary or tedious events. You'll know which ones they are.

Order of Execution
-------------------

This particular issue will rarely, if ever, be of concern in any but the most exactingly precise and complex scenarios. However, for those of you who need to know, here is the order in which the possible actions take place in any single event.

1) PlayWaveFile
2) PlayAVIFile
3) PlayCDTrack
4) CreateUnit
5) MoveUnit
6) Transportable
7) ChangeTerrain
8) MakeAggression
9) ChangeMoney
10) DestroyACivilization
11) GiveTechnology
12) TakeTechnology
13) EnableTechnology
14) Text
15) ModifyReputation
16) BestowImprovement
17) EndGameOverride
18) EndGame
19) Flag
20) Negotiator

A Simple Example
-----------------

Here is a hypothetical sample event definition from an American Revolution scenario. If England takes New York from the Americans, this event displays the text "New York captured by the Redcoats! Enraged local citizens join the fight for liberty!" Then, it creates a new American militia unit and tries to place it at map location 84,22. If that is not a legal placement (enemy units already there or whatever), it then tries 84,23 and--if that location is invalid, too--79,31.
@BEGINEVENTS
@IF
CityTaken
city=New York
attacker=English
defender=Americans
@THEN
Text
New York captured by the Redcoats! Enraged local citizens join the fight for liberty!
EndText
CreateUnit
unit=Militia
owner=Americans
veteran=false
homecity=none
locations
84,22
84,23
79,31
endlocations
@ENDIF
@ENDEVENTS
]]