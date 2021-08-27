local panel = {}

panel.Name = "search"

panel.Settings = {
	PageLimit = "page_limit",
	ColumnCount = "column_count",
	ColumnWidth = "column_width",
}

function panel:Init()

	self:BaseInit({
		DontResize = {
			Width = true,
			Height = true,
		},
		Declare = {
			Type = MediaPlayer.MediaType.YOUTUBE,
			LastValue = ""
		}
	})

	self.ScrollPanel = vgui.Create("DScrollPanel", self)
	self.SearchBox = vgui.Create("DTextEntry", self )
	self.ComboBox = vgui.Create( "DComboBox", self.SearchBox )
	self.SearchButton = vgui.Create( "DButton", self.SearchBox )
	self.ColumnWidth = self.Settings.ColumnWidth.Value

	self:SetUpGrid()

	self.ScrollPanel:Dock(FILL)
	self:SetDockMargin(self.ScrollPanel, 2)

	self:SetDockMargin(self.SearchBox, 2 )
	self.SearchBox:SetTall(40)
	self.SearchBox:Dock(TOP)
	self.SearchBox:SetPlaceholderText("Press enter to search this media platform for content")

	self.SearchBox.OnEnter = function()
		local value = string.Trim(self.SearchBox:GetValue())

		if (value != "" and self.LastValue != value ) then
			RunConsoleCommand("media_search", self.ComboBox:GetValue(), value )

			self.LastValue = value
			self.SearchBox:SetDisabled(true)
			self.SearchButton:SetDisabled(true)

			timer.Simple(1, function()
				if (!IsValid(self.SearchBox)) then return end
				self.SearchBox:SetDisabled(false)
			end)
		end
	end

	self.SearchBox.OnChange = function()
		self.SearchButton:SetDisabled(false)
		local value = string.Trim(self.SearchBox:GetValue())

		if (value == "" or value == self.LastValue) then
			self.SearchButton:SetDisabled(true)
		end
	end

	self.SearchButton:SetTall(30)
	self.SearchButton:Dock(RIGHT)
	self.SearchButton:SetText("Search")
	self.SearchButton:SetWidth(100)
	self.SearchButton:SetIcon("icon16/world.png")
	self.SearchButton:SetDisabled(true)
	self.SearchButton.DoClick = self.SearchBox.OnEnter

	self:RebuildComboBox()
end

function panel:RebuildComboBox()

	if (IsValid(self.ComboBox)) then self.ComboBox:Remove() end

	self.ComboBox = vgui.Create("DComboBox", self.SearchBox)
	self.ComboBox:SetTall(30)
	self.ComboBox:SetWide(self:GetWidth() / 6)
	self.ComboBox:Dock(RIGHT)
	self.ComboBox:SetValue( next(MediaPlayer.EnabledMediaTypes) )

	for k,v in pairs(MediaPlayer.EnabledMediaTypes) do
		self.ComboBox:AddChoice(k)
	end
end

function panel:SetUpGrid()

	if (IsValid(self.Grid)) then self.Grid:Remove() end

	self.Grid = vgui.Create("DGrid", self.ScrollPanel )
	self:SetDockMargin(self.Grid)

	self.Grid:SetCols( self:GetSettingInt("ColumnCount") )
	self.Grid:SetTall(self:GetHeight())
	self.Grid:SetColWide( self.ColumnWidth )
	self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding() * 2 )
end

function panel:SetType(typ)
	self.Type = typ
	self.ComboBox:SetValue(self.Type)
end

function panel:SetResults(results)
	self:ClearGrid()

	local limit = table.Copy(self.Settings.PageLimit).Value

	for k,v in pairs(results) do
		if (limit == 0 ) then
			self.Grid:AddItem(self:FullPanel())
			break
		end

		self.Grid:AddItem(self:ResultPanel(v))

		limit = limit - 1
	end
end

function panel:ClearGrid()
	self:SetUpGrid()
end

function panel:AddDefaultPanel()
	if (!IsValid(self.Grid)) then return end

	--adds default pls search panel
	self.Grid:AddItem(self:DefaultPanel())
end

function panel:DefaultPanel()
	local pan = vgui.Create("DButton", self.Grid )
	pan:SetWide( self.ColumnWidth - self:GetPadding() )
	pan:SetHeight(self.Settings.Size.Value.RowHeight)
	pan:SetText("")

	self:SetDockPadding(pan)

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
		surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
	end

	local title = vgui.Create("DLabel", pan )
	title:SetWide(self:GetWidth(true, true))
	title:Dock(TOP)
	title:SetText("No search results!")
	title:SetFont("BiggerText")
	title:SetTextColor(self.Settings.Colours.Value.TextColor)


	local subtitle = vgui.Create("DLabel", pan )
	subtitle:SetWide(self:GetWidth(true, true))
	subtitle:Dock(BOTTOM)
	subtitle:DockMargin(0, 0, 0, self:GetPadding() * 2)
	subtitle:SetText("Use the search box above to find the media you want to play.")
	subtitle:SetTall(self.Settings.Size.Value.RowHeight / 2)
	subtitle:SetWrap(true)
	subtitle:SetFont("BigText")
	subtitle:SetTextColor(self.Settings.Colours.Value.TextColor)

	return pan
end

function panel:FullPanel()
	local pan = vgui.Create("DButton", self.Grid )
	pan:SetWide( self.ColumnWidth - self:GetPadding() )
	pan:SetHeight(self.Settings.Size.Value.RowHeight)
	pan:SetText("")

	self:SetDockPadding(pan)

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
		surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
	end
	local title = vgui.Create("DLabel", pan )
	title:SetWide(self:GetWidth(true, true))
	title:Dock(TOP)
	title:SetText("Max Results")
	title:SetFont("BiggerText")
	title:SetTextColor(self.Settings.Colours.Value.TextColor)

	local subtitle = vgui.Create("DLabel", pan )
	subtitle:SetWide(self:GetWidth(true, true))
	subtitle:Dock(BOTTOM)
	subtitle:DockMargin(0, 0, 0, self:GetPadding() * 2)
	subtitle:SetText("Use the web browser if you still cant find what you want.")
	subtitle:SetTall(self.Settings.Size.Value.RowHeight / 2)
	subtitle:SetWrap(true)
	subtitle:SetFont("BigText")
	subtitle:SetTextColor(self.Settings.Colours.Value.TextColor)

	return pan
end

function panel:ResultPanel(result)
	local pan = vgui.Create("DButton", self.Grid )
	pan:SetWide( self.ColumnWidth - self:GetPadding() )
	pan:SetHeight(self.Settings.Size.Value.RowHeight)
	pan:SetText("")

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
		surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
	end

	pan.DoClick = function()

		if (!table.IsEmpty(MediaPlayer.CurrentVideo) and result.Video == MediaPlayer.CurrentVideo.Video ) then
			MediaPlayer.CreateWarningBox("Video alreay present","Video is currently playing")
			return
		end

		if (!table.IsEmpty(MediaPlayer.Playlist) and  MediaPlayer.Playlist[result.Video] != nil ) then
			MediaPlayer.CreateWarningBox("Video alreay present","Video already in playlist!")
			return
		end

		if (MediaPlayer.PanelValid("SearchPanel")) then
			MediaPlayer.GetPanel("SearchPanel"):ShowVideoInfo(result)
		end
	end

	local title = vgui.Create("DLabel", pan )
	title:SetWide(self:GetWidth(true, true))
	title:SetPos(5, 5)
	title:SetText(result.Title)
	title:SetFont("BigText")
	title:SetTextColor(self.Settings.Colours.Value.TextColor)

	local creator = vgui.Create("DLabel", pan )
	creator:SetWide(self:GetWidth(true, true))
	creator:SetPos(5, 20)
	creator:SetText(result.Creator)
	creator:SetFont("MediumText")
	creator:SetTextColor(self.Settings.Colours.Value.TextColor)


	local thumbnail = vgui.Create("DHTML", pan)
	thumbnail:Dock(RIGHT)
	thumbnail:SetSize( self.Settings.Size.Value.RowHeight, self.Settings.Size.Value.RowHeight)
	thumbnail:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src=" .. ( result.Thumbnail or "" ) .. "></img>")
	thumbnail:SetMouseInputEnabled(false)

	return pan
end

--Register
vgui.Register("MediaPlayer.SearchContainer", panel, "MediaPlayer.BasePanel")