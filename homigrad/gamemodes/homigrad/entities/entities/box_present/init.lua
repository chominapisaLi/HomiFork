
AddCSLuaFile("shared.lua")
include("shared.lua")

local novygod1 = {
    "weapon_hg_shovel",
    "weapon_bat",
    "weapon_hg_crowbar"
}
local eda = {
    "food_vodka",
    "food_lays",
    "food_milk",
    "food_fishcan"
}
local stvol = {
    "weapon_ak74u"
}

util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    --скин ящика
    local randSkin = math.random(1,3)
    if randSkin == 1 then
        self:SetModel("models/codmw2023/other/christmasstuff/gifta.mdl")
    end
    if randSkin == 2 then
        self:SetModel("models/gift/christmas_gift_3.mdl")
    end
    if randSkin == 3 then
        self:SetModel("models/gift/christmas_gift.mdl")
    end
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
    
    -- Initialize the Info table with Weapons and Ammo subtables
    self.Info = {
        Weapons = {},
        Ammo = {}
    }
    
    -- Populate the Weapons table with a random weapon from Gunshuy
    local random = math.random(1,10) 
    local randomWeapon = eda[math.random(1, #eda)]
    self.Info.Weapons[randomWeapon] = {
        Clip1 =  -2
    }
    print(random)
    if random >= 8 then
        local randomWeaponss = stvol[math.random(1, #stvol)]
        self.Info.Weapons[randomWeaponss] = {
            Clip1 =  -2
        }
    end
    if random >= 5 then
        local randomWeaponsss = novygod1[math.random(1, #novygod1)]
        self.Info.Weapons[randomWeaponsss] = {
            Clip1 =  -2
        }
    end

end

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        if self.Info then
            net.Start("inventory")
            net.WriteEntity(self)
            net.WriteTable(self.Info.Weapons)
            net.WriteTable(self.Info.Ammo)
            net.Send(activator)
        end
    end
end
