if CLIENT then
    -- Таблица, содержащая имена интересующих нас классов
    local targetClasses = {
        ["box_normal_z"] = true,
        ["box_small"] = true,
        ["box_medical"] = true,
        ["box_weapon"] = true,
        ["food_*"] = true,
        ["weapon_*"] = true,  -- Это будет соответствовать всем классам, начинающимся с "weapon_"
        ["weapon_hg_*"] = true 
    }
    
    -- Максимальное расстояние для подсветки (в игровых юнитах)
    local MAX_HIGHLIGHT_DISTANCE = 100
    
    -- Хук для подсветки объекта (halo эффект)
    hook.Add("PreDrawHalos", "HighlightTargetEntity", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        
        -- Создаем трейс перед игроком
        local trace = ply:GetEyeTrace()
        local ent = trace.Entity
        
        -- Если энтити валиден и его класс совпадает с тем, что в таблице или начинается с "weapon_"
        if IsValid(ent) then
            local class = ent:GetClass()
            if targetClasses[class] or string.StartWith(class, "weapon_") then
                -- Проверяем расстояние до объекта
                local distance = ply:GetPos():Distance(ent:GetPos())
                
                if distance <= MAX_HIGHLIGHT_DISTANCE then
                    -- Подсвечиваем объект, если он находится в пределах допустимого расстояния
                    halo.Add({ent}, Color(255, 255, 255), 1, 1, 2, true, true)
                end
            end
        end
    end)
end