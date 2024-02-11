--[[
    blackferrari2's Session Tracker

    Version 2.0
    10th February 2024

    SOURCE:
    https://github.com/blackferrari2/session-tracker
]]

assert(plugin, "SessionTrack must run as a plugin")

if game:GetService("RunService"):IsRunning() then
    return
end

local Session = require(script.Session)
local Settings = require(script.Settings)
local Icons = require(script.Icons)
local Logger = require(script.Session.Logger)
local SessionSave = require(script.Session.SessionSave)
local TotalProjectTime = require(script.Session.TotalProjectTime)
local SessionStatus = require(script.Session.SessionStatus)

local settings = Settings.get()
local Info = settings and require(settings.Info)

---------------

-- if the settings are wrong, abort plugin entirely

if settings then
    local success, errorMessage = Settings.assert(settings)

    if not success then
        local toolbar = plugin:CreateToolbar("BrokenSessionTrack")

        local viewAssertionFailPageButton = toolbar:CreateButton(
            "what happened??",
            "you messed up...",
            Icons.AssertionFailPage
        )

        viewAssertionFailPageButton.Click:Connect(function()
            plugin:OpenScript(script.FailedAssertionLandingPage)
        end)

        error(errorMessage)
    end
end

---------------

local toolbar = plugin:CreateToolbar("SessionTrack")

local powerButton = toolbar:CreateButton(
    "power",
    "turn bot on or off",
    Icons.Power.On
)

local pauseButton = toolbar:CreateButton(
    "pause",
    "pause or resume session",
    Icons.Pause.Unpaused
)

local settingsButton = toolbar:CreateButton(
    "settings",
    "open settings widget",
    Icons.Settings
)

local initializeButton = toolbar:CreateButton(
    "initialize",
    "create new settings",
    Icons.Initialize
)

local deleteProjectButton = toolbar:CreateButton(
    "delete",
    "delete your project",
    Icons.Delete
)

--

local settingsWidgetButtonHeight = 40
local settingsWidget = plugin:CreateDockWidgetPluginGui("SessionTrackSettings", DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    true,
    settingsWidgetButtonHeight * 5,
    settingsWidgetButtonHeight * 5,
    settingsWidgetButtonHeight * 5,
    settingsWidgetButtonHeight * 5
))

local deleteProjectPromptWidgetButtonHeight = 70
local deleteProjectPromptWidget = plugin:CreateDockWidgetPluginGui("SessionTrackDeleteProject", DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    true,
    400,
    400,
    400,
    400
))

--

local function toggleSessionButtons(offOrOn: boolean)
    powerButton.Enabled = offOrOn
    pauseButton.Enabled = offOrOn
end

---------------

-- setup the settings widget

settingsWidget.Title = "select what you wanna edit"

local scroll = Instance.new("ScrollingFrame")
Instance.new("UIListLayout", scroll)

scroll.Size = UDim2.fromScale(1, 1)
scroll.Position = UDim2.fromScale(0, 0)
scroll.BackgroundColor3 = Color3.new(0, 0, 0)
scroll.Parent = settingsWidget

-- setup project delete widget

deleteProjectPromptWidget.Title = "SessionTrack DELETE"

local warningLabel = Instance.new("TextLabel")

warningLabel.Text = "Are you sure you want to erase all your project data?"
warningLabel.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, deleteProjectPromptWidgetButtonHeight))
warningLabel.Position = UDim2.fromScale(0, 0)
warningLabel.BackgroundColor3 = Color3.new(0, 0, 0)
warningLabel.TextColor3 = Color3.new(1, 1, 1)
warningLabel.Parent = deleteProjectPromptWidget

local confirmButton = Instance.new("TextButton")

confirmButton.Text = "YES"
confirmButton.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, deleteProjectPromptWidgetButtonHeight))
confirmButton.Position = UDim2.new(UDim.new(0, 0), UDim.new(0, deleteProjectPromptWidgetButtonHeight * 2))
confirmButton.BackgroundColor3 = Color3.new(0, 0, 0)
confirmButton.TextColor3 = Color3.new(1.000000, 0.462745, 0.462745)
confirmButton.TextSize = deleteProjectPromptWidgetButtonHeight - 15
confirmButton.Font = Enum.Font.Arcade
confirmButton.Parent = deleteProjectPromptWidget

local rejectButton = Instance.new("TextButton")

rejectButton.Text = "NO"
rejectButton.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, deleteProjectPromptWidgetButtonHeight))
rejectButton.Position = UDim2.new(UDim.new(0, 0), UDim.new(0, deleteProjectPromptWidgetButtonHeight * 3))
rejectButton.BackgroundColor3 = Color3.new(0, 0, 0)
rejectButton.TextColor3 = Color3.new(0.462745, 1.000000, 0.552941)
rejectButton.TextSize = deleteProjectPromptWidgetButtonHeight - 15
rejectButton.Font = Enum.Font.Arcade
rejectButton.Parent = deleteProjectPromptWidget

-- configure initial button states

if settings then
    initializeButton.Enabled = false
    deleteProjectButton.Enabled = true
else
    settingsButton.Enabled = false
    powerButton.Enabled = false
    deleteProjectButton.Enabled = false
end

pauseButton.Enabled = false

-- if theres a recovered session detected, switch out the power button icon

if settings and SessionSave.recover(plugin, Info.ProjectName) then
    Icons.switch(powerButton, Icons.Power.Recover)
end

---------------

-- button handling

local totalProjectTime = settings and TotalProjectTime.new(plugin, Info.ProjectName, settings)
local save = settings and SessionSave.new(plugin, Info.ProjectName, 1)

local session
local logger

powerButton.Click:Connect(function()
    toggleSessionButtons(false)

    if session then
        Icons.switch(powerButton, Icons.Power.On)
        Icons.switch(pauseButton, Icons.Pause.Unpaused)
        
        session:close()        
        totalProjectTime:commit(totalProjectTime:get() + session.status:getTimeElapsed())
        session:destroy()
        logger:destroy()
        save:stopAutosaving()
        save:erase()

        session = nil
        logger = nil
        toggleSessionButtons(true)
        deleteProjectButton.Enabled = true

        return
    end

    Icons.switch(powerButton, Icons.Power.Off)
    deleteProjectButton.Enabled = false

    session = Session.new()
    logger = Logger.new(settings, session.status, totalProjectTime)

    local recoveredSessionStatus, timeSinceLastSave = SessionSave.recover(plugin, Info.ProjectName)

    if recoveredSessionStatus then
        session:startFromRecoveredSession(logger, recoveredSessionStatus, timeSinceLastSave)

        -- session recovered to paused state, change icons to reflect that
        if recoveredSessionStatus.state == SessionStatus.States.Paused then
            Icons.switch(pauseButton, Icons.Pause.Paused)
        end
    else
        session:start(logger)
    end

    save:startAutosaving(session)
    toggleSessionButtons(true)
end)

--

pauseButton.Click:Connect(function()
    if not session then
        return
    end

    toggleSessionButtons(false)

    if session.status.state == SessionStatus.States.Paused then
        Icons.switch(pauseButton, Icons.Pause.Unpaused)
        session:resume()
        toggleSessionButtons(true)
        return
    end

    Icons.switch(pauseButton, Icons.Pause.Paused)
    session:pause()
    toggleSessionButtons(true)
end)

--

local function createSettingsWidgetButtons(settings: Settings.Settings)
    for _, module in pairs(settings:GetChildren()) do
        local oldButton = scroll:FindFirstChild(module.Name)

        if oldButton then
            oldButton:Destroy()
        end

        local openScriptButton = Instance.new("TextButton")
    
        openScriptButton.Text = module.Name
        openScriptButton.Name = module.Name
        openScriptButton.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, settingsWidgetButtonHeight))
        openScriptButton.Font = Enum.Font.Arcade
        openScriptButton.TextSize = settingsWidgetButtonHeight - 15
        openScriptButton.TextStrokeTransparency = 0
        openScriptButton.TextColor3 = Color3.new(1, 1, 1)
        openScriptButton.BackgroundColor3 = Color3.new(0, 0, 0)
        openScriptButton.Parent = scroll
    end
end

local function setupSettingsWidgetButtonsEvents(settings: Settings.Settings)
    for _, module in pairs(settings:GetChildren()) do
        local openScriptButton = scroll:FindFirstChild(module.Name)
    
        openScriptButton.Activated:Connect(function()
            plugin:OpenScript(module)
            settingsWidget.Enabled = false
        end)
    end
end

settingsButton.Click:Connect(function()
    if not settings then
        return
    end

    createSettingsWidgetButtons(settings)
    setupSettingsWidgetButtonsEvents(settings)

    settingsWidget.Enabled = not settingsWidget.Enabled
end)

--

initializeButton.Click:Connect(function()
    if settings then
        return
    end

    settingsButton.Enabled = true
    initializeButton.Enabled = false
    deleteProjectButton.Enabled = true

    settings = Settings.new()
    plugin:OpenScript(settings.Info)
end)

--

deleteProjectButton.Click:Connect(function()
    if not settings then
        return
    end

    deleteProjectPromptWidget.Enabled = not deleteProjectPromptWidget.Enabled
end)

rejectButton.Activated:Connect(function()
    deleteProjectPromptWidget.Enabled = false
end)

confirmButton.Activated:Connect(function()
    if not settings then
        return
    end

    if session then
        return
    end

    deleteProjectPromptWidget.Enabled = false

    powerButton.Enabled = false
    pauseButton.Enabled = false
    initializeButton.Enabled = false
    settingsButton.Enabled = false
    deleteProjectButton.Enabled = false

    if totalProjectTime then
        totalProjectTime:erase()
    end

    if save then
        save:erase()
    end
    
    settings:Destroy()
    plugin:OpenScript(script.ProjectDeletedLandingPage)
end)

---------------