hell_yeah.GetTeamName = tdm.GetTeamName

local playsound = false
local bhop
function hell_yeah.StartRoundCL()
    sound.PlayURL("https://cdn.discordapp.com/attachments/1111941531562168360/1299062191781183588/aspose_video_133742644488633885_out.mp3?ex=671c7e31&is=671b2cb1&hm=421f14c8d13799f19868468c34795bbf6d1d4d6d2dbef88568f072ac5bb92814&","mono noblock",function(snd)
        bhop = snd
        if snd ~= nil then
            snd:SetVolume(1)
        end
    end) 
end


function hell_yeah.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = hell_yeah.GetTeamName(lply)

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,175),0.5,0.5)


        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "Ваша  " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "HELL YEAH!", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,155,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( roundTypes[roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        if name == "Полиция" then
            draw.DrawText( "Сгубите вражескую Семью за оскорбление ваших ценностей! >:)", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,155,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "Сгубите вражескую Семью и докажите их неправоту! >:)", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,155,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

    --draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end
