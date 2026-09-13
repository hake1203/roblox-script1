local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Настройки
local AimSpeed = 3
local FOV = 250
local ESPEnabled = true
local AimEnabled = true
local FOVCircleEnabled = true
local NoclipEnabled = false
local FlyEnabled = false
local TpMouseEnabled = false
local InfAmmoEnabled = false
local Whitelist = {}
local isScriptRunning = true

-- Переменные для биндов (KeyCode)
local BindNoclip = Enum.KeyCode.N
local BindFly = Enum.KeyCode.F
local BindTpMouse = Enum.KeyCode.Q
local BindInfAmmo = Enum.KeyCode.R

-- Переменные для Fly
local FlySpeed = 50
local controlModule = nil

local function loadControlModule()
    pcall(function()
        controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    end)
end
loadControlModule()

-- Создание FOV круга
local FOVDrawing = Drawing.new("Circle")
FOVDrawing.Visible = true
FOVDrawing.Thickness = 1
FOVDrawing.Color = Color3.fromRGB(255, 255, 255)
FOVDrawing.Filled = false
FOVDrawing.Radius = FOV

-- Графический интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatMenuAdvanced"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 456)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -228)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Roblox Menu [Insert — скрыть]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Функция создания универсальных кнопок с биндами
local function createFeatureButton(posY, textPrefix, state, callback, bindKey, bindCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.55, 0, 0, 26)
    btn.Position = UDim2.new(0.04, 0, 0, posY)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    btn.Text = textPrefix .. (state and ": ON" or ": OFF")
    btn.Parent = MainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local newState = callback()
        btn.Text = textPrefix .. (newState and ": ON" or ": OFF")
        btn.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0.34, 0, 0, 26)
    bindBtn.Position = UDim2.new(0.62, 0, 0, posY)
    bindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    bindBtn.TextSize = 11
    bindBtn.Font = Enum.Font.SourceSans
    bindBtn.Text = "Bind: " .. tostring(bindKey.Name)
    bindBtn.Parent = MainFrame
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = bindBtn

    bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text = "Нажмите..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                bindKey = input.KeyCode
                bindBtn.Text = "Bind: " .. tostring(bindKey.Name)
                bindCallback(bindKey)
                connection:Disconnect()
            end
        end)
    end)

    return btn
end

-- Верхний ряд быстрых переключателей (ESP, Aim, FOV)
local function createTopToggle(posX, text, state, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0, 28)
    btn.Position = UDim2.new(posX, 0, 0, 35)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    btn.Text = text .. (state and ": ON" or ": OFF")
    btn.Parent = MainFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(function()
        local s = callback()
        btn.Text = text .. (s and ": ON" or ": OFF")
        btn.BackgroundColor3 = s and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

createTopToggle(0.04, "ESP", ESPEnabled, function() ESPEnabled = not ESPEnabled return ESPEnabled end)
createTopToggle(0.35, "Aim", AimEnabled, function() AimEnabled = not AimEnabled return AimEnabled end)
createTopToggle(0.66, "FOV", FOVCircleEnabled, function() FOVCircleEnabled = not FOVCircleEnabled FOVDrawing.Visible = FOVCircleEnabled return FOVCircleEnabled end)

-- Создание элементов управления
createFeatureButton(70, "Ноуклип", NoclipEnabled, function()
    NoclipEnabled = not NoclipEnabled
    return NoclipEnabled
end, BindNoclip, function(k) BindNoclip = k end)

createFeatureButton(102, "Флай", FlyEnabled, function()
    FlyEnabled = not FlyEnabled
    return FlyEnabled
end, BindFly, function(k) BindFly = k end)

createFeatureButton(134, "ТП по колесику", TpMouseEnabled, function()
    TpMouseEnabled = not TpMouseEnabled
    return TpMouseEnabled
end, BindTpMouse, function(k) BindTpMouse = k end)

createFeatureButton(166, "Инф. Патроны", InfAmmoEnabled, function()
    InfAmmoEnabled = not InfAmmoEnabled
    return InfAmmoEnabled
end, BindInfAmmo, function(k) BindInfAmmo = k end)

-- Поле FOV Radius
local FOVBox = Instance.new("TextBox")
FOVBox.Size = UDim2.new(0.92, 0, 0, 26)
FOVBox.Position = UDim2.new(0.04, 0, 0, 198)
FOVBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVBox.TextSize = 12
FOVBox.Font = Enum.Font.SourceSans
FOVBox.Text = "Радиус FOV: " .. tostring(FOV)
FOVBox.Parent = MainFrame
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0, 6)
fovCorner.Parent = FOVBox

FOVBox.FocusLost:Connect(function()
    local num = tonumber(FOVBox.Text:match("%d+"))
    if num then
        FOV = math.clamp(num, 10, 1000)
        FOVDrawing.Radius = FOV
    end
    FOVBox.Text = "Радиус FOV: " .. tostring(FOV)
end)

-- Кнопки очистки WList и закрытия скрипта
local ClearWListBtn = Instance.new("TextButton")
ClearWListBtn.Size = UDim2.new(0.45, 0, 0, 26)
ClearWListBtn.Position = UDim2.new(0.04, 0, 0, 230)
ClearWListBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ClearWListBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearWListBtn.TextSize = 12
ClearWListBtn.Font = Enum.Font.SourceSans
ClearWListBtn.Text = "Очистить WList"
ClearWListBtn.Parent = MainFrame
local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = ClearWListBtn

local CloseScriptBtn = Instance.new("TextButton")
CloseScriptBtn.Size = UDim2.new(0.45, 0, 0, 26)
CloseScriptBtn.Position = UDim2.new(0.51, 0, 0, 230)
CloseScriptBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseScriptBtn.TextSize = 12
CloseScriptBtn.Font = Enum.Font.SourceSansBold
CloseScriptBtn.Text = "Закрыть скрипт"
CloseScriptBtn.Parent = MainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseScriptBtn

-- Список игроков для вайтлиста
local ListContainer = Instance.new("ScrollingFrame")
ListContainer.Size = UDim2.new(0.92, 0, 0, 160)
ListContainer.Position = UDim2.new(0.04, 0, 0, 266)
ListContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ListContainer.BorderSizePixel = 0
ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ListContainer.ScrollBarThickness = 6
ListContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ListContainer

local function unloadScript()
    isScriptRunning = false
    pcall(function() FOVDrawing:Remove() end)
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "CheatMenuAdvanced" then gui:Destroy() end
    end
end

CloseScriptBtn.MouseButton1Click:Connect(unloadScript)

-- Обработка смерти персонажа (сброс флая и платформенного состояния)
LocalPlayer.CharacterAdded:Connect(function(char)
    FlyEnabled = false
    NoclipEnabled = false
    task.wait(0.5)
    loadControlModule()
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.PlatformStand = false
    end
end)

-- Обработка биндов клавиатуры
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isScriptRunning then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    elseif not gameProcessed then
        if input.KeyCode == BindNoclip then
            NoclipEnabled = not NoclipEnabled
        elseif input.KeyCode == BindFly then
            FlyEnabled = not FlyEnabled
        elseif input.KeyCode == BindTpMouse then
            TpMouseEnabled = not TpMouseEnabled
        elseif input.KeyCode == BindInfAmmo then
            InfAmmoEnabled = not InfAmmoEnabled
        end
    end
end)

-- Телепортация по клику колёсика мыши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isScriptRunning or not TpMouseEnabled or gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

ClearWListBtn.MouseButton1Click:Connect(function() Whitelist = {} end)

local function updatePlayerList()
    for _, child in pairs(ListContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -6, 0, 26)
            pBtn.BackgroundColor3 = Whitelist[player.Name] and Color3.fromRGB(0, 100, 100) or Color3.fromRGB(40, 40, 40)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 12
            pBtn.Font = Enum.Font.SourceSans
            pBtn.Text = player.Name .. (Whitelist[player.Name] and " [В вайтлисте]" or "")
            pBtn.Parent = ListContainer

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 4)
            c.Parent = pBtn

            pBtn.MouseButton1Click:Connect(function()
                if Whitelist[player.Name] then
                    Whitelist[player.Name] = nil
                    pBtn.Text = player.Name
                    pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                else
                    Whitelist[player.Name] = true
                    pBtn.Text = player.Name .. " [В вайтлисте]"
                    pBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
                end
            end)
        end
    end
    ListContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
task.spawn(updatePlayerList)

local espDrawings = {}
local function removeESP(player)
    if espDrawings[player] then
        if espDrawings[player].Box then espDrawings[player].Box:Remove() end
        if espDrawings[player].Text then espDrawings[player].Text:Remove() end
        espDrawings[player] = nil
    end
end

-- Главный цикл обработки кадров (RenderStepped)
RunService.RenderStepped:Connect(function()
    if not isScriptRunning then return end

    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- FOV Круг
    local mousePos = UserInputService:GetMouseLocation()
    if FOVCircleEnabled then
        FOVDrawing.Position = mousePos
        FOVDrawing.Visible = true
    else
        FOVDrawing.Visible = false
    end

    -- Ноуклип
    if NoclipEnabled and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Флай
    if FlyEnabled and hrp and humanoid and humanoid.Health > 0 then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        if controlModule then
            moveDir = controlModule:GetMoveVector()
        end
        
        local velocity = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X) * FlySpeed
        hrp.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
        humanoid.PlatformStand = true
    elseif humanoid and humanoid.Health > 0 then
        humanoid.PlatformStand = false
    end

    -- Инфинити патроны
    if InfAmmoEnabled then
        pcall(function()
            if getgc then
                for _, obj in pairs(getgc(true)) do
                    if type(obj) == "table" then
                        if rawget(obj, "Ammo") and rawget(obj, "MaxAmmo") then
                            if isreadonly and isreadonly(obj) then
                                setreadonly(obj, false)
                            end
                            rawset(obj, "Ammo", 999)
                            rawset(obj, "MaxAmmo", 999)
                        end
                    end
                end
            end
            
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            local containers = {char, backpack}
            for _, container in pairs(containers) do
                if container then
                    for _, item in pairs(container:GetDescendants()) do
                        if item:IsA("IntValue") or item:IsA("NumberValue") then
                            local name = item.Name:lower()
                            if name:find("ammo") or name:find("clip") or name:find("bullets") then
                                item.Value = 999
                            end
                        end
                    end
                end
            end
        end)
    end

    -- ESP отрисовка
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if ESPEnabled and pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChildOfClass("Humanoid") and pChar.Humanoid.Health > 0 then
                if not espDrawings[player] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Thickness = 1
                    box.Filled = false

                    local text = Drawing.new("Text")
                    text.Visible = false
                    text.Size = 13
                    text.Center = true
                    text.Outline = true

                    espDrawings[player] = {Box = box, Text = text}
                end

                local pHrp = pChar.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(pHrp.Position)

                if onScreen then
                    local scale = 1 / (vector.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
                    local w, h = math.clamp(20 * scale, 15, 300), math.clamp(30 * scale, 20, 400)
                    
                    local box = espDrawings[player].Box
                    box.Size = Vector2.new(w, h)
                    box.Position = Vector2.new(vector.X - w / 2, vector.Y - h / 2)
                    box.Color = Whitelist[player.Name] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
                    box.Visible = true

                    local text = espDrawings[player].Text
                    text.Text = player.Name
                    text.Position = Vector2.new(vector.X, vector.Y - h / 2 - 16)
                    text.Color = box.Color
                    text.Visible = true
                else
                    espDrawings[player].Box.Visible = false
                    espDrawings[player].Text.Visible = false
                end
            else
                removeESP(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(removeESP)

-- Логика Аимбота
local function getClosestPlayer()
    local target = nil
    local shortestDist = FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not Whitelist[v.Name] and v.Character and v.Character:FindFirstChild("Head") then
            local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = v.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDist then
                        shortestDist = distance
                        target = head
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if not isScriptRunning or not AimEnabled then return end
    
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetHead = getClosestPlayer()
        if targetHead then
            local screenPos, _ = Camera:WorldToViewportPoint(targetHead.Position)
            local mousePos = UserInputService:GetMouseLocation()
            
            local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
            if delta.Magnitude <= FOV then
                if mousemoverel then
                    mousemoverel(delta.X / AimSpeed, delta.Y / AimSpeed)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetHead.Position), 1 / AimSpeed)
                end
            end
        end
    end
end)
