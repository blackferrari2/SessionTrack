local SessionStatus = require(script.SessionStatus)
local Logger = require(script.Logger)

local Session = {}
Session.__index = Session

---------------

type self = {
    status: SessionStatus.SessionStatus,
    logger: Logger.Logger?,
}

export type Session = typeof(setmetatable({} :: self, Session))

-------------

function Session.new(): Session
    local self = {
        status = SessionStatus.new(),
    }

    setmetatable(self, Session)

    return self
end

function Session.start(self: Session, logger: Logger.Logger)
    if self.status.state ~= SessionStatus.States.DidntStart then
        return
    end

    self.logger = logger
    self.status:changeState(SessionStatus.States.Ongoing)
    logger:postSessionStartMessage()
    logger:loopCheckpointPosting()
end

function Session.startFromRecoveredSession(self: Session, logger: Logger.Logger, recoveredSessionStatus: SessionStatus.SessionStatus, timeSinceLastSave: number)
    if self.status.state ~= SessionStatus.States.DidntStart then
        return
    end

    self.logger = logger
    self.status:changeState(recoveredSessionStatus.state)
    self.status.timePassed = recoveredSessionStatus.timePassed

    -- if the recovered session wasnt paused, we need to recalculate the timePassed
    -- so that we ignore the time inbetween losing the session and recovering it
    if recoveredSessionStatus.state == SessionStatus.States.Ongoing then
        self.status.timePassed = recoveredSessionStatus:getTimeElapsed() - timeSinceLastSave
        logger:loopCheckpointPosting()
    end

    logger:postSessionRecoveredMessage()
end

function Session.pause(self: Session)
    if self.status.state ~= SessionStatus.States.Ongoing then
        return
    end

    assert(self.logger)
    self.status:changeState(SessionStatus.States.Paused)
    self.logger:stopCheckpointLoop()
    self.logger:postSessionPauseMessage()
end

function Session.resume(self: Session)
    if self.status.state ~= SessionStatus.States.Paused then
        return
    end

    assert(self.logger)
    self.status:changeState(SessionStatus.States.Ongoing)
    self.logger:postSessionResumeMessage()
    self.logger:loopCheckpointPosting()
end

function Session.close(self: Session)
    if self.status.state == SessionStatus.States.Closed then
        return
    end

    assert(self.logger)
    self.status:changeState(SessionStatus.States.Closed)
    self.logger:postSessionCloseMessage()
    self.logger = nil
end

function Session.destroy(self: Session)
    self.status:changeState(SessionStatus.States.Closed)
    self.status:destroy()
    self.logger = nil

    local setmetatable: any = setmetatable
    setmetatable(self, nil)
end

---------------

return Session