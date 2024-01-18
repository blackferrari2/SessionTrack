--[[
    blackferrari2's Session Tracker

    Version 1.00
    17th January 2024

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

local toolbar = plugin:CreateToolbar("SessionTrack")

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

powerButton.Click:Connect(function()
    if currentSession then        
        changeIconSafely(powerButton, icons.power.on)
        changeIconSafely(pauseButton, icons.pause.unpaused)
        pauseButton.Enabled = false
        settingsButton.Enabled = true

        Info.addToTotalProjectTime(currentSession.status:getTimeElapsed())

        autosave:destroy()
        currentSession:close()
        currentSession = nil

        return
    end

    pauseButton.Enabled = true
    settingsButton.Enabled = false
    changeIconSafely(powerButton, icons.power.off)

    currentSession = Session.new()
    autosave = Autosave.new(plugin, Info.ProjectName)

    local logger = Logger.new(pluginSettingsRoot, currentSession.status)
    local recoveredSessionStatus = autosave:recover()

    currentSession:begin(logger, recoveredSessionStatus)
    autosave:loop(currentSession.status)
end)

--

pauseButton.Click:Connect(function()
    if not currentSession then
        return
    end

    if currentSession.status.state == SessionStatus.States.Paused then
        currentSession:resume()
        changeIconSafely(pauseButton, icons.pause.unpaused)
        return
    end

    currentSession:pause()
    changeIconSafely(pauseButton, icons.pause.paused)
end)

--

local function setupSettingsButtonEvents(modules)
    for _, module in pairs(modules) do
        local openScriptButton = scroll:FindFirstChild(module.Name)
    
        openScriptButton.Activated:Connect(function()
            plugin:OpenScript(module)
        end)
    end
end

settingsButton.Click:Connect(function()
    local modules = pluginSettingsRoot:GetChildren()

    updateSettingsWidget(modules)
    setupSettingsButtonEvents(modules)

    settingsWidget.Enabled = not settingsWidget.Enabled
end)

--

initializeButton.Click:Connect(function()
    if pluginSettingsRoot then
        return
    end

    settingsButton.Enabled = true
    initializeButton.Enabled = false

    pluginSettingsRoot = Settings.new()
    plugin:OpenScript(pluginSettingsRoot.Webhook)
end)
