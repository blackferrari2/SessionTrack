local baseModules = script.Parent.Parent.Settings.Modules

local Messages = require(baseModules.Messages)
local Checkpoints = require(baseModules.Checkpoints)
local Webhook = require(baseModules.Webhook)
local Info = require(baseModules.Info)

local Settings = require(script.Parent.Parent.Settings)
local SessionStatus = require(script.Parent.SessionStatus)

local Logger = {
    Tags = {
        DayToday = "TODAYSDATE",
        SessionTime = "SESSIONTIME",
        TotalTime = "TOTALTIME",
        RawSessionTime = "RAWSESSIONTIME",
        RawTotalTime = "RAWTOTALTIME",
        SessionState = "SESSIONSTATE",
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

local function formatSecondsToHMS(time)
    local seconds = math.floor(time % 60)
    local minutes = math.floor(time / 60) % 60
    local hours = math.floor(time / 3600) % 24

    return string.format("%s Hours, %s Minutes and %s Seconds", hours, minutes, seconds)
end

local function formatSecondsToDHMS(time)
    local seconds = math.floor(time % 60)
    local minutes = math.floor(time / 60) % 60
    local hours = math.floor(time / 3600) % 24
    local days = math.floor(time / 86400)

    return string.format("%s Days, %s Hours, %s Minutes and %s Seconds", days, hours, minutes, seconds)
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

    self:post(message)
    self:post(separator)
end

function Logger.onSessionRecovered(self: Logger)
    local message = self.messages.get(self.messages.SessionRecovered)
    
    self:post(message)
end

function Logger.postCheckpoint(self: Logger)
    local checkpoint = self.checkpoints.get()
        
    self:post(checkpoint)
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

    self:post(message)
end

function Logger.resume(self: Logger)
    local message = self.messages.get(self.messages.Resume)
    
    self:post(message)
end

function Logger.close(self: Logger)
    local separator = self.messages.get(self.messages.LineSeparators)
    local message = self.messages.get(self.messages.Close)

   self:post(separator)
   self:post(message)
end

--

-- non-message methods

function Logger.post(self: Logger, text: string)
    if self.isFaulty then
        return
    end

    text = self:getTextWithTagsApplied(text)

    self.webhook.post(text)
end

function Logger.getTextWithTagsApplied(self: Logger, text: string): string
    local tagApplications = {
        [Logger.Tags.DayToday] = os.date(),
        [Logger.Tags.SessionTime] = formatSecondsToHMS(self.sessionStatus:getTimeElapsed()),
        [Logger.Tags.TotalTime] = formatSecondsToDHMS(self.info.getTotalProjectTime()),
        [Logger.Tags.RawSessionTime] = self.sessionStatus:getTimeElapsed(),
        [Logger.Tags.RawTotalTime] = self.info.getTotalProjectTime(),
        [Logger.Tags.SessionState] = self.sessionStatus.state,
    }
    
    return string.gsub(text, "%u+", tagApplications)
end

---------------

return Logger