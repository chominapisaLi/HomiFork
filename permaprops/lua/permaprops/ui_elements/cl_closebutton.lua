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
    File: cl_checkbox.lua
    Author: Summe

    For internal purposes.
]]--

local CloseButton = {}

function CloseButton:Init()
    self.Color = PermaPropsSystem.Config.Theme.navButton
    self.HoverColor = Color(self.Color.r + 16, self.Color.g + 16, self.Color.b + 16, 255)
    self.DisabledColor = Color(180, 180, 180)

    self:SetFont("PermaProps.Button")
    self:SetText("")
end

function CloseButton:Paint(w, h)
    local color = self.DisabledColor

    if not self:GetDisabled() then
        if self:IsHovered() then
            color = self.HoverColor
        else
            color = self.Color
        end
    end

    draw.RoundedBoxEx(5, 0, 0, w, h, color, true, true, true, true)

    draw.DrawText("X", "PermaProps.Title2", w / 2, h * .09, Color(255,23,23), TEXT_ALIGN_CENTER)
end

function CloseButton:DoClickInternal()
    surface.PlaySound("UI/buttonclick.wav")
end

vgui.Register("PermaProps.CloseButton", CloseButton, "DButton")