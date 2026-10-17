-- Roblox Universal Cheat Suite (Delta Optimized)
-- Features: ESP (2D/3D/Tracers), Aim Assist, Silent Aim, Lock-on, NoClip, FullBright
-- Executor: Delta (or any executor with 'draw' support)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Prevent multiple instances
if getgenv().CheatActive then 
    warn("[Cheat] Already active.")
    return 
end
getgenv().CheatActive = true

-- ================= CONFIG =================
local Config = {
    -- ESP
    ESPEnabled = true,
    ESP2D = true,
    ESP3D = true,
    ESPTracers = true,
    ESPHealth = true,
    ESPNames = true,
    ESPDistance = true,
    ESPKillBox = false,
    ESPColor = Color3.fromRGB(0, 255, 128),
    ESPBoxColor = Color3.fromRGB(0, 255, 128),
    
    -- Aim
    AimAssist = true,
    AimStrength = 0.5, -- 0 to 1
    AimFOV = 120,
    AimSmoothness = 0.15,
    
    SilentAim = false,
    SilentAimStrength = 1.0,
    
    LockOn = false,
    LockOnDistance = 1000,
    
    -- Misc
    NoClip
