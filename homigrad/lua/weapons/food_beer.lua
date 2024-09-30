SWEP.Base = 'weapon_base'
AddCSLuaFile()
SWEP.PrintName = "Пиво"
SWEP.Author = "Нннн"
SWEP.Purpose = "Слабоалкогольный напиток"
SWEP.Category = "Вкусности"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/casual/food/w_heineken.mdl"
SWEP.WorldModel = "models/casual/food/w_heineken.mdl"
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

function SWEP:Initialize()
    self:SetHoldType( "slam" )
    if ( CLIENT ) then return end
end

if CLIENT then
    local beerEffect = false
    
    local function ApplyBeerEffect()
        if beerEffect then
            DrawSharpen(5, 1)
        end
    end

    hook.Add("RenderScreenspaceEffects", "BeerPostProcessing", ApplyBeerEffect)

    net.Receive("ActivateBeerEffect", function()
        beerEffect = true
    end)

    -- Обновленная функция для сброса эффекта
    local function ResetBeerEffect()
        beerEffect = false
    end

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
        self:GetOwner().adrenaline = self:GetOwner().adrenaline + 0
        self:GetOwner().stamina = self:GetOwner().stamina + 10
        self:GetOwner().nopain = true
        sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
        
        net.Start("ActivateBeerEffect")
        net.Send(self:GetOwner())
        
        self:GetOwner():SelectWeapon("weapon_hands")
        self:Remove()
    end
end

function SWEP:SecondaryAttack()
end