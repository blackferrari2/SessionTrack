local SessionStatus = require(script.SessionStatus)
local Logger = require(script.Logger)

local Session = {}
Session.__index = Session

---------------

type self = {
    status: SessionStatus.SessionStatus,
    logger: Logger.Logger,
}

export type Session = typeof(setmetatable({} :: self, Session))

-------------

function Session.new(): Session
    local self = {
        status = SessionStatus.new(),
        logger = nil,
    }

    setmetatable(self, Session)

    return self
end

function Session.begin(self: Session, logger: Logger.Logger, recoveredSessionStatus: SessionStatus.SessionStatus?)
    if self.status.state ~= SessionStatus.States.DidntStart then
        return
    end

    self.logger = logger
    self.status:changeState(SessionStatus.States.Ongoing)

    if recoveredSessionStatus then
        self.status.state = recoveredSessionStatus.state
        self.status.timePassed = recoveredSessionStatus.timePassed
        self.status.timeStarted = recoveredSessionStatus.timeStarted
        logger:onSessionRecovered()
    else
        logger:start()
    end

    if self.status.state ~= SessionStatus.States.Paused then
        logger:loopCheckpointPosting()
    end
end

function Session.pause(self: Session)
    if self.status.state ~= SessionStatus.States.Ongoing then
        return
    end

    self.status:changeState(SessionStatus.States.Paused)
    self.logger:stopLoop()
    self.logger:pause()
end

function Session.resume(self: Session)
    if self.status.state ~= SessionStatus.States.Paused then
        return
    end

    self.status:changeState(SessionStatus.States.Ongoing)
    self.logger:resume()
    self.logger:loopCheckpointPosting()
end

function Session.close(self: Session)
    self.status:changeState(SessionStatus.States.Closed)
    self.logger:close()
end

---------------

return Session