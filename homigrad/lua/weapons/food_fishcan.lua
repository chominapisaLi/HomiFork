SWEP.Base = 'weapon_base'
AddCSLuaFile()
SWEP.PrintName = "Банка Рыбы"
SWEP.Author = "Homigrad"
SWEP.Purpose = "Консервированная рыба"
SWEP.Category = "Вкусности"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/banka3.mdl"
SWEP.WorldModel = "models/banka3.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawCrosshair = false

SWEP.EatingSound = "player/pl_scout_dodge_can_drink.wav"

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
    if SERVER then
        self:SetNextPrimaryFire(CurTime() + 3) -- Prevent spamming
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:EatingAnimation()
    end
end

function SWEP:EatingAnimation()
    if SERVER then
        local ply = self:GetOwner()
        local eatingTime = 2 -- Duration of eating animation in seconds

        if IsValid(self) and IsValid(ply) then
            ply.hungryregen = ply.hungryregen + 2

            self:EmitSound(self.EatingSound)

            -- Start the eating animation
            self:SetNWBool("IsEating", true)
            self:SetNWFloat("EatingStartTime", CurTime())

            timer.Simple(eatingTime, function()
                if IsValid(self) and IsValid(ply) then
                    self:SetNWBool("IsEating", false)
                    self:DropEmptyCan(ply)
                    self:Remove()
                end
            end)
        end
    end
end

function SWEP:DropEmptyCan(ply)
    local can = ents.Create("prop_physics")
    can:SetModel(self.WorldModel)
    can:SetPos(ply:GetShootPos() + ply:GetAimVector() * 20)
    can:SetAngles(ply:EyeAngles())
    can:Spawn()

    local phys = can:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * 100)
    end
end

if CLIENT then
    local WorldModel = ClientsideModel(SWEP.WorldModel)
    WorldModel:SetNoDraw(true)

    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()

        if IsValid(owner) then
            local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
            if !boneid then return end

            local matrix = owner:GetBoneMatrix(boneid)
            if !matrix then return end

            local newPos, newAng
            local offsetVec = Vector(4, -1, 0)
            local offsetAng = Angle(180, -45, 90)


            newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

            WorldModel:SetPos(newPos)
            WorldModel:SetAngles(newAng)
            WorldModel:SetupBones()
        else
            WorldModel:SetPos(self:GetPos())
            WorldModel:SetAngles(self:GetAngles())
        end

        WorldModel:DrawModel()
    end
    function SWEP:PrimaryAttack()
        if !IsFirstTimePredicted() then return end
        self:EmitSound(self.EatingSound)
    end
end

function SWEP:SecondaryAttack()
end