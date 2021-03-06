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
	Limit = "display_limit"
}

--on change
panel.Updates = {
	Size = {
		RowSpacing = function(p)
			if (p:CheckChange("RowSpacing")) then
				p:SetHasResized()
			end
		end,
		Padding = function(p)
			if (p:CheckChange("Padding")) then
				p:SetHasResized()
			end
		end,
	}
}

--[[
Sets up grid and paints our colours
--]]

function panel:Init()
	self:BaseInit({
		DontResize = {
			Width = false,
			Height = true, --don't resize the height implicitly
		}
	})

	self:SetupGrid()

	if (table.IsEmpty(LydsPlayer.Playlist)) then
		self:EmptyPanel()
	else
		self:UpdatePlaylist()
	end

	self:RecalculateSize()
end

--paints
function panel:Paint()

	if (self.Settings.Colours == nil ) then
		return
	end

	surface.SetDrawColor(self.Settings.Colours.Value.Background)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
	surface.SetDrawColor(self.Settings.Colours.Value.Border)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
	surface.SetDrawColor(self.Settings.Colours.Value.SecondaryBorder or LydsPlayer.Colours.Black )
	surface.DrawOutlinedRect(2, 2, self:GetWide() - 4, self:GetTall() - 4, self.Settings.Options.Value.BorderThickness)
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
end


function panel:SetGrid()
	self.Grid:Dock(FILL)
	self.Grid:SetCols( 1 )
	self.Grid:SetWide(self:GetWidth(true, true))
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
		self:InvertXPosition(true)
		self:Reposition()
	end

	local f = false
	if (!table.IsEmpty(self.Playlist)) then
		for k,v in SortedPairs(self.Playlist) do
			if (!LydsPlayer.Playlist[v.Video]) then
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

		if (!table.IsEmpty(LydsPlayer.Playlist)) then
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

	if (table.IsEmpty(LydsPlayer.Playlist)) then return end

	local updated = false
	for k,v in pairs(LydsPlayer.Playlist) do

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

	if (!IsValid(self.Grid)) then self:SetupGrid() end
	if (IsValid(self.MiscPanel)) then self.MiscPanel:Remove() end

	self.MiscPanel = vgui.Create("DButton", self.Grid )
	self.MiscPanel:SetWide( self:GetWidth() - self:GetPadding() * 2)
	self.MiscPanel:SetTall( self.Settings.Size.Value.RowHeight)
	self.MiscPanel:SetText("")


	local str = LydsPlayer.Name

	self.MiscPanel.Paint = function(s)

		surface.SetFont("BiggerText")
		local len = surface.GetTextSize(str)

		draw.RoundedBox(5, 0, 0, self:GetWidth() - self:GetPadding() * 2, self.Settings.Size.Value.RowHeight, self.Settings.Colours.Value.ItemBackground )
		draw.SimpleTextOutlined( str, "BiggerText", 10, 20, self.Settings.Colours.Value.TextColor, 5, 1, 0.5, LydsPlayer.Colours.Black )
		draw.SimpleTextOutlined( "v" .. LydsPlayer.Version, "MediumText", len + 17, 15, self.Settings.Colours.Value.TextColor, 5, 1, 0.5, LydsPlayer.Colours.Black )
		draw.SimpleTextOutlined("No videos queued - click me to search!", "MediumText", 10, 45,self.Settings.Colours.Value.TextColor, 5, 1, 0.5, LydsPlayer.Colours.Black )
	end

	self.MiscPanel.DoClick = function(s)
		RunConsoleCommand("search_panel")
	end

	self.Grid:AddItem(self.MiscPanel)
end


--[[
Displays playlist items
--]]

function panel:CreateFullPanel()

	if (IsValid(self.FullPanel)) then self.FullPanel:Remove() end

	self.FullPanel = vgui.Create("DButton", self.Grid )
	self.FullPanel:SetWide(self:GetWidth() - self:GetPadding() * 2 )
	self.FullPanel:SetTall( self.Settings.Size.Value.RowHeight - ( self:GetPadding() * 2 ) )
	self.FullPanel:SetText("")
	self.FullPanel.Paint = function(s)
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
		surface.DrawRect(0, 0, s:GetWide(), s:GetTall())
		surface.SetDrawColor(self.Settings.Colours.Value.Border)
		surface.DrawOutlinedRect(0, 0, s:GetWide(), s:GetTall(), self.Settings.Options.Value.BorderThickness)
		draw.SimpleText("Playlist Full", "BiggerText", self:GetPadding(), ( s:GetTall() / 2 ) - 15 , LydsPlayer.Colours.FadedWhite )
		draw.SimpleText(self._Count  .. " videos in total", "PlaylistText", self:GetPadding() + 135, ( s:GetTall() / 2 ) - 10, LydsPlayer.Colours.FadedWhite)
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

		if (count == self.Settings.Limit.Value ) then
			self:CreateFullPanel()
			break
		end

		local p = vgui.Create("LydsPlayer.PlaylistItem", self )

		if (LydsPlayer.CurrentVideo and LydsPlayer.CurrentVideo.Video == v.Video) then

			if (self:IsSettingTrue("HideActive")) then
				p:Remove()
				continue
			end

			p:SetActive()
		end

		p:SetVideo(v)
		p:SetTall(self.Settings.Size.Value.RowHeight)
		p:SetWide(self:GetWidth() - self:GetPadding() * 2 )
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

	if (count > 1 ) then
		count = count - self.Settings.Size.Value.RowSpacing
	else
		count = count + self.Settings.Size.Value.RowSpacing
	end

	self:SetTall(count + self:GetPadding() * 2)
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
vgui.Register("LydsPlayer.PlaylistPanel", panel, "LydsPlayer.BasePanel")