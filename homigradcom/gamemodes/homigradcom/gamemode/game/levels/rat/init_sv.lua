function rat.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * 1

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.CenterInit()
	local time = math.Round(roundTimeStart + roundTime - CurTime())
	timer.Simple(time,function()
		tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)
	end)
end

function rat.RoundEndCheck()

	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))
	local time = math.Round(roundTimeStart + roundTime - CurTime())
	if TAlive == 0 and CTAlive == 0 then EndRound() return end
	if TAlive == 0 and time <= -4 then EndRound(2) end
	if CTAlive == 0 and time <= -4 then EndRound(1) end

	tdm.Center()
end

function rat.EndRound(winner) tdm.EndRoundMessage(winner) end

function rat.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function rat.PlayerSpawn(ply,teamID)
	local teamTbl = rat[rat.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon)
	
	if teamID == 2 then
		--ply:SetPlayerClass("combine")
		JMod.EZ_Equip_Armor(ply,"Medium-Helmet",Color(0,0,0,0))
		JMod.EZ_Equip_Armor(ply,"Light-Vest",Color(0,0,0,0))
	end

	if teamID == 1 then
		ply:Give("morphine")
		if math.random(1,4) == 4 then
			JMod.EZ_Equip_Armor(ply,"Metal Pot")
		end
	end

end

function rat.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end

function rat.ShouldSpawnLoot() return false end
function rat.PlayerDeath(ply,inf,att) return false end