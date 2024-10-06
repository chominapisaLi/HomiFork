local function GetFriends(play)
    
    local huy = ""

    for i, ply in pairs(oneinnocent.t) do
        if play == ply then continue end
        huy = huy .. ply:Name() .. ", "
    end

    return huy
end

COMMANDS.oneinnocent_get = {function(ply,args)
    if not ply:IsAdmin() then return end

    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
        if ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end}

local function makeT(ply)
    ply.roleT = true
    table.insert(oneinnocent.t,ply)

    if oneinnocent.roundType == 1 then
        ply:Give("weapon_kabar")
        local wep = ply:Give("weapon_hk_usps")


        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
    elseif oneinnocent.roundType == 2 then
        ply:Give("weapon_kabar")

        ply:Give("weapon_hg_t_syringepoison")
        ply:Give("weapon_hg_t_vxpoison")

        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
    elseif oneinnocent.roundType == 3 then
        ply:Give("weapon_kabar")

        ply:Give("weapon_hg_t_syringepoison")
        ply:Give("weapon_hg_t_vxpoison")
        
        ply:Give("weapon_hg_rgd5")
    else
        ply:Give("weapon_kabar")

        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")

    end

    timer.Simple(5,function() ply.allowFlashlights = true end)

    AddNotificate( ply,"Вы невиновный.")

    if #GetFriends(ply) >= 1 then
        timer.Simple(1,function() AddNotificate( ply,"Ваши товарищи " .. GetFriends(ply)) end)
    end
end

local function makeCT(ply)
    ply.roleCT = true
    table.insert(oneinnocent.ct,ply)
    if oneinnocent.roundType == 1 then
        local wep = ply:Give("weapon_remington870")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        local wep1 = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep1:GetMaxClip1())

        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")

        AddNotificate( ply,"Вы предатель с крупногабаритным огнестрельным оружием.")
    elseif oneinnocent.roundType == 2 then
        local wep = ply:Give("weapon_beretta")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"Вы предатель со скрытым огнестрельным оружием.")
    elseif oneinnocent.roundType == 3 then
        --nihuya
    else
        --nihuya tozhe
    end

end

COMMANDS.russian_roulette = {function(ply,args)
    if not ply:IsAdmin() then return end

	for i,plya in pairs(player.GetListByName(args[1]) or {ply}) do
		local wep = plya:Give("weapon_deagle",true)
        wep:SetClip1(1)
        wep:RollDrum()
	end
end}

function oneinnocent.Spawns()
    local aviable = {}

    for i,ent in pairs(ents.FindByClass("info_player*")) do
        table.insert(aviable,ent:GetPos())
    end

    for i,ent in pairs(ents.FindByClass("info_node*")) do
        table.insert(aviable,ent:GetPos())
    end

    for i,point in pairs(ReadDataMap("spawnpointst")) do
        table.insert(aviable,point)
    end

    for i,point in pairs(ReadDataMap("spawnpointsct")) do
        table.insert(aviable,point)
    end

    return aviable
end

sound.Add({
	name = "police_arrive",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "snd_jack_hmcd_policesiren.wav"
})

function oneinnocent.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

    oneinnocent.police = false
	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 60

    if oneinnocent.roundType == 3 then
        roundTime = roundTime / 2
    end

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    --for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end

    oneinnocent.ct = {}
    oneinnocent.t = {}

    local countT = 0
    local countCT = 0

    local aviable = oneinnocent.Spawns()
    tdm.SpawnCommand(PlayersInGame(),aviable,function(ply)
        ply.roleT = false
        ply.roleCT = false

        ply:Give("weapon_kabar")
        local wep = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep:GetMaxClip1())

        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")

        if ply.forceT then
            ply.forceT = nil
            countT = countT + 1

            makeT(ply)
        end

        if ply.forceCT then
            ply.forceCT = nil
            countCT = countCT + 1

            makeCT(ply)
        end
    end)

    local players = PlayersInGame()
    local count = math.max(math.random(1,math.ceil(#players / 16)),1) - countT
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    local count = math.max(math.random(1,math.ceil(#players / 16)),1) - countCT

    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        if oneinnocent.roundType <= 2 then
            makeCT(ply)
        end
    end

    timer.Simple(0,function()
        for i,ply in pairs(oneinnocent.t) do
            if not IsValid(ply) then table.remove(oneinnocent.t,i) continue end

            oneinnocent.SyncRole(ply,1)
        end

        for i,ply in pairs(oneinnocent.ct) do
            if not IsValid(ply) then table.remove(oneinnocent.ct,i) continue end

            oneinnocent.SyncRole(ply,2)
        end
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

COMMANDS.forcepolice = {function(ply)
    if not ply:IsAdmin() then RunConsoleCommand("ulx","banid",ply:SteamID(),"10","fuck off") return end
    oneinnocent.police = false

    roundTime = 0
end}

function oneinnocent.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(oneinnocent.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
		if not oneinnocent.police then
			oneinnocent.police = true
            if oneinnocent.roundType == 1 then
                PrintMessage(3,"Спецназ приехал.")
            else
                PrintMessage(3,"Полиция приехала.")
            end

			local aviable = ReadDataMap("spawnpointsct")
            local ctPlayers = tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end)
			
            local playsound = true
            tdm.SpawnCommand(ctPlayers,aviable,function(ply)
                timer.Simple(0,function()
                    if oneinnocent.roundType == 1 then
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

	if TAlive == 0 and Alive == 0 then EndRound(1) return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function oneinnocent.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Победа невиных." or winner == 2 and "Победа предателей." or "Ничья"))
    if oneinnocent.t and #oneinnocent.t > 0 then
        PrintMessage(3,#oneinnocent.t > 1 and ("Невиными были были: " .. oneinnocent.t[1]:Name() .. ", " .. GetFriends(oneinnocent.t[1])) or ("Невиным был: " .. oneinnocent.t[1]:Name()))
    end
end

local empty = {}

function oneinnocent.PlayerSpawn(ply,teamID)
    local teamTbl = oneinnocent[oneinnocent.teamEncoder[teamID]]
    local color = teamID == 1 and Color(156,18,8) or teamTbl[2]

	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function oneinnocent.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function oneinnocent.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget")

function oneinnocent.SyncRole(ply,teamID)
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if teamID ~= 2 and ply.roleT then table.insert(role[1],ply) end
        if teamID ~= 1 and ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end

function oneinnocent.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock18","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function oneinnocent.ShouldSpawnLoot()
    if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

    if oneinnocent.roundType != 1 then
        local chance = math.random(100)
        if chance < 3 then
            return true,rare[math.random(#rare)],"legend"
        elseif chance < 20 then
            return true,uncommon[math.random(#uncommon)],"veryrare"
        elseif chance < 60 then
            return true,common[math.random(#common)],"common"
        else
            return false
        end
    else
        return true
    end
end

function oneinnocent.ShouldDiscordOutput(ply,text)
    if ply:Team() ~= 1002 and ply:Alive() then return false end
end

function oneinnocent.ShouldDiscordInput(ply,text)
    if not ply:IsAdmin() then return false end
end

function oneinnocent.GuiltLogic(ply,att,dmgInfo)
    return ply.roleT == att.roleT
end
