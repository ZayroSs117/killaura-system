-- ========================================
-- KILLAURA LOOTIFY - INTERFACE CLEAN
-- ========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Charger une lib UI moderne
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

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

-- Interface clean
local function createCleanUI()
    local Window = Library.CreateLib("⚔️ Killaura Lootify", "DarkTheme")
    
    -- Onglet principal
    local MainTab = Window:NewTab("Killaura")
    local MainSection = MainTab:NewSection("Configuration")
    
    -- Toggle principal
    local KillauraToggle = MainSection:NewToggle("Activer Killaura", "Active/Désactive le killaura", function(Value)
        KillauraSettings.Enabled = Value
        if Value then
            Library:Notification("Killaura Activé", "Émulation des touches 1,2,3,4 active !", 3)
        else
            Library:Notification("Killaura Désactivé", "Émulation des touches arrêtée.", 3)
        end
    end)
    
    -- Slider portée
    local RangeSlider = MainSection:NewSlider("Portée", "Portée d'attaque en studs", 100, 10, function(Value)
        KillauraSettings.Range = Value
    end)
    RangeSlider:SetValue(50)
    
    -- Slider hauteur
    local HeightSlider = MainSection:NewSlider("Hauteur", "Hauteur du personnage", 100, -50, function(Value)
        KillauraSettings.HeightOffset = Value
    end)
    HeightSlider:SetValue(0)
    
    -- Onglet compétences
    local SkillsTab = Window:NewTab("Compétences")
    local SkillsSection = SkillsTab:NewSection("Touches Actives")
    
    -- Toggle compétence 1
    local Skill1Toggle = SkillsSection:NewToggle("Touche 1", "Cooldown: 0.5s", function(Value)
        if Value then
            table.insert(KillauraSettings.ActiveSkills, 1)
        else
            local index = table.find(KillauraSettings.ActiveSkills, 1)
            if index then
                table.remove(KillauraSettings.ActiveSkills, index)
            end
        end
    end)
    Skill1Toggle:SetValue(true)
    
    -- Toggle compétence 2
    local Skill2Toggle = SkillsSection:NewToggle("Touche 2", "Cooldown: 2s", function(Value)
        if Value then
            table.insert(KillauraSettings.ActiveSkills, 2)
        else
            local index = table.find(KillauraSettings.ActiveSkills, 2)
            if index then
                table.remove(KillauraSettings.ActiveSkills, index)
            end
        end
    end)
    Skill2Toggle:SetValue(true)
    
    -- Toggle compétence 3
    local Skill3Toggle = SkillsSection:NewToggle("Touche 3", "Cooldown: 1.5s", function(Value)
        if Value then
            table.insert(KillauraSettings.ActiveSkills, 3)
        else
            local index = table.find(KillauraSettings.ActiveSkills, 3)
            if index then
                table.remove(KillauraSettings.ActiveSkills, index)
            end
        end
    end)
    Skill3Toggle:SetValue(true)
    
    -- Toggle compétence 4
    local Skill4Toggle = SkillsSection:NewToggle("Touche 4", "Cooldown: 3s", function(Value)
        if Value then
            table.insert(KillauraSettings.ActiveSkills, 4)
        else
            local index = table.find(KillauraSettings.ActiveSkills, 4)
            if index then
                table.remove(KillauraSettings.ActiveSkills, index)
            end
        end
    end)
    Skill4Toggle:SetValue(true)
    
    -- Onglet stats
    local StatsTab = Window:NewTab("Statistiques")
    local StatsSection = StatsTab:NewSection("Performance")
    
    local StatsLabel = StatsSection:NewLabel("Cibles détectées: 0")
    local TimeLabel = StatsSection:NewLabel("Temps actif: 0s")
    
    local startTime = tick()
    local killCount = 0
    
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
        
        -- Mettre à jour les stats
        killCount = killCount + 1
        local activeTime = math.floor(tick() - startTime)
        StatsLabel:UpdateLabel("Cibles détectées: " .. killCount)
        TimeLabel:UpdateLabel("Temps actif: " .. activeTime .. "s")
        
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
            Library:ToggleUI()
        elseif input.KeyCode == Enum.KeyCode.J then
            KillauraSettings.Enabled = not KillauraSettings.Enabled
            KillauraToggle:SetValue(KillauraSettings.Enabled)
        end
    end)
    
    print("🎮 Killaura Lootify chargé!")
    print("📋 Contrôles: K = Interface, J = Toggle")
    print("⌨️ Émule les touches 1, 2, 3, 4 automatiquement!")
end

-- Initialiser l'interface
createCleanUI()
