--[[
    NOTE:

    SAVE AND RESTART STUDIO TO APPLY CHANGES.
]]

--[[
    Checkpoints are random messages that are sent during a session.

    scroll down
    ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
]]

local Assets = require(script.Parent.Assets)

local Checkpoints = {
    -- Minimum value: 60 seconds
    IntervalSeconds = 600,
}

---------------

export type Checkpoints = typeof(Checkpoints)

---------------

local FORMAT = "[%s]: %s"

---------------

function Checkpoints.add(author: string, message: string)
    local checkpoint = {
        author = author,
        message = message
    }

    table.insert(Checkpoints, checkpoint)
end

function Checkpoints.get(): string?
    if #Checkpoints < 1 then
        return nil
    end

    local randomCheckpoint = math.random(1, #Checkpoints)
    local checkpoint = Checkpoints[randomCheckpoint]

    return string.format(FORMAT, checkpoint.author, checkpoint.message)
end

---------------

--[[
    ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ 
    ADD MORE CHECKPOINTS HERE
    ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ 

    If you dont want checkpoints to be sent, do not add any.

    Example:
        Checkpoints.add("TestAuthor", "hey")
]]

--[[
    SPECIAL TAGS
    spice up your checkpoints with them

    ...

    SESSIONTIME
        time spent on the current session

    TOTALTIME
        total time spent on the project

    TODAYSDATE
        day, hour, minute, second at the moment of starting the session

    RAWSESSIONTIME
        SESSIONTIME, in pure seconds

    RAWTOTALTIME
        TOTALTIME, in pure seconds

    SESSIONSTATE
        state of the session (paused or ongoing)

    ...
]]

Checkpoints.add("TestAuthor", "hey" .. Assets.Emojis.Smiley)
Checkpoints.add("TestAuthor2", "helolo SESSIONTIME")

---------------

return Checkpoints