--[[
____                                    ____                                 
/\  _`\                                 /\  _`\                               
\ \ \L\ \ __   _ __    ___ ___      __  \ \ \L\ \_ __   ___   _____     ____  
 \ \ ,__/'__`\/\`'__\/' __` __`\  /'__`\ \ \ ,__/\`'__\/ __`\/\ '__`\  /',__\ 
  \ \ \/\  __/\ \ \/ /\ \/\ \/\ \/\ \L\.\_\ \ \/\ \ \//\ \L\ \ \ \L\ \/\__, `\
   \ \_\ \____\\ \_\ \ \_\ \_\ \_\ \__/.\_\\ \_\ \ \_\\ \____/\ \ ,__/\/\____/
    \/_/\/____/ \/_/  \/_/\/_/\/_/\/__/\/_/ \/_/  \/_/ \/___/  \ \ \/  \/___/ 
                                                                \ \_\         
                                                                 \/_/         
    File: sv_sql.lua
    Author: Summe

    For internal purposes.
    The SQL stuff is handled here.
]]--

hook.Add("PermaPropsSystem.Loaded", "InitializePermaPropsMySQL", function()
    if PermaPropsSystem.Config.UseMySQL then
        PermaPropsSystem:Print(Color(255,175,55), "Use mysql as database type.")
        require("mysqloo")

        PermaPropsSystem:SQLConnect()
    else
        PermaPropsSystem:Print(Color(255,175,55), "Use local sv.db as database type.")
        hook.Run("PermaPropsSystem.SQLReady")
    end
end)


function PermaPropsSystem:SQLQuery(queryString, callback, shouldWait, useLocalDB)

    if PermaPropsSystem.Config.UseMySQL and not useLocalDB then
        local query = PermaPropsSystem.MySQL:query(queryString)
        query.onSuccess = function(_, data)
            if(callback) then
                callback(data)
            end
        end
        query.onError = function(q, err, sql)
            print(err)
        end
        query:start()

        if shouldWait then
            query:wait()
        end

    else
        local data = sql.Query(queryString)
        if(callback) then
            callback(data)
        end
    end
end

function PermaPropsSystem:SQLConnect()
    PermaPropsSystem.MySQL = mysqloo.connect(PermaPropsSystem.Config.MySQL["host"], PermaPropsSystem.Config.MySQL["username"], PermaPropsSystem.Config.MySQL["password"], PermaPropsSystem.Config.MySQL["db"], PermaPropsSystem.Config.MySQL["port"])

    function PermaPropsSystem.MySQL:onConnected()
        PermaPropsSystem:Print(Color(13,158,0), "MySQL database connection successfully established.")
        hook.Run("PermaPropsSystem.SQLReady")
    end

    function PermaPropsSystem.MySQL:onConnectionFailed(error)
        PermaPropsSystem:Print(Color(255,55,55), "Could not connect to MySQL database!")
        PermaPropsSystem:Print(Color(255,55,55), "[Error] ")
        PermaPropsSystem:Print(Color(255,55,55), error)
    end

    PermaPropsSystem.MySQL:connect()
end

function PermaPropsSystem:InitializeSQL()
    if PermaPropsSystem.Config.UseMySQL then
        PermaPropsSystem:SQLQuery( "CREATE TABLE IF NOT EXISTS permaprops_system ( id INTEGER PRIMARY KEY AUTO_INCREMENT, map TEXT, class TEXT, model TEXT, player TEXT, time INTEGER, data TEXT )" )
    else
        sql.Query("CREATE TABLE IF NOT EXISTS permaprops_system ( id INTEGER PRIMARY KEY, map TEXT, class TEXT, model TEXT, player TEXT, time INTEGER, data TEXT )")
    end

    -- id INTEGER: Primarykey
    -- map TEXT: Map
    -- class TEXT: Entity Class
    -- model TEXT: Entity Model
    -- player TEXT: SteamID64
    -- time INTEGER: Unix time code
    -- data TEXT: TableToJSON Data

    PermaPropsSystem:Print(Color(2,244,42), "Successfully Initialized the database.")
end