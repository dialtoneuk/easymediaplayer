--[[
Playlist Panel
------------------------------------------------------------------------------
--]]

local panel = {}

panel.Playlist = {}
panel.Name = "playlist"
panel._RowSpacing = -1
panel._Count = 0

--Settings
panel.Settings = {
	HideActive = "hide_active",
	AutoResize = "auto_resize",
	InvertPosition = "invert_position",
	Options = "options",
	Limit = "show_limit"
}

--on change
panel.OnChange = {
	Size = {
		RowSpacing = function(p)
			if (p:CheckChange("RowSpacing")) then
				p:SetHasRescaled()
			end
		end
	}
}

--[[
Sets up grid and paints our colours
--]]

function panel:Init()
	self:BaseInit()

	self:InvertPosition(true)
	self:Reposition()
	self:SetIgnoreRescaling(true, false)
	self:SetupGrid()

	if ( self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
		end
	end

	if (table.IsEmpty(MediaPlayer.Playlist)) then
		self:EmptyPanel()
	else
		self:UpdatePlaylist()
	end

	self:RecalculateSize()
end

--[[
Creates new DickGrid
--]]

function panel:SetupGrid()
	if (IsValid(self.Grid)) then
		self.Grid:Remove()
	end

	self.Grid = vgui.Create("DGrid", self )

	self:SetGrid()
	self:SetDockPadding()
end


function panel:SetGrid()
	self.Grid:Dock(FILL)
	self.Grid:SetCols( 1 )
	self.Grid:SetWide(self:GetWidth(true))
	self.Grid:SetColWide(self:GetWidth(true, true) - self:GetPadding())
	self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self.Settings.Size.Value.RowSpacing )
end
--[[
Autromatically removes videos from our playlist
--]]

function panel:MyThink()
	if (!self:IsSettingTrue("AutoResize")) then
		self:SetTall(self:GetHeight())
	end

	if (self:IsSettingTrue("InvertPosition")) then
		self:InvertPosition(true)
		self:Reposition()
	end

	local f = false
	if (!table.IsEmpty(self.Playlist)) then
		for k,v in SortedPairs(self.Playlist) do
			if (!MediaPlayer.Playlist[v.Video]) then
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

	if (self:HasRescaled()) then
		self:SetGrid()

		if (IsValid(self.MiscPanel)) then
			self.MiscPanel:SetWide(self:GetWidth(true))
		end

		self:SetDockPadding()

		if (!table.IsEmpty(MediaPlayer.Playlist)) then
			self:UpdateGrid()
		else
			self:RecalculateSize()
		end
	end
end

--[[
Essentially fills our local playlist table and updates the grid.
--]]

function panel:UpdatePlaylist()
	self.Playlist = {}

	if (table.IsEmpty(MediaPlayer.Playlist)) then return end

	local updated = false
	for k,v in pairs(MediaPlayer.Playlist) do

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

	self._Count = table.Count(self.Playlist)
end

--[[
Displays playlist items
--]]

function panel:EmptyPanel()
	self.MiscPanel = vgui.Create("DButton", self.Grid )
	self.MiscPanel:SetWide(self:GetWidth(true))
	self.MiscPanel:SetTall( self.Settings.Size.Value.RowHeight)
	self.MiscPanel:SetText("")
	self.MiscPanel.Paint = function(s)
		draw.RoundedBox(5, 0, 0, self.Settings.Size.Value.Width, self.Settings.Size.Value.RowHeight, MediaPlayer.Colours.FadedGray )
		draw.SimpleTextOutlined( "Easy", "SmallText", 10,12, MediaPlayer.Colours.FadedWhite, 5, 1, 0.5, MediaPlayer.Colours.Black )
		draw.SimpleTextOutlined( "MediaPlayer", "BiggerText", 10, 30, MediaPlayer.Colours.White, 5, 1, 0.5, MediaPlayer.Colours.Black )
		draw.SimpleTextOutlined( "v" .. MediaPlayer.Version, "MediumText", 170, 28, MediaPlayer.Colours.White, 5, 1, 0.5, MediaPlayer.Colours.Black )
		draw.SimpleTextOutlined("No videos queued - click me to search!", "MediumText", 10, 55, MediaPlayer.Colours.FadedWhite, 5, 1, 0.5, MediaPlayer.Colours.Black )
	end

	self.MiscPanel.DoClick = function(s)
		RunConsoleCommand("media_search_panel")
	end

	self.Grid:AddItem(self.MiscPanel)
end


--[[
Displays playlist items
--]]

function panel:CreateFullPanel()
	self.FullPanel = vgui.Create("DButton", self.Grid )
	self.FullPanel:SetWide(self:GetWidth(true, true) - self:GetPadding())
	self.FullPanel:SetTall( math.floor(self.Settings.Size.Value.RowHeight / 2) + self.Settings.Size.Value.RowSpacing )
	self.FullPanel:SetText("")
	self.FullPanel.Paint = function(s)
		surface.SetDrawColor(self.Settings.Colours.Value.Background)
		surface.DrawRect(0, 0, s:GetWide(), s:GetTall(), self.Settings.Options.Value.BorderThickness)
		surface.SetDrawColor(self.Settings.Colours.Value.Border)
		surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall(), self.Settings.Options.Value.BorderThickness)
		draw.SimpleTextOutlined("Playlist Full", "BiggerText", self:GetPadding() + 10, self:GetPadding() + 20, MediaPlayer.Colours.FadedWhite, 5, 1, 0.5, MediaPlayer.Colours.Black )
		draw.SimpleTextOutlined(self._Count  .. " videos in list", "BigText", self:GetPadding() + 150, self:GetPadding() + 22, MediaPlayer.Colours.FadedWhite, 5, 1, 0.5, MediaPlayer.Colours.Black )
	end

	self.Grid:AddItem(self.FullPanel)
end

--[[

--]]

function panel:UpdateGrid()
	self:SetupGrid()

	if (table.IsEmpty(self.Playlist)) then
		return
	end

	local count = 0

	for k,v in SortedPairsByMemberValue(self.Playlist, "Position") do

		if (count > self.Settings.Limit.Value ) then
			self:CreateFullPanel()
			break
		end

		local p = vgui.Create("MediaPlayer.PlaylistItem", self.Grid )

		if (MediaPlayer.CurrentVideo and MediaPlayer.CurrentVideo.Video == v.Video) then

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

		count = count + 1
	end

	if (self:IsSettingTrue("AutoResize")) then
		self:RecalculateSize()
	end
end

function panel:RecalculateSize()
	local count = 0
	for k,v in pairs(self.Grid:GetItems()) do
		count = count + v:GetTall() + self.Settings.Size.Value.RowSpacing
	end

	self:SetTall(count)
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
vgui.Register("MediaPlayer.PlaylistPanel", panel, "MediaPlayer.BasePanel")