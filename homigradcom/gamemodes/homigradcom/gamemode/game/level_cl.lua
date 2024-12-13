dataRound = dataRound
endDataRound = endDataRound
net.Receive("round_state",function()
	roundActive = net.ReadBool()
	local data = net.ReadTable()

	if roundActive == true then
        dataRound = data

		local func = TableRound().StartRound
		if func then func(data) end
	else
        endDataRound = data

		local func = TableRound().EndRound
		if func then func(data.lastWinner,data) end
	end
end)

net.Receive("round_time",function()
	roundTimeStart = net.ReadFloat()
	roundTime = net.ReadFloat()
	roundTimeLoot = net.ReadFloat()
end)

showRoundInfo = CurTime() + 3
roundActiveName = roundActiveName or "tdm"
roundActiveNameNext = roundActiveNameNext or "tdm"

net.Receive("round",function()
	roundActiveName = net.ReadString()
	showRoundInfo = CurTime() + 10

	system.FlashWindow()

	chat.AddText("Игровой режим сменился на : " .. TableRound().Name)
end)

net.Receive("round_next",function()
	roundActiveNameNext = net.ReadString()
	showRoundInfo = CurTime() + 10

	chat.AddText("Следущий режим : " .. TableRound(roundActiveNameNext).Name)
end)

local white = Color(255,255,255)
showRoundInfoColor = Color(255,255,255)
local yellow = Color(255,255,0)
local icon = Material( "icons/police-car.png" )
hook.Add("HUDPaint","homigrad-roundstate",function()
	if roundActive then
		local func = TableRound().HUDPaint_RoundLeft
		local ffunc = TableRound().HUDPaint_RoundFelt
		local blood_shed_func = TableRound().HUDPaint_BloodShed

		if func then
			func(showRoundInfoColor)
		end
		if ffunc then
			local text = TableRound().HUDPaint_RoundText
			local time = math.Round(roundTimeStart + roundTime - CurTime())
			local acurcetime = string.FormattedTime(time,"%02i:%02i")
			text = text..acurcetime
			if time < 0 then text = "" end
			
			draw.SimpleText(text,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif blood_shed_func then
			local text = TableRound().HUDPaint_RoundText
			local time = math.Round(roundTimeStart + roundTime - CurTime())
			local acurcetime = string.FormattedTime(time, "%02i:%02i")
			text = text
			if time < 0 then text = "" end
		
			if time > 0 then
				-- Получаем позицию камеры
				local player = LocalPlayer()
				local viewPos = player:GetViewEntity():GetPos()
				
				-- Рассчитываем смещение на основе позиции камеры
				local offsetX = 1
				local offsetY = 1
				local offsetZ = 1
		
				-- Мигающий эффект
				local flashAlpha = math.abs(math.sin(CurTime() * 5)) * 255 -- Быстрое мигание
				local flashColor = Color(255, 255, 255, flashAlpha) -- Красный цвет мигалки
		
				-- Рисуем иконку с мигающим эффектом
				surface.SetMaterial(icon)
				surface.SetDrawColor(flashColor)
				surface.DrawTexturedRect(ScrW() * 0.00001 + 30 + offsetX, ScrH() * 0.001, ScrW() * 0.075, ScrH() * 0.15)
		
				-- Рисуем текст
				draw.SimpleText(text, "BloodShedLikeBig", ScrW() * 0.06 + 180 + offsetX, ScrH() * 0.075, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(acurcetime, "BloodShedLikeSmall", ScrW() * 0.06 + 105 + offsetX, ScrH() * 0.1, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

	else
		draw.SimpleText(#PlayersInGame() <= 1 and "Нужно минимум 2 игрока." or "Раунд закончен.","HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local k = showRoundInfo - CurTime()

	if k > 0 then
		k = math.min(k,1)

		showRoundInfoColor.a = k * 255
		yellow.a = showRoundInfoColor.a

		local name,nextName = TableRound().Name,TableRound(roundActiveNameNext).Name
		draw.SimpleText("Текущий режим : " .. name,"HomigradFont",ScrW() - 15,15,showRoundInfoColor,TEXT_ALIGN_RIGHT)
		draw.SimpleText("Следущий режим : " .. nextName,"HomigradFont",ScrW() - 15,35,name ~= nextName and yellow or showRoundInfoColor,TEXT_ALIGN_RIGHT)
	end
end)