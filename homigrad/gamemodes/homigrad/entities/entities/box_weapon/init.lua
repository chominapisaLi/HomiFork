AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
Gunshuy = {
    "weapon_mp5",
    "weapon_ar15",
    "weapon_akm",
    "weapon_m4a1",
    "weapon_xm1014",
    "weapon_remington870"
}
util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("update_inventory")

function ENT:Initialize()
    self:SetModel("models/props_junk/wood_crate001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    -- Локальная инициализация инвентаря как пустой таблицы
    self.Inventory = {}
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        -- Проверка на наличие инвентаря
        if self.Inventory == nil then
            self.Inventory = {}
        end

        -- Начинаем сетевое сообщение только если инвентарь корректен
        if self.Inventory then
            net.Start("inventory")
            net.WriteEntity(self)
            net.WriteTable({Gunshuy[math.random(1,#Gunshuy)]})
            net.WriteTable({})
            net.Send(activator)
        end
    end
end
