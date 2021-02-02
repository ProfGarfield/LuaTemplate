local keyboard = {}

keyboard.a = 65
keyboard.b = 66
keyboard.c = 67
keyboard.d = 68
keyboard.e = 69
keyboard.f = 70
keyboard.g = 71
keyboard.h = 72
keyboard.i = 73
keyboard.j = 74
keyboard.k = 75
keyboard.l = 76
keyboard.m = 77
keyboard.n = 78
keyboard.o = 79
keyboard.p = 80
keyboard.q = 81
keyboard.r = 82
keyboard.s = 83
keyboard.t = 84
keyboard.u = 85
keyboard.v = 86
keyboard.w = 87
keyboard.x = 88
keyboard.y = 89
keyboard.z = 90

keyboard.backspace = 214
keyboard.tab = 211
keyboard.enter = 208
keyboard.escape = 210
keyboard.esc = 210
keyboard.delete = 217
keyboard.numlockMinus = 173
keyboard.numlockPlus = 171
keyboard.numlockSlash = 175
keyboard.numlockStar = 170
keyboard.numlockAsterisk = 170

keyboard.up = 192
keyboard.north = 192
keyboard.right = 195
keyboard.east = 195
keyboard.down = 193
keyboard.south = 193
keyboard.left = 194
keyboard.west = 194

keyboard.zero = 48
keyboard.one = 49
keyboard.two = 50
keyboard.three = 51
keyboard.four = 52
keyboard.five = 53
keyboard.six = 54
keyboard.seven = 55
keyboard.eight = 56
keyboard.nine = 57

keyboard.numlock0 = 160
keyboard.numlock1 = 161
keyboard.numlock2 = 162
keyboard.numlock3 = 163
keyboard.numlock4 = 164
keyboard.numlock5 = 165
keyboard.numlock6 = 166
keyboard.numlock7 = 167
keyboard.numlock8 = 168
keyboard.numlock9 = 169

keyboard.northEast = 197
keyboard.pageUp = 197
keyboard.southEast = 198
keyboard.pageDown = 198
keyboard.southWest = 199
keyboard.endKey = 199
keyboard.northWest = 196
keyboard.home = 196


keyboard.F1 = 176
keyboard.F2 = 177
keyboard.F3 = 178
keyboard.F4 = 179
keyboard.F5 = 180
keyboard.F6 = 181
keyboard.F7 = 182
keyboard.F8 = 183
keyboard.F9 = 184
--keyboard.F10 = nil -- F10 doesn't seem to exist
keyboard.F11 = 186
keyboard.F12 = 187
keyboard.shift = {}
keyboard.shift.ctrl = {}
keyboard.ctrl = {}
keyboard.ctrl.shift = {}

local shift_offset = 256
local ctrl_offset = 512

for i,v in pairs(keyboard) do
	if i ~= "ctrl" and i ~= "shift" 
	then
		keyboard.shift[i] = shift_offset + v
		keyboard.ctrl[i] = ctrl_offset + v
		keyboard.shift.ctrl[i] = shift_offset + ctrl_offset + v
		keyboard.ctrl.shift[i] = shift_offset + ctrl_offset + v
	end
end

keyboard.ctrlOffset = ctrl_offset
keyboard.shiftOffset = shift_offset

return keyboard
