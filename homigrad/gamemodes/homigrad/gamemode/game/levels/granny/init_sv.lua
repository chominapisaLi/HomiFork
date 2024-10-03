
local function makeT(ply)
    ply.roleT = true
    table.insert(granny.t,ply)

    ply:Give("weapon_granny_bat")
    ply.nopain = true
    ply:SetMaxHealth(#player.GetAll() * 400)
    ply:SetHealth(#player.GetAll() * 400)

    ply:ChatPrint("Вы бабка Грени.")
    ply:SetModel("models/fulltilton/granny.mdl")
end

function granny.SpawnsCT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointsnaem")) do
        table.insert(aviable,point)
    end

    return aviable
end

function granny.SpawnsT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointswick")) do
        table.insert(aviable,point)
    end

    return aviable
end

function granny.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 60

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in pairs(player.GetAll()) do ply.roleT = false end

    granny.t = {}

    local countT = 0

    local aviable = granny.SpawnsCT()
    local aviable2 = granny.SpawnsT()

    local players = PlayersInGame()

    local count = 1
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    granny.SyncRole()

    tdm.SpawnCommand(players,aviable,function(ply)
        ply.roleT = false
    ply:SetMaxHealth(#player.GetAll() * 150)
    end)

    tdm.SpawnCommand(granny.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function granny.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(granny.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
        if not homicide.police then
			homicide.police = true
            if homicide.roundType == 1 then
                PrintMessage(3,"Спецназ приехал.")
            else
                PrintMessage(3,"Полиция приехала.")
            end

			local aviable = ReadDataMap("spawnpointsct")
            local ctPlayers = tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end)
			
            local playsound = true
            tdm.SpawnCommand(ctPlayers,aviable,function(ply)
                timer.Simple(0,function()
                    if homicide.roundType == 1 then
                        ply:SetPlayerClass("contr")
                    else
                        ply:SetPlayerClass("police")
                    end
                    if playsound then
                        ply:EmitSound("police_arrive")
                        playsound = false
                    end
                end)
            end)
			
		end
	end

	if TAlive == 0 and Alive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function granny.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Победа бабки Грени." or winner == 2 and "Победа школьников." or "Ничья"))
end

local empty = {}

function granny.PlayerSpawn(ply,teamID)
    local teamTbl = granny[granny.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]
    if ply.roleCT then
        PrintMessage(HUD_PRINTTALK,'TRUE')
        ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    end
    ply:SetPlayerColor(color:ToVector())
	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function granny.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function granny.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget2")

function granny.SyncRole()
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

function granny.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock18","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function granny.ShouldSpawnLoot()
    return false
end

function granny.GuiltLogic(ply,att,dmgInfo)
    return (not ply.roleT) == (not att.roleT) and 20 or 0
end

function granny.NoSelectRandom()
    return #ReadDataMap("spawnpointswick") < 1
end
