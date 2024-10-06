SWEP.Base = 'weapon_base'
AddCSLuaFile()

SWEP.PrintName = "Банка тушёнки"
SWEP.Author = "Нннн"
SWEP.Purpose = "Консервированный мясной продукт"
SWEP.Category = "Вкусности"

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/banka.mdl"
SWEP.WorldModel = "models/banka.mdl"
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

local healsound = Sound("snd_jack_hmcd_eat1.wav")

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:DropEmptyCan(ply)
    if not IsValid(ply) then return end

    local can = ents.Create("prop_physics")
    if not IsValid(can) then return end

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
    local WorldModel

    function SWEP:PreDrawViewModel(vm, wep, ply)
        -- Можно добавить кастомную настройку, если требуется изменить отображение ViewModel
    end

    function SWEP:GetViewModelPosition(pos, ang)
        pos = pos - ang:Up() * 10 + ang:Forward() * 30 + ang:Right() * 7
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Right(), -10)
        ang:RotateAroundAxis(ang:Forward(), -10)
        return pos, ang
    end

    function SWEP:DrawWorldModel()
        if not IsValid(WorldModel) then
            WorldModel = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
            WorldModel:SetNoDraw(true)
        end

        local owner = self:GetOwner()

        if IsValid(owner) then
            local offsetVec = Vector(5, -3.5, -2)
            local offsetAng = Angle(0, 0, 0)

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

    function SWEP:OnRemove()
        if IsValid(WorldModel) then
            WorldModel:Remove()
        end
    end

    function SWEP:Holster()
        if IsValid(WorldModel) then
            WorldModel:Remove()
        end
        return true
    end
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    ply:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        ply.hungryregen = (ply.hungryregen or 0) + 2
        self:DropEmptyCan(ply)
        self:Remove()
        sound.Play(healsound, ply:GetPos(), 75, 100, 0.5)
        ply:SelectWeapon("weapon_hands")
    end
end

function SWEP:EatingAnimation()
    if SERVER then
        local ply = self:GetOwner()

        if IsValid(self) and IsValid(ply) then
            ply.hungryregen = (ply.hungryregen or 0) + 2
            self:DropEmptyCan(ply)
            self:Remove()
        end
    end
end

function SWEP:SecondaryAttack()
    -- Здесь нет вторичного действия, оставляем пустым
end
