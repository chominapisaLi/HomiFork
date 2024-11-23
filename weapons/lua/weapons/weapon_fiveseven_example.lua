-- example for bg_weapon

SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "FiveSeven - ShowCase"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Пистолет под калибр 9х19"
SWEP.Category 				= "test_sweps"
SWEP.WepSelectIcon			= "pwb2/vgui/weapons/usptactical"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 9999
SWEP.Primary.DefaultClip	= 9999
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "9х19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 26
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "hndg_beretta92fs/beretta92_fire1.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_smp_far.wav"
SWEP.Primary.Force = 90/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.14

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "revolver"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/arccw_go/v_pist_fiveseven.mdl"
SWEP.WorldModel				= "models/weapons/arccw_go/v_pist_fiveseven.mdl"
SWEP.BadWorldModel = true 
SWEP.FlipModel = true   
SWEP.WorldModelPos = {
    Forward = -12,    -- Сдвиг вперед/назад
    Right = 4.5,      -- Сдвиг вправо/влево
    Up = -5       -- Сдвиг вверх/вниз
}

SWEP.WorldModelAng = {
    Forward = 0,    -- Поворот вокруг оси forward
    Right = 180,    -- Поворот вокруг оси right
    Up = 0         -- Поворот вокруг оси up
}

SWEP.MuzzlePos = {
    Forward = -0.75,
    Right = 0.39,
    Up = 3
}
SWEP.vbwPos = Vector(6.5,3.4,-4)


SWEP.addPos = Vector(0,-5,-9)
SWEP.addAng = Angle(0,0,0)