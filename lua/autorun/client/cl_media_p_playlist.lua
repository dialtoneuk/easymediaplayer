--[[
Playlist Panel
------------------------------------------------------------------------------
--]]

local panel = {}

panel.Name = "playlist"
panel.InvertPosition = true
panel.ActiveRefresh = true

--Playlist items
panel.Playlist = {}

--Settings
panel.Settings = {
	HideActive = MEDIA.GetSetting("media_playlist_hide_active"),
	AutoResize = MEDIA.GetSetting("media_playlist_autoresize")
}

--[[
Sets up grid and paints our colours
--]]

function panel:Init()
	self:BaseInit()

	if (self.Settings.AutoResize.Value ) then
		self.RescaleHeight = false
	end

	if ( self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
	end

	self:SetTall(self:GetSettingHeight())
	self:SetupGrid()
end

--[[
Creates new DickGrid
--]]

function panel:SetupGrid()
	self.Grid = vgui.Create("DGrid", self )
	self.Grid:DockMargin(5,5,5,5)
	self.Grid:Dock(TOP)
	self.Grid:SetCols( 1 )
	self.Grid:SetWide(self:GetWide())
	self.Grid:SetColWide(self:GetWide())
	self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight )
end

--[[
Autromatically removes videos from our playlist
--]]

function panel:MyThink()
	if (self.Settings.Size != nil and !self.Settings.AutoResize.Value) then
		self:SetTall(self:GetSettingHeight())
	end

	local f = false
	if (!table.IsEmpty(self.Playlist)) then
		for k,v in SortedPairs(self.Playlist) do
			if (!MEDIA.Playlist[v.Video]) then
				self.Playlist[k] = nil
				f = true
			end
		end
		if (f) then
			self:UpdateGrid()
		end
	end

	if (self:HasResized()) then
		if (!f) then
			self:UpdateGrid()
		end

		self.Grid:SetWide(self:GetWide())
		self.Grid:SetColWide(self:GetWide())
		self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight )
	end
end

--[[
Essentially fills our local playlist table and updates the grid.
--]]

function panel:UpdatePlaylist()
	self.Playlist = {}

	if (!MEDIA.Playlist or table.IsEmpty(MEDIA.Playlist)) then self:NoVidPanel() end

	for k,v in pairs(MEDIA.Playlist) do
		self.Playlist[k] = v
	end

	self:UpdateGrid()
end

--[[
Displays playlist items
--]]

function panel:NoVidPanel()
	local p = vgui.Create("DButton", self.Grid )
	p:SetWide(self.Grid:GetWide() - self:GetPadding())
	p:SetTall( self.Settings.Size.Value.RowHeight )
	p:SetText("")
	p.Paint = function(s)
		draw.RoundedBox(5, 0, 0, s:GetWide(), s:GetTall(), MEDIA.Colours.FadedGray )
		draw.SimpleTextOutlined( "EASY!", "SmallText", 10,12, MEDIA.Colours.Red, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "Media Player", "BiggerText", 10, 28, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "v" .. MEDIA.Version, "MediumText", 10, 50, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "(click me)", "MediumText", self.Grid:GetWide() - 70, 65, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
	end

	p.DoClick = function(sel)
		RunConsoleCommand("media_search_panel")
	end


	self.Grid:AddItem(p)
end

--[[

--]]

function panel:UpdateGrid()
	if (IsValid(self.Grid)) then
		self.Grid:Remove()
	end

	self:SetupGrid()

	local size = 0

	if ( table.IsEmpty(self.Playlist)) then
		self:NoVidPanel()
		return
	end

	for k,v in SortedPairsByMemberValue(self.Playlist, "Position") do
		local p = vgui.Create("MEDIA.PlaylistItem", self.Grid )

		if (MEDIA.CurrentVideo and MEDIA.CurrentVideo.Video == v.Video) then
			if (self.Settings.HideActive.Value) then
				p:Remove()
				continue
			end

			p:SetActive()
		end

		p:SetVideo(v)
		p:SetWide(self.Grid:GetWide() - self:GetPadding())
		p:SetTall(self.Settings.Size.Value.RowHeight)
		p:SetItemText()

		self.Grid:AddItem(p)

		size = size + self.Settings.Size.Value.RowHeight
	end

	if (self.Settings.AutoResize.Value) then
		self:SetTall(size + self:GetPadding())
	end

end

--[[
Adds a new video to the playlist
--]]

function panel:AddVideo(video)

	if (!self.Playlist[video.Video]) then
		self.Playlist[video.Video] = video
	end
end

--[[
Removes a video
--]]

function panel:RemoveVideo(video)

	if (self.Playlist[video.Video]) then
		self.Playlist[video.Video] = nil
	end
end

--Register
vgui.Register("MEDIA.PlaylistPanel", panel, "MEDIA.BasePanel")