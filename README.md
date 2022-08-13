# Auto mining script for cc tweaked
# tested on version 1.12.2

I coded this in ~5 days and never used lua before. It has a bit of dead code, which can be used to make it work without gps system.
I don't care about the coding style since I'm hoping to not use lua ever again. The code is commented tho.

# features

- remotely controllabe
- will work with other turtles (moving out of their way etc.)
- will automatically find its position and rotation
- will automatically randomely mine and fill target chest located where you want
- won't break specified blocks
- won't collect specified blocks
- auto consumes new fuel
- auto sorts its inventory
- auto kills creeps in your way
- won't destroy your house ( will only change x and z coordinate at desired depth)

# remote commands
Turtles will always log their current state + position + pc id

- "Work" will tell it to work if it's currently waiting
- "Here" will let them come to you
- "Follow" will let them follow you till you write "Stop"
- "Home" will let them go back to start position
- "Ping" responds with pong + current position

# setup

- setup a gps system with ender pads
- craft an ender mining turtle
- craft an ender computer or ender pocket computer
- download and name turtle.lua as "startup" on the turtle
- downlaod and name mainpc.lua as "startup" on your "main" computer or pocket computer

# settings
in turtle.lua set:
- minedepth to the depth it should mine at
- mainpcid to the id of your main computer or pocket computer
- chunkrange to the radius from the baseholepos of chunks
- baseholepos to the start pos where it should mine from
- chestpos to the position of your chest (facing north!)
- blockitemlist which shouldn't be collected
- blockattacklist which shouldn't be destroyed
