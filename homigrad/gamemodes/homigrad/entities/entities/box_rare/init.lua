
AddCSLuaFile("shared.lua")
include("shared.lua")

local secondAll = {
    "weapon_deagle_csgo",
    "weapon_deagle",
    "food_tushenka",
    "food_spongebob_home",
    "painkiller",
    "med_band_big",
    "med_band_small",
    "medkit",
    "weapon_handcuffs",
    "weapon_per4ik",
    "weapon_teaser",
    "weapon_gurkha",
    "weapon_knife",
    "weapon_kabar",
    "weapon_hg_kitknife"

}
local mainHeavy = {
    "weapon_hg_sovkov_showel",
    "weapon_hg_sleagehammer",
    "weapon_hg_pickaxe",
    "weapon_hg_fubar"
}
local gren = {
    "weapon_hg_f1",
    "weapon_hg_rgd5",
}

util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    self:SetModel("models/sarma_crates/supply_crate02.mdl")
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
    local random = math.random(1,1000) 
    local randomWeapon = mainHeavy[math.random(1, #mainHeavy)]
    self.Info.Weapons[randomWeapon] = {
        Clip1 =  -2
    }
    print(random)
    if random >= 500 then
        local randomWeaponss = secondAll[math.random(1, #secondAll)]
        self.Info.Weapons[randomWeaponss] = {
            Clip1 =  -2
        }
    end
    if random >= 888 then
        local randomWeaponsss = gren[math.random(1, #gren)]
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
