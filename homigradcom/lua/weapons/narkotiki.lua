SWEP.Base = 'weapon_base'
SWEP.PrintName = "Психотропные Вещества"
SWEP.Author = "thebogler"
SWEP.Purpose = "Не п"
SWEP.Category = "Вкусности"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/w_models/w_syringe.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_syringe.mdl"
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

    narkoEffect = false
    usedDrug = false 

    local function ApplyNarkoEffect()
        if narkoEffect then
            DrawSharpen(5, 5)
        end
    end

    local function ShowImageAndPlaySound()
        if usedDrug then

            local image = {}
            for i = 1,8 do
                image[#image + 1] = "icons/memes/meme"..i..".png"
            end
            local soundEffect = Sound("vine-boom.mp3") 

            local imgPanel = vgui.Create("DImage")
            local random = math.random
            imgPanel:SetImage(image[math.random(#image)])
            imgPanel:SetPos(ScrW() / random(1.2,2) - 128, ScrH() / random(1.2,2) - 128) 
            imgPanel:SetSize(256 / random(0.5,1), 256 / random(0.5,1))
            
            sound.Play(soundEffect, LocalPlayer():GetPos())

            timer.Simple(1, function()
                imgPanel:Remove()
            end)
        end
    end

    hook.Add("RenderScreenspaceEffects", "NarkoPostProcessing", ApplyNarkoEffect)
    function ResetnarkoEffect()
        usedDrug = false
        narkoEffect = false
    end
    timer.Create("DrugEffectTimer", 15, 0, function()
        ShowImageAndPlaySound()
    end)

    net.Receive("ActivateNarkoEffect", function()
        narkoEffect = true
        usedDrug = true -- Устанавливаем флаг использования
        timer.Create('Akvapark', 120, 0, function()
            ResetnarkoEffect()
            usedDrug = false -- Сбрасываем флаг, когда эффект закончился
        end)
    end)
    hook.Add("PlayerDeath", "ActivateNarkoEffectOnDeath", ResetnarkoEffect)
    hook.Add("OnPlayerRespawn", "RActivateNarkoEffectOnRespawn", ResetnarkoEffect)
    hook.Add("PlayerSpawn", "ActivateNarkoEffectOnSpawn", ResetnarkoEffect)


    hook.Add("Think", "CheckBeerEffect", function()
        
        if not LocalPlayer():Alive() and narkoEffect then
            ResetRumEffect()
        end
    end)
end

if SERVER then
    util.AddNetworkString("ActivateNarkoEffect")
end


function SWEP:PrimaryAttack()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    if SERVER then
        self:GetOwner().hungryregen = self:GetOwner().hungryregen + 1
        self:GetOwner().adrenaline = self:GetOwner().adrenaline + 1
        self:GetOwner().stamina = self:GetOwner().stamina + 10

        sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
        
        net.Start("ActivateNarkoEffect")
        net.Send(self:GetOwner())
        
        self:GetOwner():SelectWeapon("weapon_hands")
        self:Remove()
    end
end
function SWEP:SecondaryAttack()
end
