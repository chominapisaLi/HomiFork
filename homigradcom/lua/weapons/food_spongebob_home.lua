SWEP.Base = 'weapon_base'
AddCSLuaFile()
SWEP.PrintName = "Банка ананасов"
SWEP.Author = "Homigrad"
SWEP.Purpose = "Консервированные ананасы"
SWEP.Category = "Вкусности"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/jordfood/can.mdl"
SWEP.WorldModel = "models/jordfood/can.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawCrosshair = false

local healsound = Sound("snd_jack_hmcd_eat"..math.random(1,4)..".wav")
local angZero = Angle(0,0,0)

function SWEP:Initialize()
    self:SetHoldType("slam")
    self:SetNWBool("CanBeUsed", true)
    if CLIENT then return end
end

function SWEP:Deploy()
    self:SetNWBool("CanBeUsed", true)
    return true
end

function SWEP:Holster()
    if CLIENT then
        local owner = self:GetOwner()
        if IsValid(owner) and owner:IsPlayer() and owner == LocalPlayer() then
            owner:SetEyeAngles(owner:EyeAngles()) -- Reset view angles
        end
	else
		local owner = self:GetOwner()
        local boneID = owner:LookupBone("ValveBiped.Bip01_R_Forearm")
        local handBoneID = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        
        if boneID and handBoneID then
            local newForearmAngle = Angle(0, 0, 0)
            local newHandAngle = Angle(0, 0, 0)
            
            owner:ManipulateBoneAngles(boneID, newForearmAngle)
            owner:ManipulateBoneAngles(handBoneID, newHandAngle)
		end
    end
    return true
end

if CLIENT then
    function SWEP:PreDrawViewModel(vm, wep, ply)
    end
    
    function SWEP:GetViewModelPosition(pos, ang)
        pos = pos - ang:Up() * 10 + ang:Forward() * 30 + ang:Right() * 7
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Right(), -10)
        ang:RotateAroundAxis(ang:Forward(), -10)
        return pos, ang
    end
    
    local WorldModel = ClientsideModel(SWEP.WorldModel)
    WorldModel:SetNoDraw(true)
    
    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()
        if IsValid(owner) then
            local offsetVec = Vector(4, -1, 0)
            local offsetAng = Angle(180, -45, 90)
            local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
            
            if not boneid then return end
            local matrix = owner:GetBoneMatrix(boneid)
            if not matrix then return end
            
            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
            WorldModel:SetPos(newPos)
            WorldModel:SetAngles(newAng)
            WorldModel:SetupBones()
        else
            WorldModel:SetPos(self:GetPos())
            WorldModel:SetAngles(self:GetAngles())
        end
        WorldModel:DrawModel()
    end
end

function SWEP:PrimaryAttack()
    if not self:GetNWBool("CanBeUsed") then return end

    self:SetNextPrimaryFire(CurTime() + 2)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    
    if SERVER then
        local owner = self:GetOwner()
        local boneID = owner:LookupBone("ValveBiped.Bip01_R_Forearm")
        local handBoneID = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        
        if boneID and handBoneID then
            local newForearmAngle = Angle(0, -60, 0)
            local newHandAngle = Angle(0, 0, 0)
            
            owner:ManipulateBoneAngles(boneID, newForearmAngle)
            owner:ManipulateBoneAngles(handBoneID, newHandAngle)
            
            self:SetNWBool("IsEating", true)
            self:SetNWBool("CanBeUsed", false)
            
            timer.Create("EatingAnimation" .. self:EntIndex(), 2, 1, function()
                if IsValid(owner) then
                    owner:ManipulateBoneAngles(boneID, angZero)
                    owner:ManipulateBoneAngles(handBoneID, angZero)
                    self:SetNWBool("IsEating", false)
                    
                    owner.hungryregen = owner.hungryregen + 1
                    
                    local can = ents.Create("prop_physics")
                    can:SetModel(self.WorldModel)
                    can:SetPos(owner:GetShootPos() + owner:GetAimVector() * 30)
                    can:SetAngles(owner:EyeAngles())
                    can:Spawn()
                    
                    local phys = can:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:SetVelocity(owner:GetAimVector() * 100)
                    end
                    
                    self:Remove()
                    owner:SelectWeapon("weapon_hands")
                end
            end)
        end
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    if CLIENT and self:GetNWBool("IsEating") then
        local owner = self:GetOwner()
        if IsValid(owner) and owner:IsPlayer() and owner == LocalPlayer() then
            local shakeOffset = math.sin(CurTime() * 20) * 0.5
            owner:SetEyeAngles(owner:EyeAngles() + Angle(shakeOffset, 0, 0))
        end
        
        if not self.NextEatSound or CurTime() > self.NextEatSound then
            self.NextEatSound = CurTime() + 1
            sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
        end
    end
end