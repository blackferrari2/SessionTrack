--[[
    blackferrari2's Session Tracker

    Version 0.00
    16th January 2024

        TBA:
            - better way to handle settings
            - safety checks for the settings
            - video tutorial for the plugin idk

    SOURCE:
    https://github.com/blackferrari2/session-tracker
]]

assert(plugin, "sessiontrack must run as a plugin")

if game:GetService("RunService"):IsRunning() then
    return
end

local Settings = require(script.Settings)
local Session = require(script.Session)

local currentSettings = Settings.get() or Settings.new()
local Messages = require(currentSettings.Messages)
local Checkpoints = require(currentSettings.Checkpoints)
local Logger = require(currentSettings.Logger)
local Info = require(currentSettings.Info)

---------------

local toolbar = plugin:CreateToolbar("SessionTrack")

local settingsButtonHeight = 40
local settingsWidget do
    local widgetSize = settingsButtonHeight * #currentSettings:GetChildren()

    local widgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        false,
        false,
        widgetSize,
        widgetSize,
        widgetSize,
        widgetSize
    )

    settingsWidget = plugin:CreateDockWidgetPluginGui("SessionTrackSettings", widgetInfo)
end

local icons = {
    power = {
        on = "http://www.roblox.com/asset/?id=16008923978",
        off = "http://www.roblox.com/asset/?id=16008923312",
    },

    pause = {
        paused = "http://www.roblox.com/asset/?id=16008921548",
        unpaused = "http://www.roblox.com/asset/?id=16008922394",
    },

    settings = "http://www.roblox.com/asset/?id=16008920257",
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

--

-- theres this weird bug where if you change the .Icon id to the same one its already using, the icon turns invisible
local function changeIconSafely(of, to)
    if of.Icon == to then
        return
    end

    of.Icon = to
end

---------------

settingsWidget.Title = "select what you wanna edit"

local scroll = Instance.new("ScrollingFrame")

scroll.Size = UDim2.fromScale(1, 1)
scroll.Position = UDim2.fromScale(0, 0)
scroll.BackgroundColor3 = Color3.new(0, 0, 0)
scroll.Parent = settingsWidget

local UIListLayout = Instance.new("UIListLayout")

UIListLayout.Parent = scroll

for _, module in pairs(currentSettings:GetChildren()) do
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

pauseButton.Enabled = false

---------------

local currentSession

-- this stuff is for when studio abruplty closes. when you open studio again, itll recover the session time.
local activeSessionKey = "SESSIONTRACKER_SESSIONTIME_" .. Info.ProjectName
local autosaveIntervalSeconds = 1
local autosaveThread

powerButton.Click:Connect(function()
    if currentSession then
        Info.addToTotalProjectTime(currentSession:getTimeElapsed())
        
        currentSession:close()
        currentSession = nil

        task.cancel(autosaveThread)
        plugin:SetSetting(activeSessionKey, nil)

        changeIconSafely(powerButton, icons.power.on)
        changeIconSafely(pauseButton, icons.pause.unpaused)
        pauseButton.Enabled = false

        return
    end
    
    local recoveredSessionStartTime = plugin:GetSetting(activeSessionKey)
    local ourAwesomeLogger = Logger.new(Messages, Checkpoints)

    currentSession = Session.begin(ourAwesomeLogger, recoveredSessionStartTime)
    autosaveThread = task.spawn(function()
        while task.wait(autosaveIntervalSeconds) do
            plugin:SetSetting(activeSessionKey, currentSession.timeStarted)
        end
    end)

    pauseButton.Enabled = true
    changeIconSafely(powerButton, icons.power.off)
end)

--

pauseButton.Click:Connect(function()
    if not currentSession then
        return
    end

    if currentSession.status == Session.Statuses.Paused then
        currentSession:resume()
        changeIconSafely(pauseButton, icons.pause.unpaused)
        return
    end

    currentSession:pause()
    changeIconSafely(pauseButton, icons.pause.paused)
end)

--

settingsButton.Click:Connect(function()
    settingsWidget.Enabled = not settingsWidget.Enabled
end)

for _, module in pairs(currentSettings:GetChildren()) do
    local openScriptButton = scroll:FindFirstChild(module.Name)

    openScriptButton.Activated:Connect(function()
        plugin:OpenScript(module)
    end)
end