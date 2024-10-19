
AddCSLuaFile("shared.lua")
include("shared.lua")

local tyagi = {
    "weapon_handcuffs",
    "weapon_per4ik"
}
local eda = {
    "food_spongebob_home",
    "food_lays",
    "food_emela",
    "food_tushenka"
}

local bita = {
    "weapon_bat",
    "weapon_hg_kitknife",
    "weapon_hg_crowbar",
    "weapon_hg_metalbat",
    "weapon_t"
}

util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    self:SetModel("models/sarma_crates/static_crate_40.mdl")
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
    if random >= 3 then
        local randomWeaponss = bita[math.random(1, #bita)]
        self.Info.Weapons[randomWeaponss] = {
            Clip1 =  -2
        }
    end
    if random >= 5 then
        local randomWeaponsss = tyagi[math.random(1, #tyagi)]
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
