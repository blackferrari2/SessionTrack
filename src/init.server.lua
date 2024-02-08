--[[
    blackferrari2's Session Tracker

    Version 1.4
    8th February 2024

    SOURCE:
    https://github.com/blackferrari2/session-tracker
]]

assert(plugin, "SessionTrack must run as a plugin NOW")

if game:GetService("RunService"):IsRunning() then
    return
end

local Session = require(script.Session)
local SessionStatus = require(script.Session.SessionStatus)
local Logger = require(script.Session.Logger)
local Autosave = require(script.Session.Autosave)
local TotalTime = require(script.Session.TotalTime)
local Settings = require(script.Settings)
local Icons = require(script.Icons)

local pluginSettingsRoot = Settings.get()
local Info = pluginSettingsRoot and require(pluginSettingsRoot.Info)

---------------

if pluginSettingsRoot then
    local success, errorMessage = Settings.assert(pluginSettingsRoot)

    if not success then
        local toolbar = plugin:CreateToolbar("BrokenSessionTrack")

        local viewAssertionFailPageButton = toolbar:CreateButton(
            "what happened??",
            "you messed up...",
            Icons.AssertionFailPage
        )

        local function onViewPageClick()
            plugin:OpenScript(script.Settings.FailedAssertionLandingPage)
        end

        viewAssertionFailPageButton.Click:Connect(onViewPageClick)

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

--

local settingsButtonHeight = 40
local settingsWidget do
    local widgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        false,
        true,
        settingsButtonHeight * 5,
        settingsButtonHeight * 5,
        settingsButtonHeight * 5,
        settingsButtonHeight * 5
    )

    settingsWidget = plugin:CreateDockWidgetPluginGui("SessionTrackSettings", widgetInfo)
    settingsWidget.Title = "select what you wanna edit"
end

local scroll = Instance.new("ScrollingFrame")

scroll.Size = UDim2.fromScale(1, 1)
scroll.Position = UDim2.fromScale(0, 0)
scroll.BackgroundColor3 = Color3.new(0, 0, 0)
scroll.Parent = settingsWidget

local UIListLayout = Instance.new("UIListLayout")

UIListLayout.Parent = scroll

local function updateSettingsWidget(modules)
    for _, module in pairs(modules) do
        -- replace old button
        local oldButton = scroll:FindFirstChild(module.Name)
        
        if oldButton then
            oldButton:Destroy()
        end

        local openScriptButton = Instance.new("TextButton")

        openScriptButton.Text = module.Name
        openScriptButton.Name = module.Name
        openScriptButton.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, settingsButtonHeight))
        openScriptButton.Font = Enum.Font.Arcade
        openScriptButton.TextSize = settingsButtonHeight - 15
        openScriptButton.TextStrokeTransparency = 0
        openScriptButton.TextColor3 = Color3.new(1, 1, 1)
        openScriptButton.BackgroundColor3 = Color3.new(0, 0, 0)
        openScriptButton.Parent = scroll
    end
end

---------------

pauseButton.Enabled = false

if not pluginSettingsRoot then
    settingsButton.Enabled = false
    powerButton.Enabled = false
else
    initializeButton.Enabled = false
end

---------------

local currentSession
local autosave
local totalTime

function onPowerOnClick()
    Icons.changeIconSafely(powerButton, Icons.Power.Off)
    pauseButton.Enabled = true

    currentSession = Session.new()
    autosave = Autosave.new(plugin, Info.ProjectName)
    totalTime = TotalTime.new(plugin, Info.ProjectName, pluginSettingsRoot.Info)

    local recoveredSessionStatus = autosave:recover()
    local currentSessionStatus = currentSession.status
    local logger = Logger.new(pluginSettingsRoot, currentSessionStatus, totalTime)

    if recoveredSessionStatus and recoveredSessionStatus.state == SessionStatus.States.Paused then
        Icons.changeIconSafely(pauseButton, Icons.Pause.Paused)
    end

    currentSessionStatus.stateChanged:Connect(function()
        autosave:update(currentSessionStatus)
    end)

    currentSession:begin(logger, recoveredSessionStatus)
    autosave:loop(currentSessionStatus)
end

function onPowerOffClick()
    Icons.changeIconSafely(powerButton, Icons.Power.On)
    Icons.changeIconSafely(pauseButton, Icons.Pause.Unpaused)
    pauseButton.Enabled = false

    totalTime:update(currentSession.status:getTimeElapsed())
    autosave:erase()
    currentSession:close()
    currentSession = nil
end

powerButton.Click:Connect(function()
    powerButton.Enabled = false

    if currentSession then
        onPowerOffClick()
        powerButton.Enabled = true
        return
    end

    onPowerOnClick()
    powerButton.Enabled = true
end)

if pluginSettingsRoot and Autosave.new(plugin, Info.ProjectName):recover() then
    Icons.changeIconSafely(powerButton, Icons.Power.Recover)
end

--

function onPauseClick()
    currentSession:pause()
    Icons.changeIconSafely(pauseButton, Icons.Pause.Paused)
end

function onResumeClick()
    currentSession:resume()
    Icons.changeIconSafely(pauseButton, Icons.Pause.Unpaused)
end

pauseButton.Click:Connect(function()
    if not currentSession then
        return
    end

    pauseButton.Enabled = false

    if currentSession.status.state == SessionStatus.States.Paused then
        onResumeClick()
        pauseButton.Enabled = true
        return
    end

    onPauseClick()
    pauseButton.Enabled = true
end)

--

function setupSettingsButtonEvents(modules)
    for _, module in pairs(modules) do
        local openScriptButton = scroll:FindFirstChild(module.Name)
    
        openScriptButton.Activated:Connect(function()
            plugin:OpenScript(module)
        end)
    end
end

function onSettingsClick()
    local modules = pluginSettingsRoot:GetChildren()

    updateSettingsWidget(modules)
    setupSettingsButtonEvents(modules)

    settingsWidget.Enabled = not settingsWidget.Enabled
end

settingsButton.Click:Connect(onSettingsClick)

--

function onInitializeclick()
    settingsButton.Enabled = true
    initializeButton.Enabled = false

    pluginSettingsRoot = Settings.new()
    plugin:OpenScript(pluginSettingsRoot.Info)
end

initializeButton.Click:Connect(function()
    if pluginSettingsRoot then
        return
    end

    onInitializeclick()
end)
