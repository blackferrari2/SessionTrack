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
    -- dont set this number too low or you may be rate limited by discord
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

    dont add anything to opt out of checkpoints.

    Example:
        Checkpoints.add("TestAuthor", "hey")
]]

--[[
    SPECIAL TAGS
    spice up your checkpoints with them

    ...

    TAG_SESSION_TIME
        time spent on the current session

    TAG_TOTAL_TIME
        total time spent on the project

    TAG_TODAYS_DATE
        day, hour, minute, second at the moment of starting the session

    ...
]]

Checkpoints.add("TestAuthor", "hey" .. Assets.Emojis.Smiley)
Checkpoints.add("TestAuthor2", "helolo TAG_SESSION_TIME")

---------------

return Checkpoints