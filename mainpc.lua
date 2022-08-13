rednet.open("back")

function write() 
    while true do
        print("Run Command")
        local input = read()
        if input == "Home" then
            rednet.broadcast("home")
        end
        if input == "Stop" then
            rednet.close("back")
        end
        if input == "Ping" then
            rednet.broadcast("ping")
        end
        if input == "Here" then
            rednet.broadcast("here:" .. tostring(vector.new(gps.locate(2, false))))
        end
        if input == "Follow" then
            while true do
                if input == "Stop" then
                    break
                end
                rednet.broadcast("here:" .. tostring(vector.new(gps.locate(2, false))))
                os.sleep(1)
            end
        end
        if input == "Work" then
            rednet.broadcast("work")
        end
        os.sleep(1)
    end
end

function receive()
    while true do
        local id,message = rednet.receive()
        print("Message: ", message, " received from: ", id)
        os.sleep(1)
    end
end

parallel.waitForAny(receive, write)
