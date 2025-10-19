-- ========================================
-- KILLAURA AVANCÉ POUR LOOTIFY - SANS RAYFIELD
-- ========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Configuration
local KillauraSettings = {
    Enabled = false,
    Range = 50,
    HeightOffset = 0,
    ActiveSkills = {1, 2, 3, 4},
    SkillCooldowns = {
        [1] = 0.5,
        [2] = 2,
        [3] = 1.5,
        [4] = 3
    },
    LastSkillUse = {}
}

-- Fonction pour émuler les touches
local function emulateKey(keyCode)
    local success, error = pcall(function()
        UserInputService:SendKeyEvent(true, keyCode, false, game)
        wait(0.1)
        UserInputService:SendKeyEvent(false, keyCode, false, game)
    end)
    
    if not success then
        print("❌ Erreur émulation touche:", error)
    end
end

-- Interface simple
local function createSimpleUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillauraUI"
    screenGui.Parent = player.PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Titre
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "⚔️ KILLAURA LOOTIFY"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    -- Bouton fermer
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    -- Toggle Killaura
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 200, 0, 40)
    toggleBtn.Position = UDim2.new(0.5, -100, 0, 70)
    toggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "ACTIVER KILLAURA"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- Label portée
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(1, -20, 0, 30)
    rangeLabel.Position = UDim2.new(0, 10, 0, 130)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Text = "Portée: 50 studs"
    rangeLabel.TextColor3 = Color3.new(1, 1, 1)
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Gotham
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rangeLabel.Parent = mainFrame
    
    -- Slider portée
    local rangeSlider = Instance.new("Frame")
    rangeSlider.Size = UDim2.new(1, -20, 0, 20)
    rangeSlider.Position = UDim2.new(0, 10, 0, 170)
    rangeSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    rangeSlider.BorderSizePixel = 0
    rangeSlider.Parent = mainFrame
    
    local rangeSliderCorner = Instance.new("UICorner")
    rangeSliderCorner.CornerRadius = UDim.new(0, 10)
    rangeSliderCorner.Parent = rangeSlider
    
    local rangeFill = Instance.new("Frame")
    rangeFill.Size = UDim2.new(0.5, 0, 1, 0)
    rangeFill.BackgroundColor3 = Color3.new(0, 0.8, 0)
    rangeFill.BorderSizePixel = 0
    rangeFill.Parent = rangeSlider
    
    local rangeFillCorner = Instance.new("UICorner")
    rangeFillCorner.CornerRadius = UDim.new(0, 10)
    rangeFillCorner.Parent = rangeFill
    
    -- Label hauteur
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Size = UDim2.new(1, -20, 0, 30)
    heightLabel.Position = UDim2.new(0, 10, 0, 210)
    heightLabel.BackgroundTransparency = 1
    heightLabel.Text = "Hauteur: 0 studs"
    heightLabel.TextColor3 = Color3.new(1, 1, 1)
    heightLabel.TextScaled = true
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = mainFrame
    
    -- Slider hauteur
    local heightSlider = Instance.new("Frame")
    heightSlider.Size = UDim2.new(1, -20, 0, 20)
    heightSlider.Position = UDim2.new(0, 10, 0, 250)
    heightSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    heightSlider.BorderSizePixel = 0
    heightSlider.Parent = mainFrame
    
    local heightSliderCorner = Instance.new("UICorner")
    heightSliderCorner.CornerRadius = UDim.new(0, 10)
    heightSliderCorner.Parent = heightSlider
    
    local heightFill = Instance.new("Frame")
    heightFill.Size = UDim2.new(0.5, 0, 1, 0)
    heightFill.BackgroundColor3 = Color3.new(0, 0.5, 1)
    heightFill.BorderSizePixel = 0
    heightFill.Parent = heightSlider
    
    local heightFillCorner = Instance.new("UICorner")
    heightFillCorner.CornerRadius = UDim.new(0, 10)
    heightFillCorner.Parent = heightFill
    
    -- Boutons de compétences
    local skillsLabel = Instance.new("TextLabel")
    skillsLabel.Size = UDim2.new(1, -20, 0, 30)
    skillsLabel.Position = UDim2.new(0, 10, 0, 290)
    skillsLabel.BackgroundTransparency = 1
    skillsLabel.Text = "Compétences Actives:"
    skillsLabel.TextColor3 = Color3.new(1, 1, 1)
    skillsLabel.TextScaled = true
    skillsLabel.Font = Enum.Font.Gotham
    skillsLabel.TextXAlignment = Enum.TextXAlignment.Left
    skillsLabel.Parent = mainFrame
    
    local skillButtons = {}
    for i = 1, 4 do
        local skillBtn = Instance.new("TextButton")
        skillBtn.Size = UDim2.new(0, 70, 0, 40)
        skillBtn.Position = UDim2.new(0, 10 + (i-1) * 80, 0, 330)
        skillBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        skillBtn.BorderSizePixel = 0
        skillBtn.Text = tostring(i)
        skillBtn.TextColor3 = Color3.new(1, 1, 1)
        skillBtn.TextScaled = true
        skillBtn.Font = Enum.Font.GothamBold
        skillBtn.Parent = mainFrame
        
        local skillBtnCorner = Instance.new("UICorner")
        skillBtnCorner.CornerRadius = UDim.new(0, 8)
        skillBtnCorner.Parent = skillBtn
        
        skillButtons[i] = skillBtn
        
        -- Toggle compétence
        skillBtn.MouseButton1Click:Connect(function()
            local isActive = table.find(KillauraSettings.ActiveSkills, i)
            if isActive then
                table.remove(KillauraSettings.ActiveSkills, isActive)
                skillBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            else
                table.insert(KillauraSettings.ActiveSkills, i)
                skillBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
            end
        end)
    end
    
    -- Événements
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame:Destroy()
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        KillauraSettings.Enabled = not KillauraSettings.Enabled
        if KillauraSettings.Enabled then
            toggleBtn.Text = "DÉSACTIVER KILLAURA"
            toggleBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
        else
            toggleBtn.Text = "ACTIVER KILLAURA"
            toggleBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        end
    end)
    
    -- Slider portée
    rangeSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.Heartbeat:Connect(function()
                local mouseX = mouse.X
                local sliderX = rangeSlider.AbsolutePosition.X
                local sliderWidth = rangeSlider.AbsoluteSize.X
                local percentage = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
                
                rangeFill.Size = UDim2.new(percentage, 0, 1, 0)
                KillauraSettings.Range = math.floor(10 + percentage * 90)
                rangeLabel.Text = "Portée: " .. KillauraSettings.Range .. " studs"
                
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    -- Slider hauteur
    heightSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.Heartbeat:Connect(function()
                local mouseX = mouse.X
                local sliderX = heightSlider.AbsolutePosition.X
                local sliderWidth = heightSlider.AbsoluteSize.X
                local percentage = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
                
                heightFill.Size = UDim2.new(percentage, 0, 1, 0)
                KillauraSettings.HeightOffset = math.floor(-50 + percentage * 100)
                heightLabel.Text = "Hauteur: " .. KillauraSettings.HeightOffset .. " studs"
                
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- Logique killaura
local function findTargets()
    local targets = {}
    local character = player.Character
    if not character then return targets end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return targets end
    
    local position = humanoidRootPart.Position + Vector3.new(0, KillauraSettings.HeightOffset, 0)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRootPart then
                local distance = (otherRootPart.Position - position).Magnitude
                if distance <= KillauraSettings.Range then
                    table.insert(targets, otherPlayer)
                end
            end
        end
    end
    
    return targets
end

local function useSkill(skillId)
    local cooldown = KillauraSettings.SkillCooldowns[skillId]
    if not cooldown then return false end
    
    local now = tick()
    if KillauraSettings.LastSkillUse[skillId] and (now - KillauraSettings.LastSkillUse[skillId]) < cooldown then
        return false
    end
    
    KillauraSettings.LastSkillUse[skillId] = now
    
    -- Émuler la touche
    local keyCode = Enum.KeyCode.One
    if skillId == 1 then keyCode = Enum.KeyCode.One
    elseif skillId == 2 then keyCode = Enum.KeyCode.Two
    elseif skillId == 3 then keyCode = Enum.KeyCode.Three
    elseif skillId == 4 then keyCode = Enum.KeyCode.Four
    end
    
    emulateKey(keyCode)
    
    print("🎯 Touche " .. skillId .. " émulée!")
    return true
end

-- Boucle principale
RunService.Heartbeat:Connect(function()
    if not KillauraSettings.Enabled then return end
    
    local targets = findTargets()
    if #targets == 0 then return end
    
    -- Utiliser les touches actives
    for _, skillId in pairs(KillauraSettings.ActiveSkills) do
        if useSkill(skillId) then
            break
        end
    end
end)

-- Raccourcis clavier
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        createSimpleUI()
    elseif input.KeyCode == Enum.KeyCode.J then
        KillauraSettings.Enabled = not KillauraSettings.Enabled
        print("Killaura: " .. (KillauraSettings.Enabled and "ACTIVÉ" or "DÉSACTIVÉ"))
    end
end)

print("🎮 Killaura Lootify chargé!")
print("📋 Contrôles: K = Interface, J = Toggle")
print("⌨️ Émule les touches 1, 2, 3, 4 automatiquement!")
