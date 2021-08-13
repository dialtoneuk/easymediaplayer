--[[
Playlist Panel
------------------------------------------------------------------------------
--]]

local panel = {}

panel.Name = "playlist"
panel.InvertPosition = true
panel.RescaleHeight = false

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
	self.Grid:DockMargin(5,5,5,5)
	self.Grid:Dock(TOP)
	self.Grid:SetCols( 1 )
	self.Grid:SetRowHeight( 60 )
	self.Grid:SetWide( self:GetWide())
	self.Grid:SetColWide( self:GetWide())
end

--[[
Autromatically removes videos from our playlist
--]]

function panel:MyThink()
	if (self.Settings.AutoResize != nil ) then
		self.Settings.AutoResize = MEDIA.GetSetting("media_playlist_autoresize") or {Value = 0}
	end

	if (self.Settings.Size != nil and self.Settings.AutoResize.Value == 0) then
		self:SetTall(self.Settings.Size.Value.Height)
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

		self.Grid:SetWide( self:GetWide())
		self.Grid:SetColWide( self:GetWide())
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
	local p = vgui.Create("DPanel", self.Grid )
	p:SetWide(self.Grid:GetWide() - 10)
	p:SetTall(60)
	p.Paint = function()
		draw.SimpleTextOutlined( "Nothing Here!", "BiggerText", 10, 20, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
		draw.SimpleTextOutlined( "Play something?", "MediumText", 10, 35, MEDIA.Colours.White, 5, 1, 0.5, MEDIA.Colours.Black )
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
		local p = vgui.Create("MEDIA_PlaylistItem", self.Grid )

		if (MEDIA.CurrentVideo and MEDIA.CurrentVideo.Video == v.Video) then
			if (self.Settings.HideActive.Value == 1 ) then
				p:Remove()
				continue
			end

			p:SetActive()
		end

		p:SetVideo(v)
		p:SetWide(self.Grid:GetWide() - 10)
		p:SetTall(60)
		p:SetTexts()
		self.Grid:AddItem(p)

		size = size + 60
	end

	if (self.Settings.AutoResize.Value == 1 and size != 0 ) then
		self:SetTall(size + 10)
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
vgui.Register("MEDIA_Playlist", panel, "MEDIA_BasePanel")