table.insert(LevelList,"rat")
rat = {}
rat.Name = "Крыса на плантациях"
rat.HUDPaint_BloodShed = true 
rat.HUDPaint_RoundText = 'Полиция в пути'
local models = {}
for i = 1,9 do table.insert(models,"models/player/group03/male_0" .. i .. ".mdl") end

rat.red = {"Бандиты",Color(125,95,60),
	weapons = {"weapon_hands","med_band_big","med_band_small"},
	main_weapon = {"food_rum","food_vodka","food_muka"},
	secondary_weapon = {"weapon_p220","weapon_hk_usp","weapon_fiveseven","weapon_deagle_csgo"},
	models = homicide.models
}


rat.blue = {"Полиция",Color(75,75,125),
	weapons = {"weapon_hands"},
	main_weapon = {"weapon_akm","weapon_spas12","weapon_mp7"},
	secondary_weapon = {"weapon_p220","weapon_hk_usp","weapon_fiveseven","weapon_deagle_csgo"},
	models = {"models/humans/group05/cop_84.mdl"}
}

rat.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function rat.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,rat.red[2])
	team.SetColor(2,rat.blue[2])

	if CLIENT then

		rat.StartRoundCL()
		return
	end

	rat.StartRoundSV()
end
rat.RoundRandomDefalut = 5
rat.SupportCenter = true
