local ServerStorage = game:GetService("ServerStorage")

local baseModules = script.Modules

local Settings = {
    Version = 1,
    InstanceName = "SessionTrack.PluginSettings",
    OutdatedInstanceName = "[OUTDATED] SessionTrack.PluginSettings",
    VersionAttribute = "Version",
}

---------------

local WARN_NO_SETTINGS = "[SessionTrack]: couldnt find a settings folder. so one was created for you"
local WARN_OUTDATED_SETTINGS = "[SessionTrack]: your settings are outdated. please migrate your stuff over to the new copy. the old copy was renamed and you can still view it - its in ServerStorage"

---------------

function Settings.new(): Folder
    local clone = baseModules:Clone()

    clone.Name = Settings.InstanceName
    clone:SetAttribute(Settings.VersionAttribute, Settings.Version)
    clone.Parent = ServerStorage

    return clone
end

function Settings.get(): Folder?
    local modules = ServerStorage:FindFirstChild(Settings.InstanceName)

    if modules then
        if modules:GetAttribute(Settings.VersionAttribute) ~= Settings.Version then
            warn(WARN_OUTDATED_SETTINGS)

            modules.Name = Settings.OutdatedInstanceName

            return nil
        end

        return modules
    end

    warn(WARN_NO_SETTINGS)

    return nil
end

---------------

return Settings