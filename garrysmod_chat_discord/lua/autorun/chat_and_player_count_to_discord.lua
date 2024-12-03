-- Configuration
if SERVER then
    local config = {
        API_URL = "http://robloxapi.ru", -- Replace with your actual server IP
        SEND_INTERVAL = 5, -- How often to send logs (seconds)
        DEBUG = false -- Enable debug prints
    }
    
    -- Log queue to batch send logs
    local logQueue = {
        chat = {},
        errors = {},
        activities = {}
    }
    
    -- HTTP request helper function
    local function SendRequest_players(endpoint, data)
        HTTP({
            url = config.API_URL .. endpoint.."?player_list="..data,
            method = "GET",
            success = function(code, body, headers)
                if config.DEBUG then
                    print("[Logger] Successfully sent data to " .. endpoint)
                end
            end,
            failed = function(err)
                print("[Logger Error] Failed to send data: " .. err)
            end
        })
    end
    local function SendRequest(endpoint, data)
        HTTP({
            url = config.API_URL .. endpoint,
            method = "GET",
            parameters = data,--1
            success = function(code, body, headers)
                if config.DEBUG then
                    print("[Logger] Successfully sent data to " .. endpoint)
                end
            end,
            failed = function(err)
                print("[Logger Error] Failed to send data: " .. err)
            end
        })
    end
    
    
    -- Player count update function
    -- Enhanced player count tracking
    local function UpdatePlayerCount()
        local players = player.GetAll()
        local playerCount = #players
        
        -- Get additional player data
        local playerData = {
            total_count = playerCount,
            player_list = {}
        }
        
        -- Track basic player info
        for _, ply in ipairs(players) do
            table.insert(playerData.player_list, {
                name = ply:Nick(),
                steam_id = ply:SteamID(),
                team = team.GetName(ply:Team()),
                ping = ply:Ping()
            })
        end
        
        -- Send to server
        SendRequest_players("/api/player_list/", playerCount)
        
        if config.DEBUG then
            print(string.format("[Logger] Player count updated: %d players", playerCount))
        end
        -- Start the continuous update loop
        local function StartContinuousUpdate()
            -- Clear any existing timer to prevent duplicates
            if timer.Exists("LoggerContinuousUpdate") then
                timer.Remove("LoggerContinuousUpdate")
            end
            
            -- Create a repeating timer instead of while true
            timer.Create("LoggerContinuousUpdate", config.SEND_INTERVAL, 0, function()
                UpdatePlayerCount()
                if config.DEBUG then
                    print("[Logger] Continuous update tick")
                end
            end)
        end
        StartContinuousUpdate()
        
        -- Remove the old timer if it exists
        if timer.Exists("LoggerPlayerCount") then
            timer.Remove("LoggerPlayerCount")
        end
        
        return playerCount
    end
    -- Initialize the logging system
    local function InitializeLogger()
        -- Set up chat logging
        hook.Add("PlayerSay", "LoggerChat", function(ply, text, teamChat)
            if not IsValid(ply) then return end
            
            SendRequest("/api/chat/", {
                name = ply:Nick(),
                steam_id = ply:SteamID(),
                text = text
            })
        end)
    
        -- Log player connections
        hook.Add("PlayerInitialSpawn", "LoggerConnect", function(ply)
            if not IsValid(ply) then return end
            
            SendRequest("/api/chat/", {
                name = ply:Nick(),
                steam_id = ply:SteamID(),
                did_something = "connected to the server"
            })
            
            -- Update player count
            UpdatePlayerCount()
        end)
    
        -- Log player disconnections
        hook.Add("PlayerDisconnected", "LoggerDisconnect", function(ply)
            if not IsValid(ply) then return end
            
            SendRequest("/api/chat/", {
                name = ply:Nick(),
                steam_id = ply:SteamID(),
                did_something = "disconnected from the server"
            })
            
            -- Update player count after a short delay
            timer.Simple(1, UpdatePlayerCount)
        end)
    
        -- Log player deaths
        hook.Add("PlayerDeath", "LoggerDeath", function(victim, inflictor, attacker)
            if not IsValid(victim) then return end
            
            local message
            if IsValid(attacker) and attacker:IsPlayer() and attacker != victim then
                message = string.format("was killed by %s", attacker:Nick())
            else
                message = "died"
            end
            
            SendRequest("/api/chat/", {
                name = victim:Nick(),
                steam_id = victim:SteamID(),
                did_something = message
            })
        end)
    
        -- Error logging
        hook.Add("OnLuaError", "LoggerError", function(err, realm, stack, addons)
            SendRequest("/api/chat/", {
                name = "Server",
                steam_id = "STEAM_0:0:0",
                error = err
            })
        end)
    
        -- Set up periodic player count updates
        timer.Create("LoggerPlayerCount", 1, 0, UpdatePlayerCount) -- Update every 5 minutes
    end
    
    -- Error catching wrapper
    local function SafeInit()
        local status, err = pcall(InitializeLogger)
        if not status then
            print("[Logger Error] Failed to initialize: " .. err)
        else
            print("[Logger] Successfully initialized")
        end
    end
    
    -- Start the logger
    SafeInit()
    
    -- Console commands for manual control
    concommand.Add("logger_reset", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        HTTP({
            url = config.API_URL .. "/api/chat/reset",
            method = "POST",
            success = function()
                print("[Logger] Successfully reset logs")
            end,
            failed = function(err)
                print("[Logger Error] Failed to reset logs: " .. err)
            end
        })
    end)
    
    -- Console commands for manual control
    concommand.Add("logger_reset", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        SendRequest("/api/chat/reset", {
            action = "reset",
            initiated_by = IsValid(ply) and ply:Nick() or "Console"
        })
    end)
    
    -- Debug command to force player count update
    concommand.Add("logger_updatecount", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        UpdatePlayerCount()
    end)
    
end
