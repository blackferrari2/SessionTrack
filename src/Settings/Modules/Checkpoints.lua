--[[
    Checkpoints are random messages that are sent during a session.

    scroll down
    ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
]]

local Checkpoints = {}
Checkpoints.__index = Checkpoints

---------------

type self = {}

export type Checkpoints = typeof(setmetatable({} :: self, Checkpoints))

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

Checkpoints.add("TestAuthor", "hey")
Checkpoints.add("TestAuthor2", "helolo")

---------------

return Checkpoints