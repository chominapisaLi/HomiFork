SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Bhop Machine"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Стань настоящей бхоп машиной без какого-либо опыта"
SWEP.Category 				= "Фан"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 1
SWEP.SlotPos				= -100
SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true

SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModel				= "models/weapons/v_pist_deagle.mdl"

SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 75

function SWEP:Initialize()

end

function SWEP:Reload() end
