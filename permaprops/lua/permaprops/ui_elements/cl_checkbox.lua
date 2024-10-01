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

local Checkbox = {}
local theme = PermaPropsSystem.Config.Theme

function Checkbox:Init()
	self.status = false

    self.firstColor = Color(theme.bg.r + 16, theme.bg.g + 16, theme.bg.b + 16)
    self.secondColor = Color(93,255,72)

    self.xLerp = 0
    self.yLerp = 0
    self.wLerp = 0
    self.hLerp = 0

    self:SetText("")
end

function Checkbox:Paint(w, h)

    draw.RoundedBox(6, 0, 0, w, h, self.firstColor)

    if(self.status) then
        self.xLerp = Lerp(0.1, self.xLerp, w * 0.1)
        self.yLerp = Lerp(0.1, self.yLerp, h * 0.1)
        self.wLerp = Lerp(0.1, self.wLerp, w * 0.8)
        self.hLerp = Lerp(0.1, self.hLerp, h * 0.8)
    else
        self.xLerp = Lerp(0.1, self.xLerp, w / 2)
        self.yLerp = Lerp(0.1, self.yLerp, h / 2)
        self.wLerp = Lerp(0.1, self.wLerp, 0)
        self.hLerp = Lerp(0.1, self.hLerp, 0)
    end

    draw.RoundedBox(14, self.xLerp, self.yLerp, self.wLerp, self.hLerp, self.secondColor)
end

function Checkbox:PerformLayout()
	self:SetSize(self:GetWide(), self:GetTall())
end

function Checkbox:OnValueChange(status)
end

function Checkbox:DoClick()
    self.status = !self.status
    self:OnValueChange(self:GetValue())
end

function Checkbox:SetValue(status)
    self.status = status
end
function Checkbox:GetValue()
    return self.status
end

vgui.Register("PermaProps.Checkbox", Checkbox, "DButton")