local panel = {}

panel.Name = "search"

function panel:Init()
	self:BaseInit({
		DontResize = {
			Width = true,
			Height = true
		}
	})

	self:SetDockPadding(self, 4)

	self.Title = vgui.Create("DLabel", self  )
	self.Title:Dock(TOP)
	self.Title:SetFont("BigText")
	self.Title:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Creator = vgui.Create("DLabel", self  )
	self.Creator:Dock(TOP)
	self.Creator:SetFont("MediumText")
	self.Creator:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Type = vgui.Create("DLabel", self  )
	self.Type:Dock(TOP)
	self.Type:SetFont("MediumText")
	self.Type:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Description = vgui.Create("DLabel", self  )
	self.Description:Dock(TOP)
	self.Description:SetFont("MediumText")
	self.Description:SetTall(35)
	self.Description:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Description:SetWrap(true)


	self.Engagements = vgui.Create("DLabel", self  )
	self.Engagements:Dock(TOP)
	self.Engagements:SetFont("MediumText")
	self.Engagements:SetTall(30)
	self.Engagements:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Engagements:SetWrap(true)
	self.Engagements:DockMargin(0, 0, self:GetPadding() * 2, 0)

	self.Button = vgui.Create("DButton", self )
	self.Button:SetText("Add To Playlist")
	self.Button:SetTall(30)
	self.Button:DockMargin(0, 0, self:GetPadding() * 2, 0)
	self.Button:Dock(BOTTOM)
end

function panel:Paint()
	surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
	surface.DrawRect(0, 0, self:GetWide() - self:GetPadding(), self:GetTall() )
	surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
	surface.DrawOutlinedRect(0, 0, self:GetWide() - self:GetPadding(), self:GetTall(),  self.Settings.Options.Value.BorderThickness )
end

function panel:SetVideo(video, k)

	self.Creator:SetWide(self:GetWide())
	self.Description:SetWide(self:GetWide())
	self.Title:SetWide(self:GetWide())
	self.Type:SetWide(self:GetWide())

	self.Title:SetText("[" .. ( k or "U") .. "] " .. ( video.Title or "Unknown Title" ) )
	self.Creator:SetText(video.Creator or "Unknown Creator")
	self.Description:SetText(video.Description or "No Description...")
	self.Engagements:SetText("Likes: " .. (video.Likes or 0) .. " / Dislikes: " .. (video.Dislikes or 0)  .. " / Plays: " .. (video.Plays or 0))

	if (video.LastPlayed != nil) then
		self.Type:SetText("last played " ..  os.date( "%H:%M:%S - %d/%m/%Y" , video.LastPlayed ))
	end

	if (LydsPlayer.CurrentVideo == video.Video or LydsPlayer.Playlist[video.Video]) then
		self.Button:SetDisabled(true)
	end

	self.Button.DoClick = function()
		RunConsoleCommand("media_play", video.Type, video.Video)
		self.Button:SetDisabled(true)
	end
end
vgui.Register("LydsPlayer.SearchItemHistory", panel, "LydsPlayer.BasePanel")