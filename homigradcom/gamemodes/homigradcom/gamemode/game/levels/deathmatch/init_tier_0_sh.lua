table.insert(LevelList,"dm")
dm = {}
dm.Name = "DeathMatch"
dm.LoadScreenTime = 20
dm.CantFight = dm.LoadScreenTime

dm.RoundRandomDefalut = 1
dm.NoSelectRandom = true
dm.HUDPaint_RoundFelt = true 
dm.HUDPaint_RoundText = "До начала стрельбы: " 
local red = Color(155,155,255)

function dm.GetTeamName(ply)
    local teamID = ply:Team()

     if teamID == 1 then return "Боец",red end
end

function dm.StartRound(data)
    team.SetColor(1,red)
    team.SetColor(2,blue)
    team.SetColor(1,green)

    game.CleanUpMap(true)

    if CLIENT then
        roundTimeStart = data[1]
        roundTime = data[2]
        dm.StartRoundCL()

        return
    end

    return dm.StartRoundSV()
end

if SERVER then return end

local nigger = Color(0,0,0)
local red = Color(255,0,0)

local kill = 4

local white,red = Color(255,255,255),Color(255,0,0)

local fuck,fuckLerp = 0,0


local playsound = false
function dm.StartRoundCL()
    playsound = true
end
local spisok_dm = {"shotgun", "m4a4", "mp5"}
function dm.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()

	local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,175),0.5,0.5)
        local name = lply.DmCLASS
        local name = lply:GetNW2String('DmCLASS')
        local textt = ''
        if name == "shotgun" then
            textt = 'Штурмовик'
        elseif name == "m4a4" then
            textt = 'Стрелок'
        else
            textt = 'Разведчик'
        end
        draw.DrawText( "Вы " .. textt, "HomigradFontBig", ScrW() / 2, ScrH() / 2 +50, Color( 155,155,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Ты боец", "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( 155,155,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Бой Насмерть", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,155,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( roundTypes[roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "У тебя есть оружие, уничтож всех", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end

net.Receive("dm die",function()
    timeStartAnyDeath = CurTime()
end)

function dm.CanUseSpectateHUD()
    return false
end

dm.RoundRandomDefalut = 1