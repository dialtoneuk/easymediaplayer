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
	self.Thumbnail:SetSize( self.Settings.Size.Value.RowHeight, self.Settings.Size.Value.RowHeight)

	self.Title = vgui.Create("DLabel", self  )
	self.Title:SetWide(self:GetWidth(true, true))
	self.Title:Dock(TOP)
	self.Title:SetFont("BigText")
	self.Title:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Creator = vgui.Create("DLabel", self  )
	self.Creator:SetWide(self:GetWidth(true, true))
	self.Creator:Dock(TOP)
	self.Creator:SetFont("MediumText")
	self.Creator:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Type = vgui.Create("DLabel", self  )
	self.Type:SetWide(self:GetWidth(true, true))
	self.Type:Dock(TOP)
	self.Type:SetFont("MediumText")
	self.Type:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Button = vgui.Create("DButton", self )
	self.Button:SetText("Add To Playlist")
	self.Button:SetTall(30)
	self.Button:DockMargin(0, 0, self:GetPadding() * 2, 0)
	self.Button:Dock(BOTTOM)
end

function panel:SetVideo(video)

	self.Title:SetText(video.Title)
	self.Creator:SetText(video.Creator)
	self.Thumbnail:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src=" .. ( video.Thumbnail or "" ) .. "></img>")
	self.Type:SetText(video.Type)

	self.Button.DoClick = function()
		RunConsoleCommand("media_play", video.Type, video.Video)
		self.Parent.SearchController:Hide()
		self.Parent.SearchContainer:Dock(FILL)
	end
end

vgui.Register("MediaPlayer.SearchItem", panel, "MediaPlayer.BasePanel")