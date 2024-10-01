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
    File: cl_highlight.lua
    Author: Summe

    For internal purposes.
    Here the highlighting of PermaProps is controlled.
]]--

net.Receive("PermaPropsSystem.HighlightEntity", function(len)
    local pos = net.ReadVector()
    local model = net.ReadString()
    local ang = net.ReadAngle()

    PermaPropsSystem:HighlightEntity(pos, ang, model)
end)

local mat = Material("models/wireframe")

function PermaPropsSystem:HighlightEntity(pos, angle, model)
    hook.Remove("HUDPaint", "PermaProps.RenderHightlight"..tostring(pos))

    hook.Add("HUDPaint", "PermaProps.RenderHightlight"..tostring(pos), function()
        cam.Start3D()
            if pos and isvector(pos) then
                render.ModelMaterialOverride(mat)
                render.SetColorModulation(0.902,0.416,1)
                render.Model({
                    model = model,
                    pos = pos,
                    angle = angle,
                })
            end
        cam.End3D()
    end)

    timer.Simple(PermaPropsSystem.Config.HighlightTime, function()
        hook.Remove("HUDPaint", "PermaProps.RenderHightlight"..tostring(pos))
    end)
end