local blackListedWeps = {
	["weapon_hands"] = true
}

local blackListedAmmo = {
	[8] = true,
	[9] = true,
	[10] = true
}

Gunshuy = {
	"weapon_glock18",
	"weapon_p220",
	"weapon_mp5",
	"weapon_ar15",
	"weapon_ak74",
	"weapon_akm",
	"weapon_fiveseven",
	"weapon_hk_usp",
	"weapon_deagle",
	"weapon_beretta",
	"weapon_ak74u",
	"weapon_l1a1",
	"weapon_fal",
	"weapon_galil",
	"weapon_galilsar",
	"weapon_m14",
	"weapon_m1a1",
	"weapon_mk18",
	"weapon_m249",
	"weapon_m4a1",
	"weapon_minu14",
	"weapon_mp40",
	"weapon_rpk",
	"weapon_ump",
	"weapon_hk_usps",
	"weapon_m3super",
	"weapon_glock",
	"weapon_mp7",
	"weapon_remington870",
	"weapon_xm1014",
	"bandage",
	"morphine",
	"medkit",
	"painkiller",
	"weapon_physgun",
	"weapon_kabar",
	"weapon_bat",
	"weapon_gurkha",
	"weapon_jmoddynamite",
	"weapon_jmodflash",
	"weapon_jmodnade",
	"weapon_taser",
	"weapon_t",
	"weapon_knife",
	"weapon_pipe",
	"weapon_sar2",
	"weapon_civil_famas"
}

local AmmoTypes = {
	[47] = "vgui/hud/hmcd_round_792",
	[44] = "vgui/hud/hmcd_round_792",
	[2] = "vgui/hud/hmcd_health",
	[48] = "vgui/hud/hmcd_round_9",
	[45] = "vgui/hud/hmcd_round_556",
	[38] = "vgui/hud/hmcd_round_38",
	[6] = "vgui/hud/hmcd_round_arrow",
	[41] = "vgui/hud/hmcd_round_12",
	[8] = "vgui/wep_jack_hmcd_oldgrenade",
	[9] = "vgui/wep_jack_hmcd_oldgrenade",
	[10] = "vgui/wep_jack_hmcd_oldgrenade",
	[11] = "vgui/wep_jack_hmcd_ied"
	}

local white = Color(255,255,255)
local black = Color(0,0,0,128)
local black2 = Color(64,64,64,128)

local function SafeReadTable()
    local success, result = pcall(net.ReadTable)
    if not success then
        print("Error reading network table:", result)
        return {}
    end
    return result
end

local function getText(text,limitW)
    local newText = {}
    local newText_I = 1
    local curretText = ""

    surface.SetFont("DefaultFixedDropShadow")

    for i = 1,#text do
        local sumbol = string.sub(text,i,i)
        local w,h = surface.GetTextSize(curretText .. sumbol)

        if w >= limitW then
            newText_I = newText_I + 1
            curretText = sumbol
        else
            curretText = curretText .. sumbol
        end

        newText[newText_I] = curretText
    end

    return newText
end
local function OpenInventory(lootEnt)
    if IsValid(panel) then panel.override = true panel:Remove() end

    local lply = LocalPlayer()
    local items = {}
    local items_ammo = {}
    local nickname = ""

    if lootEnt == lply then
        -- Получаем инвентарь игрока
        for _, weapon in pairs(lply:GetWeapons()) do
            local class = weapon:GetClass()
            if not blackListedWeps[class] then
                items[class] = true
            end
        end
        for ammoType, amount in pairs(lply:GetAmmo()) do
            if not blackListedAmmo[ammoType] then
                items_ammo[ammoType] = amount
            end
        end
        nickname = "игрока"
    else
        -- Получаем инвентарь другого объекта
        items = SafeReadTable()
        items_ammo = SafeReadTable()
        if not IsValid(lootEnt) then 
            print("Invalid loot entity")
            return 
        end
        nickname = lootEnt:IsPlayer() and lootEnt:Name() or lootEnt:GetNWString("Nickname") or ""
    end

    if items[lootEnt.curweapon] and table.HasValue(Gunshuy, lootEnt.curweapon) then items[lootEnt.curweapon] = nil end
    items.weapon_hands = nil

    panel = vgui.Create("DFrame")
    panel:SetAlpha(255)
    panel:SetSize(500, 400)
    panel:Center()
    panel:SetDraggable(false)
    panel:MakePopup()
    panel:SetTitle("")

    function panel:OnKeyCodePressed(key)
        if key == KEY_W or key == KEY_S or key == KEY_A or key == KEY_D or key == KEY_C then 
            self:Remove() 
        end
    end
    
    function panel:OnRemove()
        if self.override then return end
        if lootEnt ~= lply then
            net.Start("inventory")
            net.WriteEntity(lootEnt)
            net.SendToServer()
        end
    end

    panel.Paint = function(self, w, h)
        if not IsValid(lootEnt) or not LocalPlayer():Alive() then panel:Remove() return end

        draw.RoundedBox(0, 0, 0, w, h, black)
        surface.SetDrawColor(255, 255, 255, 128)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

        draw.SimpleText("Инвентарь " .. nickname, "DefaultFixedDropShadow", 6, 6, white)
    end

    local x, y = 40, 40
    local corner = 6

    for wep in pairs(items) do
        local button = vgui.Create("DButton", panel)
        button:SetPos(x, y)
        button:SetSize(64, 64)

        x = x + button:GetWide() + 6
        if x + button:GetWide() >= panel:GetWide() then
            x = 40
            y = y + button:GetTall() + 6
        end

        button:SetText("")

        local wepTbl = weapons.Get(wep) or WeaponByModel[wep] or wep
        local text = type(wepTbl) == "table" and wepTbl.PrintName or wep
        text = getText(text, button:GetWide() - corner * 2)

        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or black)
            surface.SetDrawColor(255, 255, 255, 128)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

            for i, text in pairs(text) do
                draw.SimpleText(text, "DefaultFixedDropShadow", corner, corner + (i - 1) * 12, white)
            end

            local x, y = self:LocalToScreen(0, 0)
            DrawWeaponSelectionEX(wepTbl, x, y, w, h)
        end

        button.DoClick = function()
			if lootEnt == lply then
				-- Check if the player has the weapon in their inventory
				if items[wep] then
					-- Drop the weapon directly without equipping it first
					local weaponClass = wep  -- Get the weapon class name
					
					-- Loop through player's weapons to find if they have it
					for _, weapon in pairs(lply:GetWeapons()) do
						if weapon:GetClass() == weaponClass then
							-- Equip the weapon
							input.SelectWeapon(weapon)
		
							-- Wait for a short time to ensure the weapon is equipped before dropping it
							timer.Simple(0.1, function()
								-- Send a console command to drop the weapon
								RunConsoleCommand("say", "*drop")  -- Notify others
								RunConsoleCommand("drop")  -- Drop the weapon directly
								panel:Remove()  -- Close the inventory panel
							end)
							return
						end
					end
					
					print("Weapon not found in inventory")
				end
			else
				-- Берем предмет из инвентаря другого объекта
				net.Start("ply_take_item")
				net.WriteEntity(lootEnt)
				net.WriteString(tostring(wep))
				net.SendToServer()
			end
		end

        button.DoRightClick = button.DoClick
    end

    for ammo, amt in pairs(items_ammo) do
        if blackListedAmmo[ammo] then continue end
        local button = vgui.Create("DButton", panel)
        button:SetPos(x, y)
        button:SetSize(64, 64)

        x = x + button:GetWide() + 6
        if x + button:GetWide() >= panel:GetWide() then
            x = 40
            y = y + button:GetTall() + 6
        end

        button:SetText('')

        local text = game.GetAmmoName(ammo)
        text = getText(text, button:GetWide() - corner * 2)

        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or black)
            surface.SetDrawColor(255, 255, 255, 128)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

            local round = Material(AmmoTypes[tonumber(ammo)] or "vgui/hud/hmcd_person", "noclamp smooth")
            surface.SetMaterial(round)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(2, 2, w - 4, h - 4)

            for i, text in pairs(text) do
                draw.SimpleText(text, "DefaultFixedDropShadow", corner, corner + (i - 1) * 12, white)
            end
        end
    end
end

-- Хук для открытия инвентаря по нажатию C
hook.Add("PlayerButtonDown", "OpenPlayerInventory", function(ply, button)
    if button == KEY_C then
        OpenInventory(ply)
    end
end)

-- Обработчик сетевого сообщения для открытия инвентаря другого объекта
net.Receive("inventory", function()
    local lootEnt = net.ReadEntity()
    if not IsValid(lootEnt) then
        print("Received invalid loot entity")
        return
    end
    OpenInventory(lootEnt)
end)