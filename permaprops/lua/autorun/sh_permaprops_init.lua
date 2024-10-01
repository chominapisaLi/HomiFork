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
    File: sh_permaprops_init.lua
    Author: Summe

    For internal purposes.
    This is where the addon is initialized.
]]--

PermaPropsSystem = {}

PermaPropsSystem.Version = "1.07"

local dir = "permaprops/"

if SERVER then
    AddCSLuaFile(dir.."sh_config.lua")
    AddCSLuaFile(dir.."cl_main.lua")
    AddCSLuaFile(dir.."cl_fonts.lua")
    AddCSLuaFile(dir.."cl_highlight.lua")
    AddCSLuaFile(dir.."sh_main.lua")
    AddCSLuaFile(dir.."ui_elements/cl_pagebutton.lua")
    AddCSLuaFile(dir.."ui_elements/cl_checkbox.lua")
    AddCSLuaFile(dir.."ui_elements/cl_closebutton.lua")

    include(dir.."sh_config.lua")
    include(dir.."sh_main.lua")
    include(dir.."sv_config.lua")
    include(dir.."sv_sql.lua")
    include(dir.."sv_main.lua")
    include(dir.."sv_integrations.lua")

    hook.Run("PermaPropsSystem.Loaded")
else
    include(dir.."sh_config.lua")
    include(dir.."sh_main.lua")
    include(dir.."cl_main.lua")
    include(dir.."cl_fonts.lua")
    include(dir.."cl_highlight.lua")
    include(dir.."ui_elements/cl_pagebutton.lua")
    include(dir.."ui_elements/cl_checkbox.lua")
    include(dir.."ui_elements/cl_closebutton.lua")

    hook.Run("PermaPropsSystem.Loaded")
end

hook.Add("PermaPropsSystem.SQLReady", "PermaPropsStartupMessage", function()
    PermaPropsSystem:Print(Color(55,255,132), "Successfully loaded and initialized the PermaProp system.")    
end)
