local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer

-- Remove interface anterior se houver
if CoreGui:FindFirstChild("ToshiPanel") then
    CoreGui.HellszPanel:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToshiPanel"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Contador de FPS no canto da tela (Estilo PC Competitivo)
local FpsOverlay = Instance.new("TextLabel")
FpsOverlay.Name = "FpsOverlay"
FpsOverlay.Parent = ScreenGui
FpsOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FpsOverlay.BackgroundTransparency = 0.3
FpsOverlay.BorderSizePixel = 0
FpsOverlay.Position = UDim2.new(1, -110, 0, 10)
FpsOverlay.Size = UDim2.new(0, 100, 0, 26)
FpsOverlay.Font = Enum.Font.GothamBold
FpsOverlay.Text = "FPS: 60"
FpsOverlay.TextColor3 = Color3.fromRGB(0, 255, 120)
FpsOverlay.TextSize = 12

local FpsOverlayCorner = Instance.new("UICorner")
FpsOverlayCorner.CornerRadius = UDim.new(0, 6)
FpsOverlayCorner.Parent = FpsOverlay

local lastTick = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTick = tick()
    if currentTick - lastTick >= 1 then
        local fps = math.floor(frameCount / (currentTick - lastTick))
        FpsOverlay.Text = "FPS: " .. tostring(fps)
        if fps < 30 then
            FpsOverlay.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif fps < 50 then
            FpsOverlay.TextColor3 = Color3.fromRGB(255, 220, 50)
        else
            FpsOverlay.TextColor3 = Color3.fromRGB(0, 255, 120)
        end
        frameCount = 0
        lastTick = currentTick
    end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.03, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 190, 0, 290)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "  hellsz"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Title
CloseButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -28, 0, 0)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "-"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 12

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 5, 0, 32)
ContentFrame.Size = UDim2.new(1, -10, 1, -36)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ContentFrame.ScrollBarThickness = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function sendChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannel = TextChatService.TextChannels.RBXGeneral
            if textChannel then
                textChannel:SendAsync(msg)
            end
        else
            local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                chatEvents.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

-- Função para criar botões de comandos
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ContentFrame
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = " " .. text
    btn.TextColor3 = Color3.fromRGB(210, 210, 210)
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Variáveis de controle do ESP e Render
local espEnabled = false
local renderEnabled = false

-- Função ESP Super Leve
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = head:FindFirstChild("ToshiESP")
            
            if espEnabled then
                if not billboard then
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "HellszESP"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 140, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Name = "Text"
                    textLabel.Parent = billboard
                    textLabel.BackgroundTransparency = 1
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
                    textLabel.TextSize = 10
                    textLabel.TextStrokeTransparency = 0.3
                    textLabel.TextWrapped = true

                    billboard.Parent = head
                end
                
                local displayName = p.DisplayName or p.Name
                local rpName = ""
                local rpBio = ""
                
                if p:FindFirstChild("RPName") and p.RPName.Value ~= "" then 
                    rpName = " [" .. tostring(p.RPName.Value) .. "]" 
                end
                if p:FindFirstChild("RPBio") and p.RPBio.Value ~= "" then 
                    rpBio = "\n" .. tostring(p.RPBio.Value) 
                end
                
                if billboard:FindFirstChild("Text") then
                    billboard.Text.Text = displayName .. rpName .. rpBio
                end
            else
                if billboard then 
                    billboard:Destroy() 
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if espEnabled then 
        updateESP() 
    end
end)

-- Botão de Toggle ESP (Bolinha On/Off sem texto)
local espContainer = Instance.new("Frame")
espContainer.Parent = ContentFrame
espContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
espContainer.BorderSizePixel = 0
espContainer.Size = UDim2.new(1, 0, 0, 26)

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 5)
espCorner.Parent = espContainer

local espLabel = Instance.new("TextLabel")
espLabel.Parent = espContainer
espLabel.BackgroundTransparency = 1
espLabel.Position = UDim2.new(0, 6, 0, 0)
espLabel.Size = UDim2.new(0.7, 0, 1, 0)
espLabel.Font = Enum.Font.GothamMedium
espLabel.Text = " ESP (Colorido + Nick/RP)"
espLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
espLabel.TextSize = 11
espLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleBg = Instance.new("TextButton")
toggleBg.Parent = espContainer
toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBg.BorderSizePixel = 0
toggleBg.Position = UDim2.new(1, -42, 0.5, -9)
toggleBg.Size = UDim2.new(0, 36, 0, 18)
toggleBg.Text = ""

local toggleBgCorner = Instance.new("UICorner")
toggleBgCorner.CornerRadius = UDim.new(1, 0)
toggleBgCorner.Parent = toggleBg

local toggleBall = Instance.new("Frame")
toggleBall.Parent = toggleBg
toggleBall.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
toggleBall.Position = UDim2.new(0, 2, 0.5, -7)
toggleBall.Size = UDim2.new(0, 14, 0, 14)

local toggleBallCorner = Instance.new("UICorner")
toggleBallCorner.CornerRadius = UDim.new(1, 0)
toggleBallCorner.Parent = toggleBall

toggleBg.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        toggleBg.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
        toggleBall.Position = UDim2.new(1, -16, 0.5, -7)
        toggleBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleBall.Position = UDim2.new(0, 2, 0.5, -7)
        toggleBall.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HellszESP") then
                p.Character.Head.HellszESP:Destroy()
            end
        end
    end
end)

-- Comandos do Painel
createButton("/Kill", function()
    sendChatMessage("/Kill")
    pcall(function()
        local tool = localPlayer.Backpack:FindFirstChildOfClass("Tool") or (localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool"))
        if tool then 
            tool:Activate() 
        end
    end)
end)

createButton("/Render", function()
    sendChatMessage("/Render")
    renderEnabled = not renderEnabled
    Lighting.Brightness = renderEnabled and 3 or 1
    Lighting.ClockTime = renderEnabled and 14 or 12
    Lighting.GlobalShadows = not renderEnabled
end)

createButton("/Algemar", function()
    sendChatMessage("/Algemar")
    pcall(function()
        ReplicatedStorage.RemoteEvent:FireServer("HandCuffs", "Add")
    end)
end)

createButton("/Revistar", function()
    sendChatMessage("/Revistar")
    pcall(function()
        ReplicatedStorage.RemoteEvent:FireServer("Revistar", true)
    end)
end)

createButton("/Cortar Comunicação", function()
    sendChatMessage("/Cortar Comunicação")
    pcall(function()
        localPlayer:SetVoiceChatEnabled(false)
    end)
end)

createButton("/Furar Pneu", function()
    sendChatMessage("/Furar Pneu")
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "VehicleSeat" and v.Occupant then
                local car = v.Parent
                if car then
                    for _, part in ipairs(car:GetDescendants()) do
                        if part:IsA("BasePart") and string.find(string.lower(part.Name), "wheel") then
                            part:Destroy()
                        end
                    end
                end
            end
        end
    end)
end)

createButton("/Rajar Heli", function()
    sendChatMessage("/Rajar Heli")
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if string.find(string.lower(v.Name), "heli") or string.find(string.lower(v.Name), "helicopter") then
                for _, p in ipairs(v:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p:Destroy()
                    end
                end
            end
        end
    end)
end)

createButton("/Head Shot", function()
    sendChatMessage("/Head Shot")
end)

-- Botão Minimizar
local isOpen = true
CloseButton.MouseButton1Click:Connect(function5 = function()
    isOpen = not isOpen
    ContentFrame.Visible = isOpen
    MainFrame.Size = isOpen and UDim2.new(0, 190, 0, 290) or UDim2.new(0, 190, 0, 28)
    CloseButton.Text = isOpen and "-" or "+"
end)
