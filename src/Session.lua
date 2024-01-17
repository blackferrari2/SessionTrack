local packages = script.Parent.Parent.Packages
local settings = script.Parent.Settings.Modules

local Logger = require(settings.Logger)
local Signal = require(packages.Signal)

local Session = {
    Statuses = {
        Ongoing = "Ongoing",
        Paused = "Paused",
        Closed = "Closed",
    },
}

Session.__index = Session

---------------

type self = {
    logger: Logger.Logger,
    status: Status,
    timeStarted: number,
    timeEnded: number?,
    changed: Signal.Signal<Status>,
}

export type Status = "Ongoing" | "Paused" | "Closed"
export type Session = typeof(setmetatable({} :: self, Session))

-------------

function Session.begin(logger: Logger.Logger, recoveredSessionStartTime: number?): Session
    local self = {
        logger = logger,
        status = Session.Statuses.Ongoing,
        timeStarted = recoveredSessionStartTime or tick(),
        changed = Signal.new(),
    }

    setmetatable(self, Session)

    if recoveredSessionStartTime then
        logger:onSessionRecovered()
    else
        logger:start()
    end

    logger:loopCheckpointPosting()

    return self
end

function Session.pause(self: Session)
    if self.status ~= Session.Statuses.Ongoing then
        return
    end

    self.status = Session.Statuses.Paused
    self.changed:Fire(self.status)
    
    self.logger:stopLoop()
    self.logger:pause()
end

function Session.resume(self: Session)
    if self.status ~= Session.Statuses.Paused then
        return
    end

    self.status = Session.Statuses.Ongoing
    self.changed:Fire(self.status)

    self.logger:resume()
    self.logger:loopCheckpointPosting()
end

function Session.close(self: Session)
    self.status = Session.Statuses.Closed
    self.changed:Fire(self.status)
    self.timeEnded = tick()

    self.logger:stopLoop()
    self.logger:close()
end

function Session.getTimeElapsed(self: Session)
    if self.timeEnded then
        return self.timeEnded - self.timeStarted
    else
        return tick() - self.timeStarted
    end
end

---------------

return Session