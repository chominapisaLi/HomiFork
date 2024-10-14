-- Файл: chat_and_player_count_to_discord.lua
-- Замените URL на ваш вебхук Discord
local discord_webhook_url = "https://discord.com/api/webhooks/1294944887237775361/KzNltMz0OnyslxXScMutzejnz5T5nZ8lrAJkry5r7xJ7UZ8KbKLgef0swsDyGGV7ntIQ"

-- Функция для отправки сообщения в Discord
local function sendToDiscord(message)
    local data = {
        content = message,
        username = "Server Bot",
        avatar_url = "https://example.com/avatar.png", -- URL для аватара
    }

    -- Отправка запроса в Discord
    http.Post(discord_webhook_url, data, function(response)
        print("Сообщение отправлено в Discord: " .. response)
    end, function(error)
        print("Ошибка при отправке сообщения в Discord: " .. error)
    end)
end

-- Функция для проверки сообщений
local function isMessageValid(message)
    -- Запрет упоминаний everyone, here и пользователей
    if message:find("@everyone") or message:find("@here") or message:match("@[%w_]+") then
        return false
    end

    -- Запрет ссылок
    if message:match("https?://[%w%.%-]+%.[%w%.%-]+") then
        return false
    end

    return true
end

-- Отправка сообщения о количестве игроков
local function sendPlayerCount()
    local playerCount = #player.GetAll() -- Получение количества игроков
    sendToDiscord("Текущее количество игроков на сервере: " .. playerCount)
end

-- Хук для перехвата всех сообщений в чате
hook.Add("OnPlayerChat", "SendChatToDiscord", function(player, text, teamChat, playerIsDead)
    local name = player:GetName()
    
    -- Проверка сообщения на валидность
    if isMessageValid(text) then
        sendToDiscord(name .. ": " .. text)
    else
        -- Сообщение не отправляется в Discord
        print("Сообщение от " .. name .. " было отклонено: " .. text)
    end
end)

-- Отправка количества игроков каждую минуту
timer.Create("PlayerCountTimer", 60, 0, sendPlayerCount)

sendToDiscord("Сервер был запущен!")