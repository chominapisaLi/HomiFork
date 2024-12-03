SWEP.PrintName = "Деревянная бита Грени"

SWEP.Category = "Ближний Бой"
SWEP.Instructions = "Часть спортивного инвентаря, предназначенная для нанесения ударов по мячу. Также популярно как холодное оружие благодаря своему удобству. Особенности конструкции биты позволяют наносить ею тяжёлые и мощные удары."

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/w_knije_t.mdl"
SWEP.WorldModel = "models/weapons/w_knije_t.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = false

SWEP.Base = "weapon_base"

SWEP.Primary.Sound = Sound("Weapon_Crowbar.Single")
SWEP.Primary.Damage = 500
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.5
SWEP.Primary.Force = 500

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.MeleeReach = 48
SWEP.MeleeSize = 4.5
SWEP.MeleeDamageType = DMG_CLUB

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    local owner = self:GetOwner()
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_HITCENTER)

    if SERVER then
        owner:EmitSound(self.Primary.Sound)
    end

    owner:LagCompensation(true)
    
    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * self.MeleeReach,
        filter = owner,
        mask = MASK_SHOT_HULL
    })

    if not IsValid(tr.Entity) then
        tr = util.TraceHull({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * self.MeleeReach,
            filter = owner,
            mins = Vector(-self.MeleeSize, -self.MeleeSize, -self.MeleeSize),
            maxs = Vector(self.MeleeSize, self.MeleeSize, self.MeleeSize),
            mask = MASK_SHOT_HULL
        })
    end

    if tr.Hit then
        if SERVER then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(self.Primary.Damage)
            dmginfo:SetDamageType(self.MeleeDamageType)
            dmginfo:SetAttacker(owner)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageForce(owner:GetAimVector() * self.Primary.Force)
            dmginfo:SetDamagePosition(tr.HitPos)

            tr.Entity:TakeDamageInfo(dmginfo)

            if tr.Entity:IsPlayer() then
                self:ApplyPlayerKnockback(tr.Entity, dmginfo)
            else
                self:ApplyEntityKnockback(tr.Entity, dmginfo)
            end

            if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
                owner:EmitSound("Flesh.ImpactHard")
            else
                owner:EmitSound("Weapon_Crowbar.Melee_Hit")
            end
        end
    else
        if SERVER then
            owner:EmitSound("Weapon_Crowbar.Single")
        end
    end

    owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end

function SWEP:ApplyPlayerKnockback(ent, dmginfo)
    local knockbackForce = self:GetOwner():GetAimVector() * (dmginfo:GetDamage() * 500)
    knockbackForce.z = math.max(knockbackForce.z, 100) -- Ensure some upward force
    
    ent:SetVelocity(knockbackForce)
    
    -- Apply view punch
    local viewPunch = Angle(-dmginfo:GetDamage() * 0.5, 0, 0)
    ent:ViewPunch(viewPunch)
end
function SWEP:ApplyEntityKnockback(ent, dmginfo)
    local phys = ent:GetPhysicsObject()
    if phys:IsValid() and phys:IsMoveable() then
        phys:ApplyForceCenter(dmginfo:GetDamageForce())
        ent:SetPhysicsAttacker(self:GetOwner())
    end
end

function SWEP:DrawHUD()
    if not (GetViewEntity() == LocalPlayer()) then return end
    if LocalPlayer():InVehicle() then return end

    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.MeleeReach,
        filter = self:GetOwner()
    })
    local ply = LocalPlayer()
    local t = {}
    t.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
    t.endpos = t.start + ply:GetAngles():Forward() * 90
    t.filter = self:GetOwner()
    local Tr = util.TraceLine(t)
    
    if Tr.Hit then
    
            local Size = math.Clamp(1 - ((Tr.HitPos - self:GetOwner():GetShootPos()):Length() / 90) ^ 2, .1, .3)
            surface.SetDrawColor(Color(200, 200, 200, 200))
            draw.NoTexture()
            Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 55 * Size, 32)
    
            surface.SetDrawColor(Color(255, 255, 255, 200))
            draw.NoTexture()
            Circle(Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y, 40 * Size, 32)
    end
end

if CLIENT then
    function SWEP:DrawWorldModel()
        self:DrawModel()
    end

    function SWEP:DrawWorldModelTranslucent()
        self:DrawModel()
    end
end