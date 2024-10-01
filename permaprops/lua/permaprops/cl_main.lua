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
    Main file for the clientside stuff.
]]--

PermaPropsSystem.Overview = {}
PermaPropsSystem.Settings = {}
local theme = PermaPropsSystem.Config.Theme

function PermaPropsSystem.Overview:OpenMenu(openID)

    if not PermaPropsSystem:PlayerHasPermission(LocalPlayer(), "PermaProps.CanOpenOverview") then return end

    if self.MainFrame then self.MainFrame:Remove() end
    

    local width = ScrW() * .6
    local height = ScrH() * .6
    local windowTitle = "PermaProps"

    local map = game.GetMap()
    local tblCount = 0
    local status = 1
    local total = 0

    local selectedIDs = {}

    local dropdownOptions = {
        {
            shouldShow = function()
                return true
            end,
            name = "Remove prop",
            icon = "icon16/cross.png",
            func = function(panel, id)
                net.Start("PermaPropsSystem.RemoveByID")
                net.WriteInt(id, 32)
                net.SendToServer()
                panel:Remove()
            end
        },
        {
            shouldShow = function()
                return true
            end,
            name = "Teleport",
            icon = "icon16/arrow_up.png",
            func = function(panel, id)
                net.Start("PermaPropsSystem.TeleportToProp")
                net.WriteInt(id, 32)
                net.SendToServer()
                PermaPropsSystem.Overview.MainFrame:Remove()
            end
        },
        {
            shouldShow = function()
                return true
            end,
            name = "Highlight",
            icon = "icon16/star.png",
            func = function(panel, id)
                net.Start("PermaPropsSystem.HighlightEntity")
                net.WriteInt(id, 32)
                net.SendToServer()
                PermaPropsSystem.Overview.MainFrame:Remove()
            end
        },
        {
            shouldShow = function()
                return #selectedIDs > 0
            end,
            devider = true,
        },
        {
            shouldShow = function()
                return #selectedIDs > 0
            end,
            name = "Remove selected entries",
            icon = "icon16/bomb.png",
            func = function(panel, id)
                if selectedIDs == {} then return end

                net.Start("PermaPropsSystem.MassRemoving")
                net.WriteTable(selectedIDs)
                net.SendToServer()
        
                timer.Simple(0.5, function()
                    PermaPropsSystem.Overview.MainFrame:Remove()
                    PermaPropsSystem.Overview:OpenMenu()
                end)
            end
        },
    }

    local dropdownEditOptions = {
        {
            shouldShow = function()
                return true
            end,
            name = "Class",
            icon = "icon16/plugin_edit.png",
            func = function(panel, id, name, preText)
                Derma_StringRequest(
                "PermaProps - Edit Property", 
                name,
                preText,
                function(text) -- confirm func

                    if #selectedIDs > 0 then
                        net.Start("PermaPropsSystem.UpdateProperties")
                        net.WriteString(name)
                        net.WriteString(text)
                        net.WriteTable(selectedIDs)
                        net.SendToServer()
                    else
                        net.Start("PermaPropsSystem.UpdateProperty")
                        net.WriteString(name)
                        net.WriteString(text)
                        net.WriteInt(id, 32)
                        net.SendToServer()
                    end

                    timer.Simple(0.3, function()
                        PermaPropsSystem.Overview.PermaPropList:Clear()
                        PermaPropsSystem.Overview:Reload(1)
                    end)
                end,
                function(text) end)
            end
        },
        {
            shouldShow = function()
                return true
            end,
            name = "Model",
            icon = "icon16/plugin_edit.png",
            func = function(panel, id, name, preText)
                Derma_StringRequest(
                "PermaProps - Edit Property", 
                name,
                preText,
                function(text) -- confirm func
                    if #selectedIDs > 0 then
                        net.Start("PermaPropsSystem.UpdateProperties")
                        net.WriteString(name)
                        net.WriteString(text)
                        net.WriteTable(selectedIDs)
                        net.SendToServer()
                    else
                        net.Start("PermaPropsSystem.UpdateProperty")
                        net.WriteString(name)
                        net.WriteString(text)
                        net.WriteInt(id, 32)
                        net.SendToServer()
                    end

                    timer.Simple(0.3, function()
                        PermaPropsSystem.Overview.PermaPropList:Clear()
                        PermaPropsSystem.Overview:Reload(1)
                    end)
                end,
                function(text) end)
            end
        },
    }

    self.MainFrame = vgui.Create("DFrame")
    self.MainFrame:SetTitle("")
    self.MainFrame:SetSize(width, height)
    self.MainFrame:MakePopup()
    self.MainFrame:Center()
    self.MainFrame:SetDraggable(false)
    self.MainFrame:ShowCloseButton(false)
    self.MainFrame.Paint = function(me,w,h)
        draw.RoundedBox(20, 0, 0, w, h, theme.bg)

        surface.SetDrawColor(theme.bg)
        surface.DrawRect(0, 0, w, h * .075)

        surface.SetDrawColor(Color(theme.bg.r + 8, theme.bg.g + 8, theme.bg.b + 8))
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, 0, w, h * .075)

        draw.DrawText(windowTitle, "PermaProps.Title", w * .01, h * .007, theme.primary, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(theme.primary)
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, h * .075, w, h * .005)

        draw.SimpleText("Map: ".. map.. " | Downloaded: ".. tblCount.. " | Total: ".. total.. "/".. PermaPropsSystem.Config.Limit, "PermaProps.DetailText", w * .01, h * .084, Color(255,255,255), TEXT_ALIGN_LEFT)

        if #selectedIDs <= 0 then return end

        draw.SimpleText(#selectedIDs..  " selected entries", "PermaProps.DetailText", w * .01, h * .97, Color(141,141,141), TEXT_ALIGN_LEFT)
    end

    self.SearchBar = vgui.Create("DPanel", self.MainFrame)
    self.SearchBar:SetSize(width * .3, height * .05)
    self.SearchBar:SetPos(width * .68, height * .09)
    self.SearchBar.Paint = function(s, w, h)
        if s:IsHovered() or self.SearchBar.textentry:IsHovered() then
            draw.RoundedBox(5, 0, 0, w, h, Color(theme.bg.r + 25, theme.bg.g + 25, theme.bg.b + 25))
        else
            draw.RoundedBox(5, 0, 0, w, h, Color(theme.bg.r + 16, theme.bg.g + 16, theme.bg.b + 16))
        end
    end

    self.SearchBar.textentry = vgui.Create("DTextEntry", self.SearchBar)
	self.SearchBar.textentry:Dock(FILL)
	self.SearchBar.textentry:DockMargin(8, 8, 8, 8)
	self.SearchBar.textentry:SetFont("PermaProps.TextEntry")
    self.SearchBar.textentry:SetDrawLanguageID(false)
	self.SearchBar.textentry.Paint = function(pnl, w, h)
		local col = theme.textEntryText
		
		pnl:DrawTextEntryText(col, col, col)

		if (#pnl:GetText() == 0) then
			draw.SimpleText("Search database", pnl:GetFont(), 3, pnl:IsMultiline() and 8 or h / 2, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
    self.SearchBar.textentry.OnEnter = function()
        PermaPropsSystem:StartSearch(self.SearchBar.textentry:GetText())
    end

    function PermaPropsSystem:StartSearch(id)
        net.Start("PermaPropsSystem.RequestSearch")
        net.WriteString(id or PermaPropsSystem.Overview.SearchBar:GetText())
        net.SendToServer()
    end

    self.PermaPropList = vgui.Create("DScrollPanel", self.MainFrame)
    self.PermaPropList:SetPos(width * .01, height * .15)
    self.PermaPropList:SetSize(width * .982, height * .82)
    function self.PermaPropList:Paint(w, h) end

            local sbar = self.PermaPropList:GetVBar()
            function sbar:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(0, 0, 0, 100))
            end
            function sbar.btnUp:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end
            function sbar.btnDown:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end
            function sbar.btnGrip:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w * .3, h, Color(85, 85, 85))
            end

            sbar.LerpTarget = 0

            function sbar:AddScroll(dlta)
                local OldScroll = self.LerpTarget or self:GetScroll()
                dlta = dlta * 75
                self.LerpTarget = math.Clamp(self.LerpTarget + dlta, -self.btnGrip:GetTall(), self.CanvasSize + self.btnGrip:GetTall())

                return OldScroll ~= self:GetScroll()
            end

            sbar.Think = function(s)
                local frac = FrameTime() * 5
                if (math.abs(s.LerpTarget - s:GetScroll()) <= (s.CanvasSize / 10)) then
                    frac = FrameTime() * 2
                end
                local newpos = Lerp(frac, s:GetScroll(), s.LerpTarget)
                s:SetScroll(math.Clamp(newpos, 0, s.CanvasSize))
                if (s.LerpTarget < 0 and s:GetScroll() <= 0) then
                    s.LerpTarget = 0
                elseif (s.LerpTarget > s.CanvasSize and s:GetScroll() >= s.CanvasSize) then
                    s.LerpTarget = s.CanvasSize
                end
            end

    function self:Reload(status)

        if not openID then
            net.Start("PermaPropsSystem.GetPropList")
            net.WriteInt(status, 16)
            net.SendToServer()
        else
            net.Start("PermaPropsSystem.RequestSearch")
            net.WriteString(tostring(openID))
            net.SendToServer()
        end

        net.Receive("PermaPropsSystem.SendPropList", function(bits)
            local len = net.ReadInt(32)
            local tbl = net.ReadData(len)
            total = net.ReadInt(16)

            tbl = util.Decompress(tbl)
            tbl = util.JSONToTable(tbl)
        
            tblCount = tblCount + #tbl

            if net.ReadBool() then 
                self.PermaPropList:Clear()
                tblCount = #tbl
            end

            if tblCount > total then tblCount = total end

            for k, prop in pairs(tbl) do
                local propPanel = vgui.Create("DButton", self.PermaPropList)
                propPanel:Dock(TOP)
                propPanel:SetText("")
                propPanel:DockMargin(0, 0, 0, ScrH() * .01)
                propPanel:SetSize(width * .982, ScrH() * .04)
                propPanel:SetAlpha(0)
                propPanel.state = "collapsed"
                
                local wStatic = width * .982
                local hStatic = ScrH() * .04

                steamworks.RequestPlayerInfo(prop.player, function(steamName)
                    propPanel.steamName = steamName
                end)

                if prop.player == "N/A" then propPanel.steamName = "Imported" end

                function propPanel:Paint(w, h)
                                        
                    local bgCol

                    if self:IsHovered() then
                        bgCol = Color(theme.bg.r + 12, theme.bg.g + 12, theme.bg.b + 12)
                    else
                        bgCol = Color(theme.bg.r + 5, theme.bg.g + 5, theme.bg.b + 5)
                    end

                    draw.RoundedBox(3, 0, 0, w, h, bgCol)

                    draw.SimpleText("#"..prop.id, "PermaProps.Text", wStatic * .16, h * .3, Color(138,138,138), TEXT_ALIGN_LEFT)
                    draw.SimpleText(prop.model, "PermaProps.Text", wStatic * .25, hStatic * .25, Color(138,138,138), TEXT_ALIGN_LEFT)
                    draw.SimpleText(prop.class, "PermaProps.Text", wStatic * .75, h * .25, Color(138,138,138), TEXT_ALIGN_LEFT)

                    draw.SimpleText(propPanel.steamName.. " | ".. os.date(PermaPropsSystem.Config.TimeString, prop.time), "PermaProps.DetailText", wStatic * .25, hStatic * .92, Color(68,68,68), TEXT_ALIGN_LEFT)
                end

                local Selector = vgui.Create("PermaProps.Checkbox", propPanel)
                Selector:SetSize(height * .035, height * .035)
                Selector:SetPos(width * .01, height * .017)
                function Selector:OnValueChange()
                    if self:GetValue() == true then
                        table.insert(selectedIDs, prop.id)
                    else
                        table.RemoveByValue(selectedIDs, prop.id)
                    end
                end
                if table.HasValue(selectedIDs, prop.id) then Selector:SetValue(true) end

                local SpawnI = vgui.Create("SpawnIcon" , propPanel)
                SpawnI:SetPos(wStatic * .05, 0)
                SpawnI:SetModel(prop.model)

                function propPanel:DoClick()
                    if self.state == "collapsed" then
                        self:SizeTo(wStatic, ScrH() * .065, 0.3)
                        self.state = "extended"
                    else
                        self:SizeTo(wStatic, hStatic, 0.3)
                        self.state = "collapsed"
                    end
                end

                function propPanel:DoRightClick()
                    local contextMenu = DermaMenu(line)
                    function contextMenu:Paint(width, height) end

                    for k, option in pairs(dropdownOptions) do

                        if option.devider then
                            if not option.shouldShow() then continue end
                            local devider = contextMenu:AddSpacer()

                            function devider:Paint(width, height)
                                draw.RoundedBox(6, 0, 0, width, height, theme.primary)
                            end

                            continue
                        end

                        if option.shouldShow() then
                            local optionPanel = contextMenu:AddOption(option.name, function()
                                option.func(self, prop.id)
                            end)

                            optionPanel:SetColor(color_white)
                            optionPanel:SetFont("PermaProps.Button2")

                            function optionPanel:Paint(width, height)
                                if self:IsHovered() then
                                    draw.RoundedBox(6, 0, 0, width, height, PermaPropsSystem.Config.Theme.primary)
                                else
                                    draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
                                end
                            end

                            local icon = vgui.Create("DImage", optionPanel)
                            icon:SetPos(optionPanel:GetWide() * 0.075, optionPanel:GetTall() * 0.15)
                            icon:SetSize(ScrH() / 67.5, ScrH() / 67.5)
                            icon:SetImage(option.icon)
                        end
                    end

                    local devider = contextMenu:AddSpacer()

                    function devider:Paint(width, height)
                        draw.RoundedBox(6, 0, 0, width, height, theme.primary)
                    end

                    local editMenu, _editMenu = contextMenu:AddSubMenu("Edit")

                    function _editMenu:Paint(width, height)
                        if self:IsHovered() then
                            draw.RoundedBox(6, 0, 0, width, height, PermaPropsSystem.Config.Theme.primary)
                        else
                            draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
                        end
                    end
                    local icon = vgui.Create("DImage", _editMenu)
                    icon:SetPos(_editMenu:GetWide() * 0.075, _editMenu:GetTall() * 0.15)
                    icon:SetSize(ScrH() / 67.5, ScrH() / 67.5)
                    icon:SetImage("icon16/wrench_orange.png")
                    _editMenu:SetColor(color_white)
                    _editMenu:SetFont("PermaProps.Button2")
                    for k, option in pairs(dropdownEditOptions) do
                        if option.shouldShow() then
                            local optionPanel = editMenu:AddOption(option.name, function()
                                local preText = ""
                                if option.name == "Class" then preText = prop.class end
                                if option.name == "Model" then preText = prop.model end

                                option.func(self, prop.id, option.name, preText)
                            end)

                            optionPanel:SetColor(color_white)
                            optionPanel:SetFont("PermaProps.Button2")

                            function optionPanel:Paint(width, height)
                                if self:IsHovered() then
                                    draw.RoundedBox(6, 0, 0, width, height, PermaPropsSystem.Config.Theme.primary)
                                else
                                    draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
                                end
                            end

                            local icon = vgui.Create("DImage", optionPanel)
                            icon:SetPos(optionPanel:GetWide() * 0.075, optionPanel:GetTall() * 0.15)
                            icon:SetSize(ScrH() / 67.5, ScrH() / 67.5)
                            icon:SetImage(option.icon)
                        end
                    end

                    contextMenu:Open()
                end

                propPanel:AlphaTo(255, 0.2)
            end
        end)
    end

    self:Reload(status)

    self.PageRight = vgui.Create("PermaProps.PageButton", self.MainFrame)
    self.PageRight:SetSize( height * .05, height * .05 )
    self.PageRight:SetPos( width * .927, height * .01 )
    self.PageRight:SetButtonText("<")
    self.PageRight.DoClick = function()

        if tblCount >= total then return end

        status = status + 1
        PermaPropsSystem.Overview:Reload(status)

        surface.PlaySound("UI/buttonclick.wav")
    end

    self.Close = vgui.Create("PermaProps.CloseButton", self.MainFrame)
    self.Close:SetSize( height * .05, height * .05 )
    self.Close:SetPos( width * .967, height * .01 )
    self.Close.DoClick = function() self.MainFrame:Remove() end
end

---------------------

function PermaPropsSystem.Settings:OpenMenu()

    if not PermaPropsSystem:PlayerHasPermission(LocalPlayer(), "PermaProps.CanOpenSettings") then return end

    if self.MainFrame then self.MainFrame:Remove() end
    
    local width = ScrW() * .4
    local height = ScrH() * .4
    local windowTitle = "PermaProps Settings"

    self.MainFrame = vgui.Create("DFrame")
    self.MainFrame:SetTitle("")
    self.MainFrame:SetSize(width, height)
    self.MainFrame:MakePopup()
    self.MainFrame:Center()
    self.MainFrame:SetDraggable(false)
    self.MainFrame:ShowCloseButton(false)
    self.MainFrame.Paint = function(me,w,h)
        draw.RoundedBox(20, 0, 0, w, h, theme.bg)

        surface.SetDrawColor(theme.bg)
        surface.DrawRect(0, 0, w, h * .094)

        surface.SetDrawColor(Color(theme.bg.r + 8, theme.bg.g + 8, theme.bg.b + 8))
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, 0, w, h * .094)

        draw.DrawText(windowTitle, "PermaProps.Title", w * .01, h * .0001, theme.primary, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(theme.primary)
        surface.SetMaterial(Material("gui/gradient"))
        surface.DrawTexturedRect(0, h * .094, w, h * .005)

        draw.DrawText("Tasks", "PermaProps.Title2", w * .03, h * .14, Color(150,150,150), TEXT_ALIGN_LEFT)

        draw.DrawText("Clear all PermaProps on Map ".. game.GetMap(), "PermaProps.Text", w * .08, h * .22, Color(150,150,150), TEXT_ALIGN_LEFT)
        draw.DrawText("Clear whole database", "PermaProps.Text", w * .08, h * .3, Color(150,150,150), TEXT_ALIGN_LEFT)
        draw.DrawText("Remove invalid PermaProps on Map ".. game.GetMap(), "PermaProps.Text", w * .08, h * .38, Color(150,150,150), TEXT_ALIGN_LEFT)
        draw.DrawText("Respawn all PermaProps", "PermaProps.Text", w * .08, h * .46, Color(150,150,150), TEXT_ALIGN_LEFT)

        draw.DrawText("PermaProps Version "..PermaPropsSystem.Version, "PermaProps.Text", w * .5, h * .9, Color(150,150,150), TEXT_ALIGN_CENTER)
    end

    self.Link = vgui.Create("DButton", self.MainFrame)
    self.Link:SetPos(width / 4, height * .95)
    self.Link:SetSize(width / 2, height * .04)
    self.Link:SetText("")
    self.Link.Paint = function(me,w,h)
        if me:IsHovered() then
            draw.DrawText("Created by Summe", "PermaProps.DetailText", w * .5, 0, Color(0,109,182), TEXT_ALIGN_CENTER)
        else
            draw.DrawText("Created by Summe", "PermaProps.DetailText", w * .5, 0, Color(73,182,255), TEXT_ALIGN_CENTER)
        end
    end
    self.Link.DoClick = function()
        gui.OpenURL("https://steamcommunity.com/id/DerSumme/")
    end

    self.TaskClearMapProps = vgui.Create("PermaProps.Checkbox", self.MainFrame)
    self.TaskClearMapProps:SetSize(height * .05, height * .05)
    self.TaskClearMapProps:SetPos(width * .04, height * .22)

    self.TaskClearDatabase = vgui.Create("PermaProps.Checkbox", self.MainFrame)
    self.TaskClearDatabase:SetSize(height * .05, height * .05)
    self.TaskClearDatabase:SetPos(width * .04, height * .3)

    self.TaskClearInvalid = vgui.Create("PermaProps.Checkbox", self.MainFrame)
    self.TaskClearInvalid:SetSize(height * .05, height * .05)
    self.TaskClearInvalid:SetPos(width * .04, height * .38)

    self.TaskRespawnPermaProps = vgui.Create("PermaProps.Checkbox", self.MainFrame)
    self.TaskRespawnPermaProps:SetSize(height * .05, height * .05)
    self.TaskRespawnPermaProps:SetPos(width * .04, height * .46)

    self.Execute = vgui.Create("DButton", self.MainFrame)
    self.Execute:SetText("Execute")
    self.Execute:SetTextColor(Color(255, 255, 255))
    self.Execute:SetFont("PermaProps.Text")
    self.Execute:SetPos(width * .03, height * .57 )
    self.Execute:SetSize(width * .2, height * .06 )
    local barStatus = 0
    local hoverAnimSpeed = 6
    self.Execute.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(105, 105, 105))

        if self:IsHovered() then 
            barStatus = math.Clamp(barStatus + hoverAnimSpeed * FrameTime(), 0, 1)
        else
            barStatus = math.Clamp(barStatus - hoverAnimSpeed * FrameTime(), 0, 1)
        end

        draw.RoundedBox(3, 0, 0, w * barStatus, h * 1, Color(0, 201, 50))
    end
    
    function self.Execute.DoClick()
        net.Start("PermaPropsSystem.ExecuteTasks")
        net.WriteBool(PermaPropsSystem.Settings.TaskClearMapProps:GetValue())
        net.WriteBool(PermaPropsSystem.Settings.TaskClearDatabase:GetValue())
        net.WriteBool(PermaPropsSystem.Settings.TaskClearInvalid:GetValue())
        net.WriteBool(PermaPropsSystem.Settings.TaskRespawnPermaProps:GetValue())
        net.SendToServer()

        self.MainFrame:Remove()
    end

    self.Close = vgui.Create("PermaProps.CloseButton", self.MainFrame)
    self.Close:SetSize( height * .07, height * .07 )
    self.Close:SetPos( width * .953, height * .01 )
    self.Close.DoClick = function() self.MainFrame:Remove() end
end

concommand.Add("permaprops_open_overview", function()
    PermaPropsSystem.Overview:OpenMenu()
end)

concommand.Add("permaprops_open_admin", function()
    PermaPropsSystem.Settings:OpenMenu()
end)
