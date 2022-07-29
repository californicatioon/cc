rednet.open("right")

function write() 
    while true do
        print("Run Command")
        local input = read()
        if input == "Home" then
            rednet.broadcast("home")
        end
        if input == "Stop" then
            rednet.close("right")
        end
        if input == "Ping" then
            rednet.broadcast("ping")
        end
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
