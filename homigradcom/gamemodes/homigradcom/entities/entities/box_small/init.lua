
AddCSLuaFile("shared.lua")
include("shared.lua")

local eda = {
    "food_spongebob_home",
    "food_lays",
    "food_emela"
}
local bita = {
    "weapon_hg_kitknife"
}
local tyagi = {
    "weapon_handcuffs",
    "med_band_small",
    "weapon_per4ik"
}
util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    self:SetModel("models/sarma_crates/supply_crate01.mdl")
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
    if random == 1 then
        local randomWeapon = bita[math.random(1, #bita)]
        self.Info.Weapons[randomWeapon] = {
            Clip1 =  -2
        }
    elseif random >= 7 then
        local randomWeapon = tyagi[math.random(1, #tyagi)]
        self.Info.Weapons[randomWeapon] = {
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
