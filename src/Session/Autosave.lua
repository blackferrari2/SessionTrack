local SessionStatus = require(script.Parent.SessionStatus)

local Autosave = {
    Key = "SessionTrackAutosave%s",
    IntervalSeconds = 1,
}

Autosave.__index = Autosave

---------------

type self = {
    plugin: Plugin,
    projectName: string,
    loopThread: thread,
}

export type Autosave = typeof(setmetatable({} :: self, Autosave))

-------------

local function getKey(projectName)
    return string.format(Autosave.Key, projectName)
end

-------------

function Autosave.new(plugin: Plugin, projectName: string): Autosave
    local self = {
        plugin = plugin,
        projectName = projectName,
        loopThread = nil,
    }

    setmetatable(self, Autosave)

    return self
end

function Autosave.update(self: Autosave, sessionStatus: SessionStatus.SessionStatus)
    self.plugin:SetSetting(getKey(self.projectName), sessionStatus)
end

function Autosave.erase(self: Autosave)
    self.plugin:SetSetting(getKey(self.projectName), nil)
end

function Autosave.recover(self: Autosave): SessionStatus.SessionStatus?
    return self.plugin:GetSetting(getKey(self.projectName))
end

function Autosave.loop(self: Autosave, sessionStatus: SessionStatus.SessionStatus)
    if self.loopThread then
        return
    end

    self.loopThread = task.spawn(function()
        self:update(sessionStatus)
    end)
end

function Autosave.stop(self: Autosave)
    if not self.loopThread then
        return
    end

    task.cancel(self.loopThread)
end

function Autosave.destroy(self: Autosave)
    self:stop()
    self:erase()

    local setmetatable: any = setmetatable
    setmetatable(self, nil)
end

---------------

return Autosave