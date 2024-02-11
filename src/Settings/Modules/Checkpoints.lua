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
    IntervalSeconds = 60,
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
        day, hour, minute, second right now

    SESSIONSTATE
        state of the session (paused or ongoing)

    ...
]]

Checkpoints.add("TestAuthor", "checkpoint! did you know that the session is SESSIONSTATE?" .. Assets.Emojis.Smiley)
Checkpoints.add("IM THE AUTHOR", "checkpoint! wow this session is SO OLD that its SESSIONTIME long!" .. Assets.Emojis.Angry)

---------------

return Checkpoints