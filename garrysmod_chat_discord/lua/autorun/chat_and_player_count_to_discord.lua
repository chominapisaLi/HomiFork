-- Файл: chat_and_player_count_to_discord.lua
-- Замените URL на ваш вебхук Discord
local discord_webhook_url = "https://robloxapi.ru/api/chat/?name=123&steam_id=123&text=123"
    -- Отправляем POST-запрос на сервер


-- Функция для отправки данных на FastAPI-сервер
local function sendToDiscord(name, steamID, message)


    -- Отправляем POST-запрос на сервер
    local url = "https://robloxapi.ru/api/chat/"
    print(url)
    http.Post( url, {name = name,steam_id = steamID, text=message},

        -- onSuccess function
        function( body, length, headers, code )
            print( "Done!" )
        end,

        -- onFailure function
        function( message )
            print( message )
        end

    )
end

-- Пример использования функции--
sendToDiscord("PlayerName", "STEAM_0:1:12345678", "Привет из GMod!")
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
        sendToDiscord(name,player:SteamID64(),text)
    else
        -- Сообщение не отправляется в Discord
        print("Сообщение от " .. name .. " было отклонено: " .. text)
    end
end)

-- Отправка количества игроков каждую минуту
timer.Create("PlayerCountTimer", 60, 0, sendPlayerCount)

sendToDiscord("Сервер был запущен!")