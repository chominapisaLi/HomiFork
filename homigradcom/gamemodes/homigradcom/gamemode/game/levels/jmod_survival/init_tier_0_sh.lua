--table.insert(LevelList,"jmod_survival")
jmod_survival = jmod_survival or {}
jmod_survival.Name = "JMOD SURVIVAL"
jmod_survival.LoadScreenTime = 20
jmod_survival.CantFight = dm.LoadScreenTime
jmod_survival.red = {"Игрок",Color(125,125,125),
    models = tdm.models
}

jmod_survival.teamEncoder = {
    [1] = "red"
}

jmod_survival.RoundRandomDefalut = 1
jmod_survival.CanRandomNext = false
jmod_survival.HUDPaint_RoundLeft = true   
jmod_survival.HUDPaint_RoundText = "До стрельбы осталось: " 
local playsound = false

function jmod_survival.StartRound(data)
    team.SetColor(1,jmod_survival.red[2])

    game.CleanUpMap(true)

    if SERVER then
        net.Start("roundType2")
        net.Broadcast()
    end

    if CLIENT then

        return
    end

    return jmod_survival.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function jmod_survival.GetTeamName(ply)
    if ply.roleT then return "Я хз че сказать",red end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Игрок",ScoreboardSpec
    end
end

local black = Color(0,0,0,255)


function jmod_survival.HUDPaint_Spectate(spec)
    local name,color = jmod_survival.GetTeamName(spec)
    draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function jmod_survival.Scoreboard_Status(ply)
    local lply = LocalPlayer()

    return true
    --if not lply:Alive() or lply:Team() == 1002 then return true end

    --return "Неизвестно",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(75,75,255)
local roundSound = "snd_jack_hmcd_wildwest.mp3"

function jmod_survival.HUDPaint_RoundLeft(white2)
    local lply = LocalPlayer()
    local name,color = jmod_survival.GetTeamName(lply)

    local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound)
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,175),0.5,0.5)

        draw.DrawText( "Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "JMOD SURVIVAL", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 8,243,0,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        if lply.roleT then
            draw.DrawText( "Вы - Джон Уик, разберитесь со всеми наемниками.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 255,0,0,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "Тестовый режим для просмотра функций JMOD'a", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 255,255,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

end