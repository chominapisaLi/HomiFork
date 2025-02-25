SWEP.Base = 'weapon_base'
AddCSLuaFile()

SWEP.PrintName = "Армейский поёк"
SWEP.Author = "Нннн"
SWEP.Purpose = "Набор продуктов, предназначенный для питания военнослужащих"
SWEP.Category = "Вкусности"

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/irp.mdl"
SWEP.WorldModel = "models/irp.mdl"
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



local healsound = Sound("snd_jack_hmcd_eat"..math.random(1,4)..".wav")
function SWEP:Initialize()
	self:SetHoldType( "slam" )
	if ( CLIENT ) then return end
end

if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,wep,ply)
	end
	function SWEP:GetViewModelPosition(pos,ang)
		pos=pos-ang:Up()*10+ang:Forward()*30+ang:Right()*7
		ang:RotateAroundAxis(ang:Up(),90)
		ang:RotateAroundAxis(ang:Right(),-10)
		ang:RotateAroundAxis(ang:Forward(),-10)
		return pos,ang
	end
	if CLIENT then
		local WorldModel = ClientsideModel(SWEP.WorldModel)
	
		WorldModel:SetNoDraw(true)
	
		function SWEP:DrawWorldModel()
			local _Owner = self:GetOwner()
	
			if (IsValid(_Owner)) then
				-- Specify a good position
				local offsetVec = Vector(4,-1,0)
				local offsetAng = Angle(180, -45, 90)
				
				local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
				if !boneid then return end
	
				local matrix = _Owner:GetBoneMatrix(boneid)
				if !matrix then return end
	
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
end
function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if(SERVER)then
		self:GetOwner().hungryregen = self:GetOwner().hungryregen + 10
		self:Remove()
		sound.Play(healsound, self:GetPos(),75,100,0.5)
		self:GetOwner():SelectWeapon("weapon_hands")
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

function SWEP:SecondaryAttack()
end
