local flag = require("flag")

-- In the LuaCore folder, there is a script that will generate
-- an object file, called makeObject.lua
-- Use Load Script from the console to run makeObject.lua
-- to create the object.lua file.  The file will be created
-- in your main Test of Time directory, with form 12345678object.lua.
-- The number is derived from the current time, so that existing
-- files won't be overwritten by accident.

local object = {}

-- Civilization Advances
-- recommended key prefix 'a'
--
object.aTechnology0             = civ.getTech(0)
object.aTechnology1             = civ.getTech(1)
object.aTechnology2             = civ.getTech(2)
object.aTechnology3             = civ.getTech(3)
object.aTechnology4             = civ.getTech(4)
object.aTechnology5             = civ.getTech(5)
object.aTechnology6             = civ.getTech(6)
object.aTechnology7             = civ.getTech(7)
object.aTechnology8             = civ.getTech(8)
object.aTechnology9             = civ.getTech(9)
object.aTechnology10             = civ.getTech(10)
object.aTechnology11             = civ.getTech(11)
object.aTechnology12             = civ.getTech(12)
object.aTechnology13             = civ.getTech(13)
object.aTechnology14             = civ.getTech(14)
object.aTechnology15             = civ.getTech(15)
object.aTechnology16             = civ.getTech(16)
object.aTechnology17             = civ.getTech(17)
object.aTechnology18             = civ.getTech(18)
object.aTechnology19             = civ.getTech(19)
object.aTechnology20             = civ.getTech(20)
object.aTechnology21             = civ.getTech(21)
object.aTechnology22             = civ.getTech(22)
object.aTechnology23             = civ.getTech(23)
object.aTechnology24             = civ.getTech(24)
object.aTechnology25             = civ.getTech(25)
object.aTechnology26             = civ.getTech(26)
object.aTechnology27             = civ.getTech(27)
object.aTechnology28             = civ.getTech(28)
object.aTechnology29             = civ.getTech(29)
object.aTechnology30             = civ.getTech(30)
object.aTechnology31             = civ.getTech(31)
object.aTechnology32             = civ.getTech(32)
object.aTechnology33             = civ.getTech(33)
object.aTechnology34             = civ.getTech(34)
object.aTechnology35             = civ.getTech(35)
object.aTechnology36             = civ.getTech(36)
object.aTechnology37             = civ.getTech(37)
object.aTechnology38             = civ.getTech(38)
object.aTechnology39             = civ.getTech(39)
object.aTechnology40             = civ.getTech(40)
object.aTechnology41             = civ.getTech(41)
object.aTechnology42             = civ.getTech(42)
object.aTechnology43             = civ.getTech(43)
object.aTechnology44             = civ.getTech(44)
object.aTechnology45             = civ.getTech(45)
object.aTechnology46             = civ.getTech(46)
object.aTechnology47             = civ.getTech(47)
object.aTechnology48             = civ.getTech(48)
object.aTechnology49             = civ.getTech(49)
object.aTechnology50             = civ.getTech(50)
object.aTechnology51             = civ.getTech(51)
object.aTechnology52             = civ.getTech(52)
object.aTechnology53             = civ.getTech(53)
object.aTechnology54             = civ.getTech(54)
object.aTechnology55             = civ.getTech(55)
object.aTechnology56             = civ.getTech(56)
object.aTechnology57             = civ.getTech(57)
object.aTechnology58             = civ.getTech(58)
object.aTechnology59             = civ.getTech(59)
object.aTechnology60             = civ.getTech(60)
object.aTechnology61             = civ.getTech(61)
object.aTechnology62             = civ.getTech(62)
object.aTechnology63             = civ.getTech(63)
object.aTechnology64             = civ.getTech(64)
object.aTechnology65             = civ.getTech(65)
object.aTechnology66             = civ.getTech(66)
object.aTechnology67             = civ.getTech(67)
object.aTechnology68             = civ.getTech(68)
object.aTechnology69             = civ.getTech(69)
object.aTechnology70             = civ.getTech(70)
object.aTechnology71             = civ.getTech(71)
object.aTechnology72             = civ.getTech(72)
object.aTechnology73             = civ.getTech(73)
object.aTechnology74             = civ.getTech(74)
object.aTechnology75             = civ.getTech(75)
object.aTechnology76             = civ.getTech(76)
object.aTechnology77             = civ.getTech(77)
object.aTechnology78             = civ.getTech(78)
object.aTechnology79             = civ.getTech(79)
object.aTechnology80             = civ.getTech(80)
object.aTechnology81             = civ.getTech(81)
object.aTechnology82             = civ.getTech(82)
object.aTechnology83             = civ.getTech(83)
object.aTechnology84             = civ.getTech(84)
object.aTechnology85             = civ.getTech(85)
object.aTechnology86             = civ.getTech(86)
object.aTechnology87             = civ.getTech(87)
object.aTechnology88             = civ.getTech(88)
object.aTechnology89             = civ.getTech(89)
object.aTechnology90             = civ.getTech(90)
object.aTechnology91             = civ.getTech(91)
object.aTechnology92             = civ.getTech(92)
object.aTechnology93             = civ.getTech(93)
object.aTechnology94             = civ.getTech(94)
object.aTechnology95             = civ.getTech(95)
object.aTechnology96             = civ.getTech(96)
object.aTechnology97             = civ.getTech(97)
object.aTechnology98             = civ.getTech(98)
object.aTechnology99             = civ.getTech(99)

-- Map Locations (tiles/squares)
-- recommended key prefix 'l'



-- Cities
-- recommended key prefix 'c'
-- It is not recommended to put cities into this list if the city
-- can be destroyed. This list returns an error if 'nil' is the value
-- associated with the key (see bottom of file), so that could cause
-- a problem if a city in this list is destroyed.  Also, if another
-- city is founded, the ID number of the city might get reused, causing
-- more confusion.  An alternate way to reference a city is by using
-- object.lRome.city when you actually need the city (and suitably guarding
-- against nil values)

--Find these by entering "for city in civ.iterateCities() do print(city.id, city.name) end" in the console




-- Unit Types
-- recommended key prefix 'u'
object.uUnitType0                   = civ.getUnitType(0)
object.uUnitType1                   = civ.getUnitType(1)
object.uUnitType2                   = civ.getUnitType(2)
object.uUnitType3                   = civ.getUnitType(3)
object.uUnitType4                   = civ.getUnitType(4)
object.uUnitType5                   = civ.getUnitType(5)
object.uUnitType6                   = civ.getUnitType(6)
object.uUnitType7                   = civ.getUnitType(7)
object.uUnitType8                   = civ.getUnitType(8)
object.uUnitType9                   = civ.getUnitType(9)
object.uUnitType10                   = civ.getUnitType(10)
object.uUnitType11                   = civ.getUnitType(11)
object.uUnitType12                   = civ.getUnitType(12)
object.uUnitType13                   = civ.getUnitType(13)
object.uUnitType14                   = civ.getUnitType(14)
object.uUnitType15                   = civ.getUnitType(15)
object.uUnitType16                   = civ.getUnitType(16)
object.uUnitType17                   = civ.getUnitType(17)
object.uUnitType18                   = civ.getUnitType(18)
object.uUnitType19                   = civ.getUnitType(19)
object.uUnitType20                   = civ.getUnitType(20)
object.uUnitType21                   = civ.getUnitType(21)
object.uUnitType22                   = civ.getUnitType(22)
object.uUnitType23                   = civ.getUnitType(23)
object.uUnitType24                   = civ.getUnitType(24)
object.uUnitType25                   = civ.getUnitType(25)
object.uUnitType26                   = civ.getUnitType(26)
object.uUnitType27                   = civ.getUnitType(27)
object.uUnitType28                   = civ.getUnitType(28)
object.uUnitType29                   = civ.getUnitType(29)
object.uUnitType30                   = civ.getUnitType(30)
object.uUnitType31                   = civ.getUnitType(31)
object.uUnitType32                   = civ.getUnitType(32)
object.uUnitType33                   = civ.getUnitType(33)
object.uUnitType34                   = civ.getUnitType(34)
object.uUnitType35                   = civ.getUnitType(35)
object.uUnitType36                   = civ.getUnitType(36)
object.uUnitType37                   = civ.getUnitType(37)
object.uUnitType38                   = civ.getUnitType(38)
object.uUnitType39                   = civ.getUnitType(39)
object.uUnitType40                   = civ.getUnitType(40)
object.uUnitType41                   = civ.getUnitType(41)
object.uUnitType42                   = civ.getUnitType(42)
object.uUnitType43                   = civ.getUnitType(43)
object.uUnitType44                   = civ.getUnitType(44)
object.uUnitType45                   = civ.getUnitType(45)
object.uUnitType46                   = civ.getUnitType(46)
object.uUnitType47                   = civ.getUnitType(47)
object.uUnitType48                   = civ.getUnitType(48)
object.uUnitType49                   = civ.getUnitType(49)
object.uUnitType50                   = civ.getUnitType(50)
object.uUnitType51                   = civ.getUnitType(51)
object.uUnitType52                   = civ.getUnitType(52)
object.uUnitType53                   = civ.getUnitType(53)
object.uUnitType54                   = civ.getUnitType(54)
object.uUnitType55                   = civ.getUnitType(55)
object.uUnitType56                   = civ.getUnitType(56)
object.uUnitType57                   = civ.getUnitType(57)
object.uUnitType58                   = civ.getUnitType(58)
object.uUnitType59                   = civ.getUnitType(59)
object.uUnitType60                   = civ.getUnitType(60)
object.uUnitType61                   = civ.getUnitType(61)
object.uUnitType62                   = civ.getUnitType(62)
object.uUnitType63                   = civ.getUnitType(63)
object.uUnitType64                   = civ.getUnitType(64)
object.uUnitType65                   = civ.getUnitType(65)
object.uUnitType66                   = civ.getUnitType(66)
object.uUnitType67                   = civ.getUnitType(67)
object.uUnitType68                   = civ.getUnitType(68)
object.uUnitType69                   = civ.getUnitType(69)
object.uUnitType70                   = civ.getUnitType(70)
object.uUnitType71                   = civ.getUnitType(71)
object.uUnitType72                   = civ.getUnitType(72)
object.uUnitType73                   = civ.getUnitType(73)
object.uUnitType74                   = civ.getUnitType(74)
object.uUnitType75                   = civ.getUnitType(75)
object.uUnitType76                   = civ.getUnitType(76)
object.uUnitType77                   = civ.getUnitType(77)
object.uUnitType78                   = civ.getUnitType(78)
object.uUnitType79                   = civ.getUnitType(79)
object.uUnitType80                   = civ.getUnitType(80)
object.uUnitType81                   = civ.getUnitType(81)
object.uUnitType82                   = civ.getUnitType(82)
object.uUnitType83                   = civ.getUnitType(83)
object.uUnitType84                   = civ.getUnitType(84)
object.uUnitType85                   = civ.getUnitType(85)
object.uUnitType86                   = civ.getUnitType(86)
object.uUnitType87                   = civ.getUnitType(87)
object.uUnitType88                   = civ.getUnitType(88)
object.uUnitType89                   = civ.getUnitType(89)
object.uUnitType90                   = civ.getUnitType(90)
object.uUnitType91                   = civ.getUnitType(91)
object.uUnitType92                   = civ.getUnitType(92)
object.uUnitType93                   = civ.getUnitType(93)
object.uUnitType94                   = civ.getUnitType(94)
object.uUnitType95                   = civ.getUnitType(95)
object.uUnitType96                   = civ.getUnitType(96)
object.uUnitType97                   = civ.getUnitType(97)
object.uUnitType98                   = civ.getUnitType(98)
object.uUnitType99                   = civ.getUnitType(99)
object.uUnitType100                   = civ.getUnitType(100)
object.uUnitType101                   = civ.getUnitType(101)
object.uUnitType102                   = civ.getUnitType(102)
object.uUnitType103                   = civ.getUnitType(103)
object.uUnitType104                   = civ.getUnitType(104)
object.uUnitType105                   = civ.getUnitType(105)
object.uUnitType106                   = civ.getUnitType(106)
object.uUnitType107                   = civ.getUnitType(107)
object.uUnitType108                   = civ.getUnitType(108)
object.uUnitType109                   = civ.getUnitType(109)
object.uUnitType110                   = civ.getUnitType(110)
object.uUnitType111                   = civ.getUnitType(111)
object.uUnitType112                   = civ.getUnitType(112)
object.uUnitType113                   = civ.getUnitType(113)
object.uUnitType114                   = civ.getUnitType(114)
object.uUnitType115                   = civ.getUnitType(115)
object.uUnitType116                   = civ.getUnitType(116)
object.uUnitType117                   = civ.getUnitType(117)
object.uUnitType118                   = civ.getUnitType(118)
object.uUnitType119                   = civ.getUnitType(119)
object.uUnitType120                   = civ.getUnitType(120)
object.uUnitType121                   = civ.getUnitType(121)
object.uUnitType122                   = civ.getUnitType(122)
object.uUnitType123                   = civ.getUnitType(123)
object.uUnitType124                   = civ.getUnitType(124)
object.uUnitType125                   = civ.getUnitType(125)
object.uUnitType126                   = civ.getUnitType(126)


-- City Improvements
-- recommended key prefix 'i'
--          

object.iNothing                     = civ.getImprovement(0)
object.iImprovement1                = civ.getImprovement(1)
object.iImprovement2                = civ.getImprovement(2)
object.iImprovement3                = civ.getImprovement(3)
object.iImprovement4                = civ.getImprovement(4)
object.iImprovement5                = civ.getImprovement(5)
object.iImprovement6                = civ.getImprovement(6)
object.iImprovement7                = civ.getImprovement(7)
object.iImprovement8                = civ.getImprovement(8)
object.iImprovement9                = civ.getImprovement(9)
object.iImprovement10                = civ.getImprovement(10)
object.iImprovement11                = civ.getImprovement(11)
object.iImprovement12                = civ.getImprovement(12)
object.iImprovement13                = civ.getImprovement(13)
object.iImprovement14                = civ.getImprovement(14)
object.iImprovement15                = civ.getImprovement(15)
object.iImprovement16                = civ.getImprovement(16)
object.iImprovement17                = civ.getImprovement(17)
object.iImprovement18                = civ.getImprovement(18)
object.iImprovement19                = civ.getImprovement(19)
object.iImprovement20                = civ.getImprovement(20)
object.iImprovement21                = civ.getImprovement(21)
object.iImprovement22                = civ.getImprovement(22)
object.iImprovement23                = civ.getImprovement(23)
object.iImprovement24                = civ.getImprovement(24)
object.iImprovement25                = civ.getImprovement(25)
object.iImprovement26                = civ.getImprovement(26)
object.iImprovement27                = civ.getImprovement(27)
object.iImprovement28                = civ.getImprovement(28)
object.iImprovement29                = civ.getImprovement(29)
object.iImprovement30                = civ.getImprovement(30)
object.iImprovement31                = civ.getImprovement(31)
object.iImprovement32                = civ.getImprovement(32)
object.iImprovement33                = civ.getImprovement(33)
object.iImprovement34                = civ.getImprovement(34)
object.iImprovement35                = civ.getImprovement(35)


-- Tribes
-- recommended key prefix 't'
--
object.tBarbarians                  = civ.getTribe(0)
object.tTribe1                      = civ.getTribe(1)
object.tTribe2                      = civ.getTribe(2)
object.tTribe3                      = civ.getTribe(3)
object.tTribe4                      = civ.getTribe(4)
object.tTribe5                      = civ.getTribe(5)
object.tTribe6                      = civ.getTribe(6)
object.tTribe7                      = civ.getTribe(7)

-- Wonders
-- recommended key prefix 'w'
object.wWonder0                     = civ.getWonder(0)
object.wWonder1                     = civ.getWonder(1)
object.wWonder2                     = civ.getWonder(2)
object.wWonder3                     = civ.getWonder(3)
object.wWonder4                     = civ.getWonder(4)
object.wWonder5                     = civ.getWonder(5)
object.wWonder6                     = civ.getWonder(6)
object.wWonder7                     = civ.getWonder(7)
object.wWonder8                     = civ.getWonder(8)
object.wWonder9                     = civ.getWonder(9)
object.wWonder10                     = civ.getWonder(10)
object.wWonder11                     = civ.getWonder(11)
object.wWonder12                     = civ.getWonder(12)
object.wWonder13                     = civ.getWonder(13)
object.wWonder14                     = civ.getWonder(14)
object.wWonder15                     = civ.getWonder(15)
object.wWonder16                     = civ.getWonder(16)
object.wWonder17                     = civ.getWonder(17)
object.wWonder18                     = civ.getWonder(18)
object.wWonder19                     = civ.getWonder(19)
object.wWonder20                     = civ.getWonder(20)
object.wWonder21                     = civ.getWonder(21)
object.wWonder22                     = civ.getWonder(22)
object.wWonder23                     = civ.getWonder(23)
object.wWonder24                     = civ.getWonder(24)
object.wWonder25                     = civ.getWonder(25)
object.wWonder26                     = civ.getWonder(26)
object.wWonder27                     = civ.getWonder(27)
--

--Text
-- 



-- Flag and Counter Definitions
-- Flags and counters have to be defined somewhere, and this
-- is as good a place as any






-- this will give you an if you try to access a key not entered into
-- the object table, which could be helpful for debugging, but it
-- means that no nil value can ever be returned for table object
-- If you need that ability, comment out this section
setmetatable(object,{__index = function(myTable,key)
    error("The object table doesn't have a value associated with "..tostring(key)..".") end})

return object
