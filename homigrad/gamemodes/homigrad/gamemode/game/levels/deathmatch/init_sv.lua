function dm.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 20

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

function dm.RoundEndCheck()
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

function dm.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

    PrintMessage(3,"Победил " .. ("последний..."))
end

local red = Color(255,0,0)
local spisok_dm = {"shotgun", "m4a4", "mp5"}
local spisok_dm_dop_class = {
    ["boom"] = "Гренадёр",
    ["medkit"] = "Медик"
}

function dm.PlayerSpawn(ply,teamID)
    ply.DmCLASS = spisok_dm[math.random(1,#spisok_dm)]
    ply:SetNW2String('DmCLASS', ply.DmCLASS)
    if math.random(1,3) == 1 then
        ply.DmCLASS_two = spisok_dm_dop_class[math.random(1,#spisok_dm_dop_class)]
        if ply.DmCLASS_two == "medkit" then 
            ply:Give("medkit")
            ply:Give("med_band_big")
            ply:Give("megamedkit")
        else
            ply:Give("weapon_hidebomb")
            ply:Give("weapon_hg_f1")
            ply:Give("weapon_hg_rgd5")
            ply:Give("weapon_hg_hl2")
            ply:Give("weapon_hg_molotov")
        end
    end
	ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0,0,0.6))
    ply:Give("weapon_hands")
    if ply.DmCLASS == "mp5" then
        local r = math.random(1,3)
        ply:Give((r==1 and "weapon_mp7") or (r==2 and "weapon_civil_famas") or (r==3 and "weapon_mp5"))
        ply:Give("weapon_t")
        ply:SetAmmo( 90, ((r==1 and 42) or(r==2 and 45) or (r==3 and 49)))
    elseif ply.DmCLASS == "shotgun" then
        local r = math.random(1,3)
        ply:Give((r==1 and "weapon_spas12") or (r==2 and "weapon_xm1014") or (r==3 and "weapon_remington870"))
        ply:Give("weapon_t")
        ply:SetAmmo( 90, 41 )
    elseif ply.DmCLASS == "m4a4" then
        local r = math.random(1,3)
        ply:Give((r==1 and "weapon_akm") or (r==2 and "weapon_ak74u") or (r==3 and "weapon_m4a1"))
        ply:Give("weapon_t")
        ply:SetAmmo( 90,  ((r==1 and 47) or(r==2 and 44) or (r==3 and 45)) )
    else
        local r = math.random(1,3)
        ply:Give((r==1 and "weapon_hk_usp") or (r==2 and "weapon_fiveseven") or (r==3 and "weapon_beretta"))
        ply:Give("weapon_t")
        ply:SetAmmo( 50, 49 )
    end
    ply:Give("weapon_radio")

    ply:SetLadderClimbSpeed(100)

end

function dm.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function dm.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("пашол нахуй") return false end

    return true
end

function dm.GuiltLogic() return false end

util.AddNetworkString("dm die")
function dm.PlayerDeath()
    net.Start("dm die")
    net.Broadcast()
end