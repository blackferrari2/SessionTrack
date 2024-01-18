--[[
    NOTE:

    SAVE AND RESTART STUDIO TO APPLY CHANGES.
]]

--[[
    These are the special messages sent upon starting / ending / pausing a session.

    scroll down
    ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
]]

local Assets = require(script.Parent.Assets)
local Info = require(script.Parent.Info)

local Messages = {
    Start = {},
    SessionRecovered = {},
    Close = {},
    Pause = {},
    Resume = {},
    LineSeparators = {},
}

---------------

export type MessageList = {string}
export type Messages = typeof(Messages)

---------------

function Messages.add(to: MessageList, text: string)
    table.insert(to, text)
end

function Messages.get(from: MessageList): string?
    if #from < 1 then
        return nil
    end

    local randomMessage = math.random(1, #from)

    return from[randomMessage]
end

---------------

--[[
    ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ 
    ADD MORE MESSAGES HERE
    ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ 

    to opt out of the special messages, dont add anything
        this applies to all the categories of messages here
            dont want "Close" messages? remove all the `Messages.add(Messages.Close)` lines

    Example:
        Messages.add(Messages.Start, "hello world!")

        to add a message to the session start
]]

--[[
    SPECIAL TAGS
    spice up your messages with them

    ...

    TAG_SESSION_TIME
        time spent on the current session

    TAG_TOTAL_TIME
        total time spent on the project

    TAG_TODAYS_DATE
        day, hour, minute, second at the moment of starting the session

    ...
]]

Messages.add(Messages.Start, "Session Started! TAG_TODAYS_DATE " .. Assets.Emojis.Rat)
Messages.add(Messages.Start, Info.ProjectName .. " Session Started... TAG_TODAYS_DATE yay" .. Assets.Emojis.Angry)

Messages.add(Messages.SessionRecovered, "Session Recovered! time rn: TAG_SESSION_TIME")
Messages.add(Messages.SessionRecovered, "im so glad you remembered to bring me back! Session recovered. TAG_SESSION_TIME")

Messages.add(Messages.Close, "Session Closed! total time ever: TAG_TOTAL_TIME")
Messages.add(Messages.Close, "Session Closed unfortunately. total time ever: TAG_TOTAL_TIME")

Messages.add(Messages.Pause, "paused.")
Messages.add(Messages.Pause, "pausedddddd")

Messages.add(Messages.Resume, "resumed")
Messages.add(Messages.Resume, "resumeddddddddddd12313213")

Messages.add(Messages.LineSeparators, "----------------")

---------------

return Messages