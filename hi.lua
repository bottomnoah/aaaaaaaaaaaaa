-- // Library Imports \\
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bottomnoah/UI/refs/heads/main/cola.lua"))()
local drawhelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/bottomnoah/UI/refs/heads/main/drawing"))() -- to the community: use drawing.new instead of Drawing.new so exploits like Swift wont shit itself
local Wait = Library.subs.Wait

-- // Services \\
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
-- // Global Variables \\

local lastJumpTime = 0
local jumpCooldown = 0.8125

if _G.ScriptIsRunning then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script Already Running",
        Text = "The script is already executing. Please do not attempt to run it again.",
        Duration = 5
    })
    return
end
_G.ScriptIsRunning = true

-- // Settings Configuration \\
local Settings = {
    Aimbot = {
        Enabled = false,
        HitPart = "Head",
        WallCheck = false,
        AutoTargetSwitch = false,
        MaxDistance = { Enabled = false, Value = 500 },
        Easing = { Strength = 0.1, Sensitivity = Instance.new("NumberValue") }
    },
    ESP = {
        Enabled = false,
        MaxDistance = { Enabled = false, Value = 500 },
        VisibilityCheck = false,
        UseFOV = false,
        Features = {
            Box = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            Tracer = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            DistanceText = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            Name = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            HeadDot = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }
        }
    },
    FOV = {
        Enabled = false,
        FollowGun = false,
        Radius = 50,
        Circle = drawing.new("Circle"),
        OutlineCircle = drawing.new("Circle"),
        Filled = false,
        FillColor = Color3.fromRGB(0, 0, 0),
        FillTransparency = 0.2,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 1
    },
    Chams = {
        Enabled = false,
        TeamCheck = true,
        Teammates = false,
        Fill = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5 },
        Outline = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0 }
    },
    Player = {
        WalkSpeed = 0,
        JumpPower = 30,
        JumpDelayBypass = false
    },
    Misc = {
        Textures = false,
        VotekickRejoiner = false,
        Optimized = false
    },
    Player = {
        Bhop = { Enabled = false }
    },
    Crosshair = {
        Enabled = false,
        Size = 10,
        Thickness = 1,
        Gap = 5,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Dot = false,
        TStyle = "Default", -- "Default" or "Plus"
        Drawings = {
            Line1 = drawing.new("Line"),
            Line2 = drawing.new("Line"),
            Line3 = drawing.new("Line"),
            Line4 = drawing.new("Line"),
            CenterDot = drawing.new("Circle")
        }
    }
}

-- // Initialize Crosshair \\
local function initializeCrosshair()
    for _, drawing in pairs(Settings.Crosshair.Drawings) do
        drawing.Visible = false
    end
end

local function updateCrosshair()
    if not Settings.Crosshair.Enabled then return end
    
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local size = Settings.Crosshair.Size
    local gap = Settings.Crosshair.Gap
    local thickness = Settings.Crosshair.Thickness
    local color = Settings.Crosshair.Color
    local transparency = Settings.Crosshair.Transparency
    
    if Settings.Crosshair.TStyle == "Default" then
        -- Top line
        Settings.Crosshair.Drawings.Line1.Visible = true
        Settings.Crosshair.Drawings.Line1.From = Vector2.new(centerX, centerY - gap - size)
        Settings.Crosshair.Drawings.Line1.To = Vector2.new(centerX, centerY - gap)
        Settings.Crosshair.Drawings.Line1.Color = color
        Settings.Crosshair.Drawings.Line1.Thickness = thickness
        Settings.Crosshair.Drawings.Line1.Transparency = transparency
        
        -- Bottom line
        Settings.Crosshair.Drawings.Line2.Visible = true
        Settings.Crosshair.Drawings.Line2.From = Vector2.new(centerX, centerY + gap)
        Settings.Crosshair.Drawings.Line2.To = Vector2.new(centerX, centerY + gap + size)
        Settings.Crosshair.Drawings.Line2.Color = color
        Settings.Crosshair.Drawings.Line2.Thickness = thickness
        Settings.Crosshair.Drawings.Line2.Transparency = transparency
        
        -- Left line
        Settings.Crosshair.Drawings.Line3.Visible = true
        Settings.Crosshair.Drawings.Line3.From = Vector2.new(centerX - gap - size, centerY)
        Settings.Crosshair.Drawings.Line3.To = Vector2.new(centerX - gap, centerY)
        Settings.Crosshair.Drawings.Line3.Color = color
        Settings.Crosshair.Drawings.Line3.Thickness = thickness
        Settings.Crosshair.Drawings.Line3.Transparency = transparency
        
        -- Right line
        Settings.Crosshair.Drawings.Line4.Visible = true
        Settings.Crosshair.Drawings.Line4.From = Vector2.new(centerX + gap, centerY)
        Settings.Crosshair.Drawings.Line4.To = Vector2.new(centerX + gap + size, centerY)
        Settings.Crosshair.Drawings.Line4.Color = color
        Settings.Crosshair.Drawings.Line4.Thickness = thickness
        Settings.Crosshair.Drawings.Line4.Transparency = transparency
        
        -- Center dot
        Settings.Crosshair.Drawings.CenterDot.Visible = Settings.Crosshair.Dot
        Settings.Crosshair.Drawings.CenterDot.Position = Vector2.new(centerX, centerY)
        Settings.Crosshair.Drawings.CenterDot.Radius = thickness
        Settings.Crosshair.Drawings.CenterDot.Color = color
        Settings.Crosshair.Drawings.CenterDot.Transparency = transparency
        Settings.Crosshair.Drawings.CenterDot.Filled = true
    else -- "Plus" style
        -- Horizontal line
        Settings.Crosshair.Drawings.Line1.Visible = true
        Settings.Crosshair.Drawings.Line1.From = Vector2.new(centerX - size - gap, centerY)
        Settings.Crosshair.Drawings.Line1.To = Vector2.new(centerX + size + gap, centerY)
        Settings.Crosshair.Drawings.Line1.Color = color
        Settings.Crosshair.Drawings.Line1.Thickness = thickness
        Settings.Crosshair.Drawings.Line1.Transparency = transparency
        
        -- Vertical line
        Settings.Crosshair.Drawings.Line2.Visible = true
        Settings.Crosshair.Drawings.Line2.From = Vector2.new(centerX, centerY - size - gap)
        Settings.Crosshair.Drawings.Line2.To = Vector2.new(centerX, centerY + size + gap)
        Settings.Crosshair.Drawings.Line2.Color = color
        Settings.Crosshair.Drawings.Line2.Thickness = thickness
        Settings.Crosshair.Drawings.Line2.Transparency = transparency
        
        -- Hide unused lines
        Settings.Crosshair.Drawings.Line3.Visible = false
        Settings.Crosshair.Drawings.Line4.Visible = false
        
        -- Center dot (optional)
        Settings.Crosshair.Drawings.CenterDot.Visible = Settings.Crosshair.Dot
        Settings.Crosshair.Drawings.CenterDot.Position = Vector2.new(centerX, centerY)
        Settings.Crosshair.Drawings.CenterDot.Radius = thickness
        Settings.Crosshair.Drawings.CenterDot.Color = color
        Settings.Crosshair.Drawings.CenterDot.Transparency = transparency
        Settings.Crosshair.Drawings.CenterDot.Filled = true
    end
end

initializeCrosshair()




-- // FOV Circle Setup \\
Settings.FOV.Circle.Visible = false
Settings.FOV.Circle.Filled = Settings.FOV.Filled
Settings.FOV.Circle.Color = Settings.FOV.FillColor
Settings.FOV.Circle.Transparency = Settings.FOV.FillTransparency
Settings.FOV.Circle.Thickness = 0 
Settings.FOV.Circle.Radius = Settings.FOV.Radius
Settings.FOV.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
Settings.Aimbot.Easing.Sensitivity.Value = Settings.Aimbot.Easing.Strength


Settings.FOV.OutlineCircle.Filled = false
Settings.FOV.OutlineCircle.Color = Settings.FOV.OutlineColor
Settings.FOV.OutlineCircle.Transparency = Settings.FOV.OutlineTransparency
Settings.FOV.OutlineCircle.Thickness = 1
Settings.FOV.OutlineCircle.Radius = Settings.FOV.Radius
Settings.FOV.OutlineCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
Settings.FOV.OutlineCircle.Visible = Settings.FOV.Enabled

-- // State Management \\
local State = {
    IsRightClickHeld = false,
    TargetPart = nil,
    OriginalProperties = {},
    CachedProperties = {},
    PlayersToDraw = {},
    Highlights = {},
    Storage = { ESPCache = {} },
    MousePreload = {
        Active = false,
        LastTime = 0,
        Interval = 5,
        Connection = nil
    },
    CrosshairUpdate = nil
}


local function toggleCrosshair(state)
    if state then
        State.CrosshairUpdate = RunService.RenderStepped:Connect(updateCrosshair)
    else
        if State.CrosshairUpdate then
            State.CrosshairUpdate:Disconnect()
            State.CrosshairUpdate = nil
        end
        for _, drawing in pairs(Settings.Crosshair.Drawings) do
            drawing.Visible = false
        end
    end
end

-- // Utility Functions \\
local function getGunBarrel()
    local furthestPart = nil
    local maxZ = -math.huge
    
    for _, model in pairs(workspace.Camera:GetChildren()) do
        if model:IsA("Model") and not string.find(model.Name:lower(), "arm") then
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    local position, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and position.Z > maxZ then
                        maxZ = position.Z
                        furthestPart = part
                    end
                end
            end
        end
    end
    
    return furthestPart
end

local function updateFOVCirclePosition()
    if Settings.FOV.Enabled then
        if Settings.FOV.FollowGun then
            local barrel = getGunBarrel()
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if barrel then
                local position, onScreen = Camera:WorldToViewportPoint(barrel.Position)
                if onScreen then
                    if State.IsRightClickHeld and math.abs(position.X - screenCenter.X) <= 10 then
                        Settings.FOV.Circle.Position = screenCenter
                        Settings.FOV.OutlineCircle.Position = screenCenter
                    else
                        Settings.FOV.Circle.Position = Vector2.new(position.X, position.Y)
                        Settings.FOV.OutlineCircle.Position = Vector2.new(position.X, position.Y)
                    end
                else
                    Settings.FOV.Circle.Position = screenCenter
                    Settings.FOV.OutlineCircle.Position = screenCenter
                end
            else
                Settings.FOV.Circle.Position = screenCenter
                Settings.FOV.OutlineCircle.Position = screenCenter
            end
        else
            Settings.FOV.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            Settings.FOV.OutlineCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    else
        Settings.FOV.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        Settings.FOV.OutlineCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

local function getPlayers()
    local entityList = {}
    for _, team in pairs(workspace.Players:GetChildren()) do
        for _, player in pairs(team:GetChildren()) do
            if player:IsA("Model") then
                table.insert(entityList, player)
            end
        end
    end
    return entityList
end

local function isEnemy(player)
    local localPlayerTeam = Players.LocalPlayer.Team
    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then return false end
    local playerColor = helmet.BrickColor.Name
    if playerColor == "Black" and localPlayerTeam.Name == "Phantoms" then
        return false
    elseif playerColor ~= "Black" and localPlayerTeam.Name == "Ghosts" then
        return false
    end
    return true
end

local function cacheObject(object)
    if not State.Storage.ESPCache[object] then
        State.Storage.ESPCache[object] = {
            BoxSquare = drawing.new("Square"),
            BoxOutline = drawing.new("Square"),
            BoxInline = drawing.new("Square"),
            TracerLine = drawing.new("Line"),
            DistanceLabel = drawing.new("Text"),
            NameLabel = drawing.new("Text"),
            HeadDot = drawing.new("Circle")
        }
        for _, element in pairs(State.Storage.ESPCache[object]) do
            element.Visible = false
        end
    end
end

local function uncacheObject(object)
    if State.Storage.ESPCache[object] then
        for _, cachedInstance in pairs(State.Storage.ESPCache[object]) do
            cachedInstance:Remove()
        end
        State.Storage.ESPCache[object] = nil
    end
end

local function getBodyPart(player, bodyPartName)
    for _, bodyPart in pairs(player:GetChildren()) do
        if bodyPart:IsA("BasePart") then
            local mesh = bodyPart:FindFirstChildOfClass("SpecialMesh")
            if mesh and mesh.MeshId == "rbxassetid://4049240078" then
                return bodyPart
            end
        end
    end
    return nil
end

local function getHead(player)
    for _, bodyPart in pairs(player:GetChildren()) do
        if bodyPart:IsA("BasePart") then
            local mesh = bodyPart:FindFirstChildOfClass("SpecialMesh")
            if mesh and mesh.MeshId == "rbxassetid://6179256256" then
                return bodyPart
            end
        end
    end
    return nil
end

local function isAlly(player)
    if not player then return false end
    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then return false end
    if helmet.BrickColor == BrickColor.new("Black") then
        return Teams.Phantoms == Players.LocalPlayer.Team
    end
    return Teams.Ghosts == Players.LocalPlayer.Team
end

local function getClosestPlayer()
    local closestPart = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(getPlayers()) do
        if player:IsDescendantOf(workspace.Ignore.DeadBody) then
            -- Skip
        else
            local isAllyPlayer = isAlly(player)
            if Settings.Chams.TeamCheck and isAllyPlayer then
                -- Skip
            else
                local targetBodyPart = Settings.Aimbot.HitPart == "Head" and getHead(player) or getBodyPart(player, "Torso")
                if targetBodyPart then
                    local partPosition, onScreen = Camera:WorldToViewportPoint(targetBodyPart.Position)
                    if onScreen then
                        local screenPosition = Vector2.new(partPosition.X, partPosition.Y)
                        local distanceToCenter = math.sqrt((screenPosition.X - screenCenter.X)^2 + (screenPosition.Y - screenCenter.Y)^2)
                        local distanceToCamera = (targetBodyPart.Position - Camera.CFrame.Position).Magnitude
                        if Settings.Aimbot.MaxDistance.Enabled and distanceToCamera > Settings.Aimbot.MaxDistance.Value then
                            -- Skip
                        else
                            if Settings.FOV.Enabled then
                                if distanceToCenter <= Settings.FOV.Circle.Radius then
                                    if distanceToCamera <= 30 then
                                        closestPart = targetBodyPart
                                        break
                                    end
                                    if distanceToCenter < shortestDistance then
                                        closestPart = targetBodyPart
                                        shortestDistance = distanceToCenter
                                    end
                                end
                            else
                                if distanceToCamera <= 30 then
                                    closestPart = targetBodyPart
                                    break
                                end
                                if distanceToCenter < shortestDistance then
                                    closestPart = targetBodyPart
                                    shortestDistance = distanceToCenter
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

local function safeMouseMoveRel(x, y)
    pcall(function()
        mousemoverel(x, y)
    end)
end

local function preloadMouse()
    local currentTime = tick()
    if currentTime - State.MousePreload.LastTime >= State.MousePreload.Interval then
        safeMouseMoveRel(0.01, 0.01)
        State.MousePreload.LastTime = currentTime
    end
end

local function startMousePreload()
    if State.MousePreload.Active then return end
    State.MousePreload.Active = true
    State.MousePreload.Connection = RunService.Heartbeat:Connect(preloadMouse)
end

local function stopMousePreload()
    if not State.MousePreload.Active then return end
    State.MousePreload.Active = false
    if State.MousePreload.Connection then
        State.MousePreload.Connection:Disconnect()
        State.MousePreload.Connection = nil
    end
end

local function aimAt()
    if not Settings.Aimbot.Easing.Strength then return end
    if State.IsRightClickHeld then
        if not State.TargetPart or not State.TargetPart:IsDescendantOf(workspace.Players) then
            if Settings.Aimbot.AutoTargetSwitch then
                State.TargetPart = getClosestPlayer()
                if not State.TargetPart then
                    State.IsRightClickHeld = false
                    return
                end
            else
                State.IsRightClickHeld = false
                return
            end
        end
        local partPosition, onScreen = Camera:WorldToViewportPoint(State.TargetPart.Position)
        if onScreen then
            local mouseLocation = UserInputService:GetMouseLocation()
            local targetMousePosition = Vector2.new(partPosition.X, partPosition.Y)
            local deltaX = targetMousePosition.X - mouseLocation.X
            local deltaY = targetMousePosition.Y - mouseLocation.Y
            local distance = math.sqrt(deltaX^2 + deltaY^2)
            if distance > 1 then
                local moveX = deltaX * Settings.Aimbot.Easing.Sensitivity.Value
                local moveY = deltaY * Settings.Aimbot.Easing.Sensitivity.Value
                safeMouseMoveRel(moveX, moveY)
            end
        end
    end
end

local function updateSensitivity(newSensitivity)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Settings.Aimbot.Easing.Sensitivity, tweenInfo, {Value = newSensitivity})
    tween:Play()
end

local function storeOriginalProperties(instance)
    if instance:IsA("BasePart") or instance:IsA("UnionOperation") or instance:IsA("MeshPart") then
        State.OriginalProperties[instance] = {
            Material = instance.Material,
            Reflectance = instance.Reflectance,
            CastShadow = instance.CastShadow,
            TextureId = instance:FindFirstChild("TextureId") and instance.TextureId or nil
        }
    end
end

local function optimizeMap()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, instance in pairs(map:GetDescendants()) do
        storeOriginalProperties(instance)
        if instance:IsA("BasePart") or instance:IsA("UnionOperation") or instance:IsA("MeshPart") then
            instance.Material = Enum.Material.SmoothPlastic
            instance.Reflectance = 0
            instance.CastShadow = false
            if instance:IsA("MeshPart") and instance:FindFirstChild("TextureId") then
                instance.TextureId = ""
            end
        end
    end
    Settings.Misc.Optimized = true
end

local function revertMap()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, instance in pairs(map:GetDescendants()) do
        if State.OriginalProperties[instance] then
            instance.Material = State.OriginalProperties[instance].Material
            instance.Reflectance = State.OriginalProperties[instance].Reflectance
            instance.CastShadow = State.OriginalProperties[instance].CastShadow
            if instance:IsA("MeshPart") and instance:FindFirstChild("TextureId") then
                instance.TextureId = State.OriginalProperties[instance].TextureId or ""
            end
        end
    end
    Settings.Misc.Optimized = false
end

local function isVisible(targetPart)
    if Settings.Aimbot.WallCheck then
        local direction = targetPart.Position - Camera.CFrame.Position
        local ray = Ray.new(Camera.CFrame.Position, direction.Unit * 1000)
        local hitPart, _ = workspace:FindPartOnRay(ray, Players.LocalPlayer.Character, false, true)
        return hitPart == targetPart
    end
    return true
end

local function isVisibleESP(targetPart)
    if Settings.ESP.VisibilityCheck then
        local direction = targetPart.Position - Camera.CFrame.Position
        local ray = Ray.new(Camera.CFrame.Position, direction.Unit * 1000)
        local hitPart, _ = workspace:FindPartOnRay(ray, Players.LocalPlayer.Character, false, true)
        return hitPart == targetPart
    end
    return true
end

local function isValidPlayer(player)
    return player and player.Parent and player:IsDescendantOf(workspace.Players)
end

local function initializeESP()
    for player in pairs(State.Storage.ESPCache) do
        uncacheObject(player)
    end
    State.PlayersToDraw = {}
    State.CachedProperties = {}
end

local function cleanupStalePlayers()
    for player in pairs(State.Storage.ESPCache) do
        if not isValidPlayer(player) then
            uncacheObject(player)
            State.CachedProperties[player] = nil
        end
    end
end

local function updatePlayerCache()
    cleanupStalePlayers()
    State.PlayersToDraw = {}
    for _, player in pairs(getPlayers()) do
        if not isValidPlayer(player) then
            -- Skip
        else
            if isEnemy(player) then
                local torso = getBodyPart(player, "Torso")
                local head = getHead(player)
                if torso and head then
                    local distanceToCamera = (head.Position - Camera.CFrame.Position).Magnitude
                    if not Settings.ESP.MaxDistance.Enabled or distanceToCamera <= Settings.ESP.MaxDistance.Value then
                        if not State.Storage.ESPCache[player] then
                            cacheObject(player)
                        end
                        table.insert(State.PlayersToDraw, player)
                        local billboardGui = head:FindFirstChildOfClass("BillboardGui")
                        local textLabel = billboardGui and billboardGui:FindFirstChildOfClass("TextLabel")
                        if billboardGui and textLabel then
                            State.CachedProperties[player] = { Name = textLabel.Text }
                        end
                    else
                        if State.Storage.ESPCache[player] then
                            uncacheObject(player)
                            State.CachedProperties[player] = nil
                        end
                    end
                else
                    if State.Storage.ESPCache[player] then
                        uncacheObject(player)
                        State.CachedProperties[player] = nil
                    end
                end
            end
        end
    end
end

local function applyHighlight(player)
    if State.Highlights[player] then return State.Highlights[player] end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Settings.Chams.Fill.Color
    highlight.OutlineColor = Settings.Chams.Outline.Color
    highlight.FillTransparency = Settings.Chams.Fill.Transparency
    highlight.OutlineTransparency = Settings.Chams.Outline.Transparency
    highlight.Adornee = player
    highlight.Parent = game:GetService("CoreGui")
    State.Highlights[player] = highlight
    return highlight
end

local function removeHighlight(player)
    if State.Highlights[player] then
        State.Highlights[player]:Destroy()
        State.Highlights[player] = nil
    end
end

local function updateChams()
    if not Settings.Chams.Enabled then
        for player, highlight in pairs(State.Highlights) do
            removeHighlight(player)
        end
        return
    end
    for _, player in pairs(getPlayers()) do
        if not isValidPlayer(player) then
            -- Skip
        else
            local isAllyPlayer = isAlly(player)
            if isAllyPlayer and not Settings.Chams.Teammates then
                removeHighlight(player)
            else
                local torso = getBodyPart(player, "Torso")
                if not torso then
                    removeHighlight(player)
                else
                    local distanceToCamera = (torso.Position - Camera.CFrame.Position).Magnitude
                    if Settings.ESP.MaxDistance.Enabled and distanceToCamera > Settings.ESP.MaxDistance.Value then
                        removeHighlight(player)
                    else
                        local highlight = applyHighlight(player)
                        local isVisible = isVisibleESP(torso)
                        if Settings.ESP.VisibilityCheck and not isVisible then
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0.2
                        else
                            highlight.FillColor = Settings.Chams.Fill.Color
                            highlight.OutlineColor = Settings.Chams.Outline.Color
                            highlight.FillTransparency = Settings.Chams.Fill.Transparency
                            highlight.OutlineTransparency = Settings.Chams.Outline.Transparency
                        end
                    end
                end
            end
        end
    end
    for player in pairs(State.Highlights) do
        if not isValidPlayer(player) then
            removeHighlight(player)
        end
    end
end

local function renderESP()
    local cameraPosition = Camera.CFrame.Position
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y)
    local fovRadius = Settings.FOV.OutlineCircle.Radius
    local w2sCache = {}

    for _, player in pairs(State.PlayersToDraw) do
        if not isValidPlayer(player) then
            uncacheObject(player)
            State.CachedProperties[player] = nil
        else
            local cache = State.Storage.ESPCache[player]
            if not cache then
                cacheObject(player)
                cache = State.Storage.ESPCache[player]
            end

            local torso = getBodyPart(player, "Torso")
            local head = getHead(player)
            if not torso or not head then
                for _, element in pairs(cache) do
                    element.Visible = false
                end
            else
                w2sCache[player] = {
                    torso = {Camera:WorldToViewportPoint(torso.Position)},
                    head = {Camera:WorldToViewportPoint(head.Position)}
                }
                local torsoW2S, torsoOnScreen = unpack(w2sCache[player].torso)
                local headW2S, headOnScreen = unpack(w2sCache[player].head)

                if not torsoOnScreen then
                    for _, element in pairs(cache) do
                        element.Visible = false
                    end
                else
                    local distanceToCamera = (torso.Position - cameraPosition).Magnitude
                    local screenPosition = Vector2.new(torsoW2S.X, torsoW2S.Y)
                    local distanceToCenter = math.sqrt((screenPosition.X - screenCenter.X)^2 + (screenPosition.Y - screenCenter.Y)^2)

                    if Settings.ESP.UseFOV and distanceToCenter > fovRadius then
                        for _, element in pairs(cache) do
                            element.Visible = false
                        end
                    else
                        local scale = 1000 / distanceToCamera * 80 / Camera.FieldOfView
                        local boxWidth = math.floor(3 * scale)
                        local boxHeight = math.floor(4 * scale)
                        local boxPosition = Vector2.new(torsoW2S.X - boxWidth / 2, torsoW2S.Y - boxHeight / 2)
                        local isVisible = not Settings.ESP.VisibilityCheck or isVisibleESP(head)
                        local boxColor = isVisible and Settings.ESP.Features.Box.Color or Color3.fromRGB(255, 0, 0)

                        -- Box
                        cache.BoxSquare.Visible = Settings.ESP.Features.Box.Enabled
                        cache.BoxOutline.Visible = Settings.ESP.Features.Box.Enabled
                        if Settings.ESP.Features.Box.Enabled then
                            cache.BoxSquare.Color = boxColor
                            cache.BoxSquare.Position = boxPosition
                            cache.BoxSquare.Size = Vector2.new(boxWidth, boxHeight)
                            cache.BoxOutline.Position = Vector2.new(boxPosition.X - 1, boxPosition.Y - 1)
                            cache.BoxOutline.Size = Vector2.new(boxWidth + 2, boxHeight + 2)
                        end

                        -- Tracer
                        cache.TracerLine.Visible = Settings.ESP.Features.Tracer.Enabled
                        if Settings.ESP.Features.Tracer.Enabled then
                            cache.TracerLine.Color = isVisible and Settings.ESP.Features.Tracer.Color or Color3.fromRGB(255, 0, 0)
                            cache.TracerLine.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                            cache.TracerLine.To = screenPosition
                        end

                        -- Name
                        cache.NameLabel.Visible = Settings.ESP.Features.Name.Enabled and State.CachedProperties[player]
                        if Settings.ESP.Features.Name.Enabled and State.CachedProperties[player] then
                            cache.NameLabel.Text = State.CachedProperties[player].Name
                            cache.NameLabel.Color = Settings.ESP.Features.Name.Color
                            cache.NameLabel.Size = math.max(12, math.min(16, scale * 2.5))
                            cache.NameLabel.Center = true
                            cache.NameLabel.Position = Vector2.new(boxPosition.X + (boxWidth / 2), boxPosition.Y - 15)
                            cache.NameLabel.Outline = true
                        end

                        -- Distance
                        cache.DistanceLabel.Visible = Settings.ESP.Features.DistanceText.Enabled
                        if Settings.ESP.Features.DistanceText.Enabled then
                            local distance = math.floor(distanceToCamera)
                            cache.DistanceLabel.Text = distance .. " studs"
                            cache.DistanceLabel.Color = Settings.ESP.Features.DistanceText.Color
                            cache.DistanceLabel.Size = math.max(14, math.min(18, scale * 2.5))
                            cache.DistanceLabel.Position = Vector2.new(boxPosition.X + (boxWidth / 2), boxPosition.Y + boxHeight + 5)
                            cache.DistanceLabel.Outline = true
                        end

                        -- Head Dot
                        cache.HeadDot.Visible = Settings.ESP.Features.HeadDot.Enabled and headOnScreen
                        if Settings.ESP.Features.HeadDot.Enabled and headOnScreen then
                            cache.HeadDot.Color = Settings.ESP.Features.HeadDot.Color
                            cache.HeadDot.Radius = (boxHeight / 20)
                            cache.HeadDot.Position = Vector2.new(headW2S.X, headW2S.Y)
                        end
                    end
                end
            end
        end
    end
end

local function refreshPlayerCache()
    if Library.Flags.ESPEnabled then
        updatePlayerCache()
    end
end

local function getCharacter()
    local character
    while not character do
        character = workspace:FindFirstChild("Ignore") and workspace:FindFirstChild("Ignore"):FindFirstChildWhichIsA("Model")
        task.wait()
    end
    return character
end

local function kickAndRejoin()
    local teleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    Players.LocalPlayer:Kick("[THIS IS NOT A VOTEKICK!] You've been blocked from being votekicked, Rejoining...")
    teleportService:Teleport(placeId)
end

local function initializeVotekickRejoiner()
    local chatScreenGui = Players.LocalPlayer.PlayerGui:WaitForChild("ChatScreenGui")
    local displayVoteKick = chatScreenGui.Main:WaitForChild("DisplayVoteKick")
    displayVoteKick:GetPropertyChangedSignal("Visible"):Connect(function()
        if displayVoteKick.Visible and Toggles.VotekickRejoiner and Toggles.VotekickRejoiner.Value then
            local textTitle = displayVoteKick.TextTitle.Text
            local words = {}
            for word in string.gmatch(textTitle, "%S+") do table.insert(words, word) end
            if words[2] == Players.LocalPlayer.Name then kickAndRejoin() end
        end
    end)
end

local function isNumber(str)
    return tonumber(str) ~= nil or str == "inf"
end

-- // UI Setup \\
local Window = Library:CreateWindow({
    Name = "Apex.rocks",
    Themeable = {
        Info = "discord.gg/apexrocks"
    }
})

local Tabs = {
    Main = Window:CreateTab({Name = "Main"}),
    Visuals = Window:CreateTab({Name = "Visuals"}),
    Player = Window:CreateTab({Name = "Player"}),
    Misc = Window:CreateTab({Name = "Misc"})
}

-- // Crosshair UI \\
local CrosshairGroup = Tabs.Misc:CreateSection({Name = "Crosshair"})
CrosshairGroup:AddToggle({
    Name = "Enabled",
    Flag = "CrosshairEnabled",
    Value = Settings.Crosshair.Enabled,
    Callback = function(state)
        Settings.Crosshair.Enabled = state
        toggleCrosshair(state)
    end
})

CrosshairGroup:AddDropdown({
    Name = "Style",
    Flag = "CrosshairStyle",
    List = {"Default", "Plus"},
    Value = Settings.Crosshair.TStyle,
    Callback = function(value)
        Settings.Crosshair.TStyle = value
    end
})

CrosshairGroup:AddToggle({
    Name = "Center Dot",
    Flag = "CrosshairDot",
    Value = Settings.Crosshair.Dot,
    Callback = function(state)
        Settings.Crosshair.Dot = state
    end
})

CrosshairGroup:AddSlider({
    Name = "Size",
    Flag = "CrosshairSize",
    Value = Settings.Crosshair.Size,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = function(value)
        Settings.Crosshair.Size = value
    end
})

CrosshairGroup:AddSlider({
    Name = "Thickness",
    Flag = "CrosshairThickness",
    Value = Settings.Crosshair.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(value)
        Settings.Crosshair.Thickness = value
    end
})

CrosshairGroup:AddSlider({
    Name = "Gap",
    Flag = "CrosshairGap",
    Value = Settings.Crosshair.Gap,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(value)
        Settings.Crosshair.Gap = value
    end
})

CrosshairGroup:AddColorPicker({
    Name = "Color",
    Flag = "CrosshairColor",
    Color = Settings.Crosshair.Color,
    Transparency = 0,
    Callback = function(value)
        Settings.Crosshair.Color = value
    end
})

CrosshairGroup:AddSlider({
    Name = "Transparency",
    Flag = "CrosshairTransparency",
    Value = Settings.Crosshair.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Settings.Crosshair.Transparency = value
    end
})

-- // Aimbot UI \\
local AimbotGroup = Tabs.Main:CreateSection({Name = "Aimbot"})
AimbotGroup:AddToggle({
    Name = "Enabled",
    Flag = "AimbotEnabled",
    Value = Settings.Aimbot.Enabled,
    Callback = function(state)
        Settings.Aimbot.Enabled = state
        if state then
            startMousePreload()
            State.InputBeganConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    State.IsRightClickHeld = true
                    State.TargetPart = getClosestPlayer()
                end
            end)
            State.InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    State.IsRightClickHeld = false
                    State.TargetPart = nil
                end
            end)
            State.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
                if State.IsRightClickHeld and State.TargetPart then
                    if Library.Flags.AimbotWallCheck then
                        if isVisible(State.TargetPart) then aimAt() end
                    else
                        aimAt()
                    end
                end
            end)
        else
            stopMousePreload()
            if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end
            if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end
            if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
        end
    end
})


AimbotGroup:AddDropdown({
    Name = "Hit Part",
    Flag = "AimbotHitPart",
    List = {"Head", "Torso"},
    Value = Settings.Aimbot.HitPart,
    Callback = function(value)
        Settings.Aimbot.HitPart = value
    end
})

AimbotGroup:AddToggle({
    Name = "Wall Check",
    Flag = "AimbotWallCheck",
    Value = Settings.Aimbot.WallCheck,
    Callback = function(state)
        Settings.Aimbot.WallCheck = state
    end
})

AimbotGroup:AddToggle({
    Name = "Auto Target Switch",
    Flag = "AimbotAutoTargetSwitch",
    Value = Settings.Aimbot.AutoTargetSwitch,
    Callback = function(state)
        Settings.Aimbot.AutoTargetSwitch = state
    end
})

AimbotGroup:AddToggle({
    Name = "Use Max Distance",
    Flag = "AimbotMaxDistanceEnabled",
    Value = Settings.Aimbot.MaxDistance.Enabled,
    Callback = function(state)
        Settings.Aimbot.MaxDistance.Enabled = state
    end
})

AimbotGroup:AddSlider({
    Name = "Max Distance",
    Flag = "AimbotMaxDistance",
    Value = Settings.Aimbot.MaxDistance.Value,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        Settings.Aimbot.MaxDistance.Value = value
    end
})

AimbotGroup:AddSlider({
    Name = "Strength",
    Flag = "AimbotEasingStrength",
    Value = Settings.Aimbot.Easing.Strength,
    Min = 0.1,
    Max = 1.5,
    Decimals = 1,
    Rounding = 1,
    Callback = function(value)
        Settings.Aimbot.Easing.Strength = value
        updateSensitivity(value)
    end
})

-- // ESP UI \\
local ESPGroup = Tabs.Visuals:CreateSection({Name = "ESP"})
ESPGroup:AddToggle({
    Name = "Enabled",
    Flag = "ESPEnabled",
    Value = Settings.ESP.Enabled,
    Callback = function(state)
        Settings.ESP.Enabled = state
        if state then
            initializeESP()
            State.PlayerCacheUpdate = RunService.Heartbeat:Connect(updatePlayerCache)
            local lastUpdate = tick()
            local targetInterval = 1 / 240
            State.ESPLoop = RunService.Heartbeat:Connect(function()
                local currentTime = tick()
                if currentTime - lastUpdate >= targetInterval then
                    renderESP()
                    lastUpdate = currentTime
                end
            end)
        else
            if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end
            if State.ESPLoop then State.ESPLoop:Disconnect() end
            for player in pairs(State.Storage.ESPCache) do
                uncacheObject(player)
            end
            State.PlayersToDraw = {}
            State.CachedProperties = {}
        end
    end
})


local function updateESPFeature(featureName, state)
    Settings.ESP.Features[featureName].Enabled = state
    for player, cache in pairs(State.Storage.ESPCache) do
        if isValidPlayer(player) then
            if featureName == "Box" then
                cache.BoxSquare.Visible = state
                cache.BoxOutline.Visible = state
            elseif featureName == "Tracer" then
                cache.TracerLine.Visible = state
            elseif featureName == "HeadDot" then
                cache.HeadDot.Visible = state
            elseif featureName == "DistanceText" then
                cache.DistanceLabel.Visible = state
            elseif featureName == "Name" then
                cache.NameLabel.Visible = state
            end
        end
    end
end


ESPGroup:AddToggle({
    Name = "Box",
    Flag = "ESPBox",
    Value = Settings.ESP.Features.Box.Enabled,
    Callback = function(state)
        updateESPFeature("Box", state)
    end
})

ESPGroup:AddToggle({
    Name = "Tracer",
    Flag = "ESPTracer",
    Value = Settings.ESP.Features.Tracer.Enabled,
    Callback = function(state)
        updateESPFeature("Tracer", state)
    end
})

ESPGroup:AddToggle({
    Name = "Head Dot",
    Flag = "ESPHeadDot",
    Value = Settings.ESP.Features.HeadDot.Enabled,
    Callback = function(state)
        updateESPFeature("HeadDot", state)
    end
})

ESPGroup:AddToggle({
    Name = "Distance",
    Flag = "ESPDistance",
    Value = Settings.ESP.Features.DistanceText.Enabled,
    Callback = function(state)
        updateESPFeature("DistanceText", state)
    end
})

ESPGroup:AddToggle({
    Name = "Name",
    Flag = "ESPName",
    Value = Settings.ESP.Features.Name.Enabled,
    Callback = function(state)
        updateESPFeature("Name", state)
    end
})

ESPGroup:AddToggle({
    Name = "Wall Check",
    Flag = "ESPVisibilityCheck",
    Value = Settings.ESP.VisibilityCheck,
    Callback = function(state)
        Settings.ESP.VisibilityCheck = state
    end
})

-- // ESP Customization UI \\
local ESPCustomization = Tabs.Visuals:CreateSection({Name = "ESP Colors", Side = "Right"})

local function updateESPColor(featureName, color)
    Settings.ESP.Features[featureName].Color = color
    for player, cache in pairs(State.Storage.ESPCache) do
        if isValidPlayer(player) then
            if featureName == "Box" then
                cache.BoxSquare.Color = color
            elseif featureName == "Tracer" then
                cache.TracerLine.Color = color
            elseif featureName == "HeadDot" then
                cache.HeadDot.Color = color
            elseif featureName == "DistanceText" then
                cache.DistanceLabel.Color = color
            elseif featureName == "Name" then
                cache.NameLabel.Color = color
            end
        end
    end
end

-- Box Color
ESPCustomization:AddColorPicker({
    Name = "Box Color",
    Flag = "ESPBoxColor",
    Color = Settings.ESP.Features.Box.Color,
    Callback = function(value)
        updateESPColor("Box", value)
    end
})

-- Tracer Color
ESPCustomization:AddColorPicker({
    Name = "Tracer Color",
    Flag = "ESPTracerColor",
    Color = Settings.ESP.Features.Tracer.Color,
    Callback = function(value)
        updateESPColor("Tracer", value)
    end
})

-- Distance Color
ESPCustomization:AddColorPicker({
    Name = "Distance Color",
    Flag = "ESPDistanceColor",
    Color = Settings.ESP.Features.DistanceText.Color,
    Callback = function(value)
        updateESPColor("DistanceText", value)
    end
})

-- Head Dot Color
ESPCustomization:AddColorPicker({
    Name = "Head Dot Color",
    Flag = "ESPHeadDotColor",
    Color = Settings.ESP.Features.HeadDot.Color,
    Callback = function(value)
        updateESPColor("HeadDot", value)
    end
})

-- Name Color
ESPCustomization:AddColorPicker({
    Name = "Name Color",
    Flag = "ESPNameColor",
    Color = Settings.ESP.Features.Name.Color,
    Callback = function(value)
        updateESPColor("Name", value)
    end
})

-- // Distance Customization UI \\
local DistanceCustomization = Tabs.Visuals:CreateSection({Name = "Distance Settings", Side = "Right"})
DistanceCustomization:AddToggle({
    Name = "Use Max Distance",
    Flag = "ESPMaxDistanceEnabled",
    Value = Settings.ESP.MaxDistance.Enabled,
    Callback = function(state)
        Settings.ESP.MaxDistance.Enabled = state
        refreshPlayerCache()
    end
})

DistanceCustomization:AddSlider({
    Name = "Max Distance",
    Flag = "ESPMaxDistance",
    Value = Settings.ESP.MaxDistance.Value,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        Settings.ESP.MaxDistance.Value = value
        refreshPlayerCache()
    end
})

-- // FOV UI \\
local FOVGroup = Tabs.Main:CreateSection({Name = "FOV", Side = "Right"})
FOVGroup:AddToggle({
    Name = "Show FOV Circle",
    Flag = "FOVEnabled",
    Value = Settings.FOV.Enabled,
    Callback = function(state)
        Settings.FOV.Enabled = state
        Settings.FOV.Circle.Visible = state
        Settings.FOV.OutlineCircle.Visible = state
    end
})

FOVGroup:AddToggle({
    Name = "Follow Gun",
    Flag = "FOVFollowGun",
    Value = Settings.FOV.FollowGun,
    Callback = function(state)
        Settings.FOV.FollowGun = state
    end
})

--[[FOVGroup:AddToggle({
    Name = "Limit ESP To FOV",
    Flag = "ESPUseFOV",
    Value = Settings.ESP.UseFOV,
    Callback = function(state)
        Settings.ESP.UseFOV = state
        refreshPlayerCache()
    end
})]] -- broken asf rn, do not use

FOVGroup:AddToggle({
    Name = "Fill FOV Circle",
    Flag = "FOVFilled",
    Value = Settings.FOV.Filled,
    Callback = function(state)
        Settings.FOV.Filled = state
        Settings.FOV.Circle.Filled = state
        Settings.FOV.Circle.Color = state and Settings.FOV.FillColor or Settings.FOV.OutlineColor
        Settings.FOV.Circle.Transparency = state and Settings.FOV.FillTransparency or Settings.FOV.OutlineTransparency
        Settings.FOV.Circle.Thickness = state and 0 or 1
    end
})

FOVGroup:AddColorPicker({
    Name = "Inline Color",
    Flag = "FOVFillColor",
    Color = Settings.FOV.FillColor,
    Transparency = Settings.FOV.FillTransparency,
    Callback = function(value)
        Settings.FOV.FillColor = value
        if Settings.FOV.Filled then
            Settings.FOV.Circle.Color = value
        end
    end
})

FOVGroup:AddSlider({
    Name = "Inline Transparency",
    Flag = "FOVFillTransparency",
    Value = Settings.FOV.FillTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Settings.FOV.FillTransparency = value
        if Settings.FOV.Filled then
            Settings.FOV.Circle.Transparency = value
        end
    end
})

FOVGroup:AddColorPicker({
    Name = "Outline Color",
    Flag = "FOVOutlineColor",
    Color = Settings.FOV.OutlineColor,
    Transparency = Settings.FOV.OutlineTransparency,
    Callback = function(value)
        Settings.FOV.OutlineColor = value
        Settings.FOV.OutlineCircle.Color = value
        if not Settings.FOV.Filled then
            Settings.FOV.Circle.Color = value
        end
    end
})

FOVGroup:AddSlider({
    Name = "Outline Transparency",
    Flag = "FOVOutlineTransparency",
    Value = Settings.FOV.OutlineTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Settings.FOV.OutlineTransparency = value
        Settings.FOV.OutlineCircle.Transparency = value
        if not Settings.FOV.Filled then
            Settings.FOV.Circle.Transparency = value
        end
    end
})

FOVGroup:AddSlider({
    Name = "FOV Radius",
    Flag = "FOVRadius",
    Value = Settings.FOV.Radius,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        Settings.FOV.Radius = value
        Settings.FOV.Circle.Radius = value
        Settings.FOV.OutlineCircle.Radius = value
    end
})

-- // Chams UI \\
local ChamsGroup = Tabs.Visuals:CreateSection({Name = "Chams"})
ChamsGroup:AddToggle({
    Name = "Enabled",
    Flag = "ChamsEnabled",
    Value = Settings.Chams.Enabled,
    Callback = function(state)
        Settings.Chams.Enabled = state
        if state then
            State.ChamsUpdateConnection = RunService.RenderStepped:Connect(updateChams)
        else
            if State.ChamsUpdateConnection then
                State.ChamsUpdateConnection:Disconnect()
                State.ChamsUpdateConnection = nil
            end
            for player, highlight in pairs(State.Highlights) do
                removeHighlight(player)
            end
        end
    end
})

ChamsGroup:AddLabel("Fill Color")
ChamsGroup:AddColorPicker({
    Name = "Fill Color",
    Flag = "ChamsFillColor",
    Color = Settings.Chams.Fill.Color,
    Transparency = 0,
    Callback = function(value)
        Settings.Chams.Fill.Color = value
        for _, highlight in pairs(State.Highlights) do
            highlight.FillColor = value
        end
    end
})

ChamsGroup:AddLabel("Outline Color")
ChamsGroup:AddColorPicker({
    Name = "Outline Color",
    Flag = "ChamsOutlineColor",
    Color = Settings.Chams.Outline.Color,
    Transparency = 0,
    Callback = function(value)
        Settings.Chams.Outline.Color = value
        for _, highlight in pairs(State.Highlights) do
            highlight.OutlineColor = value
        end
    end
})

ChamsGroup:AddSlider({
    Name = "Fill Transparency",
    Flag = "ChamsFillTransparency",
    Value = Settings.Chams.Fill.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(value)
        Settings.Chams.Fill.Transparency = value
        for _, highlight in pairs(State.Highlights) do
            highlight.FillTransparency = value
        end
    end
})

ChamsGroup:AddSlider({
    Name = "Outline Transparency",
    Flag = "ChamsOutlineTransparency",
    Value = Settings.Chams.Outline.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(value)
        Settings.Chams.Outline.Transparency = value
        for _, highlight in pairs(State.Highlights) do
            highlight.OutlineTransparency = value
        end
    end
})


-- // Player Mods \\

local PlayerGroup = Tabs.Player:CreateSection({Name = "Player"})
PlayerGroup:AddToggle({
    Name = "Bunny Hop",
    Flag = "BhopEnabled",
    Value = Settings.Player.Bhop.Enabled,
    Callback = function(state)
        Settings.Player.Bhop.Enabled = state
    end
})

-- // Misc Mods UI \\
local Optimizations = Tabs.Misc:CreateSection({Name = "Miscellaneous"})
Optimizations:AddToggle({
    Name = "Toggle Textures",
    Flag = "MiscTextures",
    Value = Settings.Misc.Textures,
    Callback = function(state)
        Settings.Misc.Textures = state
        if state then
            optimizeMap()
        else
            revertMap()
        end
    end
})

-- // Safety UI \\
local Safety = Tabs.Misc:CreateSection({Name = "Safety", Side = "Right"})
Safety:AddToggle({
    Name = "Rejoin on Votekick",
    Flag = "VotekickRejoiner",
    Value = Settings.Misc.VotekickRejoiner,
    Callback = function(state)
        Settings.Misc.VotekickRejoiner = state
        if state then
            initializeVotekickRejoiner()
        end
    end
})


-- // Non-UI Setup \\
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFOVCirclePosition)
RunService.Heartbeat:Connect(updateFOVCirclePosition)

local function handleBhop()
    if Settings.Player.Bhop.Enabled then
        local currentTime = tick()
        if (currentTime - lastJumpTime) < jumpCooldown then
            local humanoid = getCharacter():FindFirstChildOfClass("Humanoid")
            if humanoid then 
                humanoid.Jump = true 
            end
        end
        lastJumpTime = currentTime
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        handleBhop()
    end
end)


-- // Cleanup on Unload \\
Library:OnUnload(function()
    for player in pairs(State.Storage.ESPCache) do
        uncacheObject(player)
    end
    for player, highlight in pairs(State.Highlights) do
        removeHighlight(player)
    end
    if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end
    if State.ESPLoop then State.ESPLoop:Disconnect() end
    if State.ChamsUpdateConnection then State.ChamsUpdateConnection:Disconnect() end
    if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end
    if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end
    if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
    if State.CrosshairUpdate then State.CrosshairUpdate:Disconnect() end
    for _, drawing in pairs(Settings.Crosshair.Drawings) do
        drawing:Remove()
    end
    Settings.FOV.Circle:Remove()
    Settings.FOV.OutlineCircle:Remove()
    stopMousePreload()
    revertMap()
	_G.ScriptIsRunning = false
end)
