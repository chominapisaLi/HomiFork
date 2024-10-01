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
    File: sv_main.lua
    Author: Summe

    For internal purposes.
    Main file for the serverside stuff.
]]--

util.AddNetworkString("PermaPropsSystem.Tool.PermaProp")
util.AddNetworkString("PermaPropsSystem.Tool.DePermaProp")
util.AddNetworkString("PermaPropsSystem.ChatMessage")
util.AddNetworkString("PermaPropsSystem.SendPropList")
util.AddNetworkString("PermaPropsSystem.GetPropList")
util.AddNetworkString("PermaPropsSystem.RemoveByID")
util.AddNetworkString("PermaPropsSystem.TeleportToProp")
util.AddNetworkString("PermaPropsSystem.RequestSearch")
util.AddNetworkString("PermaPropsSystem.ExecuteTasks")
util.AddNetworkString("PermaPropsSystem.MassRemoving")
util.AddNetworkString("PermaPropsSystem.HighlightEntity")
util.AddNetworkString("PermaPropsSystem.UpdateProperty")
util.AddNetworkString("PermaPropsSystem.UpdateProperties")
util.AddNetworkString("PermaPropsSystem.RequestID")

local imported = false

PermaPropsSystem.CurrentPropsCount = PermaPropsSystem.CurrentPropsCount or 0

function PermaPropsSystem:ClearFullDatabase()
    PermaPropsSystem:SQLQuery( "DROP TABLE IF EXISTS permaprops_system" )
    PermaPropsSystem:Print(Color(244,200,2), "Successfully cleared the whole database.")
    PermaPropsSystem:InitializeSQL()
    return true
end

function PermaPropsSystem:Push(class, model, data, map, ply)

    local data = util.TableToJSON(data)
    local steamID
    if ply then steamID = ply:SteamID64() else steamID = "N/A" end

    PermaPropsSystem:SQLQuery( "INSERT INTO permaprops_system ( map, class, model, player, time, data ) VALUES( " .. sql.SQLStr(map) .. ", " .. sql.SQLStr(class) .. ", " .. sql.SQLStr(model) .. ", ".. sql.SQLStr(steamID) .. ", ".. sql.SQLStr(os.time()).. ", ".. sql.SQLStr(data) .. " )" )
end

function PermaPropsSystem:AddProp(ply, ent, stopFancyStuff)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanPermaProp", false) then return end

    if PermaPropsSystem:Count() >= PermaPropsSystem.Config.Limit then 
        if not stopFancyStuff then
            ply:PermaPropMessage("You have reached the limit on this map.")
        end
        return
    end

    if not stopFancyStuff then
        if PermaPropsSystem:IsAlreadyAPermaProp(ent) then ply:PermaPropMessage("This prop is already a PermaProp.") return end
        if not PermaPropsSystem:IsValidProp(ent) then ply:PermaPropMessage("This cannot be permapropped.") return end
    end

    local model = ent:GetModel()
    local class = ent:GetClass()
    local data = {}
    data.pos = ent:GetPos()
    data.ang = ent:GetAngles()
    data.color = ent:GetColor()
    data.collision = ent:GetCollisionGroup()
    data.material = ent:GetMaterial()
    data.skin = ent:GetSkin()
    data.keyvalues = PermaPropsSystem:GetOptimizedKeyvalues(ent)
    data.renderFX = ent:GetRenderFX()
    data.renderMode = ent:GetRenderMode()
    data.modelScale = ent:GetModelScale()

    if (ent.GetNetworkVars) then data.dt = ent:GetNetworkVars() end -- Saves network variables if any are present

    hook.Run("PermaProps.OnAdd", ent, data, ply)

    PermaPropsSystem:Push(class, model, data, game.GetMap(), ply)

    ent:Remove()
    PermaPropsSystem:SpawnLastProp()

    if not stopFancyStuff then
        local effectdata = EffectData()
        effectdata:SetOrigin(ent:GetPos())
        effectdata:SetMagnitude(2.5)
        effectdata:SetScale(2)
        effectdata:SetRadius(3)
        util.Effect("ElectricSpark", effectdata, true, true)

        ply:PermaPropMessage("PermaProp successfully added.")
    end
end

function PermaPropsSystem:SpawnProp(propData)
    local ent = ents.Create(propData.class)

    if not IsValid(ent) then
        PermaPropsSystem:Print(Color(255,175,55), "ERROR, attempted to create an invalid entity type ("..propData.class..")")
	    return
	end

    ent:SetPos(propData.data.pos or Vector(0,0,0))
    ent:SetAngles(propData.data.ang or Angle(0,0,0))
    ent:SetModel(propData.model or "models/props_borealis/bluebarrel001.mdl")
    ent:SetColor(propData.data.color or Color(255,255,255))

    hook.Run("PermaProps.PreSpawn", ent, propData.data)

    ent:Spawn()

    ent:SetCollisionGroup(propData.data.collision or 0)
    ent:SetMaterial(propData.data.material or "")
    ent:SetSkin(propData.data.skin or 0)
    ent:SetRenderFX(propData.data.renderFX or 0)
    ent:SetRenderMode(propData.data.renderMode or 0)
    ent:SetModelScale(propData.data.modelScale or 1)

    if propData.data.keyvalues then
        for k, v in pairs(propData.data.keyvalues) do
            ent:SetKeyValue(k, v)
        end
    end

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    if propData.data.dt then -- Restores datatable

		for k, v in pairs( propData.data.dt ) do

			if ( propData.data.dt[ k ] == nil ) then continue end
			if !isfunction(ent[ "Set" .. k ]) then continue end
			ent[ "Set" .. k ]( ent, propData.data.dt[ k ] )

		end

	end

    ent.PermaPropID = propData.id

    PermaPropsSystem.CurrentPropsCount = PermaPropsSystem.CurrentPropsCount + 1

    hook.Run("PermaProps.PostSpawn", ent, propData.data)
end

function PermaPropsSystem:RemoveProp(ply, ent)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanPermaProp", false) then return end

    if not ent.PermaPropID then ply:PermaPropMessage("This prop is not a PermaProp.") return end

    PermaPropsSystem:SQLQuery("DELETE FROM permaprops_system WHERE id = ".. ent.PermaPropID.. ";")

    ply:PermaPropMessage("PermaProp successfully removed.")

    PermaPropsSystem.CurrentPropsCount = PermaPropsSystem.CurrentPropsCount - 1

    ent.PermaPropID = false
end

function PermaPropsSystem:RemovePropByID(id, removeOnMap, ply)
    local ent = PermaPropsSystem:GetEntByID(id)
    if ent then ent.PermaPropID = false end
    if removeOnMap and ent then ent:Remove() end

    PermaPropsSystem:SQLQuery("DELETE FROM permaprops_system WHERE id = ".. id.. ";")

    if ply then ply:PermaPropMessage("PermaProp successfully removed.") end

    PermaPropsSystem.CurrentPropsCount = PermaPropsSystem.CurrentPropsCount - 1
end

function PermaPropsSystem:IsAlreadyAPermaProp(ent)
    if ent.PermaPropID then return true end

    return false
end

function PermaPropsSystem:IsValidProp(ent)
    if table.HasValue(PermaPropsSystem.Config.ForbiddenEntities, ent:GetModel()) then return false end
    if table.HasValue(PermaPropsSystem.Config.ForbiddenEntities, ent:GetClass()) then return false end

    return true
end

function PermaPropsSystem:SpawnLastProp()
    PermaPropsSystem:SQLQuery("SELECT * FROM permaprops_system ORDER BY id desc LIMIT 1;", function(data)
        if not data then return end
        data[1].data = util.JSONToTable(data[1].data)
        PermaPropsSystem:SpawnProp(data[1])
    end)
end

function PermaPropsSystem:SpawnAllProps()
    PermaPropsSystem:SQLQuery( "SELECT * FROM permaprops_system WHERE map = " .. sql.SQLStr(game.GetMap()) .. ";", function(data)
        if not data then return end
        PermaPropsSystem.CurrentPropsCount = 0
        for k, v in pairs(data) do
            v.data = util.JSONToTable(v.data)
            PermaPropsSystem:SpawnProp(v)
        end
    end)
end

function PermaPropsSystem:SendProplistToClient(ply, status, replace)
    PermaPropsSystem:SQLQuery( "SELECT * FROM permaprops_system WHERE map = " .. sql.SQLStr(game.GetMap()) .. ";", function(data)
        if not data then return end
        status = status or 1

        for k, v in pairs(data) do
            v.data = nil
        end

        local reducedData = {}

        local pageIndex = status * PermaPropsSystem.Config.PerDownload - (PermaPropsSystem.Config.PerDownload)
        for i = pageIndex, pageIndex + PermaPropsSystem.Config.PerDownload do
            table.insert(reducedData, data[i])
        end

        reducedData = util.TableToJSON(reducedData)

        reducedData = util.Compress(reducedData)
        net.Start("PermaPropsSystem.SendPropList")
        net.WriteInt(#reducedData, 32)
        net.WriteData(reducedData, #reducedData)
        net.WriteInt(PermaPropsSystem:Count(), 16)
        net.WriteBool(replace)
        net.Send(ply)
    end)
end

function PermaPropsSystem:GetEntByID(id)
    for k, v in pairs(ents.GetAll()) do
        if tonumber(v.PermaPropID) == tonumber(id) then
            return v
        end
    end

    return false
end

function PermaPropsSystem:TeleportToProp(id, ply)
    local pos = PermaPropsSystem:GetEntByID(id):GetPos()
    ply:SetPos(pos + Vector(0, 0, 100))

    ply:PermaPropMessage("Successfully teleported to the entity.")
end

function PermaPropsSystem:Search(text)
    local returnData
    PermaPropsSystem:SQLQuery( "SELECT * FROM permaprops_system WHERE map = " .. sql.SQLStr(game.GetMap()) .. " AND model LIKE ".. sql.SQLStr("%"..text.."%").." OR class LIKE ".. sql.SQLStr("%"..text.."%").. "OR id LIKE ".. sql.SQLStr("%"..text.."%").." LIMIT 30;", function(data)
        if(data == nil) then
            returnData = nil
            return
        end
        returnData = data
    end, true)
    
    if returnData == nil then return end

    return returnData
end

function PermaPropsSystem:RemoveAllPropsOnMap()
    PermaPropsSystem:SQLQuery( "DELETE FROM permaprops_system WHERE map = " .. sql.SQLStr(game.GetMap()) .. ";")
    for k, v in pairs(ents.GetAll()) do
        if v.PermaPropID then v.PermaPropID = false end
        PermaPropsSystem.CurrentPropsCount = 0
    end
end

function PermaPropsSystem:RemoveEverything()
    PermaPropsSystem:ClearFullDatabase()
    for k, v in pairs(ents.GetAll()) do
        if v.PermaPropID then v.PermaPropID = false end
        PermaPropsSystem.CurrentPropsCount = 0
    end
end

function PermaPropsSystem:RemoveInvalids()
    PermaPropsSystem:SQLQuery("SELECT * FROM permaprops_system WHERE map = " .. sql.SQLStr(game.GetMap()) .. ";", function(data)
        if not data then return end
        for k, v in pairs(data) do
            if not util.IsValidModel(v.model) then
                PermaPropsSystem:RemovePropByID(v.id, true)
            end
        end
    end)
end

function PermaPropsSystem:Count()
    --[[local returnData = nil
    PermaProps:SQLQuery( "SELECT COUNT(id) AS NumberOfProps FROM permaprops_system WHERE map = " .. sql.SQLStr(game.GetMap()) .. ";", function(data)
        if(data[1] == nil) then
            returnData = nil
            return
        end
        returnData = tonumber(data[1]["NumberOfProps"])
    end )

    if returnData == nil then return 0 end

    return returnData]]--

    return PermaPropsSystem.CurrentPropsCount
end

function PermaPropsSystem:Import()
    if imported then
        PermaPropsSystem:Print(Color(221,59,59), "You have already imported all PermaProps.")
        return
    end

    local startTime = SysTime()
    PermaPropsSystem:SQLQuery( "SELECT * FROM permaprops", function(oldData)
        if not oldData then print("No data found!") return end

        PermaPropsSystem:Print(Color(244,220,2), "Starting the importer...")

        for k, v in pairs(oldData) do

            if not v.content or v.content == nil then continue end

            v.content = util.JSONToTable(v.content)

            if not v.content or v.content == nil then continue end

            local newData = {}
            local class = {}

            if v.content.Class == "prop_dynamic" then class = "prop_physics" else class = v.content.Class end

            newData.pos = v.content.Pos
            newData.ang = v.content.Angle
            newData.color = v.content.Color
            newData.collision = 30
            newData.material = v.content.Material

            PermaPropsSystem:Push(class, v.content.Model, newData, v.map)
        end

        imported = true

        local endTime = SysTime()

        PermaPropsSystem:Print(Color(2,244,42), "Successfully imported ".. #oldData.. " entities to the new database in ".. endTime - startTime.. " seconds.")
        PermaPropsSystem:Print(Color(244,220,2), "After a mapchange, the PermaProps are now spawned with the new system. You should also remove the old addon, otherwise it will be spawned twice.")
    end, false, true)
end

function PermaPropsSystem:RespawnPermaProps()
    for k, v in pairs(ents.GetAll()) do
        if v.PermaPropID then SafeRemoveEntity(v) end
    end
    PermaPropsSystem.CurrentPropsCount = 0
    timer.Simple(0.1, function()
        PermaPropsSystem:SpawnAllProps()
    end)
end


function PermaPropsSystem:GetOptimizedKeyvalues(ent)
    local keyvalues = ent:GetKeyValues()

    for k, v in pairs(keyvalues) do
        if table.HasValue(PermaPropsSystem.Config.IgnoreKeyvalues, k) then keyvalues[k] = nil end
    end

    return keyvalues
end

function PermaPropsSystem:ChangeSQL(id, row, value)
    PermaPropsSystem:SQLQuery( "UPDATE permaprops_system SET ".. row.. " = ".. sql.SQLStr(value)..  " WHERE id = " .. id .. ";" )
end

function PermaPropsSystem:RespawnPropByID(id)
    local ent = PermaPropsSystem:GetEntByID(tonumber(id))
    if not ent then return end

    ent:Remove()

    timer.Simple(0.1, function()
        PermaPropsSystem:SQLQuery("SELECT * FROM permaprops_system WHERE id = "..id.. " LIMIT 1;", function(propData)
            if not propData then return end
            propData[1].data = util.JSONToTable(propData[1].data)
            PermaPropsSystem:SpawnProp(propData[1])
        end)
    end)
end


concommand.Add("ImportPermaProps", function(ply, cmd, args)
    if ply:IsValid() then ply:PrintMessage(HUD_PRINTCONSOLE, "[PermaProps] Please execute this command in the server console!") return end
    PermaPropsSystem:Import()
end)

hook.Add("InitPostEntity", "PermaProps.SpawnAllProps", function()
    PermaPropsSystem:SpawnAllProps()
end)

hook.Add("PostCleanupMap", "Permaprops.Cleanup", function()
    if PermaPropsSystem.Config.SpawnOnCleanup then PermaPropsSystem:SpawnAllProps() end
end)

hook.Add("Initialize", "PermaProps.SetUpDatabase", function()
    PermaPropsSystem:InitializeSQL()
end)

hook.Add("PermaPropsSystem.SQLReady", "PermaProps.CheckOverlapping", function()
    timer.Simple(10, function()
        if PermaProps and PermaProps.Permissions then
            PermaPropsSystem:Print(Color(199,0,0), "You have the old PermaProps addon installed. Uninstall it or you will have compatibility problems.")
            timer.Create("PermaProps.Warning", 60, 0, function()
                PermaPropsSystem:Print(Color(199,0,0), "You have the old PermaProps addon installed. Uninstall it or you will have compatibility problems.")
            end)
            hook.Add("PlayerSpawn", "PermaProps.OverlappingUsermessage", function(ply)
                if ply:IsAdmin() then
                    timer.Simple(4, function()
                        ply:PermaPropMessage(Color(255,0,0), "You have the old PermaProps addon installed. Uninstall it or you will have compatibility problems.")
                    end)
                end
            end)
        end
    end)
end)

net.Receive("PermaPropsSystem.GetPropList", function(len, ply)
    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanOpenOverview", true) then return end
    PermaPropsSystem:SendProplistToClient(ply, net.ReadInt(16), false)
end)

net.Receive("PermaPropsSystem.RemoveByID", function(len, ply)
    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanPermaProp", true) then return end
    PermaPropsSystem:RemovePropByID(net.ReadInt(32), false, ply)
end)

net.Receive("PermaPropsSystem.TeleportToProp", function(len, ply)
    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanOpenOverview", true) then return end
    PermaPropsSystem:TeleportToProp(net.ReadInt(32), ply)
end)

net.Receive("PermaPropsSystem.RequestSearch", function(len, ply)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanOpenOverview", true) then return end

    local text = net.ReadString()

    if text == "" then PermaPropsSystem:SendProplistToClient(ply, 1, true) return end

    local data = PermaPropsSystem:Search(text)
    if not data then return end

    for k, v in pairs(data) do
        v.data = nil
    end

    local compressedData = util.TableToJSON(data)
    compressedData = util.Compress(compressedData)

    net.Start("PermaPropsSystem.SendPropList")
    net.WriteInt(#compressedData, 32)
    net.WriteData(compressedData, #compressedData)
    net.WriteInt(PermaPropsSystem:Count(), 16)
    net.WriteBool(true)
    net.Send(ply)
end)

net.Receive("PermaPropsSystem.ExecuteTasks", function(len, ply)
    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanOpenSettings", true) then return end

    local clearMapProps = net.ReadBool()
    local clearDatabase = net.ReadBool()
    local clearInvalidModels = net.ReadBool()
    local respawnPermaProps = net.ReadBool()

    if clearMapProps then PermaPropsSystem:RemoveAllPropsOnMap() ply:PermaPropMessage("Performed task: ", Color(255,238,0), "ClearMapProps") end
    if clearDatabase then PermaPropsSystem:RemoveEverything() ply:PermaPropMessage("Performed task: ", Color(255,238,0), "ClearDatabase") end
    if clearInvalidModels then PermaPropsSystem:RemoveInvalids() ply:PermaPropMessage("Performed task: ", Color(255,238,0), "ClearInvalidModels") end
    if respawnPermaProps then PermaPropsSystem:RespawnPermaProps() ply:PermaPropMessage("Performed task: ", Color(255,238,0), "RespawnPermaProps") end
end)

net.Receive("PermaPropsSystem.MassRemoving", function(len, ply)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanPermaProp", false) then return end

    local ids = net.ReadTable()

    for k, v in pairs(ids) do
        PermaPropsSystem:RemovePropByID(v, false)
    end

    ply:PermaPropMessage("Successfully removed PermaProps with the IDs: ", Color(255,238,0), table.concat(ids, ", "))
end)

net.Receive("PermaPropsSystem.HighlightEntity", function(len, ply)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanOpenOverview", false) then return end

    local id = net.ReadInt(32)
    local ent = PermaPropsSystem:GetEntByID(id)
    local pos = ent:GetPos()
    local model = ent:GetModel()
    local ang = ent:GetAngles()

    net.Start("PermaPropsSystem.HighlightEntity")
    net.WriteVector(pos)
    net.WriteString(model)
    net.WriteAngle(ang)
    net.Send(ply)
end)

local rowTranslation = {
    ["Class"] = "class",
    ["Model"] = "model",
}

net.Receive("PermaPropsSystem.UpdateProperty", function(len, ply)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanPermaProp", false) then return end

    local row = rowTranslation[net.ReadString()]
    local value = net.ReadString()
    local id = net.ReadInt(32)

    PermaPropsSystem:ChangeSQL(id, row, value)
    PermaPropsSystem:RespawnPropByID(id)

    ply:PermaPropMessage(string.format("You have successfully changed the value of row %s to %s on entry %s.", row, value, id))
end)

net.Receive("PermaPropsSystem.UpdateProperties", function(len, ply)

    if not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanPermaProp", false) then return end

    local row = rowTranslation[net.ReadString()]
    local value = net.ReadString()
    local ids = net.ReadTable()

    for k, v in pairs(ids) do
        PermaPropsSystem:ChangeSQL(v, row, value)
        PermaPropsSystem:RespawnPropByID(v)
    end

    ply:PermaPropMessage(string.format("You have successfully changed the values of row %s to %s on entries %s.", row, value, table.concat(ids,", ")))
end)

net.Receive("PermaPropsSystem.RequestID", function(len, ply)
    local ent = net.ReadEntity()
    local id = ent.PermaPropID

    if not id then id = -1 end

    net.Start("PermaPropsSystem.RequestID")
    net.WriteInt(id, 32)
    net.Send(ply)
end)

function PermaPropsSystem:SpamDB()
    for I = 1, 100 do
        PermaPropsSystem:SQLQuery("INSERT INTO permaprops_system ( map, class, model, player, time, data ) VALUES( 'gm_construct', 'prop_physics', 'models/props_c17/gravestone003a.mdl', '76561198305607704', '1615669793', '{\"pos\":\"[-564.8403 -1645.9808 -121.5472]\",\"skin\":0.0,\"color\":{\"r\":255.0,\"b\":255.0,\"a\":255.0,\"g\":255.0},\"ang\":\"{0.0025 72.0139 -0.01}\",\"keyvalues\":[],\"material\":\"\",\"collision\":0.0}\' );")
    end
end