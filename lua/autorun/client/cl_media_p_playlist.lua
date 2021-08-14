--[[
Playlist Panel
------------------------------------------------------------------------------
--]]

local panel = {}

panel.Playlist = {}
panel.Name = "playlist"
panel.InvertPosition = true
panel.RescaleHeight = false

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
	self:SetupGrid()

	if ( self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
	end
end

--[[
Creates new DickGrid
--]]

function panel:SetupGrid()
	self.Grid = vgui.Create("DGrid", self )
	self.Grid:Dock(FILL)
	self.Grid:SetCols( 1 )
	self.Grid:SetWide(self:GetSettingWidth(true, true))
	self.Grid:SetColWide(self:GetSettingWidth(true, true))
	self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight )
	self:SimpleDockMargin(self.Grid)
end

--[[
Autromatically removes videos from our playlist
--]]

function panel:MyThink()
	if (!self:IsSettingTrue("AutoResize")) then
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
	else
		self:UpdatePlaylist()
	end

	if (self:HasResized()) then
		if (!f) then
			self:UpdateGrid()
		end

		self.Grid:SetWide(self:GetSettingWidth(true, true))
		self.Grid:SetColWide(self:GetSettingWidth(true, true))
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
	p:SetWide(self.Grid:GetWide())
	p:SetTall( self.Settings.Size.Value.RowHeight )
	p:SetText("")
	p.Paint = function(s)
		draw.RoundedBox(5, 0, 0, self.Grid:GetWide(), s:GetTall(), MEDIA.Colours.FadedGray )
		draw.SimpleTextOutlined( "EASY!", "SmallText", 10,12, MEDIA.Colours.FadedWhite, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "Media Player", "BiggerText", 10, 30, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "v" .. MEDIA.Version, "MediumText", 170, 28, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined("No videos queued", "MediumText", 10, 55, MEDIA.Colours.FadedWhite, 5, 1, 0.5, MEDIA.Colours.Black )
	end

	p.DoClick = function(s)
		print("it work again?")
	end

	self.Grid:AddItem(p)

	if (self:IsSettingTrue("AutoResize")) then
		self:SetTall(self.Settings.Size.Value.RowHeight + (self:GetPadding() * 2) )
	end
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
			if (self:IsSettingTrue("HideActive")) then
				p:Remove()
				continue
			end

			p:SetActive()
		end

		p:SetVideo(v)
		p:SetTall(self.Settings.Size.Value.RowHeight)
		p:SetItemText()

		self.Grid:AddItem(p)

		size = size + self.Settings.Size.Value.RowHeight
	end

	if (self:IsSettingTrue("AutoResize")) then
		self:SetTall(size + (self:GetPadding() * 2) )
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