local function GetFriends(play)
    
    local huy = ""

    for i, ply in pairs(homicide_extended.t) do
        if play == ply then continue end
        huy = huy .. ply:Name() .. ", "
    end

    return huy
end

COMMANDS.homicide_extended_get = {function(ply,args)
    if not ply:IsAdmin() then return end

    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
        if ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_extended_roleget")
    net.WriteTable(role)
    net.Send(ply)
end}

local function makeT(ply)
    ply.roleT = true
    table.insert(homicide_extended.t,ply)

    if homicide_extended.roundType == 1 then
        ply:SetModel(homicide_extended.models[math.random(#homicide_extended.models)])
        ply:Give("weapon_kabar")
        local wep = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
    elseif homicide_extended.roundType == 2 then
        ply:Give("weapon_hg_fireaxe")
        ply:Give("weapon_hg_rgd5")
        ply:SetHealth(250)
        ply:SetModel('models/models/konnie/jasonpart6/jasonpart6.mdl')
    elseif homicide_extended.roundType == 3 then
        ply:Give("weapon_t")
        local wep = ply:Give("weapon_glock")
        wep:SetClip1(wep:GetMaxClip1())
        local wep = ply:Give("weapon_xm1014")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:SetAmmo( 90, 41 )
        ply:SetModel('models/player/arctic.mdl')
    else
        ply:Give("weapon_t")
        local wep = ply:Give("weapon_glock")
        wep:SetClip1(wep:GetMaxClip1())
        local wep = ply:Give("weapon_xm1014")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:SetAmmo( 90, 41 )
    end

    timer.Simple(5,function() ply.allowFlashlights = true end)

    AddNotificate( ply,"Вы предатель.")

    if #GetFriends(ply) >= 1 then
        timer.Simple(1,function() AddNotificate( ply,"Ваши товарищи " .. GetFriends(ply)) end)
    end
end

local function makeCT(ply)
    ply.roleCT = true
    table.insert(homicide_extended.ct,ply)
    ply:SetModel(homicide_extended.models[math.random(#homicide_extended.models)])
    local wep = ply:Give("weapon_beretta")
    wep:SetClip1(wep:GetMaxClip1())
    AddNotificate( ply,"Вы агент ФБР.")

end

COMMANDS.russian_roulette = {function(ply,args)
    if not ply:IsAdmin() then return end

	for i,plya in pairs(player.GetListByName(args[1]) or {ply}) do
		local wep = plya:Give("weapon_deagle",true)
        wep:SetClip1(1)
        wep:RollDrum()
	end
end}

function homicide_extended.Spawns()
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
    for i,point in pairs(ReadDataMap("spawnpointspepoples")) do
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
local turnTable = {
    [1] = "Standart",
    [2] = "Murder in your zone",
    [3] = "Active shooter"
}

function homicide_extended.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)
    if SERVER then
        if math.random(1,10)>= 5 then
            homicide_extended.roundType = math.random(1,3)
            net.Start("roundType")
            net.WriteInt(homicide_extended.roundType,4)
            net.Broadcast()
            PrintMessage(3,"Тип раунда: "..turnTable[homicide_extended.roundType])
            
        else

            homicide_extended.roundType = 1
            net.Start("roundType")
            net.WriteInt(homicide_extended.roundType,4)
            net.Broadcast()
        

        end
        
    end

    homicide_extended.police = false
	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 60

    if homicide_extended.roundType == 3 then
        roundTime = roundTime / 2
    end

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    --for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end

    homicide_extended.ct = {}
    homicide_extended.t = {}

    local countT = 0
    local countCT = 0

    local aviable = homicide_extended.Spawns()
    tdm.SpawnCommand(PlayersInGame(),aviable,function(ply)
        ply.roleT = false
        ply.roleCT = false

        if homicide_extended.roundType == 4 then
            timer.Simple(0,function()
                ply:Give("weapon_deagle")
            end)
        end

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
    local players_rab = PlayersInGame()
    local count = math.max(math.random(1,math.ceil(#players / 16)),1) - countT
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end
    if math.random(1,10) >= 5 then
        local count = math.max(math.random(1,math.ceil(#players / 16)),1) - countCT

        for i = 1,count do
            local ply = table.Random(players)
            table.RemoveByValue(players,ply)

            makeCT(ply)
        end
    end
    if math.random(1,10) >= 6 then
        local count = math.max(math.random(1,math.ceil(#players_rab / 4)),1)

        for i = 1,count do
            local ply = table.Random(players_rab)
            table.RemoveByValue(players_rab,ply)
            local random = math.random(1,3)
            if not ply.roleT then
                ply:SetModel(homicide_extended.models[math.random(#homicide_extended.models)])
            end
            if random == 1 then
                ply:Give('weapon_molotok')
                ply:Give('food_vodka')
                ply:ChatPrint('Вы разнорабочий.')
            elseif random == 2 then
                ply:Give('weapon_hg_shovel')
                ply:Give('food_vodka')
                ply:Give('medkit')
                ply:Give('food_rum')
                ply:ChatPrint('Вы бармен.')
            elseif random == 3 then
                ply:Give('weapon_knife')
                ply:Give('adrenaline')
                ply:Give('medkit')
                ply:Give('med_band_big')
                ply:ChatPrint('Вы медик.')

            end
        end
    end

    timer.Simple(0,function()
        for i,ply in pairs(homicide_extended.t) do
            if not IsValid(ply) then table.remove(homicide_extended.t,i) continue end

            homicide_extended.SyncRole(ply,1)
        end

        for i,ply in pairs(homicide_extended.ct) do
            if not IsValid(ply) then table.remove(homicide_extended.ct,i) continue end

            homicide_extended.SyncRole(ply,2)
        end
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

COMMANDS.forcepolice = {function(ply)
    if not ply:IsAdmin() then RunConsoleCommand("ulx","banid",ply:SteamID(),"10","fuck off") return end
    homicide_extended.police = false

    roundTime = 0
end}

function homicide_extended.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(homicide_extended.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
		if not homicide_extended.police then
			homicide_extended.police = true
            if homicide_extended.roundType == 2 or homicide_extended.roundType == 3 then
                PrintMessage(3,"Спецназ приехал.")
            else
                PrintMessage(3,"Полиция приехала.")
            end

			local aviable = ReadDataMap("spawnpointsct")
            local ctPlayers = tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end)
			
            local playsound = true
            tdm.SpawnCommand(ctPlayers,aviable,function(ply)
                timer.Simple(0,function()
                    if homicide_extended.roundType == 1 then
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

function homicide_extended.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Победа предателей." or winner == 2 and "Победа невиновых." or "Ничья"))
    if homicide_extended.t and #homicide_extended.t > 0 then
        PrintMessage(3,#homicide_extended.t > 1 and ("Трейторами были: " .. homicide_extended.t[1]:Name() .. ", " .. GetFriends(homicide_extended.t[1])) or ("Трейтором был: " .. homicide_extended.t[1]:Name()))
    end
end

local empty = {}

function homicide_extended.PlayerSpawn(ply,teamID)
    local teamTbl = homicide_extended[homicide_extended.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

    if (not (homicide_extended.roundType == 1)) or not ply.roleT then
        ply:SetModel(homicide_extended.models[math.random(#homicide_extended.models)])
    end 
    ply:SetPlayerColor(color:ToVector())
    local random_math_znach = math.random(1,11)
    for i = 0, ply:GetNumBodyGroups() - 1 do
        ply:SetBodygroup(i, 0)
    end
	for i, group in ipairs(ply:GetBodyGroups()) do
		print(group.id.." => "..group.name.." ("..group.num.." subgroups)")
	end
    if ply:GetBodygroupName(1) == 'torso' then
        ply:SetBodygroup(1,math.random(0,38))
        ply:SetBodygroup(2,math.random(0,20))
        ply:SetBodygroup(3,math.random(0,5))
        ply:SetBodygroup(6,math.random(0,6))
    else
        ply:SetBodygroup(2,math.random(1,16))    
        ply:SetBodygroup(3,math.random(1,6))
        ply:SetBodygroup(4,math.random(0,1))
    end
	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function homicide_extended.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function homicide_extended.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_extended_roleget")

function homicide_extended.SyncRole(ply,teamID)
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if teamID ~= 2 and ply.roleT then table.insert(role[1],ply) end
        if teamID ~= 1 and ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_extended_roleget")
    net.WriteTable(role)
    net.Send(ply)
end

function homicide_extended.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_p220","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function homicide_extended.ShouldSpawnLoot()
    if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

    if homicide_extended.roundType != 1 then
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

function homicide_extended.ShouldDiscordOutput(ply,text)
    if ply:Team() ~= 1002 and ply:Alive() then return false end
end

function homicide_extended.ShouldDiscordInput(ply,text)
    if not ply:IsAdmin() then return false end
end

function homicide_extended.GuiltLogic(ply,att,dmgInfo)
    return ply.roleT == att.roleT
end
