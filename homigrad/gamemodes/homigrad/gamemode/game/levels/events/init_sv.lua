

function event.SpawnsCT()
    return homicide.Spawns()
end

function event.SpawnsT()
    return homicide.Spawns()
end

function event.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 0.1

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in pairs(player.GetAll()) do ply.roleT = false end

    event.t = {}

    local countT = 0

    local aviable = event.SpawnsCT()
    local aviable2 = event.SpawnsT()

    local players = PlayersInGame()

    event.SyncRole()
    for i,ply in pairs(player.GetAll()) do
        if ply.roleT ~= true then
            ply:SetModel(tdm.models[math.random(1,#tdm.models)])
        end
    end
    tdm.SpawnCommand(players,aviable,function(ply)
    end)

    tdm.SpawnCommand(event.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()
    

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function event.RoundEndCheck()
    tdm.Center()
	if TAlive == 0 and Alive == 0 then EndRound() return end
end

function event.EndRound(winner)
    PrintMessage(3,("Ивент окончен!"))
end

local empty = {}

function event.PlayerSpawn(ply,teamID)
    local teamTbl = event[event.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]
    if ply.roleCT then
        ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    end
    ply:SetPlayerColor(color:ToVector())
	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function event.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function event.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget2")

function event.SyncRole()
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply)
        else ply.roleCT = true 
        end
    end

    net.Start("homicide_roleget2")
    net.WriteTable(role)
    net.Broadcast()
end

function event.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function event.ShouldSpawnLoot()
    return false
end

function event.GuiltLogic(ply,att,dmgInfo)
    return (not ply.roleT) == (not att.roleT) and 20 or 0
end

function event.NoSelectRandom()
    return #ReadDataMap("spawnpointsevent") < 1
end
