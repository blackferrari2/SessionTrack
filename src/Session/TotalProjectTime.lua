local TotalProjectTime = {
    Key = "SessionTrackTotalTime%s",
    FailsafeAttribute = "TotalProjectTime",
}

TotalProjectTime.__index = TotalProjectTime

---------------

type self = {
    plugin: Plugin,
    projectName: string,
    failsafe: Instance,
}

export type TotalProjectTime = typeof(setmetatable({} :: self, TotalProjectTime))

-------------

local function getKey(projectName)
    return string.format(TotalProjectTime.Key, projectName)
end

-------------

function TotalProjectTime.new(plugin: Plugin, projectName: string, failsafe: Instance): TotalProjectTime
    local self = {
        plugin = plugin,
        projectName = projectName,
        failsafe = failsafe,
    }

    setmetatable(self, TotalProjectTime)

    return self
end

function TotalProjectTime.commit(self: TotalProjectTime, newTime: number)
    self.failsafe:SetAttribute(TotalProjectTime.FailsafeAttribute, newTime)
    self.plugin:SetSetting(getKey(self.projectName), newTime)
end

function TotalProjectTime.erase(self: TotalProjectTime)
    self.failsafe:SetAttribute(TotalProjectTime.FailsafeAttribute, nil)
    self.plugin:SetSetting(getKey(self.projectName), nil)
end

function TotalProjectTime.get(self: TotalProjectTime)
    local total = self.plugin:GetSetting(getKey(self.projectName))

    if not total then
        local recoveredTotalTime = self.failsafe:GetAttribute(TotalProjectTime.FailsafeAttribute)

        total = recoveredTotalTime or 0
    end

    return total
end

---------------

return TotalProjectTime