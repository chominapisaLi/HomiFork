util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("ply_take_ammo")

local function send(ply,lootEnt,remove)
	if ply then
		net.Start("inventory")
		net.WriteEntity(not remove and lootEnt or nil)

		net.WriteTable(lootEnt.Info.Weapons)
		net.WriteTable(lootEnt.Info.Ammo)
		net.Send(ply)
	else
		if lootEnt:IsPlayer() then
			for ply in pairs(lootEnt.UsersInventory) do
				if not IsValid(ply) or not ply:Alive() or remove then lootEnt.UsersInventory[ply] = nil continue end

				send(ply,lootEnt,remove)
			end
		end

	end
end

hook.Add("PlayerSpawn","!!!huyassdd",function(lootEnt)
	if lootEnt.UsersInventory ~= nil then
		for plys,bool in pairs(lootEnt.UsersInventory) do
			lootEnt.UsersInventory[plys] = nil
			send(plys,lootEnt,true)
		end
	end
end)

hook.Add("Player Think","Looting",function(ply)
	local key = ply:KeyDown(IN_USE)

	if not ply.fake and ply:Alive() and ply:KeyDown(IN_ATTACK2) then
		if ply.okeloot ~= key and key then
			local tr = {}
			tr.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
			tr.endpos = tr.start + ply:EyeAngles():Forward() * 64
			tr.filter = ply
			local tracea = util.TraceLine(tr)
			local hitEnt = tracea.Entity

			if not IsValid(hitEnt) then return end
			if IsValid(RagdollOwner(hitEnt)) then hitEnt = RagdollOwner(hitEnt) end
			if IsValid(hitEnt) and hitEnt.IsJModArmor then hitEnt = hitEnt.Owner end
			if not IsValid(hitEnt) then return end
			if hitEnt:IsPlayer() and hitEnt:Alive() and not hitEnt.fake then return end
			if not hitEnt.Info then return end
			
			hitEnt.UsersInventory = hitEnt.UsersInventory or {}
			hitEnt.UsersInventory[ply] = true

			send(ply,hitEnt)
			hitEnt:CallOnRemove("fuckoff",function() send(nil,hitEnt,true) end)
		end
	end

	ply.okeloot = key
end)

local prekol = {
	weapon_physgun = true,
	gmod_tool = true
}



net.Receive("inventory",function(len,ply)
	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end
	if lootEnt:IsPlayer() then
		lootEnt.UsersInventory[ply] = nil
	end
	
	player.Event(ply,"inventory close",lootEnt)
end)

net.Receive("ply_take_item", function(len, ply)
    local lootEnt = net.ReadEntity()
    if not IsValid(lootEnt) then return end

    local wep = net.ReadString()
    local lootInfo = lootEnt.Info or {Weapons = {[wep] = true}, Ammo = {}}

    if prekol[wep] and not ply:IsAdmin() then
        ply:Kick("xd))00")
        return
    end

    -- Подсчет предметов в инвентаре игрока (оружие и патроны)
    local currentWeaponCount = 0
    local currentAmmoCount = 0

    -- Подсчет текущих оружий
    for k, _ in pairs(ply:GetWeapons()) do
        currentWeaponCount = currentWeaponCount + 1
    end

    -- Подсчет патронов
    for _, ammoType in pairs(lootInfo.Ammo) do
        currentAmmoCount = currentAmmoCount + ammoType  -- Предполагается, что ammoType это количество патронов
    end

    -- Проверка на ограничение (9 предметов)
    if currentWeaponCount + currentAmmoCount >= 11 then
        ply:ChatPrint("Ваш инвентарь полон! Вы не можете взять больше предметов.")
        return
    end

    if ply:HasWeapon(wep) then
        if lootInfo.Weapons[wep] then
            local wepInfo = lootInfo.Weapons[wep]

            if (lootEnt.curweapon == wep and not lootEnt.Otrub) then return end
            if wepInfo.Clip1 and wepInfo.Clip1 > 0 then
                ply:GiveAmmo(wepInfo.Clip1, wepInfo.AmmoType)
                wepInfo.Clip1 = 0
            else
                ply:ChatPrint("У тебя это уже есть.")
            end
        else
            ply:ChatPrint("У тебя это уже есть.")
        end
    else
        local wepInfo = lootInfo.Weapons[wep]

        if (lootEnt.curweapon == wep and not lootEnt.Otrub) then return end

        ply.slots = ply.slots or {}

        if IsValid(lootEnt.wep) and lootEnt.curweapon == wep then
            DespawnWeapon(lootEnt)
            lootEnt.wep:Remove()
        end

        local actwep = ply:GetActiveWeapon()
        local wep1 = ply:Give(wep)

        if IsValid(wep1) and wep1:IsWeapon() then
            wep1:SetClip1(wepInfo and wepInfo.Clip1 or 0)
        end
        if wepInfo then
            if wepInfo.Clip1 and wepInfo.Clip1 == -2 then
                wep1:SetClip1(wep1:GetMaxClip1())
            end
        end


        ply:SelectWeapon(actwep:GetClass())

        if lootEnt:IsPlayer() then
            lootEnt:StripWeapon(wep)
        end

        lootInfo.Weapons[wep] = nil
        if lootInfo.Weapons2 then
            table.RemoveByValue(lootInfo.Weapons2, wep)
        end

        if lootEnt:IsRagdoll() then
            deadBodies[lootEnt:EntIndex()] = {lootEnt, lootInfo}
            net.Start("send_deadbodies")
            net.WriteTable(deadBodies)
            net.Broadcast()
        end

        local weapons_left = 0
        for i in pairs(lootInfo.Weapons) do
            weapons_left = weapons_left + 1
        end

        if weapons_left == 0 then
            lootEnt:Remove()
        end
    end

    send(nil, lootEnt)
end)


net.Receive("ply_take_ammo",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end
	local ammo = net.ReadFloat()
	local lootInfo = lootEnt.Info
	if not lootInfo.Ammo[ammo] then return end

	ply:GiveAmmo(lootInfo.Ammo[ammo],ammo)
	lootInfo.Ammo[ammo] = nil

	send(nil,lootEnt)
end)