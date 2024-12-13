SWEP.Base = 'weapon_base'
AddCSLuaFile()
SWEP.PrintName = "Водка"
SWEP.Author = "Нннн"
SWEP.Purpose = "Крепкий алкогольный напиток"
SWEP.Category = "Вкусности"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/vodka.mdl"
SWEP.WorldModel = "models/vodka.mdl"
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

local healsound = Sound("snd_jack_hmcd_drink"..math.random(1,3)..".wav")



if CLIENT then
    local WorldModel = ClientsideModel(SWEP.WorldModel)
	
    WorldModel:SetNoDraw(true)

    function SWEP:DrawWorldModel()
        local _Owner = self:GetOwner()

        if (IsValid(_Owner)) then
            -- Specify a good position
            local offsetVec = Vector(5,-2,7)
            local offsetAng = Angle(180, 360, 0)
            
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
    local beerEffect = false
    
    local function ApplyBeerEffect()
        if beerEffect then
            DrawSharpen(5, 1)
        end
    end

    hook.Add("RenderScreenspaceEffects", "BeerPostProcessing", ApplyBeerEffect)
    -- Обновленная функция для сброса эффекта
    function ResetBeerEffect()
        beerEffect = false
    end
    net.Receive("ActivateBeerEffect", function()
        beerEffect = true
        timer.Create('Akvapark',120,0,function()
            ResetBeerEffect()          
        end)
    end)


    -- Добавляем несколько хуков для гарантированного сброса эффекта
    hook.Add("PlayerDeath", "ResetBeerEffectOnDeath", ResetBeerEffect)
    hook.Add("OnPlayerRespawn", "ResetBeerEffectOnRespawn", ResetBeerEffect)
    hook.Add("PlayerSpawn", "ResetBeerEffectOnSpawn", ResetBeerEffect)

    -- Дополнительная проверка каждый кадр
    hook.Add("Think", "CheckBeerEffect", function()
        
        if not LocalPlayer():Alive() and beerEffect then
            ResetBeerEffect()
        end
    end)
end

if SERVER then
    util.AddNetworkString("ActivateBeerEffect")
end

function SWEP:PrimaryAttack()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    if SERVER then
        self:GetOwner().hungryregen = self:GetOwner().hungryregen + 1
        self:GetOwner().adrenaline = self:GetOwner().adrenaline + 1
        self:GetOwner().stamina = self:GetOwner().stamina + 10

        sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
        
        net.Start("ActivateBeerEffect")
        net.Send(self:GetOwner())
        
        self:GetOwner():SelectWeapon("weapon_hands")
        self:Remove()
    end
end

function SWEP:SecondaryAttack()
end
