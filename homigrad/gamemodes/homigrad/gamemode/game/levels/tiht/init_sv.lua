local firstG = {
    "weapon_mp5",
    "weapon_ar15",
    "weapon_akm",
    "weapon_m4a1",
    "weapon_xm1014",
    "weapon_remington870",
    "weapon_galilsar"
}

local secondG = {
        "weapon_beretta",
	"weapon_deagle",
	"weapon_fiveseven",
	"weapon_glock"
}
 
local Meele = {
	"weapon_pipeweapon_hg_hatchet",
        "weapon_knife",
        "weapon_police_bat",
        "weapon_hg_fireaxe",
        "weapon_hg_shovel",
        "weapon_hg_metalbat",
        "weapon_hg_crowbar",
        "weapon_hg_kitknife"
}      

local function GetFriends(play)
    
    local huy = ""

    for i, ply in pairs(tiht.t) do
        if play == ply then continue end
        huy = huy .. ply:Name() .. ", "
    end

    return huy
end

COMMANDS.tiht_get = {function(ply,args)
    if not ply:IsAdmin() then return end

    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
        if ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("tiht_roleget")
    net.WriteTable(role)
    net.Send(ply)
end}

local function makeT(ply)

    ply.roleT = true
    table.insert(tiht.t,ply)
    
    if tiht.roundType == 1 then
        ply:Give("weapon_hg_t_syringepoison")
        ply:Give("weapon_hg_t_vxpoison")

        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
    elseif tiht.roundType == 2 then
        ply:Give("weapon_hg_t_syringepoison")
        ply:Give("weapon_hg_t_vxpoison")

        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
    elseif tiht.roundType == 3 then

        ply:Give("weapon_hg_t_syringepoison")
        ply:Give("weapon_hg_t_vxpoison")
        
        ply:Give("weapon_hg_rgd5")
    else

        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:GiveAmmo(12,5)
    end

    timer.Simple(5,function() ply.allowFlashlights = true end)

    AddNotificate( ply,"Вы предатель.")

    if #GetFriends(ply) >= 1 then
        timer.Simple(1,function() AddNotificate( ply,"Ваши товарищи " .. GetFriends(ply)) end)
    end
end

local function makeCT(ply)
    ply.roleCT = true
    table.insert(tiht.ct,ply)
    if tiht.roundType == 1 then
        local wep = ply:Give("weapon_handcuffs")
        local wep = ply:Give("weapon_taser")
        local wep = ply:Give("weapon_per4ik")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"Вы шериф с стяжками, тазером и перцовым балончиком")
    elseif tiht.roundType == 2 then
        local wep = ply:Give("weapon_handcuffs")
        local wep = ply:Give("weapon_taser")
        local wep = ply:Give("weapon_per4ik")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"Вы шериф с стяжками, тазером и перцовым балончиком")
    elseif tiht.roundType == 3 then
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

function tiht.Spawns()
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

function tiht.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

    tiht.police = false
	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 60

    if tiht.roundType == 3 then
        roundTime = roundTime / 2
    end

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    --for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end

    tiht.ct = {}
    tiht.t = {}

    local countT = 0
    local countCT = 0

    local aviable = tiht.Spawns()
    tdm.SpawnCommand(PlayersInGame(),aviable,function(ply)
        ply.roleT = false
        ply.roleCT = false
        table.insert(tiht.ct,ply)
        local Meele = {
            "weapon_pipeweapon_hg_hatchet",
                "weapon_knife",
                "weapon_police_bat",
                "weapon_hg_fireaxe",
                "weapon_hg_shovel",
                "weapon_hg_metalbat",
                "weapon_hg_crowbar",
                "weapon_hg_kitknife"
        }      
        local wep1 = math.random(1,#firstG)
        local wep2 = math.random(1,#secondG)
        local randomIndex = math.random(1, #Meele) 
        print(wep1)
        local wep1Give = ply:Give(firstG[wep1])
        local wep2Give = ply:Give(secondG[wep2])
        local wep3Give = ply:Give(Meele[randomIndex])

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

        if tiht.roundType <= 2 then
            makeCT(ply)
        end
    end

    timer.Simple(0,function()
        for i,ply in pairs(tiht.t) do
            if not IsValid(ply) then table.remove(tiht.t,i) continue end

            tiht.SyncRole(ply,1)
        end

        for i,ply in pairs(tiht.ct) do
            if not IsValid(ply) then table.remove(tiht.ct,i) continue end

            tiht.SyncRole(ply,2)
        end
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

COMMANDS.forcepolice = {function(ply)
    if not ply:IsAdmin() then RunConsoleCommand("ulx","banid",ply:SteamID(),"10","fuck off") return end
    tiht.police = false

    roundTime = 0
end}

function tiht.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(tiht.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
		if not tiht.police then
			tiht.police = true
            if tiht.roundType == 1 then
                PrintMessage(3,"Спецназ приехал.")
            else
                PrintMessage(3,"Полиция приехала.")
            end

			local aviable = ReadDataMap("spawnpointsct")
            local ctPlayers = tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end)
			
            local playsound = true
            tdm.SpawnCommand(ctPlayers,aviable,function(ply)
                timer.Simple(0,function()
                    if tiht.roundType == 1 then
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

function tiht.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Победа предателей." or winner == 2 and "Победа невиновых." or "Ничья"))
    if tiht.t and #tiht.t > 0 then
        PrintMessage(3,#tiht.t > 1 and ("Трейторами были: " .. tiht.t[1]:Name() .. ", " .. GetFriends(tiht.t[1])) or ("Трейтором был: " .. tiht.t[1]:Name()))
    end
end

local empty = {}
local models_1 = {"models/bala/monsterboys_pm.mdl", "models/player/cla/classic_ghostface.mdl", "models/players/mj_dbd_kk.mdl", "models/player/ghost_male_02/ghost_male_02.mdl", "models/models/konnie/jasonpart6/jasonpart6.mdl", "models/players/mj_dbd_kk.mdl", "models/players/mj_dbd_kk_joey.mdl", "models/players/mj_dbd_kk_julie.mdl", "models/players/mj_dbd_kk_susie.mdl"}

function tiht.PlayerSpawn(ply,teamID)
    local teamTbl = tiht[tiht.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]
	ply:SetModel(models_1[math.random(1,#models_1)])
    ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
    JMod.EZ_Equip_Armor(ply,"Medium-Vest",color)
    local tvoyaostanovka = math.random(1,3) 
    if tvoyaostanovka == 1 then 
        JMod.EZ_Equip_Armor(ply,"Traffic Cone",color)
    elseif tvoyaostanovka == 2 then
        JMod.EZ_Equip_Armor(ply,"Ceramic Pot",color)
        
    else
        JMod.EZ_Equip_Armor(ply,'Metal Pot',color)
    end
end

function tiht.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function tiht.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("tiht_roleget")

function tiht.SyncRole(ply,teamID)
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if teamID ~= 2 and ply.roleT then table.insert(role[1],ply) end
        if teamID ~= 1 and ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("tiht_roleget")
    net.WriteTable(role)
    net.Send(ply)
end

function tiht.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock","weapon_t","weapon_per4ik","*ammo*"}

function tiht.ShouldSpawnLoot()
    if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

    if tiht.roundType != 1 then
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

function tiht.ShouldDiscordOutput(ply,text)
    if ply:Team() ~= 1002 and ply:Alive() then return false end
end

function tiht.ShouldDiscordInput(ply,text)
    if not ply:IsAdmin() then return false end
end

function tiht.GuiltLogic(ply,att,dmgInfo)
    return ply.roleT == att.roleT
end
