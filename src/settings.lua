local VibeUI, Tabs = ...

-- Any error in this file kills core.lua before Jnkie runs the game script (blank Game tab),
-- and some executors (e.g. Opiumware) throw on restricted services - so fetch them safely.
local function safeService(name)
    local ok, svc = pcall(game.GetService, game, name)
    return ok and svc or nil
end

local TeleportService = safeService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = safeService("CoreGui")
local GuiService = safeService("GuiService")
local VirtualUser = safeService("VirtualUser")
local VirtualInputManager = safeService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local getgenv = getgenv or function() return _G end
local env = getgenv()

if env.AutoRejoin == nil then env.AutoRejoin = false end
if env.AutoExecute == nil then env.AutoExecute = false end
if env.AntiAFK == nil then env.AntiAFK = true end

-- Clean up previous settings connections so re-executing never stacks listeners
if env.VibeUI_SettingsConnections then
    for _, conn in ipairs(env.VibeUI_SettingsConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
end
local settingsConnections = {}
env.VibeUI_SettingsConnections = settingsConnections

local function trackSettingConn(conn)
    if conn then
        table.insert(settingsConnections, conn)
    end
    return conn
end

local queue = queue_on_teleport
    or queueonteleport
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)
    or (KRNL_LOADED and queue_on_teleport)
local hasQueuedThisSession = false

local function QueueLoader()
    if not queue or hasQueuedThisSession then return end
    if not env.AutoExecute then return end

    hasQueuedThisSession = true
    local scriptToQueue = string.format([[
        local env = (getgenv and getgenv()) or _G
        env.AutoRejoin = %s
        env.AutoExecute = %s
        env.AntiAFK = %s
        if env.AutoExecute then
            loadstring(game:HttpGet("https://loadstring.net/raw/mmao8nJZRo"))()
        end
    ]], tostring(env.AutoRejoin), tostring(env.AutoExecute), tostring(env.AntiAFK))

    pcall(queue, scriptToQueue)
end

local function setNativeIdleConnections(enabled)
    local getconns = getconnections or get_signal_cons
    if not getconns or not LocalPlayer then return end

    pcall(function()
        for _, conn in ipairs(getconns(LocalPlayer.Idled)) do
            if enabled then
                if conn.Enable then conn:Enable() end
            else
                if conn.Disable then
                    conn:Disable()
                elseif conn.Disconnect then
                    conn:Disconnect()
                end
            end
        end
    end)
end

local HubSection = Tabs.Main:Section({ Name = "Hub Settings", Side = 2 })
HubSection:Toggle({
    Name = "Auto Rejoin",
    Flag = "AutoRejoin",
    Default = env.AutoRejoin,
    Info = "Automatically rejoins if disconnected",
    InfoType = "info",
    Callback = function(Value)
        env.AutoRejoin = Value
    end
})

HubSection:Toggle({
    Name = "Auto Execute",
    Flag = "AutoExecute",
    Default = env.AutoExecute,
    Info = "Automatically re-executes script on teleport - Does carry the risk of a kick due to key system!",
    InfoType = "info",
    Callback = function(Value)
        env.AutoExecute = Value
        if not Value then
            hasQueuedThisSession = false
        end
    end
})

HubSection:Toggle({
    Name = "Anti-AFK",
    Flag = "AntiAFK",
    Default = env.AntiAFK,
    Info = "Prevents being kicked for idling after 20 minutes",
    InfoType = "info",
    Callback = function(Value)
        env.AntiAFK = Value
        setNativeIdleConnections(not Value)
    end
})

if env.AntiAFK then
    setNativeIdleConnections(false)
end

pcall(function()
    trackSettingConn(LocalPlayer.Idled:Connect(function()
        if not env.AntiAFK then return end

        pcall(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero, workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
            elseif VirtualInputManager then
                VirtualInputManager:SendMouseMoveEvent(1, 1, game)
                task.wait(0.05)
                VirtualInputManager:SendMouseMoveEvent(0, 0, game)
            end
        end)
    end))
end)

local isRejoining = false

local function Rejoin()
    if not env.AutoRejoin or isRejoining then return end
    isRejoining = true

    if env.AutoExecute then
        QueueLoader()
    end

    task.wait(2)
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
    task.wait(5)
    isRejoining = false
end

if GuiService then
    trackSettingConn(GuiService.ErrorMessageChanged:Connect(function(errorMessage)
        if env.AutoRejoin and errorMessage and errorMessage ~= "" then
            task.spawn(Rejoin)
        end
    end))
end

task.spawn(function()
    if not CoreGui then return end
    local PromptGui = CoreGui:WaitForChild("RobloxPromptGui", 10)
    if not PromptGui then return end

    local PromptOverlay = PromptGui:WaitForChild("promptOverlay", 10)
    if not PromptOverlay then return end

    trackSettingConn(PromptOverlay.ChildAdded:Connect(function(child)
        if env.AutoRejoin and child.Name == "ErrorPrompt" then
            task.spawn(Rejoin)
        end
    end))

    if env.AutoRejoin and PromptOverlay:FindFirstChild("ErrorPrompt") then
        task.spawn(Rejoin)
    end
end)

pcall(function()
    trackSettingConn(LocalPlayer.OnTeleport:Connect(function(teleportState)
        if not env.AutoExecute then return end
        if teleportState == Enum.TeleportState.Started or teleportState == Enum.TeleportState.InProgress or teleportState == nil then
            QueueLoader()
        end
    end))
end)