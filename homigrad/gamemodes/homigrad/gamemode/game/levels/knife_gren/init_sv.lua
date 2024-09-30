function knife.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (1 + math.min(#player.GetAll() / 16,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1) end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()
    tdm.SpawnCommand(team.GetPlayers(1),aviable,function(ply)
        ply:Freeze(true)
    end)

    freezing = true

    RTV_CountRound = RTV_CountRound - 1

    roundTimeRespawn = CurTime() + 15

    roundDmType = math.random(1,3)

    return {roundTimeStart,roundTime}
end

function knife.RoundEndCheck()
    local Alive = 0

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then Alive = Alive + 1 end
    end

    if freezing and roundTimeStart + dm.LoadScreenTime < CurTime() then
        freezing = nil

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:Freeze(false)
        end
    end

    /*if roundTimeRespawn < CurTime() then
        roundTimeRespawn = CurTime() + 15

        local aviable = ReadDataMap("dm")
        aviable = #aviable ~= 0 and aviable or homicide.Spawns()
        tdm.SpawnCommand(team.GetPlayers(1),aviable,nil,function(ply) if ply:Alive() then return false end end)
    end*/

    if Alive <= 1 then EndRound() return end

end

function knife.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

    PrintMessage(3,"Победил " .. ("последний..."))
end

local red = Color(255,0,0)

function knife.PlayerSpawn(ply,teamID)
    local meele = {
	"weapon_t",
	"weapon_knife",
    "weapon_fireaxe",
	"weapon_hg_hatchet"
    }
	ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0,0,0.6))

    ply:Give("weapon_hands")

    local randomIndex = math.random(1, #meele) 
    local weaponM = ply:Give(meele[randomIndex])
    ply:Give("med_band_big")
    ply:Give("food_beer")
    ply:Give("food_fishcan")
    

    ply:SetLadderClimbSpeed(100)

    
end

function knife.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function knife.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("пашол нахуй") return false end

    return true
end

function dm.GuiltLogic() return false end

util.AddNetworkString("knife die")
function knife.PlayerDeath()
    net.Start("knife die")
    net.Broadcast()
end
