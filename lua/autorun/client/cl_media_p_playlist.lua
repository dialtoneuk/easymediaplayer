--[[
Playlist Panel
------------------------------------------------------------------------------
--]]

local panel = {}

panel.Playlist = {}
panel.Name = "playlist"


--Settings
panel.Settings = {
	HideActive = MEDIA.GetSetting("media_playlist_hide_active"),
	AutoResize = MEDIA.GetSetting("media_playlist_auto_resize"),
	InvertPosition = MEDIA.GetSetting("media_playlist_invert_position")
}

--[[
Sets up grid and paints our colours
--]]

function panel:Init()
	self:BaseInit()

	if (self:IsSettingTrue("InvertPosition")) then
		self:InvertPosition(true)
		self:Reposition()
	end

	self:IgnoreRescaling(true, false)
	self:SetupGrid()

	if ( self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
	end

	if (table.IsEmpty(MEDIA.Playlist)) then
		self:EmptyPanel()
	else
		self:UpdatePlaylist()
	end
	if (self:IsSettingTrue("AutoResize")) then
		self:SetTall(self.Settings.Size.Value.RowHeight + self:GetPadding())
	end
end

--[[
Creates new DickGrid
--]]

function panel:SetupGrid()
	if (IsValid(self.Grid)) then
		self.Grid:Remove()
	end

	self.Grid = vgui.Create("DGrid", self )
	self.Grid:Dock(FILL)
	self.Grid:SetCols( 1 )
	self.Grid:SetWide(self:GetPaddedWidth(true, true))
	self.Grid:SetColWide(self:GetPaddedWidth(true, true))
	self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing)

	self:SimpleDockPadding()
end

--[[
Autromatically removes videos from our playlist
--]]

function panel:MyThink()
	if (!self:IsSettingTrue("AutoResize")) then
		self:SetTall(self:GetPaddedHeight())
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
		panel:UpdatePlaylist()
	end

	if (self:HasRescaled()) then
		self.Grid:SetWide(self:GetPaddedWidth(true, true))
		self.Grid:SetColWide(self:GetPaddedWidth(true, true))
		self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing)
	end
end

--[[
Essentially fills our local playlist table and updates the grid.
--]]

function panel:UpdatePlaylist()
	self.Playlist = {}

	if (table.IsEmpty(MEDIA.Playlist)) then return end

	local updated = false
	for k,v in pairs(MEDIA.Playlist) do

		if (self.Playlist[k] == nil ) then
			self.Playlist[k] = v
			updated = true
		end
	end

	if (updated) then
		self:UpdateGrid()
	else
		if (self.MiscPanel != nil ) then
			if (IsValid(self.Grid)) then
				self.Grid:Remove()
			end

			self:SetupGrid()
			self:EmptyPanel()
		end
	end
end

--[[
Displays playlist items
--]]

function panel:EmptyPanel()
	self.MiscPanel = vgui.Create("DButton", self.Grid )
	self.MiscPanel:SetWide(self:GetPaddedWidth(true))
	self.MiscPanel:SetTall(self:GetPaddedHeight(true))
	self.MiscPanel:SetText("")
	self.MiscPanel.Paint = function(s)
		draw.RoundedBox(5, 0, 0, s:GetWide(), s:GetTall(), MEDIA.Colours.FadedGray )
		draw.SimpleTextOutlined( "EASY!", "SmallText", 10,12, MEDIA.Colours.FadedWhite, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "Media Player", "BiggerText", 10, 30, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "v" .. MEDIA.Version, "MediumText", 170, 28, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined("No videos queued - click me to search!", "MediumText", 10, 55, MEDIA.Colours.FadedWhite, 5, 1, 0.5, MEDIA.Colours.Black )
	end

	self.MiscPanel.DoClick = function(s)
		RunConsoleCommand("media_search_panel")
	end

	self.Grid:AddItem(self.MiscPanel)
end

--[[

--]]

function panel:UpdateGrid()
	self:SetupGrid()

	if (table.IsEmpty(self.Playlist)) then
		return
	end

	local size = 0

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

		size = size + (self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing)
	end

	if (self:IsSettingTrue("AutoResize")) then
		self:SetTall(size)
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