local TotalTime = {
    Key = "SessionTrackTotalTime%s",
    FallbackTotalTimeAttribute = "TotalProjectTime",
}

TotalTime.__index = TotalTime

---------------

type self = {
    plugin: Plugin,
    projectName: string,
    fallback: Instance,
}

export type TotalTime = typeof(setmetatable({} :: self, TotalTime))

-------------

local function getKey(projectName)
    return string.format(TotalTime.Key, projectName)
end

-------------

function TotalTime.new(plugin: Plugin, projectName: string, fallback: Instance): TotalTime
    local self = {
        plugin = plugin,
        projectName = projectName,
        fallback = fallback,
    }

    setmetatable(self, TotalTime)

    return self
end

function TotalTime.update(self: TotalTime, sessionTime: number)
    local total = self:get() + sessionTime

    self.fallback:SetAttribute(TotalTime.FallbackTotalTimeAttribute, total)
    self.plugin:SetSetting(getKey(self.projectName), total)
end

function TotalTime.get(self: TotalTime)
    local elapsed = self.plugin:GetSetting(getKey(self.projectName))

    if not elapsed then
        local recoveredTotalTime = self.fallback:GetAttribute(TotalTime.FallbackTotalTimeAttribute)

        elapsed = recoveredTotalTime or 0
    end

    return elapsed
end

---------------

return TotalTime