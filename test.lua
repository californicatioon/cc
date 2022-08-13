local position
-- North 1
-- East 2
-- South 3
-- West 4
local rotation = 3
local startpos
-- Mine depth + random 0,5 
local mineDepth = 15

local mainPcId = 13

local chunkRange = 50

local baseHolePos = vector.new(240, mineDepth, -222)

local chestPos = vector.new(240, 67, -215)

local blockItemList = {"stone","dirt", "gravel", "marble", "basalt"}
local blockAttackList = {"chest","turtle"}

local slotMap = {}

-- check items and throws away items which aren't in blockList
-- also consumes coal
function checkInv()
    local iSlot = 1
    for i = 1,16 do
        local item = turtle.getItemDetail(i)
        if item then
            -- drop items from blocklsit
            for x = 1, #blockItemList do 
                if string.find(item.name, blockItemList[x]) then
                    turtle.select(i)
                    turtle.drop()
                end
            end
            -- refuel turtle if coal in inv
            if string.find(item.name, "coal") or string.find(item.name, "lava") then
                turtle.select(i)
                turtle.refuel()
            end
            if turtle.getItemSpace(i) == 0 and iSlot == i then
                iSlot = iSlot + 1
            end
            if i == 16 then
                return true
            end
        end
    end
    turtle.select(iSlot)
    return false
end

function log(msg)
    rednet.send(mainPcId, msg)
end

function getOrientation()
    loc1 = vector.new(gps.locate(2, false))
    if not turtle.forward() then
        for j=1,6 do
                if not turtle.forward() then
                        turtle.dig()
            else break end
        end
    end
    loc2 = vector.new(gps.locate(2, false))
    heading = loc2 - loc1
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
end

-- Extra func to save the position 
-- 0 forward
-- 1 backward
-- 2 up
-- 3 down
function move(dir)
    -- check for monster
    local r = false
    if dir == 0 then
        local l, item = turtle.inspect()
        local moveF = turtle.forward()
        if moveF == false and not l then
            -- atack them
            turtle.attack()
        elseif moveF == false then
            for x = 1, #blockAttackList do 
                if string.find(item.name, blockAttackList[x]) then
                    if blockAttackList[x] == "turtle" then
                        local dodgeVec = vector.new(position.x, position.y + 1, position.z)
                        moveTo(dodgeVec)
                    end
                    return
                end
            end
            turtle.dig()
        else
            if rotation == 1 then
                position.z = position.z - 1
            elseif rotation == 2 then
                position.x = position.x + 1
            elseif rotation == 3 then
                position.z = position.z + 1
            elseif rotation == 4 then
                position.x = position.x - 1
            end
            r = true
        end
    elseif dir == 2 then
        local moveU = turtle.up()
        local l, item = turtle.inspectUp()
        if moveU == false and not l then
            turtle.attackUp()
        elseif moveU == false then
            for x = 1, #blockAttackList do 
                if string.find(item.name, blockAttackList[x]) then
                    if blockAttackList[x] == "turtle" then
                        local dodgeVec = vector.new(position.x + 1, position.y, position.z + 1)
                        moveTo(dodgeVec)
                    end
                    return
                end
            end
            turtle.digUp()
        else
            position.y = position.y + 1
        end
    elseif dir == 3 then
        local moveD = turtle.down()
        local l, item = turtle.inspectDown()
        if moveD == false and not l then
            turtle.attackDown()
        elseif moveD == false then
            for x = 1, #blockAttackList do 
                if string.find(item.name, blockAttackList[x]) then
                    if blockAttackList[x] == "turtle" then
                        local dodgeVec = vector.new(position.x + 1, position.y, position.z + 1)
                        moveTo(dodgeVec)
                    end
                    return
                end
            end
            turtle.digDown()
        else
            position.y = position.y - 1
        end
    end
    return r
end

-- Extra fun to save orientation
-- 0 left
-- 1 right
function turn(dir)
    if dir == 0 then
        if turtle.turnLeft() then
            rotation = rotation - 1
            if rotation < 1 then rotation = rotation + 4 end
        end
    elseif dir == 1 then
        if turtle.turnRight() then
            rotation = rotation + 1
            if rotation > 4 then rotation = rotation - 4 end
        end
    end
end

function moveTo(vector3)
    local minVec = vector3
    if minVec.y < position.y then
        move(3)
        return
    end
    if minVec.z > position.z then
        while rotation ~= 3 do
            turn(0)
        end
        move(0)
        return
    end
    if minVec.z < position.z then
        while rotation ~= 1 do
            turn(0)
        end
        move(0)
        return
    end
    if minVec.x > position.x then
        while rotation ~= 2 do
            turn(0)
        end
        move(0)
        return
    end
    if minVec.x < position.x then
        while rotation ~= 4 do
            turn(0)
        end
        move(0)
        return
    end
    if minVec.y > position.y then
        move(2)
        return
    end
end

-- We use different direction enums than MC
function translateMcDir(mcDir)
    if mcDir == 3 then
        return 2        
    elseif mcDir == 4 then
        return 3
    elseif mcDir == 2 then
        return 1
    end
    return 4
end

-- Directions
-- 1 forward
-- 2 up
-- 3 down
-- 4 all
-- Returns dir
-- 1 forward
-- 2 up
-- 3 down
function checkOres(dir) 
    if dir == 2 and dir == 4 then
        local success, item = turtle.inspectUp()
        if success then
            for x = 1, #blockItemList do 
                if not string.find(item.name, blockItemList[x]) then
                    return 2
                end
            end
        end
    elseif dir == 3 and dir == 4 then
        local success, item = turtle.inspectDown()
        if success then
            for x = 1, #blockItemList do 
                if not string.find(item.name, blockItemList[x]) then
                    return 3
                end
            end
        end
    end
    return 0
end

function collectOres()
    local ores = checkOres(4)
    if ores == 2 then
        turtle.digUp()
    elseif ores == 3 then
        turtle.digDown()
    end
end

-- -1 base hole pos
-- 0 init
-- 1 minepos
-- 2 find ores
-- 3 mine all
local mineStage = -1

local depth 
local minePos
local randomPos

-- Main mine func
function randomMine() 
    -- goto hole pos
    if mineStage == -1 then
       moveTo(baseHolePos)
        if position.x == baseHolePos.x and position.y == baseHolePos.y and position.z == baseHolePos.z then
            mineStage = 0
            log("Moved to base hole pos: " .. tostring(position))
        end
    end
    -- init mine pos 
    if mineStage == 0 then
        depth = mineDepth + math.random(-5, 5)
        minePos = vector.new(baseHolePos.x + math.random(-chunkRange, chunkRange), depth, baseHolePos.z + math.random(-chunkRange, chunkRange))
        mineStage = 1
        log("Created mining pos: " .. tostring(minePos))
    end
    -- go to mine pos
    if mineStage == 1 then
        moveTo(minePos)
        if position.x == minePos.x and position.y == minePos.y and position.z == minePos.z then
            mineStage = 2
            log("Collecting ores now")
        end
    end
    -- check and collect ores and move
    if mineStage == 2 then
        collectOres()
        if randomPos == nil then
            randomPos = vector.new(baseHolePos.x + math.random(-chunkRange,chunkRange), depth, baseHolePos.z + math.random(-chunkRange,chunkRange))
            log("Stage: Create random pos: " .. tostring(randomPos))
        end
        if position.x == randomPos.x and position.y == randomPos.y and position.z == randomPos.z then
            randomPos = nil
            log("Stage: Reset random pos")
            return
        end
        moveTo(randomPos)
    end
end

-- 0 running
-- 1 going home
-- 2 stopped
local mainMode = 0

local tempPos

function dropAll()
    while rotation ~= 1 do
        turn(0)
    end
    for i = 1,16 do
       turtle.select(i)
       turtle.drop() 
    end
end

function main()
    position = vector.new(gps.locate(2, false))
    -- Check inventory items and drop them
    if checkInv() then
        -- inv is full
        log("Inventory is full! Coming back!")
        moveTo(chestPos)
        if chestPos.x == position.x and chestPos.y == position.y and chestPos.z == position.z then
            -- drop all
            dropAll()
            log("Cleared inv")
        end
        return
    end
    -- Check if empty fuel
    local fuel = turtle.getFuelLevel()
    if fuel == 0 then
        log("Fuel empty at: " .. tostring(position))
        return
    end
    -- Check if inventory full
    local lastItem = turtle.getItemDetail(16)
    if lastItem then
        log("Fuel low, will go home")
        moveTo(startpos)
        return
    end

    -- Check if we running on low gas
    local minVec = position - startpos
    local fuelNeeded = minVec.x + minVec.y + minVec.z
    -- we run out of gas so run home
    if fuel <= fuelNeeded then
        log("Fuel low, will go home")
        moveTo(startpos)
        return
    end
    -- Check if we should go home
    if mainMode == 1 then
        moveTo(startpos) 
        if startpos.x == position.x and startpos.y == position.y and startpos.z == position.z then
            log("Arrived at home")
            mainMode = 2
        end
        return
    end

    if mainMode == 3 then
        moveTo(tempPos)
        if tempPos.x == position.x and tempPos.y == position.y and tempPos.z == position.z then
            log("Arrived you")
            mainMode = 2
        end
        return
    end
    -- Random mining process
    if mainMode ~= 2 then
        randomMine()
    end
end

-- Main loop
function mainLoop()
    while true do
        -- Stop turtle
        main()
        os.queueEvent("fakeEvent");
        os.pullEvent();
        end
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function listen()
    while true do
        local id,message = rednet.receive()
        if message == "home" then
            mainMode = 1 
            log("Going home now: " .. tostring(startpos))
        elseif message == "ping" then
            log("Pong at: " .. tostring(position))
        elseif string.find(message, "here") then
            local split = Split(message, ":")
            local posStr = split[2]
            local split2 = Split(posStr, ",")
            local x = math.floor(tonumber(split2[1]))
            local y = math.floor(tonumber(split2[2]))
            local z = math.floor(tonumber(split2[3]))
            local pos = vector.new(x, y, z)
            log("Coming to you: " .. tostring(pos))
            mainMode = 3
            tempPos = pos
        elseif message == "work" then
            log("Going back to work!")
            mainMode = 2
        end
        os.queueEvent("fakeEvent2");
        os.pullEvent();
    end
end


position = vector.new(gps.locate(2, false))
startpos = position
-- For whatever reason we have to call that
-- Random gen has to warm up 
math.randomseed(os.time())
math.random(); math.random(); math.random()
rotation = translateMcDir(getOrientation()) 
rednet.open("right")
-- Run main loop
parallel.waitForAny(mainLoop, listen)