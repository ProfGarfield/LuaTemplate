-- The unitData module provides functionality to associate data with individual units.
-- The operation is similar to that of the flag and counter modules.
--

--  Flags
--  unitData Flags are values that can be true or false
--  There are a couple variants that can be defined, but they all
--  use the flag functions

--  endOfTurnResetFlag
--      an endOfTurnResetFlag is set to nil at the end of its owner's turn
--      (during onTribeTurnEnd execution, after all other events)
--
--  startOfTurnResetFlag
--      a startOfTurnResetFlag is set to nil at the start of its owner's turn
--      (during the onTribeTurnBegin execution, before all other events)
--
--  newTurnResetFlag
--      a newTurnResetFlag is set to nil at the start of the game round
--      (during the onTurn event, before all other events)
--
--  Flag
--      a standard Flag keeps its value until told not to
--
--  flag.define(flagName,defaultValue,



-- unitDatum = {
--  [string] = bool, number, or state-savable
--      Duplicate flag names can't exist for the
--      different kinds of unitDatum entries
--  [1] = unitTypeID
--  [2] = ownerID
--      These keys serve as a check that the unit ID
--      is still associated with the same unit
