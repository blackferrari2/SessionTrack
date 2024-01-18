--[[
    blackferrari2's Session Tracker

    Version 2.00
    18th January 2024

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
local Settings = require(script.Settings)

local pluginSettingsRoot = Settings.get()
local Info = pluginSettingsRoot and require(pluginSettingsRoot.Info)

---------------

local WARN_LOGGER_ERROR = "[SessionTrack]: session aborted because of an error - %s"

--

local toolbar = plugin:CreateToolbar("SessionTrack")

local icons = {
    power = {
        on = "http://www.roblox.com/asset/?id=16008923978",
        off = "http://www.roblox.com/asset/?id=16008923312",
        recover = "http://www.roblox.com/asset/?id=16025418149",
    },

    pause = {
        paused = "http://www.roblox.com/asset/?id=16008921548",
        unpaused = "http://www.roblox.com/asset/?id=16008922394",
    },

    settings = "http://www.roblox.com/asset/?id=16008920257",
    initialize = "http://www.roblox.com/asset/?id=16008985266"
}

local powerButton = toolbar:CreateButton(
    "power",
    "turn bot on or off",
    icons.power.on
)

local pauseButton = toolbar:CreateButton(
    "pause",
    "pause or resume session",
    icons.pause.unpaused
)

local settingsButton = toolbar:CreateButton(
    "settings",
    "open settings widget",
    icons.settings
)

local initializeButton = toolbar:CreateButton(
    "initialize",
    "create new settings",
    icons.initialize
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

--

-- theres this weird bug where if you change the .Icon id to the same one its already using, the icon turns invisible
local function changeIconSafely(of, to)
    if of.Icon == to then
        return
    end

    of.Icon = to
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

function onPowerOnClick()
    pauseButton.Enabled = true
    settingsButton.Enabled = false

    currentSession = Session.new()
    autosave = Autosave.new(plugin, Info.ProjectName)

    local currentSessionStatus = currentSession.status
    local recoveredSessionStatus = autosave:recover()
    local logger = Logger.new(pluginSettingsRoot, currentSessionStatus)

    if recoveredSessionStatus and recoveredSessionStatus.state == SessionStatus.States.Paused then
        changeIconSafely(pauseButton, icons.pause.paused)
    end

    currentSessionStatus.stateChanged:Connect(function()
        autosave:update(currentSessionStatus)
    end)

    local success, errorMessage = pcall(function()
        currentSession:begin(logger, recoveredSessionStatus)
    end)

    if success then
        autosave:loop(currentSessionStatus)
        changeIconSafely(powerButton, icons.power.off)
    else
        warn(string.format(WARN_LOGGER_ERROR, errorMessage))
        onPowerOffClick()
    end
end

function onPowerOffClick()
    changeIconSafely(powerButton, icons.power.on)
    changeIconSafely(pauseButton, icons.pause.unpaused)
    pauseButton.Enabled = false
    settingsButton.Enabled = true

    Info.addToTotalProjectTime(currentSession.status:getTimeElapsed())
    autosave:erase()

    pcall(function()
        currentSession:close()
    end)

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
    changeIconSafely(powerButton, icons.power.recover)
end

--

function onPauseClick()
    currentSession:pause()
    changeIconSafely(pauseButton, icons.pause.paused)
end

function onResumeClick()
    currentSession:resume()
    changeIconSafely(pauseButton, icons.pause.unpaused)
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
    plugin:OpenScript(pluginSettingsRoot.Webhook)
end

initializeButton.Click:Connect(function()
    if pluginSettingsRoot then
        return
    end

    onInitializeclick()
end)
