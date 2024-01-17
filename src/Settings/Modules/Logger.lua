--[[
    this is the main module used to send all the messages and checkpoints and stuff wrapped in a nice interface

    you shouldnt need to modify anything here.
        ...unless? xD
]]

local Messages = require(script.Parent.Messages)
local Checkpoints = require(script.Parent.Checkpoints)
local Webhook = require(script.Parent.Webhook)

local Logger = {
    -- dont set this number too low or you may be rate limited by discord
    CheckpointIntervalSeconds = 360,
}

Logger.__index = Logger

---------------

type self = {
    messages: Messages.Messages,
    checkpoints: Checkpoints.Checkpoints,
    loopThread: thread?,
}

export type Logger = typeof(setmetatable({} :: self, Logger))

-------------

function Logger.new(messages: Messages.Messages, checkpoints: Checkpoints.Checkpoints): Logger
    local self = {
        messages = messages,
        checkpoints = checkpoints,
        loopThread = nil,
    }

    setmetatable(self, Logger)

    return self
end

function Logger.start(self: Logger)
    local message = self.messages.get(self.messages.Start)
    local separator = self.messages:get(self.messages.LineSeparators)

    Webhook.post(message)
    Webhook.post(separator)
end

function Logger.onSessionRecovered(self: Logger)
    local message = self.messages.get(self.messages.SessionRecovered)
    
    Webhook.post(message)
end

function Logger.postCheckpoint(self: Logger)
    local checkpoint = self.checkpoints.get()
            
    Webhook.post(checkpoint)
end

function Logger.loopCheckpointPosting(self: Logger)
    if self.loopThread then
        return
    end

    local function loop()
        while task.wait(Logger.CheckpointIntervalSeconds) do
            self:postCheckpoint()
        end
    end

    self.loopThread = task.spawn(loop)
end

function Logger.stopLoop(self: Logger)
    if self.loopThread then
        task.cancel(self.loopThread)
        self.loopThread = nil 
    end
end

function Logger.pause(self: Logger)
    local message = self.messages.get(self.messages.Pause)

    Webhook.post(message)
end

function Logger.resume(self: Logger)
    local message = self.messages.get(self.messages.Resume)

    Webhook.post(message)
end

function Logger.close(self: Logger)
    local message = self.messages.get(self.messages.Close)
    local separator = self.messages:get(self.messages.LineSeparators)

    Webhook.post(message)
    Webhook.post(separator)
end

---------------

return Logger