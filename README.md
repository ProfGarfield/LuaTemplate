# Lua Scenario Template

This is a template for making a Civilization II: Test of Time scenario using Lua Events.

## Getting Started

To get started, Follow the following instructions:
1.  Make a backup copy of your scenario folder, just in case.
2.  If you have an events.txt file for the old style "macro" or "legacy" events in your scenario folder, rename it to legacyEvents.txt.
3.  Download the LuaTemplate code.
4.  Copy the contents of this template into your scenario folder.  Do not include the LuaTemplate-main folder.  That is, you should be copying 6 folders and a couple other files into your scenario folder.
5.  If you have legacy events, move legacyEvents.txt from the main scenario folder into the EventsFiles folder, replacing the existing file.

If your legacyEvents.txt file contains no errors, you can now load up your scenario to keep working on it.  If it does, the Lua Console will appear, and tell you the last line of the last event that was parsed successfully.  Check the next event for errors.

When you load a game, you'll probably get a message about how the Legacy Event Engine has been updated. Choose to clear the saved data and save the game. You won't get the message again (unless you change your legacyEvents.txt file, or update the Legacy Event Engine).

## How Lua Events Work

At different points during the game, the Civ II Lua interpreter will check if there is any code to run, and run the code if it is provided.  We'll call these points code "execution points."

The "goal" of an events.lua file is the register the code for these execution points.  For most execution points, there is a command [`civ.scen.onTrigger`](https://forums.civfanatics.com/threads/totpp-lua-function-reference.557527/#civ.scen) to register a "function" (set of instructions).  Some execution points rely on another civ.scen registration, but only execute the code sometimes.  One purpose of this template is to hide that machinery from the scenario designer.

In addition to running code that can make events happen (such as creating units or showing text), some execution points change the game mechanics by returning different values.

## Organization

### events.lua

The events.lua file is run by Test of Time when a game is loaded.  Other Lua files are only run if they have been told to run by events.lua (using the 'require' function), or if they are in turn asked to run by a file that events.lua has exectued.  Execution points are registered here, and the functions they registered are defined in the other files of this template.

### consolidatedEvents.lua

This file groups functions to register most execution points in a single files.  For scenarios with relatively few events, this may be more convenient than having a different file for each kind of event.

### discreteEvents.lua

A 'discrete event' can be 'registered' using the discreteEventsRegistrar.lua module.  All the 'discrete' events registered by the module are added to the function that will be registered by `civ.scen.onTrigger`.  In contrast to the consolidatedEvents format, this allows game events using the same execution point to be registered in different places, much more like the legacy style of events.  You don't have to register discrete events in discreteEvents.lua.  Rather, this is simply a file that events.lua will run, and which has some example code available.

### events.txt

This file is empty, but a file with this name must exist for the Lua events to work properly.

### LuaCore Directory

This directory contains a wide variety of modules to make programming with Lua easier.  These files are not intended to be edited by a scenario designer.  (If you do find you need to edit any of these files, let me know.)

### EventsFiles Directory

If you have a large and complicated events system, you are likely to find that it makes sense to split your events into multiple files.  The files in this directory are already linked to events.lua, so this is a convenient place to split up your events.  These files can be deleted if they are not needed.

### MechanicsFiles Directory

The files in this directory change game mechanics.  The distinction between "events" and "mechancis" is somewhat arbitrary, but this folder contains several "settings" files.

### LuaParameterFiles Directory

This directory contains a few files that provide some basic information to other files.  For example, there is the object.lua file, which provides "Lua Names" for a wide variety of data types in your scenario.  There is also parameters.lua, which can be used to change a couple settings and also be a centralized place to keep track of different parameter values for your scenario (which can then be reference by requiring parameters.lua)

### Scripts Directory

This directory contains some scripts to make the scenario building process easier.  Some of these are run using the Lua Console in Test of Time, while others are run from your web browser.  This directory can be deleted before publishing your scenario.

### LuaDocumentation Directory

This directory contains a few files documenting parts of the Lua Scenario Template.  The information hasn't been maintained or updated, and wasn't complete to begin with.  Ask in the Civfanatics Civ II forum if you need help using the Template.  (This directory can be deleted before publishing your scenario.).

## Adding New Files

If you find it convenient to add additional lua files to your scenario, the require function will look for them in the main scenario directory, the LuaCore Directory, the LuaParameterFiles directory, the EventsFiles directory, and the MechanicsFiles directory.  If you wish to place a file in any other directory, you must include the directory path starting from one of the directories listed above.








