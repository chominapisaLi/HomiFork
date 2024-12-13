AddCSLuaFile("shared.lua")
include("shared.lua")

local Gunshuy1 = {
    "weapon_mp5",
    "weapon_xm1014",
    "weapon_remington870",
    "weapon_mp5",
    "weapon_civil_famas",
    "weapon_mp40",
    "weapon_galil",
    "weapon_m4a1",
    "weapon_galilsar",
}

local PISTOLS = {
    "weapon_craft_gun",
    "weapon_p220",
    "weapon_deagle_csgo",
    "weapon_glock",
    "weapon_hk_usp",
    "weapon_fiveseven",
    "weapon_deagle"
}

local GRENADES = {
    "weapon_hg_f1",
    "weapon_hg_rgd5",
    "weapon_hg_smokenade",
    "weapon_hg_molotov",
    "weapon_hg_flashbang"
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
    local randomWeapon = PISTOLS[math.random(1, #PISTOLS)]
    self.Info.Weapons[randomWeapon] = {
        Clip1 =  -2
    }
    local randomznachenye=math.random(1,1000)
    if randomznachenye > 550 then
        local randomWeapon = Gunshuy1[math.random(1, #Gunshuy1)]
        self.Info.Weapons[randomWeapon] = {
            Clip1 =  -2
        }
    end
    if randomznachenye > 900 then
        local randomWeapon = GRENADES[math.random(1, #GRENADES)]
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
