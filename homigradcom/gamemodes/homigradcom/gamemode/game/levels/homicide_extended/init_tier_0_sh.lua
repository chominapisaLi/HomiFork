table.insert(LevelList,"homicide_extended")
homicide_extended = homicide_extended or {}
homicide_extended.Name = "homicide_extended"
homicide_extended.models = {}
for i = 1,4 do
	homicide_extended.models[#homicide_extended.models + 1] = "models/player/pandafishizens/female_0"..i..".mdl"
end
for i = 6,7 do
	homicide_extended.models[#homicide_extended.models + 1] = "models/player/pandafishizens/female_0"..i..".mdl"
end
for i = 1,9 do
	homicide_extended.models[#homicide_extended.models + 1] = "models/player/pandafishizens/male_0"..i..".mdl"
end
homicide_extended.models[#homicide_extended.models + 1] = "models/player/pandafishizens/male_10.mdl"


homicide_extended.red = {"Невиновный",Color(125,125,125),
    models = {}
}

homicide_extended.teamEncoder = {
    [1] = "red"
}

homicide_extended.RoundRandomDefalut = 5
homicide_extended.HUDPaint_RoundFelt = false
homicide_extended.HUDPaint_RoundText = 'Полиция в пути' 
homicide_extended.BloodShed_Text = '' 
local playsound = false
<<<<<<< Updated upstream
local turnTable = {
    [1] = "Standart",
    [2] = "Murder in your zone",
    [3] = "Active shooter"
}

if SERVER then
    util.AddNetworkString("roundType")
else
    net.Receive("roundType", function(len)
        homicide_extended.roundType = net.ReadInt(4)
        local roundType = turnTable[homicide_extended.roundType] -- Convert numeric type to string description

        homicide_extended.BloodShed_Text = roundType -- Set the blood shed text
=======
if SERVER then
    util.AddNetworkString("roundType_extended")
else
    net.Receive("roundType_extended",function(len)
        homicide_extended.roundType = net.ReadInt(4)
>>>>>>> Stashed changes
        playsound = true
    end)
end

<<<<<<< Updated upstream
=======
local turnTable = {
    [1] = "Стандартный",
    [2] = "Убийца в вашей зоне",
    [3] = "Активный стрелок"
}

if SERVER then
    util.AddNetworkString("roundType_extended")
end
>>>>>>> Stashed changes

local homicide_extended_setmode = CreateConVar("homicide_extended_setmode","",FCVAR_LUA_SERVER,"")

function homicide_extended.IsMapBig()
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

function homicide_extended.StartRound(data)
    team.SetColor(1,homicide_extended.red[2])

<<<<<<< Updated upstream
    game.CleanUpMap(false)

    if SERVER then
        local roundType = homicide_extended_setmode:GetInt() == 1 and 1 or (homicide_extended.IsMapBig() and 1) or false
        if math.random(1,10)>= 5 then
            homicide_extended.roundType = math.random(1,3)
            homicide_extended.BloodShed_Text = turnTable[homicide_extended.roundType]
            net.Start("roundType")
            net.WriteInt(homicide_extended.roundType,4)
            net.Broadcast()
        else

            homicide_extended.roundType = 1
            net.Start("roundType")
            net.WriteInt(homicide_extended.roundType,4)
            net.Broadcast()
        

        end
        
    end
=======
    if SERVER then

        homicide_extended.roundType = math.random(1,3)
        --soe, standard, gun-free-zone, wild west
        --print(homicide_setmode:GetString(),homicide.roundType)
        net.Start("roundType_extended")
        net.WriteInt(homicide_extended.roundType,4)
        net.Broadcast()
    end
    game.CleanUpMap(false)
    --roundType_extended
>>>>>>> Stashed changes

    if CLIENT then
        for i,ply in pairs(player.GetAll()) do
            ply.roleT = false
            ply.roleCT = false
            ply.countKick = 0
            ply.role_homicide_extended = 0
            ply.roundType = homicide_extended.roundType
        end

        roundTimeLoot = data.roundTimeLoot

        return
    end

    return homicide_extended.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function homicide_extended.GetTeamName(ply)
    if ply.roleT then return "Предатель",red end
    if ply.roleCT then return "Невиновный",blue end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Невиновный",ScoreboardSpec
    end
    if teamID == 3 then
        return "Спецназ",blue
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_extended_roleget",function()
    local role = net.ReadTable()

    for i,ply in pairs(role[1]) do ply.roleT = true end
    for i,ply in pairs(role[2]) do ply.roleCT = true end
end)

function homicide_extended.HUDPaint_Spectate(spec)
    --local name,color = homicide_extended.GetTeamName(spec)
    --draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function homicide_extended.Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return true end

    return "Неизвестно",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(75,75,255)
local roundTypes = {"Standard", "A Serial Killer in your zone", "Active Shooter"}
local roundSound = {"snd_jack_hmcd_disaster.mp3","snd_jack_hmcd_shining.mp3","snd_jack_hmcd_panic.mp3","snd_jack_hmcd_wildwest.mp3"}
homicide_extended.HUDPaint_BloodShed = true
function homicide_extended.HUDPaint_RoundLeft(white2)
<<<<<<< Updated upstream
    if SERVER then
        util.AddNetworkString("roundType")
    else
        net.Receive("roundType", function(len)
            homicide_extended.roundType = net.ReadInt(4)
            local roundType = turnTable[homicide_extended.roundType] -- Convert numeric type to string description
            homicide_extended.BloodShed_Text = roundType -- Set the blood shed text
            playsound = true
        end)
    end
=======

>>>>>>> Stashed changes
    local lply = LocalPlayer()
    local name,color = homicide_extended.GetTeamName(lply)

    local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound[math.random(1,3)])
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,175),0.5,0.5)

<<<<<<< Updated upstream

        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
=======
        -- yay!! я пофиксил!!
        draw.DrawText( turnTable[homicide_extended.roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

>>>>>>> Stashed changes
        if lply.roleCT then
            name = name.."(Агент ФБР)"
        end
        draw.DrawText( "Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
<<<<<<< Updated upstream
        draw.DrawText( "Хомисайд Экстендед ", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( LocalPlayer().roundType, "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        print(roundType)

        if lply.roleT then
            draw.DrawText( "Ваша задача убить всех до прибытия полиции", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        elseif lply.roleCT then
            if homicide_extended.roundType == 2 then 
                draw.DrawText( "Вы скрытый агент ФБР у вас есть скрытое огнестрельное оружие\nНейтрализуйте стрелка до приезда полиции.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide_extended.roundType == 3 then
                draw.DrawText( "Вы скрытый агент ФБР у вас есть скрытое огнестрельное оружие\nНейтрализуйте стрелка до приезда полиции.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER ) 
=======
        draw.DrawText( "Хомисайд Экстендед ", "HomigradFontBiggest", ScrW() / 2, ScrH() / 8, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( LocalPlayer().roundType, "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        local roundType_extended = homicide_extended.roundType

        --lply:ChatPrint(homicide_extended.roundType)
        if lply.roleT then
            draw.DrawText( "Ваша задача убить всех до прибытия полиции", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        elseif lply.roleCT then
            if roundType_extended == 3 then 
                draw.DrawText( "Вы скрытый агент ФБР у вас есть скрытое огнестрельное оружие\nНейтрализуйте стрелка до приезда полиции.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif roundType_extended == 2 then
                draw.DrawText( "Вы скрытый агент ФБР у вас есть скрытое огнестрельное оружие\nНейтрализуйте серийного убийцу до приезда полиции.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER ) 
>>>>>>> Stashed changes
            else
                draw.DrawText( "Вы скрытый агент ФБР у вас есть скрытое огнестрельное оружие\nпостарайтесь нейтрализовать предателя.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            end
        else
<<<<<<< Updated upstream
            if homicide_extended.roundType == 2 then
                draw.DrawText( "В вашей зоне замечен стрелок. Спрячьтесь где либо.\nЛибо попытайтесь отбиваться если вас заметили.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )    
            elseif homicide_extended.roundType == 3 then
=======
            if roundType_extended == 3 then
                draw.DrawText( "В вашей зоне замечен стрелок. Спрячьтесь где либо.\nЛибо попытайтесь отбиваться если вас заметили.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )    
            elseif roundType_extended == 2 then
>>>>>>> Stashed changes
                draw.DrawText( "В вашей зоне замечен серийный маньяк. Спрячьтесь где либо.\nЛибо попытайтесь отбиваться если вас заметили.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )    

            else
                draw.DrawText( "Найдите предателя, свяжите или убейте его для победы. Не доверяйте никому...", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )    
            
            end
            
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

function homicide_extended.VBWHide(ply,list)
    if (not ply:IsRagdoll() and ply:Team() == 1002) then return end

    local blad = {}
    
    for i,wep in pairs(list) do
        local wep = type(i) == "string" and weapons.Get(i) or list[i]
        
        if not wep.TwoHands then continue end

        blad[#blad + 1] = wep
    end--ufff

    return blad
end

function homicide_extended.Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

homicide_extended.SupportCenter = true
