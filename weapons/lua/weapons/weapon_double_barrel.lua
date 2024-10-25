SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "Sawed-Off"
SWEP.Author 				= "нннн"
SWEP.Instructions			= "Sawed-Off — это тип ружья с более коротким стволом под калибр 12/70"
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.05
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "snd_jack_hmcd_sht_close.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_sht_far.wav"
SWEP.Primary.Force = 15
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.5
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
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/csgo/weapons/w_shot_sawedoff.mdl"
SWEP.WorldModel				= "models/csgo/weapons/w_shot_sawedoff.mdl"

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(5,math.Rand(-2,2),0)
end

SWEP.vbwPos = Vector(-9,-5,-5)

SWEP.CLR_Scope = 1
SWEP.CLR = 0.025

SWEP.addAng = Angle(2.5,0.1,0)
SWEP.addPos = Vector(0,0,0)
