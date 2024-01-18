local baseModules = script.Parent.Parent.Settings.Modules

local Messages = require(baseModules.Messages)
local Checkpoints = require(baseModules.Checkpoints)
local Webhook = require(baseModules.Webhook)
local Info = require(baseModules.Info)

local Settings = require(script.Parent.Parent.Settings)
local SessionStatus = require(script.Parent.SessionStatus)

local Logger = {
    Tags = {
        DayToday = "TAG_TODAYS_DATE",
        SessionTime = "TAG_SESSION_TIME",
        TotalTime = "TAG_TOTAL_TIME"
    }
}

Logger.__index = Logger

---------------

type self = {
    settingsRoot: Settings.Settings,
    messages: Messages.Messages,
    checkpoints: Checkpoints.Checkpoints,
    webhook: Webhook.Webhook,
    info: Info.Info,
    sessionStatus: SessionStatus.SessionStatus,
    loopThread: thread?,
}

export type Logger = typeof(setmetatable({} :: self, Logger))

-------------

local function secondsToHMS(time)
    local seconds = time % 60
    local minutes = math.floor(time / 60) % 60
    local hours = math.floor(time / 3600) % 24

    return string.format("%s:%s:%s", hours, minutes, seconds)
end

local function secondsToDHMS(time)
    local seconds = time % 60
    local minutes = math.floor(time / 60) % 60
    local hours = math.floor(time / 3600) % 24
    local days = math.floor(time / 86400)

    return string.format("%s:%s:%s:%s", days, hours, minutes, seconds)
end

-------------

function Logger.new(settingsRoot: Settings.Settings, sessionStatus: SessionStatus.SessionStatus): Logger
    local self = {
        settingsRoot = settingsRoot,
        messages = require(settingsRoot.Messages),
        checkpoints = require(settingsRoot.Checkpoints),
        webhook = require(settingsRoot.Webhook),
        info = require(settingsRoot.Info),
        sessionStatus = sessionStatus,
        loopThread = nil,
    }

    setmetatable(self, Logger)

    return self
end

function Logger.start(self: Logger)
    local message = self.messages.get(self.messages.Start)
    local separator = self.messages.get(self.messages.LineSeparators)

    message = self:getTextWithTagsApplied(message)
    separator = self:getTextWithTagsApplied(separator)

    self.webhook.post(message)
    self.webhook.post(separator)
end

function Logger.onSessionRecovered(self: Logger)
    local message = self.messages.get(self.messages.SessionRecovered)
    
    message = self:getTextWithTagsApplied(message)

    self.webhook.post(message)
end

function Logger.postCheckpoint(self: Logger)
    local checkpoint = self.checkpoints.get()
        
    checkpoint = self:getTextWithTagsApplied(checkpoint)

    self.webhook.post(checkpoint)
end

function Logger.loopCheckpointPosting(self: Logger)
    if self.loopThread then
        return
    end

    local function loop()
        local interval = self.checkpoints.IntervalSeconds

        while task.wait(interval) do
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

    message = self:getTextWithTagsApplied(message)

    self.webhook.post(message)
end

function Logger.resume(self: Logger)
    local message = self.messages.get(self.messages.Resume)

    message = self:getTextWithTagsApplied(message)

    self.webhook.post(message)
end

function Logger.close(self: Logger)
    local separator = self.messages.get(self.messages.LineSeparators)
    local message = self.messages.get(self.messages.Close)

    separator = self:getTextWithTagsApplied(separator)
    message = self:getTextWithTagsApplied(message)

    self.webhook.post(separator)
    self.webhook.post(message)
end

--

function Logger.getTextWithTagsApplied(self: Logger, text: string): string
    local tagApplications = {
        [Logger.Tags.DayToday] = os.date(),
        [Logger.Tags.SessionTime] = secondsToHMS(self.sessionStatus:getTimeElapsed()),
        [Logger.Tags.TotalTime] = secondsToDHMS(self.info.getTotalProjectTime()),
    }
    
    return string.gsub(text, "[%w%p]+", tagApplications)
end

---------------

return Logger