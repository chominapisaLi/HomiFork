function pirate_wars.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	tdm.CenterInit()
end

function pirate_wars.RoundEndCheck()

	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end

function pirate_wars.EndRound(winner) tdm.EndRoundMessage(winner) end

function pirate_wars.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function pirate_wars.PlayerSpawn(ply,teamID)
	local teamTbl = pirate_wars[pirate_wars.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

    ply:SetPlayerColor(color:ToVector())
	ply:Give('weapon_hands')
	if math.random(1,4) == 4 then ply:Give("adrinaline") end
	if math.random(1,4) == 4 then ply:Give("morphine") end
	if math.random(1,3) == 3 then ply:Give("weapon_hg_hl2") end
	local sweps = {
		[1] = "weapon_gurkha",
		[2] = "weapon_hg_fubar",
		[3] = "weapon_hg_sovkov_showel"
	}
	ply:Give(sweps[math.random(1,3)])
	local sweps = {
		[1] = "food_fishcan",
		[2] = "food_rum",
		[3] = "food_lays"
	}
	ply:Give(sweps[math.random(1,3)])
	if math.random(1,10) == 1 then
		ply:Give('weapon_deagle')
	end
	if math.random(1,10) == 1 then
		JMod.EZ_Equip_Armor(ply,"Metal Pot",Color(255,255,255))
	end


end

function pirate_wars.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end

function pirate_wars.ShouldSpawnLoot() return false end
function pirate_wars.PlayerDeath(ply,inf,att) return false end