local ServerStorage = game:GetService("ServerStorage")

local baseModules = script.Modules

local Messages = require(baseModules.Messages)
local Checkpoints = require(baseModules.Checkpoints)
local Info = require(baseModules.Info)
local Webhook = require(baseModules.Webhook)

local Settings = {
    Version = 3,
    InstanceName = "SessionTrack.PluginSettings",
    OutdatedInstanceName = "[OUTDATED] SessionTrack.PluginSettings",
    VersionAttribute = "Version",
}

---------------

type self = {
    Messages: Messages.Messages,
    Checkpoints: Checkpoints.Checkpoints,
    Info: Info.Info,
    Webhook: Webhook.Webhook,
}

export type Settings = typeof(setmetatable({} :: self, Settings))

---------------

local WARN_OUTDATED_SETTINGS = "[SessionTrack]: your settings are outdated. please migrate your stuff over to a new copy. the old copy was renamed and you can still view it - its in ServerStorage"

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

    return nil
end

---------------

return Settings