hook.Add("Player Spawn","level",function(ply)
    local func = TableRound().PlayerSpawn
    if func then func() end
end)

hook.Add("PlayerSwitchWeapon","level",function(ply,old,new)
    local func = TableRound().PlayerSwitchWeapon
    func = func and func(ply,old,new)
    if func ~= nil then return func end
end)

hook.Add("OnContextMenuOpen","level",function()
    if not roundActive then return end
    local func = TableRound().OnContextMenuOpen
    if func then func() end
end)

hook.Add("OnContextMenuClose","level",function()
    local func = TableRound().OnContextMenuClose
    if func then func() end
end)

hook.Add("CanUseSpectateHUD","level",function()
    local func = TableRound().CanUseSpectateHUD
    if func then return func() end
end)

hook.Add("Think","level",function()
    local func = TableRound().Think
    if func then func() end
end)
-- Функция для проверки и мутирования мертвых игроков
local function MuteDeadPlayers()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then
                if not ply:IsMuted() then
                    ply:SetMuted(true)
                    print("[MuteScript] Muted player: " .. ply:Nick() .. " (Dead or Spectator)")
                end
            else
                if ply:IsMuted() then
                    ply:SetMuted(false)
                    print("[MuteScript] Unmuted player: " .. ply:Nick() .. " (Alive)")
                end
            end
        end
    end
end

-- Хук, который вызывается при смерти игрока
hook.Add("PlayerDeath", "MuteOnDeath", function(victim, inflictor, attacker)
    if IsValid(victim) and not victim:IsMuted() then
        victim:SetMuted(true)
        print("[MuteScript] Muted player on death: " .. victim:Nick())
    end
end)

-- Хук, который вызывается при возрождении игрока
hook.Add("PlayerSpawn", "UnmuteOnSpawn", function(ply)
    if IsValid(ply) and ply:IsMuted() then
        ply:SetMuted(false)
        print("[MuteScript] Unmuted player on spawn: " .. ply:Nick())
    end
end)

-- Хук, который вызывается при смене команды игрока
hook.Add("OnPlayerChangedTeam", "MuteOnSpectate", function(ply, oldTeam, newTeam)
    if IsValid(ply) then
        if newTeam == TEAM_SPECTATOR and not ply:IsMuted() then
            ply:SetMuted(true)
            print("[MuteScript] Muted player on team change to spectator: " .. ply:Nick())
        elseif oldTeam == TEAM_SPECTATOR and ply:IsMuted() and ply:Alive() then
            ply:SetMuted(false)
            print("[MuteScript] Unmuted player on team change from spectator: " .. ply:Nick())
        end
    end
end)

-- Периодическая проверка всех игроков
timer.Create("PeriodicMuteCheck", 1, 0, MuteDeadPlayers)

-- Хук для проверки перед тем, как игрок начнет говорить
hook.Add("PlayerCanHearPlayersVoice", "PreventDeadTalking", function(listener, talker)
    if not IsValid(talker) or not talker:Alive() or talker:Team() == TEAM_SPECTATOR then
        return false
    end
    return true
end)

print("[MuteScript] Скрипт мутирования мертвых игроков загружен!")