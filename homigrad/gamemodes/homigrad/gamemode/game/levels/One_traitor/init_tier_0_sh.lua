table.insert(LevelList,"oneinnocent")
oneinnocent = oneinnocent or {}
oneinnocent.Name = "Иголка в стоге сена"

oneinnocent.red = {"Невиновный",Color(125,125,125),
    models = tdm.models
}

oneinnocent.teamEncoder = {
    [1] = "red"
}

oneinnocent.RoundRandomDefalut = 3

local playsound = false
if SERVER then
    util.AddNetworkString("roundType")
else
    net.Receive("roundType",function(len)
        oneinnocent.roundType = net.ReadInt(4)
        playsound = true
    end)
end

--[[local turnTable = {
    ["standard"] = 2,
    ["soe"] = 1,
    ["wild-west"] = 4,
    ["gun-free-zone"] = 3
}--]]

local oneinnocent_setmode = CreateConVar("homicide_setmode","",FCVAR_LUA_SERVER,"")

function oneinnocent.IsMapBig()
    local mins,maxs = game.GetWorld():GetModelBounds()
    local skybox = 0
    for i,ent in pairs(ents.FindByClass("sky_camera")) do
        --local skyboxang = ent:GetPos():GetNormalized():Dot(maxs:GetNormalized())
        
        skybox = 0--skyboxang > 0 and ent:GetPos():Distance(-mins) or ent:GetPos():Distance(-maxs)
        --maxs:Sub(skybox)
    end
    
    --PrintMessage(3,tostring(mins:Distance(maxs) - skybox))
    return (mins:Distance(maxs) - skybox) > 5000
    --Vector(-10000, -2000, -2500) Vector(5000, 10000, 800)
end

function oneinnocent.StartRound(data)
    team.SetColor(1,oneinnocent.red[2])

    game.CleanUpMap(false)

    if SERVER then
        local roundType = oneinnocent_setmode:GetInt() == 1 and 1 or (oneinnocent.IsMapBig() and 1) or false

        oneinnocent.roundType = roundType or math.random(2,4)
        --soe, standard, gun-free-zone, wild west
        --print(homicide_setmode:GetString(),homicide.roundType)
        net.Start("roundType")
        net.WriteInt(oneinnocent.roundType,4)
        net.Broadcast()
    end

    if CLIENT then
        for i,ply in pairs(player.GetAll()) do
            ply.roleT = false
            ply.roleCT = false
            ply.countKick = 0
        end

        roundTimeLoot = data.roundTimeLoot

        return
    end

    return oneinnocent.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(200,0,10)
local gray = Color(200,0,10)
function oneinnocent.GetTeamName(ply)
    if ply.roleT then return "Невиновный",red end
    if ply.roleCT then return "Предатель",blue end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Невиновный",ScoreboardSpec
    end
    if teamID == 3 then
        return "Спецназ",blue
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget",function()
    local role = net.ReadTable()

    for i,ply in pairs(role[1]) do ply.roleT = true end
    for i,ply in pairs(role[2]) do ply.roleCT = true end
end)

function oneinnocent.HUDPaint_Spectate(spec)
    --local name,color = homicide.GetTeamName(spec)
    --draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function oneinnocent.Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return true end

    return "Неизвестно",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(200,0,10)
local roundTypes = {"State of Emergency", "Standard", "Gun-Free-Zone", "Wild West"}
local roundSound = {"snd_jack_hmcd_disaster.mp3","snd_jack_hmcd_shining.mp3","snd_jack_hmcd_panic.mp3","snd_jack_hmcd_wildwest.mp3"}

function oneinnocent.HUDPaint_RoundLeft(white2)
    local roundType = oneinnocent.roundType or 2
    local lply = LocalPlayer()
    local name,color = oneinnocent.GetTeamName(lply)

    local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound[oneinnocent.roundType])
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),3,0.5)


        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Хомисайд", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,55,97,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( roundTypes[roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 155,55,97,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        if lply.roleT then
            draw.DrawText( "Ваша задача выжить или убить всех до прибытия полиции >:)", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,97,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        elseif lply.roleCT then
            if oneinnocent.roundType == 2 then 
                draw.DrawText( "У вас есть крупногабаритное оружие, постарайтесь нейтрализовать невиного >:)", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,97,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            else
                draw.DrawText( "У вас есть скрытое огнестрельное оружие, постарайтесь нейтрализовать невиного >:)", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,97,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            end
        else
            draw.DrawText( "Найдите невиновного, свяжите или убейте его для победы. Не доверяйте никому... >:)", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 46,41,41,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

    local time = math.Round(roundTimeStart + roundTimeLoot - CurTime())
    if time > 0 then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = "До спавна лута : " .. acurcetime

        draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local lply_pos = lply:GetPos()

    for i,ply in pairs(player.GetAll()) do
        local color = ply.roleT and red or ply.roleCT and blue
        if not color or ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if dis > 350 then continue end

        local pos = pos:ToScreen()
        if not pos.visible then continue end

        color.a = 255 * (1 - dis / 350)

        draw.SimpleText(ply:Nick(),"HomigradFont",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function oneinnocent.VBWHide(ply,list)
    if (not ply:IsRagdoll() and ply:Team() == 1002) then return end

    local blad = {}
    
    for i,wep in pairs(list) do
        local wep = type(i) == "string" and weapons.Get(i) or list[i]
        
        if not wep.TwoHands then continue end

        blad[#blad + 1] = wep
    end--ufff

    return blad
end

function oneinnocent.Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

oneinnocent.SupportCenter = true
