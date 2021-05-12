This is a template for making a Civilization II: Test of Time scenario using Lua Events.

To get started, Follow the following instructions:
1.  Make a backup copy of your scenario folder, just in case.
2.  If you have an events.txt file for the old style "macro" or "legacy" events in your scenario folder, rename it to legacyEvents.txt.
3.  Download the LuaTemplate code.
4.  Copy the contents of this template into your scenario folder.  Do not include the LuaTemplate-main folder.  That is, you should be copying 6 folders and a couple other files into your scenario folder.
5.  If you have legacy events, move legacyEvents.txt from the main scenario folder into the LuaTriggerEvents folder, replacing the existing file.

If your legacyEvents.txt file contains no errors, you can now load up your scenario to keep working on it.  If it does, the Lua Console will appear, and tell you the last line of the last event that was parsed successfully.  Check the next event for errors.

When you load a game, you'll probably get a message about how the Legacy Event Engine has been updated. Choose to clear the saved data and save the game. You won't get the message again (unless you change your legacyEvents.txt file, or update the Legacy Event Engine).
