local settingsDirectory = script.Parent.Parent.Settings
local packages = script.Parent.Parent.Parent.Packages

local SessionStatus = require(script.Parent.SessionStatus)
local TotalProjectTime = require(script.Parent.TotalProjectTime)
local Settings = require(settingsDirectory)
local Messages = require(settingsDirectory.Modules.Messages)
local Checkpoints = require(settingsDirectory.Modules.Checkpoints)
local Info = require(settingsDirectory.Modules.Info)
local Voyager = require(packages.Voyager)

local Logger = {
    Tags = {
        DayToday = "TODAYSDATE",
        SessionState = "SESSIONSTATE",
        SessionTime = "SESSIONTIME",
        TotalTime = "TOTALTIME",
    }
}

Logger.__index = Logger

---------------

type self = {
    settings: Settings.Settings,
    messages: Messages.Messages,
    checkpoints: Checkpoints.Checkpoints,
    info: Info.Info,
    sessionStatus: SessionStatus.SessionStatus,
    totalProjectTime: TotalProjectTime.TotalProjectTime,
    webhook: typeof(Voyager)?,
    checkpointLoopThread: thread?,
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

function Logger.new(settings: Settings.Settings, sessionStatus: SessionStatus.SessionStatus, totalProjectTime: TotalProjectTime.TotalProjectTime): Logger
    local self = {
        settings = settings,
        messages = require(settings.Messages),
        checkpoints = require(settings.Checkpoints),
        info = require(settings.Info),
        sessionStatus = sessionStatus,
        totalProjectTime = totalProjectTime,
    }

    if not self.info.UseOutputInstead then
        self.webhook = Voyager.fromUrl(self.info.WebhookURL)
    end

    setmetatable(self, Logger)

    return self
end

function Logger.send(self: Logger, text: string?)
    if not text then
        return
    end

    text = self:getTextWithTagsApplied(text)

    if self.webhook then
        self.webhook:execute(text, nil, false, true)
    else
        print(text)
    end
end

function Logger.getTextWithTagsApplied(self: Logger, text: string)
    local applications = {
        [Logger.Tags.DayToday] = os.date(),
        [Logger.Tags.SessionTime] = formatSecondsToHMS(self.sessionStatus:getTimeElapsed()),
        [Logger.Tags.TotalTime] = formatSecondsToDHMS(self.totalProjectTime:get() + self.sessionStatus:getTimeElapsed()),
        [Logger.Tags.SessionState] = self.sessionStatus.state,
    }
    
    return string.gsub(text, "%u+", applications)
end

function Logger.destroy(self: Logger)
    self:stopCheckpointLoop()

    local setmetatable: any = setmetatable
    setmetatable(self, nil)
end

--

function Logger.postSessionStartMessage(self: Logger)
    local message = self.messages.get(self.messages.Start)
    local separator = self.messages.get(self.messages.LineSeparators)

    self:send(message)
    self:send(separator) 
end

function Logger.postSessionRecoveredMessage(self: Logger)
    local message = self.messages.get(self.messages.SessionRecovered)
    
    self:send(message)
end

function Logger.postCheckpoint(self: Logger)
    local checkpoint = self.checkpoints.get()
        
    self:send(checkpoint)
end

function Logger.loopCheckpointPosting(self: Logger)
    if self.checkpointLoopThread then
        return
    end

    self.checkpointLoopThread = task.spawn(function()
        local interval = self.checkpoints.IntervalSeconds

        while task.wait(interval) do
            self:postCheckpoint()
        end
    end)
end

function Logger.stopCheckpointLoop(self: Logger)
    if self.checkpointLoopThread then
        task.cancel(self.checkpointLoopThread)
        self.checkpointLoopThread = nil 
    end
end

function Logger.postSessionPauseMessage(self: Logger)
    local message = self.messages.get(self.messages.Pause)

    self:send(message)
end

function Logger.postSessionResumeMessage(self: Logger)
    local message = self.messages.get(self.messages.Resume)
    
    self:send(message)
end

function Logger.postSessionCloseMessage(self: Logger)
    local separator = self.messages.get(self.messages.LineSeparators)
    local message = self.messages.get(self.messages.Close)

   self:send(separator)
   self:send(message)
end

---------------

return Logger