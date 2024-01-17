--[[
    These are the special messages sent upon starting / ending / pausing a session.

    scroll down
    ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
]]

local Messages = {
    Start = {},
    SessionRecovered = {},
    Close = {},
    Pause = {},
    Resume = {},
    LineSeparators = {},
}

Messages.__index = Messages

---------------

type self = {
    Start: MessageList,
    Close: MessageList,
    Pause: MessageList,
    Resume: MessageList,
}

export type MessageList = {string}
export type Messages = typeof(setmetatable({} :: self, Messages))

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

Messages.add(Messages.Start, "Session Started!")
Messages.add(Messages.Start, "Session Started... yay")

Messages.add(Messages.SessionRecovered, "Session Recovered!")
Messages.add(Messages.SessionRecovered, "im so glad you remembered to bring me back! Session recovered")

Messages.add(Messages.Close, "Session Closed!")
Messages.add(Messages.Close, "Session Closed unfortunately")

Messages.add(Messages.Pause, "paused.")
Messages.add(Messages.Pause, "pausedddddd")

Messages.add(Messages.Resume, "resumed")
Messages.add(Messages.Resume, "resumeddddddddddd12313213")

Messages.add(Messages.LineSeparators, "----------------")
Messages.add(Messages.LineSeparators, "////////////////")

---------------

return Messages