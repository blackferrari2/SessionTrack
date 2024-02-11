local Session = require(script.Parent)
local SessionStatus = require(script.Parent.SessionStatus)

local SessionSave = {
    Key = "SessionTrackAutosave%s",
}

SessionSave.__index = SessionSave

---------------

type self = {
    plugin: Plugin,
    projectName: string,
    intervalSeconds: number,
    latestSessionStatus: SessionStatus.SessionStatus?,
    latestCommitTick: number?,
    autosaveThread: thread?,
}

export type SessionSave = typeof(setmetatable({} :: self, SessionSave))

-------------

local function getKey(projectName)
    return string.format(SessionSave.Key, projectName)
end

-------------

function SessionSave.new(plugin: Plugin, projectName: string, intervalSeconds: number?): SessionSave
    local self = {
        plugin = plugin,
        projectName = projectName,
        intervalSeconds = intervalSeconds or 5,
    }

    setmetatable(self, SessionSave)

    return self
end

function SessionSave.recover(plugin: Plugin, projectName: string): (SessionStatus.SessionStatus?, number?)
    local recoveredSave = plugin:GetSetting(getKey(projectName))

    if not recoveredSave then
        return
    end

    -- plugin:GetSetting() doesnt save the metatables so we need to put them back
    setmetatable(recoveredSave, SessionSave)
    setmetatable(recoveredSave.latestSessionStatus, SessionStatus)

    return recoveredSave.latestSessionStatus, recoveredSave:getTimeSinceLastSave()
end

function SessionSave.getTimeSinceLastSave(self: SessionSave): number
    if not self.latestCommitTick then
        return 0
    end

    return tick() - self.latestCommitTick
end

function SessionSave.commit(self: SessionSave, status: SessionStatus.SessionStatus)
    self.latestSessionStatus = status:clone()
    self.latestCommitTick = tick()
    self.plugin:SetSetting(getKey(self.projectName), self)
end

function SessionSave.erase(self: SessionSave)
    self.latestSessionStatus = nil
    self.latestCommitTick = nil
    self.plugin:SetSetting(getKey(self.projectName), nil)
end

function SessionSave.startAutosaving(self: SessionSave, session: Session.Session)
    if self.autosaveThread then
        return
    end

    self.autosaveThread = task.spawn(function()
        self:commit(session.status)

        while task.wait(self.intervalSeconds) do
            self:commit(session.status)
        end
    end)
end

function SessionSave.stopAutosaving(self: SessionSave)
    if not self.autosaveThread then
        return
    end

    task.cancel(self.autosaveThread)
    self.autosaveThread = nil
end

function SessionSave.destroy(self: SessionSave)
    self:stopAutosaving()
    self:erase()

    local setmetatable: any = setmetatable
    setmetatable(self, nil)
end

---------------

return SessionSave