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

    If you dont want special messages to be sent, dont add them.
        this applies to all the specific categories too
            dont want "Close" messages? remove all the `Messages.add(Messages.Close)` lines

    Example:
        Messages.add(Messages.Start, "hello world!")

        to add a message to the session start
]]

--[[
    SPECIAL TAGS
    spice up your messages with them

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

Messages.add(Messages.Start, "# " .. Info.ProjectName .. " Session Started! \n ## TODAYSDATE " .. "\n " .. Assets.Posters.Yay)

--

Messages.add(Messages.SessionRecovered, "im so glad you remembered to bring me back! \n SESSIONSTATE Session recovered. Elapsed: `SESSIONTIME` " .. Assets.Emojis.Rat)

--

Messages.add(Messages.Close, "## Session Closed! \n - time: SESSIONTIME \n - total time ever: TOTALTIME")

--

Messages.add(Messages.Pause, "SESSION PAUSED! " .. Assets.Emojis.Rat)
Messages.add(Messages.Pause, "SESSION was paused... " .. Assets.Emojis.Angry)

--

Messages.add(Messages.Resume, "SESSION RESUMED! " .. Assets.Emojis.Rat)
Messages.add(Messages.Resume, "SESSION was resumed... " .. Assets.Emojis.Smiley)

--

Messages.add(Messages.LineSeparators, "### --------------------")

---------------

return Messages