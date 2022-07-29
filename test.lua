local position
-- North 1
-- East 2
-- South 3
-- West 4
local rotation = 3
local startpos
-- Mine depth + random 0,5 
local mineDepth = 40

local mainPcId = 8

local baseHolePos = vector.new(-56, mineDepth, -53)

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
        local l = turtle.inspect()
        local moveF = turtle.forward()
        if moveF == false and not l then
            -- atack them
            turtle.attack()
        elseif moveF == false then
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
        local l = turtle.inspectUp()
        if moveU == false and not l then
            turtle.attackUp()
        elseif moveU == false then
            turtle.digUp()
        else
            position.y = position.y + 1
        end
    elseif dir == 3 then
        local moveD = turtle.down()
        local l = turtle.inspectDown()
        if moveD == false and not l then
            turtle.attackDown()
        elseif moveD == false then
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
    if minVec.y < position.y then
        move(3)
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
    if dir == 1 or dir == 4 then
        for i = 0,3,1 do
            local success, data = turtle.inspect()
            if success then
                if string.find(data.name, "gold") then
                    return 1
                end
            end
            turn(0)
        end
    elseif dir == 2 and dir == 4 then
        local success, data = turtle.inspectUp()
        if success then
            if string.find(data.name, "gold") then
                return 2
            end
        end
    elseif dir == 3 and dir == 4 then
        local success, data = turtle.inspectDown()
        if success then
            if string.find(data.name, "gold") then
                return 3
            end
        end
    end
    return false
end

function collectOres()
    local ores = checkOres(4)
    if ores == 1 then
        turtle.dig()
    elseif ores == 2 then
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
            log("Moving to hole pos")
        end
    end
    -- init mine pos 
    if mineStage == 0 then
        depth = mineDepth + math.random(-5, 5)
        minePos = vector.new(position.x + math.random(-50, 50), depth, position.z + math.random(-50, 50))
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
            randomPos = vector.new(position.x + math.random(-10,10), depth, position.z + math.random(-10,10))
            log("Stage: Create random pos: " .. tostring(randomPos))
        end
        if position.x == randomPos.x and position.y == randomPos.y and position.z == randomPos.z then
            randomPos = nil
            log("Stage: Reset random pos")
        end
        moveTo(randomPos)
    end
end

-- 0 running
-- 1 going home
-- 2 stopped
local mainMode = 0

-- Main loop
function main()
    turtle.refuel()
    while true do
        position = vector.new(gps.locate(2, false))
        if mainMode == 2 then
            log("Stopped!")
            break
        end
        local continue = false
        if mainMode == 1 then
           moveTo(startpos) 
           if startpos.x == position.x and startpos.y == position.y and startpos.z == position.z then
                log("Arrived at home")
                mainMode = 2
           end
           continue = true
           
        end
        if continue == false then
            local fuel = turtle.getFuelLevel()
            if fuel == 0 then
                log("Fuel empty!")
                return 
            end
            local minVec = position - startpos
            local fuelNeeded = math.abs(minVec.x) + math.abs(minVec.y) + math.abs(minVec.z)
            -- we run out of gas so run home
            if fuel == fuelNeeded then
                moveTo(startpos)
            end
            randomMine()
        end
        continue = false
        os.sleep(1)
    end
end

function listen()
    while true do
        local id,message = rednet.receive()
        if message == "home" then
            mainMode = 1 
            log("Going home now: " .. tostring(startpos))
        elseif message == "ping" then
            log("Pong at: " .. tostring(position))
        end
        os.sleep(1)
    end
end


position = vector.new(gps.locate(2, false))
startpos = position
-- For whatever reason we have to call that
-- Random gen has to warm up 
math.randomseed(os.time())
math.random(); math.random(); math.random()
rotation = translateMcDir(getOrientation()) 
rednet.open("left")
-- Run main loop
parallel.waitForAny(main, listen)