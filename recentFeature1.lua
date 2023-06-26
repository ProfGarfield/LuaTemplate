--require("unitDataTestingSuite")
local traits = require("traits")
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(2)
local discreteEvents = require("discreteEventsRegistrar")
local changeRules = require("changeRules")
local keyboard = require("keyboard")




discreteEvents.onKeyPress(function(keyID)
    if keyID == keyboard.zero then
        gen.justOnce("zero",function()
            civ.ui.text("zero pressed")
        end)
    end
end)









--[[
-- maxMoves(unit)--> integer
-- gen.maxMoves(unit) --> integer
-- returns movement allowance for a unit after taking damage
-- into account, multiplied by the road/rail multiplier
-- Helper Function (provided as both local function and in table
function maxMoves(unit)
    local fullHpMove = unit.type.move
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)) then
            fullHpMove = fullHpMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if applyWonderBonus(12,unit.owner) then
            fullHpMove = fullHpMove+2*totpp.movementMultipliers.aggregate
        end
        if applyWonderBonus(3,unit.owner) and not gen.isCoastal(unit.type) then
            fullHpMove = fullHpMove + totpp.movementMultipliers.aggregate
        end
    end
    local moveAllowance = (unit.hitpoints*fullHpMove)//unit.type.hitpoints
    local moveMult = totpp.movementMultipliers.aggregate
    if moveAllowance % moveMult > 0 then
        moveAllowance = moveAllowance - moveAllowance % moveMult + moveMult
    end
    if unit.type.domain == 0 or unit.type.domain >= 3 then
        return math.min(math.max( moveAllowance,moveMult),fullHpMove)
    elseif unit.type.domain == 1 then
        return fullHpMove
    elseif unit.type.domain == 2 then
        return math.min(math.max( moveAllowance,2*moveMult),fullHpMove)
    end
end
gen.maxMoves = maxMoves


-- gen.moveRemaining(unit)
-- returns gen.maxMoves-unit.moveSpent
-- bug fixed by Knighttime
local function moveRemaining(unit)
	local actualMoveSpent = unit.moveSpent
	if actualMoveSpent < 0 then
		actualMoveSpent = actualMoveSpent + 256
	end
    return maxMoves(unit)-actualMoveSpent
end
gen.moveRemaining = moveRemaining
--]]
--[[
local transportMovement = 5
local function fullHPMove(unit,rulesMovement)
    local fullHpMove = rulesMovement*totpp.movementMultipliers.aggregate
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)) then
            fullHpMove = fullHpMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if applyWonderBonus(12,unit.owner) then
            fullHpMove = fullHpMove+2*totpp.movementMultipliers.aggregate
        end
        if applyWonderBonus(3,unit.owner) and not gen.isCoastal(unit.type) then
            fullHpMove = fullHpMove + totpp.movementMultipliers.aggregate
        end
    end
    return fullHpMove
end
--]]

local function expectedMoveAllowance(unit,proposedMaxMove)
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)) then
            proposedMaxMove = proposedMaxMove+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if gen.isWonderActiveForTribe(12,unit.owner) then
            proposedMaxMove = proposedMaxMove+2*totpp.movementMultipliers.aggregate
        end
        if gen.isWonderActiveForTribe(3,unit.owner) and not gen.isCoastal(unit.type) then
            proposedMaxMove = proposedMaxMove + totpp.movementMultipliers.aggregate
        end
    end
    local moveAllowance = (unit.hitpoints*proposedMaxMove)//unit.type.hitpoints
    local moveMult = totpp.movementMultipliers.aggregate
    if moveAllowance % moveMult > 0 then
        moveAllowance = moveAllowance - moveAllowance % moveMult + moveMult
    end
    if unit.type.domain == 0 or unit.type.domain >= 3 then
        return math.min(math.max( moveAllowance,moveMult),moveAllowance)
    elseif unit.type.domain == 1 then
        return moveAllowance
    elseif unit.type.domain == 2 then
        return math.min(math.max( moveAllowance,2*moveMult),moveAllowance)
    end
end



-- specialMovementUnits[unit.type.id] = {rulesMovement,minMovement}
local specialMovementUnits = {
    [gen.original.uTransport.id] = {5,4}, -- transport has 5 movement in rules, will have max movement of 4
    [gen.original.uGalleon.id] = {4,4}, -- galleon has 4 movement in rules, will have max movement of 4
}

local function giveUnitThisMovement(unit,minAllowance)
    if gen.maxMoves(unit) >= minAllowance then
        return
    end
    if unit.type.domain == 2 then
        -- apply nuclear power
        if unit.owner:hasTech(civ.getTech(59)) then
            minAllowance = minAllowance+totpp.movementMultipliers.aggregate
        end
        -- apply magellan's and lighthouse
        if gen.isWonderActiveForTribe(12,unit.owner) then
            minAllowance = minAllowance+2*totpp.movementMultipliers.aggregate
        end
        if gen.isWonderActiveForTribe(3,unit.owner) and not gen.isCoastal(unit.type) then
            minAllowance = minAllowance + totpp.movementMultipliers.aggregate
        end
    end
    local highMax = 255 -- this is known to be higher than the correct MaxMove
    local lowMax = minAllowance -- this is known to be lower than correct maxMove
    local proposedMaxMove = math.floor(0.5*(highMax+lowMax))
    local expectedAllowance = expectedMoveAllowance(unit,proposedMaxMove)
    for loopCount = 0,255 do
        if expectedAllowance == minAllowance or proposedMaxMove == 255 then
            unit.type.move = proposedMaxMove
            return
        elseif expectedAllowance < minAllowance then
            lowMax = proposedMaxMove
            proposedMaxMove = math.ceil(0.5*(lowMax+highMax))
            expectedAllowance = expectedMoveAllowance(unit,proposedMaxMove)
        else
            highMax = proposedMaxMove
            proposedMaxMove = math.floor(0.5*(lowMax+highMax))
            expectedAllowance = expectedMoveAllowance(unit,proposedMaxMove)
        end
    end
    error("giveUnitThisMovement: failed to find a solution")
end

function discreteEvents.onActivateUnit(unit,source,repeatMove)
    for id,movementTable in pairs(specialMovementUnits) do
        civ.getUnitType(id).move = movementTable[1]*totpp.movementMultipliers.aggregate
    end
    if not specialMovementUnits[unit.type.id] then
        return
    end
    giveUnitThisMovement(unit,specialMovementUnits[unit.type.id][2]*totpp.movementMultipliers.aggregate)
end



--[[
local specificKeyTable = {
    tf = {["boolean"]=true},
    num = {["number"]=true},
    str = {["string"]=true},
}

local generalKeyTable = {
    [function(key) return string.sub(key,1,3) == "abc" end] = {["number"]=true,["nil"]=true}
}

local newSample, isSample, sampleMT = gen.createDataType("sampleType",specificKeyTable,generalKeyTable,{abc123=1,str="me"},{tf=true})

local something = newSample({tf = false,num = 4, abc456 = 3})

for key,val in pairs(something) do
    print(key,tostring(val))
end

print(isSample(something))
print(isSample({}))

--something.tf = true
--something.num = "four"
something.abc2 = 1
--something.abc3 = "1"
--something.abc456 = "4"
something.abc456 = 2

for key,val in pairs(something) do
    print(key,tostring(val))
end
print(getmetatable(something), sampleMT)

--]]


--[[
traits.allowedTraits("warrior1","warrior2","phalanx1","phalanx2","joint")

traits.assign(gen.original.uWarriors,"warrior1","warrior2","joint")
traits.assign(gen.original.uPhalanx,"phalanx1","phalanx2","joint")

local function checkExpect(expectation,actual,description)
    description = description or ""
    if expectation == actual then
        return
    end
    error("checkExpect: expectation: "..tostring(expectation).." actual: "..tostring(actual).."\nDescription: "..tostring(description))
end

function discreteEvents.onKeyPress(keyID)
    checkExpect(true,traits.hasAnyTrait(gen.original.uWarriors,"phalanx1","warrior1"),"w1")
    checkExpect(true,traits.hasAnyTrait(gen.original.uWarriors,"phalanx2","warrior2"),"w2")
    checkExpect(true,traits.hasAnyTrait(gen.original.uPhalanx,"phalanx1","warrior1"),"p1")
    checkExpect(true,traits.hasAnyTrait(gen.original.uPhalanx,"phalanx2","warrior2"),"p2")
    checkExpect(true,traits.hasAnyTrait(gen.original.uWarriors,"joint"),"wj")
    checkExpect(true,traits.hasAnyTrait(gen.original.uPhalanx,"joint"),"pj")
    checkExpect(false,traits.hasAnyTrait(gen.original.uWarriors,"phalanx1","phalanx2"),"wp")
    checkExpect(false,traits.hasAnyTrait(gen.original.uPhalanx,"warrior1","warrior2"),"pw")
    print("test complete")
end
--]]


