AddCSLuaFile("shared.lua")
include("shared.lua")

Gunshuy = {
    "weapon_mp5",
    "weapon_xm1014",
    "weapon_remington870",
    "weapon_mp5",
    "weapon_p220",
    "weapon_civil_famas",
    "weapon_mp40",
    "weapon_galil",
    "weapon_hk_usp",
    "weapon_m4a1",
    "weapon_galilsar",
}



util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    self:SetModel("models/sarma_crates/static_crate_64.mdl")
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
    local randomWeapon = Gunshuy[math.random(1, #Gunshuy)]
    self.Info.Weapons[randomWeapon] = {
        Clip1 =  -2
    }
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
