
AddCSLuaFile("shared.lua")
include("shared.lua")

medone = {
    "med_band_small",
    "med_band_big",
    "painkiller"
}
medtwo = {
    "medkit"
}
medthree = {
    "adrenaline",
    "morphine"
}
util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    self:SetModel("models/sarma_crates/static_crate_48.mdl")
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
    local randomWeapon = medone[math.random(1, #medone)]
    self.Info.Weapons[randomWeapon] = {
        Clip1 =  -2
    }
    if random >= 1 and random <= 3 then
        local randomWeapon = medthree[math.random(1, #medthree)]
        self.Info.Weapons[randomWeapon] = {
            Clip1 =  -2
        }
    elseif random >= 7 then
        local randomWeapon = medtwo[math.random(1, #medtwo)]
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
