local panel = {}
panel.Name = "warning"

--init
function panel:Init()
    self:BaseInit({
        PaddingPower = 4
    })

    self.Label = vgui.Create("DLabel", self)
    self.Label:Dock(FILL)
    self.Label:SetFont("BiggerText")
    self.Label:SetTextColor(self.Settings.Colours.Value.TextColor)
    self:SetDockMargin(self.Label, 4)
    self.AcceptButton = vgui.Create("DButton", self)
    self.AcceptButton:Dock(BOTTOM)
    self.AcceptButton:SetTall(30)
    self.AcceptButton:DockMargin(self:GetPadding(), self:GetPadding(), self:GetPadding(), self:GetPadding())
    self.AcceptButton:SetText("YES")
    self.AcceptButton:SetPaintBackground(false)

    self.AcceptButton.Paint = function()
        draw.RoundedBox(5, 0, 0, self.AcceptButton:GetWide(), self.AcceptButton:GetTall(), LydsPlayer.ComputedColours.FadedGreen)
    end

    self.AcceptButton.DoClick = function()
        self.Callback(true)
        self:Remove()
    end

    self.DenyButton = vgui.Create("DButton", self)
    self.DenyButton:Dock(BOTTOM)
    self.DenyButton:SetTall(30)
    self.DenyButton:DockMargin(self:GetPadding(), 0, self:GetPadding(), 0)
    self.DenyButton:SetTextColor(LydsPlayer.Colours.White)
    self.DenyButton:SetText("NO")
    self.DenyButton:SetPaintBackground(false)

    self.DenyButton.Paint = function()
        draw.RoundedBox(5, 0, 0, self.DenyButton:GetWide(), self.DenyButton:GetTall(), LydsPlayer.ComputedColours.FadedRed)
    end

    self.DenyButton.DoClick = function()
        self.Callback(false)
        self:Remove()
    end
end

function panel:Paint(p)
    surface.SetDrawColor(self.Settings.Colours.Value.Background)
    surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    surface.SetDrawColor(self.Settings.Colours.Value.Border)
    surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
end

function panel:SetCallback(func)
    self.Callback = func
end

function panel:SetBox(title, message)
    title = title or "Success"

    if (message ~= self.LastMessage) then
        self:SetTitle(title)
        self.Label:SetText(message)
        self.Label:SetWrap(true)
        self:SetDockPadding(self.Label, 4)
        self.LastMessage = message
    end
end

vgui.Register("LydsPlayer.OptionBox", panel, "LydsPlayer.Base")