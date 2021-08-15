--[[
Playlist Panel
------------------------------------------------------------------------------
--]]

local panel = {}

panel.Playlist = {}
panel.Name = "playlist"
panel._RowSpacing = -1

--Settings
panel.Settings = {
	HideActive = "hide_active",
	AutoResize = "auto_resize",
	InvertPosition = "invert_position",
	Options = "options"
}

--on chhange
panel.OnChange = {
	RowSpacing = function(p)
		if (p._RowSpacing and p._RowSpacing != p.Settings.Size.Value.RowSpacing ) then
			p._RowSpacing = p.Settings.Size.Value.RowSpacing
			p._Rescaled = true
		end
	end
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
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
		end
	end

	if (table.IsEmpty(MEDIA.Playlist)) then
		self:EmptyPanel()
	else
		self:UpdatePlaylist()
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
	self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing )

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
		self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing )

		if (IsValid(self.MiscPanel)) then
			self.MiscPanel:SetWide(self:GetPaddedWidth(true))
		end

		self:SimpleDockPadding()

		if (!table.IsEmpty(MEDIA.Playlist)) then
			self:UpdateGrid()
		else
			self:SetTall(self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing + ( self:GetPadding() * 2 ))
		end
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
	self.MiscPanel:SetTall( self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing )
	self.MiscPanel:SetText("")
	self.MiscPanel.Paint = function(s)
		draw.RoundedBox(5, 0, 0, self.Settings.Size.Value.Width, self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing , MEDIA.Colours.FadedGray )
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
	local count = 0

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

		if (count != 0 ) then
			size = size + (self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing)
		else
			size = self.Settings.Size.Value.RowHeight
		end

		count = count + 1
	end

	if (self:IsSettingTrue("AutoResize")) then
		self:SetTall(size + ( self:GetPadding() * 2 ) )
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