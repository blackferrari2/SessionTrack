local SessionStatus = {
    States = {
        DidntStart = "DidntStart",
        Ongoing = "Ongoing",
        Paused = "Paused",
        Closed = "Closed",
    },
}

SessionStatus.__index = SessionStatus

---------------

type self = {
    state: State,
    timePassed: number,
    timeStarted: number,
}

export type State = "DidntStart" | "Ongoing" | "Paused" | "Closed"
export type SessionStatus = typeof(setmetatable({} :: self, SessionStatus))

-------------

function SessionStatus.new(): SessionStatus
    local self = {
        state = SessionStatus.States.DidntStart,
        timePassed = 0,
        timeStarted = nil,
    }

    setmetatable(self, SessionStatus)

    return self
end

function SessionStatus.changeState(self: SessionStatus, to: State)
    if to == SessionStatus.States.Ongoing then
        self.timeStarted = tick()
    end

    if to == SessionStatus.States.Paused or to == SessionStatus.States.Closed then
        self.timePassed = self:getTimeElapsed()
    end

    self.state = to
end

function SessionStatus.getTimeElapsed(self: SessionStatus)
    if self.state == SessionStatus.States.Paused or self.state == SessionStatus.States.Closed then
        return self.timePassed
    end

    local timeElapsedSoFar = tick() - self.timeStarted

    return self.timePassed + timeElapsedSoFar
end

---------------

return SessionStatus