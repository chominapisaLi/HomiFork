
--table.insert(LevelList,"event")
event = event or {}
event.Name = "Ивент"

event.red = {"Участник Ивента",Color(125,125,125),
    models = tdm.models
}

event.teamEncoder = {
    [1] = "red"
}

event.RoundRandomDefalut = 1
event.CanRandomNext = false
event.HUDPaint_RoundFelt = true 
event.HUDPaint_RoundText = "" 
local playsound = false
if SERVER then
    util.AddNetworkString("roundType2")
else
    net.Receive("roundType2",function(len)
        playsound = true
    end)
end

function event.StartRound(data)
    team.SetColor(1,event.red[2])

    game.CleanUpMap(true)

    if SERVER then
        net.Start("roundType2")
        net.Broadcast()
    end

    if CLIENT then

        return
    end

    return event.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function event.GetTeamName(ply)
    if ply.roleT then return "Сосущий",red end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Участник Ивента",ScoreboardSpec
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget2",function()
    for i,ply in pairs(player.GetAll()) do ply.roleT = nil end
    local role = net.ReadTable()

    for i,ply in pairs(role[1]) do ply.roleT = true end
end)

function event.HUDPaint_Spectate(spec)
    local name,color = event.GetTeamName(spec)
    draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function event.Scoreboard_Status(ply)
    local lply = LocalPlayer()

    return true
    --if not lply:Alive() or lply:Team() == 1002 then return true end

    --return "Неизвестно",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(75,75,255)
local roundSound = "snd_jack_hmcd_wildwest.mp3"

function event.HUDPaint_RoundLeft(white2)
    local lply = LocalPlayer()
    local name,color = event.GetTeamName(lply)

    local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound)
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,175),0.5,0.5)

        draw.DrawText( "Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Ивент", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 8,243,0,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        if lply.roleT then
            draw.DrawText( "Вы - Джон Уик, разберитесь со всеми наемниками.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 255,0,0,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "Подчинайтесь правилам ивентов и победите в нем.\nЗа победу в ивентах часто дают призы.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 255,255,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

    local lply_pos = lply:GetPos()

    for i,ply in pairs(player.GetAll()) do
        local color = ply.roleT and red
        if not color or ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if dis > 750 then continue end

        local pos = pos:ToScreen()
        if not pos.visible then continue end

        color.a = 255 * (1 - dis / 750)

        draw.SimpleText(ply.roleT and "Джон Уик" or "","HomigradFont",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end