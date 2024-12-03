if (game.GetMap() == 'mg_piratewars_remake') then
	table.insert(LevelList,"pirate_wars")
else
	-- сосать
end

pirate_wars = {}
pirate_wars.Name = "Пиратская Бухта"

local models = {}
for i = 1,9 do table.insert(models,"models/player/group03/male_0" .. i .. ".mdl") end

pirate_wars.red = {"\"Пиратская шхуна\"",Color(0,0,0),
	weapons = {"weapon_hands","med_band_big","med_band_small","weapon_radio"},
	main_weapon = {"weapon_sar2","weapon_spas12","weapon_akm","weapon_mp7"},
	secondary_weapon = {"weapon_hk_usp","weapon_p220"},
	models =tdm.models
}


pirate_wars.blue = {"\"Белый Флаг\"",Color(255,255,255),
	weapons = {"weapon_hands"},
	main_weapon = {"weapon_sar2","weapon_spas12","weapon_mp7"},
	secondary_weapon = {"weapon_hk_usp"},
	models = tdm.models
}

pirate_wars.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function pirate_wars.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,pirate_wars.red[2])
	team.SetColor(2,pirate_wars.blue[2])

	if CLIENT then

		pirate_wars.StartRoundCL()
		return
	end

	pirate_wars.StartRoundSV()
end
pirate_wars.RoundRandomDefalut = 9999999999999
pirate_wars.SupportCenter = true
