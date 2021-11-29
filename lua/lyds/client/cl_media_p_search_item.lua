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

	self.Thumbnail = vgui.Create("DHTML", self )
	self.Thumbnail:Dock(RIGHT)
	self.Thumbnail:SetSize( self.Settings.Size.Value.RowHeight * 2, self.Settings.Size.Value.RowHeight)

	self.Title = vgui.Create("DLabel", self  )
	self.Title:Dock(TOP)
	self.Title:SetFont("BigText")
	self.Title:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Creator = vgui.Create("DLabel", self  )
	self.Creator:Dock(TOP)
	self.Creator:SetFont("MediumText")
	self.Creator:SetTextColor(self.Settings.Colours.Value.TextColor)


	self.Description = vgui.Create("DLabel", self  )
	self.Description:Dock(TOP)
	self.Description:SetFont("MediumText")
	self.Description:SetTall(40)
	self.Description:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Description:SetWrap(true)

	self.Type = vgui.Create("DLabel", self  )
	self.Type:Dock(TOP)
	self.Type:SetFont("MediumText")
	self.Type:SetTextColor(self.Settings.Colours.Value.TextColor)

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

function panel:SetVideo(video)

	self.Creator:SetWide(self:GetWide())
	self.Description:SetWide(self:GetWide())
	self.Title:SetWide(self:GetWide())
	self.Type:SetWide(self:GetWide())

	self.Title:SetText(video.Title or "Unknown Title")
	self.Creator:SetText(video.Creator or "Unknown Creator")
	self.Description:SetText(video.Description or "No Description...")

	if (video.Thumbnail != nil ) then
		self.Thumbnail:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src='" .. video.Thumbnail .. "'></img>")
	end

	if (video.LastPlayed != nil) then
		self.Type:SetText("Video was last played " ..  os.date( "%H:%M:%S - %d/%m/%Y" , video.LastPlayed ))
	else
		self.Type:SetText("hosted on " .. video.Type)
	end

	self.Button.DoClick = function()
		RunConsoleCommand("media_play", video.Type, video.Video)
		MediaPlayer.HidePanel("SearchPanel") --hide the search panel
	end
end

vgui.Register("MediaPlayer.SearchItem", panel, "MediaPlayer.BasePanel")