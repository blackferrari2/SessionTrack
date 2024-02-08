local ServerStorage = game:GetService("ServerStorage")

local baseModules = script.Modules
local assertions = script.Assertions

local Messages = require(baseModules.Messages)
local Checkpoints = require(baseModules.Checkpoints)
local Info = require(baseModules.Info)

local Settings = {
    Version = 2,
    InstanceName = "SessionTrack.PluginSettings",
    OutdatedInstanceName = "[OUTDATED] SessionTrack.PluginSettings",
    VersionAttribute = "Version",
}

---------------

export type Settings = Folder & {
    Messages: Messages.Messages,
    Checkpoints: Checkpoints.Checkpoints,
    Info: Info.Info,
}

---------------

local PRINT_NEW_SETTINGS = "[SessionTrack]: created new settings folder!"
local WARN_OUTDATED_SETTINGS = "[SessionTrack]: your settings are outdated. please migrate your stuff over to a new copy. the old copy was renamed and you can still view it - its in ServerStorage"
local ASSERTFAIL_INVALID_INSTANCE = "[SessionTrack]: %s found in settings folder. ModuleScripts ONLY please"
local ASSERTFAIL_INVALID_NAME = "[SessionTrack]: the module name of %s is invalid. Please change it back to its original name (either that or its not a module found in the original settings.)"
local ASSERTFAIL_CANT_LOAD_MODULE = "[SessionTrack]: couldnt load settings module %s. %s"

---------------

function Settings.new(): Folder
    local clone = baseModules:Clone()

    clone.Name = Settings.InstanceName
    clone:SetAttribute(Settings.VersionAttribute, Settings.Version)
    clone.Parent = ServerStorage

    print(PRINT_NEW_SETTINGS)

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

function Settings.assert(root: Settings): (boolean, string?)
    for _, module in pairs(root:GetChildren()) do
        if module.ClassName ~= "ModuleScript" then
            return false, string.format(ASSERTFAIL_INVALID_INSTANCE, module.ClassName)
        end

        local assertion = assertions:FindFirstChild(module.Name)

        if not assertion then
            return false, string.format(ASSERTFAIL_INVALID_NAME, module.Name)
        end

        local loadedModule
        local _, errorMessage = pcall(function() 
            loadedModule = require(module)
        end)

        if errorMessage then
            return false, string.format(ASSERTFAIL_CANT_LOAD_MODULE, module.Name, errorMessage)
        end

        assertion = require(assertion)

        local moduleChecksPassed, moduleErrorMessage = assertion.run(loadedModule)

        if not moduleChecksPassed then
            return moduleChecksPassed, moduleErrorMessage
        end
    end

    return true
end

---------------

return Settings