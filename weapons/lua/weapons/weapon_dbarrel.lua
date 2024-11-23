-- example for bg_weapon

SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "Double Barrel - ShowCase"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Пистолет под калибр 9х19"
SWEP.Category 				= "test_sweps"
SWEP.WepSelectIcon			= "pwb2/vgui/weapons/usptactical"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 50
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "rifle_win1892/win1892_fire_01.wav"
SWEP.Primary.SoundFar = "toz_shotgun/toz_dist.wav"
SWEP.Primary.Force = 15
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.4
SWEP.NumBullet = 8
SWEP.Sight = true
SWEP.TwoHands = true
SWEP.shotgun = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= ""
SWEP.WorldModel				= "models/weapons/tfa_ins2/w_doublebarrel.mdl"
SWEP.BadWorldModel = true 
SWEP.FlipModel = true   
SWEP.WorldModelPos = {
    Forward = 0,    -- Сдвиг вперед/назад
    Right = 0,      -- Сдвиг вправо/влево
    Up = -2.9       -- Сдвиг вверх/вниз
}

SWEP.WorldModelAng = {
    Forward = 0,    -- Поворот вокруг оси forward
    Right = 180,    -- Поворот вокруг оси right
    Up = 0         -- Поворот вокруг оси up
}
SWEP.vbwPos = Vector(6.5,3.4,-4)


SWEP.addPos = Vector(0,0,-0.9)
SWEP.addAng = Angle(-0.4,0.5,0)