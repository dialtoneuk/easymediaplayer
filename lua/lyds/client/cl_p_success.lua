local panel = {}

panel.Name = "success"

function panel:Init()
	self:BaseInit()

	if (self:IsSettingTrue("InvertPosition")) then
		self:InvertPosition(true)
	end

	self:Reposition()

	--add warning box here
	self.Label = vgui.Create("DLabel", self )
	self.Label:Dock(FILL)
	self.Label:SetFont("BiggerText")
	self.Label:SetTextColor( self.Settings.Colours.Value.TextColor )

	self:SetDockMargin(self.Label, 4)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(self.Settings.Colours.Value.Background)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(self.Settings.Colours.Value.Border)
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
	end

	self.AcceptButton = vgui.Create("DButton", self )
	self.AcceptButton:Dock(BOTTOM)
	self.AcceptButton:SetTall(50)
	self.AcceptButton:DockMargin(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
	self.AcceptButton:SetText("OK!")
	self.AcceptButton.DoClick = function()
		self:OnClicked()
	end

	self.KeepButton = vgui.Create("DButton", self )
	self.KeepButton:Dock(BOTTOM)
	self.KeepButton:DockMargin(self:GetPadding(),0,self:GetPadding(),0)
	self.KeepButton:SetText("Keep Open")
	self.KeepButton:Hide()
	self.KeepButton.DoClick = function()
		self.KeepButton:Hide()
		self.AcceptButton:SetText("OK!")
		timer.Remove("success_panel_timer")
	end

	self:SetDockPadding(self, 4)
end

function panel:OnClicked()
	timer.Remove("success_panel_timer")
	self:Remove()
end

function panel:SetBox(title, message, start_timeout)
	title = title or "Success"
	start_timeout = start_timeout or true

	if (message != self.LastMessage) then
		self:SetTitle(title)
		self.Label:SetText(message)
		self.Label:SetWrap(true)
		self:SetDockPadding(self.Label, 4)

		self.LastMessage = message

		if (start_timeout != false) then
			local seconds = 10

			if (type(start_timeout) == "number" ) then
				seconds = start_timeout
			end

			self:SetTimeout(seconds)
		end
	end
end

function panel:SetTimeout(seconds)
	seconds = seconds or 10

	self.AcceptButton:SetText("OK! (will autoclose in " .. seconds .. " seconds)")
	self.KeepButton:Show()

	timer.Remove("success_panel_timer")
	timer.Create("success_panel_timer", 1, seconds, function()
		seconds = seconds - 1

		if (IsValid(self.AcceptButton)) then
			self.AcceptButton:SetText("OK! (will autoclose in " .. seconds .. " seconds)")
		end

		if (seconds <= 0 and IsValid(self) ) then
			self:Remove()
		end
	end)
end

vgui.Register("MediaPlayer.SuccessBox", panel, "MediaPlayer.Base")
