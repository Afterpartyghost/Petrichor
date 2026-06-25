-- core/config.lua
local Config = {
    Menu = {
        Title = "instance",
        Center = true,
        AutoShow = true,
        Size = { X = 700, Y = 600 },
    },
    
    Aimbot = {
        Enabled = false,
        Smoothness = 2,
        FOV = 150,
        HitPart = "Head",
        SilentEnabled = false,
        AutoShoot = false,
        HitChance = 100,
    },
    
    ESP = {
        Enabled = false,
        Box = false,
        BoxColor = Color3.fromRGB(0, 200, 255),
        HealthBar = false,
        Name = false,
        NameColor = Color3.fromRGB(255, 255, 255),
        Distance = false,
        Skeleton = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        Tracers = false,
        TracerColor = Color3.fromRGB(0, 200, 255),
        Chams = false,
        ChamsColor = Color3.fromRGB(0, 200, 255),
        ChamsTransparency = 0.3,
    },
    
    Combat = {
        NoSpread = false,
        NoRecoil = false,
        RapidFire = false,
        NoMuzzleFlash = false,
    },
    
    Movement = {
        Walkspeed = false,
        WalkspeedValue = 32,
        Fly = false,
        FlySpeed = 50,
    },
    
    AntiAim = {
        Enabled = false,
        Yaw = "none",
        Pitch = "none",
        Angle = "none",
        Speed = 10,
        Jitter = false,
        RandomAngle = false,
        Underground = false,
    },
    
    Visuals = {
        FOV = {
            Enabled = false,
            Color = Color3.fromRGB(0, 200, 255),
            Thickness = 1.5,
            Filled = false,
            FillTransparency = 0.5,
        },
        Crosshair = {
            Enabled = false,
            Color = Color3.fromRGB(0, 200, 255),
            Size = 10,
            Gap = 5,
            Dot = true,
        },
    },
    
    Misc = {
        ModDetector = { Enabled = true },
        AntiFlashbang = false,
        AntiTrip = false,
    },
    
    Ragebot = {
        Enabled = false,
        AutoTarget = false,
        AutoShoot = true,
        HitPart = "Head",
        Prediction = false,
        PredictionMultiplier = 1.2,
        VoidSpam = false,
    },
}

-- Add a print to confirm it loaded
print("✅ Config file loaded successfully!")
print("   Menu title: " .. (Config.Menu.Title or "NOT SET"))

return Config
