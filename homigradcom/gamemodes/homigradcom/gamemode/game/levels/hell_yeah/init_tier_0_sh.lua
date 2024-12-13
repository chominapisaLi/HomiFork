table.insert(LevelList,"hell_yeah")
hell_yeah = {}
hell_yeah.Name = "Хелл Еее!!"

hell_yeah.red = {"Семья Блюндлей",Color(56,56,223),
	weapons = {"weapon_hands","weapon_hg_sword_blue"},
	main_weapon = {"weapon_double_barrel"},
	secondary_weapon = {"weapon_deagle_csgo"},
	models = {"models/players/Jerusalem_Archer_04.mdl"}
}


hell_yeah.blue = {"Семья Крэнбрук",Color(19,10,10),
	weapons = {"weapon_hands","weapon_hg_sword_red"},
	main_weapon = {"weapon_double_barrel"},
	secondary_weapon = {"weapon_deagle_csgo"},
	models = {"models/players/Hospitalier_Archer_04.mdl"}
}

hell_yeah.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function hell_yeah.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,hell_yeah.red[2])
	team.SetColor(2,hell_yeah.blue[2])

	if CLIENT then

		hell_yeah.StartRoundCL()
		return
	end

	hell_yeah.StartRoundSV()
end

hell_yeah.SupportCenter = true

hell_yeah.NoSelectRandom = false