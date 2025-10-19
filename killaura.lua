-- ========================================
-- KILLAURA AVANCÉ POUR LOOTIFY
-- ========================================
-- Créé par: Votre Nom
-- Version: 1.0
-- Description: Système de killaura avec interface Rayfield

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Charger Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

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

-- Interface Rayfield
local function createKillauraUI()
    local Window = Rayfield:CreateWindow({
        Name = "⚔️ Killaura Lootify",
        LoadingTitle = "Chargement du Killaura...",
        LoadingSubtitle = "Initialisation des compétences",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "KillauraLootify",
            FileName = "KillauraConfig"
        },
        KeySystem = false
    })
    
    -- ========================================
    -- ONGLET PRINCIPAL
    -- ========================================
    
    local MainTab = Window:CreateTab("🎯 Killaura", 4483362458)
    
    -- Toggle principal
    local KillauraToggle = MainTab:CreateToggle({
        Name = "Activer Killaura",
        CurrentValue = false,
        Flag = "KillauraEnabled",
        Callback = function(Value)
            KillauraSettings.Enabled = Value
            if Value then
                Rayfield:Notify({
                    Title = "Killaura Activé",
                    Content = "Émulation des touches 1,2,3,4 active !",
                    Duration = 3,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Killaura Désactivé",
                    Content = "Émulation des touches arrêtée.",
                    Duration = 3,
                    Image = 4483362458
                })
            end
        end,
    })
    
    -- Slider portée
    local RangeSlider = MainTab:CreateSlider({
        Name = "Portée d'attaque",
        Range = {10, 100},
        Increment = 5,
        Suffix = " studs",
        CurrentValue = 50,
        Flag = "KillauraRange",
        Callback = function(Value)
            KillauraSettings.Range = Value
        end,
    })
    
    -- Slider hauteur
    local HeightSlider = MainTab:CreateSlider({
        Name = "Hauteur du personnage",
        Range = {-50, 50},
        Increment = 1,
        Suffix = " studs",
        CurrentValue = 0,
        Flag = "CharacterHeight",
        Callback = function(Value)
            KillauraSettings.HeightOffset = Value
        end,
    })
    
    -- ========================================
    -- ONGLET TOUCHES
    -- ========================================
    
    local KeysTab = Window:CreateTab("⌨️ Touches", 4483362458)
    
    -- Toggle touche 1
    local Key1Toggle = KeysTab:CreateToggle({
        Name = "Touche 1 (Cooldown: 0.5s)",
        CurrentValue = true,
        Flag = "Key1Enabled",
        Callback = function(Value)
            if Value then
                table.insert(KillauraSettings.ActiveSkills, 1)
            else
                local index = table.find(KillauraSettings.ActiveSkills, 1)
                if index then
                    table.remove(KillauraSettings.ActiveSkills, index)
                end
            end
        end,
    })
    
    -- Toggle touche 2
    local Key2Toggle = KeysTab:CreateToggle({
        Name = "Touche 2 (Cooldown: 2s)",
        CurrentValue = true,
        Flag = "Key2Enabled",
        Callback = function(Value)
            if Value then
                table.insert(KillauraSettings.ActiveSkills, 2)
            else
                local index = table.find(KillauraSettings.ActiveSkills, 2)
                if index then
                    table.remove(KillauraSettings.ActiveSkills, index)
                end
            end
        end,
    })
    
    -- Toggle touche 3
    local Key3Toggle = KeysTab:CreateToggle({
        Name = "Touche 3 (Cooldown: 1.5s)",
        CurrentValue = true,
        Flag = "Key3Enabled",
        Callback = function(Value)
            if Value then
                table.insert(KillauraSettings.ActiveSkills, 3)
            else
                local index = table.find(KillauraSettings.ActiveSkills, 3)
                if index then
                    table.remove(KillauraSettings.ActiveSkills, index)
                end
            end
        end,
    })
    
    -- Toggle touche 4
    local Key4Toggle = KeysTab:CreateToggle({
        Name = "Touche 4 (Cooldown: 3s)",
        CurrentValue = true,
        Flag = "Key4Enabled",
        Callback = function(Value)
            if Value then
                table.insert(KillauraSettings.ActiveSkills, 4)
            else
                local index = table.find(KillauraSettings.ActiveSkills, 4)
                if index then
                    table.remove(KillauraSettings.ActiveSkills, index)
                end
            end
        end,
    })
    
    -- ========================================
    -- ONGLET STATISTIQUES
    -- ========================================
    
    local StatsTab = Window:CreateTab("📊 Stats", 4483362458)
    
    local StatsLabel = StatsTab:CreateLabel("Statistiques du Killaura")
    local KillsLabel = StatsTab:CreateLabel("Cibles détectées: 0")
    local TimeLabel = StatsTab:CreateLabel("Temps actif: 0s")
    
    local startTime = tick()
    local killCount = 0
    
    -- ========================================
    -- LOGIQUE KILLAURA
    -- ========================================
    
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
    local killauraConnection
    killauraConnection = RunService.Heartbeat:Connect(function()
        if not KillauraSettings.Enabled then return end
        
        local targets = findTargets()
        if #targets == 0 then return end
        
        -- Mettre à jour les stats
        killCount = killCount + 1
        local activeTime = math.floor(tick() - startTime)
        KillsLabel:Set("Cibles détectées: " .. killCount)
        TimeLabel:Set("Temps actif: " .. activeTime .. "s")
        
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
            Window:Toggle()
        elseif input.KeyCode == Enum.KeyCode.J then
            KillauraSettings.Enabled = not KillauraSettings.Enabled
            KillauraToggle:Set(KillauraSettings.Enabled)
        end
    end)
    
    print("🎮 Killaura Lootify chargé!")
    print("📋 Contrôles: K = Interface, J = Toggle")
    print("⌨️ Émule les touches 1, 2, 3, 4 automatiquement!")
end

-- Initialiser l'interface
createKillauraUI()
