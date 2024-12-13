

function jmod_survival.SpawnsCT()
    return homicide.Spawns()
end

function jmod_survival.SpawnsT()
    return homicide.Spawns()
end

function jmod_survival.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 0.1

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in pairs(player.GetAll()) do ply.roleT = false end

    jmod_survival.t = {}

    local countT = 0

    local aviable = jmod_survival.SpawnsCT()
    local aviable2 = jmod_survival.SpawnsT()

    local players = PlayersInGame()

    jmod_survival.SyncRole()
    for i,ply in pairs(player.GetAll()) do
        if ply.roleT ~= true then
            ply:SetModel(tdm.models[math.random(1,#tdm.models)])
        end
    end
    tdm.SpawnCommand(players,aviable,function(ply)
    end)

    tdm.SpawnCommand(jmod_survival.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()
    function construct.PlayerInitialSpawn(ply) ply:SetTeam(1) end


    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function jmod_survival.RoundEndCheck()
    tdm.Center()
	if TAlive == 0 and Alive == 0 then EndRound() return end
end

function jmod_survival.EndRound(winner)
    PrintMessage(3,("Ивент окончен!"))
end

local empty = {}

function jmod_survival.PlayerSpawn(ply,teamID)
    local teamTbl = jmod_survival[jmod_survival.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]
    ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:ChatPrint('```*inv*``` в чат для того что бы открыть инвентарь JMOD')
    ply:SetPlayerColor(Vector(math.random(0,255),math.random(0,255),math.random(0,255)))
	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = true  end)
end

function jmod_survival.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function construct.PlayerCanJoinTeam(ply,teamID)
    if teamID == 2 or teamID == 3 then return false end
end
function jmod_survival.SyncRole()
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

function jmod_survival.PlayerDeath(ply,inf,att) 
    ply:ChatPrint('Вы будете воскрешены через 15 секунд')
    timer.Simple(15,function()
        ply:Spawn()
    end)
end
