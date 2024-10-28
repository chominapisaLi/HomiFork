-- Таблица для хранения времени последнего спавна зомби для каждого игрока
local lastSpawnTime = {}
timer.Create("ZombieSpawnerTimer", 1, 0, function() -- 1800 секунд = 30 минут
    -- Проходим по всем игрокам на сервере
    for _, player in ipairs(player.GetAll()) do
        -- Проверяем, что игрок находится на карте и жив
        if IsValid(player) and player:Alive() then
            local currentTime = CurTime()

            -- Проверяем, прошло ли 30 минут с последнего спавна
            if not lastSpawnTime[player:SteamID()] or (currentTime - lastSpawnTime[player:SteamID()]) >= 60 then
                local spawnPos = player:GetPos() + Vector(math.random(60,90), 0, 10) -- Поднимаем зомби немного вверх, чтобы он не застрял в земле
                
                -- Создаем зомби
                local zombie = ents.Create("npc_zombie")
                if IsValid(zombie) then
                    zombie:SetPos(spawnPos)
                    zombie:Spawn()
                    print('zombie spawned')
                end

                -- Обновляем время последнего спавна для этого игрока
                lastSpawnTime[player:SteamID()] = currentTime
                break
            end
        end
    end
end) 
print('Started!')