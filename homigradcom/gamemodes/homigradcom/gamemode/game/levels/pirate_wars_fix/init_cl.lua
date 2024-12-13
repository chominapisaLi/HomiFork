pirate_wars.GetTeamName = tdm.GetTeamName

local playsound = false
function pirate_wars.StartRoundCL()
    playsound = true
end

function pirate_wars.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = pirate_wars.GetTeamName(lply)

	local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_disaster.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,175),0.5,0.5)

        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "Ваш корабль  " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Пиратские Войны", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,155,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( roundTypes[roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "Йо хо хо! И бутылка рома.. Деритесь и грабьте всех кроме своих!", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 193,193,193,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end