local panel = {}

panel.Name = "warning"

panel.Settings = {
	Options = "options"
}

function panel:Init()
	self:BaseInit()

	--add warning box here
	self.Label = vgui.Create("DLabel", self )
	self.Label:Dock(FILL)
	self.Label:SetFont("BiggerText")
	self.Label:SetTextColor( self.Settings.Colours.Value.TextColor )

	self.Paint = function(s, w, h)
		surface.SetDrawColor(self.Settings.Colours.Value.Background)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(self.Settings.Colours.Value.Border)
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
	end

	self.AcceptButton = vgui.Create("DButton", self )
	self.AcceptButton:Dock(BOTTOM)
	self.AcceptButton:SetTall(50)
	self.AcceptButton:DockMargin(15,15,15,15)
	self.AcceptButton:SetText("OK!")
	self.AcceptButton.DoClick = function()
		self:OnClicked()
	end

	self.KeepButton = vgui.Create("DButton", self )
	self.KeepButton:Dock(BOTTOM)
	self.KeepButton:DockMargin(15,15,15,0)
	self.KeepButton:SetText("Keep Open")
	self.KeepButton:Hide()
	self.KeepButton.DoClick = function()
		self.KeepButton:Hide()
		self.AcceptButton:SetText("OK!")
		timer.Remove("warning_panel_timer")
	end
end

function panel:OnClicked()
	--override me senpai
	timer.Remove("warning_panel_timer")
	self:Remove()
end

function panel:SetWarning(title, message, start_timeout)
	title = title or "Warning"
	start_timeout = start_timeout or true

	if (message != self.LastMessage) then
		self:SetTitle(title)
		self:DockPadding(15,15,15,15)
		self.Label:SetText(message)
		self.Label:SetWrap(true)

		self.LastMessage = message

		if (start_timeout) then
			self:SetTimeout()
		end
	end
end

function panel:SetTimeout(seconds)
	seconds = seconds or 10

	self.AcceptButton:SetText("OK! (will autoclose in " .. seconds .. " seconds)")
	self.KeepButton:Show()

	timer.Remove("warning_panel_timer")
	timer.Create("warning_panel_timer", 1, seconds, function()
		seconds = seconds - 1

		if (IsValid(self.AcceptButton)) then
			self.AcceptButton:SetText("OK! (will autoclose in " .. seconds .. " seconds)")
		end

		if (seconds <= 0 and IsValid(self) ) then
			self:Remove()
		end
	end)
end

vgui.Register("MediaPlayer.WarningBox", panel, "MediaPlayer.Base")