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
    File: sh_main.lua
    Author: Summe

    For internal purposes.
    Main file for shared stuff.
]]--

if SERVER then
    local ply = FindMetaTable("Player")

    function ply:PermaPropMessage(...)
        net.Start("PermaPropsSystem.ChatMessage")
            net.WriteTable({...})
        net.Send(self)
    end
else
    net.Receive("PermaPropsSystem.ChatMessage", function(len)
        chat.AddText(Color(214,11,255), "PermaProps", Color(90,90,90)," » ", Color(255,255,255), unpack(net.ReadTable()))
    end)
end

function PermaPropsSystem:PlayerHasPermission(ply, permission, preventMessage)
    if CAMI.PlayerHasAccess(ply, permission) then
        return true 
    else
        if preventMessage then return false end

        if SERVER then
            ply:PermaPropMessage(Color(255,0,0), "You do not have enough permissions: ".. permission)
        else
            chat.AddText(Color(214,11,255), "PermaProps", Color(90,90,90)," » ", Color(255,0,0), "You do not have enough permissions: ".. permission)
        end
        return false
    end
end

function PermaPropsSystem:Print(color, text)
    MsgC(Color(214,11,255), "[PermaProps] ", color, text)
    print("")
end

CAMI.RegisterPrivilege({
    Name = "PermaProps.CanOpenOverview",
    MinAccess = "admin",
    Description = "Can the player open the overview menu?",
})

CAMI.RegisterPrivilege({
    Name = "PermaProps.CanOpenSettings",
    MinAccess = "admin",
    Description = "Can the player open the settings menu?",
})

CAMI.RegisterPrivilege({
    Name = "PermaProps.CanPermaProp",
    MinAccess = "admin",
    Description = "Can the player make entites permanent (use the tool basically)?",
})

CAMI.RegisterPrivilege({
    Name = "PermaProps.CanManipulatePermaProps",
    MinAccess = "admin",
    Description = "Can the player uses the physgun on permaprops for example?",
})

function table_invert(t)
    local s={}
    for k,v in pairs(t) do
      s[v]=k
    end
    return s
 end

hook.Add("InitPostEntity", "PermaPropsToolStuff", function()
    hook.Remove("CanTool", "3D2DTextScreensPreventTools")
    local function textScreenCanTool(ply, trace, tool)
        if IsValid(trace.Entity) and trace.Entity:GetClass() == "sammyservers_textscreen" and tool ~= "textscreen" and tool ~= "remover" and tool ~= "permaprops" and tool ~= "sh_permaproptool" then
            return false
        end
    end
    hook.Add("CanTool", "3D2DTextScreensPreventTools", textScreenCanTool)
end)

hook.Add("CanProperty", "PreventPermaPropsManipulation", function(ply, property, ent)
    if ent.PermaPropID and not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanManipulatePermaProps") then
        return false 
    end
end)

hook.Add("PhysgunPickup", "PreventPermaPropsManipulation", function(ply, ent)
    if ent.PermaPropID and not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanManipulatePermaProps", true) then
        return false 
    end
end)

hook.Add("CanPlayerUnfreeze", "PreventPermaPropsManipulation", function(ply, ent)
    if ent.PermaPropID and not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanManipulatePermaProps", true) then
        return false 
    end
end)

hook.Add("CanTool", "PreventPermaPropsManipulation", function(ply, tr, tool)

    local ent = tr.Entity

    if not IsValid(ent) then return end

    if ent.PermaPropID and not PermaPropsSystem:PlayerHasPermission(ply, "PermaProps.CanManipulatePermaProps") then
        return false 
    end
end)

