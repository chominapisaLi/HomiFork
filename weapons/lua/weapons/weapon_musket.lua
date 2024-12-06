SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "Мушкет"
SWEP.Author 				= "thebogler"
SWEP.Instructions			= "Один патрон - 1 жизнь"
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 999
SWEP.Primary.DefaultClip	= 999
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.05
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "rifle_win1892/win1892_fire_01.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_snp_far.wav"
SWEP.Primary.Force = 15
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.2
SWEP.NumBullet = 8
SWEP.Sight = true
SWEP.TwoHands = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"
SWEP.shotgun = true

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/tfa_ins2/w_winchester_1894.mdl"
SWEP.WorldModel				= "models/weapons/tfa_ins2/w_winchester_1894.mdl"



SWEP.vbwPos = Vector(0,-10,0)

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025

SWEP.addPos = Vector(0,0,0)
SWEP.addAng = Angle(0,0,0)
SWEP.BadWorldModel = true 
SWEP.FlipModel = true    
SWEP.WorldModelPos = {
    Forward = 4,    -- Сдвиг вперед/назад
    Right = 0,      -- Сдвиг вправо/влево
    Up = -2.9      -- Сдвиг вверх/вниз
}

SWEP.WorldModelAng = {
    Forward = 0,    -- Поворот вокруг оси forward
    Right = 180,    -- Поворот вокруг оси right
    Up = 0         -- Поворот вокруг оси up
}
SWEP.dwmModeScale = 1
SWEP.dwmForward = 10
SWEP.dwmRight = 0
SWEP.dwmUp = -3

SWEP.dwmAUp = 0
SWEP.dwmARight = 0
SWEP.dwmAForward = 180
local model 
if CLIENT then
    model = GDrawWorldModel or ClientsideModel(SWEP.WorldModel,RENDER_GROUP_OPAQUE_ENTITY)
    GDrawWorldModel = model
    model:SetNoDraw(true)
end

if SERVER then
    function SWEP:GetPosAng()
        local owner = self:GetOwner()
        local Pos,Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
        if not Pos then return end
        
        Pos:Add(Ang:Forward() * self.dwmForward)
        Pos:Add(Ang:Right() * self.dwmRight)
        Pos:Add(Ang:Up() * self.dwmUp)


        Ang:RotateAroundAxis(Ang:Up(),self.dwmAUp)
        Ang:RotateAroundAxis(Ang:Right(),self.dwmARight)
        Ang:RotateAroundAxis(Ang:Forward(),self.dwmAForward)

        return Pos,Ang
    end
else
    function SWEP:SetPosAng(Pos,Ang)
        self.Pos = Pos
        self.Ang = Ang
    end
    function SWEP:GetPosAng()
        return self.Pos,self.Ang
    end
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:DrawModel()

        return
    end
    model:SetModel(self.WorldModel)

    local Pos,Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
    if not Pos then return end
    
    Pos:Add(Ang:Forward() * self.dwmForward)
    Pos:Add(Ang:Right() * self.dwmRight)
    Pos:Add(Ang:Up() * self.dwmUp)


    Ang:RotateAroundAxis(Ang:Up(),self.dwmAUp)
    Ang:RotateAroundAxis(Ang:Right(),self.dwmARight)
    Ang:RotateAroundAxis(Ang:Forward(),self.dwmAForward)
    
    self:SetPosAng(Pos,Ang)

    model:SetPos(Pos)
    model:SetAngles(Ang)

    model:SetModelScale(self.dwmModeScale)

    model:DrawModel()
end