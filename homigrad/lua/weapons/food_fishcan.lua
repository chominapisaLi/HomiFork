SWEP.Base = 'weapon_base'
AddCSLuaFile()
SWEP.PrintName = "Банка Рыбы"
SWEP.Author = "Homigrad"
SWEP.Purpose = "Консервированная рыба"
SWEP.Category = "Вкусности"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/jordfood/atun.mdl"
SWEP.WorldModel = "models/jordfood/atun.mdl"
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

			-- Drop the empty can
			local can = ents.Create("prop_physics")
			can:SetModel(self.WorldModel)
			can:SetPos(ply:GetShootPos() + ply:GetAimVector() * 20)
			can:SetAngles(ply:EyeAngles())
			can:Spawn()

			-- Apply some force to make it look like it's being thrown
			local phys = can:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(ply:GetAimVector() * 100)
			end

			-- Remove the weapon from the player's hands
			self:Remove()
		end
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
        self:SetNWFloat("EatingStartTime", CurTime())
        self:SetNWBool("IsEating", true)
    end

    function SWEP:Think()
        if self:GetNWBool("IsEating") then
            local eatingProgress = math.min((CurTime() - self:GetNWFloat("EatingStartTime")) / 2, 1)
            if eatingProgress >= 1 then
                self:SetNWBool("IsEating", false)
            end
        end
    end

    function SWEP:GetViewModelPosition(pos, ang)
        if self:GetNWBool("IsEating") then
            local eatingProgress = math.min((CurTime() - self:GetNWFloat("EatingStartTime")) / 2, 1)
            -- Move the viewmodel towards the camera and to the side
            pos = pos - ang:Up() * (10 - eatingProgress * 20) + ang:Forward() * (30 - eatingProgress * 60) + ang:Right() * (7 + eatingProgress * 10)
            
            -- Rotate the viewmodel
            ang:RotateAroundAxis(ang:Up(), 90 + eatingProgress * 45)
            ang:RotateAroundAxis(ang:Right(), -10 - eatingProgress * 30)
            ang:RotateAroundAxis(ang:Forward(), -10 - eatingProgress * 20)

            -- Add some "eating" shake
            local shake = math.sin(CurTime() * 20) * (1 - eatingProgress) * 0.5
            pos = pos + ang:Right() * shake + ang:Up() * shake
        else
            -- Normal position when not eating
            pos = pos - ang:Up() * 10 + ang:Forward() * 30 + ang:Right() * 7
            ang:RotateAroundAxis(ang:Up(), 90)
            ang:RotateAroundAxis(ang:Right(), -10)
            ang:RotateAroundAxis(ang:Forward(), -10)
        end
        return pos, ang
    end
end

function SWEP:SecondaryAttack()
end